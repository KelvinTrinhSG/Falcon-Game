--!nocheck

local Format = {}

local DEFAULT_RANK_COLOR = "#FFFFFF"
local DEFAULT_RANK_NAME  = "Player"

function Format.rankDisplayName(rank)
    if not rank then return DEFAULT_RANK_NAME end
    return rank.DisplayName or rank.displayName or rank.Name or rank.name or DEFAULT_RANK_NAME
end

function Format.fmtRankTag(rank)
    rank = rank or {}
    return string.format(
        '<font color="#666668">Rank  </font><font color="%s">[%s]</font>',
        rank.Color or DEFAULT_RANK_COLOR, Format.rankDisplayName(rank)
    )
end

function Format.fmtRankNameOnly(rank)
    rank = rank or {}
    return string.format(
        '<font color="%s">%s</font>',
        rank.Color or DEFAULT_RANK_COLOR, Format.rankDisplayName(rank)
    )
end

function Format.fmtMemory(mb)
    return string.format(
        '<font color="#d0b063">Memory Usage:</font><font color="#FFFFFF"> %d MB</font>',
        math.floor(mb)
    )
end

function Format.fmtPing(ms)
    return string.format(
        '<font color="#d0b063">Avg. Ping:</font><font color="#FFFFFF"> %d ms</font>',
        math.floor(ms)
    )
end

function Format.fmtFps(f)
    return string.format("FPS %.1f/s", f)
end

function Format.fmtPlayersCount(count, max)
    return string.format(
        '<font size="32" color="#3498db">%d</font><font size="20" color="#333333">  / </font><font size="18" color="#333333">%d</font>',
        count, max
    )
end

function Format.fmtColoredNumber(value, hexColor)
    return string.format('<font size="34" color="%s">%s</font>',
        hexColor or "#FFFFFF", tostring(value))
end

function Format.fmtServerAge(seconds)
    seconds = math.max(0, math.floor(seconds))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

function Format.fmtClockShort(t)
    return (os.date("%I:%M %p", t):gsub("^0", ""))
end

function Format.fmtLastUpdate(t)
    return "Last Update " .. Format.fmtClockShort(t)
end

function Format.hexToColor3(hex)
    hex = (hex or "#888888"):gsub("^#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 128
    local g = tonumber(hex:sub(3, 4), 16) or 128
    local b = tonumber(hex:sub(5, 6), 16) or 128
    return Color3.fromRGB(r, g, b)
end

function Format.applyRankBadge(rankFrame, rank)
    if not rankFrame then return end
    rank = rank or { Color = DEFAULT_RANK_COLOR, Name = DEFAULT_RANK_NAME }
    local color = Format.hexToColor3(rank.Color)
    rankFrame.BackgroundColor3      = color
    rankFrame.BackgroundTransparency = 0
    local grad = rankFrame:FindFirstChildOfClass("UIGradient")
    if grad then grad.Enabled = false end
    local stroke = rankFrame:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color = color end
    local label = rankFrame:FindFirstChild("TextLabel")
    if label then
        label.RichText = false
        label.Text = Format.rankDisplayName(rank)
    end
end

function Format.relative(epoch)
    if not epoch or type(epoch) ~= "number" then return "" end
    local now = os.time()
    local diff = now - epoch
    local abs = math.abs(diff)
    local future = diff < 0

    if abs < 60     then return future and "Soon"           or "Just now" end
    if abs < 3600   then
        local m = math.floor(abs / 60)
        return future and ("In "..m.."m") or (m.."m ago")
    end
    if abs < 86400  then
        local h = math.floor(abs / 3600)
        return future and ("In "..h.."h") or (h.."h ago")
    end
    if abs < 86400 * 2 then
        return future and "Tomorrow" or "Yesterday"
    end
    if abs < 86400 * 7 then
        local d = math.floor(abs / 86400)
        return future and ("In "..d.." days") or (d.." days ago")
    end
    if abs < 86400 * 30 then
        local w = math.floor(abs / 604800)
        return future and ("In "..w.."w") or (w.."w ago")
    end
    if abs < 86400 * 365 then
        local mo = math.floor(abs / 2592000)
        return future and ("In "..mo.."mo") or (mo.."mo ago")
    end
    local y = math.floor(abs / 31536000)
    return future and ("In "..y.."y") or (y.."y ago")
end

function Format.duration(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if d > 0 then return string.format("%dd %02d:%02d:%02d", d, h, m, s) end
    return string.format("%02d:%02d:%02d", h, m, s)
end

function Format.durationShort(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    if seconds >= 86400 then return math.floor(seconds / 86400).."d" end
    if seconds >= 3600  then return math.floor(seconds / 3600).."h"  end
    if seconds >= 60    then return math.floor(seconds / 60).."m"    end
    return seconds.."s"
end

return Format
