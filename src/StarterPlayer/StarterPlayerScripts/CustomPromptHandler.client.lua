--[[
	SCRIPT: CustomPromptHandler (LocalScript)
	LOCATION: StarterPlayerScripts/CustomPromptHandler.lua
	DESCRIPTION: Overrides the default ProximityPrompt UI with a custom,
	stylish version from the templates folder.
--]]
--!strict

local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

ProximityPromptService.Enabled = false

local player: Player = Players.LocalPlayer
local playerGui: PlayerGui = player:WaitForChild("PlayerGui")
local customPromptTemplate: TextButton = ReplicatedStorage.Templates:WaitForChild("CustomPrompt")

local promptContainer: ScreenGui = playerGui:FindFirstChild("PromptContainer") or Instance.new("ScreenGui")
promptContainer.Name = "PromptContainer"
promptContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
promptContainer.Parent = playerGui

local currentPromptUI: TextButton? = nil
local currentPromptObject: ProximityPrompt? = nil
local renderConnection: RBXScriptConnection? = nil
local propertyChangedConnection: RBXScriptConnection? = nil

local placeStrokeColor = Color3.fromRGB(50, 62, 130)
local placeGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 120, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(62, 204, 255))
})

local pickupStrokeColor = Color3.fromRGB(145, 0, 0)
local pickupGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 127))
})

local function updateUIPosition()
	if currentPromptUI and currentPromptObject and currentPromptObject.Parent then
		local worldPosition: Vector3 = currentPromptObject.Parent.Position
		local screenPosition: Vector3, onScreen: boolean = workspace.CurrentCamera:WorldToScreenPoint(worldPosition)
		if onScreen then
			currentPromptUI.Visible = true
			currentPromptUI.Position = UDim2.new(0, screenPosition.X, 0, screenPosition.Y) + UDim2.fromOffset(currentPromptObject.UIOffset.X, currentPromptObject.UIOffset.Y)
		else
			currentPromptUI.Visible = false
		end
	else
		if currentPromptUI then currentPromptUI.Visible = false end
		if renderConnection then
			renderConnection:Disconnect()
			renderConnection = nil
		end
	end
end

local function updatePromptStyle(prompt: ProximityPrompt)
	if not currentPromptUI then return end

	local gradient: UIGradient? = currentPromptUI:FindFirstChild("Gradient")
	local stroke: UIStroke? = currentPromptUI:FindFirstChild("Stroke")
	if not gradient or not stroke then return end

	if prompt.ActionText == "Place Car" then
		stroke.Color = placeStrokeColor
		gradient.Color = placeGradient
	elseif prompt.ActionText == "Pick Up Car" then
		stroke.Color = pickupStrokeColor
		gradient.Color = pickupGradient
	else -- ## FIXED ## The invisible character after 'else' has been replaced with a normal space.
		stroke.Color = placeStrokeColor
		gradient.Color = placeGradient
	end
end

local function onPromptShown(prompt: ProximityPrompt)
	currentPromptUI = customPromptTemplate:Clone()
	currentPromptObject = prompt

	local keyLabel: TextLabel? = currentPromptUI:FindFirstChild("KeyLabel")
	local tapImage: ImageLabel? = currentPromptUI:FindFirstChild("TapImage")

	if UserInputService.TouchEnabled then
		if keyLabel then keyLabel.Visible = false end
		if tapImage then tapImage.Visible = true end
	else
		if keyLabel then
			keyLabel.Visible = true
			keyLabel.Text = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		end
		if tapImage then tapImage.Visible = false end
	end

	updatePromptStyle(prompt)

	currentPromptUI.MouseButton1Click:Connect(function()
		prompt:InputHoldBegin()
		prompt:InputHoldEnd()
	end)

	propertyChangedConnection = prompt:GetPropertyChangedSignal("ActionText"):Connect(function()
		updatePromptStyle(prompt)
	end)

	currentPromptUI.Parent = promptContainer

	if not renderConnection then
		renderConnection = RunService.RenderStepped:Connect(updateUIPosition)
	end
end

local function onPromptHidden()
	if currentPromptUI then
		currentPromptUI:Destroy()
		currentPromptUI = nil
	end
	currentPromptObject = nil

	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	if propertyChangedConnection then
		propertyChangedConnection:Disconnect()
		propertyChangedConnection = nil
	end
end

ProximityPromptService.PromptShown:Connect(onPromptShown)
ProximityPromptService.PromptHidden:Connect(onPromptHidden)