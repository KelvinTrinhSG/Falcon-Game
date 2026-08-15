--!strict
-- LOCATION: StarterPlayerScripts/KnitClient.client.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)

-- Load controllers
local scripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
require(scripts:WaitForChild("Controllers"):WaitForChild("DebugController"))

Knit.Start():andThen(function()
	print("[Knit] Client started")
end):catch(warn)
