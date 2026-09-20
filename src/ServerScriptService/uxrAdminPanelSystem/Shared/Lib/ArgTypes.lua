--!nocheck

local ArgTypes = {}

local function isBlank(t) return t == nil or t == "" end

ArgTypes.Number = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a number"):format(spec.name)
        end
        local n = tonumber(text)
        if not n then
            return nil, ("'%s': expected a number, got '%s'"):format(spec.name, tostring(text))
        end
        if spec.min and n < spec.min then n = spec.min end
        if spec.max and n > spec.max then n = spec.max end
        return n
    end,
    format = function(n) return tostring(n) end,
}

ArgTypes.AssetId = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires an asset id"):format(spec.name)
        end
        local n = tonumber(text)
        if not n or n < 1 or n ~= math.floor(n) then
            return nil, ("'%s': expected an asset id (positive integer), got '%s'"):format(spec.name, tostring(text))
        end
        return n
    end,
}

local DURATION_UNITS = {
    y = 31536000, M = 2592000, d = 86400,
    h = 3600,     m = 60,      s = 1,
}
ArgTypes.Duration = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a duration like '10s', '5m', '1h30m'"):format(spec.name)
        end
        local total, matched = 0, false
        for value, unit in tostring(text):gmatch("(%d+)([yMdhms])") do
            local factor = DURATION_UNITS[unit]
            if factor then
                total += tonumber(value) * factor
                matched = true
            end
        end
        if not matched then
            local n = tonumber(text)
            if n then return n end
            return nil, ("'%s': bad duration '%s' — use '10s', '5m', '1h30m'…"):format(spec.name, tostring(text))
        end
        return total
    end,
    format = function(seconds)
        if not seconds then return "" end
        if seconds < 60 then return seconds.."s" end
        if seconds < 3600 then return math.floor(seconds/60).."m" end
        if seconds < 86400 then return math.floor(seconds/3600).."h" end
        return math.floor(seconds/86400).."d"
    end,
}

ArgTypes.String = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a string"):format(spec.name)
        end
        local s = tostring(text)
        if spec.oneOf then
            for _, v in ipairs(spec.oneOf) do
                if v:lower() == s:lower() then return v end
            end
            return nil, ("'%s' must be one of: %s"):format(spec.name, table.concat(spec.oneOf, ", "))
        end
        return s
    end,
}

ArgTypes.Color = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a hex color"):format(spec.name)
        end
        local hex = tostring(text):gsub("^#", "")
        if #hex == 3 then
            hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
        end
        if #hex == 6 and hex:match("^%x+$") then
            local ok, c3 = pcall(Color3.fromHex, hex)
            if ok then return c3 end
        end
        return nil, ("'%s': expected hex color like #ff0000"):format(spec.name)
    end,
}

local TRUE_TOKENS  = { ["true"]=true, ["yes"]=true, ["on"]=true,  ["1"]=true, ["t"]=true, ["y"]=true }
local FALSE_TOKENS = { ["false"]=true, ["no"]=true, ["off"]=true, ["0"]=true, ["f"]=true, ["n"]=true }
ArgTypes.Bool = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires true/false"):format(spec.name)
        end
        local low = tostring(text):lower()
        if TRUE_TOKENS[low] then return true end
        if FALSE_TOKENS[low] then return false end
        return nil, ("'%s': expected true/false, got '%s'"):format(spec.name, tostring(text))
    end,
}

ArgTypes.Rank = {
    parse = function(text, spec, ctx)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a rank name"):format(spec.name)
        end
        local low = tostring(text):lower()
        for _, r in ipairs(ctx.Permissions.Ranks) do
            if r.Name:lower() == low then return r.Name end
        end
        local names = {}
        for _, r in ipairs(ctx.Permissions.Ranks) do table.insert(names, r.Name) end
        return nil, ("'%s': unknown rank '%s'. Valid: %s"):format(spec.name, tostring(text), table.concat(names, ", "))
    end,
}

local materialNames
local function buildMaterialNames()
    if materialNames then return materialNames end
    materialNames = {}
    for _, item in ipairs(Enum.Material:GetEnumItems()) do
        materialNames[item.Name:lower()] = item
    end
    return materialNames
end
ArgTypes.Material = {
    parse = function(text, spec)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a material name"):format(spec.name)
        end
        local item = buildMaterialNames()[tostring(text):lower()]
        if item then return item end
        return nil, ("'%s': unknown material '%s'"):format(spec.name, tostring(text))
    end,
}

ArgTypes.Team = {
    parse = function(text, spec, ctx)
        if isBlank(text) then
            if spec.default ~= nil then return spec.default end
            if spec.optional then return nil end
            return nil, ("'%s' requires a team name"):format(spec.name)
        end
        local low = tostring(text):lower()
        for _, t in ipairs(game:GetService("Teams"):GetTeams()) do
            if t.Name:lower() == low then return t end
        end
        return nil, ("'%s': team '%s' not found"):format(spec.name, tostring(text))
    end,
}

ArgTypes.Players = {
    isTarget = true,
    parse = function() error("Players type must be resolved via TargetResolver") end,
}

return ArgTypes
