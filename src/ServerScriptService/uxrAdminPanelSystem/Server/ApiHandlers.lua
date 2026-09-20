--!nocheck

local Players           = game:GetService("Players")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorkspaceService  = game:GetService("Workspace")
local MessagingService  = game:GetService("MessagingService")

local function waitFor(parent, name)
    local inst = parent:WaitForChild(name, 10)
    if not inst then warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name) end
    return inst
end

local uxrRS    = waitFor(ReplicatedStorage, "uxrAdminPanelSystem")
local uxrSS    = waitFor(ServerStorage, "uxrAdminPanelSystem")
local apEvents = waitFor(waitFor(uxrRS, "Core"), "apEvents")

local Permissions       = require(uxrRS.Config.Permissions)
local Commands          = require(uxrRS.Config.Commands)
local UtilModule        = require(uxrRS.Lib.Util)
local PlayerDataManager = require(script.Parent.PlayerDataManager)
local CommandDispatcher = require(script.Parent.CommandDispatcher)
local WebhookService    = require(script.Parent.Services.WebhookService)
local AnalyticsService  = require(script.Parent.Services.AnalyticsService)
local CrossServer       = require(script.Parent.CrossServer)

local function allows(player, perm) return UtilModule:Allows(player, perm) end

local function gate(player, perm, label)
    if allows(player, perm) then return true end
    UtilModule:Log("Warn", ("denied %s: %s (%s)"):format(label or "rpc", player.Name, tostring(perm)))
    return false
end

local function pingClient(player, text, color)
    apEvents.RemoteEvent:FireClient(player, "notify", text, 3, 0, 0, color or "#D53535")
end

local ApiHandlers = {}

local events = {}
ApiHandlers.events = events

events.command = function(player, rawText)
    CommandDispatcher.execute(player, rawText)
end

events.serverPost = function(player, value1, value2)
    if not gate(player, Permissions.PostMessageRank, "serverPost") then return end
    apEvents.RemoteEvent:FireAllClients("serverPost", value1, value2)
end

events.globalPost = function(player, value1, value2)
    local minRank = Permissions.GlobalPostRank or Permissions.PostMessageRank
    if not gate(player, minRank, "globalPost") then return end
    CrossServer.publish("uxr.GlobalPost.v2", { value1 = value1, value2 = value2 })
end

events.voteStart = function(player, duration, _isStart, isGlobal, q, opts, voteId)
    local vote = Commands.vote
    if not vote or not gate(player, vote.Permission, "voteStart") then return end
    if not (duration and voteId) then return end

    if isGlobal then
        CrossServer.publish("uxr.voteStart.v2", {
            duration = duration, isGlobal = isGlobal,
            q = q, opts = opts, voteId = voteId,
        })
        return
    end

    PlayerDataManager:StartVote(voteId, opts)
    apEvents.RemoteEvent:FireAllClients("voteStart", duration, false, false, q, opts, voteId)
    task.spawn(function()
        task.wait(tonumber(duration) * 1.25)
        apEvents.RemoteEvent:FireAllClients("voteEnd", voteId, PlayerDataManager:GiveVoteInfo(voteId))
        task.wait(10)
        PlayerDataManager:RemoveVote(voteId)
    end)
end

events.voteCast = function(player, voteId, optionIndex, isGlobal)
    if not voteId or not optionIndex then return end
    if not PlayerDataManager:GiveVoteInfo(voteId) then return end
    if isGlobal then
        CrossServer.publish("uxr.voteCast.v2", {
            voteId = voteId, optionIndex = optionIndex, voter = player.Name,
        })
    end
    PlayerDataManager:AddVoter(voteId, optionIndex, player.Name)
    apEvents.RemoteEvent:FireAllClients("voteStatus", PlayerDataManager:GiveVoteInfo(voteId), voteId)
end

events.chatMessage = function(player, value1, value2, value3, value4, value5, value6)
    local meta = Commands.chatmessage
    if not (meta and gate(player, meta.Permission, "chatMessage")) then return end
    apEvents.RemoteEvent:FireAllClients("systemMessage", value1, value2, value3, value4, value5, value6)
end

