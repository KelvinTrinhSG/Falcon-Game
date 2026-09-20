--!nocheck

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local uxrRS    = ReplicatedStorage:WaitForChild("uxrAdminPanelSystem", 10)
local apEvents = uxrRS:WaitForChild("Core"):WaitForChild("apEvents")

local Settings     = require(uxrRS.Config.Settings)
local Permissions  = require(uxrRS.Config.Permissions)
local UtilModule   = require(uxrRS.Lib.Util)
local ArgTypes     = require(uxrRS.Lib.ArgTypes)

local CommandParser   = require(script.Parent.CommandParser)
local CommandRegistry = require(script.Parent.CommandRegistry)
local TargetResolver  = require(script.Parent.TargetResolver)

local PlayerDataManager, WebhookService, AnalyticsService

local CommandDispatcher = {}

local KIND_COLOR = {
    info    = "#3498DB",
    success = "#1ABC9C",
    warning = "#F1C40F",
    error   = "#D53535",
}

local function notify(actor, text, kind)
    if not actor or not text then return end
    local color = KIND_COLOR[kind] or KIND_COLOR.error
    apEvents.RemoteEvent:FireClient(actor, "notify", tostring(text), 3, 0, 0, color)
end

local lastCommandAt = {}
local function isThrottled(actor, commandName, force)
    if force then return false end
    local minGap = (Settings.CommandFrequencies and Settings.CommandFrequencies[commandName])
                 or Settings.CommandDebounce or 0
    if minGap <= 0 then return false end
    local bucket = lastCommandAt[actor.UserId]
    if not bucket then
        bucket = {}; lastCommandAt[actor.UserId] = bucket
    end
    local now  = os.clock()
    local last = bucket[commandName] or 0
    if (now - last) < minGap then return true end
    bucket[commandName] = now
    return false
end
Players.PlayerRemoving:Connect(function(p) lastCommandAt[p.UserId] = nil end)

local vipBlacklist = {}
for _, cn in ipairs(Settings.VIPServerCommandBlacklist or {}) do vipBlacklist[cn] = true end
local function blockedInVipServer(commandName)
    return game.PrivateServerId ~= ""
       and game.PrivateServerOwnerId ~= 0
       and vipBlacklist[commandName] == true
end

local typeCtx = { Permissions = Permissions, UtilModule = UtilModule }

local function resolveArgs(actor, def, rawArgs)
    local typed = {}
    local targetArgName

    local argSpecs = def.Args or {}
    local i = 1
    while i <= #argSpecs do
        local spec = argSpecs[i]
        local raw  = rawArgs[i]

        if spec.joinRest and not spec.type:find("Players") then
            local rest = {}
            for k = i, #rawArgs do table.insert(rest, rawArgs[k]) end
            raw = #rest > 0 and table.concat(rest, " ") or nil
        end

        if spec.type == "Players" then
            local list, err = TargetResolver.resolve(actor, raw or spec.default or "me")
            if err then return nil, ("'%s': %s"):format(spec.name, err) end
            typed[spec.name] = list
            targetArgName    = spec.name
        else
            local typedef = ArgTypes[spec.type]
            if not typedef then
                return nil, ("internal: unknown arg type '%s' on '%s'"):format(tostring(spec.type), spec.name)
            end
            local value, err = typedef.parse(raw, spec, typeCtx)
            if err then return nil, err end
            typed[spec.name] = value
        end

        i += 1
    end

    return typed, nil, targetArgName
end

local function makeCtx(actor, modifiers)
    return {
        actor       = actor,
        modifiers   = modifiers,
        notify      = function(text, kind)
            if not modifiers.silent then notify(actor, text, kind) end
        end,
        apEvents    = apEvents,
        Players     = Players,
        Settings    = Settings,
        Permissions = Permissions,
        UtilModule  = UtilModule,
    }
end

