--!nocheck

local S = require(script.Parent._shared)
local apEvents = S.apEvents
local Settings = S.Settings
local UtilModule = S.UtilModule

local function send(actor, text)
    apEvents.RemoteEvent:FireClient(actor, "systemMessage", text)
end

local function formatUsage(cmd)
    local parts = { (Settings.Prefix or "") .. cmd.Name }
    for _, a in ipairs(cmd.Args or {}) do
        if a.default ~= nil then
            table.insert(parts, ("[%s=%s]"):format(a.name, tostring(a.default)))
        elseif a.optional then
            table.insert(parts, ("[%s]"):format(a.name))
        else
            table.insert(parts, ("<%s:%s>"):format(a.name, a.type))
        end
    end
    return table.concat(parts, " ")
end

local function formatArgDetails(cmd)
    local lines = {}
    for _, a in ipairs(cmd.Args or {}) do
        local extras = {}
        if a.default ~= nil then table.insert(extras, "default=" .. tostring(a.default)) end
        if a.min       then table.insert(extras, "min=" .. a.min) end
        if a.max       then table.insert(extras, "max=" .. a.max) end
        if a.oneOf     then table.insert(extras, "one of: " .. table.concat(a.oneOf, "/")) end
        if a.joinRest  then table.insert(extras, "rest-of-line") end
        if a.optional  then table.insert(extras, "optional") end
        local suffix = #extras > 0 and "  (" .. table.concat(extras, ", ") .. ")" or ""
        table.insert(lines, ("    %s: %s%s"):format(a.name, a.type, suffix))
    end
    return table.concat(lines, "\n")
end

local function listAllCategories(actor, Commands)
    local byCategory = {}
    for name, cmd in pairs(Commands) do
        if name ~= "Name" and name ~= "CommandText" then
            if UtilModule:CanRunCommand(actor, cmd) then
                local cat = cmd.Category or "Misc"
                byCategory[cat] = byCategory[cat] or {}
                table.insert(byCategory[cat], name)
            end
        end
    end
    local cats = {}
    for c in pairs(byCategory) do table.insert(cats, c) end
    table.sort(cats)
    local lines = { "[Help] Type `" .. (Settings.Prefix or "") .. "help <cmd>` for details." }
    for _, c in ipairs(cats) do
        table.sort(byCategory[c])
        table.insert(lines, ("\n%s: %s"):format(c, table.concat(byCategory[c], ", ")))
    end
    send(actor, table.concat(lines, ""))
end

local function helpForOne(actor, cmd)
    local lines = {
        "[Help] " .. formatUsage(cmd),
        "  " .. (cmd.Description or "(no description)"),
        "  Permission: " .. (cmd.Permission or "?"),
    }
    if cmd.Aliases and #cmd.Aliases > 0 then
        table.insert(lines, "  Aliases: " .. table.concat(cmd.Aliases, ", "))
    end
    if cmd.Args and #cmd.Args > 0 then
        table.insert(lines, "  Args:")
        table.insert(lines, formatArgDetails(cmd))
    end
    send(actor, table.concat(lines, "\n"))
end

local function fuzzyFind(actor, query, Commands)
    query = query:lower()
    local hits = {}
    for name, cmd in pairs(Commands) do
        if UtilModule:CanRunCommand(actor, cmd) then
            local hay = (name .. " " .. (cmd.Description or "") .. " " .. (cmd.Category or "")):lower()
            for _, a in ipairs(cmd.Aliases or {}) do hay = hay .. " " .. a:lower() end
            if hay:find(query, 1, true) then table.insert(hits, name) end
        end
    end
    table.sort(hits)
    if #hits == 0 then
        send(actor, "[Help] no command matches '" .. query .. "'")
    elseif #hits == 1 then
        helpForOne(actor, Commands[hits[1]])
    else
        send(actor, ("[Help] %d matches for '%s': %s"):format(#hits, query, table.concat(hits, ", ")))
    end
end

return {
    help = function(ctx, args)
        local Commands = require(game:GetService("ReplicatedStorage").uxrAdminPanelSystem.Config.Commands)
        if not args.query or args.query == "" then
            listAllCategories(ctx.actor, Commands)
            return
        end
        local key = args.query:lower()
        local cmd = Commands[key]
        if cmd then helpForOne(ctx.actor, cmd) return end
        for name, c in pairs(Commands) do
            for _, a in ipairs(c.Aliases or {}) do
                if a:lower() == key then helpForOne(ctx.actor, c) return end
            end
        end
        fuzzyFind(ctx.actor, args.query, Commands)
    end,
}
