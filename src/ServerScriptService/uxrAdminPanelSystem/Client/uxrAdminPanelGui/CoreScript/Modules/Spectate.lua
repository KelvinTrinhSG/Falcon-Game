--!nocheck

local TweenService = game:GetService("TweenService")
local Workspace    = game:GetService("Workspace")
local Players      = game:GetService("Players")

local Spectate = {}

local FADE_TI = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Spectate.init(ctx)
    local Theme = ctx.Theme
    local LocalPlayer = ctx.LocalPlayer

    local sg = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("uxrSpectate")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "uxrSpectate"
        sg.DisplayOrder = 800
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = LocalPlayer.PlayerGui
    end

    local current = {
        target      = nil,
        banner      = nil,
        billboard   = nil,
        charConn    = nil,
    }

    local function make(class, props, children)
        local inst = Instance.new(class)
        if props then
            for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end
        end
        if children then for _, c in ipairs(children) do c.Parent = inst end end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end

    local function buildBanner(name)
        local card = make("Frame", {
            Name = "Banner",
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 8),
            Size = UDim2.fromOffset(320, 36),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = sg,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 8) }),
            make("UIStroke", { Color = Theme.gray7, Thickness = 1, Transparency = 0.4 }),
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 6),
            }),
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10),
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        make("TextLabel", {
            Size = UDim2.new(1, -86, 1, 0), BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium, TextSize = 13,
            TextColor3 = Theme.white,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "Spectating  " .. name,
            LayoutOrder = 1, Parent = card,
        })

        local exit = make("TextButton", {
            Size = UDim2.fromOffset(70, 26),
            BackgroundColor3 = Theme.danger, BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.white,
            Text = "Exit", LayoutOrder = 2, Parent = card,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })

        exit.MouseButton1Click:Connect(function()
            ctx.RemoteEvent:FireServer("command", "unview")
        end)

        card.Position = UDim2.new(0.5, 0, 0, -20)
        TweenService:Create(card, FADE_TI, { BackgroundTransparency = 0.1 }):Play()
        TweenService:Create(card, FADE_TI, { Position = UDim2.new(0.5, 0, 0, 8) }):Play()

        return card
    end

    local function destroyBanner()
        if not current.banner then return end
        local card = current.banner
        current.banner = nil
        TweenService:Create(card, FADE_TI, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(card, FADE_TI, { Position = UDim2.new(0.5, 0, 0, -20) }):Play()
        task.delay(0.2, function() if card then card:Destroy() end end)
    end

    local function buildBillboard(target)
        local char = target.Character
        local head = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
        if not head then return nil end

        local bb = make("BillboardGui", {
            Name = "uxrSpectateTag",
            Adornee = head,
            Size = UDim2.fromOffset(140, 36),
            StudsOffset = Vector3.new(0, 3, 0),
            AlwaysOnTop = true,
            MaxDistance = 5000,
            LightInfluence = 0,
            Parent = sg,
        })

        local card = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.15,
            BorderSizePixel = 0, Parent = bb,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 6) }),
            make("UIStroke", { Color = Theme.danger, Thickness = 1, Transparency = 0.2 }),
            make("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })

        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, TextSize = 11,
            TextColor3 = Theme.danger,
            Text = "ADMIN VIEW", LayoutOrder = 1, Parent = card,
        })
        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextColor3 = Theme.white,
            Text = LocalPlayer.DisplayName, LayoutOrder = 2, Parent = card,
        })

        return bb
    end

    local function destroyBillboard()
        if current.billboard then current.billboard:Destroy() end
        current.billboard = nil
        if current.charConn then current.charConn:Disconnect() end
        current.charConn = nil
    end

    local function attachBillboard(target)
        destroyBillboard()
        current.billboard = buildBillboard(target)
        current.charConn = target.CharacterAdded:Connect(function()
            task.wait(0.1)
            if current.target == target then attachBillboard(target) end
        end)
    end

    local Spec = {}

    function Spec.start(target)
        if not (target and typeof(target) == "Instance" and target:IsA("Player")) then return end
        if current.target == target then return end
        Spec.stop()
        current.target = target

        if target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        end

        current.banner = buildBanner(target.DisplayName ~= "" and target.DisplayName or target.Name)
        attachBillboard(target)
    end

    function Spec.stop()
        if not current.target then return end
        current.target = nil
        destroyBanner()
        destroyBillboard()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end

    Players.PlayerRemoving:Connect(function(p)
        if current.target == p then Spec.stop() end
    end)

    ctx.Spectate = Spec
    return Spec
end

return Spectate
