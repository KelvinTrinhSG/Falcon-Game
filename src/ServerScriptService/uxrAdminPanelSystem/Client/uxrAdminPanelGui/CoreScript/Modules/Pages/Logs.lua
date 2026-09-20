--!nocheck

local Logs = {}

local function makeParser(Players)
    return function(entry)
        local userId    = entry.userId
        local adminName = entry.adminName or ("user" .. tostring(userId))
        if userId then
            local p = Players:GetPlayerByUserId(tonumber(userId) or -1)
            if p then adminName = p.Name end
        end
        return {
            id          = entry.id,
            userId      = userId,
            adminName   = adminName,
            commandName = entry.command or "",
            target      = entry.target or "",
            description = entry.description or "",
            dateString  = entry.dateString or "",
            time        = entry.time,
        }
    end
end

function Logs.init(ctx)
    local Players        = ctx.Players
    local LocalPlayer    = ctx.LocalPlayer
    local UtilModule     = ctx.UtilModule
    local Permissions    = ctx.Permissions
    local RemoteFunction = ctx.RemoteFunction
    local Templates      = ctx.Templates

    local page       = ctx.pages.Logs
    local logsListSF = page.LogsListFrame:FindFirstChildWhichIsA("ScrollingFrame")
    local parseLogEntry = makeParser(Players)

    local SEVERITY_COLOR = {
        warn     = Color3.fromRGB(241, 196,  15),
        ban      = Color3.fromRGB(239,  35,  60),
        tempban  = Color3.fromRGB(239,  35,  60),
        kick     = Color3.fromRGB(239,  35,  60),
        mute     = Color3.fromRGB(239, 137,  35),
        tempmute = Color3.fromRGB(239, 137,  35),
    }

    local function fillLogRow(row, parsed)
        Templates.safeText(row, "DescriptionTextLabel", parsed.description or "")
        local typeFrame = row:FindFirstChild("TypeFrame")
        if typeFrame then
            local typeLbl = typeFrame:FindFirstChild("TextLabel")
            Templates.safeText(typeFrame, "TextLabel",
                parsed.commandName ~= "" and parsed.commandName or "log")
            if typeLbl then
                typeLbl.TextColor3 = SEVERITY_COLOR[parsed.commandName] or Color3.fromRGB(255, 255, 255)
            end
        end
        local nameFrame = row:FindFirstChild("NameFrame")
        if nameFrame then
            Templates.safeText(nameFrame, "DisplayNameTextLabel", "@" .. parsed.adminName)
            Templates.safeText(nameFrame, "TimeTextLabel", parsed.dateString or "")
        end
    end

    local function refreshLogs(filter)
        Templates.clearList(logsListSF)
        if not UtilModule:HasRank(LocalPlayer, Permissions.LogsViewRank or "Mod") then return end
        local ok, logs = pcall(function() return RemoteFunction:InvokeServer("getLogs") end)
        if not ok or type(logs) ~= "table" then warn("[uxrAPS v5] getLogs failed:", logs); return end
        filter = (filter or ""):lower()
        local count = 0
        for _, entry in pairs(logs) do
            local parsed = parseLogEntry(entry)
            local hay = (parsed.adminName .. " " .. parsed.commandName .. " " .. parsed.description):lower()
            if filter == "" or hay:find(filter, 1, true) then
                local row = Templates.cloneTemplate(logsListSF)
                if not row then break end
                fillLogRow(row, parsed)
                count += 1
            end
        end
        if count == 0 then
            local row = Templates.cloneTemplate(logsListSF)
            if row then
                Templates.safeText(row, "DescriptionTextLabel",
                    filter == "" and "No log entries yet" or "No matches")
                local tf = row:FindFirstChild("TypeFrame")
                if tf then Templates.safeText(tf, "TextLabel", "—") end
                local nf = row:FindFirstChild("NameFrame")
                if nf then
                    Templates.safeText(nf, "DisplayNameTextLabel", "@system")
                    Templates.safeText(nf, "TimeTextLabel", "")
                end
            end
        end
    end

    page.SearchFrame.SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshLogs(page.SearchFrame.SearchTextBox.Text)
    end)

    ctx.refreshHooks.Logs = function()
        refreshLogs(page.SearchFrame.SearchTextBox.Text)
    end

    Logs.parseLogEntry = parseLogEntry
    ctx.parseLogEntry  = parseLogEntry
end

return Logs
