--!nocheck

local PlayerProfile = {}

local function shortDuration(seconds)
    if not seconds or seconds < 0 then return "permanent" end
    if seconds < 60       then return seconds.."s" end
    if seconds < 3600     then return math.floor(seconds/60).."m" end
    if seconds < 86400    then return math.floor(seconds/3600).."h" end
    if seconds < 2592000  then return math.floor(seconds/86400).."d" end
    return math.floor(seconds/2592000).."M"
end

local function isoDate(t)
    if not t then return "?" end
    return os.date("!%Y-%m-%d", t)
end

function PlayerProfile.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local pill  = Modal._pillButton
    local C     = Modal._theme()
    local Rfunc = ctx.RemoteFunction

    local function vstack(children, padding, autoSize)
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = autoSize ~= false and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            Padding = UDim.new(0, padding or 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })
        for i, c in ipairs(children or {}) do c.LayoutOrder = i; c.Parent = f end
        return f
    end

    local function hstack(children, padding, height)
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, height or 30),
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, padding or 6),
            VerticalAlignment = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })
        for i, c in ipairs(children or {}) do c.LayoutOrder = i; c.Parent = f end
        return f
    end

    local function label(text, opts)
        opts = opts or {}
        return make("TextLabel", {
            Size = opts.size or UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Font = opts.font or Enum.Font.Gotham,
            TextSize = opts.textSize or 13,
            TextColor3 = opts.color or C.white,
            TextXAlignment = opts.align or Enum.TextXAlignment.Left,
            Text = tostring(text),
            TextWrapped = opts.wrap or false,
        })
    end

    local function rankBadge(rank)
        local hex = rank.color or "#888888"
        local ok, c3 = pcall(Color3.fromHex, hex:gsub("^#", ""))
        local color = ok and c3 or C.gray11
        local frame = make("Frame", {
            Size = UDim2.fromOffset(80, 22),
            BackgroundColor3 = color, BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })
        make("TextLabel", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = ctx.Theme.adjust(color, 0.7),
            Text = ("[%s]"):format(rank.displayName or rank.DisplayName or rank.name or "?"),
            Parent = frame,
        })
        return frame
    end

    local function sectionTitle(text)
        return label(text, {
            font = Enum.Font.GothamBold, textSize = 12, color = C.gray11,
            size = UDim2.new(1, 0, 0, 16),
        })
    end

    local function divider()
        local d = make("Frame", {
            Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0,
            BackgroundColor3 = C.gray7, BackgroundTransparency = 0.5,
        })
        return d
    end

    local Players      = game:GetService("Players")
    local UIS          = game:GetService("UserInputService")
    local RunService   = game:GetService("RunService")

    local function buildViewport(userId)
        local container = make("Frame", {
            Size = UDim2.fromOffset(110, 110),
            BackgroundColor3 = C.gray4, BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 8) }),
            make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.5 }),
        })

        local placeholder = make("ImageLabel", {
            Name = "Placeholder",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = "rbxthumb://type=AvatarHeadShot&id="..tostring(userId).."&w=150&h=150",
            Parent = container,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 8) }) })

        local viewport = make("ViewportFrame", {
            Name = "Rig",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LightDirection = Vector3.new(-0.3, -1, -0.3),
            LightColor = Color3.fromRGB(240, 240, 240),
            Ambient = Color3.fromRGB(100, 100, 110),
            Parent = container,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 8) }) })

        local camera = Instance.new("Camera")
        camera.FieldOfView = 50
        viewport.CurrentCamera = camera
        camera.Parent = viewport

        local worldModel = Instance.new("WorldModel")
        worldModel.Parent = viewport

        task.spawn(function()
            local ok, model = pcall(function()
                return Players:CreateHumanoidModelFromUserId(userId)
            end)
            if not ok or not model then
                warn("[uxrAPS] CreateHumanoidModelFromUserId failed for", userId, ok and "" or model)
                return
            end

            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored = true
                    d.CanCollide = false
                end
            end
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end

            local _, size = model:GetBoundingBox()
            model:PivotTo(CFrame.new(0, size.Y / 2, 0))
            model.Parent = worldModel

            local center = Vector3.new(0, size.Y / 2, 0)
            local diag   = math.max(size.X, size.Y, size.Z)
            local dist   = diag * 1.6
            local angle  = math.rad(180)
            local function aimAt(a)
                local pos = center + Vector3.new(math.sin(a) * dist, 0, math.cos(a) * dist)
                camera.CFrame = CFrame.lookAt(pos, center)
            end
            aimAt(angle)


            local dragging, dragStart, startAngle = false, nil, angle
            local lastInteract = os.clock()
            viewport.Active = true
            viewport.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startAngle = angle
                    lastInteract = os.clock()
                end
            end)
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UIS.InputChanged:Connect(function(input)
                if not dragging then return end
                if input.UserInputType ~= Enum.UserInputType.MouseMovement
                and input.UserInputType ~= Enum.UserInputType.Touch then return end
                local dx = (input.Position - dragStart).X
                angle = startAngle - math.rad(dx * 0.6)
                lastInteract = os.clock()
                aimAt(angle)
            end)

            local conn
            conn = RunService.RenderStepped:Connect(function(dt)
                if not viewport.Parent then conn:Disconnect(); return end
                if os.clock() - lastInteract > 2 and not dragging then
                    angle += dt * 0.4
                    aimAt(angle)
                end
            end)
        end)

        return container
    end

    local function buildHeader(data)
        local avatar = buildViewport(data.userId)

        local nameLbl = label(data.displayName or data.name or "?", {
            font = Enum.Font.GothamBold, textSize = 18,
            size = UDim2.new(1, 0, 0, 22),
        })
        local userLbl = label("@"..(data.name or "?"), {
            font = Enum.Font.Gotham, textSize = 12, color = C.gray11,
            size = UDim2.new(1, 0, 0, 14),
        })
        local metaBits = {}
        if data.accountAge then
            table.insert(metaBits, ("%d-day account"):format(data.accountAge))
        end
        table.insert(metaBits, data.inServer and "in this server" or "offline")
        local metaLbl = label(table.concat(metaBits, "  ·  "), {
            font = Enum.Font.Gotham, textSize = 11, color = C.gray11,
            size = UDim2.new(1, 0, 0, 14),
        })

        local badge = rankBadge(data.rank or { name = "?", color = "#888888" })

        local right = vstack({ nameLbl, userLbl, badge, metaLbl }, 4)
        right.Size = UDim2.new(1, -122, 0, 0)
        local row = hstack({ avatar, right }, 12, 110)
        row.Size = UDim2.new(1, 0, 0, 110)
        return row
    end

    local function buildStatus(data)
        local lines = {}
        if data.activeMute then
            local who = data.muter and ("by "..data.muter) or ""
            local why = data.muteReason and (' — "'..data.muteReason..'"') or ""
            table.insert(lines, label("Currently muted  "..who..why, {
                font = Enum.Font.GothamMedium, textSize = 12, color = C.warning,
            }))
        end
        if data.warningCount and data.warningCount > 0 then
            table.insert(lines, label(("%d warning(s) on record"):format(data.warningCount), {
                font = Enum.Font.GothamMedium, textSize = 12, color = C.warning,
            }))
        end
        if #lines == 0 then
            table.insert(lines, label("✓ No active punishments", {
                font = Enum.Font.Gotham, textSize = 12, color = C.success,
            }))
        end
        return vstack({ sectionTitle("STATUS"), unpack(lines) }, 4)
    end

    local function buildWarningHistory(data)
        local rows = { sectionTitle("WARNINGS") }
        if #(data.warnings or {}) == 0 then
            table.insert(rows, label("(none)", { color = C.gray11, textSize = 12 }))
        else
            for _, w in ipairs(data.warnings) do
                table.insert(rows, label(("• %s — \"%s\" (by %s)"):format(
                    w.Date or "?", w.Reason or "?", w.Admin or "?"), {
                    textSize = 12, color = C.white, wrap = true,
                }))
            end
        end
        return vstack(rows, 3)
    end

    local function buildNotesHistory(data)
        local rows = { sectionTitle("ADMIN NOTES") }
        if #(data.notes or {}) == 0 then
            table.insert(rows, label("(none)", { color = C.gray11, textSize = 12 }))
        else
            for _, n in ipairs(data.notes) do
                table.insert(rows, label(("• %s — \"%s\" (by %s)"):format(
                    n.Date or "?", n.Text or "?", n.Admin or "?"), {
                    textSize = 12, color = C.white, wrap = true,
                }))
            end
        end
        return vstack(rows, 3)
    end

    local function buildBanHistory(data)
        local rows = { sectionTitle("BAN HISTORY") }
        if #(data.banHistory or {}) == 0 then
            table.insert(rows, label("(no bans on record)", { color = C.gray11, textSize = 12 }))
        else
            for _, b in ipairs(data.banHistory) do
                local dur = b.duration and b.duration > 0 and shortDuration(b.duration) or "permanent"
                local activeTag = b.active and "  [ACTIVE]" or ""
                table.insert(rows, label(("• %s  %s — \"%s\"%s"):format(
                    isoDate(b.startTime), dur, b.reason or "?", activeTag), {
                    textSize = 12,
                    color = b.active and C.danger or C.white, wrap = true,
                }))
            end
        end
        return vstack(rows, 3)
    end

    local function quickActions(data, closeHandle)
        local function fire(text)
            ctx.RemoteEvent:FireServer("command", text)
        end
        local target = data.name
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })

        local BUTTON_COUNT = 7
        local function add(text, layoutOrder, kind, onClick)
            local bg = C.gray5
            if kind == "danger"  then bg = C.danger end
            if kind == "primary" then bg = ctx.Theme.primary end
            local b = pill(text, { bg = bg, width = 0 })
            b.Size = UDim2.new(1 / BUTTON_COUNT, -6, 1, 0)
            b.LayoutOrder = layoutOrder
            b.Parent = row
            b.MouseButton1Click:Connect(onClick)
        end

        add("Command", 1, "primary", function()
            closeHandle:close()
            ctx.state.selectedTarget = target
            if not ctx.screen.Enabled then ctx.toggleScreen(true) end
            ctx.togglePopup(true)
            local box = ctx.commandFrame:FindFirstChild("SearchFrame")
            box = box and box:FindFirstChild("SearchTextBox")
            if box then box.Text = ""; box:CaptureFocus() end
        end)
        add("Note", 2, nil, function()
            closeHandle:close()
            Modal.prompt({
                title = "Note on "..target,
                placeholder = "what should other admins know?",
                onSubmit = function(t)
                    if t and t ~= "" then fire(('note "%s" "%s"'):format(target, t)) end
                end,
            })
        end)
        add("Warn", 3, nil, function()
            closeHandle:close()
            Modal.prompt({
                title = "Warn "..target,
                placeholder = "reason",
                onSubmit = function(t) fire(('warn "%s" "%s"'):format(target, t)) end,
            })
        end)
        add("Mute", 4, nil, function()
            closeHandle:close()
            ctx.Punishment.open({ target = target, category = "mute", initialTab = "Mute" })
        end)
        add("Kick", 5, "danger", function()
            closeHandle:close()
            Modal.prompt({
                title = "Kick "..target,
                placeholder = "reason",
                onSubmit = function(t) fire(('kick "%s" "%s"'):format(target, t)) end,
            })
        end)
        add("Ban", 6, "danger", function()
            closeHandle:close()
            ctx.Punishment.open({ target = target, category = "ban", initialTab = "Permanent" })
        end)
        add("View", 7, nil, function()
            closeHandle:close()
            fire("view "..target)
        end)
        return row
    end

    function PlayerProfile.open(targetName)
        if not targetName or targetName == "" then return end

        local ok, data = pcall(function()
            return Rfunc:InvokeServer("getProfile", targetName)
        end)

        if not ok or not data or data.error then
            Modal.alert({
                title = "Profile error",
                body  = (data and data.error) or "Couldn't load profile for "..tostring(targetName),
                kind  = "danger",
            })
            return
        end

        local header  = buildHeader(data)
        local status  = buildStatus(data)
        local notes   = buildNotesHistory(data)
        local warns   = buildWarningHistory(data)
        local bans    = buildBanHistory(data)

        local handleRef = {}
        local actions = quickActions(data, handleRef)

        handleRef.close = function() end

        local handle = Modal.custom({
            title = nil, body = nil,
            width = 540,
            kind  = "info",
            dismissable = true,
            bodyChildren = {
                header, divider(), status, divider(),
                actions, divider(),
                notes, divider(),
                warns, divider(),
                bans,
            },
            buttons = {
                { text = "Close", onClick = function(h) h:close() end },
            },
        })
        handleRef.close = function(...) handle:close(...) end
    end

    ctx.PlayerProfile = PlayerProfile
    return PlayerProfile
end

return PlayerProfile
