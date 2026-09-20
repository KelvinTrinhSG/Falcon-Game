--!nocheck

local S = require(script.Parent._shared)
local apEvents      = S.apEvents
local withCharacter = S.withCharacter

local function neutraliseAndExtractTools(model, target)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BaseScript") or d:IsA("ModuleScript") then
            pcall(function() d.Enabled = false end)
            d:Destroy()
        end
    end
    for _, t in ipairs(model:GetChildren()) do
        if t:IsA("Tool") and target.Backpack then t.Parent = target.Backpack end
    end
    model:Destroy()
end

return {
    clearinventory = function(ctx, args)
        for _, v in ipairs(args.target.Backpack:GetChildren()) do v:Destroy() end
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Tool") then v:Destroy() end
            end
        end)
    end,

    viewinventory = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "openInventoryViewer", args.target.Name)
    end,

    viewhats = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "openHatsViewer", args.target.Name)
    end,

    viewtools = function(ctx, args)
        apEvents.RemoteEvent:FireClient(ctx.actor, "openToolsViewer", args.target.Name)
    end,

    handto = function(ctx, args)
        local actorChar = ctx.actor.Character
        local tool = actorChar and actorChar:FindFirstChildOfClass("Tool")
        if not tool then ctx.notify("handto: equip a tool first", "error"); return end
        if not args.target.Backpack then ctx.notify("handto: target has no Backpack", "error"); return end
        tool.Parent = args.target.Backpack
    end,

    speedcoil = function(ctx, args)
        local InsertService = game:GetService("InsertService")
        local ok, model = pcall(function() return InsertService:LoadAsset(99119158) end)
        if not ok or not model then ctx.notify("speedcoil: asset load failed", "error"); return end
        neutraliseAndExtractTools(model, args.target)
    end,
    tool = function(ctx, args)
        local Tools = S.Tools; if not Tools then ctx.notify("Storage/Tools missing", "error"); return end
        local name = tostring(args.name or ""):lower()
        for _, t in ipairs(Tools:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() == name then
                t:Clone().Parent = args.target.Backpack
                return
            end
        end
        ctx.notify(("tool '%s' not in Storage/Tools"):format(args.name or ""), "error")
    end,

    give = function(ctx, args)
        local Tools = S.Tools; if not Tools then return end
        local name = tostring(args.name or ""):lower()
        for _, t in ipairs(Tools:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() == name then
                t:Clone().Parent = args.target.Backpack
                return
            end
        end
        ctx.notify(("give '%s' not found"):format(args.name or ""), "error")
    end,

    gear = function(ctx, args)
        local id = tonumber(args.assetId); if not id then ctx.notify("gear: invalid id", "error"); return end
        local InsertService = game:GetService("InsertService")
        local ok, model = pcall(function() return InsertService:LoadAsset(id) end)
        if not ok or not model then ctx.notify("gear: asset load failed", "error"); return end
        neutraliseAndExtractTools(model, args.target)
    end,

    rocket = function(ctx, args)
        local ok, reason = S.giveTool(args.target, "RocketLauncher")
        if not ok then ctx.notify("rocket: "..tostring(reason), "error") end
    end,

    swag = function(ctx, args)
        local SWAG_POOL = { 583181593, 4819740796, 31784253, 16630147, 451220849, 451220715, 1898764006 }
        local char = args.target.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local desc = hum:GetAppliedDescription()
        local current = desc.HatAccessory or ""
        for _, id in ipairs(SWAG_POOL) do
            current = current == "" and tostring(id) or (current .. "," .. id)
        end
        desc.HatAccessory = current
        pcall(function() hum:ApplyDescription(desc) end)
    end,

    gravitycoil = function(ctx, args)
        local InsertService = game:GetService("InsertService")
        local ok, model = pcall(function() return InsertService:LoadAsset(16688968) end)
        if not ok or not model then ctx.notify("gravitycoil: asset load failed", "error"); return end
        for _, t in ipairs(model:GetChildren()) do
            if t:IsA("Tool") then t.Parent = args.target.Backpack end
        end
        model:Destroy()
    end,

    removetools = function(ctx, args)
        for _, v in ipairs(args.target.Backpack:GetChildren()) do
            if v:IsA("Tool") then v:Destroy() end
        end
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Tool") then v:Destroy() end
            end
        end)
        local sg = args.target:FindFirstChildOfClass("StarterGear")
        if sg then
            for _, v in ipairs(sg:GetChildren()) do
                if v:IsA("Tool") then v:Destroy() end
            end
        end
        ctx.notify(("cleared all tools on %s"):format(args.target.Name), "success")
    end,

    startergive = function(ctx, args)
        local Tools = S.Tools; if not Tools then ctx.notify("Storage/Tools missing", "error"); return end
        local sg = args.target:FindFirstChildOfClass("StarterGear")
        if not sg then ctx.notify("startergive: target has no StarterGear", "error"); return end
        local name = tostring(args.name or ""):lower()
        for _, t in ipairs(Tools:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() == name then
                t:Clone().Parent = sg
                if args.target.Backpack then t:Clone().Parent = args.target.Backpack end
                ctx.notify(("%s added to %s's StarterGear"):format(t.Name, args.target.Name), "success")
                return
            end
        end
        ctx.notify(("startergive: '%s' not in Storage/Tools"):format(args.name or ""), "error")
    end,

    starterremove = function(ctx, args)
        local sg = args.target:FindFirstChildOfClass("StarterGear")
        if not sg then ctx.notify("starterremove: target has no StarterGear", "error"); return end
        local name = tostring(args.name or ""):lower()
        local n = 0
        for _, t in ipairs(sg:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() == name then t:Destroy(); n += 1 end
        end
        ctx.notify(("removed %d '%s' from StarterGear"):format(n, args.name or ""), n > 0 and "success" or "info")
    end,

    startertools = function(ctx, args)
        local Tools = S.Tools; if not Tools then ctx.notify("Storage/Tools missing", "error"); return end
        local sg = args.target:FindFirstChildOfClass("StarterGear")
        if not sg then ctx.notify("startertools: target has no StarterGear", "error"); return end
        local n = 0
        for _, t in ipairs(Tools:GetChildren()) do
            if t:IsA("Tool") then
                t:Clone().Parent = sg
                if args.target.Backpack then t:Clone().Parent = args.target.Backpack end
                n += 1
            end
        end
        ctx.notify(("gave %d starter tool(s) to %s"):format(n, args.target.Name), "success")
    end,

    tools = function(ctx)
        local Tools = S.Tools
        if not Tools then ctx.notify("Storage/Tools missing", "error"); return end
        local names = {}
        for _, t in ipairs(Tools:GetChildren()) do
            if t:IsA("Tool") then table.insert(names, t.Name) end
        end
        if #names == 0 then ctx.notify("Storage/Tools is empty", "info"); return end
        table.sort(names)
        ctx.notify(("Available tools (%d): %s"):format(#names, table.concat(names, ", ")), "info")
    end,
}
