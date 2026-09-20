--!nocheck

local Punishment = {}

local PRESETS_BAN  = { { "1h", 3600 }, { "1d", 86400 }, { "7d", 604800 }, { "30d", 2592000 } }
local PRESETS_MUTE = { { "5m", 300  }, { "1h", 3600  }, { "1d", 86400  }, { "7d", 604800 } }

function Punishment.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()
    local RemoteEvent = ctx.RemoteEvent

    local function labelledInput(label, opts)
        opts = opts or {}
        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
        }, {
            make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
        })
        make("TextLabel", {
            Name = "Label", Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left, Text = label, LayoutOrder = 1,
            Parent = wrap,
        })
        local field = make("Frame", {
            Name = "Field", Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = C.gray2, BorderSizePixel = 0, LayoutOrder = 2,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIStroke", { Color = C.gray8, Thickness = 1 }),
            make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
        })
        field.Parent = wrap
        local box = make("TextBox", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.white,
            PlaceholderColor3 = C.gray11, PlaceholderText = opts.placeholder or "",
            Text = opts.default or "", ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = field,
        })
        return wrap, box
    end

    local function tabBar(initial, options, onChange)
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.gray2, BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3),
                PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
            }),
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        local buttons, active = {}, initial
        local function refresh()
            for k, btn in pairs(buttons) do
                btn.BackgroundColor3 = (k == active) and C.primary or C.gray4
                btn.TextColor3 = C.white
            end
        end
        for i, key in ipairs(options) do
            local btn = make("TextButton", {
                Size = UDim2.new(1 / #options, -4, 1, 0),
                BorderSizePixel = 0, AutoButtonColor = false,
                Font = Enum.Font.GothamMedium, TextSize = 12, Text = key,
                LayoutOrder = i, Parent = row,
            }, {
                make("UICorner", { CornerRadius = UDim.new(0, 4) }),
            })
            buttons[key] = btn
            btn.MouseButton1Click:Connect(function()
                active = key
                refresh()
                if onChange then onChange(key) end
            end)
        end
        refresh()
        return row, function() return active end
    end

    local function presetRow(presets, onPick)
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
        }, {
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
        for i, p in ipairs(presets) do
            local label, seconds = p[1], p[2]
            local btn = make("TextButton", {
                Size = UDim2.new(0, 56, 1, 0), BorderSizePixel = 0,
                BackgroundColor3 = C.gray4, AutoButtonColor = false,
                Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.white,
                Text = label, LayoutOrder = i, Parent = row,
            }, {
                make("UICorner", { CornerRadius = UDim.new(0, 4) }),
            })
            btn.MouseButton1Click:Connect(function() onPick(label, seconds) end)
        end
        return row
    end

    local function checkbox(label, initial)
        local checked = initial and true or false
        local frame = make("Frame", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
        }, {
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center,
            }),
        })
        local box = make("TextButton", {
            Size = UDim2.fromOffset(18, 18), BorderSizePixel = 0, AutoButtonColor = false,
            BackgroundColor3 = checked and C.primary or C.gray4,
            Text = checked and "✓" or "",
            Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white,
            LayoutOrder = 1, Parent = frame,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })
        make("TextLabel", {
            Size = UDim2.new(1, -26, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left, Text = label,
            LayoutOrder = 2, Parent = frame,
        })
        box.MouseButton1Click:Connect(function()
            checked = not checked
            box.BackgroundColor3 = checked and C.primary or C.gray4
            box.Text = checked and "✓" or ""
        end)
        return frame, function() return checked end
    end

    function Punishment.open(opts)
        opts = opts or {}
        local category = opts.category == "mute" and "mute" or "ban"
        local presets  = category == "mute" and PRESETS_MUTE or PRESETS_BAN
        local tabs     = category == "mute" and { "Mute", "TempMute" } or { "Permanent", "Temporary" }
        local initial = tabs[1]
        if opts.initialTab then
            for _, t in ipairs(tabs) do
                if t == opts.initialTab then initial = t; break end
            end
        end

        local targetWrap, targetBox = labelledInput("Target", {
            default = opts.target or "",
            placeholder = "username or UserId",
        })

        local typeWrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
        make("TextLabel", {
            Name = "Label", Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left, Text = "Type",
            LayoutOrder = 1, Parent = typeWrap,
        })

        local durationWrap, durationBox = labelledInput("Duration (e.g. 1d12h, 30m)", {
            placeholder = "leave blank for default",
        })
        local presetsWrap = presetRow(presets, function(_label, _seconds)
            durationBox.Text = _label
        end)

        local function showDuration(visible)
            durationWrap.Visible = visible
            presetsWrap.Visible  = visible
        end
        local tabRow, getActiveTab = tabBar(initial, tabs, function(active)
            showDuration(active == "Temporary" or active == "TempMute")
        end)
        tabRow.LayoutOrder = 2
        tabRow.Parent = typeWrap
        showDuration(initial == "Temporary" or initial == "TempMute")

        local reasonWrap, reasonBox = labelledInput("Reason (shown to player)", {
            placeholder = "e.g. exploiting in lobby",
        })
        reasonWrap.Size = UDim2.new(1, 0, 0, 70)
        local rField = reasonWrap:FindFirstChild("Field")
        if rField then
            rField.Size = UDim2.new(1, 0, 0, 50)
            reasonBox.TextWrapped = true
            reasonBox.TextYAlignment = Enum.TextYAlignment.Top
            reasonBox.MultiLine = true
        end

        local noteWrap, noteBox = labelledInput("Moderator note (internal, optional)", {
            placeholder = "context for other admins",
        })

        local altsWrap, getExcludeAlts = checkbox("Exclude alt accounts (recommended)", true)
        local univWrap, getApplyUniverse = checkbox("Apply ban across the whole universe", true)

        local function isTemp()
            local tab = getActiveTab()
            return tab == "Temporary" or tab == "TempMute"
        end

        Modal.custom({
            title = (category == "mute" and "Mute" or "Ban") .. " " .. (opts.target or "player"),
            body  = "Configure the action and submit. The server still enforces your rank.",
            kind  = "danger",
            bodyChildren = {
                targetWrap, typeWrap, durationWrap, presetsWrap,
                reasonWrap, noteWrap, altsWrap, univWrap,
            },
            buttons = {
                { text = "Cancel", onClick = function(h) h:close() end },
                {
                    text = (category == "mute" and "Mute" or "Ban"),
                    kind = "danger",
                    onClick = function(handle)
                        local target = targetBox.Text:match("^%s*(.-)%s*$")
                        if target == "" then return end
                        local kind
                        if category == "mute" then
                            kind = isTemp() and "tempmute" or "mute"
                        else
                            kind = isTemp() and "tempban" or "ban"
                        end

                        local payload = {
                            kind            = kind,
                            targetName      = target,
                            reason          = reasonBox.Text,
                            modNote         = noteBox.Text,
                            excludeAlts     = getExcludeAlts(),
                            applyToUniverse = getApplyUniverse(),
                        }
                        if isTemp() then
                            local raw = durationBox.Text
                            if raw == "" then return end
                            local total = 0
                            for v, u in raw:gmatch("(%d+)([yMdhms])") do
                                local f = ({y=31536000, M=2592000, d=86400, h=3600, m=60, s=1})[u]
                                total = total + tonumber(v) * f
                            end
                            if total == 0 then total = tonumber(raw) or 0 end
                            payload.duration = total
                        end

                        RemoteEvent:FireServer("punish", payload)
                        handle:close()
                    end,
                },
            },
        })
    end

    return Punishment
end

return Punishment
