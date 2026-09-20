--!nocheck

local Commands_Page = {}

function Commands_Page.init(ctx)
    local Settings       = ctx.Settings
    local UtilModule     = ctx.UtilModule
    local LocalPlayer    = ctx.LocalPlayer
    local commandFrame   = ctx.commandFrame
    local Format         = ctx.Format
    local Templates      = ctx.Templates
    local getCommandRank = ctx.Ranks.getCommandRank

    local page       = ctx.pages.Commands
    local cmdsListSF = page.CommandListFrame:FindFirstChildWhichIsA("ScrollingFrame")

    local function fillCommandRow(row, cmd, onClick)
        Templates.safeText(row, "CommandTextLabel",     (Settings.Prefix or "") .. (cmd.Name or ""))
        Templates.safeText(row, "DescriptionTextLabel", cmd.Description or "")
        Format.applyRankBadge(row:FindFirstChild("RankFrame"), getCommandRank(cmd))
        local btn = row:FindFirstChild("ClickButton")
        if btn then btn.MouseButton1Click:Connect(onClick) end
    end

    local function refreshCommandsList(filter)
        Templates.clearList(cmdsListSF)
        filter = (filter or ""):lower()

        local function fits(name, cmd)
            if not UtilModule:CanRunCommand(LocalPlayer, cmd) then return false end
            if filter == "" then return true end
            local hay = (name .. " " .. (cmd.CommandText or "") .. " " .. (cmd.Description or "")
                       .. " " .. (cmd.Category or "")):lower()
            if hay:find(filter, 1, true) then return true end
            for _, a in ipairs(cmd.Aliases or {}) do
                if a:lower():find(filter, 1, true) then return true end
            end
            return false
        end

        local rows = ctx.sortedCommands(fits)

        local PUNISH_TAB = {
            ban      = { category = "ban",  initialTab = "Permanent" },
            tempban  = { category = "ban",  initialTab = "Temporary" },
            mute     = { category = "mute", initialTab = "Mute"      },
            tempmute = { category = "mute", initialTab = "TempMute"  },
        }

        for _, entry in ipairs(rows) do
            local row = Templates.cloneTemplate(cmdsListSF)
            if row then
                fillCommandRow(row, entry.cmd, function()
                    local cmd = entry.cmd

                    local tab = PUNISH_TAB[entry.name]
                    if tab and ctx.Punishment then
                        return ctx.Punishment.open({
                            target = "", category = tab.category, initialTab = tab.initialTab,
                        })
                    end

                    if cmd.Args and #cmd.Args > 0 and ctx.Composer then
                        return ctx.Composer.open({
                            cmd = cmd, commandName = entry.name,
                            words = { entry.name },
                            onSubmit = function(builtText)
                                if ctx.runCommand then ctx.runCommand(builtText) end
                            end,
                        })
                    end

                    if ctx.runCommand then ctx.runCommand(entry.name) end
                end)
            end
        end
    end

    page.SearchFrame.SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshCommandsList(page.SearchFrame.SearchTextBox.Text)
    end)
    refreshCommandsList()

    ctx.refreshHooks.Commands = function()
        refreshCommandsList(page.SearchFrame.SearchTextBox.Text)
    end
end

return Commands_Page
