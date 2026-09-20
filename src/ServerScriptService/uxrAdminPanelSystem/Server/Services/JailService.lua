--!nocheck

local DataStoreService = game:GetService("DataStoreService")

local PlayerStateService = require(script.Parent.PlayerStateService)

local PlayerJailData = DataStoreService:GetDataStore("PlayerJailData")

local JailService = {}

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

function JailService:Save(userId, jailData)
	local success, errorMessage = pcall(function()
		PlayerJailData:SetAsync(tostring(userId), jailData)
	end)
	return success, errorMessage
end

function JailService:GetSaved(userId)
	local success, data = pcall(function()
		return PlayerJailData:GetAsync(tostring(userId))
	end)
	if success and data then return data end
	return nil
end

function JailService:ClearSaved(userId)
	local success, errorMessage = pcall(function()
		PlayerJailData:RemoveAsync(tostring(userId))
	end)
	return success, errorMessage
end

function JailService:CheckExpiry(player)
	local userId = getUserIdFromInput(player)
	if not userId then return false end

	local playerData = PlayerStateService:_getRow(userId)
	if not playerData then return false end

	local currentTime = os.time()
	local jailExpired = false

	if playerData.LocalPlayerJailed and playerData.LocalJailEndTime > 0 then
		if currentTime >= playerData.LocalJailEndTime then
			playerData.LocalPlayerJailed = false
			playerData.LocalJailEndTime  = 0
			jailExpired = true
		end
	end

	if playerData.GlobalPlayerJailed and playerData.GlobalJailEndTime > 0 then
		if currentTime >= playerData.GlobalJailEndTime then
			playerData.GlobalPlayerJailed = false
			playerData.GlobalJailEndTime  = 0
			jailExpired = true
		end
	end

	return jailExpired
end

return JailService
