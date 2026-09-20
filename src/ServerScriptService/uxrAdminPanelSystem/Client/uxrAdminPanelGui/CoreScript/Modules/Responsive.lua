--!nocheck

local Animations = require(script.Parent.Animations)

local Responsive = {}

local DESIGN = {
    main = Vector2.new(960, 540),
    cmd  = Vector2.new(960, 240),
}
local REFERENCE_WIDTH = 1100

function Responsive.init(ctx)
    local screen = ctx.screen
    screen.IgnoreGuiInset = true

    if ctx.mainFrame then
        ctx.mainFrame.Size = UDim2.fromOffset(DESIGN.main.X, DESIGN.main.Y)
    end

    local cmdScale
    if ctx.commandFrame then
        ctx.commandFrame.Size = UDim2.fromOffset(DESIGN.cmd.X, DESIGN.cmd.Y)
        cmdScale = ctx.commandFrame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
        cmdScale.Parent = ctx.commandFrame
    end

    local function refresh()
        local w = screen.AbsoluteSize.X
        if w < 1 then return end
        local s = math.clamp(w / REFERENCE_WIDTH, 0, 1)
        if ctx.mainFrame then Animations.setDeviceScale(ctx.mainFrame, s) end
        if cmdScale then cmdScale.Scale = s end
    end
    refresh()
    screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)

    ctx.Responsive = Responsive
end

return Responsive
