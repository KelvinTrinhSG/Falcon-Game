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

-- NotificationTemplate (same one used by the notification system)
local notificationTemplate: TextLabel = ReplicatedStorage
	:WaitForChild("Templates")
	:WaitForChild("NotificationTemplate")

-- Warning-style colors (matches NotificationManager "Normal" palette)
local STROKE_COLOR   = Color3.fromRGB(145, 97, 0)
local GRADIENT_COLOR = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0)),
})

local TWEEN_FADE = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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

local activeGui: ScreenGui?    = nil
local countdownLabel: TextLabel? = nil
local countdownThread: thread? = nil

local function destroyGui()
	if countdownThread then
		task.cancel(countdownThread)
		countdownThread = nil
	end
	if activeGui then
		activeGui:Destroy()
		activeGui = nil
		countdownLabel = nil
	end
end

local function startCountdown(duration: number)
	destroyGui()

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name           = "DuchessEventCountdown"
	screenGui.ResetOnSpawn   = false
	screenGui.IgnoreGuiInset = false
	screenGui.DisplayOrder   = 20
	screenGui.Parent         = PlayerGui
	activeGui = screenGui

	-- Clone NotificationTemplate (TextLabel with UIStroke + UIGradient)
	local label: TextLabel = notificationTemplate:Clone()
	label.Text            = formatTime(duration)
	label.TextScaled      = true
	-- Center on screen
	label.AnchorPoint     = Vector2.new(0.5, 0)
	label.Position        = UDim2.new(0.5, 0, 0, 0)
	label.Size            = UDim2.new(0, 220, 0, 70)
	label.Parent          = screenGui

	print("[DuchessEvent] Countdown label created — Position:", label.Position, "AbsolutePosition:", label.AbsolutePosition, "Size:", label.Size)
	print("[DuchessEvent] ScreenGui DisplayOrder:", screenGui.DisplayOrder, "Parent:", screenGui.Parent)
	countdownLabel = label

	-- Apply Warning color palette
	local stroke: UIStroke?     = label:FindFirstChild("Stroke") :: UIStroke?
	local gradient: UIGradient? = label:FindFirstChild("Gradient") :: UIGradient?
	if stroke then
		stroke.Color = STROKE_COLOR
	end
	if gradient then
		gradient.Color = GRADIENT_COLOR
	end

	-- Fade in
	label.TextTransparency = 1
	if stroke then stroke.Transparency = 1 end

	TweenService:Create(label, TWEEN_FADE, { TextTransparency = 0 }):Play()
	if stroke then
		TweenService:Create(stroke, TWEEN_FADE, { Transparency = 0 }):Play()
	end

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
		-- Client-side safety: clean up if server End event never arrives
		task.wait(1)
		destroyGui()
	end)
end

local function stopCountdown()
	if not activeGui or not countdownLabel then return end

	local label  = countdownLabel
	local stroke = label:FindFirstChild("Stroke") :: UIStroke?

	TweenService:Create(label, TWEEN_FADE, { TextTransparency = 1 }):Play()
	if stroke then
		TweenService:Create(stroke, TWEEN_FADE, { Transparency = 1 }):Play()
	end

	task.delay(TWEEN_FADE.Time + 0.1, destroyGui)
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
end

-- ============================================================
-- Remote Listeners
-- ============================================================

-- Notification lifetime: 0.3s fade-in + 5s display + 0.3s fade-out ≈ 5.6s
local NOTIFICATION_DISPLAY_TIME = 5.6

DuchessEventStart.OnClientEvent:Connect(function(startTime: number, totalDuration: number)
	print("[DuchessEvent] DuchessEventStart received — startTime:", startTime, "totalDuration:", totalDuration)
	-- Wait for the notification to finish displaying, then show countdown
	task.delay(NOTIFICATION_DISPLAY_TIME, function()
		print("[DuchessEvent] Delay done, activeGui:", activeGui)
		if not activeGui then -- don't show if event already ended
			local elapsed   = os.time() - startTime
			local remaining = totalDuration - elapsed
			print("[DuchessEvent] elapsed:", elapsed, "remaining:", remaining)
			if remaining > 0 then
				startCountdown(remaining)
			else
				warn("[DuchessEvent] No remaining time — countdown skipped")
			end
		else
			warn("[DuchessEvent] activeGui already exists — countdown skipped")
		end
	end)
end)

DuchessEventEnd.OnClientEvent:Connect(function()
	stopCountdown()
end)

-- ============================================================
-- Boot
-- ============================================================

buildTestButton()
