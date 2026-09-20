--!nocheck

local Players              = game:GetService("Players")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local TextChatService      = game:GetService("TextChatService")
local UserInputService     = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")
local Stats                = game:GetService("Stats")
local LogService           = game:GetService("LogService")
local Lighting             = game:GetService("Lighting")
local Workspace            = game:GetService("Workspace")

local function waitFor(parent, name)
    local inst = parent:WaitForChild(name, 10)
    if not inst then
        warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name)
    end
    return inst
end

local Context = {}

function Context.new(screen)
    local mainFrame    = waitFor(screen, "MainFrame")
    local commandFrame = waitFor(screen, "CommandFrame")
    local uxrRS        = waitFor(ReplicatedStorage, "uxrAdminPanelSystem")
    local apEvents     = waitFor(waitFor(uxrRS, "Core"), "apEvents")

    local UtilModule  = require(waitFor(waitFor(uxrRS, "Lib"), "Util"))
    local Settings    = require(uxrRS.Config.Settings)
    local Commands    = require(uxrRS.Config.Commands)
    local Permissions = require(uxrRS.Config.Permissions)

    local ctx = {
        Players          = Players,
        RunService       = RunService,
        UserInputService = UserInputService,
        TextChatService  = TextChatService,
        Stats            = Stats,
        LogService       = LogService,
        Lighting         = Lighting,
        Workspace        = Workspace,
        LocalPlayer      = Players.LocalPlayer,

        screen       = screen,
        mainFrame    = mainFrame,
        commandFrame = commandFrame,
        navbar       = waitFor(mainFrame, "NavbarFrame"),
        sidebarSF    = waitFor(waitFor(mainFrame, "SidebarFrame"), "ScrollingFrame"),
        userInfo     = waitFor(mainFrame, "UserInfoFrame"),
        searchFrame  = waitFor(mainFrame, "SearchFrame"),

        pages = {
            Home      = waitFor(mainFrame, "HomeFrame"),
            Players   = waitFor(mainFrame, "PlayersFrame"),
            Commands  = waitFor(mainFrame, "CommandsFrame"),
            Servers   = waitFor(mainFrame, "ServersFrame"),
            Chat      = waitFor(mainFrame, "ChatFrame"),
            Logs      = waitFor(mainFrame, "LogsFrame"),
            Analytics = waitFor(mainFrame, "AnalyticsFrame"),
            Settings  = waitFor(mainFrame, "SettingsFrame"),
        },

        uxrRS = uxrRS,

        RemoteEvent    = waitFor(apEvents, "RemoteEvent"),
        RemoteFunction = waitFor(apEvents, "RemoteFunction"),

        Settings    = Settings,
        Commands    = Commands,
        Permissions = Permissions,
        UtilModule  = UtilModule,

        state = {
            currentPage    = nil,
            selectedTarget = nil,
        },

        showOnly     = nil,
        refreshHooks = {},
    }

    local CATEGORY_ORDER = {
        Movement = 1, Teleportation = 2, Combat = 3, Cosmetic = 4,
        Inventory = 5, Moderation = 6, ServerOps = 7, Messaging = 8,
        Rank = 9, Utility = 10, Help = 11,
    }
    function ctx.sortedCommands(predicate)
        local getCommandRank = ctx.Ranks and ctx.Ranks.getCommandRank
        local out = {}
        for name, cmd in pairs(ctx.Commands) do
            if not predicate or predicate(name, cmd) then
                local rank = getCommandRank and getCommandRank(cmd)
                table.insert(out, { name = name, cmd = cmd, level = rank and rank.Level or 0 })
            end
        end
        table.sort(out, function(a, b)
            if a.level ~= b.level then return a.level < b.level end
            local ca = CATEGORY_ORDER[a.cmd.Category] or 99
            local cb = CATEGORY_ORDER[b.cmd.Category] or 99
            if ca ~= cb then return ca < cb end
            return a.name:lower() < b.name:lower()
        end)
        return out
    end

    return ctx
end

return Context
