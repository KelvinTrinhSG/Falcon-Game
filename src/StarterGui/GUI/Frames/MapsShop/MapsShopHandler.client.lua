--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local MapConfigurations = ItemConfigsModule.MapConfigurations
local MAP_ORDER = ItemConfigsModule.MAP_ORDER
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)
local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

local player = Players.LocalPlayer
local shopFrame = script.Parent
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local itemTemplate = ReplicatedStorage.Templates:WaitForChild("MapsTemplate")

local purchaseMapEvent    = ReplicatedStorage.Events:WaitForChild("PurchaseMap")
local selectMapEvent      = ReplicatedStorage.Events:WaitForChild("SelectMap")
local mapDataUpdatedEvent = ReplicatedStorage.Events:WaitForChild("MapDataUpdated")
local getMapDataFunc      = ReplicatedStorage.Functions:WaitForChild("GetMapData")
local waveStateChanged    = ReplicatedStorage.Events:WaitForChild("WaveStateChanged")

local ownedMaps: {string} = {}
local selectedMap: string = "Map1"
local isFighting: boolean = false
local robuxPricesCache: {[number]: string} = {}
local ROBUX_ICON = "\xee\x80\x82"
local isPurchasing = false

waveStateChanged.OnClientEvent:Connect(function(active: boolean)
	isFighting = active
end)

local function populateShop()
	isPurchasing = false
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end

	for _, mapId in ipairs(MAP_ORDER) do
		local config = MapConfigurations[mapId]
		if not config then continue end

		local item = itemTemplate:Clone()
		item.Name = mapId

		local isOwned    = table.find(ownedMaps, mapId) ~= nil
		local isSelected = selectedMap == mapId

		local itemImage: ImageLabel? = item:FindFirstChild("ItemImage")
		if itemImage then itemImage.Image = config.ImageId end

		local nameLabel: TextLabel? = item:FindFirstChild("ItemName")
		if nameLabel then nameLabel.Text = config.DisplayName end

		local descLabel: TextLabel? = item:FindFirstChild("ItemDescription")
		if descLabel then descLabel.Text = config.Description end

		local stockLabel: TextLabel? = item:FindFirstChild("ItemStock")
		if stockLabel then stockLabel.Visible = false end

		local buyButton: TextButton?      = item:FindFirstChild("BuyButton")
		local selectButton: TextButton?   = item:FindFirstChild("EquipButton")
		local selectedButton: TextLabel?  = item:FindFirstChild("EquippedButton")
		local robuxBuyButton: TextButton? = item:FindFirstChild("RobuxBuy")

		local function hideAll()
			if buyButton then buyButton.Visible = false end
			if selectButton then selectButton.Visible = false end
			if selectedButton then selectedButton.Visible = false end
			if robuxBuyButton then robuxBuyButton.Visible = false end
		end

		hideAll()

		if isSelected then
			if selectedButton then selectedButton.Visible = true end
		elseif isOwned then
			if selectButton then
				selectButton.Visible = true
				selectButton.MouseButton1Click:Connect(function()
					if isFighting then
						NotificationManager.show("Stop fighting first!", "Error")
						return
					end
					selectMapEvent:FireServer(mapId)
				end)
			end
		else
			if buyButton and (not config.ProductID or config.ProductID == 0) then
				buyButton.Visible = true
				local buyText: TextLabel? = buyButton:FindFirstChild("Text")
				if buyText then
					buyText.Text = if config.Price == 0 then "Free" else NumberFormatter.formatNumber(config.Price, "$")
				end
				buyButton.MouseButton1Click:Connect(function()
					if isPurchasing then return end
					if isFighting then
						NotificationManager.show("Stop fighting first!", "Error")
						return
					end
					isPurchasing = true
					buyButton.Active = false
					purchaseMapEvent:FireServer(mapId)
					task.delay(5, function() isPurchasing = false end)
				end)
			end

			if robuxBuyButton and config.ProductID and config.ProductID > 0 then
				robuxBuyButton.Visible = true
				local robuxText: TextLabel? = robuxBuyButton:FindFirstChild("Text")
				if robuxText then
					if robuxPricesCache[config.ProductID] then
						robuxText.Text = robuxPricesCache[config.ProductID]
					else
						robuxText.Text = "..."
						task.spawn(function()
							local ok, result = pcall(MarketplaceService.GetProductInfo, MarketplaceService, config.ProductID, Enum.InfoType.Product)
							if ok and result and result.PriceInRobux and robuxBuyButton.Parent then
								local priceString = ROBUX_ICON .. result.PriceInRobux
								robuxPricesCache[config.ProductID] = priceString
								robuxText.Text = priceString
							elseif robuxBuyButton.Parent then
								robuxText.Text = "N/A"
							end
						end)
					end
				end
				robuxBuyButton.MouseButton1Click:Connect(function()
					MarketplaceService:PromptProductPurchase(player, config.ProductID)
				end)
			end
		end

		item.Parent = scrollingFrame
	end
end

mapDataUpdatedEvent.OnClientEvent:Connect(function(newOwned: {string}, newSelected: string)
	ownedMaps = newOwned
	selectedMap = newSelected
	if shopFrame.Visible then
		populateShop()
	end
end)

shopFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if shopFrame.Visible then
		populateShop()
	end
end)

local success, owned, selected = pcall(getMapDataFunc.InvokeServer, getMapDataFunc)
if success and owned then
	ownedMaps = owned
	selectedMap = selected or "Map1"
else
	warn("[MapsShopHandler] Could not get initial map data.")
end
