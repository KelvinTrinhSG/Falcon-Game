--[[
	Main Server Script
	
	Description: The entry point for all server-side game logic.
	It initializes the Bootstrap module which loads, initializes,
	and starts all other controller scripts.
	
	Location: ServerScriptService
--]]
--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local Bootstrap = require(ServerScriptService.Modules.Bootstrap)

-- Run the bootstrap process and tell it to look for controllers
-- inside the "Controllers" folder.
Bootstrap(ServerScriptService.Controllers)
