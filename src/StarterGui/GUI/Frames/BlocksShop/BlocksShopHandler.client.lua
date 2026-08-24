--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)
local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

local player = Players.LocalPlayer
local shopFrame = script.Parent
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local itemTemplate = ReplicatedStorage.Templates:WaitForChild("BlocksTemplate")
local designFrame = shopFrame:WaitForChild("Design")
local timerLabel = designFrame:WaitForChild("Timer")
local restockButton = designFrame:WaitForChild("RestockButton")
local buttonFrame = shopFrame:WaitForChild("Buttons")
local blocksButton = buttonFrame:WaitForChild("Blocks")
local turretsButton = buttonFrame:WaitForChild("Turrets")

local onboardingStepValue = ReplicatedStorage:WaitForChild("OnboardingStep")

local purchaseItemEvent = ReplicatedStorage.Events:WaitForChild("PurchaseBlockItem")
local updateStocksEvent = ReplicatedStorage.Events:WaitForChild("UpdateBlockStocks")
local getResetTime = ReplicatedStorage.Functions:WaitForChild("GetBlockShopResetTime")
local getStocks = ReplicatedStorage.Functions:WaitForChild("GetBlockShopStocks")

local currentStocks: {[string]: number} = {}
local isPopulating = false
local visualTimerConnection: RBXScriptConnection?
local robuxPricesCache: {[number]: string} = {}
local currentFilter: string = "Turrets"

local function formatRemaining(seconds: number): string
	if seconds <= 0 then return "00:00" end
	local min = math.floor(seconds / 60)
	local sec = seconds % 60
	return string.format("%02d:%02d", min, sec)
end

-- ⚡ AJOUT : Gestion des flèches sur les boutons d'onglets (Blocks / Turrets)
local function updateTabOnboarding()
	local blocksOnboarding = blocksButton:FindFirstChild("Onboarding")
	if blocksOnboarding then
		-- Si on doit acheter un bloc mais qu'on est pas dans l'onglet Blocks -> On montre la flèche
		blocksOnboarding.Visible = (onboardingStepValue.Value == "Step3b_BuyFirstBlock" and currentFilter ~= "Blocks")
	end

	local turretsOnboarding = turretsButton:FindFirstChild("Onboarding")
	if turretsOnboarding then
		turretsOnboarding.Visible = (onboardingStepValue.Value == "Step3_BuyOldTurret" and currentFilter ~= "Turrets")
	end
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
			timerLabel.Text = formatRemaining(remaining)
		end)
	else
		warn("[BlocksShopHandler] FAILED to get new restock time.")
	end
end

local function populateShop()
	if isPopulating then return end
	isPopulating = true
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end

	local itemsToDisplay = {}
	for itemId, config in pairs(ItemConfigurations) do
		if config.Type == currentFilter then
			table.insert(itemsToDisplay, {Id = itemId, Config = config})
		end
	end
	table.sort(itemsToDisplay, function(a, b)
		return a.Config.Price < b.Config.Price
	end)

	for _, itemData in ipairs(itemsToDisplay) do
		local itemId = itemData.Id
		local config = itemData.Config
		local item = itemTemplate:Clone()
		item.Name = itemId

		local itemImage: ImageLabel? = item:FindFirstChild("ItemImage")
		if itemImage then itemImage.Image = config.ImageId end

		local itemName: TextLabel? = item:FindFirstChild("ItemName")
		if itemName then itemName.Text = config.DisplayName end

		local itemPrice: TextLabel? = item:FindFirstChild("ItemPrice")
		if itemPrice then itemPrice.Text = NumberFormatter.formatNumber(config.Price, "$") end

		local stockLabel: TextLabel? = item:FindFirstChild("ItemStock")
		local buyButton: TextButton? = item:FindFirstChild("BuyButton")
		local robuxButton: TextButton? = item:FindFirstChild("RobuxButton")

		if stockLabel then
			stockLabel.Text = "Stock: " .. tostring(currentStocks[itemId] or 0)
		end

		if buyButton then
			local isInStock = (currentStocks[itemId] or 0) > 0
			buyButton.Active = isInStock
			buyButton.TextColor3 = if isInStock then Color3.new(1,1,1) else Color3.fromRGB(200,200,200)
			buyButton.MouseButton1Click:Connect(function()
				if isInStock then
					purchaseItemEvent:FireServer(itemId)
				else
					NotificationManager.show("This item is out of stock!", "Error")
				end
			end)

			local onboardingImage = buyButton:FindFirstChild("Onboarding")
			if onboardingImage then
				if onboardingStepValue.Value == "Step3_BuyOldTurret" and itemId == "CameraGuy" then
					onboardingImage.Visible = true
					-- ⚡ MODIFIÉ : Cible maintenant le CardboardBlock
				elseif onboardingStepValue.Value == "Step3b_BuyFirstBlock" and itemId == "RockBlock" then
					onboardingImage.Visible = true
				else
					onboardingImage.Visible = false
				end
			end
		end

		if robuxButton then
			local tripleText: TextLabel? = robuxButton:FindFirstChild("TripleText")
			if tripleText then
				tripleText.Visible = (currentFilter == "Blocks")
			end

			if config.ProductID and config.ProductID > 0 then
				robuxButton.Visible = true
				local priceLabel = robuxButton:FindFirstChild("Text")
				if priceLabel and priceLabel:IsA("TextLabel") then
					if robuxPricesCache[config.ProductID] then
						priceLabel.Text = robuxPricesCache[config.ProductID]
					else
						priceLabel.Text = "..."
						task.spawn(function()
							local success, result = pcall(MarketplaceService.GetProductInfo, MarketplaceService, config.ProductID, Enum.InfoType.Product)
							if success and result and result.PriceInRobux and item.Parent then
								local priceString = "" .. result.PriceInRobux
								robuxPricesCache[config.ProductID] = priceString
								priceLabel.Text = priceString
							elseif item.Parent then
								priceLabel.Text = "N/A"
							end
						end)
					end
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
	isPopulating = false
	updateTabOnboarding() -- ⚡ On actualise les flèches d'onglets après avoir généré la liste
end

local function onFilterButtonClicked(filterName: string)
	if currentFilter == filterName then return end
	currentFilter = filterName
	populateShop()
end

blocksButton.MouseButton1Click:Connect(function() onFilterButtonClicked("Blocks") end)
turretsButton.MouseButton1Click:Connect(function() onFilterButtonClicked("Turrets") end)

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

onboardingStepValue.Changed:Connect(function()
	if shopFrame.Visible then
		populateShop()
	end
end)

local restockConfig = WeaponConfigurations.ShopProducts.RestockBlocksShop
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

local initialStocksSuccess, initialStocks = pcall(getStocks.InvokeServer, getStocks)
if initialStocksSuccess and initialStocks then
	currentStocks = initialStocks
else
	warn("[BlocksShopHandler] Could not get initial stocks on startup.")
end