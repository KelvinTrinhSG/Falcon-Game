--!nocheck

local Chat = {}

function Chat.init(ctx)
    local Format       = ctx.Format
    local Templates    = ctx.Templates
    local RemoteEvent  = ctx.RemoteEvent
    local UtilModule   = ctx.UtilModule
    local LocalPlayer  = ctx.LocalPlayer
    local Permissions  = ctx.Permissions

    local page      = ctx.pages.Chat
    local chatSF    = page.ChattingFrame:FindFirstChildWhichIsA("ScrollingFrame")
    local textFrame = page:FindFirstChild("TextFrame")
    local chatInput = textFrame and textFrame:FindFirstChild("ChatTextBox")

    local MAX_ROWS = 80

    local function appendMessage(data)
        local row = Templates.cloneTemplate(chatSF)
        if not row then return end

        local img = row:FindFirstChild("UserImage")
        if img and data.fromUserId then
            img.Image = "rbxthumb://type=AvatarHeadShot&id="
                .. tostring(data.fromUserId) .. "&w=150&h=150"
        end

        Templates.safeText(row, "UserNameTextLabel", data.text or "")

        local nameFrame = row:FindFirstChild("NameFrame")
        if nameFrame then
            local display = data.fromDisplay or data.fromName or "?"
            Templates.safeText(nameFrame, "DisplayNameTextLabel", display)
            Templates.safeText(nameFrame, "TimeTextLabel", Format.fmtClockShort(data.time))
            local rankLabel = nameFrame:FindFirstChild("RankTextLabel")
                            or nameFrame:FindFirstChild("RankLabel")
            if rankLabel and rankLabel:IsA("TextLabel") then
                rankLabel.Text = data.rankName or ""
                local c = data.rankColor
                if type(c) == "string" then
                    rankLabel.TextColor3 = Format.hexToColor3(c) or rankLabel.TextColor3
                end
            end
        end

        local rows = {}
        for _, c in ipairs(chatSF:GetChildren()) do
            if not (c:IsA("UIGridLayout") or c:IsA("UIListLayout") or c:IsA("UIPadding")) then
                table.insert(rows, c)
            end
        end
        if #rows > MAX_ROWS then
            for i = 1, #rows - MAX_ROWS do rows[i]:Destroy() end
        end
    end

    if ctx.clientHandlers then
        ctx.clientHandlers["adminChat"] = appendMessage
    else
        RemoteEvent.OnClientEvent:Connect(function(rtype, payload)
            if rtype == "adminChat" then appendMessage(payload) end
        end)
    end

    if chatInput then
        local canPost = UtilModule:HasRank(LocalPlayer, Permissions.PostMessageRank or "Mod")
        if not canPost then
            if textFrame then textFrame.Visible = false end
        else
            chatInput.FocusLost:Connect(function(enter)
                if not enter then return end
                local text = chatInput.Text
                chatInput.Text = ""
                if text == "" then return end
                RemoteEvent:FireServer("adminChat", text)
            end)
        end
    end
end

return Chat
