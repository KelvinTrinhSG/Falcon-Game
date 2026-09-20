--!nocheck

local HttpService = game:GetService("HttpService")
local Webhooks    = require(script.Parent.Parent.Config.Webhooks)

local WebhookService = {}

local function resolveUrl(commandName)
	local list = Webhooks.CommandWebhook or {}
	return list[commandName] or list["*"]
end

local function fetchAvatarUrl(userId)
	local url = "https://thumbnails.roproxy.com/v1/users/avatar-bust?userIds="
		..tostring(userId).."&size=420x420&format=Png&isCircular=false"
	local ok, response = pcall(HttpService.RequestAsync, HttpService, {
		Url = url, Method = "GET",
	})
	if not ok or not response or not response.Success then return nil end
	local ok2, body = pcall(HttpService.JSONDecode, HttpService, response.Body)
	if not ok2 or type(body) ~= "table" or not body.data or not body.data[1] then return nil end
	return body.data[1].imageUrl
end

function WebhookService:SendWebhook(userId, adminName, commandName, target)
	local webhookUrl = resolveUrl(commandName)
	if not webhookUrl or webhookUrl == "" or webhookUrl == "YOUR WEBHOOK LINK HERE" then
		return
	end

	local payload = {
		["username"] = "UXR Admin Panel — LOG",
		["embeds"] = { {
			["title"]       = "**NEW LOG**",
			["description"] = string.format(
				"**User:** %s (%s)\n**Command:** %s\n**Target/Value:** %s",
				tostring(adminName), tostring(userId),
				tostring(commandName), tostring(target or "—")
			),
			["type"]  = "rich",
			["color"] = 0x3246A8,
			["thumbnail"] = { ["url"] = fetchAvatarUrl(userId) or "" },
			["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
		} },
	}

	pcall(HttpService.PostAsync, HttpService, webhookUrl, HttpService:JSONEncode(payload))
end

return WebhookService
