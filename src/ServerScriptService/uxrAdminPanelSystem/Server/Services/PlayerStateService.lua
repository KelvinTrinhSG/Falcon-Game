--!nocheck

local Players = game:GetService("Players")

local PlayerStateService = {}

local LocalPlayerDataList = {}

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

function PlayerStateService:GetUserIdFromInput(playerInput)
	return getUserIdFromInput(playerInput)
end

function PlayerStateService:GetPlayerFromUserId(userId)
	return Players:GetPlayerByUserId(userId)
end

function PlayerStateService:Add(player)
	local userId = getUserIdFromInput(player)
	if not userId then return end

	LocalPlayerDataList[userId] = {
		LocalPlayerJailed   = false,
		GlobalPlayerJailed  = false,
		LockdownWhitelist   = true,
		PlayerJailTime      = 0,
		LocalJailEndTime    = 0,
		GlobalJailEndTime   = 0,
	}
end

function PlayerStateService:Give(player)
	local userId = getUserIdFromInput(player)
	if not userId then return nil end
	return LocalPlayerDataList[userId]
end

function PlayerStateService:Remove(player)
	local userId = getUserIdFromInput(player)
	if not userId then return false end
	LocalPlayerDataList[userId] = nil
	return true
end

function PlayerStateService:Edit(player, key, value)
	local userId = getUserIdFromInput(player)
	if not userId then return nil end

	local playerData = LocalPlayerDataList[userId]
	if not playerData then
		self:Add(userId)
		playerData = LocalPlayerDataList[userId]
	end
	if playerData then
		playerData[key] = value
	end
	return playerData
end

function PlayerStateService:_getRow(userId)
	return LocalPlayerDataList[userId]
end

function PlayerStateService:SetJail(player, jailType, duration)
	local userId = getUserIdFromInput(player)
	if not userId then return false end

	local playerData = LocalPlayerDataList[userId]
	if not playerData then
		self:Add(userId)
		playerData = LocalPlayerDataList[userId]
	end

	if jailType == "Local" then
		playerData.LocalPlayerJailed = true
		playerData.LocalJailEndTime = duration > 0 and (os.time() + duration) or 0
	elseif jailType == "Global" then
		playerData.GlobalPlayerJailed = true
		playerData.GlobalJailEndTime = duration > 0 and (os.time() + duration) or 0
	end
	return true
end

function PlayerStateService:RemoveJail(player, jailType)
	local userId = getUserIdFromInput(player)
	if not userId then return false end

	local playerData = LocalPlayerDataList[userId]
	if not playerData then return false end

	if jailType == "Local" or jailType == "Both" then
		playerData.LocalPlayerJailed = false
		playerData.LocalJailEndTime = 0
	end
	if jailType == "Global" or jailType == "Both" then
		playerData.GlobalPlayerJailed = false
		playerData.GlobalJailEndTime = 0
	end
	return true
end

return PlayerStateService