events.globalMessage = function(player, text)
    local meta = Commands.globalservermessage
    if not (meta and gate(player, meta.Permission, "globalMessage")) then return end
    CrossServer.publish("uxr.announcement.v2", { user = player.Name, msg = text })
end

events.privateMessage = function(player, text, targetName)
    local meta = Commands.privatemessage
    if not (meta and gate(player, meta.Permission, "privateMessage")) then return end
    local target = UtilModule.GetPlayer(player, targetName)
    if target and typeof(target) == "Instance" then
        apEvents.RemoteEvent:FireClient(target, "privateMessageReceive", text, player.Name)
    end
end

events.serverMessage = function(player, text)
    local meta = Commands.servermessage
    if not (meta and gate(player, meta.Permission, "serverMessage")) then return end
    apEvents.RemoteEvent:FireAllClients("serverMessageBroadcast", text, player.Name)
end

events.removeTool = function(player, targetName, toolName)
    local meta = Commands.clearinventory
    if not (meta and gate(player, meta.Permission, "removeTool")) then return end
    local target = UtilModule.GetPlayer(player, targetName)
    if not (target and typeof(target) == "Instance") then return end
    local function killByName(parent)
        for _, t in ipairs(parent:GetChildren()) do
            if t:IsA("Tool") and t.Name == toolName then t:Destroy() end
        end
    end
    if target.Backpack  then killByName(target.Backpack)  end
    if target.Character then killByName(target.Character) end
    PlayerDataManager:AddLog(player, "removetool", target.Name, toolName)
end

events.removeHat = function(player, targetName, accessoryName)
    local meta = Commands.clearhats
    if not (meta and gate(player, meta.Permission, "removeHat")) then return end
    local target = UtilModule.GetPlayer(player, targetName)
    if not (target and typeof(target) == "Instance") then return end
    if not target.Character then return end
    for _, a in ipairs(target.Character:GetChildren()) do
        if a:IsA("Accessory") and a.Name == accessoryName then a:Destroy() end
    end
    PlayerDataManager:AddLog(player, "removehat", target.Name, accessoryName)
end

local DATA_VALUE_TYPES = {
    IntValue = "int", NumberValue = "number",
    BoolValue = "bool", StringValue = "string",
}

local function isDataNode(inst)
    return inst:IsA("ValueBase") or inst:IsA("Folder") or inst:IsA("Configuration")
end

local function countDataChildren(inst)
    local n = 0
    for _, c in ipairs(inst:GetChildren()) do
        if isDataNode(c) then n += 1 end
    end
    return n
end

local function resolveDataPath(target, path)
    local node = target
    for _, seg in ipairs(path) do
        node = node:FindFirstChild(tostring(seg))
        if not (node and isDataNode(node)) then return nil end
    end
    return node
end

events.setData = function(player, targetName, path, newValue)
    local meta = Commands.editdata
    if not (meta and gate(player, meta.Permission, "setData")) then return end
    local target = UtilModule.GetPlayer(player, targetName)
    if not (target and typeof(target) == "Instance") then return end
    if type(path) ~= "table" or #path == 0 then return end

    local node = resolveDataPath(target, path)
    if not (node and node:IsA("ValueBase")) then return end

    local kind = DATA_VALUE_TYPES[node.ClassName]
    if kind == "int" then
        local n = tonumber(newValue); if not n then return end
        node.Value = math.floor(n)
    elseif kind == "number" then
        local n = tonumber(newValue); if not n then return end
        node.Value = n
    elseif kind == "bool" then
        local s = tostring(newValue):lower()
        node.Value = (s == "true" or s == "1" or s == "yes" or s == "on")
    elseif kind == "string" then
        node.Value = tostring(newValue)
    else
        return
    end
    PlayerDataManager:AddLog(player, "editdata", target.Name,
        table.concat(path, ".").."="..tostring(node.Value))
end

events.setSkybox = function(player, name)
    local meta = Commands.skybox
    if not (meta and gate(player, meta.Permission, "setSkybox")) then return end
    local folder = uxrSS:FindFirstChild("Skybox")
    local sky = folder and folder:FindFirstChild(tostring(name))
    if not (sky and sky:IsA("Sky")) then return end
    for _, existing in ipairs(game:GetService("Lighting"):GetChildren()) do
        if existing:IsA("Sky") then existing:Destroy() end
    end
    sky:Clone().Parent = game:GetService("Lighting")
    PlayerDataManager:AddLog(player, "skybox", "", name)
