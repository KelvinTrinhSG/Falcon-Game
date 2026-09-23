--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local MapConfigurations = ItemConfigsModule.MapConfigurations

local PlayerController
local PlotController
local WaveController
local PlacementController

local MapsShopController = {}

local showNotificationEvent: RemoteEvent
local purchaseMapEvent: RemoteEvent
local selectMapEvent: RemoteEvent
local mapDataUpdatedEvent: RemoteEvent
local getMapDataFunc: RemoteFunction

local function getOrCreate(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = parent
	return obj
end

function MapsShopController:SelectMap(player: Player, mapId: string, silent: boolean?)
	local config = MapConfigurations[mapId]
	if not config then return end

	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	if WaveController and WaveController:IsPlayerFighting(player) then
		showNotificationEvent:FireClient(player, "Stop fighting first!", "Error")
		return
	end

	if not table.find(profile.Data.OwnedMaps, mapId) then
		showNotificationEvent:FireClient(player, "You don't own this map!", "Error")
		return
	end

	if profile.Data.SelectedMap == mapId then return end

	profile.Data.SelectedMap = mapId
	PlacementController:ResetPlotItems(player)
	PlotController:ApplyMapPath(player, mapId)

	mapDataUpdatedEvent:FireClient(player, profile.Data.OwnedMaps, profile.Data.SelectedMap)
	if not silent then
		showNotificationEvent:FireClient(player, config.DisplayName .. " selected!", "Success")
	end
end

function MapsShopController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	PlotController = controllers.PlotController
	WaveController = controllers.WaveController
	PlacementController = controllers.PlacementController
end

function MapsShopController:Start()
	local eventsFolder = ReplicatedStorage.Events
	local functionsFolder = ReplicatedStorage.Functions

	showNotificationEvent = getOrCreate(eventsFolder, "RemoteEvent", "ShowNotification") :: RemoteEvent
	purchaseMapEvent      = getOrCreate(eventsFolder, "RemoteEvent", "PurchaseMap") :: RemoteEvent
	selectMapEvent        = getOrCreate(eventsFolder, "RemoteEvent", "SelectMap") :: RemoteEvent
	mapDataUpdatedEvent   = getOrCreate(eventsFolder, "RemoteEvent", "MapDataUpdated") :: RemoteEvent
	getMapDataFunc        = getOrCreate(functionsFolder, "RemoteFunction", "GetMapData") :: RemoteFunction

	getMapDataFunc.OnServerInvoke = function(player: Player)
		local profile = PlayerController:GetProfile(player)
		while not profile do task.wait() profile = PlayerController:GetProfile(player) end
		return profile.Data.OwnedMaps or {"Map1"}, profile.Data.SelectedMap or "Map1"
	end

	purchaseMapEvent.OnServerEvent:Connect(function(player: Player, mapId: string)
		local config = MapConfigurations[mapId]
		if not config then return end

		local profile = PlayerController:GetProfile(player)
		if not profile then return end

		if WaveController and WaveController:IsPlayerFighting(player) then
			showNotificationEvent:FireClient(player, "Stop fighting first!", "Error")
			return
		end

		if table.find(profile.Data.OwnedMaps, mapId) then
			showNotificationEvent:FireClient(player, "You already own " .. config.DisplayName .. "!", "Error")
			return
		end

		if config.ProductID and config.ProductID > 0 then return end

		local leaderstats = player:FindFirstChild("leaderstats")
		local cashValue = leaderstats and leaderstats:FindFirstChild("Cash")
		if not (cashValue and cashValue.Value >= config.Price) then
			showNotificationEvent:FireClient(player, "Not enough cash!", "Error")
			return
		end

		cashValue.Value -= config.Price
		table.insert(profile.Data.OwnedMaps, mapId)

		self:SelectMap(player, mapId, true)
		showNotificationEvent:FireClient(player, config.DisplayName .. " purchased & selected!", "Success")
	end)

	selectMapEvent.OnServerEvent:Connect(function(player: Player, mapId: string)
		self:SelectMap(player, mapId)
	end)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(player: Player, productId: number, wasPurchased: boolean)
		if not wasPurchased then return end
		for mapId, config in pairs(MapConfigurations) do
			if config.ProductID == productId then
				local profile = PlayerController:GetProfile(player)
				if not profile then return end
				if not table.find(profile.Data.OwnedMaps, mapId) then
					table.insert(profile.Data.OwnedMaps, mapId)
				end
				self:SelectMap(player, mapId)
				return
			end
		end
	end)
end

return MapsShopController
