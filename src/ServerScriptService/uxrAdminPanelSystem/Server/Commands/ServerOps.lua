--!nocheck

local CrossServer = require(script.Parent.Parent.CrossServer)

local S = require(script.Parent._shared)
local Players            = S.Players
local TeleportService    = S.TeleportService
local apEvents           = S.apEvents
local Settings           = S.Settings
local PlayerDataManager  = S.PlayerDataManager
local uxrSS              = S.uxrSS
local withCharacter      = S.withCharacter
local ensureEffect       = S.ensureEffect
local removeEffect       = S.removeEffect

return {
    pvpoff = function()
        PlayerDataManager.EditServerData("PVP", false)
        for _, v in ipairs(Players:GetPlayers()) do
            withCharacter(v, function(char)
                local ff = ensureEffect(char, "ForceField", "PVPField")
                ff.Visible = false
            end)
        end
    end,
    pvpon = function()
        PlayerDataManager.EditServerData("PVP", true)
        for _, v in ipairs(Players:GetPlayers()) do
            withCharacter(v, function(char) removeEffect(char, "PVPField") end)
        end
    end,

    lock   = function() PlayerDataManager.EditServerData("Locked", true)  end,
    unlock = function() PlayerDataManager.EditServerData("Locked", false) end,

    restartserver = function()
        for _, v in ipairs(Players:GetPlayers()) do
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, v)
        end
    end,

    setteam = function(ctx, args)
        args.target.Team = args.team
    end,

    time = function(ctx, args)
        local t = args.hour
        if args.minute then t = t + args.minute / 60 end
        game.Lighting.ClockTime = math.clamp(t, 0, 24)
    end,

    sunrisetime = function() game.Lighting.ClockTime = 8  end,
    noontime    = function() game.Lighting.ClockTime = 12 end,
    sunsettime  = function() game.Lighting.ClockTime = 18 end,
    nighttime   = function() game.Lighting.ClockTime = 0  end,

    brightness = function(ctx, args)
        game.Lighting.Brightness = math.clamp(tonumber(args.amount) or 2, 0, 10)
    end,
    ambience = function(ctx, args)
        local raw = tostring(args.color or "")
        local c
        if raw:sub(1, 1) == "#" then
            local hex = raw:sub(2)
            local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
            if r and g and b then c = Color3.fromRGB(r, g, b) end
        else
            local r, g, b = raw:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
            if r then c = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
        end
        if not c then ctx.notify("ambience: expected 'r,g,b' or '#hex'", "error"); return end
        game.Lighting.Ambient = c
        game.Lighting.OutdoorAmbient = c
    end,
    fog = function(ctx, args)
        game.Lighting.FogStart = math.max(0, tonumber(args.start) or 0)
        game.Lighting.FogEnd   = math.max(1, tonumber(args.distance) or 500)
    end,
    fogColor = function(ctx, args)
        local raw = tostring(args.color or "")
        local c
        if raw:sub(1, 1) == "#" then
            local hex = raw:sub(2)
            local r, g, b = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
            if r and g and b then c = Color3.fromRGB(r, g, b) end
        else
            local r, g, b = raw:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
            if r then c = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
        end
        if not c then ctx.notify("fogColor: expected 'r,g,b' or '#hex'", "error"); return end
        game.Lighting.FogColor = c
    end,
    gravity = function(ctx, args)
        workspace.Gravity = math.clamp(tonumber(args.amount) or 196, 0, 1000)
    end,

    ambient = function(ctx, args)
        game.Lighting.Ambient = args.color
    end,
    outdoorambient = function(ctx, args)
        game.Lighting.OutdoorAmbient = args.color
    end,
    colorshift = function(ctx, args)
        game.Lighting.ColorShift_Top = args.color
        game.Lighting.ColorShift_Bottom = args.color
    end,
    exposure = function(ctx, args)
        game.Lighting.ExposureCompensation = math.clamp(tonumber(args.amount) or 0, -5, 5)
    end,
    shadows = function(ctx, args)
        game.Lighting.GlobalShadows = args.enabled and true or false
    end,
    fogstart = function(ctx, args)
        game.Lighting.FogStart = math.max(0, tonumber(args.distance) or 0)
    end,
    fogend = function(ctx, args)
        game.Lighting.FogEnd = math.max(1, tonumber(args.distance) or 500)
    end,
    diffusescale = function(ctx, args)
        game.Lighting.EnvironmentDiffuseScale = math.clamp(tonumber(args.scale) or 1, 0, 1)
    end,
    specularscale = function(ctx, args)
        game.Lighting.EnvironmentSpecularScale = math.clamp(tonumber(args.scale) or 1, 0, 1)
    end,
    latitude = function(ctx, args)
        game.Lighting.GeographicLatitude = math.clamp(tonumber(args.degrees) or 41.7, -90, 90)
    end,
    atmosphere = function(ctx, args)
        local atm = game.Lighting:FindFirstChildOfClass("Atmosphere")
        if not atm then
            atm = Instance.new("Atmosphere")
            atm.Parent = game.Lighting
        end
        atm.Density = math.clamp(tonumber(args.density) or 0.3, 0, 1)
        ctx.notify(("atmosphere density = %.2f"):format(atm.Density), "success")
    end,

    winddir = function(ctx, args)
        local cur = workspace.GlobalWind
        local speed = cur.Magnitude
        if speed < 0.01 then speed = 10 end
        local dir = Vector3.new(tonumber(args.x) or 0, tonumber(args.y) or 0, tonumber(args.z) or 0)
        if dir.Magnitude < 0.01 then dir = Vector3.new(1, 0, 0) end
        workspace.GlobalWind = dir.Unit * speed
    end,
    windspeed = function(ctx, args)
        local cur = workspace.GlobalWind
        local dir = cur.Magnitude > 0.01 and cur.Unit or Vector3.new(1, 0, 0)
        workspace.GlobalWind = dir * math.max(0, tonumber(args.speed) or 0)
    end,

    watercolor = function(ctx, args)
        workspace.Terrain.WaterColor = args.color
    end,
    waterreflectance = function(ctx, args)
        workspace.Terrain.WaterReflectance = math.clamp(tonumber(args.amount) or 0, 0, 1)
    end,
    watertransparency = function(ctx, args)
        workspace.Terrain.WaterTransparency = math.clamp(tonumber(args.amount) or 0.5, 0, 1)
    end,
    watersize = function(ctx, args)
        workspace.Terrain.WaterWaveSize = math.clamp(tonumber(args.amount) or 0.15, 0, 1)
    end,
    waterspeed = function(ctx, args)
        workspace.Terrain.WaterWaveSpeed = math.clamp(tonumber(args.amount) or 10, 0, 100)
    end,

    closeserver = function()
        PlayerDataManager.EditServerData("ServerClosed", true)
        apEvents.RemoteEvent:FireAllClients("notify", Settings.Messages.ServerCloseWarning, 3, 89455602226058, 18984764939, "#ffea00")
        task.wait(3)
        for _, v in ipairs(Players:GetPlayers()) do v:Kick(Settings.Messages.ServerClosed) end
    end,

    shutdown = function()
        PlayerDataManager.EditServerData("ServerClosed", true)
        apEvents.RemoteEvent:FireAllClients("shutdownWarning")
        task.wait(3)
        for _, v in ipairs(Players:GetPlayers()) do v:Kick(Settings.Messages.ServerClosed) end
    end,

    lockdown = function()
        PlayerDataManager.EditServerData("Lockdown", true)
        for _, v in ipairs(Players:GetPlayers()) do
            if not PlayerDataManager:GiveLocalPlayerData(v).LockdownWhitelist then
                v:Kick(Settings.Messages.LockdownKick)
            end
        end
    end,
    unlockdown = function()
        PlayerDataManager.EditServerData("Lockdown", false)
    end,
    addlockdown = function(ctx, args)
        PlayerDataManager:EditLocalPlayerData(args.target, "LockdownWhitelist", true)
    end,
    removelockdown = function(ctx, args)
        PlayerDataManager:EditLocalPlayerData(args.target, "LockdownWhitelist", false)
    end,

    createserver = function(ctx)
        TeleportService:TeleportToPrivateServer(game.PlaceId, TeleportService:ReserveServer(game.PlaceId), { ctx.actor })
    end,

    gshutdown = function(ctx)
        CrossServer.publish("uxr.shutdown.v2", { actor = ctx.actor and ctx.actor.Name or "system" })
        PlayerDataManager.EditServerData("ServerClosed", true)
        apEvents.RemoteEvent:FireAllClients("shutdownWarning")
        task.wait(3)
        for _, v in ipairs(Players:GetPlayers()) do v:Kick(Settings.Messages.ServerClosed) end
    end,

    globallockdown = function(ctx)
        CrossServer.publish("uxr.lockdown.v2", {
            actor = ctx.actor and ctx.actor.Name or "system",
            state = true,
        })
        PlayerDataManager.EditServerData("Lockdown", true)
        for _, v in ipairs(Players:GetPlayers()) do
            if not PlayerDataManager:GiveLocalPlayerData(v).LockdownWhitelist then
                v:Kick(Settings.Messages.LockdownKick)
            end
        end
    end,

    globalunlockdown = function(ctx)
        CrossServer.publish("uxr.lockdown.v2", {
            actor = ctx.actor and ctx.actor.Name or "system",
            state = false,
        })
        PlayerDataManager.EditServerData("Lockdown", false)
    end,

    migrate = function(ctx)
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        end
    end,
    gmigrate = function(ctx)
        CrossServer.publish("uxr.migrate.v2", { actor = ctx.actor and ctx.actor.Name or "system" })
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function() TeleportService:Teleport(game.PlaceId, p) end)
        end
    end,

    clearterrain = function(ctx)
        workspace.Terrain:Clear()
    end,
    colorterrain = function(ctx, args)
        local raw = tostring(args.color or "")
        local c
        if raw:sub(1, 1) == "#" then
            local hex = raw:sub(2)
            local r, g, b = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
            if r and g and b then c = Color3.fromRGB(r, g, b) end
        else
            local r, g, b = raw:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
            if r then c = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
        end
        if not c then ctx.notify("colorterrain: expected 'r,g,b' or '#hex'", "error"); return end
        for _, material in ipairs(Enum.Material:GetEnumItems()) do
            pcall(function() workspace.Terrain:SetMaterialColor(material, c) end)
        end
    end,

    editdata = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "openEditData", args.target.Name)
    end,

    givecash = function(ctx, args)
        local ls = args.target:FindFirstChild("leaderstats")
        local cash = ls and ls:FindFirstChild("Cash")
        if not cash then
            ctx.notify(("givecash: %s has no leaderstats.Cash"):format(args.target.Name), "error")
            return
        end
        cash.Value += args.amount
        ctx.notify(("gave %d cash to %s (total: %d)"):format(args.amount, args.target.Name, cash.Value), "success")
    end,

    givesword = function(ctx, args)
        local ReplicatedStorage   = game:GetService("ReplicatedStorage")
        local PlayerController    = require(game:GetService("ServerScriptService").Controllers.PlayerController)
        local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)

        local weaponId = tostring(args.weapon or "")
        local config   = WeaponConfigurations.Weapons[weaponId]
        if not config then
            ctx.notify(("givesword: '%s' is not a valid weapon id"):format(weaponId), "error")
            return
        end

        local profile = PlayerController:GetProfile(args.target)
        if not profile then
            ctx.notify(("givesword: no profile found for %s"):format(args.target.Name), "error")
            return
        end

        local inventory = profile.Data.WeaponInventory
        if table.find(inventory, weaponId) then
            ctx.notify(("%s already owns %s"):format(args.target.Name, config.DisplayName), "error")
            return
        end
        table.insert(inventory, weaponId)
        ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(args.target, inventory)

        ctx.notify(("gave %s to %s"):format(config.DisplayName, args.target.Name), "success")
    end,

    giveblock = function(ctx, args)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local PlayerController   = require(game:GetService("ServerScriptService").Controllers.PlayerController)
        local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations).ItemConfigurations

        local itemId = tostring(args.block or "")
        local config = ItemConfigurations[itemId]
        if not config or config.Type ~= "Blocks" then
            ctx.notify(("giveblock: '%s' is not a valid block id"):format(itemId), "error")
            return
        end

        local profile = PlayerController:GetProfile(args.target)
        if not profile then
            ctx.notify(("giveblock: no profile found for %s"):format(args.target.Name), "error")
            return
        end

        local amount = math.max(1, math.floor(tonumber(args.amount) or 1))
        local inventory = profile.Data.BlockInventory
        inventory[itemId] = (inventory[itemId] or 0) + amount
        ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(args.target, inventory)

        ctx.notify(("gave %dx %s to %s"):format(amount, config.DisplayName, args.target.Name), "success")
    end,

    giveturret = function(ctx, args)
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local PlayerController   = require(game:GetService("ServerScriptService").Controllers.PlayerController)
        local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations).ItemConfigurations

        local itemId = tostring(args.turret or "")
        local config = ItemConfigurations[itemId]
        if not config or config.Type ~= "Turrets" then
            ctx.notify(("giveturret: '%s' is not a valid turret id"):format(itemId), "error")
            return
        end

        local profile = PlayerController:GetProfile(args.target)
        if not profile then
            ctx.notify(("giveturret: no profile found for %s"):format(args.target.Name), "error")
            return
        end

        local amount = math.max(1, math.floor(tonumber(args.amount) or 1))
        local inventory = profile.Data.BlockInventory
        inventory[itemId] = (inventory[itemId] or 0) + amount
        ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(args.target, inventory)

        ctx.notify(("gave %dx %s to %s"):format(amount, config.DisplayName, args.target.Name), "success")
    end,

    setstat = function(ctx, args)
        local ls = args.target:FindFirstChild("leaderstats")
        local stat = ls and ls:FindFirstChild(args.stat)
        if not stat then ctx.notify(("no stat '%s'"):format(args.stat), "error"); return end
        if stat:IsA("IntValue") or stat:IsA("NumberValue") then
            stat.Value = tonumber(args.value) or stat.Value
        else
            stat.Value = tostring(args.value)
        end
        ctx.notify(("%s.%s = %s"):format(args.target.Name, args.stat, tostring(stat.Value)), "success")
    end,
    addstat = function(ctx, args)
        local ls = args.target:FindFirstChild("leaderstats")
        local stat = ls and ls:FindFirstChild(args.stat)
        if not stat then ctx.notify(("no stat '%s'"):format(args.stat), "error"); return end
        if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
            ctx.notify(("'%s' is %s, not numeric"):format(args.stat, stat.ClassName), "error"); return
        end
        local delta = tonumber(args.value) or 0
        stat.Value = stat.Value + delta
        ctx.notify(("%s.%s += %s → %s"):format(args.target.Name, args.stat, tostring(delta), tostring(stat.Value)), "success")
    end,
    subtractstat = function(ctx, args)
        local ls = args.target:FindFirstChild("leaderstats")
        local stat = ls and ls:FindFirstChild(args.stat)
        if not stat then ctx.notify(("no stat '%s'"):format(args.stat), "error"); return end
        if not (stat:IsA("IntValue") or stat:IsA("NumberValue")) then
            ctx.notify(("'%s' is %s, not numeric"):format(args.stat, stat.ClassName), "error"); return
        end
        local delta = tonumber(args.value) or 0
        stat.Value = stat.Value - delta
        ctx.notify(("%s.%s -= %s → %s"):format(args.target.Name, args.stat, tostring(delta), tostring(stat.Value)), "success")
    end,
    resetstats = function(ctx, args)
        local ls = args.target:FindFirstChild("leaderstats")
        if not ls then ctx.notify("no leaderstats on target", "error"); return end
        local count = 0
        for _, v in ipairs(ls:GetChildren()) do
            if v:IsA("IntValue") or v:IsA("NumberValue") then v.Value = 0; count += 1
            elseif v:IsA("StringValue") then v.Value = ""; count += 1 end
        end
        ctx.notify(("reset %d stat(s) on %s"):format(count, args.target.Name), "success")
    end,
    lockMap = function(ctx)
        local count = 0
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("BasePart") and not d:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid") then
                d.Anchored = true; d.Locked = true; count += 1
            end
        end
        ctx.notify(("locked %d parts"):format(count), "success")
    end,
    insert = function(ctx, args)
        local InsertService = game:GetService("InsertService")
        local id = tonumber(args.assetId); if not id then ctx.notify("insert: invalid id", "error"); return end
        local ok, model = pcall(function() return InsertService:LoadAsset(id) end)
        if not ok or not model then ctx.notify("insert: asset load failed", "error"); return end
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BaseScript") or d:IsA("ModuleScript") then
                pcall(function() d.Enabled = false end)
                d:Destroy()
            end
        end
        local char = ctx.actor.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then model:PivotTo(hrp.CFrame + Vector3.new(0, 0, -8)) end
        model.Parent = workspace
        ctx.notify(("inserted asset %d"):format(id), "success")
    end,
    globalPlace = function(ctx, args)
        local placeId = tonumber(args.placeId); if not placeId then return end
        CrossServer.publish("uxr.place.v2", { placeId = placeId, target = args.target.Name })
        pcall(function() TeleportService:Teleport(placeId, args.target) end)
    end,
    globalForcePlace = function(ctx, args)
        local placeId = tonumber(args.placeId); if not placeId then return end
        local names = {}
        for n in tostring(args.names or ""):gmatch("[^,]+") do
            table.insert(names, n:match("^%s*(.-)%s*$"))
        end
        CrossServer.publish("uxr.forcePlace.v2", { placeId = placeId, names = names })
        for _, name in ipairs(names) do
            local p = Players:FindFirstChild(name)
            if p then pcall(function() TeleportService:Teleport(placeId, p) end) end
        end
    end,

    removestat = function(ctx, args)
        local ls = args.target:FindFirstChild("leaderstats")
        local stat = ls and ls:FindFirstChild(args.stat)
        if not stat then ctx.notify(("no stat '%s'"):format(args.stat), "error"); return end
        stat:Destroy()
        ctx.notify(("removed %s.%s"):format(args.target.Name, args.stat), "success")
    end,

    setwarp = function(ctx, args)
        withCharacter(ctx.actor, function(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            PlayerDataManager:AddWarp(args.name, hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
        end)
    end,
    delwarp = function(ctx, args)
        PlayerDataManager.RemoveWarp(args.name)
    end,
    warps = function(ctx)
        local all = PlayerDataManager.GetWarps()
        local rows = {}
        for name, pos in pairs(all) do
            rows[#rows + 1] = ("%s (%d, %d, %d)"):format(name, pos[1] or 0, pos[2] or 0, pos[3] or 0)
        end
        if #rows == 0 then
            ctx.notify("No warps set — use setwarp <name>", "info"); return
        end
        table.sort(rows)
        ctx.notify(("Warps (%d): %s"):format(#rows, table.concat(rows, "  ·  ")), "info")
    end,

    createteam = function(ctx, args)
        local Team = Instance.new("Team")
        Team.Name = args.name:gsub("_", " ")
        Team.TeamColor = BrickColor.new(args.color)
        Team.AutoAssignable = args.autoAssignable and true or false
        Team.Parent = game:GetService("Teams")
    end,
    removeteam = function(ctx, args)
        local team = game:GetService("Teams"):FindFirstChild(args.name:gsub("_", " "))
        if team then team:Destroy() end
    end,

    teamrespawn = function(ctx, args)
        local n = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Team == args.team then p:LoadCharacter(); n += 1 end
        end
        ctx.notify(("respawned %d player(s) on %s"):format(n, args.team.Name), "success")
    end,
    clearteams = function(ctx)
        local n = 0
        for _, t in ipairs(game:GetService("Teams"):GetTeams()) do t:Destroy(); n += 1 end
        ctx.notify(("removed %d team(s)"):format(n), "success")
    end,
    editteam = function(ctx, args)
        args.team.TeamColor = BrickColor.new(args.color)
        ctx.notify(("%s recolored"):format(args.team.Name), "success")
    end,
    randomizeteams = function(ctx)
        local teams = game:GetService("Teams"):GetTeams()
        if #teams == 0 then ctx.notify("randomizeteams: no teams exist", "error"); return end
        local players = Players:GetPlayers()
        for i = #players, 2, -1 do
            local j = math.random(i)
            players[i], players[j] = players[j], players[i]
        end
        for idx, p in ipairs(players) do
            p.Team = teams[((idx - 1) % #teams) + 1]
        end
        ctx.notify(("randomized %d player(s) across %d team(s)"):format(#players, #teams), "success")
    end,

    savemap = function()
        for _, v in ipairs(uxrSS.MapSave:GetChildren()) do v:Destroy() end
        for _, v in ipairs(workspace:GetChildren()) do
            if not Players:GetPlayerFromCharacter(v) and not v:IsA("Camera") and not v:IsA("Terrain") then
                v:Clone().Parent = uxrSS.MapSave
            end
        end
    end,
    loadmap = function()
        for _, v in ipairs(workspace:GetChildren()) do
            if not Players:GetPlayerFromCharacter(v) and not v:IsA("Camera") and not v:IsA("Terrain") then
                v:Destroy()
            end
        end
        for _, v in ipairs(uxrSS.MapSave:GetChildren()) do v:Clone().Parent = workspace end
    end,
    restoremap = function(ctx)
        local original = uxrSS.MapSave:FindFirstChild("__Original")
        if not original then
            original = Instance.new("Folder")
            original.Name = "__Original"
            for _, v in ipairs(workspace:GetChildren()) do
                if not Players:GetPlayerFromCharacter(v) and not v:IsA("Camera") and not v:IsA("Terrain") then
                    v:Clone().Parent = original
                end
            end
            original.Parent = uxrSS.MapSave
            ctx.notify("restoremap: captured initial snapshot for future restores", "info")
            return
        end
        for _, v in ipairs(workspace:GetChildren()) do
            if not Players:GetPlayerFromCharacter(v) and not v:IsA("Camera") and not v:IsA("Terrain") then
                v:Destroy()
            end
        end
        for _, v in ipairs(original:GetChildren()) do v:Clone().Parent = workspace end
        ctx.notify("restoremap: original snapshot loaded", "success")
    end,
}
