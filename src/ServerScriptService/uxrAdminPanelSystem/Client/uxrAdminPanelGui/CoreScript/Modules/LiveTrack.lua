--!nocheck

local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")

local LiveTrack = {}

local POLL_HZ = 2
local ROW_HEIGHT = 64
local ROW_WIDTH  = 260

function LiveTrack.init(ctx)
    local LocalPlayer = ctx.LocalPlayer
    local Theme = ctx.Theme

    local sg = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("uxrLiveTrack")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "uxrLiveTrack"
        sg.DisplayOrder = 600
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.IgnoreGuiInset = true
        sg.Parent = LocalPlayer.PlayerGui
    end

    local function make(class, props, children)
        local inst = Instance.new(class)
        if props then for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end end
        if children then for _, c in ipairs(children) do c.Parent = inst end end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end

    local container = make("Frame", {
        Name = "Dashboard",
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 12, 0, 80),
        Size = UDim2.fromOffset(ROW_WIDTH, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = sg,
    }, {
        make("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local titleBar

    titleBar = make("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        LayoutOrder = -1,
        Parent = container,
    }, {
        make("UICorner", { CornerRadius = UDim.new(0, 6) }),
        make("UIStroke", { Color = Theme.gray7, Thickness = 1, Transparency = 0.4 }),
        make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
    })
    make("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextColor3 = Theme.gray11,
        Text = "LIVE TRACK",
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })
    titleBar.Visible = false

    do
        local dragging, dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position
                startPos = container.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                local d = input.Position - dragStart
                container.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
    end

    local rows = {}

    local function buildRow(player)
        local frame = make("Frame", {
            Name = "Row_"..player.Name,
            Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 8) }),
            make("UIStroke", { Color = Theme.gray7, Thickness = 1, Transparency = 0.5 }),
        })

        local avatar = make("ImageLabel", {
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.fromOffset(48, 48),
            BackgroundColor3 = Theme.gray4, BorderSizePixel = 0,
            Image = "rbxthumb://type=AvatarHeadShot&id="..tostring(player.UserId).."&w=100&h=100",
            Parent = frame,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })

        local nameLbl = make("TextLabel", {
            Position = UDim2.fromOffset(64, 6),
            Size = UDim2.new(1, -98, 0, 16),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, TextSize = 12,
            TextColor3 = Theme.white,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = player.DisplayName ~= "" and player.DisplayName or player.Name,
            Parent = frame,
        })

        local hpBack = make("Frame", {
            Position = UDim2.fromOffset(64, 24),
            Size = UDim2.new(1, -98, 0, 6),
            BackgroundColor3 = Theme.gray4, BorderSizePixel = 0,
            Parent = frame,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 3) }) })
        local hpFill = make("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(80, 200, 100), BorderSizePixel = 0,
            Parent = hpBack,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 3) }) })

        local metaLbl = make("TextLabel", {
            Position = UDim2.fromOffset(64, 34),
            Size = UDim2.new(1, -98, 0, 24),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 10,
            TextColor3 = Theme.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Text = "loading…",
            Parent = frame,
        })

        local closeBtn = make("TextButton", {
            Position = UDim2.new(1, -28, 0, 6),
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = Theme.danger, BorderSizePixel = 0,
            AutoButtonColor = true,
            Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Theme.white,
            Text = "×",
            Parent = frame,
        }, { make("UICorner", { CornerRadius = UDim.new(0, 4) }) })
        closeBtn.MouseButton1Click:Connect(function()
            ctx.RemoteEvent:FireServer("command", 'unlivetrack "'..player.Name..'"')
        end)

        local clickHit = make("TextButton", {
            Position = UDim2.fromOffset(64, 0),
            Size = UDim2.new(1, -98, 1, 0),
            BackgroundTransparency = 1, Text = "",
            AutoButtonColor = false,
            Parent = frame,
        })
        clickHit.MouseButton1Click:Connect(function()
            ctx.RemoteEvent:FireServer("command", 'view "'..player.Name..'"')
        end)

        return frame, { hpFill = hpFill, hpBack = hpBack, meta = metaLbl, name = nameLbl }
    end

    local function formatPos(v3)
        return ("[%d, %d, %d]"):format(math.floor(v3.X), math.floor(v3.Y), math.floor(v3.Z))
    end

    local function updateRow(entry)
        local p = entry.player
        if not p.Parent then return false end

        local char = p.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")

        if not (hum and hrp) then
            entry.refs.meta.Text = "no character"
            entry.refs.hpFill.Size = UDim2.fromScale(0, 1)
            return true
        end

        local pct = math.clamp(hum.Health / math.max(1, hum.MaxHealth), 0, 1)
        entry.refs.hpFill.Size = UDim2.fromScale(pct, 1)
        if pct > 0.5 then
            entry.refs.hpFill.BackgroundColor3 = Color3.fromRGB(80, 200, 100)
        elseif pct > 0.25 then
            entry.refs.hpFill.BackgroundColor3 = Color3.fromRGB(230, 195, 50)
        else
            entry.refs.hpFill.BackgroundColor3 = Color3.fromRGB(230, 80, 80)
        end

        local toolName = "—"
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then toolName = tool.Name end
        end

        local distance = "—"
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            distance = ("%dm"):format((hrp.Position - myHrp.Position).Magnitude)
        end

        entry.refs.meta.Text = ("HP %d/%d  ·  %s\n%s  ·  %s away"):format(
            math.floor(hum.Health), math.floor(hum.MaxHealth),
            formatPos(hrp.Position),
            toolName, distance)
        return true
    end

    local lastPoll = 0
    local pollConn
    local function ensurePollLoop()
        if pollConn then return end
        pollConn = RunService.Heartbeat:Connect(function()
            local now = os.clock()
            if now - lastPoll < (1 / POLL_HZ) then return end
            lastPoll = now
            for userId, entry in pairs(rows) do
                local alive = updateRow(entry)
                if not alive then LiveTrack.remove(entry.player) end
            end
        end)
    end
    local function stopPollLoopIfEmpty()
        if next(rows) then return end
        if pollConn then pollConn:Disconnect(); pollConn = nil end
        titleBar.Visible = false
    end

    function LiveTrack.add(player)
        if not player or rows[player.UserId] then return end
        local frame, refs = buildRow(player)
        frame.Parent = container
        rows[player.UserId] = { player = player, frame = frame, refs = refs }
        titleBar.Visible = true
        ensurePollLoop()
    end

    function LiveTrack.remove(player)
        if not player then return end
        local entry = rows[player.UserId]
        if not entry then return end
        rows[player.UserId] = nil
        if entry.frame then entry.frame:Destroy() end
        stopPollLoopIfEmpty()
    end

    function LiveTrack.clear()
        for _, entry in pairs(rows) do
            if entry.frame then entry.frame:Destroy() end
        end
        rows = {}
        stopPollLoopIfEmpty()
    end

    Players.PlayerRemoving:Connect(function(p)
        if rows[p.UserId] then LiveTrack.remove(p) end
    end)

    ctx.LiveTrack = LiveTrack
    return LiveTrack
end

return LiveTrack
