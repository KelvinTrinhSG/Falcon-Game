local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

local eventRemote = ReplicatedStorage:WaitForChild("Events", math.huge)
	:WaitForChild("SecretAgentEventNotify", math.huge)

-- BillboardUI labels
local billboardTouch = workspace:WaitForChild("NewEvent", math.huge)
	:WaitForChild("Touch", math.huge)
local billboardFrame = billboardTouch:WaitForChild("BillboardUI", math.huge)
	:WaitForChild("Frame", math.huge)
local timeLabel  = billboardFrame:WaitForChild("Time", math.huge):WaitForChild("Required", math.huge)
local worldLabel = billboardFrame:WaitForChild("World", math.huge)

local function formatTime(seconds: number): string
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%02d:%02d", m, s)
end

-- State
local isActive       = false
local eventStartedAt = 0
local eventDuration  = 0

-- Countdown loop
RunService.Heartbeat:Connect(function()
	local now = os.time()
	if isActive then
		local remaining = math.max(0, eventDuration - (now - eventStartedAt))
		timeLabel.Text = formatTime(remaining)
	else
		-- Đếm ngược đến đầu giờ UTC tiếp theo
		local t = os.date("!*t", now)
		local secondsIntoHour = t.min * 60 + t.sec
		local secondsUntilNext = 3600 - secondsIntoHour
		timeLabel.Text = formatTime(secondsUntilNext)
	end
end)

eventRemote.OnClientEvent:Connect(function(action: string, startedAt: number?, duration: number?)
	if action == "start" then
		isActive = true
		eventStartedAt = startedAt or os.time()
		eventDuration  = duration or 300
		worldLabel.Text = "Active"
		NotificationManager.show("Secret Agent has appeared! Go find them!", "Info")

	elseif action == "end" then
		isActive = false
		worldLabel.Text = "Soon"
		NotificationManager.show("The Secret Agent Event has ended.", "Info")

	elseif action == "collect" then
		NotificationManager.show("You collected a Secret Agent turret!", "Success")
	end
end)

-- Default state khi mới join
worldLabel.Text = "Soon"
