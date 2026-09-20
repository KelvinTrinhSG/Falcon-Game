--!nocheck

local Sidebar = {}

local sidebarNameToPage = {
    HomeFrame      = "Home",
    PlayersFrame   = "Players",
    CommandsFrame  = "Commands",
    ServersFrame   = "Servers",
    ChatFrame      = "Chat",
    LogsFrame      = "Logs",
    AnalyticsFrame = "Analytics",
    SettingsFrame  = "Settings",
}

local INACTIVE_COLOR = Color3.fromRGB(104, 102, 103)

local activeColor = Color3.fromRGB(255, 255, 255)

local function applyActiveStyle(sidebarItem, active)
    local inner = sidebarItem:FindFirstChildWhichIsA("Frame")
    if not inner then return end
    inner.BackgroundTransparency = active and 0 or 1
    local stroke = inner:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Enabled = active end
    local color = active and activeColor or INACTIVE_COLOR
    local img = inner:FindFirstChildOfClass("ImageLabel")
    if img then img.ImageColor3 = color end
    local lbl = inner:FindFirstChildOfClass("TextLabel")
    if lbl then lbl.TextColor3 = color end
end

local function bindClickable(frame, fn)
    frame.Active = true
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            fn()
        end
    end)
end

function Sidebar.init(ctx)
    activeColor = ctx.Theme.primary
    ctx.Theme.changed.Event:Connect(function()
        activeColor = ctx.Theme.primary
        if ctx.state.currentPage then ctx.showOnly(ctx.state.currentPage) end
    end)

    function ctx.showOnly(pageName)
        ctx.state.currentPage = pageName
        for name, frame in pairs(ctx.pages) do
            frame.Visible = (name == pageName)
        end
        for _, child in ipairs(ctx.sidebarSF:GetChildren()) do
            if child:IsA("Frame") then
                applyActiveStyle(child, sidebarNameToPage[child.Name] == pageName)
            end
        end
        local hook = ctx.refreshHooks[pageName]
        if hook then hook() end
    end

    for _, child in ipairs(ctx.sidebarSF:GetChildren()) do
        if child:IsA("Frame") then
            local clickTarget = child:FindFirstChildWhichIsA("Frame") or child
            local pageName = sidebarNameToPage[child.Name]
            if pageName then
                child:SetAttribute("PageName", pageName)
                bindClickable(clickTarget, function() ctx.showOnly(pageName) end)
            end
        end
    end

    local box = ctx.searchFrame:FindFirstChild("SearchTextBox")
    if box then
        local function labelOf(item)
            local inner = item:FindFirstChildWhichIsA("Frame") or item
            local lbl = inner:FindFirstChild("TextLabel")
            return lbl and lbl.Text or item.Name
        end
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local q = (box.Text or ""):lower()
            for _, child in ipairs(ctx.sidebarSF:GetChildren()) do
                if child:IsA("Frame") then
                    child.Visible = (q == "") or (labelOf(child):lower():find(q, 1, true) ~= nil)
                end
            end
        end)
    end
end

return Sidebar
