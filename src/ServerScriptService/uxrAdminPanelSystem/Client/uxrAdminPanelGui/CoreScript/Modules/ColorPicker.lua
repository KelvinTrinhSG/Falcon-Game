--!nocheck

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ColorPicker = {}

local function clamp01(v) return math.clamp(v, 0, 1) end

local function rgbFromColor3(c3)
    return math.floor(c3.R * 255 + 0.5),
           math.floor(c3.G * 255 + 0.5),
           math.floor(c3.B * 255 + 0.5)
end

local function hexFromColor3(c3)
    local r, g, b = rgbFromColor3(c3)
    return string.format("#%02X%02X%02X", r, g, b)
end

local function color3FromHex(hex)
    local cleaned = (hex or ""):gsub("^#", "")
    if #cleaned ~= 6 then return nil end
    local r = tonumber(cleaned:sub(1, 2), 16)
    local g = tonumber(cleaned:sub(3, 4), 16)
    local b = tonumber(cleaned:sub(5, 6), 16)
    if not (r and g and b) then return nil end
    return Color3.fromRGB(r, g, b)
end

function ColorPicker.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()

    function ColorPicker.open(opts)
        opts = opts or {}
        local initial = opts.initial
        if typeof(initial) == "string" then
            initial = color3FromHex(initial) or Color3.fromRGB(255, 255, 255)
        elseif typeof(initial) ~= "Color3" then
            initial = Color3.fromRGB(255, 255, 255)
        end
        local h, s, v = Color3.toHSV(initial)

        local body = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })

        local row1 = make("Frame", {
            Size = UDim2.new(1, 0, 0, 180),
            BackgroundTransparency = 1, LayoutOrder = 1, Parent = body,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
        }) })

        local svFrame = make("Frame", {
            Size = UDim2.new(1, -32, 1, 0),
            BackgroundColor3 = Color3.fromHSV(h, 1, 1), BorderSizePixel = 0,
            LayoutOrder = 1, Parent = row1,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
        make("Frame", {
            Name = "WhiteOverlay",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0, Parent = svFrame,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }),
            }),
        })
        make("Frame", {
            Name = "BlackOverlay",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0, Parent = svFrame,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(0,0,0)),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                }),
            }),
        })
        local svDot = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(s, 1 - v),
            Size = UDim2.fromOffset(12, 12),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0, Parent = svFrame,
        }, {
            make("UICorner", { CornerRadius = UDim.new(1, 0) }),
            make("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1.5 }),
        })

        local hueFrame = make("Frame", {
            Size = UDim2.new(0, 22, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
            LayoutOrder = 2, Parent = row1,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIGradient", {
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255,   0,   0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255,   0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(  0, 255,   0)),
                    ColorSequenceKeypoint.new(0.500, Color3.fromRGB(  0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(  0,   0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,   0, 255)),
                    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255,   0,   0)),
                }),
            }),
        })
        local hueArrow = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, h, 0),
            Size = UDim2.new(1, 6, 0, 4),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
            Parent = hueFrame,
        }, { make("UIStroke", { Color = Color3.fromRGB(0,0,0), Thickness = 1 }) })

        local row2 = make("Frame", {
            Size = UDim2.new(1, 0, 0, 96),
            BackgroundTransparency = 1, LayoutOrder = 2, Parent = body,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
        }) })

        local preview = make("Frame", {
            Size = UDim2.new(0, 90, 1, 0),
            BackgroundColor3 = initial, BorderSizePixel = 0,
            LayoutOrder = 1, Parent = row2,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.4 }),
        })

        local inputs = make("Frame", {
            Size = UDim2.new(1, -100, 1, 0),
            BackgroundTransparency = 1, LayoutOrder = 2, Parent = row2,
        }, { make("UIListLayout", { Padding = UDim.new(0, 4) }) })

        local function inputRow(label, layoutOrder)
            local r = make("Frame", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1, LayoutOrder = layoutOrder, Parent = inputs,
            })
            make("TextLabel", {
                Size = UDim2.new(0, 36, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left, Text = label, Parent = r,
            })
            local box = make("TextBox", {
                Position = UDim2.fromOffset(40, 0),
                Size = UDim2.new(1, -40, 1, 0),
                BackgroundColor3 = C.gray3, BorderSizePixel = 0,
                Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.white,
                ClearTextOnFocus = false, Parent = r,
            }, {
                make("UICorner", { CornerRadius = UDim.new(0, 4) }),
                make("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
            })
            return box
        end

        local rBox   = inputRow("R",   1)
        local gBox   = inputRow("G",   2)
        local bBox   = inputRow("B",   3)
        local hexBox = inputRow("Hex", 4)

        local syncing = false
        local function rebuild()
            if syncing then return end
            syncing = true
            local c = Color3.fromHSV(h, s, v)
            preview.BackgroundColor3 = c
            svFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            svDot.Position = UDim2.fromScale(s, 1 - v)
            hueArrow.Position = UDim2.new(0.5, 0, h, 0)
            local rr, gg, bb = rgbFromColor3(c)
            rBox.Text = tostring(rr); gBox.Text = tostring(gg); bBox.Text = tostring(bb)
            hexBox.Text = hexFromColor3(c)
            syncing = false
        end
        rebuild()

        local huedragging = false
        hueFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                huedragging = true
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                huedragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if huedragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local rel = (input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y
                h = clamp01(rel); rebuild()
            end
        end)

        local svdragging = false
        svFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                svdragging = true
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                svdragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if svdragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local rx = (input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X
                local ry = (input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y
                s = clamp01(rx); v = 1 - clamp01(ry); rebuild()
            end
        end)

        local function commitFromRGB()
            if syncing then return end
            local rr = tonumber(rBox.Text) or 0
            local gg = tonumber(gBox.Text) or 0
            local bb = tonumber(bBox.Text) or 0
            local c = Color3.fromRGB(math.clamp(rr,0,255), math.clamp(gg,0,255), math.clamp(bb,0,255))
            h, s, v = Color3.toHSV(c); rebuild()
        end
        rBox.FocusLost:Connect(commitFromRGB)
        gBox.FocusLost:Connect(commitFromRGB)
        bBox.FocusLost:Connect(commitFromRGB)
        hexBox.FocusLost:Connect(function()
            if syncing then return end
            local c = color3FromHex(hexBox.Text)
            if c then h, s, v = Color3.toHSV(c); rebuild() end
        end)

        local handle
        handle = Modal.custom({
            title = opts.title or "Pick a color",
            body = nil, width = 360, kind = "info", dismissable = true,
            bodyChildren = { body },
            buttons = {
                { text = "Cancel", onClick = function(mh) mh:close() end },
                { text = "Use",    onClick = function(mh)
                    local c = Color3.fromHSV(h, s, v)
                    if opts.onSubmit then opts.onSubmit(hexFromColor3(c), c) end
                    mh:close()
                end },
            },
        })
    end

    ctx.ColorPicker = ColorPicker
    return ColorPicker
end

return ColorPicker
