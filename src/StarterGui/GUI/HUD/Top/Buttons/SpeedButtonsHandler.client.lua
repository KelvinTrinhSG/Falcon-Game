--!strict
-- LOCATION: GUI/HUD/Top/Buttons/SpeedButtonsHandler (LocalScript)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local buttonsFolder = script.Parent

local speed1Btn = buttonsFolder:WaitForChild("Speed1")
local speed3Btn = buttonsFolder:WaitForChild("Speed3")

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local changeSpeedEvent = eventsFolder:WaitForChild("ChangeWaveSpeed", 5)

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
if speed3Btn:IsA("GuiButton") then applyAnimations(speed3Btn) end

-- Ẩn lock, hiện text cho Speed3 ngay khi load
local lockedFrame = speed3Btn:FindFirstChild("Locked")
local textLabel = speed3Btn:FindFirstChild("Text")
if lockedFrame then lockedFrame.Visible = false end
if textLabel then textLabel.Visible = true end

-- ==========================================
-- 🏃‍♂️ ENVOI DU SIGNAL DE VITESSE AU SERVEUR
-- ==========================================
local function requestWaveSpeed(multiplier: number)
	if changeSpeedEvent then
		changeSpeedEvent:FireServer(multiplier)
	else
		warn("[SpeedButtons] ChangeWaveSpeed event not found in ReplicatedStorage.Events")
	end
end

-- ==========================================
-- 🖱️ CLICS SUR LES BOUTONS
-- ==========================================
local isX2Active = false
local isX3Active = false

local speed1Design = speed1Btn:FindFirstChild("Design")
local speed1Gradient = speed1Design and speed1Design:FindFirstChild("Gradient")
local speed1Stroke = speed1Design and speed1Design:FindFirstChild("Stroke")

local speed3Design = speed3Btn:FindFirstChild("Design")
local speed3Gradient = speed3Design and speed3Design:FindFirstChild("Gradient")
local speed3Stroke = speed3Design and speed3Design:FindFirstChild("Stroke")

local OnStroke = Color3.fromRGB(0, 100, 0)
local OnGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 50))
})
local OffStroke = Color3.fromRGB(80, 80, 80)
local OffGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 120)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
})

local function updateSpeed1Visuals()
	if speed1Gradient then speed1Gradient.Color = isX2Active and OnGradient or OffGradient end
	if speed1Stroke then speed1Stroke.Color = isX2Active and OnStroke or OffStroke end
end

local function updateSpeed3Visuals()
	if speed3Gradient then speed3Gradient.Color = isX3Active and OnGradient or OffGradient end
	if speed3Stroke then speed3Stroke.Color = isX3Active and OnStroke or OffStroke end
end

speed1Btn.MouseButton1Click:Connect(function()
	isX2Active = not isX2Active
	if isX2Active then isX3Active = false end
	updateSpeed1Visuals()
	updateSpeed3Visuals()
	requestWaveSpeed(isX2Active and 2 or 1)
end)

speed3Btn.MouseButton1Click:Connect(function()
	print("[Speed3] Clicked | isX3Active (before) =", isX3Active)
	isX3Active = not isX3Active
	if isX3Active then isX2Active = false end
	updateSpeed1Visuals()
	updateSpeed3Visuals()
	requestWaveSpeed(isX3Active and 3 or 1)
	print("[Speed3] Fired speed", isX3Active and 3 or 1)
end)

updateSpeed1Visuals()
updateSpeed3Visuals()
