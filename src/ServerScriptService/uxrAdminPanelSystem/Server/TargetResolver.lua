--!nocheck

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local uxrRS = ReplicatedStorage:WaitForChild("uxrAdminPanelSystem", 10)
local Settings    = require(uxrRS.Config.Settings)
local UtilModule  = require(uxrRS.Lib.Util)

local TargetResolver = {}


local function allPlayers()
    return Players:GetPlayers()
end

local function others(actor)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= actor then table.insert(list, p) end
    end
    return list
end

local function randomOne()
    local pool = Players:GetPlayers()
    if #pool == 0 then return {} end
    return { pool[math.random(1, #pool)] }
end

local function friendsOf(actor)
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= actor then
            local ok, isFriend = pcall(function() return actor:IsFriendsWith(p.UserId) end)
            if ok and isFriend then table.insert(list, p) end
        end
    end
    return list
end

local function distanceFromActor(actor, target)
    local ac = actor.Character and actor.Character:FindFirstChild("HumanoidRootPart")
    local tc = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not (ac and tc) then return math.huge end
    return (ac.Position - tc.Position).Magnitude
end

local function nearestOrFurthest(actor, want)
    local best, bestDist
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= actor then
            local d = distanceFromActor(actor, p)
            if bestDist == nil
                or (want == "nearest"  and d < bestDist)
                or (want == "furthest" and d > bestDist)
            then
                best, bestDist = p, d
            end
        end
    end
    return best and { best } or {}
end

local function teamMembers(name)
    if not name or name == "" then return {} end
    local low = name:lower()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name:lower() == low then table.insert(list, p) end
    end
    return list
end

local function rankMembers(name)
    if not name or name == "" then return {} end
    local low = name:lower()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        local rank = UtilModule:GetRank(p)
        if rank and rank.Name:lower() == low then table.insert(list, p) end
    end
    return list
end

local function byUserId(idStr)
    local id = tonumber(idStr)
    if not id then return {} end
    local p = Players:GetPlayerByUserId(id)
    return p and { p } or {}
end

local function byPartialName(text)
    if not text or text == "" then return {} end
    local low = text:lower()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(low, 1, true)
           or p.DisplayName:lower():find(low, 1, true)
        then
            table.insert(list, p)
        end
    end
    return list
end

local function resolveSingleToken(token, actor)
    if not token or token == "" then return {} end
    token = token:lower()

    if token == "me"   or token == (Settings.Localization.Self  or ""):lower() then return { actor } end
    if token == "all"  or token == (Settings.Localization.All   or ""):lower() then return allPlayers() end
    if token == "others" or token == "other"
        or token == (Settings.Localization.Other or ""):lower() then return others(actor) end
    if token == "random"   then return randomOne() end
    if token == "friends"  then return friendsOf(actor) end
    if token == "nearest"  then return nearestOrFurthest(actor, "nearest")  end
    if token == "furthest" then return nearestOrFurthest(actor, "furthest") end

    local teamName = token:match("^team%-(.+)$")
    if teamName then return teamMembers(teamName) end

    local rankName = token:match("^rank%-(.+)$")
    if rankName then return rankMembers(rankName) end

    local uid = token:match("^userid:(%d+)$")
    if uid then return byUserId(uid) end

    return byPartialName(token)
end

function TargetResolver.resolve(actor, expr)
    if not actor or typeof(actor) ~= "Instance" then
        return nil, "internal: actor missing"
    end
    expr = tostring(expr or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if expr == "" then expr = "me" end

    local includeSet, includeOrder = {}, {}
    local excludeSet = {}
    local seenAny = false

    for raw in expr:gmatch("[^,]+") do
        raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
        if raw ~= "" then
            seenAny = true
            local exclude = raw:sub(1, 1) == "-"
            local token   = exclude and raw:sub(2) or raw
            local players = resolveSingleToken(token, actor)
            local bucket  = exclude and excludeSet or includeSet
            for _, p in ipairs(players) do
                if not bucket[p.UserId] then
                    bucket[p.UserId] = p
                    if not exclude then table.insert(includeOrder, p) end
                end
            end
        end
    end

    if not seenAny then return nil, "no target specified" end

    local result = {}
    for _, p in ipairs(includeOrder) do
        if not excludeSet[p.UserId] then table.insert(result, p) end
    end

    if #result == 0 then
        return nil, ("no target matched '%s'"):format(expr)
    end
    return result, nil
end

function TargetResolver.resolveSingle(actor, expr)
    local list, err = TargetResolver.resolve(actor, expr)
    if not list then return nil, err end
    if #list > 1 then
        return nil, ("'%s' matches %d players — pick one"):format(expr, #list)
    end
    return list[1], nil
end

return TargetResolver
