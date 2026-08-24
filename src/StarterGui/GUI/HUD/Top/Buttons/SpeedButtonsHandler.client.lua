--!strict
-- LOCATION: GUI/HUD/Top/Buttons/SpeedButtonsHandler (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local buttonsFolder = script.Parent

local speed1Btn = buttonsFolder:WaitForChild("Speed1")
local speed2Btn = buttonsFolder:WaitForChild("Speed2")
local speed3Btn = buttonsFolder:WaitForChild("Speed3")

-- On prépare l'événement pour parler au serveur
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local changeSpeedEvent = eventsFolder:WaitForChild("ChangeWaveSpeed", 5) 

-- L'ID de ton Gamepass X3 Speed
local GAMEPASS_X3_SPEED = 1831192303
local ownsSpeedPass = false

-- ==========================================
-- ✨ ANIMATIONS DES BOUTONS (Survol & Clic)
-- ==========================================
local function applyAnimations(button: GuiButton)
	local scale = button:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = button
	end
	scale.Scale = 1

	button.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.05}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)

	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.9}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.05}):Play()
	end)
end

if speed1Btn:IsA("GuiButton") then applyAnimations(speed1Btn) end
if speed2Btn:IsA("GuiButton") then applyAnimations(speed2Btn) end
if speed3Btn:IsA("GuiButton") then applyAnimations(speed3Btn) end

-- ==========================================
-- 🔒 GESTION DU CADENAS (INTERFACE)
-- ==========================================
local function updateSpeed3UI()
	local lockedFrame = speed3Btn:FindFirstChild("Locked")
	local textLabel = speed3Btn:FindFirstChild("Text")

	-- ⚡ NOUVEAU : On vérifie AUSSI l'attribut donné par la roue !
	local hasWonPass = (player:GetAttribute("HasX3WavePass") == true)

	if ownsSpeedPass or hasWonPass then
		if lockedFrame then lockedFrame.Visible = false end
		if textLabel then textLabel.Visible = true end
	else
		if lockedFrame then lockedFrame.Visible = true end
		if textLabel then textLabel.Visible = false end
	end
end

-- On écoute si le serveur donne soudainement le pass via la Roue !
player:GetAttributeChangedSignal("HasX3WavePass"):Connect(function()
	updateSpeed3UI()
end)

-- ==========================================
-- 🏃‍♂️ ENVOI DU SIGNAL DE VITESSE AU SERVEUR
-- ==========================================
local function requestWaveSpeed(multiplier: number)
	if changeSpeedEvent then
		changeSpeedEvent:FireServer(multiplier)
	else
		warn("L'événement ChangeWaveSpeed n'existe pas dans ReplicatedStorage.Events !")
	end
end

-- ==========================================
-- 🛒 VÉRIFICATION ET ACHAT DU GAMEPASS
-- ==========================================
task.spawn(function()
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_X3_SPEED)
	end)
	if success and hasPass then
		ownsSpeedPass = true
	end
	updateSpeed3UI()
end)

-- QUAND LE JOUEUR ACHÈTE LE PASS EN JEU :
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(purchasedPlayer, passId, wasPurchased)
	if purchasedPlayer == player and passId == GAMEPASS_X3_SPEED and wasPurchased then
		ownsSpeedPass = true
		updateSpeed3UI() -- Enlève le cadenas
		requestWaveSpeed(3) -- ⚡ ACTIVE LA VITESSE X3 IMMÉDIATEMENT !
	end
end)

-- ==========================================
-- 🖱️ CLICS SUR LES BOUTONS
-- ==========================================
-- Sync GUI khi WaveSpeedMultiplier thay đổi (debug command hoặc nút bấm)
local speed1Text = speed1Btn:FindFirstChild("Text")
local function updateSpeedDisplay()
	local mult = player:GetAttribute("WaveSpeedMultiplier") or 1
	if speed1Text then
		speed1Text.Text = "x" .. tostring(mult)
	end
end
player:GetAttributeChangedSignal("WaveSpeedMultiplier"):Connect(updateSpeedDisplay)

speed1Btn.MouseButton1Click:Connect(function()
	requestWaveSpeed(1)
end)

speed2Btn.MouseButton1Click:Connect(function()
	requestWaveSpeed(2)
end)

speed3Btn.MouseButton1Click:Connect(function()
	local hasWonPass = (player:GetAttribute("HasX3WavePass") == true)

	if ownsSpeedPass or hasWonPass then
		requestWaveSpeed(3)
	else
		MarketplaceService:PromptGamePassPurchase(player, GAMEPASS_X3_SPEED)
	end
end)