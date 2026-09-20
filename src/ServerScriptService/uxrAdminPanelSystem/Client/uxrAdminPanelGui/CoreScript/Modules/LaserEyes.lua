--!nocheck

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LaserEyes = {}

local MAX_DISTANCE = 30
local LASER_SOUND_ID = "rbxassetid://81715108332528"
local SHOT_SEND_INTERVAL = 1 / 15

local function getRemote()
    local pkg = ReplicatedStorage:FindFirstChild("uxrAdminPanelSystem")
    if not pkg then return nil end
    local core = pkg:FindFirstChild("Core")
    local ev = core and core:FindFirstChild("apEvents")
    return ev and ev:FindFirstChild("RemoteEvent")
end

local function findNeck(char)
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    if not torso then return nil end
    return torso:FindFirstChild("Neck")
end

local function findTargetPart(char)
    return char:FindFirstChild("uxrLaserTarget")
end

local function setBeamsEnabled(char, on)
    local head = char and char:FindFirstChild("Head"); if not head then return end
    for _, n in ipairs({"uxrLaserLeftBeam", "uxrLaserRightBeam"}) do
        local b = head:FindFirstChild(n); if b then b.Enabled = on end
    end
    local target = findTargetPart(char); if not target then return end
    local mid = target:FindFirstChild("uxrLaser_Mid")
    if mid then
        for _, c in ipairs(mid:GetChildren()) do
            if c:IsA("ParticleEmitter") then c.Enabled = on end
        end
    end
end


local owner = {
    active     = false,
    firing     = false,
    color      = Color3.fromRGB(255, 30, 30),
    sound      = nil,
    inputBegan = nil,
    inputEnded = nil,
    renderStep = nil,
    origNeckC0 = nil,
}

local function teardownOwner()
    if owner.inputBegan then owner.inputBegan:Disconnect(); owner.inputBegan = nil end
    if owner.inputEnded then owner.inputEnded:Disconnect(); owner.inputEnded = nil end
    if owner.renderStep then owner.renderStep:Disconnect(); owner.renderStep = nil end
    if owner.sound then owner.sound:Destroy(); owner.sound = nil end
    local plr = Players.LocalPlayer
    local char = plr and plr.Character
    if char then
        setBeamsEnabled(char, false)
        if owner.origNeckC0 then
            local neck = findNeck(char)
            if neck then neck.C0 = owner.origNeckC0 end
        end
    end
    owner.origNeckC0 = nil
    owner.firing = false
end

local function ensureSound(parent)
    if owner.sound and owner.sound.Parent then return owner.sound end
    local s = Instance.new("Sound")
    s.Name = "uxrLaserSizzle"
    s.SoundId = LASER_SOUND_ID
    s.Volume = 0.6
    s.Looped = true
    s.Parent = parent
    owner.sound = s
    return s
end

local function activateOwner(colorParam)
    teardownOwner()
    owner.active = true
    if typeof(colorParam) == "Color3" then owner.color = colorParam end

    local plr = Players.LocalPlayer
    local cam = workspace.CurrentCamera
    if not (plr and cam) then return end

    owner.inputBegan = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not owner.active then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local char = plr.Character; if not char then return end
        local target = findTargetPart(char); if not target then return end
        local neck = findNeck(char)
        if neck and not owner.origNeckC0 then owner.origNeckC0 = neck.C0 end

        owner.firing = true
        setBeamsEnabled(char, true)
        local head = char:FindFirstChild("Head")
        if head then ensureSound(head):Play() end
    end)

    owner.inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if not owner.firing then return end
        owner.firing = false
        local char = plr.Character; if not char then return end
        setBeamsEnabled(char, false)
        if owner.sound then owner.sound:Stop() end
        local neck = findNeck(char)
        if neck and owner.origNeckC0 then
            TweenService:Create(neck,
                TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                { C0 = owner.origNeckC0 }):Play()
        end
        local r = getRemote()
        if r then r:FireServer("laserShot", char:GetPivot(), owner.origNeckC0 or CFrame.new(), false) end
    end)

    local lastShotSentAt = 0
    owner.renderStep = RunService.RenderStepped:Connect(function()
        if not owner.firing then return end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        local target = char and findTargetPart(char)
        if not (char and head and target) then return end

        local mouse = plr:GetMouse()
        local unit = cam:ScreenPointToRay(mouse.X, mouse.Y, 1)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = { char }
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(unit.Origin, unit.Direction * 1000, rayParams)
        local hitPos = result and result.Position
            or (unit.Origin + unit.Direction.Unit * MAX_DISTANCE)

        local toHit = hitPos - head.Position
        if toHit.Magnitude > MAX_DISTANCE then
            hitPos = head.Position + toHit.Unit * MAX_DISTANCE
        end

        target.CFrame = CFrame.new(hitPos, head.Position)

        local neck = findNeck(char)
        if neck and owner.origNeckC0 then
            local torso = neck.Part0
            if torso then
                local rel = torso.CFrame:PointToObjectSpace(hitPos)
                local yaw = math.atan2(-rel.X, -rel.Z)
                local pitch = math.atan2(rel.Y, math.sqrt(rel.X * rel.X + rel.Z * rel.Z))
                local rot = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
                neck.C0 = CFrame.new(owner.origNeckC0.Position) * rot
            end
        end

        local now = os.clock()
        if now - lastShotSentAt >= SHOT_SEND_INTERVAL then
            lastShotSentAt = now
            local r = getRemote()
            if r then r:FireServer("laserShot", target.CFrame, neck and neck.C0 or CFrame.new(), true) end
        end
    end)
end

local function deactivateOwner()
    owner.active = false
    teardownOwner()
end


local spectators = {}

local function applyShotReplicate(shooter, targetCFrame, neckC0, firing)
    if not shooter or not shooter.Parent then return end
    local char = shooter.Character; if not char then return end
    local target = findTargetPart(char); if not target then return end

    target.CFrame = targetCFrame
    local neck = findNeck(char)
    if neck then neck.C0 = neckC0 end

    setBeamsEnabled(char, firing == true)
end


function LaserEyes.init(ctx)
    local clientHandlers = ctx and ctx._clientHandlers
    LaserEyes.setOwnerActive = function(on, color)
        if on then activateOwner(color) else deactivateOwner() end
    end
    LaserEyes.applyReplicate = applyShotReplicate
end

return LaserEyes
