--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService") -- NOUVEAU : Le moteur d'animation !

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. L'écran des paramètres
local settingsScreen = playerGui:WaitForChild("Settings")
local mainFrame = settingsScreen:WaitForChild("Frame")

-- NOUVEAU : On crée un "UIScale" pour animer la taille sans casser ton design
local uiScale = mainFrame:FindFirstChildOfClass("UIScale")
if not uiScale then
	uiScale = Instance.new("UIScale")
	uiScale.Parent = mainFrame
end
uiScale.Scale = 1 -- Taille normale par défaut

-- 2. Boutons
local exitButton = mainFrame:WaitForChild("Exit")
local gui = playerGui:WaitForChild("GUI")
local hud = gui:WaitForChild("HUD")
local openButton = hud:FindFirstChild("Settings", true) 

-- ==========================================
-- ✨ ANIMATION DE SURVOL DU BOUTON (HOVER)
-- ==========================================
if openButton then
	-- On crée un UIScale caché dans le bouton s'il n'y en a pas déjà un
	local buttonScale = openButton:FindFirstChildOfClass("UIScale")
	if not buttonScale then
		buttonScale = Instance.new("UIScale")
		buttonScale.Parent = openButton
	end
	buttonScale.Scale = 1

	-- Quand la souris ENTRE sur le bouton (il grossit à 110%)
	openButton.MouseEnter:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
	end)

	-- Quand la souris QUITTE le bouton (il revient à 100%)
	openButton.MouseLeave:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

-- 3. Curseur de musique
local list = mainFrame:WaitForChild("List")
local template = list:WaitForChild("Template")
local sliderFrame = template:WaitForChild("SliderFrame")
local sliderButton = sliderFrame:WaitForChild("Slider")

-- Musiques
local normalMusic = SoundService:WaitForChild("NormalMusic")
local bossMusic = SoundService:WaitForChild("BossMusic")
local fightingMusic = SoundService:WaitForChild("FightingMusic")

local isDragging = false
local isOpen = settingsScreen.Enabled

-- ==========================================
-- ⚙️ GESTION DU MENU (AVEC ANIMATION)
-- ==========================================
local function toggleSettings()
	isOpen = not isOpen

	if isOpen then
		-- ANIMATION D'OUVERTURE
		settingsScreen.Enabled = true
		uiScale.Scale = 0 -- On le rend tout petit

		-- On l'anime avec un effet "Back" (un petit rebond à la fin)
		local tweenOpen = TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
		tweenOpen:Play()
	else
		-- ANIMATION DE FERMETURE
		-- On le rétrécit vite fait
		local tweenClose = TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		tweenClose:Play()

		-- On attend que l'animation finisse pour désactiver l'écran
		tweenClose.Completed:Connect(function()
			if not isOpen then -- Sécurité si le joueur clique super vite
				settingsScreen.Enabled = false
			end
		end)
	end
end

if openButton and openButton:IsA("GuiButton") then
	openButton.MouseButton1Click:Connect(toggleSettings)
end

if exitButton and exitButton:IsA("GuiButton") then
	exitButton.MouseButton1Click:Connect(function()
		if isOpen then toggleSettings() end
	end)
end

-- ==========================================
-- 🎵 GESTION DU VOLUME DE LA MUSIQUE
-- ==========================================
local function updateVolume(input)
	local framePos = sliderFrame.AbsolutePosition.X
	local frameSize = sliderFrame.AbsoluteSize.X

	local mousePos = input.Position.X
	local percentage = math.clamp((mousePos - framePos) / frameSize, 0, 1)

	sliderButton.Position = UDim2.new(percentage, 0, sliderButton.Position.Y.Scale, sliderButton.Position.Y.Offset)

	normalMusic.Volume = percentage
	bossMusic.Volume = percentage
	fightingMusic.Volume = percentage
end

-- NOUVEAU : Une fonction commune pour commencer à glisser
local function startDragging(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		updateVolume(input)
	end
end

-- CORRECTION : Maintenant, on écoute le fond blanc ET le bouton bleu !
sliderFrame.InputBegan:Connect(startDragging)
sliderButton.InputBegan:Connect(startDragging)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateVolume(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
	end
end)

-- On met le curseur tout à droite par défaut
sliderButton.Position = UDim2.new(1, 0, sliderButton.Position.Y.Scale, sliderButton.Position.Y.Offset)