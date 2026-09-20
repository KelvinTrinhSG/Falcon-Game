--!nocheck
local CollectionService = game:GetService("CollectionService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local GuiService        = game:GetService("GuiService")

local Sticky = {}
local TAG = "uxrSticky"
local INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local OFFSET_PX = 15

local function wire(frame)
    if frame:GetAttribute("_uxrStickyWired") then return end
    frame:SetAttribute("_uxrStickyWired", true)
    if not frame:IsA("GuiObject") then return end

    local origPos = frame.Position
    local hovering = false

    local function reset()
        TweenService:Create(frame, INFO, { Position = origPos }):Play()
    end

    frame.MouseEnter:Connect(function() hovering = true end)
    frame.MouseLeave:Connect(function()
        hovering = false
        reset()
    end)
    frame.InputChanged:Connect(function(input)
        if not hovering then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
        local center = frame.AbsolutePosition + frame.AbsoluteSize * frame.AnchorPoint
        local size = frame.AbsoluteSize
        if size.X == 0 or size.Y == 0 then return end
        local diff = (mousePos - center) / size * 2
        local off = Vector2.new(diff.X * OFFSET_PX, diff.Y * OFFSET_PX)
        TweenService:Create(frame, INFO, {
            Position = origPos + UDim2.fromOffset(off.X, off.Y),
        }):Play()
    end)
end

function Sticky.init(ctx)
    for _, inst in ipairs(CollectionService:GetTagged(TAG)) do
        if inst:IsDescendantOf(ctx.screen) then wire(inst) end
    end
    CollectionService:GetInstanceAddedSignal(TAG):Connect(function(inst)
        if inst:IsDescendantOf(ctx.screen) then wire(inst) end
    end)
end

return Sticky
