--[[
	SCRIPT: NotificationClient (LocalScript)
	LOCATION: StarterPlayerScripts/NotificationClient.lua
	DESCRIPTION: Listens for the "ShowNotification" event from the server
	and displays the message using the NotificationManager module.
--]]
--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local NotificationManager = require(ReplicatedStorage.Modules:WaitForChild("NotificationManager"))

-- Events
local showNotificationEvent: RemoteEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

-- Connect to the event and show the notification when the server sends one.
showNotificationEvent.OnClientEvent:Connect(function(message: string, messageType: string?)
	NotificationManager.show(message, messageType)
end)