--!nocheck

local S = require(script.Parent._shared)
local Tools             = S.Tools
local PlayerDataManager = S.PlayerDataManager
local withCharacter, withHumanoid, ensureEffect, removeEffect =
    S.withCharacter, S.withHumanoid, S.ensureEffect, S.removeEffect

local NAMED_COLORS = {
    red = "#FF0000",   green   = "#00FF00", blue   = "#0000FF",
    yellow = "#FFFF00", cyan   = "#00FFFF", magenta = "#FF00FF",
    white = "#FFFFFF", black   = "#000000",
    orange = "#FF8C00", purple = "#800080", pink   = "#FFC0CB",
    brown = "#8B4513", gray    = "#808080", grey   = "#808080",
    teal  = "#1ABC9C", lime    = "#00FF00", navy   = "#000080",
}
local function parseColorInput(raw)
    if raw == nil then return nil end
    local s = tostring(raw):match("^%s*(.-)%s*$"):lower()
    if s == "" then return nil end
    if NAMED_COLORS[s] then return NAMED_COLORS[s] end
    local hex = s:match("^#?(%x%x%x%x%x%x)$")
    if hex then return "#" .. hex:upper() end
    return nil
end

local function toggleEffect(target, className, name)
    withCharacter(target, function(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp:FindFirstChild(name) then removeEffect(hrp, name)
        else ensureEffect(hrp, className, name) end
    end)
end

local function forceRemoveEffect(target, name, legacyClassName)
    withCharacter(target, function(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        removeEffect(hrp, name)
        if legacyClassName then
            for _, v in ipairs(hrp:GetChildren()) do
                if v:IsA(legacyClassName) then v:Destroy() end
            end
        end
    end)
end

local function applyAccessoryByDescription(target, assetId)
    if not assetId or assetId == 0 then return false end
    local char = target.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local desc = hum:GetAppliedDescription()
    local current = desc.HatAccessory or ""
    desc.HatAccessory = (current ~= "") and (current .. "," .. tostring(assetId)) or tostring(assetId)
    local ok, err = pcall(function() hum:ApplyDescription(desc) end)
    return ok, err
end

local function removeAccessoryByDescription(target, assetId)
    local char = target.Character; if not char then target:LoadCharacter(); return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then target:LoadCharacter(); return end
    local desc = hum:GetAppliedDescription()
    local kept = {}
    for id in tostring(desc.HatAccessory or ""):gmatch("[^,]+") do
        if tonumber(id) ~= assetId then table.insert(kept, id) end
    end
    desc.HatAccessory = table.concat(kept, ",")
    pcall(function() hum:ApplyDescription(desc) end)
end

local function applyBundleParts(target, bundleId, partFields)
    task.spawn(function()
        local char = target.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local ok, bundleDesc = pcall(function()
            return game.Players:GetHumanoidDescriptionFromBundleId(bundleId)
        end)
        if not ok or not bundleDesc then return end
        local cur = hum:GetAppliedDescription()
        for _, field in ipairs(partFields) do
            cur[field] = bundleDesc[field]
        end
        pcall(function() hum:ApplyDescription(cur) end)
    end)
end

local function setMaterialAndColor(target, material, color, transparency, dropClothes)
    withCharacter(target, function(char)
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("MeshPart") then
                v.Material = material
                if color then v.Color = color end
                if transparency then v.Transparency = transparency end
            end
            if dropClothes and (v:IsA("Shirt") or v:IsA("Pants")) then v:Destroy() end
        end
    end)
end

local BUNDLE_MORPHS = {
    Buff     = 594200,
    Chibi    = 6470,
    Frog     = 386731,
    Snowman  = 173035,
    Skeleton = 4778,
    Hamster  = 8232,
    Capybara = 295597,
    Penguin  = 319025,
    Duck     = 394166,
    Goose    = 310626,
}
local function applyBundleMorph(target, bundleId, notifyFn)
    local function fail(msg)
        warn(("[uxr] bundle %d: %s"):format(bundleId, msg))
        if notifyFn then notifyFn("bundle: "..msg, "error") end
    end
    task.spawn(function()
        local char = target.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return fail("target has no Humanoid") end

        local AES = game:GetService("AvatarEditorService")
        local ok, details = pcall(function()
            return AES:GetItemDetails(bundleId, Enum.AvatarItemType.Bundle)
        end)
        if not ok or type(details) ~= "table" then
            return fail("GetItemDetails: "..tostring(details))
        end

        local outfitId
        for _, item in ipairs(details.BundledItems or {}) do
            if item.Type == "UserOutfit" then outfitId = item.Id; break end
        end
        if not outfitId then return fail("no UserOutfit in BundledItems") end

        local ok2, bundleDesc = pcall(function()
            return game.Players:GetHumanoidDescriptionFromOutfitId(outfitId)
        end)
        if not ok2 or not bundleDesc then
            return fail("GetHumanoidDescriptionFromOutfitId: "..tostring(bundleDesc))
        end

        local ok3, err = pcall(function() hum:ApplyDescription(bundleDesc) end)
        if not ok3 then return fail("ApplyDescription: "..tostring(err)) end
        if notifyFn then notifyFn("bundle applied ("..(details.Name or bundleId)..")", "success") end
    end)
end

local function mulScale(hum, field, mult)
    local v = hum:FindFirstChild(field)
    if v then v.Value = v.Value * mult end
end

local nightVisionOn = {}
S.Players.PlayerRemoving:Connect(function(p) nightVisionOn[p.UserId] = nil end)

local module = {
    highlight = function(ctx, args)
        withCharacter(args.target, function(char)
            local existing = char:FindFirstChildOfClass("Highlight")
            if existing then existing:Destroy()
            else
                local h = Instance.new("Highlight")
                h.FillTransparency = 1
                h.Parent = char
            end
        end)
    end,
    unhighlight = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Highlight") then v:Destroy() end
            end
        end)
    end,

    shirt = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Shirt") then
                    v.ShirtTemplate = "http://www.roblox.com/asset/?id=" .. args.asset
                    break
                end
            end
        end)
    end,
    pants = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Pants") then
                    v.PantsTemplate = "http://www.roblox.com/asset/?id=" .. args.asset
                    break
                end
            end
        end)
    end,
    face = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            for _, v in ipairs(head:GetChildren()) do
                if v:IsA("Decal") then
                    v.Texture = "http://www.roblox.com/asset/?id=" .. args.asset
                    break
                end
            end
        end)
    end,

    bighead = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if head then head.Size = Vector3.new(args.size, args.size, args.size) end
        end)
    end,
    smallhead = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if head then head.Size = Vector3.new(args.size, args.size, args.size) end
        end)
    end,
    normalhead = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if head then head.Size = Vector3.new(1.2, 1.2, 1.2) end
        end)
    end,

    smoke   = function(ctx, args) toggleEffect(args.target, "Smoke",    "uxrSmoke")    end,
    fire    = function(ctx, args) toggleEffect(args.target, "Fire",     "uxrFire")     end,
    sparkles= function(ctx, args) toggleEffect(args.target, "Sparkles", "uxrSparkles") end,
    unsmoke   = function(ctx, args) forceRemoveEffect(args.target, "uxrSmoke",    "Smoke")    end,
    unfire    = function(ctx, args) forceRemoveEffect(args.target, "uxrFire",     "Fire")     end,
    unsparkles= function(ctx, args) forceRemoveEffect(args.target, "uxrSparkles", "Sparkles") end,

    size = function(ctx, args)
        withHumanoid(args.target, function(hum)
            mulScale(hum, "HeadScale",       args.scale)
            mulScale(hum, "BodyDepthScale",  args.scale)
            mulScale(hum, "BodyWidthScale",  args.scale)
            mulScale(hum, "BodyHeightScale", args.scale)
        end)
    end,
    height = function(ctx, args)
        withHumanoid(args.target, function(hum) mulScale(hum, "BodyHeightScale", args.scale) end)
    end,
    width = function(ctx, args)
        withHumanoid(args.target, function(hum) mulScale(hum, "BodyWidthScale", args.scale) end)
    end,
    giant = function(ctx, args)
        withHumanoid(args.target, function(hum)
            mulScale(hum, "HeadScale",       5)
            mulScale(hum, "BodyDepthScale",  5)
            mulScale(hum, "BodyWidthScale",  5)
            mulScale(hum, "BodyHeightScale", 5)
        end)
    end,
    dwarf = function(ctx, args)
        withHumanoid(args.target, function(hum)
            mulScale(hum, "HeadScale",       0.5)
            mulScale(hum, "BodyDepthScale",  0.5)
            mulScale(hum, "BodyWidthScale",  0.5)
            mulScale(hum, "BodyHeightScale", 0.5)
        end)
    end,
    fat = function(ctx, args)
        withHumanoid(args.target, function(hum)
            mulScale(hum, "BodyWidthScale", 1.75)
            mulScale(hum, "BodyDepthScale", 1.75)
        end)
    end,
    thin = function(ctx, args)
        withHumanoid(args.target, function(hum)
            mulScale(hum, "BodyWidthScale", 0.2)
            mulScale(hum, "BodyDepthScale", 0.2)
        end)
    end,

    changename = function(ctx, args)
        if not args.name then return end
        withHumanoid(args.target, function(hum) hum.DisplayName = args.name end)
    end,
    hidename = function(ctx, args)
        withHumanoid(args.target, function(hum)
            if hum.DisplayDistanceType == Enum.HumanoidDisplayDistanceType.None then
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            else
                hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            end
        end)
    end,
    showname = function(ctx, args)
        withHumanoid(args.target, function(hum)
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
        end)
    end,

    invisible = function(ctx, args)
        withCharacter(args.target, function(char)
            local invis = false
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("MeshPart") and v.Transparency >= 1 then invis = true; break end
            end
            local newT = invis and 0 or 1
            local emitters = not invis
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("MeshPart") then v.Transparency = newT end
                if v:FindFirstChild("Handle") then
                    v.Handle.Transparency = newT
                    for _, sub in ipairs(v:GetDescendants()) do
                        if sub:IsA("ParticleEmitter") then sub.Enabled = not emitters end
                    end
                end
            end
        end)
    end,
    visible = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("MeshPart") then v.Transparency = 0 end
                if v:FindFirstChild("Handle") then
                    v.Handle.Transparency = 0
                    for _, sub in ipairs(v:GetDescendants()) do
                        if sub:IsA("ParticleEmitter") then sub.Enabled = true end
                    end
                end
            end
        end)
    end,

    hideguis = function(ctx, args)
        local target = args.target
        local anyHidden = false
        for _, v in ipairs(target.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name ~= "Chat" and not v.Enabled then
                anyHidden = true; break
            end
        end
        local newState = anyHidden
        for _, v in ipairs(target.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name ~= "Chat" then v.Enabled = newState end
        end
    end,
    showguis = function(ctx, args)
        for _, v in ipairs(args.target.PlayerGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name ~= "Chat" then v.Enabled = true end
        end
    end,

    material = function(ctx, args)
        withCharacter(args.target, function(char)
            local function apply(part)
                if not part or not part:IsA("BasePart") then return end
                part.Material = args.material
                if part:IsA("MeshPart") then part.TextureID = "" end
            end
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    apply(v)
                elseif v:IsA("Accessory") then
                    apply(v:FindFirstChild("Handle"))
                end
            end
        end)
    end,
    gold  = function(ctx, args) setMaterialAndColor(args.target, Enum.Material.Metal, Color3.fromRGB(255, 255, 0), nil, true) end,
    neon  = function(ctx, args) setMaterialAndColor(args.target, Enum.Material.Neon,  Color3.fromRGB(255, 255, 255), nil, true) end,
    ghost = function(ctx, args) setMaterialAndColor(args.target, Enum.Material.Glass, Color3.fromRGB(255, 255, 255), 0.9, true) end,
    glass = function(ctx, args) setMaterialAndColor(args.target, Enum.Material.Glass, Color3.fromRGB(255, 255, 255), 0.4, true) end,
    ice   = function(ctx, args) setMaterialAndColor(args.target, Enum.Material.Ice,   Color3.fromRGB(0,   255, 255), 0.2, true) end,

    sword = function(ctx, args)
        local ok, err = S.giveTool(args.target, "Sword")
        if not ok then ctx.notify("sword: "..err, "error") end
    end,
    btools = function(ctx, args)
        local ok, err = S.giveTool(args.target, "Building Tools")
        if not ok then ctx.notify("btools: "..err, "error") end
    end,

    spin = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            local s = head:FindFirstChild("Spin1")
            if s then s:Destroy(); return end
            s = Instance.new("BodyAngularVelocity")
            s.MaxTorque = Vector3.new(300000, 300000, 300000)
            s.P = 300
            s.Name = "Spin1"
            s.Parent = head
            s.AngularVelocity = Vector3.new(0, args.rate, 0)
        end)
    end,
    unspin = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if head and head:FindFirstChild("Spin1") then head.Spin1:Destroy() end
        end)
    end,

    fart = function(ctx, args)
        withCharacter(args.target, function(char)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local s1 = Instance.new("Smoke"); s1.Opacity = 0.1; s1.Color = Color3.fromRGB(102, 255, 51); s1.Parent = hrp
            local s2 = Instance.new("Smoke"); s2.Opacity = 0.3; s2.Color = Color3.fromRGB(51, 205, 51);  s2.Parent = hrp
            task.delay(0.9, function() s1.Enabled = false; s2.Enabled = false end)
            task.delay(5.9, function() s1:Destroy(); s2:Destroy() end)
        end)
    end,

    clearhats = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Accessory") and v.AccessoryType == Enum.AccessoryType.Hat then v:Destroy() end
            end
        end)
    end,

    disco = function(ctx)
        local sd = PlayerDataManager.GiveServerData(PlayerDataManager)
        if sd.Disco then
            game.Lighting.Ambient = sd.AmbientDefault
            PlayerDataManager.EditServerData("Disco", false)
            return
        end
        task.spawn(function()
            PlayerDataManager.EditServerData("Disco", true)
            while PlayerDataManager.GiveServerData(PlayerDataManager).Disco do
                game.Lighting.Ambient = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
                task.wait(0.3)
            end
        end)
    end,
    undisco = function(ctx)
        game.Lighting.Ambient = PlayerDataManager.GiveServerData(PlayerDataManager).AmbientDefault
        PlayerDataManager.EditServerData("Disco", false)
    end,
    skybox = function(ctx)
        ctx.apEvents.RemoteEvent:FireClient(ctx.actor, "openSkyboxPicker")
    end,

    grayscale = function() local fx = ensureEffect(game.Lighting, "ColorCorrectionEffect", "uxrCorrection"); fx.Saturation = -1; fx.Contrast = 0; fx.TintColor = Color3.fromRGB(255,255,255) end,
    saturate  = function() local fx = ensureEffect(game.Lighting, "ColorCorrectionEffect", "uxrCorrection"); fx.Saturation = 1.5 end,
    contrast  = function() local fx = ensureEffect(game.Lighting, "ColorCorrectionEffect", "uxrCorrection"); fx.Contrast = 1.0 end,
    inverted  = function() local fx = ensureEffect(game.Lighting, "ColorCorrectionEffect", "uxrCorrection"); fx.Brightness = -1 end,
    tint = function(ctx, args)
        local fx = ensureEffect(game.Lighting, "ColorCorrectionEffect", "uxrCorrection")
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
        if not c then ctx.notify("tint: expected 'r,g,b' or '#hex'", "error"); return end
        fx.TintColor = c
    end,
    unvisuals = function()
        removeEffect(game.Lighting, "uxrCorrection")
        for _, v in ipairs(game.Lighting:GetChildren()) do
            if v.Name == "uxrCorrection" or v.Name == "uxrBlur" then v:Destroy() end
        end
    end,

    color = function(ctx, args)
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
        if not c then ctx.notify("color: expected 'r,g,b' or '#hex'", "error"); return end
        S.forEachBasePart(args.target, function(p) p.Color = c end)
    end,
    reflectance = function(ctx, args)
        local v = math.clamp(tonumber(args.amount) or 0, 0, 1)
        S.forEachBasePart(args.target, function(p)
            p.Reflectance = v
            if v > 0 and p:IsA("MeshPart") then p.TextureID = "" end
        end)
    end,
    transparency = function(ctx, args)
        local v = math.clamp(tonumber(args.amount) or 0, 0, 1)
        S.forEachBasePart(args.target, function(p)
            if p.Name ~= "HumanoidRootPart" then p.Transparency = v end
        end)
    end,

    headsize = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local v = hum:FindFirstChild("HeadScale")
            if v then v.Value = math.clamp(tonumber(args.scale) or 1, 0.1, 10) end
        end)
    end,
    hipheight = function(ctx, args)
        withHumanoid(args.target, function(hum)
            hum.HipHeight = math.clamp(tonumber(args.scale) or 2, 0, 50)
        end)
    end,
    bodytype = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local v = hum:FindFirstChild("BodyTypeScale")
            if v then v.Value = math.clamp(tonumber(args.scale) or 0, 0, 1) end
        end)
    end,
    depth = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local v = hum:FindFirstChild("BodyDepthScale")
            if v then v.Value = math.clamp(tonumber(args.scale) or 1, 0.1, 10) end
        end)
    end,
    proportion = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local v = hum:FindFirstChild("BodyProportionScale")
            if v then v.Value = math.clamp(tonumber(args.scale) or 0, 0, 1) end
        end)
    end,
    squash = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local h = hum:FindFirstChild("BodyHeightScale")
            local w = hum:FindFirstChild("BodyWidthScale")
            local amt = math.clamp(tonumber(args.scale) or 0.5, 0.1, 1)
            if h then h.Value = amt end
            if w then w.Value = 2 - amt end
        end)
    end,

    glitch = function(ctx, args)
        withCharacter(args.target, function(char)
            if char:FindFirstChild("uxrGlitching") then
                removeEffect(char, "uxrGlitching")
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Transparency = (p.Name == "HumanoidRootPart") and 1 or 0
                        p.Reflectance = 0
                    end
                end
                return
            end
            local marker = ensureEffect(char, "BoolValue", "uxrGlitching")
            marker.Value = true
            task.spawn(function()
                while marker.Parent and marker.Value do
                    for _, p in ipairs(char:GetDescendants()) do
                        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                            p.Transparency = math.random() * 0.7
                            p.Reflectance  = math.random()
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end)
    end,
    unglitch = function(ctx, args)
        withCharacter(args.target, function(char)
            removeEffect(char, "uxrGlitching")
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.Transparency = (p.Name == "HumanoidRootPart") and 1 or 0
                    p.Reflectance = 0
                end
            end
        end)
    end,

    title = function(ctx, args)
        local text = tostring(args.text or "")
        local function attach(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            local old = head:FindFirstChild("uxrTitle")
            if old then old:Destroy() end
            local bb = Instance.new("BillboardGui")
            bb.Name = "uxrTitle"; bb.Adornee = head
            bb.Size = UDim2.fromOffset(220, 28); bb.StudsOffset = Vector3.new(0, 3.5, 0)
            bb.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size = UDim2.fromScale(1, 1); lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 16
            lbl.TextColor3 = Color3.fromRGB(255, 220, 100)
            lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            lbl.Text = text
            bb.Parent = head
        end
        local player = args.target
        withCharacter(player, attach)
        player:SetAttribute("uxrTitleText", text)
        if not player:GetAttribute("uxrTitleHooked") then
            player:SetAttribute("uxrTitleHooked", true)
            player.CharacterAdded:Connect(function(char)
                local t = player:GetAttribute("uxrTitleText")
                if t and t ~= "" then task.wait(0.2); attach(char) end
            end)
        end
    end,
    untitle = function(ctx, args)
        args.target:SetAttribute("uxrTitleText", nil)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if head then local old = head:FindFirstChild("uxrTitle"); if old then old:Destroy() end end
        end)
    end,

    ragdoll = function(ctx, args)
        withCharacter(args.target, function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end
            for _, m in ipairs(char:GetDescendants()) do
                if m:IsA("Motor6D") then
                    local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
                    a0.CFrame = m.C0; a1.CFrame = m.C1
                    a0.Parent = m.Part0; a1.Parent = m.Part1
                    local socket = Instance.new("BallSocketConstraint")
                    socket.Attachment0 = a0; socket.Attachment1 = a1
                    socket.Parent = m.Parent
                    m:Destroy()
                end
            end
        end)
    end,
    unragdoll = function(ctx, args)
        args.target:LoadCharacter()
    end,

    playerlist  = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "PlayerList",   args.state) end,
    backpack    = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "Backpack",     args.state) end,
    emotesmenu  = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "EmotesMenu",   args.state) end,
    chatwindow  = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "Chat",         args.state) end,
    healthbar   = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "Health",       args.state) end,
    captures    = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "Captures",     args.state) end,
    selfview    = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setCoreGui", "SelfView",     args.state) end,
    resetbutton = function(ctx, args) ctx.apEvents.RemoteEvent:FireClient(args.target, "setResetButton", args.state) end,

    talk = function(ctx, args)
        local text = tostring(args.text or ""):gsub("[<>]", "")
        if text == "" then return end
        ctx.apEvents.RemoteEvent:FireAllClients("systemMessage",
            ("[%s] %s"):format(args.target.DisplayName, text))
    end,
    bubblechat = function(ctx, args)
        ctx.apEvents.RemoteEvent:FireClient(args.target, "bubbleChat", tostring(args.text or ""))
    end,

    korblox = function(ctx, args)
        local target = args.target
        local char = target.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then ctx.notify("korblox: no humanoid", "error"); return end
        if hum.RigType ~= Enum.HumanoidRigType.R15 then
            ctx.notify("korblox: target must be R15 (Game Settings → R15)", "error"); return
        end
        local desc = hum:GetAppliedDescription()
        desc.RightLeg = 139607718
        local ok, err = pcall(function() hum:ApplyDescription(desc) end)
        if ok then ctx.notify("korblox applied to "..target.Name, "success")
        else ctx.notify("korblox: "..tostring(err), "error") end
    end,
    unkorblox = function(ctx, args)
        withCharacter(args.target, function(char)
            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local desc = hum:GetAppliedDescription()
            desc.RightLeg = 0
            pcall(function() hum:ApplyDescription(desc) end)
        end)
    end,
    dominus = function(ctx, args)
        local ok, err = applyAccessoryByDescription(args.target, 21070012)
        if ok then ctx.notify("dominus applied to "..args.target.Name, "success")
        else ctx.notify("dominus: "..tostring(err), "error") end
    end,
    undominus  = function(ctx, args) removeAccessoryByDescription(args.target, 21070012) end,

    headless = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            head.Transparency = 1
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") then d.Transparency = 1 end
            end
        end)
    end,
    unheadless = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            head.Transparency = 0
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") then d.Transparency = 0 end
            end
        end)
    end,

    clearaccessory = function(ctx, args)
        withCharacter(args.target, function(char)
            for _, a in ipairs(char:GetChildren()) do
                if a:IsA("Accessory") then a:Destroy() end
            end
        end)
    end,
    accessory = function(ctx, args)
        local ok = applyAccessoryByDescription(args.target, tonumber(args.assetId))
        if not ok then ctx.notify("accessory: ApplyDescription failed", "error") end
    end,
    clearfaces = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") then d:Destroy() end
            end
        end)
    end,

    character = function(ctx, args)
        task.spawn(function()
            local username = tostring(args.username or "")
            local ok, userId = pcall(function() return game.Players:GetUserIdFromNameAsync(username) end)
            if not ok or not userId then ctx.notify("character: user not found", "error"); return end
            local hum = args.target.Character and args.target.Character:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            local ok2, desc = pcall(function() return game.Players:GetHumanoidDescriptionFromUserId(userId) end)
            if ok2 and desc then pcall(function() hum:ApplyDescription(desc) end) end
        end)
    end,
    uncharacter = function(ctx, args) args.target:LoadCharacter() end,

    unbundle = function(ctx, args) args.target:LoadCharacter() end,

    unsize     = function(ctx, args) withHumanoid(args.target, function(hum) for _, n in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}) do local v = hum:FindFirstChild(n); if v then v.Value = 1 end end end) end,
    undwarf    = function(ctx, args) withHumanoid(args.target, function(hum) for _, n in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}) do local v = hum:FindFirstChild(n); if v then v.Value = 1 end end end) end,
    ungiant    = function(ctx, args) withHumanoid(args.target, function(hum) for _, n in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}) do local v = hum:FindFirstChild(n); if v then v.Value = 1 end end end) end,
    unbodytype = function(ctx, args) withHumanoid(args.target, function(hum) local v = hum:FindFirstChild("BodyTypeScale"); if v then v.Value = 0 end end) end,
    undepth    = function(ctx, args) withHumanoid(args.target, function(hum) local v = hum:FindFirstChild("BodyDepthScale"); if v then v.Value = 1 end end) end,
    unsquash   = function(ctx, args) withHumanoid(args.target, function(hum) local h = hum:FindFirstChild("BodyHeightScale"); local w = hum:FindFirstChild("BodyWidthScale"); if h then h.Value = 1 end; if w then w.Value = 1 end end) end,
    unwidth    = function(ctx, args) withHumanoid(args.target, function(hum) local v = hum:FindFirstChild("BodyWidthScale"); if v then v.Value = 1 end end) end,
    unheight   = function(ctx, args) withHumanoid(args.target, function(hum) local v = hum:FindFirstChild("BodyHeightScale"); if v then v.Value = 1 end end) end,
    unfat      = function(ctx, args) withHumanoid(args.target, function(hum) local w = hum:FindFirstChild("BodyWidthScale"); local d = hum:FindFirstChild("BodyDepthScale"); if w then w.Value = 1 end; if d then d.Value = 1 end end) end,
    unthin     = function(ctx, args) withHumanoid(args.target, function(hum) local w = hum:FindFirstChild("BodyWidthScale"); local d = hum:FindFirstChild("BodyDepthScale"); if w then w.Value = 1 end; if d then d.Value = 1 end end) end,
    unbighead  = function(ctx, args) withCharacter(args.target, function(char) local h = char:FindFirstChild("Head"); if h then h.Size = Vector3.new(2, 1, 1) end end) end,

    shine = function(ctx, args)
        S.forEachBasePart(args.target, function(p)
            p.Material = Enum.Material.Neon
            p.Reflectance = 0.9
            if p:IsA("MeshPart") then p.TextureID = "" end
        end)
    end,

    head = function(ctx, args)
        applyAccessoryByDescription(args.target, tonumber(args.assetId))
    end,

    potatoHead = function(ctx, args)
        withCharacter(args.target, function(char)
            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local desc = hum:GetAppliedDescription()
            desc.Head = 152611565
            pcall(function() hum:ApplyDescription(desc) end)
        end)
    end,

    giantDwarf = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local rnd = 0.5 + math.random() * 4.5
            for _, n in ipairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}) do
                local v = hum:FindFirstChild(n); if v then v.Value = rnd end
            end
        end)
    end,

    boost = function(ctx, args)
        withHumanoid(args.target, function(hum)
            hum.WalkSpeed = 50
            hum.JumpHeight = 20
        end)
    end,

    chatTag = function(ctx, args)
        local ok, why = S.UtilModule:CanActOn(args.target, "Configurable")
        if not ok then ctx.notify(why or "target is config-immune", "error"); return end
        local tag = tostring(args.tag or ""):gsub("[<>\"'&]", ""):sub(1, 24)
        args.target:SetAttribute("uxrChatTag", tag)
        ctx.notify(("%s tag set to [%s]"):format(args.target.Name, tag), "success")
    end,
    chatTagColor = function(ctx, args)
        local ok, why = S.UtilModule:CanActOn(args.target, "Configurable")
        if not ok then ctx.notify(why or "target is config-immune", "error"); return end
        local color = parseColorInput(args.color)
        if not color then
            ctx.notify(("invalid color: %s (use #RRGGBB or a named color)"):format(tostring(args.color or "")), "error")
            return
        end
        args.target:SetAttribute("uxrChatTagColor", color)
        ctx.notify(("%s tag color set to %s"):format(args.target.Name, color), "success")
    end,
    chatName = function(ctx, args)
        local ok, why = S.UtilModule:CanActOn(args.target, "Configurable")
        if not ok then ctx.notify(why or "target is config-immune", "error"); return end
        local name = tostring(args.name or args.target.Name):gsub("[<>\"'&]", ""):sub(1, 32)
        args.target:SetAttribute("uxrChatName", name)
        ctx.notify(("%s chat name set to '%s'"):format(args.target.Name, name), "success")
    end,
    chatNameColor = function(ctx, args)
        local ok, why = S.UtilModule:CanActOn(args.target, "Configurable")
        if not ok then ctx.notify(why or "target is config-immune", "error"); return end
        local color = parseColorInput(args.color)
        if not color then
            ctx.notify(("invalid color: %s (use #RRGGBB or a named color)"):format(tostring(args.color or "")), "error")
            return
        end
        args.target:SetAttribute("uxrChatNameColor", color)
        ctx.notify(("%s name color set to %s"):format(args.target.Name, color), "success")
    end,

    nightVision = function(ctx, args)
        local on = not nightVisionOn[args.target.UserId]
        nightVisionOn[args.target.UserId] = on or nil
        S.apEvents.RemoteEvent:FireClient(args.target, "setNightVision", on)
    end,
    unNightVision = function(ctx, args)
        nightVisionOn[args.target.UserId] = nil
        S.apEvents.RemoteEvent:FireClient(args.target, "setNightVision", false)
    end,

    laserEyes = function(ctx, args)
        withCharacter(args.target, function(char)
            local head = char:FindFirstChild("Head")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not (head and hum) then return end

            for _, inst in ipairs(char:GetDescendants()) do
                if inst:GetAttribute("uxrLaser") then inst:Destroy() end
            end

            local color = Color3.fromRGB(255, 30, 30)
            local hex = args.color and parseColorInput(args.color)
            if hex then
                color = Color3.fromRGB(
                    tonumber(hex:sub(2, 3), 16),
                    tonumber(hex:sub(4, 5), 16),
                    tonumber(hex:sub(6, 7), 16))
            end

            local target = Instance.new("Part")
            target.Name = "uxrLaserTarget"
            target.Size = Vector3.new(0.2, 0.2, 0.2)
            target.Transparency = 1
            target.CanCollide = false
            target.Anchored = true
            target.Massless = true
            target.Color = color
            target.CFrame = head.CFrame * CFrame.new(0, 0, -5)
            target:SetAttribute("uxrLaser", true)
            target.Parent = char

            local function makeAtt(parent, name, offset)
                local a = Instance.new("Attachment")
                a.Name = name
                a.Position = offset
                a:SetAttribute("uxrLaser", true)
                a.Parent = parent
                return a
            end
            local headL = makeAtt(head,   "uxrLaser_HeadL", Vector3.new(-0.15, 0.15, -0.5))
            local headR = makeAtt(head,   "uxrLaser_HeadR", Vector3.new( 0.15, 0.15, -0.5))
            local tgtL  = makeAtt(target, "uxrLaser_TgtL",  Vector3.new(-0.05, 0,    0))
            local tgtR  = makeAtt(target, "uxrLaser_TgtR",  Vector3.new( 0.05, 0,    0))
            local tgtM  = makeAtt(target, "uxrLaser_Mid",   Vector3.new( 0,    0,    0))

            local function makeBeam(name, a0, a1)
                local beam = Instance.new("Beam")
                beam.Name = name
                beam.Attachment0 = a0
                beam.Attachment1 = a1
                beam.Width0 = 0.18
                beam.Width1 = 0.18
                beam.LightEmission = 1
                beam.LightInfluence = 0
                beam.FaceCamera = true
                beam.Color = ColorSequence.new(color)
                beam.Enabled = false
                beam:SetAttribute("uxrLaser", true)
                beam.Parent = head
                return beam
            end
            makeBeam("uxrLaserLeftBeam",  headL, tgtL)
            makeBeam("uxrLaserRightBeam", headR, tgtR)

            local function makeParticle(name, opts)
                local p = Instance.new("ParticleEmitter")
                p.Name = name
                p.Color = ColorSequence.new(color)
                p.LightEmission = 1
                p.LightInfluence = 0
                p.Lifetime = opts.lifetime
                p.Rate = opts.rate
                p.Speed = opts.speed
                p.SpreadAngle = Vector2.new(180, 180)
                p.Size = opts.size
                p.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,    0),
                    NumberSequenceKeypoint.new(0.85, 0),
                    NumberSequenceKeypoint.new(1,    1),
                })
                p.Enabled = false
                p:SetAttribute("uxrLaser", true)
                p.Parent = tgtM
                return p
            end
            makeParticle("uxrLaserSparks", {
                lifetime = NumberRange.new(0.3, 0.7),
                rate     = 40,
                speed    = NumberRange.new(6, 14),
                size     = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.25),
                    NumberSequenceKeypoint.new(1, 0),
                }),
            })
            makeParticle("uxrLaserGlow", {
                lifetime = NumberRange.new(0.5, 1.0),
                rate     = 18,
                speed    = NumberRange.new(0.5, 2),
                size     = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1.2),
                    NumberSequenceKeypoint.new(1, 0),
                }),
            })

            S.apEvents.RemoteEvent:FireClient(args.target, "setLaserEyes", true, color)
        end)
    end,
    unLaserEyes = function(ctx, args)
        S.apEvents.RemoteEvent:FireClient(args.target, "setLaserEyes", false)
        withCharacter(args.target, function(char)
            for _, inst in ipairs(char:GetDescendants()) do
                if inst:GetAttribute("uxrLaser") then inst:Destroy() end
            end
        end)
    end,

    danceAndBundleReset = function(ctx, args)
        if args.target and args.target.Parent then
            args.target:LoadCharacter()
        end
    end,

    emote = function(ctx, args)
        withHumanoid(args.target, function(hum)
            local raw = tostring(args.emote or "")
            if raw == "" then ctx.notify("emote: missing name/id", "error"); return end
            local asNum = tonumber(raw)
            if asNum then
                local animator = hum:FindFirstChildOfClass("Animator")
                if not animator then ctx.notify("emote: target has no Animator", "error"); return end
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. asNum
                local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
                if not ok or not track then
                    ctx.notify(("emote: id %d failed to load"):format(asNum), "error"); return
                end
                track.Priority = Enum.AnimationPriority.Action
                track:Play()
            else
                local ok, played = pcall(hum.PlayEmote, hum, raw)
                if not ok or played == false then
                    ctx.notify(("emote: '%s' not equipped"):format(raw), "error")
                end
            end
        end)
    end,

}

for name, bundleId in pairs(BUNDLE_MORPHS) do
    local id = bundleId
    module[name:lower()] = function(ctx, args)
        applyBundleMorph(args.target, id, ctx.notify)
    end
end

module.bundle = function(ctx, args)
    local id = tonumber(args.bundleId)
    if not id then ctx.notify("bundle: invalid bundleId", "error"); return end
    applyBundleMorph(args.target, id, ctx.notify)
end

return module
