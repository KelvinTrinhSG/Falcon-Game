--!strict
-- LOCATION: StarterPlayer/StarterPlayerScripts/DuchessEvent/DuchessEventClient.client.lua
-- Astro Toilet Event — client-side countdown GUI + test button for admin

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local TEST_PLAYER_ID = 11115679011

-- RemoteEvents (created by server on boot)
local eventsFolder       = ReplicatedStorage:WaitForChild("Events")
local DuchessEventStart  = eventsFolder:WaitForChild("DuchessEventStart")
local DuchessEventEnd    = eventsFolder:WaitForChild("DuchessEventEnd")
local DuchessTestTrigger = eventsFolder:WaitForChild("DuchessTestTrigger")
local DuchessEndTrigger  = eventsFolder:WaitForChild("DuchessEndTrigger")

-- NotificationTemplate (same one used by the notification system)
local notificationTemplate: TextLabel = ReplicatedStorage
	:WaitForChild("Templates")
	:WaitForChild("NotificationTemplate")

local STROKE_COLOR   = Color3.fromRGB(100, 0, 0)
local GRADIENT_COLOR = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 85)),
})

local TWEEN_FADE               = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NOTIFICATION_DISPLAY_TIME = 5.6

-- ============================================================
-- Helpers
-- ============================================================

local function formatTime(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

-- ============================================================
-- Countdown state
-- ============================================================

local activeGui: ScreenGui?      = nil
local countdownLabel: TextLabel? = nil
local countdownThread: thread?   = nil
local eventActive: boolean       = false

-- stopCountdown forward declaration (used inside startCountdown's thread)
local stopCountdown: () -> ()

local function destroyGui()
	-- Cancel thread first to avoid it calling stopCountdown after destroy
	if countdownThread then
		task.cancel(countdownThread)
		countdownThread = nil
	end
	if activeGui then
		activeGui:Destroy()
		activeGui      = nil
		countdownLabel = nil
	end
end

local function startCountdown(duration: number)
	destroyGui()

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name           = "DuchessEventCountdown"
	screenGui.ResetOnSpawn   = false
	screenGui.IgnoreGuiInset = false
	screenGui.DisplayOrder   = 20
	screenGui.Parent         = PlayerGui
	activeGui = screenGui

	local label: TextLabel = notificationTemplate:Clone()
	label.Text         = formatTime(duration)
	label.TextScaled   = true
	label.AnchorPoint  = Vector2.new(0.5, 0)
	label.Position     = UDim2.new(0.5, 0, 0.05, 0)
	label.Size         = UDim2.new(0, 220, 0, 70)
	label.Parent       = screenGui
	countdownLabel     = label

	local stroke: UIStroke?     = label:FindFirstChild("Stroke") :: UIStroke?
	local gradient: UIGradient? = label:FindFirstChild("Gradient") :: UIGradient?
	if stroke   then stroke.Color   = STROKE_COLOR   end
	if gradient then gradient.Color = GRADIENT_COLOR  end

	-- Fade in
	label.TextTransparency = 1
	if stroke then stroke.Transparency = 1 end
	TweenService:Create(label, TWEEN_FADE, { TextTransparency = 0 }):Play()
	if stroke then TweenService:Create(stroke, TWEEN_FADE, { Transparency = 0 }):Play() end

	-- Countdown loop
	local endTime = os.clock() + duration
	countdownThread = task.spawn(function()
		while true do
			local remaining = endTime - os.clock()
			if remaining <= 0 then
				label.Text = "0:00"
				break
			end
			label.Text = formatTime(remaining)
			task.wait(0.5)
		end
		task.wait(0.5)
		stopCountdown()
	end)
end

stopCountdown = function()
	-- Null refs immediately — prevents re-entry if called twice simultaneously
	if not activeGui or not countdownLabel then return end
	local label = countdownLabel
	local gui   = activeGui
	countdownLabel = nil
	activeGui      = nil

	-- Cancel the countdown thread so it doesn't call stopCountdown again
	if countdownThread then
		task.cancel(countdownThread)
		countdownThread = nil
	end

	local stroke: UIStroke? = label:FindFirstChild("Stroke") :: UIStroke?
	TweenService:Create(label, TWEEN_FADE, { TextTransparency = 1 }):Play()
	if stroke then TweenService:Create(stroke, TWEEN_FADE, { Transparency = 1 }):Play() end

	task.delay(TWEEN_FADE.Time + 0.1, function()
		if gui and gui.Parent then
			gui:Destroy()
		end
	end)
end

-- ============================================================
-- Test Button (admin only)
-- ============================================================

local function buildTestButton()
	if LocalPlayer.UserId ~= TEST_PLAYER_ID then return end

	local testGui = Instance.new("ScreenGui")
	testGui.Name         = "DuchessTestGui"
	testGui.ResetOnSpawn = false
	testGui.Parent       = PlayerGui

	local btn = Instance.new("TextButton")
	btn.Size             = UDim2.new(0, 160, 0, 40)
	btn.Position         = UDim2.new(0, 10, 1, -60)
	btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	btn.TextColor3       = Color3.fromRGB(255, 255, 255)
	btn.Font             = Enum.Font.GothamBold
	btn.TextSize         = 14
	btn.Text             = "▶ Trigger Astro Event"
	btn.BorderSizePixel  = 0
	btn.Parent           = testGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		DuchessTestTrigger:FireServer()
	end)

	local endBtn = Instance.new("TextButton")
	endBtn.Size             = UDim2.new(0, 160, 0, 40)
	endBtn.Position         = UDim2.new(0, 10, 1, -110)
	endBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
	endBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
	endBtn.Font             = Enum.Font.GothamBold
	endBtn.TextSize         = 14
	endBtn.Text             = "⏹ End Astro Event"
	endBtn.BorderSizePixel  = 0
	endBtn.Parent           = testGui

	local endCorner = Instance.new("UICorner")
	endCorner.CornerRadius = UDim.new(0, 8)
	endCorner.Parent = endBtn

	endBtn.MouseButton1Click:Connect(function()
		DuchessEndTrigger:FireServer()
	end)
end

-- ============================================================
-- Remote Listeners
-- ============================================================

DuchessEventStart.OnClientEvent:Connect(function(startTime: number, totalDuration: number)
	eventActive = true
	task.delay(NOTIFICATION_DISPLAY_TIME, function()
		if not eventActive then return end
		local elapsed   = os.time() - startTime
		local remaining = totalDuration - elapsed
		if remaining > 0 then
			startCountdown(remaining)
		end
	end)
end)

DuchessEventEnd.OnClientEvent:Connect(function()
	eventActive = false
	stopCountdown()
end)

-- ============================================================
-- Boot
-- ============================================================

buildTestButton()
