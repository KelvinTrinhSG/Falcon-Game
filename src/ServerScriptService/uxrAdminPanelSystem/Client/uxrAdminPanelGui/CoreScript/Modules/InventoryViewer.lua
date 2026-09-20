--!nocheck

local InventoryViewer = {}

function InventoryViewer.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()
    local Rfunc = ctx.RemoteFunction

    local function buildRow(text, layoutOrder, removeFn)
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
        })
        make("TextLabel", {
            Size = UDim2.new(1, -56, 1, 0), Position = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.white,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = text, Parent = row,
        })
        if removeFn then
            local btn = make("TextButton", {
                Size = UDim2.fromOffset(50, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = C.danger, BorderSizePixel = 0,
                AutoButtonColor = false,
                Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.white,
                Text = "Remove", Parent = row,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            btn.MouseButton1Click:Connect(removeFn)
        end
        return row
    end

    local function buildList(items, emptyText, formatter, removeFnFor)
        local sf = make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, 200),
            BackgroundColor3 = C.gray2, BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = C.gray7,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, {
            make("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            make("UIPadding", {
                PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
            }),
            make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),
        })

        local listApi = { onChange = nil }

        local function placeEmpty()
            local existing = sf:FindFirstChild("EmptyLabel")
            if existing then return end
            local lbl = make("TextLabel", {
                Name = "EmptyLabel",
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "  " .. emptyText,
            })
            lbl.Parent = sf
        end

        if #items == 0 then
            placeEmpty()
        else
            for i, item in ipairs(items) do
                local row
                local onRemoveClick
                if removeFnFor then
                    onRemoveClick = function()
                        removeFnFor(item, i)
                        if row then row:Destroy() end
                        for idx, it in ipairs(items) do
                            if it == item then table.remove(items, idx); break end
                        end
                        if #items == 0 then placeEmpty() end
                        if listApi.onChange then listApi.onChange(#items) end
                    end
                end
                row = buildRow(formatter(item, i), i, onRemoveClick)
                row.Parent = sf
            end
        end
        return sf, listApi
    end

    local function tabBar(sections, initial)
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = C.gray2, BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
                PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            }),
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        local buttons = {}
        local active = initial or sections[1].key

        local function refresh()
            for _, s in ipairs(sections) do
                buttons[s.key].BackgroundColor3 = (s.key == active) and ctx.Theme.primary or C.gray4
                s.frame.Visible = (s.key == active)
            end
        end

        for i, s in ipairs(sections) do
            local b = make("TextButton", {
                Size = UDim2.new(1 / #sections, -4, 1, 0),
                BorderSizePixel = 0, AutoButtonColor = false,
                Font = Enum.Font.GothamMedium, TextSize = 12,
                TextColor3 = C.white,
                Text = ("%s  (%d)"):format(s.label, s.count),
                LayoutOrder = i, Parent = row,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            buttons[s.key] = b
            b.MouseButton1Click:Connect(function() active = s.key; refresh() end)
            if s.api and s.api ~= true then
                s.api.onChange = function(newCount)
                    b.Text = ("%s  (%d)"):format(s.label, newCount)
                end
            end
        end
        refresh()
        return row
    end

    function InventoryViewer.open(targetName, defaultTab)
        if not targetName or targetName == "" then return end
        local ok, data = pcall(function() return Rfunc:InvokeServer("getInventory", targetName) end)
        if not ok or not data or data.error then
            Modal.alert({
                title = "Inventory error",
                body  = (data and data.error) or "Couldn't fetch inventory",
                kind  = "danger",
            })
            return
        end

        local Remote = ctx.RemoteEvent
        local function removeTool(t)
            Remote:FireServer("removeTool", data.target, t.name)
            if ctx.Notify then
                ctx.Notify:show({
                    title = "Removed", description = t.name,
                    kind = "success", duration = 2,
                })
            end
        end
        local function removeHat(h)
            Remote:FireServer("removeHat", data.target, h.name)
            if ctx.Notify then
                ctx.Notify:show({
                    title = "Removed", description = h.name,
                    kind = "success", duration = 2,
                })
            end
        end

        local backpackList, backpackApi = buildList(data.backpack, "(empty)", function(t)
            return ("  • %s"):format(t.name)
        end, removeTool)
        local equippedList, equippedApi = buildList(data.equipped, "(none equipped)", function(t)
            return ("  • %s"):format(t.name)
        end, removeTool)
        local hatsList, hatsApi = buildList(data.hats, "(no accessories)", function(h)
            return ("  • %s  [%s]"):format(h.name, h.accessoryType or "?")
        end, removeHat)

        local sections = {
            { key = "Backpack", label = "Backpack", count = #data.backpack, frame = backpackList, api = backpackApi },
            { key = "Equipped", label = "Equipped", count = #data.equipped, frame = equippedList, api = equippedApi },
            { key = "Hats",     label = "Hats",     count = #data.hats,     frame = hatsList,     api = hatsApi     },
        }
        local tabs = tabBar(sections, defaultTab or "Backpack")

        Modal.custom({
            title = ("Inventory  ·  %s"):format(data.target),
            width = 480,
            kind  = "info",
            bodyChildren = { tabs, backpackList, equippedList, hatsList },
            buttons = { { text = "Close", onClick = function(h) h:close() end } },
        })
    end

    ctx.InventoryViewer = InventoryViewer
    return InventoryViewer
end

return InventoryViewer
