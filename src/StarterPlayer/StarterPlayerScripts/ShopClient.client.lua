--[[
	ShopClient Script
	
	Description: Listens for the OpenShopFrame event from the server and
	uses the FrameManager to open the specified shop UI.
	
	Location: StarterPlayerScripts
--]]
--!strict

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local FrameManager = require(ReplicatedStorage.Modules.FrameManager)

-- Events
local openShopFrameEvent: RemoteEvent = ReplicatedStorage.Events:WaitForChild("OpenShopFrame")

-- Listen for the server's instruction to open a shop frame
openShopFrameEvent.OnClientEvent:Connect(function(frameName: string)
	print(`Received instruction to open frame: {frameName}`)
	FrameManager.open(frameName)
end)
