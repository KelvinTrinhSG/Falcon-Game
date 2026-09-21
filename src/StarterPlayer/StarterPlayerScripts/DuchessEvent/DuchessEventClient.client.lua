--!strict
-- LOCATION: StarterPlayer/StarterPlayerScripts/DuchessEvent/DuchessEventClient.client.lua
-- Duchess / Astro Toilet Event — config only, logic lives in EventClientClass.

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
