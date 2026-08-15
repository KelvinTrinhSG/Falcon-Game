--!strict
-- LOCATION: ServerScriptService/KnitServer.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.knit)

-- Load services
require(ServerScriptService.Services.DebugService)

Knit.Start():andThen(function()
	print("[Knit] Server started")
end):catch(warn)
