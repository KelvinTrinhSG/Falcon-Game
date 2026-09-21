--!strict
-- LOCATION: StarterPlayer/StarterPlayerScripts/DuchessEvent/DuchessEventClient.client.lua
-- Astro Toilet Event — client-side countdown GUI + test button for admin

local Players        = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService   = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local TEST_PLAYER_ID = 11115679011

-- Wait for RemoteEvents created by server
local eventsFolder    = ReplicatedStorage:WaitForChild("Events")
local DuchessEventStart  = eventsFolder:WaitForChild("DuchessEventStart")
local DuchessEventEnd    = eventsFolder:WaitForChild("DuchessEventEnd")
local DuchessTestTrigger = eventsFolder:WaitForChild("DuchessTestTrigger")

-- ============================================================
-- Build Countdown GUI
-- ============================================================

local function buildCountdownGui(): (ScreenGui, TextLabel, TextLabel)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name              = "DuchessEventCountdown"
	screenGui.ResetOnSpawn      = false
	screenGui.IgnoreGuiInset    = false
	screenGui.ZIndexBehavior    = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder      = 10

	-- Outer frame
	local frame = Instance.new("Frame")
	frame.Name              = "EventFrame"
	frame.Size              = UDim2.new(0, 280, 0, 90)
	frame.Position          = UDim2.new(1, -300, 0, 20)
	frame.BackgroundColor3  = Color3.fromRGB(20, 10, 10)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel   = 0
	frame.Parent            = screenGui

	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	-- Gradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 30, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 0, 180)),
	})
	gradient.Rotation = 90
	gradient.Parent = frame

	-- Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color       = Color3.fromRGB(255, 80, 0)
	stroke.Thickness   = 2
	stroke.Transparency = 0
	stroke.Parent = frame

	-- Title label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name              = "Title"
	titleLabel.Size              = UDim2.new(1, -10, 0, 28)
	titleLabel.Position          = UDim2.new(0, 5, 0, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text              = "⚔️  ASTRO TOILET EVENT"
	titleLabel.TextColor3        = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled        = true
	titleLabel.Font              = Enum.Font.GothamBold
	titleLabel.Parent            = frame

	-- Countdown label
	local countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name              = "Countdown"
	countdownLabel.Size              = UDim2.new(1, -10, 0, 32)
	countdownLabel.Position          = UDim2.new(0, 5, 0, 33)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Text              = "4:00"
	countdownLabel.TextColor3        = Color3.fromRGB(255, 220, 100)
	countdownLabel.TextScaled        = true
	countdownLabel.Font              = Enum.Font.GothamBold
	countdownLabel.Parent            = frame

	-- Sub-label
	local subLabel = Instance.new("TextLabel")
	subLabel.Name              = "Sub"
	subLabel.Size              = UDim2.new(1, -10, 0, 18)
	subLabel.Position          = UDim2.new(0, 5, 0, 68)
	subLabel.BackgroundTransparency = 1
	subLabel.Text              = "Defend the main base now!"
	subLabel.TextColor3        = Color3.fromRGB(255, 180, 180)
	subLabel.TextScaled        = true
	subLabel.Font              = Enum.Font.Gotham
	subLabel.Parent            = frame

	return screenGui, countdownLabel, frame
end

-- ============================================================
-- Build Test Button (admin only)
-- ============================================================

local function buildTestButton()
	if LocalPlayer.UserId ~= TEST_PLAYER_ID then return end

	local testGui = Instance.new("ScreenGui")
	testGui.Name         = "DuchessTestGui"
	testGui.ResetOnSpawn = false
	testGui.Parent       = PlayerGui

	local btn = Instance.new("TextButton")
	btn.Size              = UDim2.new(0, 160, 0, 40)
	btn.Position          = UDim2.new(0, 10, 1, -60)
	btn.BackgroundColor3  = Color3.fromRGB(180, 0, 0)
	btn.TextColor3        = Color3.fromRGB(255, 255, 255)
	btn.Font              = Enum.Font.GothamBold
	btn.TextSize          = 14
	btn.Text              = "▶ Trigger Duchess Event"
	btn.Parent            = testGui

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		DuchessTestTrigger:FireServer()
	end)
end

-- ============================================================
-- Countdown Logic
-- ============================================================

local TWEEN_FADE = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local activeGui: ScreenGui?     = nil
local countdownThread: thread?  = nil

local function formatTime(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	local m = math.floor(s / 60)
	local sec = s % 60
	return string.format("%d:%02d", m, sec)
end

local function destroyGui()
	if countdownThread then
		task.cancel(countdownThread)
		countdownThread = nil
	end
	if activeGui then
		activeGui:Destroy()
		activeGui = nil
	end
end

local function startCountdown(duration: number)
	destroyGui() -- safety: clean up any existing GUI

	local screenGui, countdownLabel, frame = buildCountdownGui()
	screenGui.Parent = PlayerGui
	activeGui = screenGui

	-- Fade in
	frame.BackgroundTransparency = 1
	local uiStroke = frame:FindFirstChildOfClass("UIStroke")
	if uiStroke then uiStroke.Transparency = 1 end
	countdownLabel.TextTransparency = 1
	for _, label in frame:GetChildren() do
		if label:IsA("TextLabel") then
			label.TextTransparency = 1
		end
	end

	local fadeIn = TweenService:Create(frame, TWEEN_FADE, { BackgroundTransparency = 0.15 })
	fadeIn:Play()
	if uiStroke then
		TweenService:Create(uiStroke, TWEEN_FADE, { Transparency = 0 }):Play()
	end
	for _, label in frame:GetChildren() do
		if label:IsA("TextLabel") then
			TweenService:Create(label, TWEEN_FADE, { TextTransparency = 0 }):Play()
		end
	end

	-- Countdown loop
	local endTime = os.clock() + duration
	countdownThread = task.spawn(function()
		while true do
			local remaining = endTime - os.clock()
			if remaining <= 0 then
				countdownLabel.Text = "0:00"
				break
			end
			countdownLabel.Text = formatTime(remaining)
			task.wait(0.5)
		end
		-- Client-side safety: if server hasn't sent End yet, clean up anyway
		task.wait(1)
		destroyGui()
	end)
end

local function stopCountdown()
	if not activeGui then return end

	-- Fade out then destroy
	local frame = activeGui:FindFirstChild("EventFrame")
	if frame then
		local uiStroke = frame:FindFirstChildOfClass("UIStroke")
		TweenService:Create(frame, TWEEN_FADE, { BackgroundTransparency = 1 }):Play()
		if uiStroke then
			TweenService:Create(uiStroke, TWEEN_FADE, { Transparency = 1 }):Play()
		end
		for _, label in frame:GetChildren() do
			if label:IsA("TextLabel") then
				TweenService:Create(label, TWEEN_FADE, { TextTransparency = 1 }):Play()
			end
		end
	end

	task.delay(TWEEN_FADE.Time + 0.1, function()
		destroyGui()
	end)
end

-- ============================================================
-- Remote Listeners
-- ============================================================

DuchessEventStart.OnClientEvent:Connect(function(duration: number)
	startCountdown(duration)
end)

DuchessEventEnd.OnClientEvent:Connect(function()
	stopCountdown()
end)

-- ============================================================
-- Boot
-- ============================================================

buildTestButton()
