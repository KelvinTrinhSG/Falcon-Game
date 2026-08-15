--!strict
-- Manages the UI for the limited turret shop, including price and HUD counter.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local LimitedItems = ItemConfigsModule.LimitedItems

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local frame = script.Parent

-- UI References
local buyButton = frame:WaitForChild("BuyButton")
local buyButtonText = buyButton:WaitForChild("Text")
local stockLabel = frame:WaitForChild("Stats"):WaitForChild("StockLabel")
local itemNameLabel = frame:WaitForChild("ItemName")
local itemImage = frame:WaitForChild("ItemImage")

local hudButton = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Right"):WaitForChild("LimitedTurret")
local hudStockLabel = hudButton:WaitForChild("Text")

-- Remotes
local getStockFunc = ReplicatedStorage.Functions:WaitForChild("GetLimitedTurretStock")
local stockUpdatedEvent = ReplicatedStorage.Events:WaitForChild("LimitedTurretStockUpdated")

local limitedItemId = "LavaTurret"
local limitedItemConfig = LimitedItems[limitedItemId]
local MAX_STOCK = 999

-- Function to update all UI displays related to the turret
local function updateDisplay(stock: number)
	if not limitedItemConfig then 
		warn("[LimitedTurretHandler] Could not find config for '"..limitedItemId.."' in ItemConfigurations.LimitedItems.")
		return 
	end

	-- Update the main shop frame content
	itemNameLabel.Text = limitedItemConfig.DisplayName
	itemImage.Image = limitedItemConfig.ImageId
	stockLabel.Text = tostring(stock) .. " REMAINING"

	-- ## MODIFIED ## This now displays the remaining stock (e.g., "996/999")
	if stock < 0 then stock = 0 end
	hudStockLabel.Text = string.format("%d/%d", stock, MAX_STOCK)

	if stock <= 0 then
		buyButtonText.Text = "SOLD OUT"
		buyButton.Active = false
		stockLabel.Text = "SOLD OUT FOREVER"
	else
		-- The price is set separately and doesn't need constant updates
		buyButton.Active = true
	end
end

-- Fetch and display the Robux price on the buy button (runs once)
if limitedItemConfig and limitedItemConfig.ProductID > 0 then
	buyButtonText.Text = "..."
	task.spawn(function()
		local success, pinfo = pcall(MarketplaceService.GetProductInfo, MarketplaceService, limitedItemConfig.ProductID, Enum.InfoType.Product)
		if success and pinfo then
			buyButtonText.Text = "" .. tostring(pinfo.PriceInRobux)
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


-- Listen for global stock updates from the server
stockUpdatedEvent.OnClientEvent:Connect(updateDisplay)

-- Fetch the stock count again when the frame becomes visible, just in case
frame:GetPropertyChangedSignal("Visible"):Connect(function()
	if frame.Visible then
		local currentStock = getStockFunc:InvokeServer()
		updateDisplay(currentStock)
	end
end)

-- Fetch initial stock as soon as the player joins the game.
task.spawn(function()
	local initialStock = getStockFunc:InvokeServer()
	updateDisplay(initialStock)
end)