--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local FrameManager = require(ReplicatedStorage.Modules.FrameManager)
-- ## ADDED ## Get the PlacementController to exit preview mode
local PlacementHandler = require(ReplicatedStorage.Modules.PlacementHandler)

local WaveButton = script.Parent
local DesignFrame = WaveButton:WaitForChild("Design")
local TextLabel = WaveButton:WaitForChild("Text")
local Gradient = DesignFrame:WaitForChild("Gradient")
local Stroke = DesignFrame:WaitForChild("Stroke")
local TextStroke = TextLabel:WaitForChild("Stroke")

local ToggleWaveStateEvent = ReplicatedStorage.Events:WaitForChild("ToggleWaveState")
local WaveStateChangedEvent = ReplicatedStorage.Events:WaitForChild("WaveStateChanged")

-- Color presets for the button states
local FIGHT_STROKE_COLOR = Color3.fromRGB(33, 100, 0)
local FIGHT_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

local STOP_STROKE_COLOR = Color3.fromRGB(130, 0, 0)
local STOP_GRADIENT = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 127))
})

local isWaveActive = false

local function updateButtonState()
	if isWaveActive then
		TextLabel.Text = "Stop"
		Stroke.Color = STOP_STROKE_COLOR
		TextStroke.Color = STOP_STROKE_COLOR
		Gradient.Color = STOP_GRADIENT
	else
		TextLabel.Text = "Fight"
		Stroke.Color = FIGHT_STROKE_COLOR
		TextStroke.Color = FIGHT_STROKE_COLOR
		Gradient.Color = FIGHT_GRADIENT
	end
end

WaveStateChangedEvent.OnClientEvent:Connect(function(isActive: boolean)
	isWaveActive = isActive
	updateButtonState()
end)

WaveButton.MouseButton1Click:Connect(function()
	-- If the fight is about to start, close inventory and exit placement mode.
	if not isWaveActive then
		FrameManager.close("Inventory")
		PlacementHandler:ExitAllModes() -- ## ADDED ##
	end

	ToggleWaveStateEvent:FireServer()
end)

-- Initial setup
updateButtonState()