--!nocheck

local Players          = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats            = game:GetService("Stats")
local RunService       = game:GetService("RunService")

local AnalyticsService = {}

local serverStartTime    = os.time()
local totalJoinedPlayers = 0
local totalCommandsRun   = 0
local commandsLastHour   = {}
local topCommandCounts   = {}
local topAdminCounts     = {}

Players.PlayerAdded:Connect(function() totalJoinedPlayers += 1 end)
totalJoinedPlayers = #Players:GetPlayers()

function AnalyticsService:RecordCommand(commandName, adminName)
    totalCommandsRun += 1
    topCommandCounts[commandName] = (topCommandCounts[commandName] or 0) + 1
    topAdminCounts[adminName]     = (topAdminCounts[adminName] or 0) + 1
    table.insert(commandsLastHour, { time = os.time(), name = commandName, admin = adminName })
    local cutoff = os.time() - 3600
    while commandsLastHour[1] and commandsLastHour[1].time < cutoff do
        table.remove(commandsLastHour, 1)
    end
end

local function fmtDuration(secs)
    if secs < 60 then return secs.."s" end
    if secs < 3600 then return ("%dm %ds"):format(secs / 60, secs % 60) end
    if secs < 86400 then return ("%dh %dm"):format(secs / 3600, (secs % 3600) / 60) end
    return ("%dd %dh"):format(secs / 86400, (secs % 86400) / 3600)
end

local function topK(map, k)
    local list = {}
    for name, count in pairs(map) do table.insert(list, { name = name, count = count }) end
    table.sort(list, function(a, b) return a.count > b.count end)
    local out = {}
    for i = 1, math.min(k or 3, #list) do table.insert(out, list[i]) end
    return out
end

local function countAccessibleParts()
    local count, scanned = 0, 0
    for _, d in ipairs(workspace:GetDescendants()) do
        scanned += 1
        if d:IsA("BasePart") then count += 1 end
        if scanned >= 5000 then break end
    end
    return count, scanned >= 5000
end

local function countScripts()
    local n = 0
    for _, s in ipairs(game:GetDescendants()) do
        if s:IsA("Script") or s:IsA("LocalScript") or s:IsA("ModuleScript") then n += 1 end
        if n > 9999 then return ">9999" end
    end
    return n
end

local function avgPing()
    local players = Players:GetPlayers()
    if #players == 0 then return 0 end
    local total = 0
    for _, p in ipairs(players) do
        total += math.floor(p:GetNetworkPing() * 1000 * 2)
    end
    return math.floor(total / #players)
end

local function premiumCount()
    local n = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p.MembershipType == Enum.MembershipType.Premium then n += 1 end
    end
    return n
end

local function avgAccountAge()
    local players = Players:GetPlayers()
    if #players == 0 then return 0 end
    local total = 0
    for _, p in ipairs(players) do total += p.AccountAge end
    return math.floor(total / #players)
end

function AnalyticsService:Snapshot()
    local uptime = os.time() - serverStartTime
    local parts, truncated = countAccessibleParts()
    local productInfo = nil
    local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
    if ok then productInfo = info end

    return {
        placeId        = game.PlaceId,
        universeId     = game.GameId,
        jobId          = game.JobId ~= "" and game.JobId or "studio",
        placeVersion   = game.PlaceVersion,
        creatorType    = productInfo and tostring(productInfo.Creator.CreatorType) or "?",
        creatorId      = productInfo and productInfo.Creator.CreatorTargetId or 0,
        creatorName    = productInfo and productInfo.Creator.Name or "?",
        placeName      = productInfo and productInfo.Name or "?",

        uptime         = uptime,
        uptimeFormatted= fmtDuration(uptime),
        privateServer  = game.PrivateServerId ~= "",

        online         = #Players:GetPlayers(),
        maxPlayers     = Players.MaxPlayers,
        totalJoined    = totalJoinedPlayers,
        premiumCount   = premiumCount(),
        avgAccountAge  = avgAccountAge(),
        avgPing        = avgPing(),

        partsCount     = parts,
        partsTruncated = truncated,
        scriptCount    = countScripts(),
        serverFps      = math.floor(workspace:GetRealPhysicsFPS() or 0),
        serverMemoryMB = math.floor(Stats:GetTotalMemoryUsageMb() or 0),
        physicsStepMs  = (function()
            local fps = workspace:GetRealPhysicsFPS() or 0
            return fps > 0 and math.floor(1000 / fps) or 0
        end)(),

        totalCommands     = totalCommandsRun,
        commandsLastHour  = #commandsLastHour,
        topCommands       = topK(topCommandCounts, 5),
        topAdmins         = topK(topAdminCounts, 5),

        snapshotAt        = os.time(),
    }
end

return AnalyticsService
