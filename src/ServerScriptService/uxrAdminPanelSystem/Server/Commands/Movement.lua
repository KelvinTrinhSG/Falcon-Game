--!nocheck

local S = require(script.Parent._shared)
local Tools         = S.Tools
local apEvents      = S.apEvents
local Players       = S.Players
local withHumanoid  = S.withHumanoid
local withCharacter = S.withCharacter

local flyOn, noclipOn = {}, {}
Players.PlayerRemoving:Connect(function(p)
    flyOn[p.UserId]    = nil
    noclipOn[p.UserId] = nil
end)

local function setToolSpeed(tool, value, propName)
    if value == nil then return end
    local sv = tool:FindFirstChild(propName)
    if sv then sv.Value = value end
end

return {
    fly = function(ctx, args)
        local target = args.target
        if flyOn[target.UserId] then
            flyOn[target.UserId] = nil
            apEvents.RemoteEvent:FireClient(target, "flyStop")
        else
            flyOn[target.UserId] = true
            apEvents.RemoteEvent:FireClient(target, "flyStart", args.speed)
        end
    end,

    unfly = function(ctx, args)
        flyOn[args.target.UserId] = nil
        apEvents.RemoteEvent:FireClient(args.target, "flyStop")
    end,

    noclip = function(ctx, args)
        local target = args.target
        if noclipOn[target.UserId] then
            noclipOn[target.UserId] = nil
            apEvents.RemoteEvent:FireClient(target, "noclipStop")
        else
            noclipOn[target.UserId] = true
            apEvents.RemoteEvent:FireClient(target, "noclipStart", args.speed)
        end
    end,

    unnoclip = function(ctx, args)
        noclipOn[args.target.UserId] = nil
        apEvents.RemoteEvent:FireClient(args.target, "noclipStop")
    end,

    flytool = function(ctx, args)
        local folder = S.liveFolder("Tools")
        local src = folder and folder:FindFirstChild("FLY Tool")
        if not src then ctx.notify("flytool: 'FLY Tool' not in Storage/Tools", "error"); return end
        local tool = src:Clone()
        setToolSpeed(tool, args.speed, "SpeedValue")
        tool.Parent = args.target.Backpack
    end,

    unflytool = function(ctx, args)
        for _, t in ipairs(args.target.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == "FLY Tool" then t:Destroy() end
        end
        withCharacter(args.target, function(char)
            local t = char:FindFirstChild("FLY Tool")
            if t then t:Destroy() end
        end)
    end,

    nocliptool = function(ctx, args)
        local folder = S.liveFolder("Tools")
        local src = folder and folder:FindFirstChild("Noclip")
        if not src then ctx.notify("nocliptool: 'Noclip' not in Storage/Tools", "error"); return end
        local tool = src:Clone()
        setToolSpeed(tool, args.speed, "Speed")
        tool.Parent = args.target.Backpack
    end,

    unnocliptool = function(ctx, args)
        for _, t in ipairs(args.target.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == "Noclip" then t:Destroy() end
        end
        withCharacter(args.target, function(char)
            local t = char:FindFirstChild("Noclip")
            if t then t:Destroy() end
        end)
    end,

    walkspeed = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.WalkSpeed = args.speed end)
    end,

    jumpspeed = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.JumpHeight = args.height end)
    end,

    sit = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.Sit = true end)
    end,

    jump = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.Jump = true end)
    end,

    fov = function(ctx, args)
        apEvents.RemoteEvent:FireClient(args.target, "setFov", args.fov)
    end,

    superJump = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.JumpHeight = 200 end)
    end,
    heavyJump = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.JumpHeight = 100 end)
    end,
    fast = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.WalkSpeed = 50 end)
    end,
    slow = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.WalkSpeed = 6 end)
    end,
    fly2 = function(ctx, args)
        flyOn[args.target.UserId] = true
        apEvents.RemoteEvent:FireClient(args.target, "flyStart", args.speed or 75)
    end,
    noclip2 = function(ctx, args)
        noclipOn[args.target.UserId] = true
        apEvents.RemoteEvent:FireClient(args.target, "noclipStart", args.speed or 75)
    end,

    weld = function(ctx, args)
        local actorChar = ctx.actor.Character
        local hrp = actorChar and actorChar:FindFirstChild("HumanoidRootPart")
        if not hrp then ctx.notify("weld: actor has no HumanoidRootPart", "error"); return end

        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = { actorChar, args.target.Character }
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 8, rp)
        if not (hit and hit.Instance) then
            ctx.notify("weld: no BasePart in front of you", "error"); return
        end

        local targetHrp = args.target.Character and args.target.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return end
        targetHrp.CFrame = hit.Instance.CFrame * CFrame.new(0, hit.Instance.Size.Y/2 + 3, 0)
        local weldI = Instance.new("WeldConstraint")
        weldI.Part0 = targetHrp; weldI.Part1 = hit.Instance
        weldI.Parent = targetHrp
    end,

    apparate = function(ctx, args)
        withCharacter(args.target, function(char)
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local dist = math.clamp(tonumber(args.distance) or 8, 1, 200)
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * dist
        end)
    end,

    lockplayer = function(ctx, args)
        withCharacter(args.target, function(char)
            local newState = nil
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    if newState == nil then newState = not p.Locked end
                    p.Locked = newState
                end
            end
        end)
    end,
    unlockplayer = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.Locked = false end
            end
        end)
    end,

    control = function(ctx, args)
        local target = args.target
        local actor  = ctx.actor
        if not (actor.Character and target.Character) then
            ctx.notify("control: both players must have a character", "error"); return
        end
        if actor:GetAttribute("uxrControlling") then
            ctx.notify("control: already controlling someone; uncontrol first", "error"); return
        end
        actor:SetAttribute("uxrOriginalCharacterName", actor.Character.Name)
        actor:SetAttribute("uxrControlling", target.Name)
        target:SetAttribute("uxrControlledBy", actor.Name)
        local actorChar = actor.Character
        local targetChar = target.Character
        actor.Character  = targetChar
        target.Character = actorChar
        ctx.notify(("controlling %s — type uncontrol to release"):format(target.Name), "success")
    end,
    uncontrol = function(ctx, args)
        local actor = ctx.actor
        local targetName = actor:GetAttribute("uxrControlling")
        if not targetName then ctx.notify("uncontrol: not controlling anyone", "error"); return end
        local target = Players:FindFirstChild(targetName)
        if not target then
            actor:SetAttribute("uxrControlling", nil)
            ctx.notify("uncontrol: target left the server; cleared marker", "info"); return
        end
        local actorChar = target.Character
        local targetChar = actor.Character
        actor.Character  = actorChar
        target.Character = targetChar
        actor:SetAttribute("uxrControlling", nil)
        actor:SetAttribute("uxrOriginalCharacterName", nil)
        target:SetAttribute("uxrControlledBy", nil)
        ctx.notify("control released", "success")
    end,
    chatHijacker = function(ctx, args)
        args.target:SetAttribute("uxrHijackedBy", ctx.actor.Name)
        if not args.target:GetAttribute("uxrChatHooked") then
            args.target:SetAttribute("uxrChatHooked", true)
            args.target.Chatted:Connect(function(message)
                local hijackerName = args.target:GetAttribute("uxrHijackedBy")
                if not hijackerName then return end
                local hijacker = Players:FindFirstChild(hijackerName)
                if hijacker then
                    apEvents.RemoteEvent:FireClient(hijacker, "notify",
                        ("[%s] %s"):format(args.target.Name, message),
                        6, 0, 0, "#9B59B6")
                end
            end)
        end
        ctx.notify(("spying on %s's chat"):format(args.target.Name), "success")
    end,
    unchathijack = function(ctx, args)
        args.target:SetAttribute("uxrHijackedBy", nil)
        ctx.notify(("stopped spying on %s"):format(args.target.Name), "info")
    end,

    setspawn = function(ctx, args)
        local target = args.target or ctx.actor
        withCharacter(target, function(char)
            local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local spawnName = "uxrSpawn_" .. target.Name
            for _, existing in ipairs(workspace:GetChildren()) do
                if existing.Name == spawnName then existing:Destroy() end
            end
            local sp = Instance.new("SpawnLocation")
            sp.Name = spawnName
            sp.Size = Vector3.new(4, 1, 4)
            sp.Anchored = true; sp.CanCollide = true
            sp.Transparency = 0.5
            sp.BrickColor = BrickColor.new("Bright green")
            sp.TopSurface = Enum.SurfaceType.Smooth
            sp.Neutral = false; sp.AllowTeamChangeOnTouch = false
            sp.TeamColor = sp.BrickColor
            sp.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3, 0))
            sp.Parent = workspace
            target.RespawnLocation = sp
        end)
    end,
}
