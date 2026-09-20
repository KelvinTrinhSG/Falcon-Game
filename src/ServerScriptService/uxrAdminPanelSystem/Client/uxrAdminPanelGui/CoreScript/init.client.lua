--!nocheck

local function waitFor(parent, name)
    local inst = parent:WaitForChild(name, 10)
    if not inst then
        warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name)
    end
    return inst
end

local screen  = script.Parent
local Modules = waitFor(script, "Modules")

local Context        = require(Modules.Context)
local Format         = require(Modules.Format)
local Templates      = require(Modules.Templates)
local Ranks          = require(Modules.Ranks)
local Placeholder    = require(Modules.Placeholder)
local Sidebar        = require(Modules.Sidebar)
local Navbar         = require(Modules.Navbar)
local UserInfo       = require(Modules.UserInfo)
local EventDispatch  = require(Modules.EventDispatch)
local Animations     = require(Modules.Animations)
local Motion         = require(Modules.Motion)
local Theme          = require(Modules.Theme)
local HoverScan      = require(Modules.HoverScan)
local Specular       = require(Modules.Specular)
local Sticky         = require(Modules.Sticky)
local Themed         = require(Modules.Themed)
local Spectate       = require(Modules.Spectate)
local Notify         = require(Modules.Notify)
local Modal          = require(Modules.Modal)
local Punishment     = require(Modules.Punishment)
local Composer       = require(Modules.Composer)
local PlayerProfile  = require(Modules.PlayerProfile)
local InventoryViewer= require(Modules.InventoryViewer)
local EditData       = require(Modules.EditData)
local SkyboxPicker   = require(Modules.SkyboxPicker)
local VoteLauncher   = require(Modules.VoteLauncher)
local VoteDisplay    = require(Modules.VoteDisplay)
local MobileToggle   = require(Modules.MobileToggle)
local LiveTrack      = require(Modules.LiveTrack)
local RoleInfo       = require(Modules.RoleInfo)
local Hint           = require(Modules.Hint)
local ColorPicker    = require(Modules.ColorPicker)
local AssetPicker    = require(Modules.AssetPicker)
local ChatPrefix     = require(Modules.ChatPrefix)
local LaserEyes      = require(Modules.LaserEyes)
local Responsive     = require(Modules.Responsive)
local Pages          = waitFor(Modules, "Pages")

local ctx = Context.new(screen)
ctx.Motion = Motion
ctx.Theme  = Theme
ctx.Modal           = Modal.init(ctx)
ctx.Punishment      = Punishment.init(ctx)
ctx.Composer        = Composer.init(ctx)
ctx.PlayerProfile   = PlayerProfile.init(ctx)
ctx.InventoryViewer = InventoryViewer.init(ctx)
ctx.EditData        = EditData.init(ctx)
ctx.SkyboxPicker    = SkyboxPicker.init(ctx)
ctx.VoteLauncher    = VoteLauncher.init(ctx)
ctx.VoteDisplay     = VoteDisplay.init(ctx)
MobileToggle.init(ctx)
Responsive.init(ctx)

ctx.Format    = Format
ctx.Templates = Templates
ctx.Ranks     = Ranks.init(ctx)

do
    local Commands = ctx.Commands
    function ctx.getCommand(name)
        local key = (name or ""):lower()
        if Commands[key] then return Commands[key] end
        for n, c in pairs(Commands) do
            if n:lower() == key then return c end
        end
        for _, c in pairs(Commands) do
            for _, a in ipairs(c.Aliases or {}) do
                if a:lower() == key then return c end
            end
        end
        return nil
    end
end

ctx.Animations    = Animations
ctx._origMainSize = ctx.mainFrame.Size
ctx._origCmdSize  = ctx.commandFrame.Size
function ctx.toggleScreen(value)
    if value == nil then value = not ctx.screen.Enabled end
    Animations.setScreenEnabled(ctx.screen, ctx.mainFrame, ctx._origMainSize, value)
end
function ctx.togglePopup(value)
    if value == nil then value = not ctx.commandFrame.Visible end
    Animations.setPopupVisible(ctx.commandFrame, ctx._origCmdSize, value)
end

if not ctx.UtilModule:HasRank(ctx.LocalPlayer, ctx.Permissions.NavSeeRank or "NonAdmin") then
    screen.Enabled = false
    return
end

ctx.screen.Enabled       = false
ctx.mainFrame.Visible    = true
ctx.commandFrame.Visible = false

Sidebar.init(ctx)
Navbar.init(ctx)
UserInfo.init(ctx)

for _, name in ipairs({"Home", "Players", "Commands", "Logs", "Analytics", "Servers", "Chat", "Settings"}) do
    local pageModule = require(waitFor(Pages, name))
    pageModule.init(ctx)
end
require(waitFor(Pages, "CommandPopup")).init(ctx)

Placeholder.wireAll(ctx)
EventDispatch.init(ctx)
Notify:init(ctx)
HoverScan.init(ctx)

Specular.init()
Sticky.init(ctx)
Themed.init(ctx)
Spectate.init(ctx)
LiveTrack.init(ctx)
RoleInfo.init(ctx)
Hint.init(ctx)
ColorPicker.init(ctx)
AssetPicker.init(ctx)
ChatPrefix.init()
LaserEyes.init(ctx)

ctx.showOnly("Home")

task.spawn(function()
    task.wait(1)

    if ctx.Settings.WelcomeNotification == false then return end

    local myRank = ctx.Ranks.myRank
    local commandCount = 0
    for _, cmd in pairs(ctx.Commands) do
        if ctx.UtilModule:CanRunCommand(ctx.LocalPlayer, cmd) then
            commandCount += 1
        end
    end

    ctx.Notify:show({
        title       = "Welcome to UXR Admin Panel",
        description = "You're authorized. Press \"/\" to open the panel, \";\" for the command bar, or type \"u!\" in chat.",
        kind        = "info",
        duration    = 7,
    })

    task.wait(0.5)

    ctx.Notify:show({
        title       = ("Your rank is '%s'"):format(myRank.DisplayName or myRank.Name),
        description = ("Click to view the %d command%s you can run."):format(
            commandCount, commandCount == 1 and "" or "s"),
        kind        = "success",
        duration    = 9,
        onClick = function()
            if not ctx.screen.Enabled then ctx.toggleScreen(true) end
            if ctx.showOnly then ctx.showOnly("Commands") end
        end,
    })
end)
