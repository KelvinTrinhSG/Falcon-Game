--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local BaseConfigurations = ItemConfigsModule.BaseConfigurations

local PlayerController
local WaveController

local BaseShopController = {}

local BASES_FOLDER = ReplicatedStorage:WaitForChild("Bases")
local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

-- Create events if they don't exist yet
local function getOrCreate(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = parent
	return obj
end

local purchaseBaseEvent: RemoteEvent
local equipBaseEvent: RemoteEvent
local baseDataUpdatedEvent: RemoteEvent
local getBaseDataFunc: RemoteFunction

local function getPlotForPlayer(player: Player): Model?
	local plotNum = player:GetAttribute("PlotNumber")
	if not plotNum then return nil end
	local plots = game:GetService("Workspace"):WaitForChild("Plots")
	local plot = plots:FindFirstChild("Plot" .. plotNum)
	if plot and plot:GetAttribute("OwnerId") == player.UserId then
		return plot
	end
	return nil
end

function BaseShopController:EquipBase(player: Player, baseId: string, forceEquip: boolean?)
	print(string.format("[BaseShopController] EquipBase called | player=%s baseId=%s forceEquip=%s", player.Name, tostring(baseId), tostring(forceEquip)))

	local config = BaseConfigurations[baseId]
	if not config then
		warn("[BaseShopController] Unknown baseId:", baseId)
		return
	end

	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn("[BaseShopController] No profile for", player.Name)
		return
	end

	-- Save preference first so it persists even if model swap fails
	profile.Data.EquippedBase = baseId
	print(string.format("[BaseShopController] profile.Data.EquippedBase set → '%s' for %s", baseId, player.Name))

	local plot = getPlotForPlayer(player)
	if not plot then
		warn(string.format("[BaseShopController] Plot not found for %s (PlotNumber=%s)", player.Name, tostring(player:GetAttribute("PlotNumber"))))
		if baseDataUpdatedEvent then
			baseDataUpdatedEvent:FireClient(player, profile.Data.OwnedBases, profile.Data.EquippedBase)
		end
		return
	end

	print(string.format("[BaseShopController] Plot found: %s", plot.Name))

	local currentCore = plot:FindFirstChild("Core1")
	local coreCFrame = currentCore and currentCore:GetPivot() or CFrame.new()

	-- Swap model (all bases including Core1 should be in ReplicatedStorage/Bases/)
	local template = BASES_FOLDER:FindFirstChild(baseId)
	if template then
		print(string.format("[BaseShopController] Template found for '%s', swapping model", baseId))
		if currentCore then currentCore:Destroy() end
		local newCore = template:Clone()
		newCore.Name = "Core1"
		newCore:PivotTo(coreCFrame)
		newCore:SetAttribute("MaxHealth", config.Health)
		newCore:SetAttribute("Health", config.Health)
		newCore.Parent = plot
	else
		warn(string.format("[BaseShopController] No template in ReplicatedStorage/Bases/%s — only updating health attributes", baseId))
		-- Model not in ReplicatedStorage/Bases, just update health attributes
		if currentCore then
			currentCore:SetAttribute("MaxHealth", config.Health)
			currentCore:SetAttribute("Health", config.Health)
		end
	end

	-- Sync health UI if currently fighting
	if WaveController and WaveController:IsPlayerFighting(player) then
		local core = plot:FindFirstChild("Core1")
		local currentHealth = core and (core:GetAttribute("Health") or config.Health) or config.Health
		ReplicatedStorage.Events.WaveStateChanged:FireClient(player, true, currentHealth, config.Health)
	end

	if not forceEquip then
		showNotificationEvent:FireClient(player, config.DisplayName .. " equipped!", "Success")
	end

	if baseDataUpdatedEvent then
		baseDataUpdatedEvent:FireClient(player, profile.Data.OwnedBases, profile.Data.EquippedBase)
	end
end

function BaseShopController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	WaveController = controllers.WaveController
end

function BaseShopController:Start()
	local eventsFolder = ReplicatedStorage.Events
	local functionsFolder = ReplicatedStorage.Functions

	purchaseBaseEvent   = getOrCreate(eventsFolder, "RemoteEvent", "PurchaseBase") :: RemoteEvent
	equipBaseEvent      = getOrCreate(eventsFolder, "RemoteEvent", "EquipBase") :: RemoteEvent
	baseDataUpdatedEvent = getOrCreate(eventsFolder, "RemoteEvent", "BaseDataUpdated") :: RemoteEvent
	getBaseDataFunc     = getOrCreate(functionsFolder, "RemoteFunction", "GetBaseData") :: RemoteFunction

	getBaseDataFunc.OnServerInvoke = function(player: Player)
		local profile = PlayerController:GetProfile(player)
		if not profile then return {}, "Core1" end
		return profile.Data.OwnedBases or {"Core1"}, profile.Data.EquippedBase or "Core1"
	end

	purchaseBaseEvent.OnServerEvent:Connect(function(player: Player, baseId: string)
		local config = BaseConfigurations[baseId]
		if not config then return end

		local profile = PlayerController:GetProfile(player)
		if not profile then return end

		-- Core1 is free and always owned
		if baseId == "Core1" then return end

		-- Already owned
		if table.find(profile.Data.OwnedBases, baseId) then
			showNotificationEvent:FireClient(player, "You already own " .. config.DisplayName .. "!", "Error")
			return
		end

		-- Check cash
		if profile.Data.Cash < config.Price then
			showNotificationEvent:FireClient(player, "Not enough cash!", "Error")
			return
		end

		profile.Data.Cash -= config.Price
		table.insert(profile.Data.OwnedBases, baseId)

		ReplicatedStorage.Events.CashUpdated:FireClient(player, profile.Data.Cash)
		showNotificationEvent:FireClient(player, config.DisplayName .. " purchased!", "Success")

		self:EquipBase(player, baseId)
	end)

	equipBaseEvent.OnServerEvent:Connect(function(player: Player, baseId: string)
		local profile = PlayerController:GetProfile(player)
		if not profile then return end

		if not table.find(profile.Data.OwnedBases, baseId) then
			showNotificationEvent:FireClient(player, "You don't own this base!", "Error")
			return
		end

		self:EquipBase(player, baseId)
	end)
end

return BaseShopController
