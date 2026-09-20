--!nocheck

local RoleInfo = {}

local FLAG_LABELS = {
    Bannable     = "Ban",
    Kickable     = "Kick",
    Mutable      = "Mute",
    Jailable     = "Jail",
    Warnable     = "Warn",
    Killable     = "Kill",
    Configurable = "Config",
}

function RoleInfo.init(ctx)
    local Modal       = ctx.Modal
    local make        = Modal._make
    local C           = Modal._theme()
    local Permissions = ctx.Permissions
    local Commands    = ctx.Commands

    local function hexToColor3(hex)
        local cleaned = (hex or "#888888"):gsub("^#", "")
        local ok, c3 = pcall(Color3.fromHex, cleaned)
        return ok and c3 or Color3.fromRGB(136, 136, 136)
    end

    local function countCommandsForRank(rank)
        local count = 0
        for _, cmd in pairs(Commands) do
            local perm = cmd.Permission or cmd.CommandPermission
            if perm then
                local names = type(perm) == "table" and perm or { perm }
                for _, name in ipairs(names) do
                    for _, r in ipairs(Permissions.Ranks) do
                        if r.Name == name and rank.Level >= r.Level then
                            count += 1; break
                        end
                    end
                end
            end
        end
        return count
    end

    local function summarizeAssignment(rankName)
        local a = Permissions.Assignments[rankName]
        if not a then return "(no assignments)" end
        local parts = {}
        if a.Players    and #a.Players    > 0 then table.insert(parts, ("%d player(s)"):format(#a.Players)) end
        if a.Gamepasses and #a.Gamepasses > 0 then table.insert(parts, ("%d gamepass(es)"):format(#a.Gamepasses)) end
        if a.Assets     and #a.Assets     > 0 then table.insert(parts, ("%d asset(s)"):format(#a.Assets)) end
        if a.Groups     and #a.Groups     > 0 then table.insert(parts, ("%d group(s)"):format(#a.Groups)) end
        if a.Teams      and #a.Teams      > 0 then table.insert(parts, ("%d team(s)"):format(#a.Teams)) end
        if #parts == 0 then return "(no members)" end
        return table.concat(parts, "  ·  ")
    end

    local function buildFlagBadges(flags)
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })
        local i = 0
        for flagName, value in pairs(flags or {}) do
            if value == false then
                i += 1
                local pill = make("Frame", {
                    Size = UDim2.fromOffset(0, 18),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = C.gray5, BorderSizePixel = 0,
                    LayoutOrder = i, Parent = row,
                }, {
                    make("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    make("UIPadding", {
                        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
                    }),
                })
                make("TextLabel", {
                    Size = UDim2.fromOffset(0, 18),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium, TextSize = 10,
                    TextColor3 = C.gray11,
                    Text = (FLAG_LABELS[flagName] or flagName) .. " immune",
                    Parent = pill,
                })
            end
        end
        return row, i
    end

    function RoleInfo.openRank(rankName)
        local rank
        for _, r in ipairs(Permissions.Ranks) do
            if r.Name == rankName then rank = r; break end
        end
        if not rank then return end

        local byCat = {}
        for name, cmd in pairs(Commands) do
            local perm = cmd.Permission or cmd.CommandPermission
            if perm then
                local names = type(perm) == "table" and perm or { perm }
                local allowed = false
                for _, pname in ipairs(names) do
                    for _, r in ipairs(Permissions.Ranks) do
                        if r.Name == pname and rank.Level >= r.Level then
                            allowed = true; break
                        end
                    end
                    if allowed then break end
                end
                if allowed then
                    local cat = cmd.Category or "Other"
                    byCat[cat] = byCat[cat] or {}
                    table.insert(byCat[cat], name)
                end
            end
        end

        local cats = {}
        for k in pairs(byCat) do table.insert(cats, k) end
        table.sort(cats)

        local stack = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

        for i, cat in ipairs(cats) do
            local names = byCat[cat]
            table.sort(names)
            local section = make("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = i, Parent = stack,
            }, { make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }) })
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 16),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold, TextSize = 11,
                TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = cat:upper() .. ("  (%d)"):format(#names),
                LayoutOrder = 0, Parent = section,
            })
            for j, n in ipairs(names) do
                make("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Code, TextSize = 11,
                    TextColor3 = C.white,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = "  " .. n,
                    LayoutOrder = j, Parent = section,
                })
            end
        end

        Modal.custom({
            title = ("[%s] — %d commands"):format(rank.DisplayName or rank.Name, countCommandsForRank(rank)),
            body = nil,
            width = 460,
            kind = "info",
            dismissable = true,
            bodyChildren = { stack },
            buttons = {
                { text = "Back", onClick = function(h) h:close(); RoleInfo.open() end },
                { text = "Close", onClick = function(h) h:close() end },
            },
        })
    end

    function RoleInfo.open()
        local stack = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

        for i, rank in ipairs(Permissions.Ranks) do
            local color = hexToColor3(rank.Color)
            local card = make("Frame", {
                Size = UDim2.new(1, 0, 0, 72),
                BackgroundColor3 = C.gray3, BorderSizePixel = 0,
                LayoutOrder = i, Parent = stack,
            }, {
                make("UICorner", { CornerRadius = UDim.new(0, 8) }),
                make("UIStroke", { Color = color, Thickness = 1, Transparency = 0.5 }),
            })

            local stripe = make("Frame", {
                Size = UDim2.new(0, 4, 1, -3),
                Position = UDim2.fromOffset(0, 1.5),
                BackgroundColor3 = color, BorderSizePixel = 0,
                Parent = card,
            }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })

            make("TextLabel", {
                Position = UDim2.fromOffset(14, 8),
                Size = UDim2.new(1, -28, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold, TextSize = 14,
                TextColor3 = C.white,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = ("[%s]  ·  Level %d  ·  %d commands"):format(
                    rank.DisplayName or rank.Name, rank.Level, countCommandsForRank(rank)),
                Parent = card,
            })
            make("TextLabel", {
                Position = UDim2.fromOffset(14, 28),
                Size = UDim2.new(1, -28, 0, 14),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Members: " .. summarizeAssignment(rank.Name),
                Parent = card,
            })

            local flagsRow, flagCount = buildFlagBadges(rank.Flags)
            flagsRow.Position = UDim2.fromOffset(14, 46)
            flagsRow.Size = UDim2.new(1, -28, 0, 18)
            flagsRow.Parent = card
            if flagCount == 0 then
                make("TextLabel", {
                    Position = UDim2.fromOffset(14, 46),
                    Size = UDim2.new(1, -28, 0, 14),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham, TextSize = 10,
                    TextColor3 = C.gray11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = "(no immunity flags)",
                    Parent = card,
                })
            end

            local hit = make("TextButton", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                Text = "", AutoButtonColor = false, Parent = card,
            })
            hit.MouseButton1Click:Connect(function()
                if Modal.closeAll then Modal.closeAll() end
                RoleInfo.openRank(rank.Name)
            end)
        end

        Modal.custom({
            title = "Roles",
            body = nil,
            width = 500,
            kind = "info",
            dismissable = true,
            bodyChildren = { stack },
            buttons = {
                { text = "Close", onClick = function(h) h:close() end },
            },
        })
    end

    ctx.RoleInfo = RoleInfo
    return RoleInfo
end

return RoleInfo
