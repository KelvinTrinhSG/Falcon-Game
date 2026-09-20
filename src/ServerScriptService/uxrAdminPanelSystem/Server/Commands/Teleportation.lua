--!nocheck

local S = require(script.Parent._shared)
local Players            = S.Players
local TeleportService    = S.TeleportService
local apEvents           = S.apEvents
local PlayerDataManager  = S.PlayerDataManager
local withCharacter      = S.withCharacter

local TargetResolver = require(script.Parent.Parent.TargetResolver)

local function moveTo(char, cf)
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
    end
end

return {
    teleport = function(ctx, args)
        local me = ctx.actor.Character
        local them = args.target.Character
        if me and them and them:FindFirstChild("HumanoidRootPart") then
            moveTo(me, them.HumanoidRootPart.CFrame * CFrame.new(1, 0, 0))
        end
    end,

    bring = function(ctx, args)
        local me = ctx.actor.Character
        local them = args.target.Character
        if me and them and me:FindFirstChild("HumanoidRootPart") then
            moveTo(them, me.HumanoidRootPart.CFrame * CFrame.new(1, 0, 0))
        end
    end,

    tpplayer = function(ctx, args)
        local dest, err = TargetResolver.resolveSingle(ctx.actor, args.to)
        if err or not dest then ctx.notify("tpplayer: "..(err or "no dest")); return end
        local fromChar = args.from.Character or args.from.CharacterAdded:Wait()
        local toChar   = dest.Character     or dest.CharacterAdded:Wait()
        if fromChar and toChar and toChar:FindFirstChild("HumanoidRootPart") then
            moveTo(fromChar, toChar.HumanoidRootPart.CFrame * CFrame.new(1, 0, 0))
        end
    end,

    warp = function(ctx, args)
        withCharacter(ctx.actor, function(char)
            local data = PlayerDataManager.GetWarp(args.name)
            if data and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(data[1], data[2], data[3])
            end
        end)
    end,

    view = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "spectateStart", args.target.Name)
    end,
    unview = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "spectateStop", args.target.Name)
    end,

    livetrack = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "liveTrackAdd", args.target.Name)
    end,
    unlivetrack = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "liveTrackRemove", args.target.Name)
    end,
    unlivetrackall = function(ctx)
        apEvents.RemoteEvent:FireClient(ctx.actor, "liveTrackClear")
    end,

    rejoin = function(ctx, args)
        local target = args and args.target or ctx.actor
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, target)
        end)
        if not ok then ctx.notify(("rejoin failed: %s"):format(err), "error") end
    end,

    join = function(ctx, args)
        local destPlayer = args.target
        local ok1, place = pcall(function()
            return TeleportService:GetPlayerPlaceInstanceAsync(destPlayer.UserId)
        end)
        if not ok1 then
            ctx.notify("join: can't locate that player", "error"); return
        end
        local placeId, jobId
        if type(place) == "table" then
            placeId = place.placeId or place[1]
            jobId   = place.jobId   or place[2]
        else
            placeId = place
        end
        if placeId and jobId and jobId ~= "" then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, ctx.actor)
        elseif placeId then
            TeleportService:Teleport(placeId, ctx.actor)
        else
            ctx.notify("join: that player isn't in a teleportable place", "error")
        end
    end,

    place = function(ctx, args)
        local placeId = tonumber(args.placeId)
        if not placeId or placeId <= 0 then
            ctx.notify("place: invalid placeId", "error"); return
        end
        local target = args.target or ctx.actor
        local players = (typeof(target) == "table") and target or { target }
        local ok, err = pcall(function()
            TeleportService:Teleport(placeId, players[1])
            for i = 2, #players do TeleportService:Teleport(placeId, players[i]) end
        end)
        if not ok then ctx.notify(("place failed: %s"):format(err), "error") end
    end,

    follow = function(ctx, args)
        local ok1, userId = pcall(function() return Players:GetUserIdFromNameAsync(args.username) end)
        if not ok1 or not userId then ctx.notify("follow: user not found"); return end

        local ok2, result = pcall(function() return TeleportService:GetPlayerPlaceInstanceAsync(userId) end)
        if not ok2 then ctx.notify("follow: can't locate that player"); return end

        local placeId, jobId
        if type(result) == "table" then
            placeId = result.placeId or result[1]
            jobId   = result.jobId   or result[2]
        else
            placeId = result
        end

        if placeId and type(placeId) == "number" and jobId and jobId ~= "" then
            TeleportService:TeleportToPlaceInstance(placeId, jobId, ctx.actor)
        elseif placeId then
            TeleportService:Teleport(placeId, ctx.actor)
        end
    end,
}
