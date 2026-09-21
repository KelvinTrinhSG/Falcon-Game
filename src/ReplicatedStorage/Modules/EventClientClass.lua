--!strict
-- LOCATION: ReplicatedStorage/Modules/EventClientClass.lua
-- Generic client-side Event OOP class.
-- Each instance is fully independent: own GUI, own threads, own remotes.
--
-- Usage:
--   local EventClientClass = require(ReplicatedStorage.Modules.EventClientClass)
--   local myEvent = EventClientClass.new({
--       remotePrefix          = "MyEvent",
--       notificationDelay     = 5.6,
--       adminUserId           = 12345,
--       strokeColor           = Color3.fromRGB(100, 0, 0),
--       gradientColor         = ColorSequence.new({...}),
--       triggerButtonText     = "▶ Trigger",
--       endButtonText         = "⏹ End",
--   })

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local notificationTemplate: TextLabel = ReplicatedStorage
	:WaitForChild("Templates")
	:WaitForChild("NotificationTemplate")

local TWEEN_FADE = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ============================================================
-- EventClientClass
-- ============================================================

local EventClientClass = {}
EventClientClass.__index = EventClientClass

export type EventClientConfig = {
	remotePrefix       : string,
	notificationDelay  : number,
	adminUserId        : number,
	strokeColor        : Color3,
	gradientColor      : ColorSequence,
	triggerButtonText  : string,
	endButtonText      : string,
}

function EventClientClass.new(config: EventClientConfig)
	local self = setmetatable({}, EventClientClass)

	self._config          = config
	self._eventActive     = false
	self._activeGui       = nil :: ScreenGui?
	self._countdownLabel  = nil :: TextLabel?
	self._countdownThread = nil :: thread?

	-- Remotes
	local eventsFolder = ReplicatedStorage:WaitForChild("Events")
	local p = config.remotePrefix
	self._remotes = {
		Start       = eventsFolder:WaitForChild(p .. "Start")       :: RemoteEvent,
		End         = eventsFolder:WaitForChild(p .. "End")         :: RemoteEvent,
		TestTrigger = eventsFolder:WaitForChild(p .. "TestTrigger") :: RemoteEvent,
		EndTrigger  = eventsFolder:WaitForChild(p .. "EndTrigger")  :: RemoteEvent,
	}

	self:_setupListeners()
	self:_buildAdminButtons()

	return self
end

-- ============================================================
-- Helpers
-- ============================================================

local function formatTime(seconds: number): string
	local s = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

-- ============================================================
-- GUI
-- ============================================================

function EventClientClass:_buildCountdownGui(): (ScreenGui, TextLabel)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name           = self._config.remotePrefix .. "Countdown"
	screenGui.ResetOnSpawn   = false
	screenGui.IgnoreGuiInset = false
	screenGui.DisplayOrder   = 20
	screenGui.Parent         = PlayerGui

	local label: TextLabel = notificationTemplate:Clone()
	label.Text        = "4:00"
	label.TextScaled  = true
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position    = UDim2.new(0.5, 0, 0.05, 0)
	label.Size        = UDim2.new(0, 220, 0, 70)
	label.Parent      = screenGui

	local stroke: UIStroke?     = label:FindFirstChild("Stroke") :: UIStroke?
	local gradient: UIGradient? = label:FindFirstChild("Gradient") :: UIGradient?
	if stroke   then stroke.Color   = self._config.strokeColor   end
	if gradient then gradient.Color = self._config.gradientColor  end

	return screenGui, label
end

function EventClientClass:_destroyGui()
	if self._countdownThread then
		task.cancel(self._countdownThread)
		self._countdownThread = nil
	end
	if self._activeGui then
		self._activeGui:Destroy()
		self._activeGui     = nil
		self._countdownLabel = nil
	end
end

function EventClientClass:_startCountdown(duration: number)
	self:_destroyGui()

	local screenGui, label = self:_buildCountdownGui()
	self._activeGui      = screenGui
	self._countdownLabel = label

	local stroke: UIStroke? = label:FindFirstChild("Stroke") :: UIStroke?

	-- Fade in
	label.TextTransparency = 1
	if stroke then stroke.Transparency = 1 end
	TweenService:Create(label, TWEEN_FADE, { TextTransparency = 0 }):Play()
	if stroke then TweenService:Create(stroke, TWEEN_FADE, { Transparency = 0 }):Play() end

	-- Countdown loop
	local endTime = os.clock() + duration
	self._countdownThread = task.spawn(function()
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
		self:_stopCountdown()
	end)
end

function EventClientClass:_stopCountdown()
	-- Null refs immediately to prevent re-entry if called from two places at once
	if not self._activeGui or not self._countdownLabel then return end
	local label = self._countdownLabel
	local gui   = self._activeGui
	self._countdownLabel = nil
	self._activeGui      = nil

	if self._countdownThread then
		task.cancel(self._countdownThread)
		self._countdownThread = nil
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
-- Remote listeners
-- ============================================================

function EventClientClass:_setupListeners()
	local notifDelay = self._config.notificationDelay

	self._remotes.Start.OnClientEvent:Connect(function(startTime: number, totalDuration: number)
		self._eventActive = true
		task.delay(notifDelay, function()
			if not self._eventActive then return end
			local remaining = totalDuration - (os.time() - startTime)
			if remaining > 0 then
				self:_startCountdown(remaining)
			end
		end)
	end)

	self._remotes.End.OnClientEvent:Connect(function()
		self._eventActive = false
		self:_stopCountdown()
	end)
end

-- ============================================================
-- Admin buttons
-- ============================================================

function EventClientClass:_buildAdminButtons()
	if LocalPlayer.UserId ~= self._config.adminUserId then return end

	local testGui = Instance.new("ScreenGui")
	testGui.Name         = self._config.remotePrefix .. "TestGui"
	testGui.ResetOnSpawn = false
	testGui.Parent       = PlayerGui

	local function makeButton(text: string, bgColor: Color3, posY: number): TextButton
		local btn = Instance.new("TextButton")
		btn.Size             = UDim2.new(0, 160, 0, 40)
		btn.Position         = UDim2.new(0, 10, 1, posY)
		btn.BackgroundColor3 = bgColor
		btn.TextColor3       = Color3.fromRGB(255, 255, 255)
		btn.Font             = Enum.Font.GothamBold
		btn.TextSize         = 14
		btn.Text             = text
		btn.BorderSizePixel  = 0
		btn.Parent           = testGui
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = btn
		return btn
	end

	local triggerBtn = makeButton(self._config.triggerButtonText, Color3.fromRGB(180, 0, 0), -60)
	local endBtn     = makeButton(self._config.endButtonText,     Color3.fromRGB(80, 0, 0),  -110)

	triggerBtn.MouseButton1Click:Connect(function()
		self._remotes.TestTrigger:FireServer()
	end)
	endBtn.MouseButton1Click:Connect(function()
		self._remotes.EndTrigger:FireServer()
	end)
end

return EventClientClass
