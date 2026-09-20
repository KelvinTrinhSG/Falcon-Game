--!nocheck

local S = require(script.Parent._shared)
local apEvents = S.apEvents
local Tools    = S.Tools

return {
    servermessage       = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "serverMessage")       end,
    globalservermessage = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "globalMessage") end,
    chatmessage         = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "chatMessage")         end,
    vote                = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openVoteLauncher")            end,
    globalVote          = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openVoteLauncher", true)      end,
    notifications       = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openNotifyHistory")       end,
    roleinfo            = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openRoleInfo")            end,

    sellgamepass = function(ctx, args)
        local MS = game:GetService("MarketplaceService")
        local id = tonumber(args.assetId); if not id then ctx.notify("sellgamepass: invalid id", "error"); return end
        pcall(MS.PromptGamePassPurchase, MS, args.target, id)
    end,
    sellproduct = function(ctx, args)
        local MS = game:GetService("MarketplaceService")
        local id = tonumber(args.assetId); if not id then ctx.notify("sellproduct: invalid id", "error"); return end
        pcall(MS.PromptProductPurchase, MS, args.target, id)
    end,
    sellasset = function(ctx, args)
        local MS = game:GetService("MarketplaceService")
        local id = tonumber(args.assetId); if not id then ctx.notify("sellasset: invalid id", "error"); return end
        pcall(MS.PromptPurchase, MS, args.target, id)
    end,

    age = function(ctx, args)
        ctx.notify(("%s — %d day account"):format(args.target.Name, args.target.AccountAge), "info")
    end,

    countdown = function(ctx, args)
        local seconds = math.clamp(tonumber(args.seconds) or 10, 1, 600)
        local message = tostring(args.message or "Countdown")
        task.spawn(function()
            for i = seconds, 1, -1 do
                apEvents.RemoteEvent:FireAllClients("notify",
                    ("%s — %ds"):format(message, i), 1.1, 0, 0, "#FFC107")
                task.wait(1)
            end
            apEvents.RemoteEvent:FireAllClients("notify",
                ("%s — GO!"):format(message), 3, 0, 0, "#03fc52")
        end)
    end,

    checkban = function(ctx, args)
        local target = args.target
        local userId = (typeof(target) == "Instance") and target.UserId or tonumber(target)
        if not userId then
            local ok, id = pcall(function() return game.Players:GetUserIdFromNameAsync(tostring(target)) end)
            if ok then userId = id end
        end
        if not userId then ctx.notify("checkban: player not found", "error"); return end

        task.spawn(function()
            local ok, pages = pcall(function() return game.Players:GetBanHistoryAsync(userId) end)
            if not ok or not pages then ctx.notify("checkban: API failed", "error"); return end
            local items = pages:GetCurrentPage()
            local activeCount, total = 0, #items
            local mostRecent
            for _, b in ipairs(items) do
                if b.Active then activeCount += 1; mostRecent = mostRecent or b end
            end
            if activeCount > 0 then
                ctx.notify(("%d active ban(s) of %d — \"%s\""):format(
                    activeCount, total, mostRecent.DisplayReason or "?"), "error")
            else
                ctx.notify(("no active bans (%d historical)"):format(total), "success")
            end
        end)
    end,

    checkwarn = function(ctx, args)
        local list = require(script.Parent.Moderation).warns
        list(ctx, args)
    end,

    checkpermissions = function(ctx)
        apEvents.RemoteEvent:FireClient(ctx.actor, "openRoleInfo")
    end,

    checkrank = function(ctx, args)
        local Players       = game:GetService("Players")
        local UtilModule    = require(game.ReplicatedStorage.uxrAdminPanelSystem.Lib.Util)
        local Permissions   = require(game.ReplicatedStorage.uxrAdminPanelSystem.Config.Permissions)
        local target = args.target
        local userId
        if typeof(target) == "Instance" and target:IsA("Player") then
            userId = target.UserId
        else
            local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(tostring(target)) end)
            if ok then userId = id end
        end
        if not userId then ctx.notify("checkrank: player not found", "error"); return end
        local rank = UtilModule:GetRank({ UserId = userId, Name = tostring(target) })
        local label = rank.DisplayName or rank.Name
        ctx.notify(("%s is %s (level %d)"):format(tostring(target), label, rank.Level or 0), "info")
    end,

    prefix = function(ctx)
        ctx.notify(("Prefix is '%s' — try %shelp"):format(S.Settings.Prefix, S.Settings.Prefix), "info")
    end,

    hint = function(ctx, args)
        local text = tostring(args.text or "")
        if text == "" then return end
        local duration = math.clamp(tonumber(args.duration) or 8, 1, 60)
        apEvents.RemoteEvent:FireAllClients("showHint", text, duration)
    end,

    notice = function(ctx, args)
        apEvents.RemoteEvent:FireClient(args.target, "notify",
            tostring(args.text or ""), 5, 0, 0, "#1ABC9C")
    end,

    alert = function(ctx, args)
        local text = tostring(args.text or "")
        apEvents.RemoteEvent:FireAllClients("notify",
            text, 10, 0, 0, "#EF233C")
    end,
    systemMessage = function(ctx, args)
        apEvents.RemoteEvent:FireAllClients("systemMessage", tostring(args.text or ""))
    end,
    countdown2 = function(ctx, args)
        local seconds = math.clamp(tonumber(args.seconds) or 10, 1, 600)
        local message = tostring(args.message or "Time")
        task.spawn(function()
            for i = seconds, 1, -1 do
                apEvents.RemoteEvent:FireAllClients("notify",
                    ("%s — T-%d"):format(message, i), 1.05, 0, 0, "#EF233C")
                task.wait(1)
            end
            apEvents.RemoteEvent:FireAllClients("notify",
                ("%s"):format(message), 3, 0, 0, "#1ABC9C")
        end)
    end,
    crash = function(ctx, args)
        args.target:Kick("[uxr] crashed by admin")
    end,
    globalAlert = function(ctx, args)
        local text = tostring(args.text or "")
        local CrossServer = require(script.Parent.Parent.CrossServer)
        CrossServer.publish("uxr.alert.v2", { text = text })
        apEvents.RemoteEvent:FireAllClients("notify",
            text, 10, 0, 0, "#EF233C")
    end,

    panel    = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openPage", "Home") end,
    commands = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openPage", "Commands") end,
    settings = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openPage", "Settings") end,
    logs     = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openPage", "Logs") end,
    manager  = function(ctx) apEvents.RemoteEvent:FireClient(ctx.actor, "openPage", "Players") end,

    privatemessage = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "openPrivateMessageDialog", args.target.Name)
    end,

    ping = function(ctx, args)
        local pingMs = math.floor(args.target:GetNetworkPing() * 1000 * 2)
        apEvents.RemoteEvent:FireClient(args.target, "notify", "Player Ping: "..pingMs, 3, 89455602226058, 18984764939, "#ffea00")
    end,

    radio = function(ctx, args)
        local ok, err = S.giveTool(args.target, "BoomBox")
        if not ok then ctx.notify("radio: "..err, "error") end
    end,

    unblur = function(ctx, args)
        ctx.apEvents.RemoteEvent:FireClient(args.target, "setBlur", 0)
    end,

    commandbar = function(ctx)
        ctx.apEvents.RemoteEvent:FireClient(ctx.actor, "toggleCommandBar", true)
    end,
    uncommandbar = function(ctx)
        ctx.apEvents.RemoteEvent:FireClient(ctx.actor, "toggleCommandBar", false)
    end,

    blur = function(ctx, args)
        apEvents.RemoteEvent:FireClient(args.target, "setBlur", args.amount)
    end,
}
