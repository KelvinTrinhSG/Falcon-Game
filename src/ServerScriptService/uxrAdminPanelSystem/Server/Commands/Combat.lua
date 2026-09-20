--!nocheck

local S = require(script.Parent._shared)
local Builds          = S.Builds
local WorkspaceBuilds = S.WorkspaceBuilds
local uxrSS           = S.uxrSS
local withCharacter   = S.withCharacter
local withHumanoid    = S.withHumanoid

return {
    kill = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.Health = 0 end)
    end,

    killall = function(ctx)
        for _, p in ipairs(ctx.Players:GetPlayers()) do
            if p ~= ctx.actor then
                withHumanoid(p, function(hum) hum.Health = 0 end)
            end
        end
    end,

    refresh = function(ctx, args)
        args.target:LoadCharacter()
    end,

    clone = function(ctx, args)
        local target = args.target
        local char = target.Character or target.CharacterAdded:Wait()
        if not char then return end
        local copy = Instance.new("Model")
        copy.Name = target.Name .. "_Clone"
        for _, item in ipairs(char:GetChildren()) do
            local c = item:Clone()
            c.Parent = copy
        end
        copy.Parent = WorkspaceBuilds
        pcall(function()
            copy:PivotTo(char:GetPivot())
        end)
    end,

    damage = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.Health = math.max(hum.Health - args.amount, 0) end)
    end,

    heal = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.Health = hum.Health + args.amount end)
    end,

    maxhealth = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local pct = hum.Health / math.max(1, hum.MaxHealth)
            hum.MaxHealth = math.max(1, tonumber(args.hp) or 100)
            hum.Health    = hum.MaxHealth * pct
        end)
    end,

    sethealth = function(ctx, args)
        withHumanoid(args.target, function(hum) hum.Health = args.hp end)
    end,

    forcefield = function(ctx, args)
        withCharacter(args.target, function(char)
            local existing
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("ForceField") and v.Visible then existing = v; break end
            end
            if existing then existing:Destroy()
            else
                local ff = Instance.new("ForceField")
                ff.Parent = char
            end
        end)
    end,

    unforcefield = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("ForceField") and v.Visible then v:Destroy() end
            end
        end)
    end,

    god = function(ctx, args)
        withCharacter(args.target, function(char)
            local existing
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("ForceField") and not v.Visible then existing = v; break end
            end
            if existing then existing:Destroy()
            else
                local ff = Instance.new("ForceField")
                ff.Visible = false
                ff.Parent  = char
            end
        end)
    end,

    ungod = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("ForceField") and not v.Visible then v:Destroy() end
            end
        end)
    end,

    explosion = function(ctx, args)
        withCharacter(args.target, function(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local ex = Instance.new("Explosion")
            ex.ExplosionType = Enum.ExplosionType.NoCraters
            ex.BlastRadius = args.radius
            ex.Position = hrp.Position
            ex.Parent = hrp
        end)
    end,

    freeze = function(ctx, args)
        local target = args.target
        if not target.Character then return end
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local existing = WorkspaceBuilds:FindFirstChild(target.Name .. "Ice")
        if existing then
            existing:Destroy()
            for _, v in ipairs(target.Character:GetChildren()) do
                if v:IsA("MeshPart") and v.Name ~= "HumanoidRootPart" then v.Anchored = false end
            end
            return
        end

        if not (Builds and Builds:FindFirstChild("Ice")) then
            warn("[uxrAPS] freeze: Builds.Ice missing in Storage/Builds")
            return
        end
        local ice = Builds.Ice:Clone()
        ice.Name   = target.Name .. "Ice"
        ice.Parent = WorkspaceBuilds
        for _, v in ipairs(target.Character:GetChildren()) do
            if v:IsA("MeshPart") then v.Anchored = true end
        end
        ice.CFrame = hrp.CFrame
    end,

    unfreeze = function(ctx, args)
        local target = args.target
        local ice = WorkspaceBuilds:FindFirstChild(target.Name .. "Ice")
        if ice then ice:Destroy() end
        if target.Character then
            for _, v in ipairs(target.Character:GetChildren()) do
                if v:IsA("MeshPart") and v.Name ~= "HumanoidRootPart" then v.Anchored = false end
            end
        end
    end,

    nuke = function(ctx)
        local char = ctx.actor and ctx.actor.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local TweenService = game:GetService("TweenService")

        local function detonate(origin)
            local FIRE_GROW   = 2.2
            local SHOCK_GROW  = 2.6
            local STEM_RISE   = 2.4
            local CAP_RISE    = 3.0
            local CLEANUP_AT  = 6.0
            local MAX_RADIUS  = 110

            local container = Instance.new("Folder")
            container.Name = "uxrNukeBlast"
            container.Parent = WorkspaceBuilds

            local function newPart(name, props)
                local p = Instance.new("Part")
                p.Name = name; p.Anchored = true; p.CanCollide = false
                p.CanQuery = false; p.CanTouch = false; p.Massless = true
                for k, v in pairs(props) do p[k] = v end
                p.Parent = container
                return p
            end

            local flash = newPart("Flash", {
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(MAX_RADIUS * 0.4, MAX_RADIUS * 0.4, MAX_RADIUS * 0.4),
                Material = Enum.Material.Neon,
                Color = Color3.fromRGB(255, 255, 240),
                Transparency = 0, Position = origin,
            })
            local flashLight = Instance.new("PointLight", flash)
            flashLight.Brightness = 50; flashLight.Range = MAX_RADIUS * 2
            flashLight.Color = Color3.fromRGB(255, 240, 200)
            TweenService:Create(flash, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Transparency = 1, Size = Vector3.new(MAX_RADIUS, MAX_RADIUS, MAX_RADIUS) }):Play()
            TweenService:Create(flashLight, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Brightness = 0 }):Play()

            local fireball = newPart("Fireball", {
                Shape = Enum.PartType.Ball, Size = Vector3.new(4, 4, 4),
                Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 150, 30),
                Transparency = 0.05, Position = origin,
            })
            local fireLight = Instance.new("PointLight", fireball)
            fireLight.Brightness = 10; fireLight.Range = MAX_RADIUS
            fireLight.Color = Color3.fromRGB(255, 140, 40)
            TweenService:Create(fireball, TweenInfo.new(FIRE_GROW, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = Vector3.new(MAX_RADIUS * 1.8, MAX_RADIUS * 1.8, MAX_RADIUS * 1.8), Transparency = 1 }):Play()
            TweenService:Create(fireLight, TweenInfo.new(FIRE_GROW * 1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Brightness = 0 }):Play()

            local shock = newPart("Shockwave", {
                Shape = Enum.PartType.Cylinder, Size = Vector3.new(2, 4, 4),
                Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 220, 140),
                Transparency = 0.3,
                CFrame = CFrame.new(origin) * CFrame.Angles(0, 0, math.rad(90)),
            })
            TweenService:Create(shock, TweenInfo.new(SHOCK_GROW, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                { Size = Vector3.new(2, MAX_RADIUS * 2.4, MAX_RADIUS * 2.4), Transparency = 1 }):Play()

            task.delay(0.3, function()
                if not container.Parent then return end
                local stem = newPart("Stem", {
                    Shape = Enum.PartType.Cylinder,
                    Size = Vector3.new(MAX_RADIUS * 0.4, MAX_RADIUS * 0.45, MAX_RADIUS * 0.45),
                    Material = Enum.Material.Neon, Color = Color3.fromRGB(220, 140, 60),
                    Transparency = 0.25,
                    CFrame = CFrame.new(origin + Vector3.new(0, MAX_RADIUS * 0.25, 0))
                           * CFrame.Angles(0, 0, math.rad(90)),
                })
                TweenService:Create(stem, TweenInfo.new(STEM_RISE, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = Vector3.new(MAX_RADIUS * 1.4, MAX_RADIUS * 0.55, MAX_RADIUS * 0.55),
                    CFrame = CFrame.new(origin + Vector3.new(0, MAX_RADIUS * 0.85, 0)) * CFrame.Angles(0, 0, math.rad(90)),
                    Transparency = 0.65,
                }):Play()
            end)

            task.delay(0.7, function()
                if not container.Parent then return end
                local cap = newPart("Cap", {
                    Shape = Enum.PartType.Ball,
                    Size = Vector3.new(MAX_RADIUS * 0.6, MAX_RADIUS * 0.6, MAX_RADIUS * 0.6),
                    Material = Enum.Material.Neon, Color = Color3.fromRGB(200, 110, 50),
                    Transparency = 0.2,
                    Position = origin + Vector3.new(0, MAX_RADIUS * 0.6, 0),
                })
                TweenService:Create(cap, TweenInfo.new(CAP_RISE, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = Vector3.new(MAX_RADIUS * 1.6, MAX_RADIUS * 1.2, MAX_RADIUS * 1.6),
                    Position = origin + Vector3.new(0, MAX_RADIUS * 1.7, 0),
                    Transparency = 0.85,
                }):Play()
            end)

            local boom = Instance.new("Sound", flash)
            boom.SoundId = "rbxassetid://138186576"; boom.Volume = 2
            boom.PlayOnRemove = false; boom:Play()
            local roar = Instance.new("Sound", flash)
            roar.SoundId = "rbxassetid://9114013963"; roar.Volume = 1.2
            roar.PlayOnRemove = false; roar:Play()

            task.spawn(function()
                local start = os.clock()
                local hit = {}
                while os.clock() - start < FIRE_GROW do
                    local currentRadius = fireball.Size.X / 2
                    for _, p in ipairs(ctx.Players:GetPlayers()) do
                        if not hit[p] then
                            local pChar = p.Character
                            local pHrp  = pChar and pChar:FindFirstChild("HumanoidRootPart")
                            if pHrp and (pHrp.Position - origin).Magnitude < currentRadius then
                                local hum = pChar:FindFirstChildOfClass("Humanoid")
                                if hum then hum.Health = 0; hit[p] = true end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)

            task.delay(CLEANUP_AT, function()
                if container.Parent then container:Destroy() end
            end)
        end

        local rocket = Instance.new("Model")
        rocket.Name = "uxrNuke_Rocket"

        local body = Instance.new("Part")
        body.Name = "Body"
        body.Shape = Enum.PartType.Cylinder
        body.Size = Vector3.new(14, 3.5, 3.5)
        body.Material = Enum.Material.Metal
        body.Color = Color3.fromRGB(80, 80, 90)
        body.CanCollide = true; body.CanTouch = true
        body.Anchored = false
        body.Massless = false
        body.Parent = rocket

        local nose = Instance.new("Part")
        nose.Name = "Nose"
        nose.Shape = Enum.PartType.Ball
        nose.Size = Vector3.new(3.5, 3.5, 3.5)
        nose.Material = Enum.Material.Metal
        nose.Color = Color3.fromRGB(200, 40, 40)
        nose.CanCollide = false; nose.CanTouch = false
        nose.Anchored = false; nose.Massless = true
        nose.Parent = rocket

        local spawnPos = hrp.Position + (hrp.CFrame.RightVector * 6) + Vector3.new(0, 9, 0)
        body.CFrame = CFrame.new(spawnPos) * CFrame.Angles(0, 0, math.rad(90))
        nose.CFrame = body.CFrame * CFrame.new(8.5, 0, 0)

        local weldN = Instance.new("WeldConstraint", nose)
        weldN.Part0 = nose; weldN.Part1 = body

        rocket.PrimaryPart = body
        rocket.Parent = WorkspaceBuilds

        local smoke = Instance.new("Smoke", body)
        smoke.Color = Color3.fromRGB(255, 200, 100)
        smoke.Size = 4; smoke.RiseVelocity = 2; smoke.Opacity = 0.6

        local launchSnd = Instance.new("Sound", body)
        launchSnd.SoundId = "rbxassetid://9120399346"
        launchSnd.Volume = 1.2; launchSnd.PlayOnRemove = false
        launchSnd:Play()

        local bv = Instance.new("BodyVelocity", body)
        bv.Velocity = Vector3.new(0, 180, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        task.delay(1.0, function() if bv.Parent then bv:Destroy() end end)

        local impacted = false
        local function tryImpact(other)
            if impacted then return end
            if not other or other:IsDescendantOf(rocket) then return end
            if os.clock() - (rocket:GetAttribute("LaunchedAt") or 0) < 0.3 then
                if char and other:IsDescendantOf(char) then return end
            end
            impacted = true
            local impactPos = body.Position
            rocket:Destroy()
            detonate(impactPos)
        end
        rocket:SetAttribute("LaunchedAt", os.clock())
        body.Touched:Connect(tryImpact)

        task.delay(12, function()
            if not impacted and rocket.Parent then
                impacted = true
                local impactPos = body.Position
                rocket:Destroy()
                detonate(impactPos)
            end
        end)
    end,

    fling = function(ctx, args)
        withCharacter(args.target, function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not (hum and hrp) then return end
            hum.Sit = true
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(100, 100, 100)
            bv.Parent = hrp
            task.delay(1, function() if bv then bv:Destroy() end end)
        end)
    end,

    healall = function(ctx)
        for _, p in ipairs(ctx.Players:GetPlayers()) do
            withHumanoid(p, function(hum) hum.Health = hum.MaxHealth end)
        end
    end,

    tpall = function(ctx, args)
        local dest = args.target.Character
        local destHrp = dest and dest:FindFirstChild("HumanoidRootPart")
        if not destHrp then ctx.notify("tpall: target has no HRP", "error"); return end
        for _, p in ipairs(ctx.Players:GetPlayers()) do
            if p ~= args.target then
                withCharacter(p, function(c)
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = destHrp.CFrame * CFrame.new(math.random(-4,4), 0, math.random(-4,4)) end
                end)
            end
        end
    end,

    fix = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("Smoke") or d:IsA("Fire") or d:IsA("Sparkles") or d:IsA("ParticleEmitter") then
                    d:Destroy()
                end
                if d:IsA("BasePart") then
                    d.Transparency = (d.Name == "HumanoidRootPart") and 1 or 0
                    d.Reflectance = 0
                end
                if d.Name == "uxrGlitching" then d:Destroy() end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed   = 16
                hum.JumpHeight  = 7.2
                hum.Health      = hum.MaxHealth
            end
        end)
    end,

    clear = function(ctx)
        local PRESERVE = { JailCell = true, PublicCell = true, Sounds = true }
        local removed = 0
        if WorkspaceBuilds then
            for _, child in ipairs(WorkspaceBuilds:GetChildren()) do
                if not PRESERVE[child.Name] then
                    child:Destroy(); removed += 1
                end
            end
        end
        ctx.notify(("cleared %d workspace item(s)"):format(removed), "success")
    end,

    removeall = function(ctx, args)
        local kind = tostring(args.effect or ""):lower()
        local classMap = {
            fire = "Fire", smoke = "Smoke", sparkles = "Sparkles",
            forcefield = "ForceField", ff = "ForceField",
            highlight = "Highlight",
        }
        local className = classMap[kind]
        if not className then ctx.notify("removeall: unknown effect "..kind, "error"); return end
        local removed = 0
        for _, p in ipairs(ctx.Players:GetPlayers()) do
            local char = p.Character
            if char then
                for _, d in ipairs(char:GetDescendants()) do
                    if d:IsA(className) then d:Destroy(); removed += 1 end
                end
            end
        end
        ctx.notify(("removed %d %s instance(s)"):format(removed, className), "success")
    end,
}
