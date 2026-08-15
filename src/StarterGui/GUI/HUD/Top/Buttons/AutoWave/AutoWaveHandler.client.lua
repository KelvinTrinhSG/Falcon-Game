--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- UI Elements
local autoWaveButton = script.Parent
local DesignFrame = autoWaveButton:WaitForChild("Design")
local Gradient = DesignFrame:WaitForChild("Gradient")
local Stroke = DesignFrame:WaitForChild("Stroke")

-- Events
local SetAutoWaveEvent = ReplicatedStorage.Events:WaitForChild("SetAutoWave")
local AutoWaveStateChangedEvent = ReplicatedStorage.Events:WaitForChild("AutoWaveStateChanged") -- ## ADDED ##

-- State
local isAutoWaveEnabled = false -- Default to off

-- Visual States
local OnStroke = Color3.fromRGB(33, 100, 0)
local OnGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

local OffStroke = Color3.fromRGB(0, 93, 140)
local OffGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
})

local function updateButtonVisuals()
	if isAutoWaveEnabled then
		Gradient.Color = OnGradient
		Stroke.Color = OnStroke
	else
		Gradient.Color = OffGradient
		Stroke.Color = OffStroke
	end
end

-- Listen for the button to be clicked
autoWaveButton.MouseButton1Click:Connect(function()
	-- Toggle the state
	isAutoWaveEnabled = not isAutoWaveEnabled

	-- Update the button's look
	updateButtonVisuals()

	-- Tell the server about the change
	SetAutoWaveEvent:FireServer(isAutoWaveEnabled)
end)

-- ## ADDED ## Listen for the server to force an update to our state
AutoWaveStateChangedEvent.OnClientEvent:Connect(function(newState: boolean)
	-- Check if the state is actually different to avoid redundant updates
	if isAutoWaveEnabled ~= newState then
		isAutoWaveEnabled = newState
		updateButtonVisuals()
	end
end)


-- Set the initial appearance
updateButtonVisuals()