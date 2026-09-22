--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)
local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shopFrame = script.Parent
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local itemTemplate = ReplicatedStorage.Templates:WaitForChild("TurretsTemplate")
local designFrame = shopFrame:WaitForChild("Design")
local timerLabel = designFrame:WaitForChild("Timer")
local restockButton = designFrame:WaitForChild("RestockButton")

local onboardingStepValue = ReplicatedStorage:WaitForChild("OnboardingStep")

local purchaseItemEvent = ReplicatedStorage.Events:WaitForChild("PurchaseTurretItem")
local updateStocksEvent = ReplicatedStorage.Events:WaitForChild("UpdateTurretStocks")
local getResetTime = ReplicatedStorage.Functions:WaitForChild("GetTurretShopResetTime")
local getStocks = ReplicatedStorage.Functions:WaitForChild("GetTurretShopStocks")

local currentStocks: {[string]: number} = {}
local isPopulating = false
local visualTimerConnection: RBXScriptConnection?
local robuxPricesCache: {[number]: string} = {}
local isPurchasing = false

-- TurretInfo panel
local turretInfoGui = playerGui:WaitForChild("TurretInfo", 10)
local turretInfoFrame = turretInfoGui and turretInfoGui:FindFirstChild("Frame")

local function closeTurretInfo()
	if not turretInfoFrame then return end
	local uiScale = turretInfoFrame:FindFirstChild("UIScale")
	turretInfoGui.Enabled = false
	if uiScale then uiScale.Scale = 0 end
end

local function getTurretInfoScale(): number
	local UIS = game:GetService("UserInputService")
	local PC_SCALE = 0.7
	if UIS.GamepadEnabled and not UIS.TouchEnabled then
		return PC_SCALE -- Console (TV distance, same layout as PC)
	elseif UIS.TouchEnabled then
		local viewportWidth = workspace.CurrentCamera.ViewportSize.X
		if viewportWidth < 1000 then
			return PC_SCALE * 0.55 -- Mobile phone (~0.39)
		else
			return PC_SCALE * 0.75 -- Tablet (~0.53)
		end
	end
	return PC_SCALE -- PC / Desktop
end

local function openTurretInfo(config: {[string]: any})
	if not turretInfoFrame then
		warn("[TurretsShopHandler] TurretInfo GUI not found in PlayerGui")
		return
	end

	local targetScale = getTurretInfoScale()

	local itemName = turretInfoFrame:FindFirstChild("ItemName")
	local design = turretInfoFrame:FindFirstChild("Design")
	local stats = turretInfoFrame:FindFirstChild("Stats")
	local uiScale = turretInfoFrame:FindFirstChild("UIScale")
	local exitButton = turretInfoFrame:FindFirstChild("Exit")

	if itemName then itemName.Text = config.DisplayName or "?" end
	if design then
		local img = design:FindFirstChild("Image")
		if img then img.Image = config.ImageId or "" end
	end
	if stats then
		local damageFrame = stats:FindFirstChild("Damage")
		local fastFrame = stats:FindFirstChild("Fast")
		local specialFrame = stats:FindFirstChild("Special")
		if damageFrame then
			local inner = damageFrame:FindFirstChild("Frame")
			if inner then
				local title = inner:FindFirstChild("Title")
				local count = inner:FindFirstChild("Count")
				if title then title.Text = "DAMAGE" end
				if count then count.Text = tostring(config.Damage or "?") end
			end
		end
		if fastFrame then
			fastFrame.Visible = true
			local inner = fastFrame:FindFirstChild("Frame")
			if inner then
				local count = inner:FindFirstChild("Count")
				if count then count.Text = tostring(config.Cooldown or config.FireRate or "?") end
			end
		end
		if specialFrame then
			if config.SlowEffect then
				specialFrame.Visible = true
				local inner = specialFrame:FindFirstChild("Frame")
				if inner then
					local title = inner:FindFirstChild("Title")
					if title then title.Text = "Slows Down Toilets" end
				end
			else
				specialFrame.Visible = false
			end
		end
	end

	if exitButton then
		exitButton.MouseButton1Click:Once(function()
			closeTurretInfo()
		end)
	end

	turretInfoGui.Enabled = true
	turretInfoFrame.Position = UDim2.new(1, -20, 0.6, 0)
	if uiScale then uiScale.Scale = 0 end

	TweenService:Create(turretInfoFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -20, 0.5, 0),
	}):Play()
	if uiScale then
		TweenService:Create(uiScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = targetScale,
		}):Play()
	end
end

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
		if nextTime <= os.time() then
			-- Restock chưa được set (new player), retry sau 2s
			task.delay(2, function()
				if shopFrame.Visible then startTimer() end
			end)
			return
		end
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
		warn("[TurretsShopHandler] FAILED to get new restock time.")
	end
end

local function populateShop()
	if isPopulating then return end
	isPopulating = true
	isPurchasing = false
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end

	local itemsToDisplay = {}
	for itemId, config in pairs(ItemConfigurations) do
		if config.Type == "Turrets" and config.Chance and config.StockAmount then
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
				if isPurchasing then return end
				if isInStock then
					isPurchasing = true
					buyButton.Active = false
					purchaseItemEvent:FireServer(itemId)
					task.delay(5, function() isPurchasing = false end)
				else
					NotificationManager.show("This item is out of stock!", "Error")
				end
			end)

			local onboardingImage = buyButton:FindFirstChild("Onboarding")
			if onboardingImage then
				onboardingImage.Visible = (onboardingStepValue.Value == "Step3_BuyOldTurret" and itemId == "CameraGuy")
			end
		end

		local informButton: TextButton? = item:FindFirstChild("InformButton")
		if informButton then
			informButton.MouseButton1Click:Connect(function()
				openTurretInfo(config)
			end)
		end

		if robuxButton then
			local tripleText: TextLabel? = robuxButton:FindFirstChild("TripleText")
			if tripleText then
				tripleText.Visible = false
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
end

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
		closeTurretInfo()
	end
end)

onboardingStepValue.Changed:Connect(function()
	if shopFrame.Visible then
		populateShop()
	end
end)

local restockConfig = WeaponConfigurations.ShopProducts.RestockTurretsShop
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
if initialStocksSuccess and initialStocks and next(initialStocks) and not next(currentStocks) then
	currentStocks = initialStocks
elseif not initialStocksSuccess then
	warn("[TurretsShopHandler] Could not get initial stocks on startup.")
end
