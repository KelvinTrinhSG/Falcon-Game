--!nocheck

local Analytics = {}

local function fmtNumber(n)
    if type(n) ~= "number" then return tostring(n) end
    if n >= 1e9 then return ("%.1fB"):format(n / 1e9) end
    if n >= 1e6 then return ("%.1fM"):format(n / 1e6) end
    if n >= 1e3 then return ("%.1fK"):format(n / 1e3) end
    return tostring(n)
end

function Analytics.init(ctx)
    local Players        = ctx.Players
    local LocalPlayer    = ctx.LocalPlayer
    local UtilModule     = ctx.UtilModule
    local Permissions    = ctx.Permissions
    local RemoteFunction = ctx.RemoteFunction
    local Templates      = ctx.Templates

    local page         = ctx.pages.Analytics
    local analyticsSF  = page.AnalyticsListFrame:FindFirstChildWhichIsA("ScrollingFrame")

    local function addRow(label, value, hint, category)
        local row = Templates.cloneTemplate(analyticsSF)
        if not row then return end
        Templates.safeText(row, "DescriptionTextLabel", hint or "")
        Templates.safeText(row, "StatsValueTextLabel",  tostring(value or "—"))
        local nameFrame = row:FindFirstChild("NameFrame")
        if nameFrame then
            Templates.safeText(nameFrame, "StatsNameTextLabel", label)
            Templates.safeText(nameFrame, "TimeTextLabel", category or "")
        end
    end

    local function render(d)
        Templates.clearList(analyticsSF)
        if not d or type(d) ~= "table" or not d.placeId then
            addRow("No permission", "—", "Need Mod+ rank to view analytics", "")
            return
        end

        addRow("Server uptime",  d.uptimeFormatted or "?",
            ("started %s ago"):format(d.uptimeFormatted or "?"), "SERVER")
        addRow("Place version",  "v"..tostring(d.placeVersion or 1),
            d.placeName or "?",  "SERVER")
        addRow("Server type",    d.privateServer and "Private (VIP)" or "Public",
            "max "..tostring(d.maxPlayers).." slots", "SERVER")
        addRow("Place ID",       tostring(d.placeId),
            "PlaceId",           "SERVER")
        addRow("Universe ID",    tostring(d.universeId),
            "GameId / UniverseId", "SERVER")
        addRow("Job ID",         (tostring(d.jobId or ""):sub(1, 12).."…"),
            "ServerJobId",       "SERVER")

        addRow("Creator",        d.creatorName or "?",
            (d.creatorType or "?").." · id "..tostring(d.creatorId), "CREATOR")

        addRow("Online players", ("%d / %d"):format(d.online or 0, d.maxPlayers or 0),
            ("%d distinct joined this session"):format(d.totalJoined or 0), "PLAYERS")
        addRow("Premium players", tostring(d.premiumCount or 0),
            ("%.1f%% of online"):format(d.online > 0 and (d.premiumCount / d.online * 100) or 0), "PLAYERS")
        addRow("Avg account age", (d.avgAccountAge or 0).." days",
            "across players online", "PLAYERS")
        addRow("Avg ping",       (d.avgPing or 0).." ms",
            "round-trip", "PLAYERS")

        addRow("Server FPS",     tostring(d.serverFps or 0),
            "heartbeat", "PERFORMANCE")
        addRow("Server memory",  (d.serverMemoryMB or 0).." MB",
            "total Lua memory", "PERFORMANCE")
        addRow("Physics step",   (d.physicsStepMs or 0).." ms",
            "per-frame budget", "PERFORMANCE")
        addRow("Parts in workspace", fmtNumber(d.partsCount or 0) ..
            (d.partsTruncated and "+" or ""),
            d.partsTruncated and "scan capped at 5000" or "exact", "PERFORMANCE")
        addRow("Scripts (total)", fmtNumber(d.scriptCount or 0),
            "Script + LocalScript + ModuleScript", "PERFORMANCE")

        addRow("Commands run",  tostring(d.totalCommands or 0),
            "since server start", "ACTIVITY")
        addRow("Last hour",     tostring(d.commandsLastHour or 0),
            "commands fired in last 60min", "ACTIVITY")
        for i, c in ipairs(d.topCommands or {}) do
            addRow(("TOP CMD #%d"):format(i), tostring(c.count), c.name, "ACTIVITY")
        end
        for i, a in ipairs(d.topAdmins or {}) do
            addRow(("TOP ADMIN #%d"):format(i), tostring(a.count), "@"..a.name, "ACTIVITY")
        end

        local spacer = Instance.new("Frame")
        spacer.Name = "uxrSpacer"
        spacer.BackgroundTransparency = 1
        spacer.BorderSizePixel = 0
        spacer.LayoutOrder = 999
        spacer.Parent = analyticsSF
    end

    local function refresh()
        if not UtilModule:HasRank(LocalPlayer, Permissions.LogsViewRank or "Mod") then
            render(nil); return
        end
        local ok, snapshot = pcall(function()
            return RemoteFunction:InvokeServer("getAnalytics")
        end)
        if not ok then warn("[uxrAPS v5] getAnalytics failed:", snapshot); return end
        render(snapshot)
    end

    ctx.refreshHooks.Analytics = refresh

    task.spawn(function()
        while true do
            task.wait(5)
            if page.Visible then refresh() end
        end
    end)
end

return Analytics
