--!nocheck

local CommandParser = {}

local MODIFIER_FLAGS = {
    silent = true,
    force  = true,
}

local function tokenize(text)
    local tokens = {}
    local i, n = 1, #text
    while i <= n do
        local c = text:sub(i, i)
        if c == " " or c == "\t" then
            i += 1
        elseif c == '"' then
            local buf = {}
            i += 1
            while i <= n do
                local ch = text:sub(i, i)
                if ch == '\\' and i + 1 <= n then
                    local nx = text:sub(i + 1, i + 1)
                    if nx == '"' or nx == '\\' then
                        table.insert(buf, nx); i += 2
                    else
                        table.insert(buf, ch); i += 1
                    end
                elseif ch == '"' then
                    i += 1; break
                else
                    table.insert(buf, ch); i += 1
                end
            end
            table.insert(tokens, table.concat(buf))
        else
            local j = i
            while j <= n and text:sub(j, j) ~= " " and text:sub(j, j) ~= "\t" do
                j += 1
            end
            table.insert(tokens, text:sub(i, j - 1))
            i = j
        end
    end
    return tokens
end

local function parseStatement(tokens)
    if #tokens == 0 then return nil, "empty command" end

    local modifiers = {}
    local idx = 1

    while idx <= #tokens do
        local tok = tokens[idx]
        local low = tok:lower()

        if MODIFIER_FLAGS[low] then
            modifiers[low] = true
            idx += 1
        else
            local n = low:match("^n(%d+)$")
            if n then
                modifiers.n = math.min(tonumber(n), 100)
                idx += 1
            else
                break
            end
        end
    end

    if idx > #tokens then return nil, "modifier(s) but no command" end

    local commandName = tokens[idx]:lower()
    local args = {}
    for j = idx + 1, #tokens do table.insert(args, tokens[j]) end

    return {
        modifiers = modifiers,
        command   = commandName,
        args      = args,
    }
end

function CommandParser.parse(rawText)
    rawText = tostring(rawText or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if rawText == "" then return nil, "empty input" end

    local statements = {}
    for chunk in (rawText .. "&&"):gmatch("(.-)%&%&") do
        chunk = chunk:gsub("^%s+", ""):gsub("%s+$", "")
        if chunk ~= "" then
            local tokens = tokenize(chunk)
            local stmt, err = parseStatement(tokens)
            if not stmt then return nil, err end
            table.insert(statements, stmt)
        end
    end

    if #statements == 0 then return nil, "no command in input" end
    return { statements = statements }, nil
end

CommandParser._tokenize = tokenize

return CommandParser
