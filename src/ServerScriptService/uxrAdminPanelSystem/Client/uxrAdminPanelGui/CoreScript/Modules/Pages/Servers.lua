--!nocheck

local Servers = {}

local function formatJobId(jobId)
    if not jobId or jobId == "" then return "studio-playtest" end
    if jobId:find("-") then return jobId end
    if #jobId >= 32 then
        return string.format("%s-%s-%s-%s-%s",
            jobId:sub(1, 8), jobId:sub(9, 12), jobId:sub(13, 16),
            jobId:sub(17, 20), jobId:sub(21, 32))
    end
    return jobId
end

function Servers.init(ctx)
    local Players   = ctx.Players
    local Templates = ctx.Templates
    local uxrRS     = ctx.uxrRS

    local page         = ctx.pages.Servers
    local serverListSF = page.ServerListFrame:FindFirstChildWhichIsA("ScrollingFrame")
    local serversFolder = uxrRS.Core:FindFirstChild("Servers")

    local function fillServerRow(row, info)
        Templates.safeText(row, "ServerIdTextLabel", formatJobId(info.id))

        local loc
        if info.country and info.region then
            loc = string.upper(tostring(info.country)) .. "/" .. string.upper(tostring(info.region))
        elseif info.location and info.location ~= "" then
            loc = tostring(info.location)
        else
            loc = "Unknown"
        end
        Templates.safeText(row, "LocationTextLabel", loc)

        local online = row:FindFirstChild("OnlineFrame")
        if online then
            local p = info.players or 0
            local m = info.maxPlayers or Players.MaxPlayers
            Templates.safeText(online, "TextLabel", string.format("%d/%d", p, m))
        end
    end

    local function refreshServers(filter)
        Templates.clearList(serverListSF)
        filter = (filter or ""):lower()

        local localInfo = {
            id         = game.JobId,
            location   = "",
            players    = #Players:GetPlayers(),
            maxPlayers = Players.MaxPlayers,
        }
        local localIdDisplay = formatJobId(localInfo.id)
        if filter == "" or localIdDisplay:lower():find(filter, 1, true) then
            local row = Templates.cloneTemplate(serverListSF)
            if row then fillServerRow(row, localInfo) end
        end

        if serversFolder then
            for _, child in ipairs(serversFolder:GetChildren()) do
                local id = child:GetAttribute("id") or child.Name
                if id ~= game.JobId then
                    if filter == "" or tostring(id):lower():find(filter, 1, true) then
                        local row = Templates.cloneTemplate(serverListSF)
                        if not row then break end
                        fillServerRow(row, {
                            id         = id,
                            location   = child:GetAttribute("Location") or "",
                            players    = child:GetAttribute("Players") or 0,
                            maxPlayers = child:GetAttribute("MaxPlayers") or Players.MaxPlayers,
                        })
                    end
                end
            end
        end
    end

    page.SearchFrame.SearchTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshServers(page.SearchFrame.SearchTextBox.Text)
    end)

    ctx.refreshHooks.Servers = function()
        refreshServers(page.SearchFrame.SearchTextBox.Text)
    end

    if serversFolder then
        serversFolder.ChildAdded:Connect(function()
            refreshServers(page.SearchFrame.SearchTextBox.Text)
        end)
        serversFolder.ChildRemoved:Connect(function()
            refreshServers(page.SearchFrame.SearchTextBox.Text)
        end)
    end
    Players.PlayerAdded:Connect(function()
        refreshServers(page.SearchFrame.SearchTextBox.Text)
    end)
    Players.PlayerRemoving:Connect(function()
        refreshServers(page.SearchFrame.SearchTextBox.Text)
    end)
end

return Servers
