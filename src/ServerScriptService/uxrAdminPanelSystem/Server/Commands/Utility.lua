--!nocheck

local Players = game:GetService("Players")

local S = require(script.Parent._shared)
local uxrWS = S.uxrWS

local SERVER_START = os.time()

local function ensureSoundsFolder()
    local f = uxrWS:FindFirstChild("Sounds")
    if not f then
        f = Instance.new("Folder"); f.Name = "Sounds"; f.Parent = uxrWS
    end
    return f
end

local function resolveInstance(path)
    if not path or path == "" then return game end
    local parts = string.split(path, ".")
    local cur = game
    for i, name in ipairs(parts) do
        if name == "" then continue end
        local child = cur:FindFirstChild(name)
        if not child and cur == game and i == 1 then
            local ok, svc = pcall(game.GetService, game, name)
            if ok then child = svc end
        end
        if not child then
            return nil, ("not found: %s under %s"):format(name, cur:GetFullName())
        end
        cur = child
    end
    return cur
end

local function parseValue(currentValue, raw)
    local t = typeof(currentValue)
    if t == "string" then
        return raw
    elseif t == "number" then
        local n = tonumber(raw)
        if not n then return nil, ("expected number, got: %s"):format(raw) end
        return n
    elseif t == "boolean" then
        local lower = raw:lower()
        if lower == "true"  or lower == "1" or lower == "yes" or lower == "on"  then return true  end
        if lower == "false" or lower == "0" or lower == "no"  or lower == "off" then return false end
        return nil, ("expected true/false, got: %s"):format(raw)
    elseif t == "Color3" then
        if raw:sub(1, 1) == "#" then
            local hex = raw:sub(2)
            if #hex ~= 6 then return nil, "hex must be #RRGGBB" end
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if not (r and g and b) then return nil, "invalid hex digits" end
            return Color3.fromRGB(r, g, b)
        end
        local r, g, b = raw:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
        if not (r and g and b) then return nil, "Color3 expects 'r,g,b' (0-255) or '#RRGGBB'" end
        return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    elseif t == "Vector3" then
        local x, y, z = raw:match("^(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)$")
        if not (x and y and z) then return nil, "Vector3 expects 'x,y,z'" end
        return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
    elseif t == "Vector2" then
        local x, y = raw:match("^(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)$")
        if not (x and y) then return nil, "Vector2 expects 'x,y'" end
        return Vector2.new(tonumber(x), tonumber(y))
    elseif t == "UDim" then
        local s, o = raw:match("^(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)$")
        if not (s and o) then return nil, "UDim expects 'scale,offset'" end
        return UDim.new(tonumber(s), tonumber(o))
    elseif t == "UDim2" then
        local xs, xo, ys, yo = raw:match("^(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)$")
        if not (xs and xo and ys and yo) then return nil, "UDim2 expects 'xS,xO,yS,yO'" end
        return UDim2.new(tonumber(xs), tonumber(xo), tonumber(ys), tonumber(yo))
    elseif t == "BrickColor" then
        local ok, bc = pcall(BrickColor.new, raw)
        if not ok or not bc then return nil, ("BrickColor '%s' not found"):format(raw) end
        return bc
    elseif t == "EnumItem" then
        local short = raw:match("([^%.]+)$") or raw
        local enumType = currentValue.EnumType
        local ok, item = pcall(function() return enumType[short] end)
        if not ok or not item then
            return nil, ("Enum.%s has no item '%s'"):format(tostring(enumType), short)
        end
        return item
    elseif t == "CFrame" then
        local x, y, z = raw:match("^(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)%s*,%s*(-?%d+%.?%d*)$")
        if not (x and y and z) then return nil, "CFrame expects 'x,y,z' (position only)" end
        return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
    end
    return nil, ("unsupported type: %s"):format(t)
end

