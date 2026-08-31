--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local BaseConfigurations = ItemConfigsModule.BaseConfigurations
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)
local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

local player = Players.LocalPlayer
local shopFrame = script.Parent
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local designFrame = shopFrame:WaitForChild("Design")
local timerLabel = designFrame:WaitForChild("Timer")
local restockButton = designFrame:WaitForChild("RestockButton")
local itemTemplate = ReplicatedStorage.Templates:WaitForChild("BasesTemplate")

local purchaseBaseEvent = ReplicatedStorage.Events:WaitForChild("PurchaseBase")
local equipBaseEvent    = ReplicatedStorage.Events:WaitForChild("EquipBase")
local baseDataUpdatedEvent = ReplicatedStorage.Events:WaitForChild("BaseDataUpdated")
local getBaseDataFunc   = ReplicatedStorage.Functions:WaitForChild("GetBaseData")
local updateStocksEvent  = ReplicatedStorage.Events:WaitForChild("UpdateBaseStocks")
local getResetTime       = ReplicatedStorage.Functions:WaitForChild("GetBasesShopResetTime")
local getStocks          = ReplicatedStorage.Functions:WaitForChild("GetBasesShopStocks")
local waveStateChanged   = ReplicatedStorage.Events:WaitForChild("WaveStateChanged")

local ownedBases: {string} = {}
local equippedBase: string = "Core1"
local currentStocks: {[string]: number} = {}
local visualTimerConnection: RBXScriptConnection?
local isFighting: boolean = false
local robuxPricesCache: {[number]: string} = {}
local ROBUX_ICON = "\xee\x80\x82"

waveStateChanged.OnClientEvent:Connect(function(active: boolean)
	isFighting = active
end)

local TIER_ORDER = {"Core1", "Core2", "Core3", "Core4", "Core5"}

local function formatRemaining(seconds: number): string
	if seconds <= 0 then return "00:00" end
	local min = math.floor(seconds / 60)
	local sec = seconds % 60
	return string.format("%02d:%02d", min, sec)
end

local function startTimer()
	if visualTimerConnection then visualTimerConnection:Disconnect() end

	local success, nextTime = pcall(getResetTime.InvokeServer, getResetTime)
	if success and typeof(nextTime) == "number" then
		visualTimerConnection = RunService.Heartbeat:Connect(function()
			if not shopFrame.Visible then
				if visualTimerConnection then
					visualTimerConnection:Disconnect()
					visualTimerConnection = nil
				end
				return
			end
			local remaining = nextTime - os.time()
			timerLabel.Text = "Restocks in " .. formatRemaining(remaining)
		end)
	else
		warn("[BasesShopHandler] FAILED to get new restock time.")
	end
end

local function populateShop()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end

	for _, baseId in ipairs(TIER_ORDER) do
		local config = BaseConfigurations[baseId]
		if not config then continue end

		local item = itemTemplate:Clone()
		item.Name = baseId

		local isOwned    = table.find(ownedBases, baseId) ~= nil
		local isEquipped = equippedBase == baseId
		local inStock    = (currentStocks[baseId] or 0) > 0

		local itemImage: ImageLabel? = item:FindFirstChild("ItemImage")
		if itemImage then itemImage.Image = config.ImageId end

		local nameLabel: TextLabel? = item:FindFirstChild("ItemName")
		if nameLabel then nameLabel.Text = config.DisplayName end

		local healthLabel: TextLabel? = item:FindFirstChild("ItemHealth")
		if healthLabel then healthLabel.Text = "HP: " .. config.Health end

		local stockLabel: TextLabel? = item:FindFirstChild("ItemStock")
		if stockLabel then
			if isOwned then
				stockLabel.Visible = false
			else
				stockLabel.Visible = true
				stockLabel.Text = "x" .. tostring(currentStocks[baseId] or 0)
			end
		end

		local buyButton: TextButton?      = item:FindFirstChild("BuyButton")
		local equipButton: TextButton?    = item:FindFirstChild("EquipButton")
		local equippedButton: TextLabel?  = item:FindFirstChild("EquippedButton")
		local naButton: TextLabel?        = item:FindFirstChild("NAButton")
		local robuxBuyButton: TextButton? = item:FindFirstChild("RobuxBuy")

		local function hideAll()
			if buyButton then buyButton.Visible = false end
			if equipButton then equipButton.Visible = false end
			if equippedButton then equippedButton.Visible = false end
			if naButton then naButton.Visible = false end
			if robuxBuyButton then robuxBuyButton.Visible = false end
		end

		hideAll()

		if isEquipped then
			if equippedButton then equippedButton.Visible = true end
		elseif isOwned then
			if equipButton then
				equipButton.Visible = true
				equipButton.MouseButton1Click:Connect(function()
					if isFighting then
						NotificationManager.show("Stop fighting first!", "Error")
						return
					end
					equipBaseEvent:FireServer(baseId)
				end)
			end
		elseif inStock then
			if buyButton then
				buyButton.Visible = true
				local buyText: TextLabel? = buyButton:FindFirstChild("Text")
				if buyText then
					buyText.Text = if config.Price == 0 then "Free" else NumberFormatter.formatNumber(config.Price, "$")
				end
				buyButton.MouseButton1Click:Connect(function()
					if isFighting then
						NotificationManager.show("Stop fighting first!", "Error")
						return
					end
					purchaseBaseEvent:FireServer(baseId)
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
					if isFighting then
						NotificationManager.show("Stop fighting first!", "Error")
						return
					end
					MarketplaceService:PromptProductPurchase(player, config.ProductID)
				end)
			end
		else
			if naButton then naButton.Visible = true end
		end

		item.Parent = scrollingFrame
	end
end

baseDataUpdatedEvent.OnClientEvent:Connect(function(newOwned: {string}, newEquipped: string)
	ownedBases = newOwned
	equippedBase = newEquipped
	if shopFrame.Visible then
		populateShop()
	end
end)

updateStocksEvent.OnClientEvent:Connect(function(newStocks: {[string]: number})
	currentStocks = newStocks
	if shopFrame.Visible then
		populateShop()
		startTimer()
	end
end)

shopFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if shopFrame.Visible then
		populateShop()
		startTimer()
	else
		if visualTimerConnection then
			visualTimerConnection:Disconnect()
			visualTimerConnection = nil
		end
	end
end)

-- RestockButton
local restockConfig = WeaponConfigurations.ShopProducts.RestockBasesShop
if restockButton and restockConfig then
	local priceLabel = restockButton:FindFirstChild("Text")
	if priceLabel and priceLabel:IsA("TextLabel") then
		priceLabel.Text = "..."
		task.spawn(function()
			local ok, productInfo = pcall(function()
				return MarketplaceService:GetProductInfo(restockConfig.ProductID, Enum.InfoType.Product)
			end)
			if ok and productInfo and restockButton.Parent then
				priceLabel.Text = "" .. productInfo.PriceInRobux
			elseif restockButton.Parent then
				priceLabel.Text = "N/A"
			end
		end)
	end

	restockButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, restockConfig.ProductID)
	end)
end

-- Load initial data
local success, owned, equipped = pcall(getBaseDataFunc.InvokeServer, getBaseDataFunc)
if success and owned then
	ownedBases = owned
	equippedBase = equipped or "Core1"
else
	warn("[BasesShopHandler] Could not get initial base data.")
end

local stockSuccess, initialStocks = pcall(getStocks.InvokeServer, getStocks)
if stockSuccess and initialStocks then
	currentStocks = initialStocks
else
	warn("[BasesShopHandler] Could not get initial stocks.")
end
