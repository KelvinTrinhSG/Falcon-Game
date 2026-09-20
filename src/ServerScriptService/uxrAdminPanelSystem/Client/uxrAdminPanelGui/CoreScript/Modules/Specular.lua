--!nocheck
local CollectionService = game:GetService("CollectionService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")

local Specular = {}
local TAG = "uxrSpecular"

local current = 0
local function shortestRotation(from, to)
    local diff = ((to - from) % 360 + 540) % 360 - 180
    return from + diff
end

function Specular.init()
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local function tick()
        local look = cam.CFrame.LookVector
        local yaw  = math.deg(math.atan2(-look.X, -look.Z)) % 360
        current = shortestRotation(current, yaw) % 360
        for _, g in ipairs(CollectionService:GetTagged(TAG)) do
            g.Rotation = current
        end
    end

    RunService.RenderStepped:Connect(tick)
end

return Specular
