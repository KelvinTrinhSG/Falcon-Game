--!nocheck

local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local Navbar = {}

local DRAG_STIFFNESS = 18
local SNAP_THRESHOLD = 0.5

function Navbar.init(ctx)
    local navbar    = ctx.navbar
    local mainFrame = ctx.mainFrame

    navbar.CloseImageButton.MouseButton1Click:Connect(function()
        ctx.toggleScreen(false)
    end)

    navbar.Active = true

    local dragging = false
    local dragInput, dragStart, startPos
    local targetPos = mainFrame.Position

    navbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = mainFrame.Position
            targetPos = startPos
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    navbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            targetPos = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        local cur = mainFrame.Position
        local dx = targetPos.X.Offset - cur.X.Offset
        local dy = targetPos.Y.Offset - cur.Y.Offset
        if math.abs(dx) < SNAP_THRESHOLD and math.abs(dy) < SNAP_THRESHOLD then
            if dx ~= 0 or dy ~= 0 then
                mainFrame.Position = targetPos
            end
            return
        end
        local alpha = 1 - math.exp(-DRAG_STIFFNESS * dt)
        mainFrame.Position = UDim2.new(
            cur.X.Scale, cur.X.Offset + dx * alpha,
            cur.Y.Scale, cur.Y.Offset + dy * alpha
        )
    end)
end

return Navbar
