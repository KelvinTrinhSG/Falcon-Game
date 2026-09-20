--!nocheck

local TweenService = game:GetService("TweenService")

local Hint = {}

local IN  = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local OUT = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

function Hint.init(ctx)
    local LocalPlayer = ctx.LocalPlayer

    local sg = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("uxrHint")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "uxrHint"
        sg.DisplayOrder = 950
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = LocalPlayer.PlayerGui
    end

    local currentCard, currentDismissTask

    local function buildCard(text)
        local frame = Instance.new("Frame")
        frame.Name = "HintCard"
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.Position = UDim2.new(0.5, 0, 0, -34)
        frame.Size = UDim2.fromOffset(560, 34)
        frame.AutomaticSize = Enum.AutomaticSize.X
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.Parent = sg

        local c = Instance.new("UICorner", frame); c.CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", frame)
        s.Color = Color3.fromRGB(241, 196, 15); s.Thickness = 1; s.Transparency = 0.3
        local p = Instance.new("UIPadding", frame)
        p.PaddingLeft = UDim.new(0, 14); p.PaddingRight = UDim.new(0, 14)
        p.PaddingTop = UDim.new(0, 6);   p.PaddingBottom = UDim.new(0, 6)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 0, 1, 0)
        lbl.AutomaticSize = Enum.AutomaticSize.X
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.TextSize = 13
        lbl.TextColor3 = Color3.fromRGB(245, 220, 130)
        lbl.Text = text
        lbl.Parent = frame
        return frame
    end

    function Hint:show(text, duration)
        if not text or text == "" then return end
        duration = tonumber(duration) or 8

        if currentCard then
            if currentDismissTask then task.cancel(currentDismissTask); currentDismissTask = nil end
            local dying = currentCard
            TweenService:Create(dying, OUT, {
                Position = UDim2.new(0.5, 0, 0, -34),
                BackgroundTransparency = 1,
            }):Play()
            for _, d in ipairs(dying:GetDescendants()) do
                if d:IsA("TextLabel") then TweenService:Create(d, OUT, { TextTransparency = 1 }):Play() end
                if d:IsA("UIStroke")  then TweenService:Create(d, OUT, { Transparency = 1 }):Play() end
            end
            task.delay(0.3, function() if dying then dying:Destroy() end end)
        end

        currentCard = buildCard(text)
        TweenService:Create(currentCard, IN, {
            Position = UDim2.new(0.5, 0, 0, 12),
            BackgroundTransparency = 0.1,
        }):Play()

        currentDismissTask = task.delay(duration, function()
            currentDismissTask = nil
            if not currentCard then return end
            local dying = currentCard
            currentCard = nil
            TweenService:Create(dying, OUT, {
                Position = UDim2.new(0.5, 0, 0, -34),
                BackgroundTransparency = 1,
            }):Play()
            for _, d in ipairs(dying:GetDescendants()) do
                if d:IsA("TextLabel") then TweenService:Create(d, OUT, { TextTransparency = 1 }):Play() end
                if d:IsA("UIStroke")  then TweenService:Create(d, OUT, { Transparency = 1 }):Play() end
            end
            task.delay(0.3, function() if dying then dying:Destroy() end end)
        end)
    end

    ctx.Hint = Hint
    return Hint
end

return Hint
