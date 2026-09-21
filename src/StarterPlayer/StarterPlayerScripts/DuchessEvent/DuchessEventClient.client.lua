--!strict
-- LOCATION: StarterPlayer/StarterPlayerScripts/DuchessEvent/DuchessEventClient.client.lua
-- Duchess / Astro Toilet Event — config only, logic lives in EventClientClass.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventClientClass  = require(ReplicatedStorage.Modules.EventClientClass)

EventClientClass.new({
	remotePrefix      = "DuchessEvent",
	notificationDelay = 5.6,
	adminUserId       = 11115679011,
	strokeColor       = Color3.fromRGB(100, 0, 0),
	gradientColor     = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 85)),
	}),
	triggerButtonText = "▶ Trigger Astro Event",
	endButtonText     = "⏹ End Astro Event",
})

-- ============================================================
-- EventTeleport button visibility
-- ============================================================

local function getEventTeleportButton(): GuiObject?
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("GUI")
	local btn = gui
		and (gui :: any):FindFirstChild("HUD")
		and (gui :: any).HUD:FindFirstChild("Top")
		and (gui :: any).HUD.Top:FindFirstChild("Buttons")
		and (gui :: any).HUD.Top.Buttons:FindFirstChild("EventTeleport") :: GuiObject?
	return btn
end

local function setEventTeleportVisible(visible: boolean)
	local btn = getEventTeleportButton()
	if not btn then return end
	;(btn :: any).Visible = visible
	-- Bàn tay onboarding — chỉ hiện khi button hiện
	local onboarding = (btn :: any):FindFirstChild("Onboarding")
	if onboarding then
		onboarding.Visible = visible
	end
end

-- Ẩn button ngay khi load để đảm bảo trạng thái mặc định
task.defer(function()
	setEventTeleportVisible(false)
end)

local eventsFolder = ReplicatedStorage:WaitForChild("Events")
eventsFolder:WaitForChild("DuchessEventStart").OnClientEvent:Connect(function()
	setEventTeleportVisible(true)
end)
eventsFolder:WaitForChild("DuchessEventEnd").OnClientEvent:Connect(function()
	setEventTeleportVisible(false)
end)
