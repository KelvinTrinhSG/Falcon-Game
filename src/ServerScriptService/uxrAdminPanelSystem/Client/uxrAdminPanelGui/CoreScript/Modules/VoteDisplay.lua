--!nocheck

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")

local VoteDisplay = {}

local FADE_TI = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function VoteDisplay.init(ctx)
    local C       = ctx.Theme
    local LocalPlayer = ctx.LocalPlayer
    local Remote  = ctx.RemoteEvent

    local function make(class, props, children)
        local inst = Instance.new(class)
        if props then for k, v in pairs(props) do if k ~= "Parent" then inst[k] = v end end end
        if children then for _, c in ipairs(children) do c.Parent = inst end end
        if props and props.Parent then inst.Parent = props.Parent end
        return inst
    end

    local sg = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("uxrVotes")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "uxrVotes"
        sg.DisplayOrder = 750
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = LocalPlayer.PlayerGui
    end

    local active = nil

    local function dismissCard()
        if not active then return end
        local card = active.card
        active = nil
        TweenService:Create(card, FADE_TI, { BackgroundTransparency = 1 }):Play()
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                TweenService:Create(d, FADE_TI, { TextTransparency = 1 }):Play()
            end
            if d:IsA("TextButton") then
                TweenService:Create(d, FADE_TI, { BackgroundTransparency = 1 }):Play()
            end
        end
        task.delay(0.2, function() if card then card:Destroy() end end)
    end

    local function refreshTally(voteInfo)
        if not active or not voteInfo then return end
        local counts = voteInfo[3] or {}
        local total  = 0
        for _, n in ipairs(counts) do total += n end
        local parts = {}
        for i, opt in ipairs(active.options) do
            table.insert(parts, ("%s %d"):format(opt, counts[i] or 0))
        end
        active.tallyLabel.Text = ("  %s · %d votes"):format(table.concat(parts, "  ·  "), total)
    end

    local function buildCard(voteId, duration, question, options, isGlobal)
        dismissCard()
        local card = make("Frame", {
            Name = "VoteCard",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -20, 0, 60),
            Size = UDim2.fromOffset(320, 122),
            BackgroundColor3 = Color3.fromRGB(27, 27, 27),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = sg,
        }, {
            make("UICorner", { CornerRadius = UDim.new(0, 10) }),
            make("UIStroke", { Color = C.gray7, Thickness = 1, Transparency = 0.4 }),
            make("UIPadding", {
                PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
            }),
        })

        make("Frame", {
            Name = "Accent",
            Size = UDim2.new(0, 3, 1, -22), Position = UDim2.fromOffset(0, 11),
            AnchorPoint = Vector2.new(0, 0),
            BackgroundColor3 = isGlobal and Color3.fromRGB(155, 89, 182) or C.primary,
            BorderSizePixel = 0, Parent = card,
        }, { make("UICorner", { CornerRadius = UDim.new(1, 0) }) })

        make("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -10, 0, 18),
            Position = UDim2.fromOffset(10, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = C.white,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Text = ("%s"):format(question),
            Parent = card,
        })

        local kindTag = make("TextLabel", {
            Size = UDim2.new(0, 60, 0, 14), Position = UDim2.fromOffset(10, 20),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = isGlobal and Color3.fromRGB(155, 89, 182) or C.primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = isGlobal and "GLOBAL" or "LOCAL",
            Parent = card,
        })
        local timerLabel = make("TextLabel", {
            Size = UDim2.new(1, -80, 0, 14), Position = UDim2.fromOffset(70, 20),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = ("%ds"):format(duration), Parent = card,
        })

        local buttonRow = make("Frame", {
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.fromOffset(10, 40),
            BackgroundTransparency = 1, Parent = card,
        }, { make("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }) })

        local buttons = {}
        for i, opt in ipairs(options) do
            local b = make("TextButton", {
                Size = UDim2.new(1 / #options, -3, 1, 0),
                BackgroundColor3 = C.gray5, BorderSizePixel = 0,
                AutoButtonColor = false,
                Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.white,
                Text = opt, LayoutOrder = i, Parent = buttonRow,
            }, { make("UICorner", { CornerRadius = UDim.new(0, 6) }) })
            table.insert(buttons, b)
        end

        local tallyLabel = make("TextLabel", {
            Size = UDim2.new(1, -10, 0, 14),
            Position = UDim2.fromOffset(10, 76),
            BackgroundTransparency = 1,
            Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  no votes yet", Parent = card,
        })

        local hint = make("TextLabel", {
            Size = UDim2.new(1, -10, 0, 12),
            Position = UDim2.fromOffset(10, 92),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.gray11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  click an option to cast your vote", Parent = card,
        })

        TweenService:Create(card, FADE_TI, { BackgroundTransparency = 0.05 }):Play()

        active = {
            voteId     = voteId,
            isGlobal   = isGlobal,
            options    = options,
            card       = card,
            buttons    = buttons,
            tallyLabel = tallyLabel,
            timerLabel = timerLabel,
            hintLabel  = hint,
            endTime    = os.time() + duration,
            voted      = false,
        }

        for i, b in ipairs(buttons) do
            b.MouseButton1Click:Connect(function()
                if not active or active.voted then return end
                active.voted = true
                Remote:FireServer("voteCast", voteId, i, true)
                for _, ob in ipairs(active.buttons) do
                    ob.BackgroundColor3 = C.gray3
                    ob.TextColor3 = C.gray11
                end
                b.BackgroundColor3 = C.success
                b.TextColor3 = C.white
                hint.Text = ("  Voted: %s"):format(b.Text)
            end)
        end

        task.spawn(function()
            while active and active.voteId == voteId do
                local remaining = math.max(0, active.endTime - os.time())
                if active.timerLabel then
                    active.timerLabel.Text = ("%ds"):format(remaining)
                end
                if remaining <= 0 then break end
                task.wait(1)
            end
        end)
    end

    function VoteDisplay.show(duration, _start, isGlobal, question, optionsCsv, voteId)
        local options = {}
        for o in tostring(optionsCsv or "Yes,No"):gmatch("[^,]+") do
            table.insert(options, o:match("^%s*(.-)%s*$"))
        end
        if #options == 0 then options = { "Yes", "No" } end
        buildCard(voteId or "?", tonumber(duration) or 30,
            tostring(question or "?"), options, isGlobal and true or false)
    end

    function VoteDisplay.status(voteInfo, voteId)
        if active and active.voteId == voteId then refreshTally(voteInfo) end
    end

    function VoteDisplay.endVote(voteId, voteInfo)
        if not active or active.voteId ~= voteId then return end
        refreshTally(voteInfo)

        local counts = voteInfo and voteInfo[3] or {}
        local total, topN = 0, 0
        for _, n in ipairs(counts) do
            total += n
            if n > topN then topN = n end
        end

        local leaders = {}
        if topN > 0 then
            for i, n in ipairs(counts) do
                if n == topN then table.insert(leaders, active.options[i] or "?") end
            end
        end

        if active.hintLabel then
            if total == 0 then
                active.hintLabel.Text = "  No votes were cast"
                active.hintLabel.TextColor3 = C.gray11
            elseif #leaders > 1 then
                active.hintLabel.Text = ("  Draw: %s (%d each)"):format(
                    table.concat(leaders, " · "), topN)
                active.hintLabel.TextColor3 = C.warning
            else
                active.hintLabel.Text = ("  Winner: %s (%d votes)"):format(leaders[1], topN)
                active.hintLabel.TextColor3 = C.success
            end
        end

        task.delay(5, function()
            if active and active.voteId == voteId then dismissCard() end
        end)
    end

    ctx.VoteDisplay = VoteDisplay
    return VoteDisplay
end

return VoteDisplay