end

events.punish = function(player, payload)
    if type(payload) ~= "table" then return end
    local kind = payload.kind
    local meta = Commands[kind]
    if not meta then return end
    if not gate(player, meta.Permission, "punish."..kind) then return end

    local targetName = tostring(payload.targetName or "")
    if targetName == "" then return end

    local reason   = tostring(payload.reason or "No reason provided")
    local modNote  = tostring(payload.modNote or "")
    local privateReason = (modNote ~= "" and modNote or ("Issued by "..player.Name)).." | "..reason

    if kind == "ban" or kind == "tempban" then
        local target = UtilModule.GetPlayer(player, targetName)
        local userId
        if target and typeof(target) == "Instance" then
            userId = target.UserId
        else
            local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(targetName) end)
            if ok and id then userId = id end
        end
        if not userId then
            pingClient(player, "ban: couldn't resolve '"..targetName.."'")
            return
        end

        pcall(function() UtilModule:LoadPermRank(userId) end)
        local actAllowed, denyReason = UtilModule:CanActOn(target or userId, "Bannable")
        if not actAllowed then
            pingClient(player, denyReason or "target is ban-immune")
            return
        end

        local duration = -1
        if kind == "tempban" then
            duration = tonumber(payload.duration) or 0
            if duration <= 0 then
                pingClient(player, "tempban needs a positive duration")
                return
            end
        end

        local ok, err = pcall(function()
            Players:BanAsync({
                UserIds            = { userId },
                ApplyToUniverse    = payload.applyToUniverse ~= false,
                Duration           = duration,
                DisplayReason      = reason,
                PrivateReason      = privateReason,
                ExcludeAltAccounts = payload.excludeAlts ~= false,
            })
        end)
        if ok then
            apEvents.RemoteEvent:FireClient(player, "notify",
                kind == "ban" and "Banned successfully." or ("Banned for "..duration.."s."),
                3, 14694516293, 6026984224, "#03fc52")
            PlayerDataManager:AddLog(player, kind, targetName, reason)
            WebhookService:SendWebhook(player.UserId, player.Name, kind, targetName)
        else
            pingClient(player, "Ban failed: "..tostring(err))
        end
        return
    end

    if kind == "mute" or kind == "tempmute" then
        local target = UtilModule.GetPlayer(player, targetName)
        if not (target and typeof(target) == "Instance") then
            pingClient(player, "mute: target not in server")
            return
        end
        local actAllowed, denyReason = UtilModule:CanActOn(target, "Mutable")
        if not actAllowed then
            pingClient(player, denyReason or "target is mute-immune")
            return
        end
        local duration = 0
        if kind == "tempmute" then
            duration = tonumber(payload.duration) or 0
            if duration <= 0 then return end
        end
        PlayerDataManager:GivePunishment(target.UserId, "Mute", reason, duration, player.Name)
        apEvents.RemoteEvent:FireClient(target, "selfMute")
        PlayerDataManager:AddLog(player, kind, target.Name, reason)
    end
end

events.laserShot = function(player, targetCFrame, neckC0, firing)
    if typeof(targetCFrame) ~= "CFrame" or typeof(neckC0) ~= "CFrame" then return end
    if firing ~= nil and typeof(firing) ~= "boolean" then return end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            apEvents.RemoteEvent:FireClient(other, "laserShotReplicate",
                player, targetCFrame, neckC0, firing == true)
        end
    end
end

events.fpsReport = function(player, requester, fps)
    if typeof(requester) ~= "Instance" or not requester:IsA("Player") then return end
    fps = tonumber(fps); if not fps then return end
    fps = math.clamp(math.floor(fps + 0.5), 0, 1000)
    apEvents.RemoteEvent:FireClient(requester, "notify",
        ("%s FPS: %d"):format(player.Name, fps), 3, 0, 0, "#7CFC00")
end

