--!strict
-- LOCATION: Dans le LocalScript de ton interface Settings (SettingsController)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")

-- 🎛️ RÉCUPÉRATION SÉCURISÉE DES GROUPES AUDIO
local sfxGroup = SoundService:WaitForChild("SFXGroup")
-- On utilise FindFirstChild pour que ça ne bloque JAMAIS le script si tu n'as pas de MusicGroup
local musicGroup = SoundService:FindFirstChild("MusicGroup") 

local gui = script.Parent
local frame = gui:WaitForChild("Frame")
local list = frame:WaitForChild("List")

-- ==========================================
-- 🎁 SYSTÈME DE CODES PROMO
-- ==========================================
local codeFrame = list:WaitForChild("Code")
local box = codeFrame:WaitForChild("CodeInput")
local redeemCodeEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RedeemCodeEvent")

local function tryClaim()
	local codeText = box.Text:upper():gsub("%s+", "")
	if codeText == "" then return end

	box.Text = "Vérification..."
	redeemCodeEvent:FireServer(codeText)

	task.wait(1)
	box.Text = ""
end

box.FocusLost:Connect(function(enterPressed)
	if enterPressed then tryClaim() end
end)

-- ==========================================
-- 🎚️ FONCTION GÉNÉRIQUE POUR LES SLIDERS
-- ==========================================
local saveSettingsEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SaveSettingsEvent")
local activeSliders = {}

local function setupSlider(sliderFrame: GuiObject, sliderBtn: GuiButton, settingName: string, soundGroup: SoundGroup?)
	local isDragging = false

	-- Met à jour le volume et le visuel
	local function applyVolume(percent: number)
		sliderBtn.Position = UDim2.new(percent, 0, 0.5, 0)
		if soundGroup then
			soundGroup.Volume = percent
		end
	end

	-- Enregistre l'action pour le chargement DataStore
	activeSliders[settingName] = applyVolume

	-- Calcule le pourcentage au clic / glisser
	local function updateSlider(input: InputObject)
		local mouseX = input.Position.X
		local bgPos = sliderFrame.AbsolutePosition.X
		local bgSize = sliderFrame.AbsoluteSize.X

		local percent = math.clamp((mouseX - bgPos) / bgSize, 0, 1)
		applyVolume(percent)

		-- Envoie la valeur au serveur pour la sauvegarde
		saveSettingsEvent:FireServer(settingName, percent)
	end

	-- Événements de clic sur la barre blanche
	sliderFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
			updateSlider(input)
		end
	end)

	-- Événements de clic sur le bouton bleu
	sliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = true
		end
	end)

	-- Relâchement du clic n'importe où
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isDragging = false
		end
	end)

	-- Glissement de la souris
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	-- Animation Hover du bouton bleu
	local sc = sliderBtn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", sliderBtn)
	sliderBtn.MouseEnter:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.08}):Play()
	end)
	sliderBtn.MouseLeave:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.0}):Play()
	end)
end

-- ==========================================
-- 🚀 INITIALISATION DES DEUX SLIDERS
-- ==========================================

-- 1. Configuration de la barre Bruitages (Song)
local songFrame = list:WaitForChild("Song")
local sfxSliderFrame = songFrame:WaitForChild("SliderFrame")
local sfxSliderBtn = sfxSliderFrame:WaitForChild("Slider")
setupSlider(sfxSliderFrame, sfxSliderBtn, "SFX", sfxGroup)

-- 2. Configuration de la barre Musique (Template - OPTION 2 AUTOMATIQUE)
local musicFrame = list:WaitForChild("Template") 
local musicSliderFrame = musicFrame:WaitForChild("SliderFrame")
local musicSliderBtn = musicSliderFrame:WaitForChild("Slider")
setupSlider(musicSliderFrame, musicSliderBtn, "Music", musicGroup)

-- ==========================================
-- 📥 RÉCEPTION ET APPLICATION DE LA SAUVEGARDE
-- ==========================================
saveSettingsEvent.OnClientEvent:Connect(function(savedData)
	if savedData and type(savedData) == "table" then
		-- On remet les deux barres aux positions enregistrées
		if activeSliders["SFX"] and savedData.SFX then activeSliders["SFX"](savedData.SFX) end
		if activeSliders["Music"] and savedData.Music then activeSliders["Music"](savedData.Music) end
	end
end)