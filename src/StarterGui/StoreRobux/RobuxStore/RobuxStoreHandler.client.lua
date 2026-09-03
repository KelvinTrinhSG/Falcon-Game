--!strict
-- LOCATION: GUI/StoreRobux/RobuxStore/RobuxStoreHandler.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local NotificationManager = require(ReplicatedStorage.Modules:WaitForChild("NotificationManager"))

local player = Players.LocalPlayer
local storeFrame = script.Parent
local scrollingFrame = storeFrame:WaitForChild("Content"):WaitForChild("ScrollingFrame")
local closeButton = storeFrame:WaitForChild("Close")

local playerGui = player:WaitForChild("PlayerGui")
local mainGui = playerGui:WaitForChild("GUI")
local hud = mainGui:WaitForChild("HUD")
local openStoreButton = hud:FindFirstChild("RobuxStore", true) or hud:FindFirstChild("Store", true)

-- ==========================================
-- 🛒 CONFIGURATION DES IDs
-- ==========================================
local GamepassIDs = {
	VIP = 1832112258,
	X3Speed = 1968442351,
	X2Cash = 1969462271,
}
local robuxPricesCache = {}
local purchaseButtons = {}

-- ==========================================
-- ✨ ANIMATIONS DE L'INTERFACE
-- ==========================================
local storeScale = storeFrame:FindFirstChildOfClass("UIScale")
if not storeScale then
	storeScale = Instance.new("UIScale")
	storeScale.Parent = storeFrame
end
storeScale.Scale = 1
local isAnimating = false

local function closeStore()
	if isAnimating or not storeFrame.Visible then return end
	isAnimating = true
	local tween = TweenService:Create(storeScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.5})
	tween:Play()
	tween.Completed:Connect(function()
		storeFrame.Visible = false
		isAnimating = false
	end)
end

storeFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if storeFrame.Visible then
		storeScale.Scale = 0.5
		TweenService:Create(storeScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end
end)

local function addHoverAnimation(button: GuiButton)
	local scale = button:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = button
	end
	button.MouseEnter:Connect(function()
		if not button:GetAttribute("AlreadyOwned") then
			TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.05}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

if openStoreButton and openStoreButton:IsA("GuiButton") then
	addHoverAnimation(openStoreButton)
	openStoreButton.MouseButton1Click:Connect(function()
		if storeFrame.Visible then closeStore() else storeFrame.Visible = true end
	end)
end

-- ==========================================
-- ❗ ANIMATION DU POINT D'EXCLAMATION (MARK)
-- ==========================================
if openStoreButton then
	local mark = openStoreButton:FindFirstChild("Mark")
	if mark then
		mark.Rotation = -15
		local markTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local markTween = TweenService:Create(mark, markTweenInfo, {Rotation = 15})
		markTween:Play()
	end
end

if closeButton and closeButton:IsA("GuiButton") then
	addHoverAnimation(closeButton)
	closeButton.MouseButton1Click:Connect(closeStore)
end

-- ==========================================
-- 💰 GESTION DES PRIX ET ACHATS
-- ==========================================

local GREEN_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromHex("1aaa00")),
	ColorSequenceKeypoint.new(1, Color3.fromHex("aaff00")),
})

local function markAsOwned(button: GuiButton, priceLabel: TextLabel)
	priceLabel.Text = "Đã sở hữu"
	button:SetAttribute("AlreadyOwned", true)

	local stroke = button:FindFirstChild("Stroke")
	if stroke then
		local gradient = stroke:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient.Color = GREEN_GRADIENT
		end
	end
end

local function setupPriceLabel(button: GuiButton, priceLabel: TextLabel, id: number, infoType: Enum.InfoType)
	if robuxPricesCache[id] then
		if not button:GetAttribute("AlreadyOwned") then
			priceLabel.Text = robuxPricesCache[id]
		end
		return
	end
	priceLabel.Text = "..."
	task.spawn(function()
		local success, productInfo = pcall(function()
			return MarketplaceService:GetProductInfo(id, infoType)
		end)
		if button:GetAttribute("AlreadyOwned") then return end
		if success and productInfo then
			local priceString = " " .. productInfo.PriceInRobux
			robuxPricesCache[id] = priceString
			priceLabel.Text = priceString
		else
			priceLabel.Text = "N/A"
		end
	end)
end

local function connectPurchase(parentFolder: Instance, searchName: string, id: number, isGamepass: boolean)
	local pack = parentFolder:FindFirstChild(searchName, true)
	if not pack then return end

	local buyButton = pack:FindFirstChild("BuyButton1", true) or pack:FindFirstChild("BuyButton", true)
	if not buyButton or not buyButton:IsA("GuiButton") then return end

	addHoverAnimation(buyButton)
	local priceLabel = buyButton:FindFirstChild("Label") or buyButton:FindFirstChild("Text")
	if not (priceLabel and priceLabel:IsA("TextLabel")) then return end

	purchaseButtons[id] = {Button = buyButton, Label = priceLabel}

	priceLabel:GetPropertyChangedSignal("Text"):Connect(function()
		print("[Store] Text thay đổi →", priceLabel:GetFullName(), "| Text mới:", priceLabel.Text, "| AlreadyOwned:", buyButton:GetAttribute("AlreadyOwned"))
	end)

	if isGamepass then
		task.spawn(function()
			local success, hasPass = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
			end)
			if success and hasPass then
				markAsOwned(buyButton, priceLabel)
			else
				setupPriceLabel(buyButton, priceLabel, id, Enum.InfoType.GamePass)
			end
		end)
	else
		setupPriceLabel(buyButton, priceLabel, id, Enum.InfoType.Product)
	end

	buyButton.MouseButton1Click:Connect(function()
		if buyButton:GetAttribute("AlreadyOwned") then
			NotificationManager.show("You already own this item!", "Error")
			return
		end

		if isGamepass then
			MarketplaceService:PromptGamePassPurchase(player, id)
		else
			MarketplaceService:PromptProductPurchase(player, id)
		end
	end)
end

-- Mises à jour en direct (Si le joueur achète pendant qu'il joue)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(purchasedPlayer, passId, wasPurchased)
	if purchasedPlayer == player and wasPurchased and purchaseButtons[passId] then
		markAsOwned(purchaseButtons[passId].Button, purchaseButtons[passId].Label)
	end
end)

-- ==========================================
-- 🚀 CONNEXION DE TOUTE LA BOUTIQUE
-- ==========================================
local coinPacksFrame = scrollingFrame:WaitForChild("CoinPacks")
for productName, productConfig in pairs(WeaponConfigurations.CashProducts) do
	local guiName = string.gsub(productName, "Product", "Pack")
	connectPurchase(coinPacksFrame, guiName, productConfig.ProductID, false)
end

connectPurchase(scrollingFrame, "VIP", GamepassIDs.VIP, true)

local gamepassesFrame = scrollingFrame:WaitForChild("Gamepasses")
connectPurchase(gamepassesFrame, "Pack1", GamepassIDs.X3Speed, true)
connectPurchase(gamepassesFrame, "Pack2", GamepassIDs.X2Cash, true)