local function execStatement(actor, stmt)
    local mods = stmt.modifiers or {}
    local def  = CommandRegistry.get(stmt.command)
    if not def then
        return ("unknown command '%s' — try u!help"):format(stmt.command)
    end
    if not UtilModule:Allows(actor, def.Permission) then
        return ("you don't have permission for '%s'"):format(def.Name)
    end
    if blockedInVipServer(def.Name) then
        return ("'%s' is disabled in private VIP servers"):format(def.Name)
    end
    if mods.force and not UtilModule:HasRank(actor, "Admin") then
        mods.force = nil
    end
    if isThrottled(actor, def.Name, mods.force) then
        return
    end

    local typedArgs, err, targetArgName = resolveArgs(actor, def, stmt.args)
    if err then return err end

    local ctx = makeCtx(actor, mods)
    local repeats = math.max(1, mods.n or 1)

    if not PlayerDataManager then PlayerDataManager = require(script.Parent.PlayerDataManager) end
    if not WebhookService    then WebhookService    = require(script.Parent.Services.WebhookService) end
    if not AnalyticsService  then AnalyticsService  = require(script.Parent.Services.AnalyticsService) end
    AnalyticsService:RecordCommand(def.Name, actor.Name)

    local function buildDescription(targetName)
        local parts = {}
        if targetName and targetName ~= "" then
            table.insert(parts, "→ " .. targetName)
        end
        if not def.Args or #def.Args == 0 then return table.concat(parts, "  ·  ") end
        for _, spec in ipairs(def.Args) do
            if spec.name ~= targetArgName then
                local v = typedArgs[spec.name]
                if v ~= nil and v ~= "" then
                    local s
                    local t = typeof(v)
                    if t == "Color3" then
                        s = ("#%02X%02X%02X"):format(math.floor(v.R*255+0.5), math.floor(v.G*255+0.5), math.floor(v.B*255+0.5))
                    elseif t == "Vector3" then
                        s = ("(%.1f, %.1f, %.1f)"):format(v.X, v.Y, v.Z)
                    elseif t == "EnumItem" then
                        s = v.Name
                    elseif t == "Instance" and v:IsA("Player") then
                        s = v.Name
                    elseif type(v) == "table" then
                        s = ("%d item(s)"):format(#v)
                    else
                        s = tostring(v)
                    end
                    if not (spec.default ~= nil and tostring(spec.default) == s) then
                        table.insert(parts, spec.name .. ": " .. s)
                    end
                end
            end
        end
        return table.concat(parts, "  ·  ")
    end

    local function logIfNeeded(targetName)
        if def.Log     then PlayerDataManager:AddLog(actor, def.Name, targetName or "", buildDescription(targetName)) end
        if def.Webhook then WebhookService:SendWebhook(actor.UserId, actor.Name, def.Name, targetName or "") end
    end

    local actedOn

    if targetArgName then
        local targets = typedArgs[targetArgName]
        for _ = 1, repeats do
            for _, target in ipairs(targets) do
                typedArgs[targetArgName] = target
                local ok, ex = pcall(def.Code, ctx, typedArgs)
                if not ok then warn("[uxrAPS v5] '"..def.Name.."' errored:", ex) end
                logIfNeeded(target.Name)
            end
        end
        typedArgs[targetArgName] = targets
        if #targets == 1 then actedOn = targets[1] and targets[1].Name
        elseif #targets > 1 then actedOn = (#targets).." players" end
    else
        for _ = 1, repeats do
            local ok, ex = pcall(def.Code, ctx, typedArgs)
            if not ok then warn("[uxrAPS v5] '"..def.Name.."' errored:", ex) end
        end
        logIfNeeded(actor.Name)
    end

    if not mods.silent and not def.Quiet then
        local label
        if actedOn then label = ("✓ %s · %s"):format(def.Name, actedOn)
        else label = ("✓ %s"):format(def.Name) end
        apEvents.RemoteEvent:FireClient(actor, "notify", label, 1.8, 0, 0, "#1ABC9C")
    end

    return nil
end

function CommandDispatcher.execute(actor, rawText)
    if not actor or not actor.Parent then return end
    local parsed, perr = CommandParser.parse(rawText)
    if not parsed then
        notify(actor, perr)
        return
    end

    for _, stmt in ipairs(parsed.statements) do
        local err = execStatement(actor, stmt)
        if err and not (stmt.modifiers and stmt.modifiers.silent) then
            notify(actor, err)
        end
    end
end

return CommandDispatcher
