--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- On part du joueur pour trouver l'interface proprement
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CORRECTION : Settings est directement dans PlayerGui, pas dans "GUI/Frames" !
local settingsScreen = playerGui:WaitForChild("Settings")

-- On descend dans ton arborescence jusqu'au bouton
local mainFrame = settingsScreen:WaitForChild("Frame")
local list = mainFrame:WaitForChild("List")
local template = list:WaitForChild("Template")
local sliderFrame = template:WaitForChild("SliderFrame")
local sliderButton = sliderFrame:WaitForChild("Slider")

-- Tes 3 musiques
local normalMusic = SoundService:WaitForChild("NormalMusic")
local bossMusic = SoundService:WaitForChild("BossMusic")
local fightingMusic = SoundService:WaitForChild("FightingMusic")

local isDragging = false

-- Fonction qui calcule le volume selon la position de la souris
local function updateVolume(input)
	local framePos = sliderFrame.AbsolutePosition.X
	local frameSize = sliderFrame.AbsoluteSize.X

	-- On calcule où se trouve la souris sur la barre (entre 0 et 1)
	local mousePos = input.Position.X
	local percentage = math.clamp((mousePos - framePos) / frameSize, 0, 1)

	-- 1. On déplace le curseur visuellement (sur l'axe X)
	sliderButton.Position = UDim2.new(percentage, 0, sliderButton.Position.Y.Scale, sliderButton.Position.Y.Offset)

	-- 2. On change le volume des 3 musiques
	normalMusic.Volume = percentage
	bossMusic.Volume = percentage
	fightingMusic.Volume = percentage
end

-- Quand le joueur CLIQUE sur la barre
sliderFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		updateVolume(input)
	end
end)

-- Quand le joueur GLISSE la souris
UserInputService.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateVolume(input)
	end
end)

-- Quand le joueur RELÂCHE le clic
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = false
	end
end)

-- Initialisation : on met le curseur tout à droite par défaut
sliderButton.Position = UDim2.new(1, 0, sliderButton.Position.Y.Scale, sliderButton.Position.Y.Offset)