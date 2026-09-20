--!nocheck

local SkyboxPicker = {}

function SkyboxPicker.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()
    local Rfunc = ctx.RemoteFunction
    local Remote= ctx.RemoteEvent

    function SkyboxPicker.open()
        local ok, data = pcall(function() return Rfunc:InvokeServer("getSkyboxes") end)
        if not ok or not data then
            Modal.alert({ title = "Skybox error", body = "Couldn't fetch list", kind = "danger" })
            return
        end
        if not data.skies or #data.skies == 0 then
            Modal.alert({
                title = "No skyboxes",
                body  = "ServerStorage/uxrAdminPanelSystem/Skybox is empty. Drop Sky instances into that folder.",
                kind  = "info",
            })
            return
        end

        local grid = make("ScrollingFrame", {
            Size = UDim2.new(1, 0, 0, 220),
            BackgroundColor3 = C.gray2, BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = C.gray7,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, {
            make("UICorner",  { CornerRadius = UDim.new(0, 6) }),
            make("UIPadding", {
                PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6),
            }),
            make("UIGridLayout", {
                CellSize = UDim2.fromOffset(140, 34),
                CellPadding = UDim2.fromOffset(6, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        local handleRef = {}

        for i, name in ipairs(data.skies) do
            local btn = make("TextButton", {
                BorderSizePixel = 0,
                BackgroundColor3 = C.gray4,
                AutoButtonColor = false,
                Font = Enum.Font.GothamMedium, TextSize = 12,
                TextColor3 = C.white,
                Text = name, LayoutOrder = i, Parent = grid,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
            btn.MouseButton1Click:Connect(function()
                Remote:FireServer("setSkybox", name)
                if ctx.Notify then
                    ctx.Notify:show({
                        title = "Skybox applied", description = name,
                        kind = "success", duration = 2,
                    })
                end
                if handleRef.close then handleRef:close() end
            end)
        end

        local handle = Modal.custom({
            title = "Pick a skybox",
            body  = ("%d available — click to apply"):format(#data.skies),
            width = 480,
            kind  = "info",
            bodyChildren = { grid },
            buttons = { { text = "Cancel", onClick = function(h) h:close() end } },
        })
        handleRef.close = function(self, ...) handle:close(...) end
    end

    ctx.SkyboxPicker = SkyboxPicker
    return SkyboxPicker
end

return SkyboxPicker
