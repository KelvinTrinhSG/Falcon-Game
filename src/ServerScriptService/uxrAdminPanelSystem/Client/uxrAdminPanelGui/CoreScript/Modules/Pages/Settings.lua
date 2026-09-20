--!nocheck

local Settings_Page = {}

local THEME_ATTR         = "uxrPanelTheme"
local HOTKEY_ATTR_PREFIX = "uxrHotkey_"

local function gui(ctx) return ctx.LocalPlayer:FindFirstChildOfClass("PlayerGui") end

local function loadTheme(ctx)
    local pg = gui(ctx); return pg and pg:GetAttribute(THEME_ATTR) or nil
end
local function saveTheme(ctx, name)
    local pg = gui(ctx); if pg then pg:SetAttribute(THEME_ATTR, name) end
end
local function loadHotkey(ctx, action)
    local pg = gui(ctx)
    local raw = pg and pg:GetAttribute(HOTKEY_ATTR_PREFIX .. action)
    if type(raw) ~= "string" or raw == "" then return nil end
    local out = {}
    for kc in raw:gmatch("[^,]+") do
        if Enum.KeyCode[kc] then table.insert(out, kc) end
    end
    return #out > 0 and out or nil
end
local function saveHotkey(ctx, action, names)
    local pg = gui(ctx); if not pg then return end
    pg:SetAttribute(HOTKEY_ATTR_PREFIX .. action,
        names and #names > 0 and table.concat(names, ",") or nil)
end

local function wireAppearance(ctx, sections)
    local Theme = ctx.Theme
    local card  = sections:FindFirstChild("AppearanceCard")
    if not card then return end
    local grid  = card:FindFirstChild("ThemeGrid")
    if not grid then return end

    local function refreshActive()
        local current = Theme.current()
        for _, swatch in ipairs(grid:GetChildren()) do
            if swatch:IsA("TextButton") then
                local active = (swatch.Name == current)
                local stroke = swatch:FindFirstChildOfClass("UIStroke")
                if stroke then
                    stroke.Thickness    = active and 2 or 1
                    stroke.Color        = active and Theme.white or Theme.gray8
                    stroke.Transparency = active and 0 or 0.4
                end
                local check = swatch:FindFirstChild("Check")
                if check then check.Visible = active end
            end
        end
    end

    for _, swatch in ipairs(grid:GetChildren()) do
        if swatch:IsA("TextButton") then
            swatch.MouseButton1Click:Connect(function()
                if Theme.set(swatch.Name) then
                    saveTheme(ctx, swatch.Name)
                    refreshActive()
                end
            end)
        end
    end

    refreshActive()
    Theme.changed.Event:Connect(refreshActive)
end

local function captureNextKey(ctx, onPick)
    local UIS = game:GetService("UserInputService")
    local conn
    local handle = ctx.Modal.custom({
        title = "Press any key",
        body  = "Tap the key you want to use. Modifier keys (Shift / Ctrl / Alt) and Esc are skipped.",
        kind  = "info",
        dismissable = true,
        buttons = {
            { text = "Cancel", onClick = function(h)
                if conn then conn:Disconnect() end
                h:close()
            end },
        },
    })
    conn = UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        local n = input.KeyCode.Name
        if input.KeyCode == Enum.KeyCode.Unknown then return end
        if n:match("Shift$") or n:match("Control$") or n:match("Alt$") or n == "Escape" then
            return
        end
        conn:Disconnect()
        handle:close()
        onPick(n)
    end)
end

local function wireHotkeyRow(ctx, row, action)
    if not row then return end
    local value  = row:FindFirstChild("ValueTextLabel")
    local rebind = row:FindFirstChild("Rebind")
    local reset  = row:FindFirstChild("Reset")
    if not (value and rebind and reset) then return end

    local function refresh()
        local names = loadHotkey(ctx, action)
        value.Text = names and table.concat(names, " · ") or "(default)"
    end

    rebind.MouseButton1Click:Connect(function()
        captureNextKey(ctx, function(kcName)
            saveHotkey(ctx, action, { kcName })
            refresh()
        end)
    end)
    reset.MouseButton1Click:Connect(function()
        saveHotkey(ctx, action, nil)
        refresh()
    end)

    refresh()
end

local function wireHotkeys(ctx, sections)
    local card = sections:FindFirstChild("HotkeysCard")
    if not card then return end
    wireHotkeyRow(ctx, card:FindFirstChild("PopupRow"), "popup")
    wireHotkeyRow(ctx, card:FindFirstChild("PanelRow"), "panel")
end

local function wireAbout(ctx, sections)
    local card = sections:FindFirstChild("AboutCard")
    if not card then return end
    local row = card:FindFirstChild("InfoRow")
    local rankLbl = row and row:FindFirstChild("RankTextLabel")
    if rankLbl and ctx.Ranks and ctx.Ranks.myRank then
        rankLbl.Text = ("Your rank: %s  ·  level %d"):format(
            ctx.Ranks.myRank.Name, ctx.Ranks.myRank.Level)
    end
end

function Settings_Page.init(ctx)
    local page = ctx.pages.Settings
    if not page then warn("[Settings] no SettingsFrame in pages"); return end
    local sections = page:FindFirstChild("SectionsScrollingFrame")
    if not sections then warn("[Settings] SectionsScrollingFrame missing"); return end

    local saved = loadTheme(ctx)
    if saved and ctx.Theme.themes[saved] then ctx.Theme.set(saved) end

    wireAppearance(ctx, sections)
    wireHotkeys   (ctx, sections)
    wireAbout     (ctx, sections)
end

return Settings_Page
