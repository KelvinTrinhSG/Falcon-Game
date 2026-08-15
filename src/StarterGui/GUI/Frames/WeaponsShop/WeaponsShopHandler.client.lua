--!strict
-- Populates the weapons shop and handles purchase requests.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)

local player = Players.LocalPlayer
local shopFrame = script.Parent
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local itemTemplate = ReplicatedStorage.Templates:WaitForChild("WeaponsTemplate")
local designFrame = shopFrame:WaitForChild("Design")
local timerLabel = designFrame:WaitForChild("Timer")
local restockButton = designFrame:WaitForChild("RestockButton")

local purchaseItemEvent = ReplicatedStorage.Events:WaitForChild("PurchaseWeaponCrate")
local updateStocksEvent = ReplicatedStorage.Events:WaitForChild("UpdateWeaponStocks")
local getResetTime = ReplicatedStorage.Functions:WaitForChild("GetWeaponShopResetTime")
local getStocks = ReplicatedStorage.Functions:WaitForChild("GetWeaponShopStocks")
local crateDataUpdatedEvent = ReplicatedStorage.Events:WaitForChild("CrateDataUpdated")

local currentStocks = {}
local currentCrateCount = 0
local MAX_CRATES = 3
local timerConnection: RBXScriptConnection?
local robuxPricesCache = {}

local function formatRemaining(seconds: number): string
	if seconds <= 0 then return "00:00" end
	local min = math.floor(seconds / 60)
	local sec = seconds % 60
	return string.format("%02d:%02d", min, sec)
end

-- ## MODIFIED ## The startTimer function now accepts an optional 'nextTime' parameter.
-- If no time is provided, it fetches it from the server (for initial UI open).
-- If a time is provided (from the restock event), it uses that directly.
local function startTimer(nextTime: number?)
	if timerConnection then timerConnection:Disconnect() end

	local function setupConnection(timestamp: number)
		timerConnection = RunService.Heartbeat:Connect(function()
			if not shopFrame.Visible then
				if timerConnection then
					timerConnection:Disconnect()
					timerConnection = nil
				end
				return
			end
			local remaining = timestamp - os.time()
			timerLabel.Text = "" .. formatRemaining(remaining)
		end)
	end

	if nextTime then
		setupConnection(nextTime)
	else
		-- Fetch time from server on initial open
		local success, serverTime = pcall(getResetTime.InvokeServer, getResetTime)
		if success and typeof(serverTime) == "number" then
			setupConnection(serverTime)
		end
	end
end

local function populateShop()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end

	local itemsToSort = {}
	for itemId, config in pairs(WeaponConfigurations.Crates) do
		if config.Price then
			table.insert(itemsToSort, {Id = itemId, Config = config})
		end
	end

	table.sort(itemsToSort, function(a, b) return a.Config.Price < b.Config.Price end)

	for _, itemData in ipairs(itemsToSort) do
		local itemId = itemData.Id
		local config = itemData.Config
		local item = itemTemplate:Clone()
		item.Name = itemId
		item.ItemImage.Image = config.ImageId
		item.ItemName.Text = config.DisplayName
		item.ItemPrice.Text = NumberFormatter.formatNumber(config.Price, "$")
		item.ItemStock.Text = "Stock: " .. tostring(currentStocks[itemId] or 0)
		item.BuyButton.MouseButton1Click:Connect(function()
			purchaseItemEvent:FireServer(itemId)
		end)
		local robuxButton = item:FindFirstChild("RobuxBuy")
		if robuxButton and robuxButton:IsA("GuiButton") then
			local priceLabel = robuxButton:FindFirstChild("Text")
			if not (priceLabel and priceLabel:IsA("TextLabel")) then continue end

			if config.ProductID and config.ProductID > 0 then
				robuxButton.Visible = true
				robuxButton.Active = (currentCrateCount < MAX_CRATES)

				if robuxPricesCache[config.ProductID] then
					priceLabel.Text = robuxPricesCache[config.ProductID]
				else
					priceLabel.Text = "..."
					task.spawn(function()
						local success, productInfo = pcall(function()
							return MarketplaceService:GetProductInfo(config.ProductID, Enum.InfoType.Product)
						end)
						if success and productInfo and item.Parent then
							local priceString = "" .. productInfo.PriceInRobux
							robuxPricesCache[config.ProductID] = priceString
							priceLabel.Text = priceString
						elseif item.Parent then
							priceLabel.Text = "N/A"
						end
					end)
				end

				robuxButton.MouseButton1Click:Connect(function()
					MarketplaceService:PromptProductPurchase(player, config.ProductID)
				end)
			else
				robuxButton.Visible = false
			end
		end
		item.Parent = scrollingFrame
	end
end

crateDataUpdatedEvent.OnClientEvent:Connect(function(crateData: table)
	currentCrateCount = #crateData
	if shopFrame.Visible then
		populateShop()
	end
end)

-- ## MODIFIED ## The event listener now receives the new restock time.
updateStocksEvent.OnClientEvent:Connect(function(newStocks, newRestockTime: number?)
	currentStocks = newStocks
	if shopFrame.Visible then
		populateShop()
		if newRestockTime then
			startTimer(newRestockTime) -- Pass the new time directly to the timer function
		end
	end
end)

shopFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if shopFrame.Visible then
		populateShop()
		startTimer() -- No time passed, so it will fetch from server
	elseif timerConnection then
		timerConnection:Disconnect()
		timerConnection = nil
	end
end)

local restockConfig = WeaponConfigurations.ShopProducts.RestockWeaponsShop
if restockButton and restockConfig then
	local priceLabel = restockButton:FindFirstChild("Text")
	if priceLabel and priceLabel:IsA("TextLabel") then
		if robuxPricesCache[restockConfig.ProductID] then
			priceLabel.Text = robuxPricesCache[restockConfig.ProductID]
		else
			priceLabel.Text = "..."
			task.spawn(function()
				local success, productInfo = pcall(function()
					return MarketplaceService:GetProductInfo(restockConfig.ProductID, Enum.InfoType.Product)
				end)
				if success and productInfo and restockButton.Parent then
					local priceString = "" .. productInfo.PriceInRobux
					robuxPricesCache[restockConfig.ProductID] = priceString
					priceLabel.Text = priceString
				elseif restockButton.Parent then
					priceLabel.Text = "N/A"
				end
			end)
		end
	end

	restockButton.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, restockConfig.ProductID)
	end)
end

local success, initialStocks = pcall(getStocks.InvokeServer, getStocks)
if success and initialStocks then currentStocks = initialStocks end