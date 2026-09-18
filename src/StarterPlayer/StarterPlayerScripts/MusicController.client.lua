--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings UI
local settingsScreen = playerGui:WaitForChild("Settings")
local mainFrame = settingsScreen:WaitForChild("Frame")

local uiScale = mainFrame:FindFirstChildOfClass("UIScale")
if not uiScale then
	uiScale = Instance.new("UIScale")
	uiScale.Parent = mainFrame
end
uiScale.Scale = 1

local exitButton = mainFrame:WaitForChild("Exit")
local gui = playerGui:WaitForChild("GUI")
local hud = gui:WaitForChild("HUD")
local openButton = hud:FindFirstChild("Settings", true)

if openButton then
	local buttonScale = openButton:FindFirstChildOfClass("UIScale")
	if not buttonScale then
		buttonScale = Instance.new("UIScale")
		buttonScale.Parent = openButton
	end
	buttonScale.Scale = 1
	openButton.MouseEnter:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.1}):Play()
	end)
	openButton.MouseLeave:Connect(function()
		TweenService:Create(buttonScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
	end)
end

-- Volume slider
local list = mainFrame:WaitForChild("List")
local template = list:WaitForChild("Template")
local sliderFrame = template:WaitForChild("SliderFrame")
local sliderButton = sliderFrame:WaitForChild("Slider")

-- Sounds
local normalMusic = SoundService:WaitForChild("NormalMusic")
local bossMusic = SoundService:WaitForChild("BossMusic")
local fightingMusic = SoundService:WaitForChild("FightingMusic")

local NORMAL_IDS = {
	"rbxassetid://105471320630827",
	"rbxassetid://98294731871015",
}

local currentVolume = 1
local currentMusic: Sound? = nil
local isBossActive = false
local FADE = 1.5

local function stopWithFade(sound: Sound)
	if not sound.IsPlaying then return end
	TweenService:Create(sound, TweenInfo.new(FADE, Enum.EasingStyle.Linear), {Volume = 0}):Play()
	task.delay(FADE, function() sound:Stop() end)
end

local function playMusic(sound: Sound, soundId: string?)
	if soundId then sound.SoundId = soundId end
	for _, s in ipairs({normalMusic, bossMusic, fightingMusic} :: {Sound}) do
		if s ~= sound then stopWithFade(s) end
	end
	sound.Looped = true
	sound.Volume = 0
	sound:Play()
	TweenService:Create(sound, TweenInfo.new(FADE, Enum.EasingStyle.Linear), {Volume = currentVolume}):Play()
	currentMusic = sound
end

local function playNormalMusic()
	local id = NORMAL_IDS[math.random(1, #NORMAL_IDS)]
	playMusic(normalMusic, id)
end

-- Stop any auto-playing sounds from Studio, then start normal music
for _, s in ipairs({normalMusic, bossMusic, fightingMusic} :: {Sound}) do
	s:Stop()
end
playNormalMusic()

-- Game state events
local Events = ReplicatedStorage:WaitForChild("Events")

Events:WaitForChild("WaveStateChanged").OnClientEvent:Connect(function(isActive: boolean)
	if isActive then
		if not isBossActive then
			playMusic(fightingMusic, "rbxassetid://102925780230657")
		end
	else
		isBossActive = false
		playNormalMusic()
	end
end)

Events:WaitForChild("BossWaveStarted").OnClientEvent:Connect(function()
	isBossActive = true
	playMusic(bossMusic, "rbxassetid://78744747224727")
end)

Events:WaitForChild("BossWaveEnded").OnClientEvent:Connect(function()
	isBossActive = false
	playMusic(fightingMusic, "rbxassetid://102925780230657")
end)

Events:WaitForChild("ShowGameOver").OnClientEvent:Connect(function()
	isBossActive = false
	playNormalMusic()
end)

Events:WaitForChild("GameWin").OnClientEvent:Connect(function()
	isBossActive = false
	playNormalMusic()
end)

-- Settings menu toggle
local isDragging = false
local isOpen = settingsScreen.Enabled

local function toggleSettings()
	isOpen = not isOpen
	if isOpen then
		settingsScreen.Enabled = true
		uiScale.Scale = 0
		TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	else
		local tweenClose = TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		tweenClose:Play()
		tweenClose.Completed:Connect(function()
			if not isOpen then settingsScreen.Enabled = false end
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

-- Volume slider
local function updateVolume(input)
	local framePos = sliderFrame.AbsolutePosition.X
	local frameSize = sliderFrame.AbsoluteSize.X
	local percentage = math.clamp((input.Position.X - framePos) / frameSize, 0, 1)
	sliderButton.Position = UDim2.new(percentage, 0, sliderButton.Position.Y.Scale, sliderButton.Position.Y.Offset)
	currentVolume = percentage
	if currentMusic then currentMusic.Volume = percentage end
end

local function startDragging(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		updateVolume(input)
	end
end

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

sliderButton.Position = UDim2.new(1, 0, sliderButton.Position.Y.Scale, sliderButton.Position.Y.Offset)
