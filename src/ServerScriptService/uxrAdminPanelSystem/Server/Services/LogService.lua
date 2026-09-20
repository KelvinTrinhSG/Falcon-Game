--!nocheck

local HttpService = game:GetService("HttpService")

local MAX_LOGS = 500

local LogService = {}

local Logs = {}
local LogCount = 0

local function getUserIdFromInput(playerInput)
	if typeof(playerInput) == "Instance" and playerInput:IsA("Player") then
		return playerInput.UserId
	elseif typeof(playerInput) == "number" then
		return playerInput
	elseif typeof(playerInput) == "string" and tonumber(playerInput) then
		return tonumber(playerInput)
	end
	return nil
end

function LogService:Add(admin, command, target, description)
	local userId = getUserIdFromInput(admin)
	if not userId then return false end

	local adminName = (typeof(admin) == "Instance" and admin:IsA("Player")) and admin.Name or tostring(admin)
	local id = HttpService:GenerateGUID(false)

	Logs[id] = {
		id          = id,
		userId      = userId,
		adminName   = adminName,
		command     = tostring(command or ""),
		target      = tostring(target or ""),
		description = tostring(description or ""),
		time        = os.time(),
		date        = os.date("!*t", os.time()),
		dateString  = os.date(),
	}
	LogCount += 1

	if LogCount > MAX_LOGS then
		local ids = table.create(LogCount)
		for k in pairs(Logs) do
			ids[#ids + 1] = k
		end
		table.sort(ids, function(a, b)
			return Logs[a].time < Logs[b].time
		end)
		local i = 1
		while LogCount > MAX_LOGS and i <= #ids do
			Logs[ids[i]] = nil
			LogCount -= 1
			i += 1
		end
	end
	return true
end

function LogService:GetAll()
	return Logs
end

return LogService
