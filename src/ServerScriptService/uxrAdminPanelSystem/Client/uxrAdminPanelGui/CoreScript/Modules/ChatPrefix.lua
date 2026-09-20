--!nocheck

local Players         = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local ChatPrefix = {}

local function sanitize(value, maxLen)
    local s = tostring(value or ""):gsub("[<>\"'&]", "")
    if maxLen and #s > maxLen then s = s:sub(1, maxLen) end
    return s
end

local function validColor(value)
    local hex = tostring(value or ""):match("^#?(%x%x%x%x%x%x)$")
    return hex and ("#"..hex) or nil
end

local function buildProps(message)
    if not message.TextSource then return nil end
    local player = Players:GetPlayerByUserId(message.TextSource.UserId)
    if not player then return nil end

    local nick      = player:GetAttribute("uxrChatName")
    local nameColor = validColor(player:GetAttribute("uxrChatNameColor"))
    local tag       = player:GetAttribute("uxrChatTag")
    local tagColor  = validColor(player:GetAttribute("uxrChatTagColor"))

    local tagStr  = sanitize(tag, 24)
    local nickStr = sanitize(nick, 32)

    if tagStr == "" and nickStr == "" and not nameColor then
        return nil
    end

    local nameSegment
    if nickStr ~= "" or nameColor then
        if nickStr == "" then nickStr = player.DisplayName end
        nameSegment = string.format('<font color="%s">%s</font>:',
            nameColor or "#FFFFFF", nickStr)
    else
        nameSegment = message.PrefixText
    end

    local tagSegment = ""
    if tagStr ~= "" then
        tagSegment = string.format('<font color="%s">[%s]</font> ',
            tagColor or "#F1C40F", tagStr)
    end

    local props = Instance.new("TextChatMessageProperties")
    props.PrefixText = tagSegment .. nameSegment
    return props
end

local function attachToChannel(d)
    if d:IsA("TextChannel") then
        d.OnIncomingMessage = buildProps
    end
end

function ChatPrefix.init()
    TextChatService.OnIncomingMessage = buildProps
    for _, d in ipairs(TextChatService:GetDescendants()) do attachToChannel(d) end
    TextChatService.DescendantAdded:Connect(attachToChannel)
end

return ChatPrefix
