--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local BaseConfigurations = ItemConfigsModule.BaseConfigurations

local PlayerController
local WaveController

local RESTOCK_INTERVAL_SECONDS = 300

local BaseShopController = {}

local BASES_FOLDER = ReplicatedStorage:WaitForChild("Bases")
local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

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
local cashUpdatedEvent: RemoteEvent
local getBaseDataFunc: RemoteFunction
local updateStocksEvent: RemoteEvent
local getResetTime: RemoteFunction
local getStocks: RemoteFunction

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

function BaseShopController:Restock(player: Player, suppressNotification: boolean?)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local newStock = {}
	for baseId in pairs(BaseConfigurations) do
		newStock[baseId] = 1
	end

	profile.Data.BaseShopStock = newStock
	profile.Data.BaseShopNextRestock = os.time() + RESTOCK_INTERVAL_SECONDS

	updateStocksEvent:FireClient(player, newStock)
	if not suppressNotification then
		showNotificationEvent:FireClient(player, "The Bases Shop has been restocked!", "Normal")
	end
end

function BaseShopController:EquipBase(player: Player, baseId: string, forceEquip: boolean?)
	local config = BaseConfigurations[baseId]
	if not config then
		warn("[BaseShopController] Unknown baseId:", baseId)
		return
	end

	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	profile.Data.EquippedBase = baseId

	local plot = getPlotForPlayer(player)
	if not plot then
		if baseDataUpdatedEvent then
			baseDataUpdatedEvent:FireClient(player, profile.Data.OwnedBases, profile.Data.EquippedBase)
		end
		return
	end

	local currentCore = plot:FindFirstChild("Core1")
	local coreCFrame = currentCore and currentCore:GetPivot() or CFrame.new()

	local template = BASES_FOLDER:FindFirstChild(baseId)
	if template then
		if currentCore then currentCore:Destroy() end
		local newCore = template:Clone()
		newCore.Name = "Core1"
		newCore:PivotTo(coreCFrame)
		newCore:SetAttribute("MaxHealth", config.Health)
		newCore:SetAttribute("Health", config.Health)
		newCore.Parent = plot
	else
		if currentCore then
			currentCore:SetAttribute("MaxHealth", config.Health)
			currentCore:SetAttribute("Health", config.Health)
		end
	end

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

	purchaseBaseEvent    = getOrCreate(eventsFolder, "RemoteEvent", "PurchaseBase") :: RemoteEvent
	equipBaseEvent       = getOrCreate(eventsFolder, "RemoteEvent", "EquipBase") :: RemoteEvent
	baseDataUpdatedEvent = getOrCreate(eventsFolder, "RemoteEvent", "BaseDataUpdated") :: RemoteEvent
	cashUpdatedEvent     = getOrCreate(eventsFolder, "RemoteEvent", "CashUpdated") :: RemoteEvent
	getBaseDataFunc      = getOrCreate(functionsFolder, "RemoteFunction", "GetBaseData") :: RemoteFunction
	updateStocksEvent    = getOrCreate(eventsFolder, "RemoteEvent", "UpdateBaseStocks") :: RemoteEvent
	getResetTime         = getOrCreate(functionsFolder, "RemoteFunction", "GetBasesShopResetTime") :: RemoteFunction
	getStocks            = getOrCreate(functionsFolder, "RemoteFunction", "GetBasesShopStocks") :: RemoteFunction

	getResetTime.OnServerInvoke = function(player: Player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.BaseShopNextRestock
	end

	getStocks.OnServerInvoke = function(player: Player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.BaseShopStock
	end

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

		if baseId == "Core1" then return end

		if table.find(profile.Data.OwnedBases, baseId) then
			showNotificationEvent:FireClient(player, "You already own " .. config.DisplayName .. "!", "Error")
			return
		end

		local stock = profile.Data.BaseShopStock or {}
		if (stock[baseId] or 0) <= 0 then
			showNotificationEvent:FireClient(player, "This base is out of stock!", "Error")
			return
		end

		if profile.Data.Cash < config.Price then
			showNotificationEvent:FireClient(player, "Not enough cash!", "Error")
			return
		end

		profile.Data.Cash -= config.Price
		table.insert(profile.Data.OwnedBases, baseId)

		stock[baseId] = 0
		profile.Data.BaseShopStock = stock

		cashUpdatedEvent:FireClient(player, profile.Data.Cash)
		showNotificationEvent:FireClient(player, config.DisplayName .. " purchased!", "Success")

		self:EquipBase(player, baseId)

		updateStocksEvent:FireClient(player, stock)
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
