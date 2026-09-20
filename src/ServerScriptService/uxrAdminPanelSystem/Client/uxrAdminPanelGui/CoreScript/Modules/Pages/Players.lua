--!nocheck

local Players_Page = {}

function Players_Page.init(ctx)
    local Players      = ctx.Players
    local Format       = ctx.Format
    local Templates    = ctx.Templates
    local commandFrame = ctx.commandFrame
    local StatsHelpers = require(script.Parent.Parent.Stats)

    local pf = ctx.pages.Players

    local function updatePlayersStats()
        StatsHelpers.setStat(pf:FindFirstChild("PlayersFrame"), "Players",
            Format.fmtColoredNumber(#Players:GetPlayers(), "#3498DB"), true)
        StatsHelpers.setStat(pf:FindFirstChild("AdminsFrame"), "Admins",
            Format.fmtColoredNumber(StatsHelpers.countAdmins(ctx), "#E74C3C"), true)
        StatsHelpers.setStat(pf:FindFirstChild("MaxPlayerFrame"), "Max Players",
            Format.fmtColoredNumber(Players.MaxPlayers, "#F1C40F"), true)
    end

    local playerListSF = pf.PlayerListFrame:FindFirstChildWhichIsA("ScrollingFrame")

    local rowByUserId = {}

    local function fillRow(row, p)
        local img = row:FindFirstChild("UserImage")
        if img then img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=150&h=150" end

        Templates.safeText(row, "DisplayNameLabel", p.DisplayName)
        Templates.safeText(row, "UserNameLabel", "@" .. p.Name)

        local manage = row:FindFirstChild("ManageFrame")
        if manage then Templates.safeText(manage, "TextLabel", "Manage") end
    end

    local function addRow(p)
        if rowByUserId[p.UserId] then return end
        local row = Templates.cloneTemplate(playerListSF)
        if not row then return end
        row.Name = tostring(p.UserId)
        fillRow(row, p)

        local btn = row:FindFirstChild("ClickButton")
        if btn then
            btn.MouseButton1Click:Connect(function()
                if ctx.PlayerProfile then
                    ctx.PlayerProfile.open(p.Name)
                else
                    ctx.state.selectedTarget = p.Name
                    ctx.togglePopup(true)
                    local box = commandFrame.SearchFrame.SearchTextBox
                    box.Text = ""
                    box:CaptureFocus()
                end
            end)
        end

        rowByUserId[p.UserId] = row
    end

    local function removeRow(userId)
        local row = rowByUserId[userId]
        if row then
            row:Destroy()
            rowByUserId[userId] = nil
        end
    end

    local function applyFilter(filter)
        filter = (filter or ""):lower()
        for _, p in ipairs(Players:GetPlayers()) do
            local row = rowByUserId[p.UserId]
            if row then
                row.Visible = (filter == "")
                    or p.Name:lower():find(filter, 1, true) ~= nil
                    or p.DisplayName:lower():find(filter, 1, true) ~= nil
            end
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        addRow(p)
    end
    updatePlayersStats()

    pf.SearchFrame.SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        applyFilter(pf.SearchFrame.SearchTextBox.Text)
    end)

    Players.PlayerAdded:Connect(function(p)
        addRow(p)
        applyFilter(pf.SearchFrame.SearchTextBox.Text)
        updatePlayersStats()
    end)
    Players.PlayerRemoving:Connect(function(p)
        removeRow(p.UserId)
        updatePlayersStats()
    end)

    ctx.refreshHooks.Players = function()
        updatePlayersStats()
        applyFilter(pf.SearchFrame.SearchTextBox.Text)
    end
end

return Players_Page
