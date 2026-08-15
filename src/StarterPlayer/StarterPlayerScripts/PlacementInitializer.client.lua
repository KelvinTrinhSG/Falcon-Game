--!strict
--[[
	SCRIPT: PlacementInitializer (LocalScript)
	LOCATION: StarterPlayerScripts/PlacementInitializer.lua
	DESCRIPTION: Initializes the client-side PlacementHandler module.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- ## MODIFIED ## Renamed to PlacementHandler
local PlacementHandler = require(ReplicatedStorage.Modules:WaitForChild("PlacementHandler"))

PlacementHandler:Init()