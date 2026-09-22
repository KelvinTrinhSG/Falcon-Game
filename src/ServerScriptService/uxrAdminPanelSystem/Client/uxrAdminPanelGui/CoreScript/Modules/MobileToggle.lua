--!nocheck

local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local MobileToggle = {}

local FADE_TI = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function MobileToggle.init(ctx)
    local Theme       = ctx.Theme
    local LocalPlayer = ctx.LocalPlayer
    local screen      = ctx.screen
    local mainFrame   = ctx.mainFrame
    local commandFrame= ctx.commandFrame

    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local force = pg:GetAttribute("uxrForceMobileFab")
    local needFab = UserInputService.TouchEnabled or UserInputService.GamepadEnabled or force
    if not needFab then return end

    local function make(class, props, children)
        local inst = Instance.new(class)
        if props then for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end end
        if children then for _, c in ipairs(children) do c.Parent = inst end end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end

    local sg = pg:FindFirstChild("uxrMobileToggle")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "uxrMobileToggle"
        sg.DisplayOrder = 600
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = pg
    end

    local fabRow = make("Frame", {
        Name = "FabRow",
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -18, 1, -18),
        Size = UDim2.fromOffset(116, 52),
        BackgroundTransparency = 1,
        Parent = sg,
    }, {
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment   = Enum.VerticalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local function fab(text, bg, layoutOrder)
        local b = make("TextButton", {
            Size = UDim2.fromOffset(52, 52),
            BackgroundColor3 = bg, BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold, TextSize = 22,
            TextColor3 = Theme.white,
            Text = text, LayoutOrder = layoutOrder, Parent = fabRow,
        }, {
            make("UICorner", { CornerRadius = UDim.new(1, 0) }),
            make("UIStroke", { Color = Theme.gray3, Thickness = 2, Transparency = 0.4 }),
        })
        local baseBg = b.BackgroundColor3
        b.MouseEnter:Connect(function()
            TweenService:Create(b, FADE_TI, { BackgroundColor3 = baseBg:Lerp(Theme.white, 0.1) }):Play()
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, FADE_TI, { BackgroundColor3 = baseBg }):Play()
        end)
        return b
    end

    local popupBtn = fab(";", Theme.gray5, 1)
    local panelBtn = fab("≡", Theme.primary, 2)

    popupBtn.MouseButton1Click:Connect(function()
        local screenWasEnabled = screen.Enabled
        if not screenWasEnabled then
            mainFrame.Visible = false
            screen.Enabled    = true
        end
        ctx.togglePopup(true)
        ctx.state._popupOpenedSolo = not screenWasEnabled
        local box = commandFrame:FindFirstChild("SearchFrame")
        box = box and box:FindFirstChild("SearchTextBox")
        if box then box:CaptureFocus() end
    end)

    panelBtn.MouseButton1Click:Connect(function()
        if commandFrame.Visible then ctx.togglePopup(false) end
        if ctx.state._popupOpenedSolo then
            ctx.state._popupOpenedSolo = nil
            mainFrame.Visible = true
        end
        ctx.toggleScreen()
    end)

    local function refreshVisibility()
        fabRow.Visible = not (screen.Enabled and mainFrame.Visible)
    end
    screen:GetPropertyChangedSignal("Enabled"):Connect(refreshVisibility)
    mainFrame:GetPropertyChangedSignal("Visible"):Connect(refreshVisibility)
    refreshVisibility()

    Theme.changed.Event:Connect(function()
        panelBtn.BackgroundColor3 = Theme.primary
    end)

    ctx._mobileToggleSg = sg
end

function MobileToggle.destroy(ctx)
    local pg = ctx.LocalPlayer:FindFirstChild("PlayerGui")
    local sg = (ctx._mobileToggleSg) or (pg and pg:FindFirstChild("uxrMobileToggle"))
    if sg then sg:Destroy() end
end

return MobileToggle
