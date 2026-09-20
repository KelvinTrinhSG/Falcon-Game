--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")

local function waitFor(parent, name)
    local inst = parent:WaitForChild(name, 10)
    if not inst then warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name) end
    return inst
end

local uxrRS    = waitFor(ReplicatedStorage, "uxrAdminPanelSystem")
local apEvents = waitFor(waitFor(uxrRS, "Core"), "apEvents")

local PlayerDataManager = require(script.Parent.PlayerDataManager)
local Settings          = require(uxrRS.Config.Settings)
local CrossServer       = require(script.Parent.CrossServer)

local MessagingHub = {}

function MessagingHub.init()
    CrossServer.subscribe("uxr.announcement.v2", function(d)
        apEvents.RemoteEvent:FireAllClients("globalMessageBroadcast", d.user, d.msg)
    end)

    CrossServer.subscribe("uxr.GlobalPost.v2", function(d)
        apEvents.RemoteEvent:FireAllClients("globalPost", d.value1, d.value2)
    end)

    CrossServer.subscribe("uxr.AdminChat.v2", function(d, origin)
        if not d or origin == game.JobId then return end
        apEvents.RemoteEvent:FireAllClients("adminChat", d)
    end)

    CrossServer.subscribe("uxr.voteCast.v2", function(d)
        PlayerDataManager:AddVoter(d.voteId, d.optionIndex, d.voter)
        apEvents.RemoteEvent:FireAllClients("voteStatus", PlayerDataManager:GiveVoteInfo(d.voteId), d.voteId)
    end)

    CrossServer.subscribe("uxr.voteStart.v2", function(d)
        PlayerDataManager:StartVote(d.voteId, d.opts)
        apEvents.RemoteEvent:FireAllClients("voteStart", d.duration, d.isStart, d.isGlobal, d.q, d.opts, d.voteId)
        task.spawn(function()
            task.wait(tonumber(d.duration) * 1.25)
            apEvents.RemoteEvent:FireAllClients("voteEnd", d.voteId, PlayerDataManager:GiveVoteInfo(d.voteId))
            task.wait(10)
            PlayerDataManager:RemoveVote(d.voteId)
        end)
    end)

    CrossServer.subscribe("uxr.shutdown.v2", function(_d, origin)
        if origin == game.JobId then return end
        PlayerDataManager.EditServerData("ServerClosed", true)
        apEvents.RemoteEvent:FireAllClients("shutdownWarning")
        task.wait(3)
        for _, v in ipairs(Players:GetPlayers()) do v:Kick(Settings.Messages.ServerClosed) end
    end)

    CrossServer.subscribe("uxr.lockdown.v2", function(d, origin)
        if origin == game.JobId then return end
        PlayerDataManager.EditServerData("Lockdown", d.state and true or false)
        if d.state then
            for _, v in ipairs(Players:GetPlayers()) do
                if not PlayerDataManager:GiveLocalPlayerData(v).LockdownWhitelist then
                    v:Kick(Settings.Messages.LockdownKick)
                end
            end
        end
    end)

    CrossServer.subscribe("uxr.alert.v2", function(d)
        if not d then return end
        apEvents.RemoteEvent:FireAllClients("notify",
            tostring(d.text or ""), 10, 0, 0, "#EF233C")
    end)

    CrossServer.subscribe("uxr.migrate.v2", function(_d, origin)
        if origin == game.JobId then return end
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        end
    end)

    CrossServer.subscribe("uxr.serverList.v2", function(d, origin)
        if not d or not d.ServerId or d.ServerId == game.JobId then return end
        local serversFolder = uxrRS.Core:WaitForChild("Servers")
        local entry
        for _, child in ipairs(serversFolder:GetChildren()) do
            if child:GetAttribute("id") == d.ServerId then
                entry = child; break
            end
        end
        if not entry then
            entry = Instance.new("StringValue")
            entry.Name = d.ServerId
            entry.Parent = serversFolder
        end
        entry:SetAttribute("id",       d.ServerId)
        entry:SetAttribute("Players",  d.Players)
        entry:SetAttribute("Location", d.Location)
        entry:SetAttribute("LastSeen", os.time())
        entry.Value = tostring(d.ServerId).." "..tostring(d.Players)
    end)
end

return MessagingHub
