--!strict
-- Manages the global stock of limited-edition turrets, one DataStore key per item.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ItemConfigs = require(ReplicatedStorage.Modules.ItemConfigurations)
local LimitedItems = ItemConfigs.LimitedItems
local PlayerController

local LimitedTurretController = {}

local stockDataStore = DataStoreService:GetDataStore("GlobalItemStock")
local MAX_STOCK = 999

-- One DataStore key per limited item
local STOCK_KEYS: {[string]: string} = {
	TitanCameraGuy  = "TitanCameraGuyStock",
	TitanTVMan      = "TitanTVManStock",
	TitanSpeakerman = "TitanSpeakermanStock",
}

-- Remotes
local getStockFunc = ReplicatedStorage.Functions:WaitForChild("GetLimitedTurretStock")
local stockUpdatedEvent = ReplicatedStorage.Events:WaitForChild("LimitedTurretStockUpdated")
local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

-- true nếu turret này có kho global toàn server (nằm trong STOCK_KEYS).
function LimitedTurretController:IsStockTracked(itemId: string): boolean
	return STOCK_KEYS[itemId] ~= nil
end

function LimitedTurretController:GetStock(itemId: string): number
	local key = STOCK_KEYS[itemId]
	if not key then return 0 end

	local success, stock = pcall(function()
		return stockDataStore:GetAsync(key)
	end)
	if success then
		if stock == nil then
			stockDataStore:SetAsync(key, MAX_STOCK)
			return MAX_STOCK
		end
		return stock
	else
		warn("Could not get stock for", itemId, ":", stock)
		return 0
	end
end

-- Trừ 1 đơn vị khỏi kho global của một limited item.
-- Trả về true nếu trừ được, false nếu đã hết hàng / item không có kho global / lỗi DataStore.
-- Dùng cho đường mua bằng Cash (BlocksShopController) — đường Robux vẫn đi qua ProcessPurchase.
function LimitedTurretController:ConsumeStock(itemId: string): boolean
	local key = STOCK_KEYS[itemId]
	if not key then return false end

	local success, newStock = pcall(function()
		return stockDataStore:IncrementAsync(key, -1)
	end)
	if not success then
		warn("Could not consume stock for", itemId, ":", newStock)
		return false
	end

	if newStock >= 0 then
		stockUpdatedEvent:FireAllClients(itemId, newStock)
		return true
	end

	-- Hết hàng: hoàn lại đơn vị vừa trừ
	pcall(function()
		stockDataStore:IncrementAsync(key, 1)
	end)
	return false
end

function LimitedTurretController:ProcessPurchase(player: Player, itemId: string)
	local profile = PlayerController:GetProfile(player)
	if not profile then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local key = STOCK_KEYS[itemId]

	if key then
		-- Stock-limited: decrement global stock
		local newStock = stockDataStore:IncrementAsync(key, -1)
		if newStock >= 0 then
			local inventory = profile.Data.BlockInventory
			inventory[itemId] = (inventory[itemId] or 0) + 1
			ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)
			showNotificationEvent:FireClient(player, `Successfully purchased {LimitedItems[itemId].DisplayName}!`, "Success")
			stockUpdatedEvent:FireAllClients(itemId, newStock)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			stockDataStore:IncrementAsync(key, 1)
			showNotificationEvent:FireClient(player, "Sorry, this item just sold out!", "Error")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	else
		-- No stock limit: grant directly
		local inventory = profile.Data.BlockInventory
		inventory[itemId] = (inventory[itemId] or 0) + 1
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)
		showNotificationEvent:FireClient(player, `Successfully purchased {LimitedItems[itemId].DisplayName}!`, "Success")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function LimitedTurretController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
end

function LimitedTurretController:Start()
	-- Client passes itemId to get stock for that specific turret
	getStockFunc.OnServerInvoke = function(_player: Player, itemId: string)
		return self:GetStock(itemId)
	end
end

return LimitedTurretController
