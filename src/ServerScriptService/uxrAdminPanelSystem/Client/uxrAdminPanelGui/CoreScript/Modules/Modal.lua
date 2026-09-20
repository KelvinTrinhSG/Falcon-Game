--!nocheck

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")

local Modal = {}

local OPEN_TI  = TweenInfo.new(0.20, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CLOSE_TI = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local FADE_TI  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local C

local function make(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then inst[k] = v end
        end
    end
    if children then
        for _, c in ipairs(children) do c.Parent = inst end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local stack    = {}
local modalSG
local escConn

local function attachEscape()
    if escConn then return end
    escConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Escape and #stack > 0 then
            local top = stack[#stack]
            if top.dismissable then top:close("cancel") end
        end
    end)
end

local function detachEscapeIfIdle()
    if #stack == 0 and escConn then
        escConn:Disconnect(); escConn = nil
    end
end

local function buildShell(opts, bodyChildren, buttonChildren)
    local backdrop = make("TextButton", {
        Name = "Backdrop",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.new(),
        AutoButtonColor = false,
        Text = "",
        ZIndex = 100 + #stack * 5,
        Parent = modalSG,
    })

    local cardWidth = tonumber(opts.width) or 420
    local card = make("Frame", {
        Name = "Card",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(cardWidth, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.gray3,
        BorderSizePixel = 0,
        ZIndex = backdrop.ZIndex + 1,
        Parent = backdrop,
    }, {
        make("UICorner", { CornerRadius = UDim.new(0, 10) }),
        make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.5 }),
        make("UIPadding", {
            PaddingTop    = UDim.new(0, 18), PaddingBottom = UDim.new(0, 16),
            PaddingLeft   = UDim.new(0, 20), PaddingRight  = UDim.new(0, 20),
        }),
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    if opts.title and opts.title ~= "" then
        local titleColor = C.white
        if opts.kind == "danger" then titleColor = C.danger end
        make("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = titleColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Text = tostring(opts.title),
            LayoutOrder = 1,
            ZIndex = card.ZIndex,
            Parent = card,
        })
    end

    if opts.body and opts.body ~= "" then
        make("TextLabel", {
            Name = "Body",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Text = tostring(opts.body),
            LayoutOrder = 2,
            ZIndex = card.ZIndex,
            Parent = card,
        })
    end

    if bodyChildren then
        for i, child in ipairs(bodyChildren) do
            child.LayoutOrder = 2 + i
            child.ZIndex = card.ZIndex
            child.Parent = card
        end
    end

    local buttonRow = make("Frame", {
        Name = "Buttons",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = 100,
        ZIndex = card.ZIndex,
        Parent = card,
    }, {
        make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    for i, btn in ipairs(buttonChildren or {}) do
        btn.LayoutOrder = i
        btn.ZIndex = card.ZIndex
        btn.Parent = buttonRow
    end

    local handle = { dismissable = opts.dismissable ~= false }

    local closing = false
    function handle:close(reason)
        if closing then return end
        closing = true
        for idx, h in ipairs(stack) do
            if h == handle then table.remove(stack, idx); break end
        end
        local fadeOut  = TweenService:Create(backdrop, CLOSE_TI, { BackgroundTransparency = 1 })
        local scaleOut = TweenService:Create(card,     CLOSE_TI, { Size = UDim2.fromOffset(cardWidth, 0) })
        fadeOut:Play(); scaleOut:Play()
        task.spawn(function()
            fadeOut.Completed:Wait()
            if backdrop then backdrop:Destroy() end
            detachEscapeIfIdle()
            if reason == "cancel" and opts._onAutoCancel then opts._onAutoCancel() end
        end)
    end

    local dragStartedInCard = false
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragStartedInCard = true
        end
    end)
    backdrop.MouseButton1Click:Connect(function()
        if dragStartedInCard then
            dragStartedInCard = false
            return
        end
        if handle.dismissable then handle:close("cancel") end
    end)

    card.Size = UDim2.fromOffset(cardWidth * 0.92, 0)
    TweenService:Create(backdrop, FADE_TI, { BackgroundTransparency = 0.4 }):Play()
    TweenService:Create(card,    OPEN_TI, { Size = UDim2.fromOffset(cardWidth, 0) }):Play()

    table.insert(stack, handle)
    attachEscape()

    return card, backdrop, handle
end

local function pillButton(text, opts)
    opts = opts or {}
    local bg = opts.bg or C.gray5
    local fg = opts.fg or C.white
    local btn = make("TextButton", {
        Name = text,
        Size = UDim2.fromOffset(opts.width or 88, 32),
        BackgroundColor3 = bg,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = fg,
        Text = text,
    }, {
        make("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, FADE_TI, { BackgroundColor3 = bg:Lerp(C.white, 0.08) }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, FADE_TI, { BackgroundColor3 = bg }):Play()
    end)
    return btn
end

function Modal.confirm(opts)
    opts = opts or {}
    local cancelBtn = pillButton(opts.no or "Cancel", { bg = C.gray5 })
    local okBtn     = pillButton(opts.yes or "Confirm", {
        bg = opts.kind == "danger" and C.danger or C.primary,
    })
    local _, _, handle = buildShell(opts, nil, { cancelBtn, okBtn })

    opts._onAutoCancel = opts.onCancel
    cancelBtn.MouseButton1Click:Connect(function()
        handle:close()
        if opts.onCancel then task.spawn(opts.onCancel) end
        opts._onAutoCancel = nil
    end)
    okBtn.MouseButton1Click:Connect(function()
        handle:close()
        opts._onAutoCancel = nil
        if opts.onConfirm then task.spawn(opts.onConfirm) end
    end)
    return handle
end

function Modal.alert(opts)
    opts = opts or {}
    local okBtn = pillButton(opts.ok or "OK", { bg = C.primary })
    local _, _, handle = buildShell(opts, nil, { okBtn })

    opts._onAutoCancel = opts.onClose
    okBtn.MouseButton1Click:Connect(function()
        handle:close()
        opts._onAutoCancel = nil
        if opts.onClose then task.spawn(opts.onClose) end
    end)
    return handle
end

function Modal.prompt(opts)
    opts = opts or {}
    local inputHolder = make("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = C.gray2,
        BorderSizePixel = 0,
    }, {
        make("UICorner", { CornerRadius = UDim.new(0, 6) }),
        make("UIStroke", { Color = C.gray8, Thickness = 1 }),
        make("UIPadding", {
            PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
        }),
    })
    local box = make("TextBox", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = C.white,
        PlaceholderColor3 = C.gray11,
        PlaceholderText = opts.placeholder or "",
        Text = opts.default or "",
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputHolder,
    })

    local cancelBtn = pillButton(opts.cancel or "Cancel", { bg = C.gray5 })
    local okBtn     = pillButton(opts.submit or "OK",     { bg = C.primary })
    local _, _, handle = buildShell(opts, { inputHolder }, { cancelBtn, okBtn })

    task.defer(function() box:CaptureFocus() end)

    local function submit()
        handle:close()
        opts._onAutoCancel = nil
        if opts.onSubmit then task.spawn(opts.onSubmit, box.Text) end
    end
    local function cancel()
        handle:close()
        opts._onAutoCancel = nil
        if opts.onCancel then task.spawn(opts.onCancel) end
    end

    opts._onAutoCancel = opts.onCancel
    okBtn.MouseButton1Click:Connect(submit)
    cancelBtn.MouseButton1Click:Connect(cancel)
    box.FocusLost:Connect(function(enter)
        if enter then submit() end
    end)
    return handle
end

function Modal.select(opts)
    opts = opts or {}
    local list = make("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, math.min(36 * #opts.options + 8, 220)),
        BackgroundColor3 = C.gray2,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = C.gray7,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, {
        make("UICorner", { CornerRadius = UDim.new(0, 6) }),
        make("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        }),
        make("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local cancelBtn = pillButton(opts.cancel or "Cancel", { bg = C.gray5 })
    local _, _, handle = buildShell(opts, { list }, { cancelBtn })

    for i, option in ipairs(opts.options or {}) do
        local row = pillButton(tostring(option), { bg = C.gray4, width = 0 })
        row.Size = UDim2.new(1, 0, 0, 30)
        row.LayoutOrder = i
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Text = "  " .. tostring(option)
        row.Parent = list
        row.MouseButton1Click:Connect(function()
            handle:close()
            opts._onAutoCancel = nil
            if opts.onSelect then task.spawn(opts.onSelect, option, i) end
        end)
    end

    opts._onAutoCancel = opts.onCancel
    cancelBtn.MouseButton1Click:Connect(function()
        handle:close()
        opts._onAutoCancel = nil
        if opts.onCancel then task.spawn(opts.onCancel) end
    end)
    return handle
end

function Modal.custom(opts)
    opts = opts or {}
    local buttonInsts = {}
    for _, spec in ipairs(opts.buttons or {}) do
        local bg = C.gray5
        if spec.kind == "danger"  then bg = C.danger  end
        if spec.kind == "primary" then bg = C.primary end
        if spec.kind == "success" then bg = C.success end
        local btn = pillButton(spec.text or "OK", { bg = bg, width = spec.width })
        table.insert(buttonInsts, btn)
    end

    local _, _, handle = buildShell(opts, opts.bodyChildren, buttonInsts)

    for i, spec in ipairs(opts.buttons or {}) do
        local btn = buttonInsts[i]
        if spec.onClick then
            btn.MouseButton1Click:Connect(function()
                spec.onClick(handle)
            end)
        end
    end

    return handle
end

Modal._make       = make
Modal._pillButton = function(text, opts) return pillButton(text, opts) end
Modal._theme      = function() return C end

function Modal.closeAll()
    for i = #stack, 1, -1 do
        local h = stack[i]
        if h then h:close("cancel") end
    end
end

function Modal.init(ctx)
    C = ctx.Theme

    local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
    modalSG = gui:FindFirstChild("uxrModals")
    if not modalSG then
        modalSG = Instance.new("ScreenGui")
        modalSG.Name = "uxrModals"
        modalSG.DisplayOrder = 1000
        modalSG.ResetOnSpawn = false
        modalSG.IgnoreGuiInset = true
        modalSG.Enabled = true
        modalSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        modalSG.Parent = gui
    end

    return Modal
end

return Modal
