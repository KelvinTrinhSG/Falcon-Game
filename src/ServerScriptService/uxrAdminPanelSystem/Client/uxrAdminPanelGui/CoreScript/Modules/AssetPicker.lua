--!nocheck

local SoundService = game:GetService("SoundService")

local AssetPicker = {}

local THUMB_TYPE = {
    Image           = "rbxthumb://type=Asset&id=%d&w=150&h=150",
    Hat             = "rbxthumb://type=Asset&id=%d&w=150&h=150",
    Shirt           = "rbxthumb://type=Asset&id=%d&w=150&h=150",
    Pants           = "rbxthumb://type=Asset&id=%d&w=150&h=150",
    Face            = "rbxthumb://type=Asset&id=%d&w=150&h=150",
    BundleThumbnail = "rbxthumb://type=BundleThumbnail&id=%d&w=150&h=150",
    Outfit          = "rbxthumb://type=Outfit&id=%d&w=150&h=150",
}

function AssetPicker.init(ctx)
    local Modal = ctx.Modal
    local make  = Modal._make
    local C     = Modal._theme()

    function AssetPicker.open(opts)
        opts = opts or {}
        local assetType = opts.assetType or "Image"
        local isAudio   = assetType == "Audio"
        local thumbTemplate = THUMB_TYPE[assetType] or THUMB_TYPE.Image

        local body = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, { make("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }) })

        local idRow = make("Frame", {
            Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1,
            LayoutOrder = 1, Parent = body,
        })
        make("TextLabel", {
            Size = UDim2.new(0, 56, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = isAudio and "Sound id" or "Asset id", Parent = idRow,
        })
        local idBox = make("TextBox", {
            Position = UDim2.fromOffset(60, 0),
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundColor3 = C.gray3, BorderSizePixel = 0,
            Font = Enum.Font.Code, TextSize = 13, TextColor3 = C.white,
            PlaceholderText = "e.g. 12345",
            Text = tostring(opts.initial or ""),
            ClearTextOnFocus = false, Parent = idRow,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 4) }),
            make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
        })

        local previewBox = make("Frame", {
            Size = UDim2.new(1, 0, 0, 170),
            BackgroundColor3 = C.gray3, BorderSizePixel = 0,
            LayoutOrder = 2, Parent = body,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.4 }),
        })

        if isAudio then
            local statusLbl = make("TextLabel", {
                Position = UDim2.fromOffset(12, 12),
                Size = UDim2.new(1, -24, 0, 20),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = C.gray11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "Enter an id, then press ▶ to preview", Parent = previewBox,
            })
            local btn = make("TextButton", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.55),
                Size = UDim2.fromOffset(80, 60),
                BackgroundColor3 = ctx.Theme.primary, BorderSizePixel = 0,
                AutoButtonColor = true,
                Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = C.white,
                Text = "▶", Parent = previewBox,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 8) }) })

            local sound
            local function stop()
                if sound then sound:Destroy(); sound = nil end
                btn.Text = "▶"; statusLbl.Text = "Stopped"
            end
            btn.MouseButton1Click:Connect(function()
                if sound then return stop() end
                local id = tonumber(idBox.Text); if not id then
                    statusLbl.Text = "invalid id"; return
                end
                sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://"..id
                sound.Volume = 0.6
                sound.Parent = SoundService
                SoundService:PlayLocalSound(sound)
                btn.Text = "■"
                statusLbl.Text = "Playing  "..id
            end)
        else
            local img = make("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(150, 150),
                BackgroundColor3 = C.gray4, BorderSizePixel = 0,
                Image = "", Parent = previewBox,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
            local function refresh()
                local id = tonumber(idBox.Text)
                if id and id > 0 then img.Image = thumbTemplate:format(id)
                else img.Image = "" end
            end
            idBox:GetPropertyChangedSignal("Text"):Connect(refresh)
            refresh()
        end

        Modal.custom({
            title = opts.title or "Pick an asset",
            body = nil, width = 320, kind = "info", dismissable = true,
            bodyChildren = { body },
            buttons = {
                { text = "Cancel", onClick = function(h) h:close() end },
                { text = "Use",    onClick = function(h)
                    if opts.onSubmit then opts.onSubmit(idBox.Text) end
                    h:close()
                end },
            },
        })
    end

    ctx.AssetPicker = AssetPicker
    return AssetPicker
end

return AssetPicker
