--!nocheck

local Home = {}

function Home.init(ctx)
    local Players       = ctx.Players
    local RunService    = ctx.RunService
    local LogService    = ctx.LogService
    local Stats         = ctx.Stats
    local LocalPlayer   = ctx.LocalPlayer
    local screen        = ctx.screen
    local UtilModule    = ctx.UtilModule
    local Permissions   = ctx.Permissions
    local RemoteFunction = ctx.RemoteFunction
    local Format        = ctx.Format
    local Templates     = ctx.Templates
    local StatsHelpers  = require(script.Parent.Parent.Stats)

    local home = ctx.pages.Home

    local function updateHomeCards()
        StatsHelpers.setStat(home:FindFirstChild("PlayersFrame"), "Players",
            Format.fmtColoredNumber(#Players:GetPlayers(), "#3498DB"), true)
        StatsHelpers.setStat(home:FindFirstChild("AdminsFrame"), "Admins",
            Format.fmtColoredNumber(StatsHelpers.countAdmins(ctx), "#E74C3C"), true)
    end
    updateHomeCards()

    local sif = home:FindFirstChild("ServerInfoFrame")
    local errorCount, warnCount = 0, 0
    LogService.MessageOut:Connect(function(_, msgType)
        if     msgType == Enum.MessageType.MessageError   then errorCount += 1
        elseif msgType == Enum.MessageType.MessageWarning then warnCount  += 1 end
    end)

    local fps = 60
    RunService.RenderStepped:Connect(function(dt)
        if dt > 0 then fps = (fps * 0.9) + ((1 / dt) * 0.1) end
    end)

    local function setLabel(parent, name, text, rich)
        if not parent then return end
        local node = parent:FindFirstChild(name)
        if not node then return end
        if rich then node.RichText = true end
        node.Text = text
    end

    local serverState = { version = "v5.0" }
    task.spawn(function()
        while screen.Parent do
            local ok, snap = pcall(function() return RemoteFunction:InvokeServer("getHomeState") end)
            if ok and type(snap) == "table" then serverState = snap end
            task.wait(5)
        end
    end)

    local function fmtServerState()
        return serverState.version or "v5.0"
    end

    task.spawn(function()
        while screen.Parent do
            if sif then
                StatsHelpers.setStat(home:FindFirstChild("ServerAgeFrame"), "Server Age",
                    Format.fmtServerAge(workspace.DistributedGameTime), false)

                setLabel(sif, "ErrorTextLabel",  tostring(errorCount), false)
                setLabel(sif, "WarnTextLabel",   tostring(warnCount),  false)
                setLabel(sif, "MemoryTextLabel", Format.fmtMemory(Stats:GetTotalMemoryUsageMb()), true)
                setLabel(sif, "PingTextLabel",   Format.fmtPing((LocalPlayer:GetNetworkPing() or 0) * 1000), true)
                setLabel(sif, "FpsTextLabel",    Format.fmtFps(fps), false)
                setLabel(sif, "VersionTextLabel", fmtServerState(), false)
            end
            task.wait(1)
        end
    end)

    local fastAccessFrame = home:FindFirstChild("FastAccessFrame")
    local fastAccessSF    = fastAccessFrame and fastAccessFrame:FindFirstChild("ListScrollingFrame")

    local FAST_ACCESS_ATTR = "uxrFastAccess"
    local DEFAULT_FAST_ACCESS = { "fly", "heal", "kill", "view", "bring", "respawn" }

    local function loadFastAccess()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local raw = pg and pg:GetAttribute(FAST_ACCESS_ATTR)
        if type(raw) ~= "string" or raw == "" then
            return table.clone(DEFAULT_FAST_ACCESS)
        end
        local out = {}
        for name in raw:gmatch("[^,]+") do
            name = name:match("^%s*(.-)%s*$")
            if name ~= "" and ctx.getCommand(name) then
                table.insert(out, name)
            end
        end
        return out
    end

    local function saveFastAccess(names)
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then pg:SetAttribute(FAST_ACCESS_ATTR, table.concat(names, ",")) end
    end

    local function refreshFastAccess()
        if not fastAccessSF then return end
        Templates.clearList(fastAccessSF)
        local prefix = ctx.Settings.Prefix or ""
        for _, name in ipairs(loadFastAccess()) do
            local cmd = ctx.getCommand(name)
            if cmd and UtilModule:CanRunCommand(LocalPlayer, cmd) then
                local row = Templates.cloneTemplate(fastAccessSF)
                if not row then break end
                local labelHost = row:FindFirstChild("InFrame") or row
                Templates.safeText(labelHost, "ActionTextLabel", prefix .. name)
                local clickBtn = row:FindFirstChild("ClickButton")
                if clickBtn then
                    clickBtn.MouseButton1Click:Connect(function()
                        if ctx.runCommand then ctx.runCommand(name) end
                    end)
                end
            end
        end
    end
    refreshFastAccess()

    local function openEditModal()
        if not ctx.Modal then return end
        local Modal = ctx.Modal
        local make  = Modal._make
        local C     = Modal._theme()

        local working = loadFastAccess()
        local listFrame

        local function rebuildList()
            for _, c in ipairs(listFrame:GetChildren()) do
                if not c:IsA("UIListLayout") then c:Destroy() end
            end
            for i, name in ipairs(working) do
                local row = make("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = C.gray3, BorderSizePixel = 0,
                    LayoutOrder = i, Parent = listFrame,
                }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })

                make("TextLabel", {
                    Position = UDim2.fromOffset(12, 0),
                    Size = UDim2.new(1, -108, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium, TextSize = 13,
                    TextColor3 = C.white,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = (ctx.Settings.Prefix or "") .. name,
                    Parent = row,
                })

                local function mkIconBtn(text, xOffset, onClick)
                    local b = make("TextButton", {
                        Position = UDim2.new(1, xOffset, 0.5, -12),
                        Size = UDim2.fromOffset(24, 24),
                        BackgroundColor3 = C.gray5, BorderSizePixel = 0,
                        AutoButtonColor = false,
                        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white,
                        Text = text, Parent = row,
                    }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                    b.MouseButton1Click:Connect(onClick)
                    return b
                end

                mkIconBtn("↑", -96, function()
                    if i > 1 then
                        working[i], working[i-1] = working[i-1], working[i]
                        rebuildList()
                    end
                end)
                mkIconBtn("↓", -68, function()
                    if i < #working then
                        working[i], working[i+1] = working[i+1], working[i]
                        rebuildList()
                    end
                end)
                local rm = mkIconBtn("×", -32, function()
                    table.remove(working, i)
                    rebuildList()
                end)
                rm.BackgroundColor3 = C.danger
            end
        end

        listFrame = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })

        local addBtn = Modal._pillButton("+ Add command", { bg = C.gray5, width = 160 })
        addBtn.Size = UDim2.fromOffset(160, 28)
        addBtn.MouseButton1Click:Connect(function()
            local existing = {}
            for _, n in ipairs(working) do existing[n:lower()] = true end

            local candidates = {}
            for name, cmd in pairs(ctx.Commands) do
                if not existing[name:lower()] and UtilModule:CanRunCommand(LocalPlayer, cmd) then
                    table.insert(candidates, name)
                end
            end
            table.sort(candidates)

            if #candidates == 0 then
                Modal.alert({ title = "No more commands", body = "Every available command is already in your Fast Access list." })
                return
            end

            Modal.select({
                title = "Pick a command",
                options = candidates,
                onSelect = function(picked)
                    table.insert(working, picked)
                    rebuildList()
                end,
            })
        end)

        local addRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
        })
        addBtn.Parent = addRow

        rebuildList()

        Modal.custom({
            title = "Edit Fast Access",
            body  = "Reorder, remove, or add commands. Clicking a Fast Access item runs the command immediately.",
            width = 460,
            kind  = "info",
            dismissable = true,
            bodyChildren = { listFrame, addRow },
            buttons = {
                { text = "Cancel", onClick = function(h) h:close() end },
                {
                    text = "Save", kind = "primary",
                    onClick = function(h)
                        saveFastAccess(working)
                        refreshFastAccess()
                        h:close()
                    end,
                },
            },
        })
    end

    if fastAccessFrame then
        local editFrame = fastAccessFrame:FindFirstChild("EditFrame")
        local editBtn   = editFrame and (editFrame:FindFirstChild("ClickButton")
                                         or editFrame:FindFirstChildWhichIsA("TextButton"))
        if editBtn then
            editBtn.MouseButton1Click:Connect(openEditModal)
        end
    end

    Players.PlayerAdded:Connect(updateHomeCards)
    Players.PlayerRemoving:Connect(updateHomeCards)

    ctx.refreshHooks.Home = function()
        updateHomeCards()
    end
end

return Home
