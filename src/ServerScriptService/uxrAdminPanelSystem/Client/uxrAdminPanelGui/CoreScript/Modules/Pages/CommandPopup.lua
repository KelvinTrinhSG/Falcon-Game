--!nocheck

local CommandPopup = {}

function CommandPopup.init(ctx)
    local UserInputService = ctx.UserInputService
    local screen           = ctx.screen
    local commandFrame     = ctx.commandFrame
    local RemoteEvent      = ctx.RemoteEvent
    local Settings         = ctx.Settings
    local Commands         = ctx.Commands
    local UtilModule       = ctx.UtilModule
    local LocalPlayer      = ctx.LocalPlayer
    local Format           = ctx.Format
    local Templates        = ctx.Templates
    local getCommandRank   = ctx.Ranks.getCommandRank

    local cmdPopupSF = commandFrame.CommandListFrame:FindFirstChildWhichIsA("ScrollingFrame")
    local cmdBox     = commandFrame.SearchFrame.SearchTextBox

    local function fillPopupRow(row, cmd, onClick)
        local nameFrame = row:FindFirstChild("NameFrame")
        if nameFrame then
            Templates.safeText(nameFrame, "CommandNameTextLabel", (Settings.Prefix or "") .. (cmd.Name or ""))
            Templates.safeText(nameFrame, "DescriptionTextLabel", cmd.Description or "")
        end
        Format.applyRankBadge(row:FindFirstChild("RankFrame"), getCommandRank(cmd))
        local btn = row:FindFirstChild("ClickButton")
        if btn then btn.MouseButton1Click:Connect(onClick) end
    end

    local function stripPrefix(text)
        local pre = Settings.Prefix
        if pre and pre ~= "" and text:sub(1, #pre):lower() == pre:lower() then
            return text:sub(#pre + 1)
        end
        return text
    end

    local function lookupCommand(token)
        local key = (token or ""):lower()
        if Commands[key] then return key, Commands[key] end
        for name, cmd in pairs(Commands) do
            if name:lower() == key then return name, cmd end
        end
        for name, cmd in pairs(Commands) do
            for _, a in ipairs(cmd.Aliases or {}) do
                if a:lower() == key then return name, cmd end
            end
        end
        return nil, nil
    end

    local function findMissingRequiredArg(cmd, words)
        for i, spec in ipairs(cmd.Args or {}) do
            local raw = words[i + 1]
            local present = raw and raw ~= ""
            local hasDefault = spec.default ~= nil
            local isOptional = spec.optional
            if not present and not hasDefault and not isOptional then
                return i, spec
            end
        end
        return nil, nil
    end


    local function actuallyFire(text)
        RemoteEvent:FireServer("command", text)
    end

    local function fireCommandText(text)
        text = (text or ""):match("^%s*(.-)%s*$")
        if text == "" then return end
        text = stripPrefix(text)
        if ctx.state.selectedTarget and not text:find("%s") then
            text = text .. " " .. ctx.state.selectedTarget
        end

        local words = {}
        for w in text:gmatch("%S+") do table.insert(words, w) end
        if #words == 0 then return end

        local cmdName, cmd = lookupCommand(words[1])

        if not cmd then return actuallyFire(text) end

        local COMPOSER_KIND = {
            ban      = { category = "ban",  initialTab = "Permanent" },
            tempban  = { category = "ban",  initialTab = "Temporary" },
            mute     = { category = "mute", initialTab = "Mute"      },
            tempmute = { category = "mute", initialTab = "TempMute"  },
        }
        local composerSpec = COMPOSER_KIND[cmdName]
        if composerSpec and ctx.Punishment then
            return ctx.Punishment.open({
                target     = words[2] or "",
                category   = composerSpec.category,
                initialTab = composerSpec.initialTab,
            })
        end

        local _, missingSpec = findMissingRequiredArg(cmd, words)
        if missingSpec and ctx.Composer then
            return ctx.Composer.open({
                cmd = cmd, commandName = cmdName, words = words,
                onSubmit = function(builtText) fireCommandText(builtText) end,
            })
        end

        if cmd.Confirm then
            return ctx.Modal.confirm({
                title = "Run `" .. (Settings.Prefix or "") .. cmdName .. "`?",
                body  = "`" .. (Settings.Prefix or "") .. text .. "`\n\nThis action is destructive and cannot be undone.",
                yes = "Run", no = "Cancel", kind = "danger",
                onConfirm = function() actuallyFire(text) end,
            })
        end

        actuallyFire(text)
    end

    ctx.runCommand = fireCommandText

    cmdBox.FocusLost:Connect(function(enter)
        if enter then
            fireCommandText(cmdBox.Text)
            cmdBox.Text = ""
            ctx.state.selectedTarget = nil
            ctx.togglePopup(false)
        end
    end)

    local mainFrame = ctx.mainFrame
    local function openCmdPopupOnly()
        local screenWasEnabled = screen.Enabled
        if not screenWasEnabled then
            mainFrame.Visible = false
            screen.Enabled    = true
        end
        ctx.togglePopup(true)
        cmdBox:CaptureFocus()
        ctx.state._popupOpenedSolo = not screenWasEnabled
    end
    local function closeCmdPopup()
        ctx.togglePopup(false)
        if ctx.state._popupOpenedSolo then
            ctx.state._popupOpenedSolo = nil
            mainFrame.Visible = true
            screen.Enabled    = false
        end
    end
    local function toggleCmdPopup()
        local minRank = ctx.Permissions and ctx.Permissions.CommandBarRank or "VIP"
        if not UtilModule:HasRank(LocalPlayer, minRank) then return end
        if commandFrame.Visible then closeCmdPopup() else openCmdPopupOnly() end
    end

    local function togglePanel()
        if commandFrame.Visible then ctx.togglePopup(false) end
        if ctx.state._popupOpenedSolo then
            ctx.state._popupOpenedSolo = nil
            mainFrame.Visible = true
        end
        ctx.toggleScreen()
    end

    local HOTKEY_ATTR_PREFIX = "uxrHotkey_"

    local function loadHotkeyOverride(action)
        local pg = ctx.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local raw = pg and pg:GetAttribute(HOTKEY_ATTR_PREFIX .. action)
        if type(raw) ~= "string" or raw == "" then return nil end
        local set = {}
        for kcName in raw:gmatch("[^,]+") do
            local kc = Enum.KeyCode[kcName]
            if kc then set[kc] = true end
        end
        return next(set) and set or nil
    end

    local function buildLayoutKeyMap()
        local popup, panel = {}, {}
        for _, kc in ipairs(Enum.KeyCode:GetEnumItems()) do
            local ok, s = pcall(UserInputService.GetStringForKeyCode, UserInputService, kc)
            if ok and type(s) == "string" then
                if s == ";" then popup[kc] = true end
                if s == "/" then panel[kc] = true end
            end
        end
        popup[Enum.KeyCode.Semicolon]    = true
        popup[Enum.KeyCode.BackSlash]    = true
        panel[Enum.KeyCode.Slash]        = true
        panel[Enum.KeyCode.KeypadDivide] = true
        return popup, panel
    end

    local popupKeys, panelKeys
    local function rebuildHotkeys()
        local p, n = buildLayoutKeyMap()
        local poOverride = loadHotkeyOverride("popup")
        local paOverride = loadHotkeyOverride("panel")
        popupKeys = poOverride or p
        panelKeys = paOverride or n
    end
    rebuildHotkeys()

    do
        local pg = ctx.LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            pg:GetAttributeChangedSignal(HOTKEY_ATTR_PREFIX .. "popup")
              :Connect(rebuildHotkeys)
            pg:GetAttributeChangedSignal(HOTKEY_ATTR_PREFIX .. "panel")
              :Connect(rebuildHotkeys)
        end
    end

    local function shiftHeld()
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local kc = input.KeyCode

        if popupKeys[kc] then toggleCmdPopup(); return end
        if panelKeys[kc] then togglePanel();    return end

        if shiftHeld() then
            if kc == Enum.KeyCode.Comma then toggleCmdPopup(); return end
            if kc == Enum.KeyCode.Seven then togglePanel();    return end
        end
    end)

    do
        local TextChatService = game:GetService("TextChatService")
        local prefix = Settings.Prefix or "u!"

        local container = TextChatService:FindFirstChild("UxrAdminPanelCommands")
        if container then container:Destroy() end
        container = Instance.new("Folder")
        container.Name = "UxrAdminPanelCommands"
        container.Parent = TextChatService

        local function runLine(line)
            fireCommandText(line)
        end

        local function tail(unfilteredText)
            local _, e = unfilteredText:find("^%S+")
            local args = e and unfilteredText:sub(e + 1) or ""
            return args:match("^%s*(.-)%s*$")
        end

        local registered = {}
        local function register(name, primaryAlias, fn)
            if registered[primaryAlias] then return end
            registered[primaryAlias] = true
            local cmd = Instance.new("TextChatCommand")
            cmd.Name = name
            cmd.PrimaryAlias = primaryAlias
            cmd.Triggered:Connect(function(_textSource, unfilteredText)
                fn(unfilteredText or primaryAlias)
            end)
            cmd.Parent = container
        end

        register("PanelToggle", prefix,             function() togglePanel() end)
        register("PopupToggle", prefix .. "cmd",    function() toggleCmdPopup() end)

        for cmdName, cmd in pairs(Commands) do
            local function handler(unfilteredText)
                local args = tail(unfilteredText)
                local line = cmdName
                if args ~= "" then line = line .. " " .. args end
                runLine(line)
            end

            register("Cmd_"..cmdName, prefix .. cmdName, handler)
            register("Cmd_"..cmdName.."_lower", (prefix .. cmdName):lower(), handler)

            for i, alias in ipairs(cmd.Aliases or {}) do
                register("Alias_"..cmdName.."_"..i, prefix .. alias, handler)
                register("Alias_"..cmdName.."_"..i.."_lower",
                    (prefix .. alias):lower(), handler)
            end
        end
    end

    local resolveCommandName = lookupCommand

    local function makeSyntheticRow(label, description, onClick)
        local row = Templates.cloneTemplate(cmdPopupSF)
        if not row then return end
        local nameFrame = row:FindFirstChild("NameFrame")
        if nameFrame then
            Templates.safeText(nameFrame, "CommandNameTextLabel", label)
            Templates.safeText(nameFrame, "DescriptionTextLabel", description or "")
        end
        local rf = row:FindFirstChild("RankFrame")
        if rf then rf.Visible = false end
        local btn = row:FindFirstChild("ClickButton")
        if btn and onClick then btn.MouseButton1Click:Connect(onClick) end
    end

    local function applyTokenAt(text, argIdx, replacement)
        local words = {}
        for w in text:gmatch("%S+") do table.insert(words, w) end
        local boundary = argIdx + 1
        if #words < boundary then
            table.insert(words, replacement)
        else
            words[boundary] = replacement
        end
        return table.concat(words, " ") .. " "
    end

    local function suggestForArg(rawText, argSpec, argIdx, partial)
        partial = (partial or ""):lower()
        local prefix = Settings.Prefix or ""

        local function add(token, hint)
            if partial ~= "" and not token:lower():find(partial, 1, true) then return end
            makeSyntheticRow(token, hint or "", function()
                cmdBox.Text = applyTokenAt(stripPrefix(rawText), argIdx, token)
                cmdBox.Text = prefix .. cmdBox.Text
                cmdBox:CaptureFocus()
                cmdBox.CursorPosition = #cmdBox.Text + 1
            end)
        end

        if argSpec.type == "Players" then
            add("me",      "yourself")
            add("all",     "everyone")
            add("others",  "everyone except you")
            add("random",  "one random player")
            for _, p in ipairs(ctx.Players:GetPlayers()) do
                add(p.Name, p.DisplayName ~= p.Name and ("@" .. p.DisplayName) or "")
            end
        elseif argSpec.type == "Rank" then
            for _, r in ipairs(ctx.Permissions.Ranks) do add(r.Name, "rank") end
        elseif argSpec.type == "Material" then
            for _, m in ipairs(Enum.Material:GetEnumItems()) do add(m.Name, "material") end
        elseif argSpec.type == "Team" then
            for _, t in ipairs(game:GetService("Teams"):GetTeams()) do add(t.Name, "team") end
        elseif argSpec.type == "Bool" then
            add("true"); add("false")
        elseif argSpec.oneOf then
            for _, v in ipairs(argSpec.oneOf) do add(v) end
        else
            local hint = ("expects %s"):format(argSpec.type)
            if argSpec.default ~= nil then hint = hint .. ", default: " .. tostring(argSpec.default) end
            makeSyntheticRow(("<%s>"):format(argSpec.name), hint)
        end
    end

    local function refreshCommandPopupList(filter)
        Templates.clearList(cmdPopupSF)
        local raw = (filter or ""):match("^%s*(.-)%s*$") or ""
        local body = stripPrefix(raw)

        local words = {}
        for w in body:gmatch("%S+") do table.insert(words, w) end

        local hasTrailingSpace = body:sub(-1) == " " or (raw ~= "" and raw:sub(-1) == " ")

        if #words >= 1 then
            local cmdName, cmd = resolveCommandName(words[1])
            if cmd and (#words >= 2 or hasTrailingSpace) and cmd.Args and #cmd.Args > 0 then
                local argIdx = hasTrailingSpace and #words or (#words - 1)
                argIdx = math.max(argIdx, 1)
                local argSpec = cmd.Args[argIdx]
                if argSpec then
                    makeSyntheticRow(cmd.CommandText or cmdName, cmd.Description or "")
                    local partial = hasTrailingSpace and "" or (words[#words] or "")
                    suggestForArg(raw, argSpec, argIdx, partial)
                    return
                end
            end
        end

        local first = (words[1] or ""):lower()
        local function matches(name, cmd)
            if not UtilModule:CanRunCommand(LocalPlayer, cmd) then return false end
            if first == "" then return true end
            if name:lower():find(first, 1, true) then return true end
            for _, a in ipairs(cmd.Aliases or {}) do
                if a:lower():find(first, 1, true) then return true end
            end
            return false
        end

        local MAX = 12
        for _, entry in ipairs(ctx.sortedCommands(matches)) do
            if MAX <= 0 then break end
            local row = Templates.cloneTemplate(cmdPopupSF)
            if row then
                local name = entry.name
                fillPopupRow(row, entry.cmd, function()
                    cmdBox.Text = (Settings.Prefix or "") .. name .. " "
                    cmdBox:CaptureFocus()
                    cmdBox.CursorPosition = #cmdBox.Text + 1
                end)
                MAX -= 1
            end
        end
    end

    cmdBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshCommandPopupList(cmdBox.Text)
    end)
    refreshCommandPopupList("")

    ctx.CommandPopup = {
        cmdBox             = cmdBox,
        fireCommandText    = fireCommandText,
        stripPrefix        = stripPrefix,
        refreshList        = refreshCommandPopupList,
    }
end

return CommandPopup
