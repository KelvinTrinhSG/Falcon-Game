--!nocheck

local Themed = {}

local function applyOne(inst, theme)
    local role = inst:GetAttribute("uxrTheme")
    if not role then return end
    role = tostring(role)

    if role == "bg" or role == "fill" then
        if inst:IsA("GuiObject") then
            inst.BackgroundColor3 = theme.primary
        end

    elseif role == "text" then
        if inst:IsA("TextLabel") or inst:IsA("TextBox") or inst:IsA("TextButton") then
            inst.TextColor3 = theme.primary
        elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            inst.ImageColor3 = theme.primary
        end

    elseif role == "stroke" then
        if inst:IsA("UIStroke") then
            inst.Color = theme.primary
        end
    end
end

function Themed.init(ctx)
    local Theme = ctx.Theme
    local screen = ctx.screen

    local function scanAll()
        for _, d in ipairs(screen:GetDescendants()) do
            applyOne(d, Theme)
        end
    end

    scanAll()

    screen.DescendantAdded:Connect(function(d) applyOne(d, Theme) end)

    Theme.changed.Event:Connect(scanAll)
end

return Themed