events.adminChat = function(player, text)
    if not gate(player, Permissions.PostMessageRank, "adminChat") then return end
    text = tostring(text or "")
    if text == "" then return end
    if #text > 200 then text = text:sub(1, 200) end
    text = text:gsub("[<>]", "")
    local rank = UtilModule:GetRank(player)
    local payload = {
        fromUserId  = player.UserId, fromName = player.Name, fromDisplay = player.DisplayName,
        rankName    = rank.Name, rankColor = rank.Color, rankLevel = rank.Level,
        serverId    = game.JobId, text = text, time = os.time(),
    }
    apEvents.RemoteEvent:FireAllClients("adminChat", payload)
    CrossServer.publish("uxr.AdminChat.v2", payload)
end

local invokes = {}
ApiHandlers.invokes = invokes

invokes.getLogs = function(player)
    if not allows(player, Permissions.LogsViewRank) then return end
    return PlayerDataManager:GiveLogs()
end

invokes.getPunishments = function(player)
    if not allows(player, Permissions.PunishViewRank) then return end
    return PlayerDataManager.GetPunishmentData()
end

invokes.getMyRank = function(player)
    local rank = UtilModule:GetRank(player)
    return {
        Name = rank.Name, DisplayName = rank.DisplayName or rank.Name,
        Level = rank.Level, Color = rank.Color,
    }
end

invokes.getAnalytics = function(player)
    if not allows(player, Permissions.LogsViewRank or "Mod") then return {} end
    return AnalyticsService:Snapshot()
end

invokes.getHomeState = function(player)
    if not allows(player, Permissions.NavSeeRank or "NonAdmin") then return {} end
    local sd = PlayerDataManager:GiveServerData(PlayerDataManager) or {}
    local jailedCount = 0
    for _, p in ipairs(Players:GetPlayers()) do
        local ld = PlayerDataManager:GiveLocalPlayerData(p)
        if ld and (ld.LocalPlayerJailed or ld.GlobalPlayerJailed) then
            jailedCount += 1
        end
    end
    return {
        jailed       = jailedCount,
        lockdown     = sd.Lockdown    and true or false,
        locked       = sd.Locked      and true or false,
        pvp          = sd.PVP         and true or false,
        serverClosed = sd.ServerClosed and true or false,
        version      = "v5.0",
    }
end

