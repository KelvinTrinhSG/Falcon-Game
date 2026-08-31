--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local LimitedItems = ItemConfigsModule.LimitedItems
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local frame = script.Parent

-- UI References
local buyButton = frame:WaitForChild("BuyButton")
local buyButtonText = buyButton:WaitForChild("Text")
local statsFrame = frame:WaitForChild("Stats")
local stockLabel = statsFrame:WaitForChild("StockLabel")
local damageLabel = statsFrame:WaitForChild("DamageLabel")
local itemNameLabel = frame:WaitForChild("ItemName")
local itemImage = frame:WaitForChild("ItemImage")

local hudButton = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Right"):WaitForChild("LimitedTurretTitanTV")
local hudStockLabel = hudButton:WaitForChild("Text")

-- Remotes
local getStockFunc = ReplicatedStorage.Functions:WaitForChild("GetLimitedTurretStock")
local stockUpdatedEvent = ReplicatedStorage.Events:WaitForChild("LimitedTurretStockUpdated")

local limitedItemId = "TitanTVMan"
local limitedItemConfig = LimitedItems[limitedItemId]
local MAX_STOCK = 999

local function updateDisplay(stock: number)
	if not limitedItemConfig then
		warn("[LimitedTurretTitanTVManHandler] Could not find config for '" .. limitedItemId .. "' in LimitedItems.")
		return
	end

	itemNameLabel.Text = limitedItemConfig.DisplayName
	itemImage.Image = limitedItemConfig.ImageId
	damageLabel.Text = "Damage: " .. NumberFormatter.formatNumber(limitedItemConfig.Damage)
	stockLabel.Text = tostring(stock) .. " REMAINING"

	if stock < 0 then stock = 0 end
	hudStockLabel.Text = string.format("%d/%d", stock, MAX_STOCK)

	if stock <= 0 then
		buyButtonText.Text = "SOLD OUT"
		buyButton.Active = false
		stockLabel.Text = "SOLD OUT FOREVER"
	else
		buyButton.Active = true
	end
end

if limitedItemConfig and limitedItemConfig.ProductID > 0 then
	buyButtonText.Text = "..."
	task.spawn(function()
		local success, pinfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, limitedItemConfig.ProductID, Enum.InfoType.Product)
		if success and pinfo then
			buyButtonText.Text = "" .. tostring(pinfo.PriceInRobux)
		else
			buyButtonText.Text = "N/A"
		end
	end)

	buyButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, limitedItemConfig.ProductID)
	end)
else
	buyButton.Visible = false
end

stockUpdatedEvent.OnClientEvent:Connect(function(itemId: string, stock: number)
	if itemId == limitedItemId then
		updateDisplay(stock)
	end
end)

frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if frame.Visible then
		local currentStock = getStockFunc:InvokeServer(limitedItemId)
		updateDisplay(currentStock)
	end
end)

task.spawn(function()
	local initialStock = getStockFunc:InvokeServer(limitedItemId)
	updateDisplay(initialStock)
end)
