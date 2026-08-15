--!strict
-- Manages the global stock of a limited-edition turret.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ItemConfigs = require(ReplicatedStorage.Modules.ItemConfigurations)
local LimitedItems = ItemConfigs.LimitedItems
local PlayerController

local LimitedTurretController = {}

local stockDataStore = DataStoreService:GetDataStore("GlobalItemStock")
local STOCK_KEY = "LavaTurretStock"
local MAX_STOCK = 999

-- Remotes
local getStockFunc = ReplicatedStorage.Functions:WaitForChild("GetLimitedTurretStock")
local stockUpdatedEvent = ReplicatedStorage.Events:WaitForChild("LimitedTurretStockUpdated")
local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

function LimitedTurretController:GetStock()
	local success, stock = pcall(function()
		return stockDataStore:GetAsync(STOCK_KEY)
	end)
	if success then
		if stock == nil then
			stockDataStore:SetAsync(STOCK_KEY, MAX_STOCK)
			return MAX_STOCK
		end
		return stock
	else
		warn("Could not get limited turret stock:", stock)
		return 0
	end
end

function LimitedTurretController:ProcessPurchase(player: Player, itemId: string)
	local newStock = stockDataStore:IncrementAsync(STOCK_KEY, -1)

	if newStock >= 0 then
		local profile = PlayerController:GetProfile(player)
		if not profile then return Enum.ProductPurchaseDecision.NotProcessedYet end

		-- ## THIS IS THE LOGIC THAT GIVES THE TURRET ##
		local inventory = profile.Data.BlockInventory
		inventory[itemId] = (inventory[itemId] or 0) + 1
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)

		showNotificationEvent:FireClient(player, `Successfully purchased {LimitedItems[itemId].DisplayName}!`, "Success")
		stockUpdatedEvent:FireAllClients(newStock)

		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		stockDataStore:IncrementAsync(STOCK_KEY, 1)
		showNotificationEvent:FireClient(player, "Sorry, this item just sold out!", "Error")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function LimitedTurretController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
end

function LimitedTurretController:Start()
	getStockFunc.OnServerInvoke = function(player: Player)
		return self:GetStock()
	end
end

return LimitedTurretController