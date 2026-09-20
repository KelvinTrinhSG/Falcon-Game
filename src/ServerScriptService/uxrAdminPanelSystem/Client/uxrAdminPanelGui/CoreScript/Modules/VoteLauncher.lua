--!nocheck

local VoteLauncher = {}

function VoteLauncher.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()
    local Remote= ctx.RemoteEvent

    local function labelledTextBox(labelText, default, opts)
        opts = opts or {}
        local wrap = make("Frame", {
            Size = UDim2.new(1, 0, 0, 50), BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }) })
        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = labelText, LayoutOrder = 1, Parent = wrap,
        })
        local field = make("Frame", {
            Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.gray2, BorderSizePixel = 0,
            LayoutOrder = 2, Parent = wrap,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIStroke", { Color = C.gray8, Thickness = 1 }),
            make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
        })
        local box = make("TextBox", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = C.white,
            PlaceholderColor3 = C.gray11, PlaceholderText = opts.placeholder or "",
            Text = default or "", ClearTextOnFocus = false,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = field,
        })
        return wrap, box
    end

    local function checkbox(labelText, initial)
        local on = initial and true or false
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }) })
        local box = make("TextButton", {
            Size = UDim2.fromOffset(18, 18), BorderSizePixel = 0, AutoButtonColor = false,
            BackgroundColor3 = on and ctx.Theme.primary or C.gray4,
            Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.white,
            Text = on and "✓" or "", LayoutOrder = 1, Parent = row,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
        make("TextLabel", {
            Size = UDim2.new(1, -26, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = labelText, LayoutOrder = 2, Parent = row,
        })
        box.MouseButton1Click:Connect(function()
            on = not on
            box.BackgroundColor3 = on and ctx.Theme.primary or C.gray4
            box.Text = on and "✓" or ""
        end)
        return row, function() return on end
    end

    function VoteLauncher.open(prefillGlobal)
        local questionWrap, questionBox = labelledTextBox("Question",
            "", { placeholder = "What are we voting on?" })
        local durationWrap, durationBox = labelledTextBox("Duration (seconds)",
            "30", { placeholder = "30" })
        durationBox:GetPropertyChangedSignal("Text"):Connect(function()
            local cleaned = durationBox.Text:gsub("[^%d]", "")
            if cleaned ~= durationBox.Text then durationBox.Text = cleaned end
        end)

        local globalRow, getGlobal = checkbox("Global (across all servers)", prefillGlobal == true)

        Modal.custom({
            title = "Launch vote",
            body  = "Sends a yes/no vote to every player. Closes when the timer ends.",
            width = 460,
            kind  = "info",
            bodyChildren = { questionWrap, durationWrap, globalRow },
            buttons = {
                { text = "Cancel", onClick = function(h) h:close() end },
                {
                    text = "Launch",
                    kind = "primary",
                    onClick = function(h)
                        local q = questionBox.Text:match("^%s*(.-)%s*$")
                        if q == "" then return end
                        local dur = tonumber(durationBox.Text) or 30
                        local voteId = "vote_" .. os.time()
                        Remote:FireServer("voteStart",
                            dur, true, getGlobal(), q, "Yes,No", voteId)
                        h:close()
                        if ctx.Notify then
                            ctx.Notify:show({
                                title = "Vote launched",
                                description = q .. (" (" .. dur .. "s)"),
                                kind = "success", duration = 3,
                            })
                        end
                    end,
                },
            },
        })
    end

    ctx.VoteLauncher = VoteLauncher
    return VoteLauncher
end

return VoteLauncher