local function formatValue(v)
    local t = typeof(v)
    if     t == "Color3"    then return ("(%d, %d, %d)"):format(math.floor(v.R*255+0.5), math.floor(v.G*255+0.5), math.floor(v.B*255+0.5))
    elseif t == "Vector3"   then return ("(%.2f, %.2f, %.2f)"):format(v.X, v.Y, v.Z)
    elseif t == "Vector2"   then return ("(%.2f, %.2f)"):format(v.X, v.Y)
    elseif t == "UDim"      then return ("{%.2f, %d}"):format(v.Scale, v.Offset)
    elseif t == "UDim2"     then return ("{%.2f, %d}, {%.2f, %d}"):format(v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
    elseif t == "EnumItem"  then return ("Enum.%s.%s"):format(tostring(v.EnumType), v.Name)
    elseif t == "BrickColor"then return v.Name
    elseif t == "Instance"  then return v:GetFullName()
    elseif t == "string"    then return ("'%s'"):format(v)
    elseif t == "nil"       then return "nil" end
    return tostring(v)
end

local loops = {}
local MAX_LOOPS_PER_ACTOR = 5
local MIN_LOOP_DELAY      = 0.25
local MAX_LOOP_DELAY      = 3600

local function actorBucket(userId)
    local b = loops[userId]
    if not b then b = {}; loops[userId] = b end
    return b
end

local function cancelLoop(userId, cmdName)
    local b = loops[userId]
    if not b or not b[cmdName] then return false end
    local entry = b[cmdName]
    if entry.thread then task.cancel(entry.thread) end
    b[cmdName] = nil
    return true
end

local function cancelAll(userId)
    local b = loops[userId]; if not b then return 0 end
    local count = 0
    for cmdName in pairs(b) do
        cancelLoop(userId, cmdName); count += 1
    end
    return count
end

Players.PlayerRemoving:Connect(function(p) cancelAll(p.UserId) end)

return {
    sound = function(ctx, args)
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://"..args.asset
        s.Parent = ensureSoundsFolder()
        s:Play()
    end,
    stopsound = function(ctx, args)
        local folder = uxrWS:FindFirstChild("Sounds")
        if not folder then return end
        local id = "rbxassetid://"..args.asset
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Sound") and v.SoundId == id then v:Destroy() end
        end
    end,
    stopallsounds = function()
        local folder = uxrWS:FindFirstChild("Sounds")
        if not folder then return end
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Sound") then v:Destroy() end
        end
    end,
    pitch = function(ctx, args)
        local folder = uxrWS:FindFirstChild("Sounds")
        if not folder then ctx.notify("no active sounds", "error"); return end
        local pitch = math.clamp(tonumber(args.pitch) or 1, 0.1, 10)
        local n = 0
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Sound") then v.PlaybackSpeed = pitch; n += 1 end
        end
        ctx.notify(("pitch=%.2f applied to %d sound(s)"):format(pitch, n), "success")
    end,
    volume = function(ctx, args)
        local folder = uxrWS:FindFirstChild("Sounds")
        if not folder then ctx.notify("no active sounds", "error"); return end
        local vol = math.clamp(tonumber(args.volume) or 0.5, 0, 10)
        local n = 0
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Sound") then v.Volume = vol; n += 1 end
        end
        ctx.notify(("volume=%.2f applied to %d sound(s)"):format(vol, n), "success")
    end,
    pause = function(ctx)
        local folder = uxrWS:FindFirstChild("Sounds")
        if not folder then ctx.notify("no active sounds", "error"); return end
        local n = 0
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Sound") and v.IsPlaying then v:Pause(); n += 1 end
        end
        ctx.notify(("paused %d sound(s)"):format(n), "success")
    end,
    resume = function(ctx)
        local folder = uxrWS:FindFirstChild("Sounds")
        if not folder then ctx.notify("no active sounds", "error"); return end
        local n = 0
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Sound") then v:Resume(); n += 1 end
        end
        ctx.notify(("resumed %d sound(s)"):format(n), "success")
    end,

    whois = function(ctx, args)
        local p = args.target
        local rank = S.UtilModule:GetRank(p)
        ctx.notify(
            ("%s — userId %d, rank %s (lvl %d), account %d days, display '%s'")
                :format(p.Name, p.UserId, rank.Name, rank.Level, p.AccountAge, p.DisplayName),
            "info")
    end,
    playercount = function(ctx)
        ctx.notify(("%d / %d players in this server"):format(#Players:GetPlayers(), Players.MaxPlayers), "info")
    end,
    serverage = function(ctx)
        local up = os.time() - SERVER_START
        local d = math.floor(up / 86400); up %= 86400
        local h = math.floor(up / 3600);  up %= 3600
        local m = math.floor(up / 60);    local s = up % 60
        local parts = {}
        if d > 0 then table.insert(parts, d .. "d") end
        if h > 0 then table.insert(parts, h .. "h") end
        if m > 0 then table.insert(parts, m .. "m") end
        table.insert(parts, s .. "s")
        ctx.notify("server uptime: " .. table.concat(parts, " "), "info")
    end,
    gameid  = function(ctx) ctx.notify("GameId: " .. tostring(game.GameId), "info") end,
    jobid   = function(ctx) ctx.notify("JobId: " .. (game.JobId ~= "" and game.JobId or "(studio session)"), "info") end,
    placeid = function(ctx) ctx.notify("PlaceId: " .. tostring(game.PlaceId), "info") end,

    showfps = function(ctx, args)
        S.apEvents.RemoteEvent:FireClient(args.target, "measureFps", ctx.actor)
        ctx.notify(("measuring %s's FPS…"):format(args.target.Name), "info")
    end,

    setproperty = function(ctx, args)
        local inst, err = resolveInstance(args.path)
        if not inst then
            ctx.notify(("setProperty: %s"):format(err), "error"); return
        end
        local ok, cur = pcall(function() return inst[args.property] end)
        if not ok then
            ctx.notify(("setProperty: %s has no property '%s'"):format(inst.ClassName, args.property), "error")
            return
        end
        local val, perr = parseValue(cur, args.value)
        if val == nil then
            ctx.notify(("setProperty: %s"):format(perr), "error"); return
        end
        local setOk, setErr = pcall(function() inst[args.property] = val end)
        if not setOk then
            ctx.notify(("setProperty: %s"):format(tostring(setErr):gsub(".*: ", "")), "error")
            return
        end
        ctx.notify(("%s.%s = %s"):format(inst.Name, args.property, formatValue(val)), "success")
    end,

    loop = function(ctx, args)
        local actor = ctx.actor
        local delay = tonumber(args.delay) or 1
        delay = math.clamp(delay, MIN_LOOP_DELAY, MAX_LOOP_DELAY)

        local inner = tostring(args.command or ""):match("^%s*(.-)%s*$")
        if inner == "" then ctx.notify("loop: missing command", "error"); return end
        local cmdKey = inner:match("^(%S+)") or inner

        if cmdKey:lower() == "loop" then
            ctx.notify("loop: cannot nest loop inside loop", "error"); return
        end

        local bucket = actorBucket(actor.UserId)
        if bucket[cmdKey] then
            cancelLoop(actor.UserId, cmdKey)
        end
        local active = 0
        for _ in pairs(bucket) do active += 1 end
        if active >= MAX_LOOPS_PER_ACTOR then
            ctx.notify(("loop: max %d concurrent loops reached"):format(MAX_LOOPS_PER_ACTOR), "error")
            return
        end
        bucket[cmdKey] = { thread = nil, delay = delay, raw = inner, started = os.time(), reserving = true }

        local CommandDispatcher = require(script.Parent.Parent.CommandDispatcher)

        local thread = task.spawn(function()
            while true do
                task.wait(delay)
                if not actor.Parent then break end
                local entry = loops[actor.UserId] and loops[actor.UserId][cmdKey]
                if not entry then break end
                CommandDispatcher.execute(actor, inner)
            end
        end)
        bucket[cmdKey] = { thread = thread, delay = delay, raw = inner, started = os.time() }

        ctx.notify(("looping '%s' every %.2fs"):format(cmdKey, delay), "info")
    end,

    unloop = function(ctx, args)
        local cmdKey = tostring(args.command or ""):match("^(%S+)") or ""
        if cmdKey == "" then ctx.notify("unloop: missing command", "error"); return end
        local ok = cancelLoop(ctx.actor.UserId, cmdKey)
        if ok then
            ctx.notify(("stopped loop '%s'"):format(cmdKey), "success")
        else
            ctx.notify(("no active loop for '%s'"):format(cmdKey), "error")
        end
    end,

    unloopall = function(ctx)
        local count = cancelAll(ctx.actor.UserId)
        ctx.notify(("stopped %d loop(s)"):format(count), count > 0 and "success" or "info")
    end,

    award = function(ctx, args)
        local BadgeService = game:GetService("BadgeService")
        local badgeId = tonumber(args.badgeId)
        if not badgeId then ctx.notify("award: badgeId must be a number", "error"); return end
        local ok, err = pcall(function()
            return BadgeService:AwardBadge(args.target.UserId, badgeId)
        end)
        if not ok then ctx.notify(("award: %s"):format(tostring(err)), "error") end
    end,

    getproperty = function(ctx, args)
        local inst, err = resolveInstance(args.path)
        if not inst then
            ctx.notify(("getProperty: %s"):format(err), "error"); return
        end
        local ok, cur = pcall(function() return inst[args.property] end)
        if not ok then
            ctx.notify(("getProperty: %s has no property '%s'"):format(inst.ClassName, args.property), "error")
            return
        end
        ctx.notify(("%s.%s = %s"):format(inst.Name, args.property, formatValue(cur)), "info")
    end,
}
