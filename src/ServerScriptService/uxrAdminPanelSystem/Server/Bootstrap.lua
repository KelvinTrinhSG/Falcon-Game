--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local uxrRS = ReplicatedStorage:WaitForChild("uxrAdminPanelSystem", 10)

local PlayerLifecycle  = require(script.Parent.PlayerLifecycle)
local MessagingHub     = require(script.Parent.MessagingHub)
local PeriodicTasks    = require(script.Parent.PeriodicTasks)
local CommandRegistry  = require(script.Parent.CommandRegistry)
local ApiHandlers      = require(script.Parent.ApiHandlers)

CommandRegistry.init(
    require(uxrRS.Config.Commands),
    require(script.Parent.Commands)
)

require(script.Parent.CustomCommands)

PlayerLifecycle.init()
MessagingHub.init()
PeriodicTasks.init()
ApiHandlers.init()


return true
