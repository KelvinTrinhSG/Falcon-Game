--!nocheck

local S = require(script.Parent._shared)
local Players            = S.Players
local apEvents           = S.apEvents
local Settings           = S.Settings
local PlayerDataManager  = S.PlayerDataManager
local Builds             = S.Builds
local WorkspaceBuilds    = S.WorkspaceBuilds
local waitForCharacter   = S.waitForCharacter
local UtilModule         = S.UtilModule

local function blockedByFlag(ctx, target, action)
    local ok, reason = UtilModule:CanActOn(target, action)
    if ok then return false end
    apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
        reason or "target is immune", 3, 0, 0, "#D53535")
    return true
end

local function notifyError(actor, msg)
    apEvents.RemoteEvent:FireClient(actor, "notify", msg, 3, 14710282993, 5188022160, "#D53535")
end

local function notifyOk(actor, msg)
    apEvents.RemoteEvent:FireClient(actor, "notify", msg, 3, 14694516293, 6026984224, "#03fc52")
end

return {
    kick = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Kickable") then return end
        args.target:Kick(string.gsub(Settings.Messages.KickMessage, "$reason", args.reason or ""))
    end,

    kickall = function(ctx, args)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= ctx.actor and UtilModule:CanActOn(p, "Kickable") then
                p:Kick(string.gsub(Settings.Messages.KickMessage, "$reason", args.reason or ""))
            end
        end
    end,

    banall = function(ctx, args)
        local reason = tostring(args.reason or "No reason provided")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= ctx.actor and UtilModule:CanActOn(p, "Bannable") then
                pcall(function()
                    Players:BanAsync({
                        UserIds            = { p.UserId },
                        ApplyToUniverse    = true,
                        Duration           = -1,
                        DisplayReason      = reason,
                        PrivateReason      = ("banall by %s"):format(ctx.actor.Name),
                        ExcludeAltAccounts = false,
                    })
                end)
            end
        end
    end,

    ban = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Bannable") then return end
        local userId = args.target.UserId
        local displayReason = string.gsub(Settings.Messages.BanDisplayReason, "$reason", args.reason or "")
        local privateReason = "Player banned by "..ctx.actor.Name.." - Reason: "..(args.reason or "")
        local ok, err = pcall(function()
            Players:BanAsync({
                UserIds = { userId },
                ApplyToUniverse = true,
                Duration = -1,
                DisplayReason = displayReason,
                PrivateReason = privateReason,
                ExcludeAltAccounts = false,
            })
        end)
        if ok then notifyOk(ctx.actor, Settings.Messages.BanSuccess)
        else notifyError(ctx.actor, string.gsub(Settings.Messages.BanFail, "$error", tostring(err))) end
    end,

    tempban = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Bannable") then return end
        local userId = args.target.UserId
        local displayReason = string.gsub(
            string.gsub(Settings.Messages.TempBanDisplayReason, "$reason", args.reason or ""),
            "$duration", tostring(args.duration))
        local privateReason = "Player tempbanned by "..ctx.actor.Name.." for "..args.duration.."s — "..(args.reason or "")
        local ok, err = pcall(function()
            Players:BanAsync({
                UserIds = { userId },
                ApplyToUniverse = true,
                Duration = args.duration,
                DisplayReason = displayReason,
                PrivateReason = privateReason,
                ExcludeAltAccounts = false,
            })
        end)
        if ok then notifyOk(ctx.actor, string.gsub(Settings.Messages.TempBanSuccess, "$duration", tostring(args.duration)))
        else notifyError(ctx.actor, string.gsub(Settings.Messages.TempBanFail, "$error", tostring(err))) end
    end,

    unban = function(ctx, args)
        local id = tonumber(args.target)
        if not id then
            local ok, resolved = pcall(function() return Players:GetUserIdFromNameAsync(args.target) end)
            if ok then id = resolved end
        end
        if not id then notifyError(ctx.actor, "unban: couldn't resolve '"..tostring(args.target).."'"); return end
        PlayerDataManager:RemoveBan(id)
    end,

    directBan = function(ctx, args)
        local id = tonumber(args.target)
        if not id then
            local ok, resolved = pcall(function() return Players:GetUserIdFromNameAsync(args.target) end)
            if ok then id = resolved end
        end
        if not id then
            notifyError(ctx.actor, ("directBan: couldn't resolve '%s'"):format(tostring(args.target)))
            return
        end
        local displayReason = string.gsub(Settings.Messages.BanDisplayReason, "$reason", args.reason or "")
        local privateReason = ("directBan by %s on userId %d — %s"):format(ctx.actor.Name, id, args.reason or "")
        local ok, err = pcall(function()
            Players:BanAsync({
                UserIds = { id },
                ApplyToUniverse = true,
                Duration = -1,
                DisplayReason = displayReason,
                PrivateReason = privateReason,
                ExcludeAltAccounts = false,
            })
        end)
        if ok then notifyOk(ctx.actor, ("directBan: userId %d banned"):format(id))
        else notifyError(ctx.actor, string.gsub(Settings.Messages.BanFail, "$error", tostring(err))) end
    end,

    mute = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Mutable") then return end
        PlayerDataManager:GivePunishment(args.target.UserId, "Mute", args.reason or "", 0, ctx.actor.Name)
        apEvents.RemoteEvent:FireClient(args.target, "selfMute")
    end,

    tempmute = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Mutable") then return end
        PlayerDataManager:GivePunishment(args.target.UserId, "Mute", args.reason or "", args.duration, ctx.actor.Name)
        apEvents.RemoteEvent:FireClient(args.target, "selfMute")
    end,

    unmute = function(ctx, args)
        local ok = PlayerDataManager:RemoveMute(args.target.UserId)
        if ok then apEvents.RemoteEvent:FireClient(args.target, "selfUnmute") end
    end,

    muteall = function()
        apEvents.RemoteEvent:FireAllClients("selfMute")
    end,
    unmuteall = function()
        apEvents.RemoteEvent:FireAllClients("selfUnmute")
    end,

    warn = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Warnable") then return end
        local ok, countOrErr = PlayerDataManager:AddWarning(args.target, args.reason, ctx.actor.Name)
        if not ok then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                "warn failed: "..tostring(countOrErr), 3, 0, 0, "#D53535")
            return
        end
        local total = tonumber(countOrErr) or 0
        apEvents.RemoteEvent:FireClient(args.target, "notify",
            ("Warning from %s: %s  (total: %d)"):format(ctx.actor.Name, args.reason or "", total),
            6, 14710282993, 18984764939, "#ffea00")
        apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
            ("%s now has %d warning(s)"):format(args.target.Name, total),
            3, 14694516293, 6026984224, "#03fc52")

        local threshold = tonumber(Settings.WarnThreshold) or 0
        local action    = tostring(Settings.WarnAutoAction or "none"):lower()
        if threshold <= 0 or action == "none" or total < threshold then return end

        local reason = ("Auto: reached %d warnings"):format(total)
        if action == "kick" then
            local okFlag = select(1, UtilModule:CanActOn(args.target, "Kickable"))
            if okFlag then
                args.target:Kick(string.gsub(Settings.Messages.KickMessage, "$reason", reason))
            end
        elseif action == "tempban" or action == "ban" then
            local okFlag = select(1, UtilModule:CanActOn(args.target, "Bannable"))
            if okFlag then
                local duration = (action == "ban") and -1
                              or (tonumber(Settings.WarnAutoBanDuration) or 86400 * 7)
                pcall(function()
                    Players:BanAsync({
                        UserIds            = { args.target.UserId },
                        ApplyToUniverse    = true,
                        Duration           = duration,
                        DisplayReason      = reason,
                        PrivateReason      = ("Threshold auto-action by %s"):format(ctx.actor.Name),
                        ExcludeAltAccounts = false,
                    })
                end)
            end
        end

        apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
            ("Auto-action fired: %s"):format(action),
            3, 14710282993, 18984764939, "#ffea00")
    end,

    unwarn = function(ctx, args)
        local ok, removed = PlayerDataManager:RemoveLastWarning(args.target)
        if not ok then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                "unwarn: "..tostring(removed), 3, 0, 0, "#D53535")
            return
        end
        apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
            ("Removed warning: %s"):format(removed.Reason or "?"),
            3, 14694516293, 6026984224, "#03fc52")
    end,

    warns = function(ctx, args)
        local list = PlayerDataManager:GetWarnings(args.target)
        local lines = { ("[%s — %d warning(s)]"):format(args.target.Name, #list) }
        if #list == 0 then
            table.insert(lines, "  no warnings on record")
        else
            for i, w in ipairs(list) do
                table.insert(lines, ("  %d. %s — \"%s\" (by %s)"):format(
                    i, w.Date or "?", w.Reason or "?", w.Admin or "?"))
            end
        end
        apEvents.RemoteEvent:FireClient(ctx.actor, "systemMessage", table.concat(lines, "\n"))
    end,

    note = function(ctx, args)
        local target = args.target
        local resolved = (typeof(target) == "Instance" and target:IsA("Player")) and target or S.GetPlayerOrUserId(tostring(target))
        if not resolved then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                ("note: player '%s' not found"):format(tostring(target)), 3, 0, 0, "#D53535")
            return
        end
        local ok, countOrErr = PlayerDataManager:AddNote(resolved, args.text, ctx.actor.Name)
        if not ok then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                "note failed: "..tostring(countOrErr), 3, 0, 0, "#D53535")
            return
        end
        local name = (typeof(resolved) == "Instance") and resolved.Name or ("user "..tostring(resolved))
        apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
            ("Noted on %s (#%d)"):format(name, tonumber(countOrErr) or 0),
            3, 14694516293, 6026984224, "#03fc52")
    end,

    unnote = function(ctx, args)
        local target = args.target
        local resolved = (typeof(target) == "Instance" and target:IsA("Player")) and target or S.GetPlayerOrUserId(tostring(target))
        if not resolved then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                ("unnote: player '%s' not found"):format(tostring(target)), 3, 0, 0, "#D53535")
            return
        end
        local idx = tonumber(args.index) or 1
        local ok, removed = PlayerDataManager:RemoveNote(resolved, idx)
        if not ok then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                "unnote: "..tostring(removed), 3, 0, 0, "#D53535")
            return
        end
        apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
            ("Removed note: %s"):format((removed and removed.Text) or "?"),
            3, 14694516293, 6026984224, "#03fc52")
    end,

    punish = function(ctx, args)
        local reason = tostring(args.reason or "No reason provided")
        if blockedByFlag(ctx, args.target, "Warnable") then return end
        PlayerDataManager:AddWarning(args.target, reason, ctx.actor.Name)
        PlayerDataManager:GivePunishment(args.target, "Mute", reason, 15 * 60, ctx.actor.Name)
        apEvents.RemoteEvent:FireClient(args.target, "notify",
            ("Punished by %s: %s — muted 15m + warning recorded"):format(ctx.actor.Name, reason),
            6, 14710282993, 18984764939, "#ffea00")
        apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
            ("punished %s"):format(args.target.Name), 3, 14694516293, 6026984224, "#03fc52")
    end,

    notes = function(ctx, args)
        local target = args.target
        local resolved = (typeof(target) == "Instance" and target:IsA("Player")) and target or S.GetPlayerOrUserId(tostring(target))
        if not resolved then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                ("notes: player '%s' not found"):format(tostring(target)), 3, 0, 0, "#D53535")
            return
        end
        local list = PlayerDataManager:GetNotes(resolved)
        local name = (typeof(resolved) == "Instance") and resolved.Name or ("user "..tostring(resolved))
        local lines = { ("[%s — %d note(s)]"):format(name, #list) }
        if #list == 0 then
            table.insert(lines, "  no notes on record")
        else
            for i, n in ipairs(list) do
                table.insert(lines, ("  %d. %s — \"%s\" (by %s)"):format(
                    i, n.Date or "?", n.Text or "?", n.Admin or "?"))
            end
        end
        apEvents.RemoteEvent:FireClient(ctx.actor, "systemMessage", table.concat(lines, "\n"))
    end,

    jail = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Jailable") then return end
        local target = args.target
        local duration = args.duration or 0

        if WorkspaceBuilds:FindFirstChild(target.Name.."JailCell") then
            WorkspaceBuilds[target.Name.."JailCell"]:Destroy()
        end
        if not (Builds and Builds:FindFirstChild("JailCell")) then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                "jail: Builds.JailCell missing in Storage/Builds", 4, 0, 0, "#D53535")
            return
        end
        local cell = Builds.JailCell:Clone()
        cell.Name = target.Name.."JailCell"
        cell.Parent = WorkspaceBuilds

        local char = target.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            PlayerDataManager:SetJail(target, "Local", duration)
            cell:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(0, -2.6, 0))
            local spawn = cell:FindFirstChild("SpawnPart")
            if spawn then UtilModule.StandCharacterOn(char, spawn) end
        end

        if duration > 0 then
            task.spawn(function()
                task.wait(duration)
                if PlayerDataManager:CheckJailExpiry(target) then
                    local c = WorkspaceBuilds:FindFirstChild(target.Name.."JailCell")
                    if c then c:Destroy() end
                end
            end)
        end
    end,

    sendjail = function(ctx, args)
        if blockedByFlag(ctx, args.target, "Jailable") then return end
        local target = args.target
        local duration = args.duration or 0
        PlayerDataManager:SetJail(target, "Global", duration)
        target:LoadCharacter()
        local char = waitForCharacter(target)
        if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
        local cell = WorkspaceBuilds:FindFirstChild("PublicCell")
        local spawn = cell and cell:FindFirstChild("SpawnPart")
        if not spawn then
            apEvents.RemoteEvent:FireClient(ctx.actor, "notify",
                "sendjail: PublicCell.SpawnPart missing in Workspace/Builds", 4, 0, 0, "#D53535")
            return
        end
        UtilModule.StandCharacterOn(char, spawn)

        if duration > 0 then
            task.spawn(function()
                task.wait(duration)
                if PlayerDataManager:CheckJailExpiry(target) then
                    local data = PlayerDataManager:GiveLocalPlayerData(target)
                    if target.Parent and data and not data.GlobalPlayerJailed then
                        target:LoadCharacter()
                    end
                end
            end)
        end
    end,

    unjail = function(ctx, args)
        local target = args.target
        local data = PlayerDataManager:GiveLocalPlayerData(target)
        if not data then return end
        local wasLocal  = data.LocalPlayerJailed
        local wasGlobal = data.GlobalPlayerJailed
        PlayerDataManager:RemoveJail(target, "Both")
        PlayerDataManager:ClearSavedJailData(target.UserId)
        if wasLocal then
            local c = WorkspaceBuilds:FindFirstChild(target.Name.."JailCell")
            if c then c:Destroy() end
        end
        if wasGlobal then target:LoadCharacter() end
    end,
}
