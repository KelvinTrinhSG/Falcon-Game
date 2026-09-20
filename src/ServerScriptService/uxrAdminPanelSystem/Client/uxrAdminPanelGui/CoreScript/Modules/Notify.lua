--!nocheck

local TweenService = game:GetService("TweenService")

local Notify = {}

local SLIDE_IN = TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local POP_IN   = TweenInfo.new(0.50, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local FADE_IN  = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FADE_OUT = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
local COLLAPSE = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut)
local BUMP_TI  = TweenInfo.new(0.40, Enum.EasingStyle.Back,  Enum.EasingDirection.Out)
local HOVER_TI = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local KIND_COLOR = {
    info    = Color3.fromRGB(  0, 140, 255),
    success = Color3.fromRGB( 26, 188, 156),
    warning = Color3.fromRGB(241, 196,  15),
    error   = Color3.fromRGB(239,  35,  60),
}

local screen, container
local cards = {}

local HISTORY_MAX = 50
local history = {}

local SoundService = game:GetService("SoundService")

local function buildCard(data)
    local color = KIND_COLOR[data.kind] or KIND_COLOR.info

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.AnchorPoint = Vector2.new(0.5, 1)
    card.Size = UDim2.new(0, 340, 0, 84)
    card.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.ClipsDescendants = true

    local corner = Instance.new("UICorner", card); corner.CornerRadius = UDim.new(0, 10)

    local uiScale = Instance.new("UIScale", card)
    uiScale.Scale = 0.7

    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(56, 56, 56)
    stroke.Thickness = 1
    stroke.Transparency = 1

    local accent = Instance.new("Frame", card)
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    accent.BackgroundTransparency = 1
    accent.BorderSizePixel = 0

    local textX = 16
    if data.iconId and tonumber(data.iconId) and tonumber(data.iconId) > 0 then
        local icon = Instance.new("ImageLabel", card)
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.fromOffset(12, 22)
        icon.Size = UDim2.fromOffset(40, 40)
        icon.Image = "rbxassetid://" .. tostring(data.iconId)
        icon.ImageTransparency = 1
        textX = 60
    end

    local title = Instance.new("TextLabel", card)
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(textX, 10)
    title.Size = UDim2.new(1, -textX - 12, 0, 22)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(240, 240, 240)
    title.TextTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = tostring(data.title or "")

    local desc = Instance.new("TextLabel", card)
    desc.Name = "Description"
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.fromOffset(textX, 32)
    desc.Size = UDim2.new(1, -textX - 12, 0, 44)
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextColor3 = Color3.fromRGB(180, 180, 185)
    desc.TextTransparency = 1
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Text = tostring(data.description or "")

    local hit = Instance.new("TextButton", card)
    hit.Name = "ClickHit"
    hit.BackgroundTransparency = 1
    hit.Size = UDim2.fromScale(1, 1)
    hit.Text = ""
    hit.AutoButtonColor = false

    if data.soundId and tonumber(data.soundId) and tonumber(data.soundId) > 0 then
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://" .. tostring(data.soundId)
        s.Volume = 0.5
        s.Parent = SoundService
        SoundService:PlayLocalSound(s)
        task.delay(5, function() if s then s:Destroy() end end)
    end

    return card, hit, stroke, uiScale
end

local function findEntry(card)
    for i, c in ipairs(cards) do
        if c.card == card then return i, c end
    end
    return nil, nil
end

local function dismiss(card)
    local idx, entry = findEntry(card)
    if not idx or entry._dismissing then return end
    entry._dismissing = true
    table.remove(cards, idx)

    TweenService:Create(entry.uiScale, FADE_OUT, { Scale = 0.85 }):Play()
    TweenService:Create(card, FADE_OUT, { BackgroundTransparency = 1 }):Play()
    for _, d in ipairs(card:GetDescendants()) do
        if d:IsA("TextLabel") then
            TweenService:Create(d, FADE_OUT, { TextTransparency = 1 }):Play()
        elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
            TweenService:Create(d, FADE_OUT, { ImageTransparency = 1 }):Play()
        elseif d:IsA("Frame") then
            TweenService:Create(d, FADE_OUT, { BackgroundTransparency = 1 }):Play()
        elseif d:IsA("UIStroke") then
            TweenService:Create(d, FADE_OUT, { Transparency = 1 }):Play()
        end
    end

    task.delay(0.18, function()
        if not card.Parent then return end
        TweenService:Create(card, COLLAPSE, {
            Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0),
        }):Play()
    end)

    task.delay(0.55, function() if card.Parent then card:Destroy() end end)
end

local function bumpExisting(entry)
    TweenService:Create(entry.uiScale, BUMP_TI, { Scale = 1.06 }):Play()
    task.delay(0.18, function()
        if entry._dismissing then return end
        TweenService:Create(entry.uiScale, BUMP_TI, { Scale = 1 }):Play()
    end)
    entry.expiry = os.clock() + (entry.data.duration or 5)
end

