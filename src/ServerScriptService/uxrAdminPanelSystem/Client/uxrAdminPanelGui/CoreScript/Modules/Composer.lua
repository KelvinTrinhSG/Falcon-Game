--!nocheck

local Players = game:GetService("Players")

local Composer = {}

local DURATION_PRESETS = {
    { "5m", 300 }, { "1h", 3600 }, { "1d", 86400 }, { "7d", 604800 },
}

function Composer.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()

    local function vstack(children, padding)
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            Padding = UDim.new(0, padding or 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })
        for i, c in ipairs(children or {}) do
            c.LayoutOrder = i; c.Parent = f
        end
        return f
    end

    local function hstack(children, padding)
        local f = make("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, padding or 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })
        for i, c in ipairs(children or {}) do
            c.LayoutOrder = i; c.Parent = f
        end
        return f
    end

    local function label(text, color)
        return make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 11,
            TextColor3 = color or C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = text,
        })
    end

    local function textBox(props)
        local field = make("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = C.gray2, BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIStroke", { Color = props.invalid and C.danger or C.gray8, Thickness = 1 }),
            make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
        })
        local box = make("TextBox", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.white,
            PlaceholderColor3 = C.gray11, PlaceholderText = props.placeholder or "",
            Text = props.default or "", ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = field,
        })
        if props.multiline then
            field.Size = UDim2.new(1, 0, 0, 56)
            box.TextWrapped = true
            box.TextYAlignment = Enum.TextYAlignment.Top
            box.MultiLine = true
        end
        if props.numeric then
            box:GetPropertyChangedSignal("Text"):Connect(function()
                local cleaned = box.Text:gsub("[^%-%.%d]", "")
                if cleaned ~= box.Text then box.Text = cleaned end
            end)
        end
        return field, box
    end

    local function pillRow(options, onPick, opts)
        opts = opts or {}
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Wraps = true,
        }) })
        local pills = {}
        local activeName
        local function refresh()
            for k, p in pairs(pills) do
                p.BackgroundColor3 = (k == activeName) and C.primary or C.gray4
            end
        end
        for i, name in ipairs(options) do
            local pill = make("TextButton", {
                Size = UDim2.fromOffset(opts.width or 64, 22),
                BorderSizePixel = 0, AutoButtonColor = false,
                BackgroundColor3 = C.gray4,
                Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.white,
                Text = tostring(name), LayoutOrder = i, Parent = row,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            pills[name] = pill
            pill.MouseButton1Click:Connect(function()
                activeName = name
                refresh()
                if onPick then onPick(name) end
            end)
        end
        return row, function(n) activeName = n; refresh() end
    end

    local function toggle(initialOn, onChange)
        local on = initialOn and true or false
        local frame = make("Frame", {
            Size = UDim2.new(0, 80, 0, 28),
            BackgroundColor3 = on and C.primary or C.gray4,
            BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
        })
        local btn = make("TextButton", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.white,
            Text = on and "✓ Yes" or "× No",
            AutoButtonColor = false, Parent = frame,
        })
        btn.MouseButton1Click:Connect(function()
            on = not on
            frame.BackgroundColor3 = on and C.primary or C.gray4
            btn.Text = on and "✓ Yes" or "× No"
            if onChange then onChange(on) end
        end)
        return frame, function() return on end
    end

    local function pickPlayerSubmodal(onPick)
        local opts = {}
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(opts, p.Name)
        end
        if #opts == 0 then
            Modal.alert({ title = "No players", body = "Nobody else is in the server." })
            return
        end
        Modal.select({
            title = "Pick a player",
            options = opts,
            onSelect = function(name) onPick(name) end,
        })
    end

    local function pickMaterialSubmodal(currentValue, onPick)
        local allMaterials = {}
        for _, m in ipairs(Enum.Material:GetEnumItems()) do
            table.insert(allMaterials, m.Name)
        end
        table.sort(allMaterials)
        Modal.select({
            title = "Pick a material (" .. #allMaterials .. " options)",
            options = allMaterials,
            onSelect = function(name) onPick(name) end,
        })
    end

    local function buildInput(spec, currentValue)
        local default = currentValue or spec.default
        local function lit(v) return v == nil and "" or tostring(v) end

        if spec.type == "Players" then
            local field, box = textBox({
                default = lit(default ~= nil and default or "me"),
                placeholder = "me / all / others / siracozmen01 / team-Red,-bob",
            })
            local chips = pillRow(
                { "me", "all", "others", "random", "nearest", "furthest" },
                function(name) box.Text = name end,
                { width = 62 }
            )
            local pickBtn = Modal._pillButton("Pick player…", { bg = C.gray5, width = 110 })
            pickBtn.Size = UDim2.fromOffset(110, 26)
            pickBtn.MouseButton1Click:Connect(function()
                pickPlayerSubmodal(function(name) box.Text = name end)
            end)
            local extras = hstack({ pickBtn })
            extras.Size = UDim2.new(1, 0, 0, 26)
            return vstack({ field, chips, extras }, 4), function() return box.Text end

        elseif spec.type == "Rank" then
            local names = {}
            for _, r in ipairs(ctx.Permissions.Ranks) do
                if r.Level >= 0 then table.insert(names, r.Name) end
            end
            local active = lit(default)
            local row, setActive = pillRow(names, function(name) active = name end, { width = 72 })
            if active ~= "" then setActive(active) end
            return row, function() return active end

        elseif spec.type == "Material" then
            local active = lit(default)
            local field, box = textBox({
                default = active,
                placeholder = "click Browse to pick from the list",
            })
            local browseBtn = Modal._pillButton("Browse…", { bg = C.gray5, width = 90 })
            browseBtn.Size = UDim2.fromOffset(90, 26)
            browseBtn.MouseButton1Click:Connect(function()
                pickMaterialSubmodal(box.Text, function(name) box.Text = name end)
            end)
            return vstack({ field, hstack({ browseBtn }) }, 4), function() return box.Text end

        elseif spec.type == "Team" then
            local teams = game:GetService("Teams"):GetTeams()
            local names = {}
            for _, t in ipairs(teams) do table.insert(names, t.Name) end
            if #names == 0 then
                local hint = label("(no teams — run u!createteam first)", C.danger)
                return hint, function() return "" end
            end
            local active = lit(default)
            local row, setActive = pillRow(names, function(n) active = n end, { width = 90 })
            if active ~= "" then setActive(active) end
            return row, function() return active end

        elseif spec.type == "Bool" then
            local initial = false
            if default == true or default == "true" then initial = true end
            local frame, getter = toggle(initial)
            return frame, function() return getter() and "true" or "false" end

        elseif spec.oneOf then
            if #spec.oneOf > 6 then
                local active = lit(default)
                local field, box = textBox({ default = active, placeholder = "click Browse to pick" })
                local browseBtn = Modal._pillButton("Browse…", { bg = C.gray5, width = 90 })
                browseBtn.Size = UDim2.fromOffset(90, 26)
                browseBtn.MouseButton1Click:Connect(function()
                    Modal.select({
                        title = "Pick " .. (spec.name or "option"),
                        options = spec.oneOf,
                        onSelect = function(name) box.Text = name; active = name end,
                    })
                end)
                box:GetPropertyChangedSignal("Text"):Connect(function() active = box.Text end)
                return vstack({ field, hstack({ browseBtn }) }, 4), function() return active end
            else
                local active = lit(default)
                local row, setActive = pillRow(spec.oneOf, function(n) active = n end, { width = 72 })
                if active ~= "" then setActive(active) end
                return row, function() return active end
            end

        elseif spec.type == "Duration" then
            local field, box = textBox({
                default = lit(default),
                placeholder = "e.g. 1d12h, 30m, 1y",
            })
            local presets = pillRow(
                { "5m", "1h", "1d", "7d" },
                function(p) box.Text = p end,
                { width = 48 }
            )
            return vstack({ field, presets }, 4), function() return box.Text end

        elseif spec.type == "Color" then
            local field, box = textBox({
                default = lit(default),
                placeholder = "#ff0000",
            })
            local swatch = make("TextButton", {
                Size = UDim2.fromOffset(28, 28),
                BackgroundColor3 = C.white, BorderSizePixel = 0,
                AutoButtonColor = false, Text = "",
            }, {
                make("UICorner", { CornerRadius = UDim.new(0, 4) }),
                make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.4 }),
            })
            box:GetPropertyChangedSignal("Text"):Connect(function()
                local hex = box.Text:gsub("^#", "")
                if #hex == 6 and hex:match("^%x+$") then
                    local ok, c3 = pcall(Color3.fromHex, hex)
                    if ok then swatch.BackgroundColor3 = c3 end
                else
                    swatch.BackgroundColor3 = C.white
                end
            end)
            swatch.MouseButton1Click:Connect(function()
                if not ctx.ColorPicker then return end
                ctx.ColorPicker.open({
                    title = "Pick a color for "..(spec.name or "color"),
                    initial = box.Text ~= "" and box.Text or "#FFFFFF",
                    onSubmit = function(hex) box.Text = hex end,
                })
            end)
            local row = hstack({ field, swatch })
            row.Size = UDim2.new(1, 0, 0, 30)
            field.Size = UDim2.new(1, -36, 1, 0)
            return row, function() return box.Text end

        elseif spec.type == "Number" then
            local hint = ""
            if spec.min or spec.max then
                hint = (" (%s..%s)"):format(tostring(spec.min or "-∞"), tostring(spec.max or "+∞"))
            end
            local field, box = textBox({
                default = lit(default),
                placeholder = "number" .. hint,
                numeric = true,
            })
            local lname = (spec.name or ""):lower()
            local isAssetId = lname:sub(-2) == "id" and #lname >= 4
            if isAssetId and ctx.AssetPicker then
                local pickBtn = make("TextButton", {
                    Size = UDim2.fromOffset(28, 28),
                    BackgroundColor3 = ctx.Theme.primary, BorderSizePixel = 0,
                    AutoButtonColor = true,
                    Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white,
                    Text = "…",
                }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                local atype = (lname:find("audio") or lname:find("sound")) and "Audio"
                    or (lname:find("bundle") and "BundleThumbnail")
                    or "Image"
                pickBtn.MouseButton1Click:Connect(function()
                    ctx.AssetPicker.open({
                        title = "Pick "..spec.name,
                        assetType = atype,
                        initial = box.Text,
                        onSubmit = function(id) box.Text = id end,
                    })
                end)
                local row = hstack({ field, pickBtn })
                row.Size = UDim2.new(1, 0, 0, 30)
                field.Size = UDim2.new(1, -36, 1, 0)
                return row, function() return box.Text end
            end
            return field, function() return box.Text end

        elseif spec.type == "AssetId" then
            local field, box = textBox({
                default = lit(default),
                placeholder = "Roblox asset id",
                numeric = true,
            })
            if ctx.AssetPicker then
                local pickBtn = make("TextButton", {
                    Size = UDim2.fromOffset(28, 28),
                    BackgroundColor3 = ctx.Theme.primary, BorderSizePixel = 0,
                    AutoButtonColor = true,
                    Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white,
                    Text = "…",
                }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
                local lname = (spec.name or ""):lower()
                local atype = (lname:find("audio") or lname:find("sound")) and "Audio" or "Image"
                pickBtn.MouseButton1Click:Connect(function()
                    ctx.AssetPicker.open({
                        title = "Pick "..spec.name,
                        assetType = atype,
                        initial = box.Text,
                        onSubmit = function(id) box.Text = id end,
                    })
                end)
                local row = hstack({ field, pickBtn })
                row.Size = UDim2.new(1, 0, 0, 30)
                field.Size = UDim2.new(1, -36, 1, 0)
                return row, function() return box.Text end
            end
            return field, function() return box.Text end

        else
            local lname = (spec.name or ""):lower()
            local isColorish = lname:find("color") or lname == "tint" or lname == "hex"
            local wantMultiline = spec.joinRest and not isColorish
                and (lname:find("reason") or lname:find("message")
                  or lname:find("text") or lname:find("body")
                  or lname:find("note"))
            local field, box = textBox({
                default = lit(default),
                placeholder = spec.placeholder or spec.name,
                multiline = wantMultiline,
            })
            if isColorish and ctx.ColorPicker then
                local swatch = make("TextButton", {
                    Size = UDim2.fromOffset(28, 28),
                    BackgroundColor3 = C.white, BorderSizePixel = 0,
                    AutoButtonColor = false, Text = "",
                }, {
                    make("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.4 }),
                })
                local function syncSwatch()
                    local hex = (box.Text or ""):gsub("^#", "")
                    if #hex == 6 and hex:match("^%x+$") then
                        local ok, c3 = pcall(Color3.fromHex, hex)
                        if ok then swatch.BackgroundColor3 = c3 end
                    else
                        swatch.BackgroundColor3 = C.white
                    end
                end
                box:GetPropertyChangedSignal("Text"):Connect(syncSwatch)
                syncSwatch()
                swatch.MouseButton1Click:Connect(function()
                    ctx.ColorPicker.open({
                        title = "Pick a color for "..spec.name,
                        initial = (box.Text ~= "" and box.Text:match("^#?%x%x%x%x%x%x$")) and box.Text or "#FFFFFF",
                        onSubmit = function(hex) box.Text = hex end,
                    })
                end)
                local row = hstack({ field, swatch })
                row.Size = UDim2.new(1, 0, 0, 30)
                field.Size = UDim2.new(1, -36, 1, 0)
                return row, function() return box.Text end
            end
            return field, function() return box.Text end
        end
    end

    function Composer.open(args)
        args = args or {}
        local cmd = args.cmd
        local words = args.words or {}
        local commandName = args.commandName or cmd and cmd.Name or words[1] or ""
        if not cmd or not cmd.Args then
            warn("[Composer] cmd or Args missing")
            return
        end

        local rows = {}
        local getters = {}

        for i, spec in ipairs(cmd.Args) do
            local raw = words[i + 1]
            local isReq = spec.default == nil and not spec.optional
            local hintBits = { spec.type }
            if spec.default ~= nil then table.insert(hintBits, "default: " .. tostring(spec.default))
            elseif spec.optional         then table.insert(hintBits, "optional")
            else                              table.insert(hintBits, "required") end
            local hint = table.concat(hintBits, " · ")

            local lbl = label(spec.name .. "  " .. hint, isReq and C.white or C.gray11)
            local input, getter = buildInput(spec, raw)
            getters[i] = getter

            local rowFrame = vstack({ lbl, input }, 4)
            table.insert(rows, rowFrame)
        end

        local bodyChildren = rows

        local function buildText()
            local out = { commandName }
            for i, spec in ipairs(cmd.Args) do
                local v = getters[i]()
                v = (v or ""):match("^%s*(.-)%s*$")
                if v == "" then
                    if spec.default ~= nil then
                        v = tostring(spec.default)
                    elseif spec.optional then
                        break
                    else
                        return nil, ("'%s' is required"):format(spec.name)
                    end
                end
                if spec.type == "String" and v:find("%s") and not spec.joinRest then
                    v = '"' .. v .. '"'
                end
                table.insert(out, v)
            end
            return table.concat(out, " "), nil
        end

        Modal.custom({
            title = (ctx.Settings.Prefix or "") .. commandName,
            body  = cmd.Description or "",
            kind  = cmd.Confirm and "danger" or "info",
            bodyChildren = bodyChildren,
            buttons = {
                {
                    text = "Cancel",
                    onClick = function(h)
                        h:close()
                        if args.onCancel then task.spawn(args.onCancel) end
                    end,
                },
                {
                    text = cmd.Confirm and "Run (destructive)" or "Run",
                    kind = cmd.Confirm and "danger" or "primary",
                    onClick = function(h)
                        local text, err = buildText()
                        if not text then
                            Modal.alert({ title = "Missing input", body = err or "?" })
                            return
                        end
                        h:close()
                        if args.onSubmit then task.spawn(args.onSubmit, text) end
                    end,
                    width = cmd.Confirm and 160 or 88,
                },
            },
        })
    end

    return Composer
end

return Composer
