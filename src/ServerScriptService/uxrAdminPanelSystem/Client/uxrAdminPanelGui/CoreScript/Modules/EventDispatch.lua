--!nocheck

local EventDispatch = {}

function EventDispatch.init(ctx)
    local Players          = ctx.Players
    local RunService       = ctx.RunService
    local UserInputService = ctx.UserInputService
    local TextChatService  = ctx.TextChatService
    local Lighting         = ctx.Lighting
    local Workspace        = ctx.Workspace
    local LocalPlayer      = ctx.LocalPlayer
    local RemoteEvent      = ctx.RemoteEvent

    local clientHandlers = {}

    clientHandlers["systemMessage"] = function(text)
        local channels = TextChatService:FindFirstChild("TextChannels")
        local sys = channels and channels:FindFirstChild("RBXSystem")
        if sys then sys:DisplaySystemMessage(tostring(text)) end
    end

    local function classifyKind(hex)
        local h = type(hex) == "string" and hex:gsub("^#", "") or ""
        if #h ~= 6 then return "info" end
        local r = tonumber(h:sub(1, 2), 16) or 0
        local g = tonumber(h:sub(3, 4), 16) or 0
        local b = tonumber(h:sub(5, 6), 16) or 0
        if r > 200 and g <  90 and b <  90 then return "error"   end
        if r > 200 and g > 150 and b < 110 then return "warning" end
        if g > 140 and r < 100             then return "success" end
        return "info"
    end
    local KIND_TITLE = {
        info = "Info", success = "Done", warning = "Warning", error = "Error",
    }
    clientHandlers["notify"] = function(text, duration, iconId, soundId, hexColor)
        local kind = classifyKind(hexColor)
        if not ctx.Notify then return end
        ctx.Notify:show({
            title       = KIND_TITLE[kind] or "Info",
            description = tostring(text or ""),
            kind        = kind,
            duration    = tonumber(duration) or 4,
            iconId      = tonumber(iconId)  or nil,
            soundId     = tonumber(soundId) or nil,
        })
    end

    clientHandlers["serverMessage"] = function()
        if not ctx.Modal then return end
        ctx.Modal.prompt({
            title       = "Server message",
            body        = "Broadcasts a toast to every player on this server.",
            placeholder = "message body",
            onSubmit    = function(text)
                if text == "" then return end
                ctx.RemoteEvent:FireServer("serverMessage", text)
            end,
        })
    end

    clientHandlers["globalMessage"] = function()
        if not ctx.Modal then return end
        ctx.Modal.prompt({
            title       = "Global announcement",
            body        = "Broadcasts across every active server via MessagingService.",
            placeholder = "announcement body",
            onSubmit    = function(text)
                if text == "" then return end
                ctx.RemoteEvent:FireServer("globalMessage", text)
            end,
        })
    end

    clientHandlers["chatMessage"] = function()
        if not ctx.Modal then return end
        ctx.Modal.prompt({
            title       = "System chat message",
            body        = "Shows as a system message in every player's chat window.",
            placeholder = "message",
            onSubmit    = function(text)
                if text == "" then return end
                ctx.RemoteEvent:FireServer("chatMessage", text)
            end,
        })
    end

    clientHandlers["openPrivateMessageDialog"] = function(targetName)
        if not ctx.Modal then return end
        ctx.Modal.prompt({
            title       = "Direct message to " .. tostring(targetName or "?"),
            placeholder = "DM contents",
            onSubmit    = function(text)
                if text == "" then return end
                ctx.RemoteEvent:FireServer("privateMessage", text, targetName)
            end,
        })
    end

    clientHandlers["serverMessageBroadcast"] = function(text, fromName)
        local channels = TextChatService:FindFirstChild("TextChannels")
        local sys = channels and channels:FindFirstChild("RBXSystem")
        if sys then
            sys:DisplaySystemMessage(("[SERVER] @%s: %s"):format(tostring(fromName or "?"), tostring(text or "")))
        end
    end

    clientHandlers["globalMessageBroadcast"] = function(fromName, text)
        local channels = TextChatService:FindFirstChild("TextChannels")
        local sys = channels and channels:FindFirstChild("RBXSystem")
        if sys then
            sys:DisplaySystemMessage(("[GLOBAL] @%s: %s"):format(tostring(fromName or "?"), tostring(text or "")))
        end
    end

    clientHandlers["privateMessageReceive"] = function(text, fromName)
        if ctx.Notify then
            ctx.Notify:show({
                title       = "DM from @" .. tostring(fromName or "?"),
                description = tostring(text or ""),
                kind        = "info", duration = 7,
            })
        end
    end

    clientHandlers["globalPost"] = function(value1, value2)
        local channels = TextChatService:FindFirstChild("TextChannels")
        local sys = channels and channels:FindFirstChild("RBXSystem")
        if sys then
            sys:DisplaySystemMessage(("[POST] @%s: %s"):format(tostring(value1 or "?"), tostring(value2 or "")))
        end
    end

    clientHandlers["serverPost"] = function(value1, value2)
        local channels = TextChatService:FindFirstChild("TextChannels")
        local sys = channels and channels:FindFirstChild("RBXSystem")
        if sys then
            sys:DisplaySystemMessage(("[POST] @%s: %s"):format(tostring(value1 or "?"), tostring(value2 or "")))
        end
    end

    clientHandlers["selfMute"] = function()
        pcall(function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)
    end
    clientHandlers["selfUnmute"] = function()
        pcall(function() game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
    end

    clientHandlers["setBlur"] = function(size)
        local b = Lighting:FindFirstChild("UXPBlur")
        if not b then b = Instance.new("BlurEffect"); b.Name = "UXPBlur"; b.Parent = Lighting end
        b.Size = tonumber(size) or 0
    end

    clientHandlers["setLaserEyes"] = function(on, color)
        local LaserEyes = require(script.Parent.LaserEyes)
        if LaserEyes.setOwnerActive then LaserEyes.setOwnerActive(on == true, color) end
    end

    clientHandlers["laserShotReplicate"] = function(shooter, targetCFrame, neckC0, firing)
        local LaserEyes = require(script.Parent.LaserEyes)
        if LaserEyes.applyReplicate then
            LaserEyes.applyReplicate(shooter, targetCFrame, neckC0, firing)
        end
    end

    clientHandlers["measureFps"] = function(requester)
        task.spawn(function()
            local frames, t0 = 0, os.clock()
            local conn = RunService.RenderStepped:Connect(function() frames += 1 end)
            task.wait(1)
            conn:Disconnect()
            local elapsed = os.clock() - t0
            local fps = elapsed > 0 and (frames / elapsed) or 0
            RemoteEvent:FireServer("fpsReport", requester, fps)
        end)
    end

    clientHandlers["setNightVision"] = function(on)
        local existing = Lighting:FindFirstChild("UXPNightVision")
        if not on then
            if existing then existing:Destroy() end
            return
        end
        local cc = existing or Instance.new("ColorCorrectionEffect")
        cc.Name = "UXPNightVision"
        cc.Brightness = 0.35
        cc.Contrast = 0.2
        cc.Saturation = -0.5
        cc.TintColor = Color3.fromRGB(120, 255, 120)
        cc.Parent = Lighting
    end

    clientHandlers["setFov"] = function(fov)
        local cam = Workspace.CurrentCamera
        if not cam then return end
        cam.FieldOfView = tonumber(fov) or 70
    end

    clientHandlers["shutdownWarning"] = function()
        if not ctx.Notify then return end
        ctx.Notify:show({
            title       = "Server shutting down",
            description = "The server is closing in 3 seconds.",
            kind        = "warning", duration = 3,
        })
    end

    clientHandlers["openSkyboxPicker"] = function()
        if ctx.SkyboxPicker then ctx.SkyboxPicker.open() end
    end
    clientHandlers["openEditData"] = function(targetName)
        if ctx.EditData then ctx.EditData.open(tostring(targetName or "")) end
    end
    clientHandlers["openInventoryViewer"] = function(targetName)
        if ctx.InventoryViewer then ctx.InventoryViewer.open(tostring(targetName or ""), "Backpack") end
    end
    clientHandlers["openHatsViewer"] = function(targetName)
        if ctx.InventoryViewer then ctx.InventoryViewer.open(tostring(targetName or ""), "Hats") end
    end
    clientHandlers["openToolsViewer"] = function(targetName)
        if ctx.InventoryViewer then ctx.InventoryViewer.open(tostring(targetName or ""), "Equipped") end
    end
    clientHandlers["openVoteLauncher"] = function(prefillGlobal)
        if ctx.VoteLauncher then ctx.VoteLauncher.open(prefillGlobal == true) end
    end

    clientHandlers["voteStart"] = function(duration, startFlag, isGlobal, question, optionsCsv, voteId)
        if ctx.VoteDisplay then
            ctx.VoteDisplay.show(duration, startFlag, isGlobal, question, optionsCsv, voteId)
        end
    end
    clientHandlers["voteStatus"] = function(voteInfo, voteId)
        if ctx.VoteDisplay then ctx.VoteDisplay.status(voteInfo, voteId) end
    end
    clientHandlers["voteEnd"] = function(voteId, voteInfo)
        if ctx.VoteDisplay then ctx.VoteDisplay.endVote(voteId, voteInfo) end
    end

    clientHandlers["spectateStart"] = function(targetName)
        local target = Players:FindFirstChild(tostring(targetName))
        if target and ctx.Spectate then
            ctx.Spectate.start(target)
        elseif target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        end
    end
    clientHandlers["spectateStop"] = function()
        if ctx.Spectate then
            ctx.Spectate.stop()
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end

    clientHandlers["liveTrackAdd"] = function(targetName)
        local target = Players:FindFirstChild(tostring(targetName))
        if target and ctx.LiveTrack then ctx.LiveTrack.add(target) end
    end
    clientHandlers["liveTrackRemove"] = function(targetName)
        local target = Players:FindFirstChild(tostring(targetName))
        if target and ctx.LiveTrack then ctx.LiveTrack.remove(target) end
    end
    clientHandlers["liveTrackClear"] = function()
        if ctx.LiveTrack then ctx.LiveTrack.clear() end
    end

    clientHandlers["openNotifyHistory"] = function()
        if ctx.Notify and ctx.Notify.openHistory then ctx.Notify:openHistory() end
    end
    clientHandlers["openRoleInfo"] = function()
        if ctx.RoleInfo and ctx.RoleInfo.open then ctx.RoleInfo.open() end
    end

    clientHandlers["setCoreGui"] = function(typeName, state)
        local StarterGui = game:GetService("StarterGui")
        local ok, current = pcall(StarterGui.GetCoreGuiEnabled, StarterGui, Enum.CoreGuiType[typeName])
        if not ok then return end
        local newState
        if state == nil then newState = not current
        else newState = state and true or false end
        pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType[typeName], newState)
    end
    clientHandlers["setResetButton"] = function(state)
        local StarterGui = game:GetService("StarterGui")
        pcall(StarterGui.SetCore, StarterGui, "ResetButtonCallback", state ~= false)
    end
    clientHandlers["showHint"] = function(text, duration)
        if ctx.Hint then ctx.Hint:show(tostring(text or ""), tonumber(duration) or 8) end
    end

    clientHandlers["bubbleChat"] = function(text)
        local Chat = game:GetService("Chat")
        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if head and text then pcall(Chat.Chat, Chat, head, tostring(text), Enum.ChatColor.White) end
    end

    clientHandlers["toggleCommandBar"] = function(state)
        if ctx.togglePopup then ctx.togglePopup(state and true or false) end
    end

    clientHandlers["openPage"] = function(pageName)
        if not ctx.screen.Enabled then ctx.toggleScreen(true) end
        if ctx.showOnly and pageName then ctx.showOnly(tostring(pageName)) end
    end

    local FLY_BG, FLY_BV, FLY_LOOP
    local function stopFly()
        if FLY_LOOP then FLY_LOOP:Disconnect(); FLY_LOOP = nil end
        if FLY_BG then FLY_BG:Destroy(); FLY_BG = nil end
        if FLY_BV then FLY_BV:Destroy(); FLY_BV = nil end
    end
    clientHandlers["flyStart"] = function(speed)
        speed = tonumber(speed) or 50
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        stopFly()
        hum.PlatformStand = true
        FLY_BG = Instance.new("BodyGyro");     FLY_BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9); FLY_BG.P = 1e4; FLY_BG.D = 500; FLY_BG.Parent = hrp
        FLY_BV = Instance.new("BodyVelocity"); FLY_BV.MaxForce = Vector3.new(9e9, 9e9, 9e9); FLY_BV.Velocity = Vector3.zero; FLY_BV.Parent = hrp
        local cam = Workspace.CurrentCamera
        FLY_LOOP = RunService.RenderStepped:Connect(function()
            if not (hrp and hrp.Parent and FLY_BV and FLY_BG) then return end
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            FLY_BV.Velocity = (move.Magnitude > 0 and move.Unit or Vector3.zero) * speed
            FLY_BG.CFrame   = cam.CFrame
        end)
    end
    clientHandlers["flyStop"] = function()
        stopFly()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end

    local NOCLIP_CONN
    local function stopNoclip()
        if NOCLIP_CONN then NOCLIP_CONN:Disconnect(); NOCLIP_CONN = nil end
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.Anchored = false end
        if hum then hum.PlatformStand = false end
    end
    clientHandlers["noclipStart"] = function(speed)
        speed = tonumber(speed) or 50
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        stopNoclip()
        hum.PlatformStand = true
        local cam = Workspace.CurrentCamera
        NOCLIP_CONN = RunService.RenderStepped:Connect(function(dt)
            local c  = LocalPlayer.Character
            local rp = c and c:FindFirstChild("HumanoidRootPart")
            if not rp then return end
            rp.Anchored = true
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then move += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                rp.CFrame = rp.CFrame + move.Unit * speed * dt
            end
        end)
    end
    clientHandlers["noclipStop"] = function()
        stopNoclip()
    end

    RemoteEvent.OnClientEvent:Connect(function(rtype, ...)
        local h = clientHandlers[rtype]
        if h then
            local ok, err = pcall(h, ...)
            if not ok then warn("[uxrAPS v5] handler", rtype, "failed:", err) end
        end
    end)

    ctx.clientHandlers = clientHandlers
end

return EventDispatch
