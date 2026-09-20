--!nocheck
local CollectionService = game:GetService("CollectionService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local HoverScan = {}

local INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function wireHoverBtn(inst)
    if inst:GetAttribute("_uxrHoverWired") then return end
    inst:SetAttribute("_uxrHoverWired", true)

    local icon  = inst:FindFirstChildWhichIsA("ImageLabel")
                or inst:FindFirstChildWhichIsA("ImageButton")
    local scale = icon and icon:FindFirstChildOfClass("UIScale")
    if not scale and icon then
        scale = Instance.new("UIScale"); scale.Scale = 1; scale.Parent = icon
    end

    inst.MouseEnter:Connect(function()
        if scale then TweenService:Create(scale, INFO, { Scale = 1.15 }):Play() end
        if inst:IsA("ImageButton") or inst:IsA("ImageLabel") then
            TweenService:Create(inst, INFO, { ImageTransparency = 0.9 }):Play()
        end
    end)
    inst.MouseLeave:Connect(function()
        if scale then TweenService:Create(scale, INFO, { Scale = 1 }):Play() end
        if inst:IsA("ImageButton") or inst:IsA("ImageLabel") then
            TweenService:Create(inst, INFO, { ImageTransparency = 1 }):Play()
        end
    end)
    inst.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if scale then TweenService:Create(scale, INFO, { Scale = 0.7 }):Play() end
        end
    end)
    inst.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if scale then TweenService:Create(scale, INFO, { Scale = 1.15 }):Play() end
        end
    end)
end

function HoverScan.scan(root, tag, wireFn)
    for _, inst in ipairs(CollectionService:GetTagged(tag)) do
        if inst:IsDescendantOf(root) then wireFn(inst) end
    end
    CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
        if inst:IsDescendantOf(root) then wireFn(inst) end
    end)
end

function HoverScan.init(ctx)
    HoverScan.scan(ctx.screen, "uxrHoverBtn", wireHoverBtn)
end

return HoverScan