function Notify:show(data)
    if not data or not container then return end

    table.insert(history, {
        title       = tostring(data.title or ""),
        description = tostring(data.description or ""),
        kind        = tostring(data.kind or "info"),
        time        = os.time(),
    })
    while #history > HISTORY_MAX do table.remove(history, 1) end

    if #cards > 0 then
        local top = cards[1]
        if top.data.title == data.title and top.data.description == data.description then
            bumpExisting(top)
            return
        end
    end

    local card, hit, stroke, uiScale = buildCard(data)
    card.Parent = container
    card.Position = UDim2.new(0.5, 0, 1, 0)
    card.AnchorPoint = Vector2.new(0.5, 1)

    TweenService:Create(card, SLIDE_IN, { AnchorPoint = Vector2.new(0.5, 0) }):Play()
    TweenService:Create(uiScale, POP_IN, { Scale = 1 }):Play()
    TweenService:Create(card, FADE_IN, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(stroke, FADE_IN, { Transparency = 0.4 }):Play()

    task.delay(0.08, function()
        if not card.Parent then return end
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, FADE_IN, { TextTransparency = 0 }):Play()
            elseif d:IsA("ImageLabel") then
                TweenService:Create(d, FADE_IN, { ImageTransparency = 0 }):Play()
            elseif d:IsA("Frame") and d.Name == "Accent" then
                TweenService:Create(d, FADE_IN, { BackgroundTransparency = 0 }):Play()
            end
        end
    end)

    local entry = {
        card = card,
        uiScale = uiScale,
        data = data,
        expiry = os.clock() + (data.duration or 5),
        hovering = false,
    }
    table.insert(cards, 1, entry)

    hit.MouseButton1Click:Connect(function()
        if data.onClick then task.spawn(data.onClick) end
        if data.pin then return end
        dismiss(card)
    end)
    card.MouseEnter:Connect(function()
        entry.hovering = true
        TweenService:Create(uiScale, HOVER_TI, { Scale = 1.02 }):Play()
        TweenService:Create(stroke, HOVER_TI, { Transparency = 0.15 }):Play()
    end)
    card.MouseLeave:Connect(function()
        entry.hovering = false
        entry.expiry = os.clock() + 1.0
        if not entry._dismissing then
            TweenService:Create(uiScale, HOVER_TI, { Scale = 1 }):Play()
            TweenService:Create(stroke, HOVER_TI, { Transparency = 0.4 }):Play()
        end
    end)

    if not data.pin then
        task.spawn(function()
            while card.Parent do
                if not entry.hovering and os.clock() >= entry.expiry then
                    dismiss(card)
                    return
                end
                task.wait(0.1)
            end
        end)
    end
end

local capturedCtx
local function timeSince(t)
    local d = os.time() - t
    if d < 60      then return d.."s ago" end
    if d < 3600    then return math.floor(d/60).."m ago" end
    if d < 86400   then return math.floor(d/3600).."h ago" end
    return math.floor(d/86400).."d ago"
end
local KIND_HEX = {
    info    = "#0090FF",
    success = "#1ABC9C",
    warning = "#F1C40F",
    error   = "#EF233C",
}
function Notify:openHistory()
    if not capturedCtx or not capturedCtx.Modal then return end
    local make = capturedCtx.Modal._make

    local rows = {}
    for i = #history, 1, -1 do
        local h = history[i]
        local color = KIND_HEX[h.kind] or KIND_HEX.info
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = Color3.fromRGB(27, 27, 27),
            BorderSizePixel = 0,
            ClipsDescendants = true,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("Frame", {
                Size = UDim2.new(0, 3, 1, 0),
                BackgroundColor3 = (function()
                    local hex = color:sub(2)
                    return Color3.fromRGB(
                        tonumber(hex:sub(1,2), 16),
                        tonumber(hex:sub(3,4), 16),
                        tonumber(hex:sub(5,6), 16))
                end)(),
                BorderSizePixel = 0,
            }),
        })
        make("TextLabel", {
            Position = UDim2.fromOffset(12, 6),
            Size = UDim2.new(1, -84, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold, TextSize = 12,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = h.title, Parent = row,
        })
        make("TextLabel", {
            Position = UDim2.fromOffset(12, 22),
            Size = UDim2.new(1, -24, 0, 30),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = Color3.fromRGB(180, 180, 185),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Text = h.description, Parent = row,
        })
        make("TextLabel", {
            Position = UDim2.new(1, -68, 0, 6),
            Size = UDim2.fromOffset(60, 14),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 10,
            TextColor3 = Color3.fromRGB(120, 120, 125),
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = timeSince(h.time), Parent = row,
        })
        table.insert(rows, row)
    end

    if #rows == 0 then
        table.insert(rows, make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Text = "(no notifications yet)",
        }))
    end

    local stack = make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, {
        make("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
    for i, r in ipairs(rows) do r.LayoutOrder = i; r.Parent = stack end

    capturedCtx.Modal.custom({
        title = ("Notification History (%d)"):format(#history),
        body = nil,
        width = 460,
        kind = "info",
        dismissable = true,
        bodyChildren = { stack },
        buttons = {
            { text = "Clear", onClick = function(h)
                table.clear(history); h:close()
            end },
            { text = "Close", onClick = function(h) h:close() end },
        },
    })
end

function Notify:init(ctx)
    capturedCtx = ctx
    local plr = ctx.LocalPlayer
    local pg  = plr:WaitForChild("PlayerGui")

    screen = Instance.new("ScreenGui")
    screen.Name = "uxrNotifications"
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.DisplayOrder = 1000
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = pg

    container = Instance.new("Frame")
    container.Name = "Stack"
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(1, 1)
    container.Position = UDim2.new(1, -20, 1, -20)
    container.Size = UDim2.new(0, 340, 1, -40)
    container.ClipsDescendants = true
    container.Parent = screen

    local list = Instance.new("UIListLayout", container)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Padding = UDim.new(0, 8)

    ctx.Notify = Notify
end

return Notify