invokes.getInventory = function(player, targetName)
    if not allows(player, Permissions.PunishViewRank or "Mod") then return { error = "forbidden" } end
    local target = UtilModule.GetPlayer(player, targetName)
    if not (target and typeof(target) == "Instance") then
        return { error = "target must be in-server" }
    end
    local backpack, equipped, hats = {}, {}, {}
    if target.Backpack then
        for _, t in ipairs(target.Backpack:GetChildren()) do
            if t:IsA("Tool") then
                table.insert(backpack, { name = t.Name, className = t.ClassName })
            end
        end
    end
    if target.Character then
        for _, child in ipairs(target.Character:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(equipped, { name = child.Name, className = child.ClassName })
            elseif child:IsA("Accessory") then
                local typ = (child.AccessoryType and child.AccessoryType.Name) or "?"
                table.insert(hats, { name = child.Name, accessoryType = typ })
            end
        end
    end
    return { target = target.Name, backpack = backpack, equipped = equipped, hats = hats }
end

invokes.getDataTree = function(player, targetName, path)
    local meta = Commands.editdata
    if not (meta and allows(player, meta.Permission)) then return { error = "forbidden" } end
    local target = UtilModule.GetPlayer(player, targetName)
    if not (target and typeof(target) == "Instance") then return { error = "target offline" } end
    path = type(path) == "table" and path or {}

    local node = resolveDataPath(target, path)
    if not node then return { error = "path no longer exists" } end

    local children = {}
    for _, c in ipairs(node:GetChildren()) do
        if isDataNode(c) then
            local isVB = c:IsA("ValueBase")
            table.insert(children, {
                name         = c.Name,
                className    = c.ClassName,
                isValue      = isVB,
                editableType = DATA_VALUE_TYPES[c.ClassName],
                valueText    = isVB and tostring(c.Value) or nil,
                childCount   = countDataChildren(c),
            })
        end
    end
    return {
        target   = target.Name,
        path     = path,
        nodeName = (#path == 0) and target.Name or node.Name,
        children = children,
    }
end

invokes.getSkyboxes = function(player)
    if not allows(player, "Mod") then return { skies = {} } end
    local folder = uxrSS:FindFirstChild("Skybox")
    if not folder then return { skies = {} } end
    local names = {}
    for _, s in ipairs(folder:GetChildren()) do
        if s:IsA("Sky") then table.insert(names, s.Name) end
    end
    table.sort(names)
    return { skies = names }
end

invokes.getProfile = function(player, targetName)
    if not allows(player, Permissions.PunishViewRank or "Mod") then return { error = "forbidden" } end
    if type(targetName) ~= "string" or targetName == "" then
        return { error = "missing target" }
    end

    local target = UtilModule.GetPlayer(player, targetName)
    local resolvedName, displayName, userId, accountAge
    if target and typeof(target) == "Instance" then
        userId, resolvedName, displayName, accountAge =
            target.UserId, target.Name, target.DisplayName, target.AccountAge
    else
        local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(targetName) end)
        if ok and id then
            userId, resolvedName, displayName = id, targetName, targetName
        end
    end
    if not userId then return { error = "not found: "..targetName } end

    local rankSource = target
    if not (rankSource and typeof(rankSource) == "Instance") then
        rankSource = { UserId = userId, Name = resolvedName or targetName }
    end
    local rank = UtilModule:GetRank(rankSource)

    local pd       = PlayerDataManager:LoadPunishmentData(userId)
    local warnings = PlayerDataManager:GetWarnings(userId)
    local notes    = PlayerDataManager:GetNotes(userId)

    local banHistory = {}
    local ok, pages = pcall(function() return Players:GetBanHistoryAsync(userId) end)
    if ok and pages then
        local ok2, items = pcall(function() return pages:GetCurrentPage() end)
        if ok2 and items then
            for i, item in ipairs(items) do
                if i > 10 then break end
                table.insert(banHistory, {
                    startTime = item.StartTime, duration = item.Duration,
                    reason    = item.DisplayReason, note = item.PrivateReason,
                    active    = item.Active, moderator = item.ModeratorName,
                })
            end
        end
    end

    return {
        userId       = userId,
        name         = resolvedName or targetName,
        displayName  = displayName or resolvedName or targetName,
        inServer     = target and typeof(target) == "Instance",
        accountAge   = accountAge,
        rank         = { name = rank.Name, displayName = rank.DisplayName or rank.Name, level = rank.Level, color = rank.Color },
        warnings     = warnings,
        warningCount = #warnings,
        notes        = notes,
        noteCount    = #notes,
        activeMute   = pd.PermaMute or (pd.MuteTime and pd.MuteTime > os.time()),
        muteReason   = pd.MuteReason,
        muter        = pd.Muter,
        banHistory   = banHistory,
    }
end

local RATE_WINDOW = 1
local RATE_MAX    = 10
local rates = {}

local function tooManyRequests(player)
    local now = tick()
    local d = rates[player.UserId]
    if not d then
        d = { count = 0, windowStart = now }
        rates[player.UserId] = d
    end
    if now - d.windowStart >= RATE_WINDOW then
        d.count = 0; d.windowStart = now
    end
    d.count += 1
    return d.count > RATE_MAX
end

Players.PlayerRemoving:Connect(function(p) rates[p.UserId] = nil end)

function ApiHandlers.init()
    local STREAMING_RTYPES = { laserShot = true }

    apEvents.RemoteEvent.OnServerEvent:Connect(function(player, rtype, ...)
        if not STREAMING_RTYPES[rtype] and tooManyRequests(player) then
            UtilModule:Log("Warn", "rate limit: "..player.Name)
            return
        end
        local h = events[rtype]
        if h then h(player, ...) end
    end)

    apEvents.RemoteFunction.OnServerInvoke = function(player, rtype, ...)
        if tooManyRequests(player) then
            UtilModule:Log("Warn", "rate limit: "..player.Name)
            return nil
        end
        local h = invokes[rtype]
        if h then return h(player, ...) end
    end
end

return ApiHandlers
