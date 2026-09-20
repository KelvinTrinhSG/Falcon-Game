--!nocheck

local EditData = {}

function EditData.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()
    local Rfunc = ctx.RemoteFunction
    local Remote= ctx.RemoteEvent

    local function buildRow(targetName, path, node, navigate)
        local row = make("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = C.gray2, BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 6) }),
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 6),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        make("TextLabel", {
            Size = UDim2.new(0, 100, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.white,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            Text = node.name, LayoutOrder = 1, Parent = row,
        })
        make("TextLabel", {
            Size = UDim2.new(0, 90, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            Text = node.className, LayoutOrder = 2, Parent = row,
        })

        local childPath = table.clone(path)
        table.insert(childPath, node.name)

        if node.childCount and node.childCount > 0 then
            make("TextLabel", {
                Size = UDim2.new(1, -260, 1, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = ("%d item%s"):format(node.childCount, node.childCount == 1 and "" or "s"),
                LayoutOrder = 3, Parent = row,
            })
            local openBtn = Modal._pillButton("Open ›", { bg = C.gray5, width = 56 })
            openBtn.Size = UDim2.fromOffset(56, 24)
            openBtn.LayoutOrder = 4
            openBtn.Parent = row
            openBtn.MouseButton1Click:Connect(function() navigate(childPath) end)

        elseif node.editableType then
            local field = make("Frame", {
                Size = UDim2.new(1, -260, 1, -8),
                BackgroundColor3 = C.gray3, BorderSizePixel = 0,
                LayoutOrder = 3, Parent = row,
            }, {
                make("UICorner", { CornerRadius = UDim.new(0, 4) }),
                make("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
            })
            local box = make("TextBox", {
                Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.white,
                PlaceholderColor3 = C.gray11, PlaceholderText = "",
                Text = tostring(node.valueText or ""), ClearTextOnFocus = false,
                TextXAlignment = Enum.TextXAlignment.Left, Parent = field,
            })

            if node.editableType == "int" or node.editableType == "number" then
                box:GetPropertyChangedSignal("Text"):Connect(function()
                    local cleaned = box.Text:gsub("[^%-%.%d]", "")
                    if cleaned ~= box.Text then box.Text = cleaned end
                end)
            end

            local saveBtn = Modal._pillButton("Save", { bg = ctx.Theme.primary, width = 56 })
            saveBtn.Size = UDim2.fromOffset(56, 24)
            saveBtn.LayoutOrder = 4
            saveBtn.Parent = row
            saveBtn.MouseButton1Click:Connect(function()
                Remote:FireServer("setData", targetName, childPath, box.Text)
                if ctx.Notify then
                    ctx.Notify:show({
                        title = "Saved", description = node.name.." = "..box.Text,
                        kind = "success", duration = 2,
                    })
                end
            end)

        else
            make("TextLabel", {
                Size = UDim2.new(1, -260, 1, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                Text = tostring(node.valueText or ""), LayoutOrder = 3, Parent = row,
            })
            make("TextLabel", {
                Size = UDim2.new(0, 56, 1, 0), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.gray8,
                TextXAlignment = Enum.TextXAlignment.Right,
                Text = "read-only", LayoutOrder = 4, Parent = row,
            })
        end

        return row
    end

    function EditData.open(targetName)
        if not targetName or targetName == "" then return end

        local body = make("Frame", {
            Size = UDim2.new(1, 0, 0, 360), BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

        local crumbRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
            LayoutOrder = 1, Parent = body,
        })
        local backBtn = Modal._pillButton("‹ Back", { bg = C.gray5, width = 64 })
        backBtn.Size = UDim2.fromOffset(64, 28)
        backBtn.Parent = crumbRow
        local crumbLabel = make("TextLabel", {
            Position = UDim2.fromOffset(72, 0), Size = UDim2.new(1, -72, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            Text = targetName, Parent = crumbRow,
        })

        local list = make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, -36), BackgroundColor3 = C.gray2,
            BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = C.gray7,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2, Parent = body,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIPadding", {
                PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
            }),
            make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
        })

        local function clearList()
            for _, c in ipairs(list:GetChildren()) do
                if not c:IsA("UIListLayout") and not c:IsA("UIPadding") and not c:IsA("UICorner") then
                    c:Destroy()
                end
            end
        end

        local function emptyRow(text)
            make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
                Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left, Text = text, Parent = list,
            })
        end

        local currentPath = {}
        local navigate
        navigate = function(path)
            currentPath = path
            local ok, data = pcall(function()
                return Rfunc:InvokeServer("getDataTree", targetName, path)
            end)
            if not ok or not data or data.error then
                clearList()
                emptyRow((data and data.error) or "couldn't read data")
                return
            end

            backBtn.Visible = #path > 0
            crumbLabel.Position = UDim2.fromOffset(#path > 0 and 72 or 8, 0)
            crumbLabel.Size     = UDim2.new(1, #path > 0 and -72 or -8, 1, 0)
            crumbLabel.Text = data.nodeName ..
                (#path > 0 and ("  /  "..table.concat(path, " / ")) or "")

            clearList()
            if #data.children == 0 then
                emptyRow("(no editable data here)")
                return
            end
            for i, node in ipairs(data.children) do
                local row = buildRow(targetName, path, node, navigate)
                row.LayoutOrder = i
                row.Parent = list
            end
        end

        backBtn.MouseButton1Click:Connect(function()
            if #currentPath == 0 then return end
            local parent = table.clone(currentPath)
            table.remove(parent)
            navigate(parent)
        end)

        Modal.custom({
            title = ("Data editor  ·  %s"):format(targetName),
            width = 560,
            kind  = "info",
            bodyChildren = { body },
            buttons = { { text = "Close", onClick = function(h) h:close() end } },
        })

        navigate({})
    end

    ctx.EditData = EditData
    return EditData
end

return EditData
