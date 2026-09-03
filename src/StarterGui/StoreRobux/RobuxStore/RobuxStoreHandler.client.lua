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
local StarterPackID = 3588689957
local robuxPricesCache = {}
local purchaseButtons = {} -- NOUVEAU : Sauvegarde tous les boutons pour les mettre à jour en direct

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
		if not button:GetAttribute("AlreadyOwned") then -- Ne grossit plus si déjà acheté
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
		-- Position de départ inclinée
		mark.Rotation = -15

		-- TweenInfo : 0.4s l'aller, Style doux, -1 pour une boucle infinie, true pour faire l'aller-retour (yoyo)
		local markTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local markTween = TweenService:Create(mark, markTweenInfo, {Rotation = 15})

		-- Lancement de l'animation de balancier
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

-- Fonction pour bloquer visuellement un bouton "Déjà possédé"
local function markAsOwned(button: GuiButton, priceLabel: TextLabel)
	priceLabel.Text = "Owned"
	button:SetAttribute("AlreadyOwned", true)
end

local function setupPriceLabel(priceLabel: TextLabel, id: number, infoType: Enum.InfoType)
	if robuxPricesCache[id] then
		priceLabel.Text = robuxPricesCache[id]
		return
	end
	priceLabel.Text = "..." 
	task.spawn(function()
		local success, productInfo = pcall(function()
			return MarketplaceService:GetProductInfo(id, infoType)
		end)
		if success and productInfo then
			local priceString = " " .. productInfo.PriceInRobux
			robuxPricesCache[id] = priceString
			priceLabel.Text = priceString
		else
			priceLabel.Text = "N/A"
		end
	end)
end

local function connectPurchase(parentFolder: Instance, searchName: string, id: number, isGamepass: boolean)
	print("[RobuxStore] connectPurchase -> searchName:", searchName, "| id:", id, "| parent:", parentFolder.Name)

	local pack = parentFolder:FindFirstChild(searchName, true)
	if not pack then
		warn("[RobuxStore] FAIL: pack not found ->", searchName, "in", parentFolder.Name)
		return
	end
	print("[RobuxStore] pack found:", pack:GetFullName())

	local buyButton = pack:FindFirstChild("BuyButton1", true) or pack:FindFirstChild("BuyButton", true)
	if not buyButton then
		warn("[RobuxStore] FAIL: BuyButton1/BuyButton not found inside", pack:GetFullName())
		return
	end
	if not buyButton:IsA("GuiButton") then
		warn("[RobuxStore] FAIL: button found but is not GuiButton, class:", buyButton.ClassName)
		return
	end
	print("[RobuxStore] buyButton found:", buyButton:GetFullName())

	addHoverAnimation(buyButton)
	local priceLabel = buyButton:FindFirstChild("Label") or buyButton:FindFirstChild("Text")
	if not (priceLabel and priceLabel:IsA("TextLabel")) then
		warn("[RobuxStore] FAIL: price label (Label/Text TextLabel) not found inside", buyButton:GetFullName())
		return
	end
	print("[RobuxStore] priceLabel found:", priceLabel:GetFullName())

	-- On sauvegarde le bouton
	purchaseButtons[id] = {Button = buyButton, Label = priceLabel}

	-- VERIFICATION SI DEJA POSSEDE
	if isGamepass then
		task.spawn(function()
			local success, hasPass = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
			end)
			print("[RobuxStore] UserOwnsGamePassAsync id:", id, "| success:", success, "| hasPass:", hasPass)
			if success and hasPass then
				markAsOwned(buyButton, priceLabel)
			else
				setupPriceLabel(priceLabel, id, Enum.InfoType.GamePass)
			end
		end)
	else
		if id == StarterPackID then
			-- Le serveur nous dit si le Starter Pack a déjà été acheté
			if player:GetAttribute("OwnsStarterPack") then
				markAsOwned(buyButton, priceLabel)
			else
				setupPriceLabel(priceLabel, id, Enum.InfoType.Product)
			end
		else
			-- Pour l'argent normal (achetable à l'infini)
			setupPriceLabel(priceLabel, id, Enum.InfoType.Product)
		end
	end

	buyButton.MouseButton1Click:Connect(function()
		print("[RobuxStore] BuyButton clicked -> searchName:", searchName, "| id:", id, "| AlreadyOwned:", buyButton:GetAttribute("AlreadyOwned"))
		if buyButton:GetAttribute("AlreadyOwned") then
			print("[RobuxStore] Blocked: player already owns this item")
			NotificationManager.show("You already own this item!", "Error")
			return
		end

		if isGamepass then
			print("[RobuxStore] Calling PromptGamePassPurchase for id:", id)
			MarketplaceService:PromptGamePassPurchase(player, id)
		else
			print("[RobuxStore] Calling PromptProductPurchase for id:", id)
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

player:GetAttributeChangedSignal("OwnsStarterPack"):Connect(function()
	if player:GetAttribute("OwnsStarterPack") and purchaseButtons[StarterPackID] then
		markAsOwned(purchaseButtons[StarterPackID].Button, purchaseButtons[StarterPackID].Label)
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

local vipFrame = scrollingFrame:WaitForChild("VIP")
connectPurchase(scrollingFrame, "VIP", GamepassIDs.VIP, true)

local gamepassesFrame = scrollingFrame:WaitForChild("Gamepasses")
connectPurchase(gamepassesFrame, "Pack1", GamepassIDs.X3Speed, true)
connectPurchase(gamepassesFrame, "Pack2", GamepassIDs.X2Cash, true)

local starterPackFrame = scrollingFrame:WaitForChild("StarterPackHolder")
connectPurchase(starterPackFrame, "BeginnerPack", StarterPackID, false)