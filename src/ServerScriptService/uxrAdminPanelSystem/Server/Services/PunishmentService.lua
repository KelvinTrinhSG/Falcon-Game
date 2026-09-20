--!nocheck

local DataStoreService = game:GetService("DataStoreService")
local Players          = game:GetService("Players")

local PlayerPunishmentData = DataStoreService:GetDataStore("PlayerPunishmentData_v2")

local PunishmentService = {}

local GlobalPlayerDataList = {}

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

local function defaultPunishmentRow()
	return {
		PermaBan       = false,
		BanTime        = 0,
		BanReason      = nil,
		Banner         = nil,
		PermaMute      = false,
		MuteTime       = 0,
		MuteReason     = nil,
		Muter          = nil,
		PunishmentLogs = {},
		Warnings       = {},
		Notes          = {},
	}
end

function PunishmentService:Load(player)
	local userId = getUserIdFromInput(player)
	if not userId then
		return defaultPunishmentRow()
	end

	local success, playerData = pcall(function()
		return PlayerPunishmentData:GetAsync(tostring(userId))
	end)

	if success and playerData then
		if playerData.PermaMute and not playerData.Muter then playerData.PermaMute = false end
		if playerData.PermaBan  and not playerData.Banner then playerData.PermaBan  = false end
		return playerData
	end
	return defaultPunishmentRow()
end

function PunishmentService:Save(player, data)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "Geçersiz oyuncu veya UserId" end

	local success, errorMessage = pcall(function()
		PlayerPunishmentData:SetAsync(tostring(userId), data)
	end)
	return success, errorMessage
end

function PunishmentService:AddGlobal(player, banTime, banReason, banner, muteTime, muteReason, muter)
	local userId = getUserIdFromInput(player)
	if not userId then return end

	GlobalPlayerDataList[userId] = {
		BanTime    = banTime,
		BanReason  = banReason,
		Banner     = banner,
		MuteTime   = muteTime,
		MuteReason = muteReason,
		Muter      = muter,
	}
end

function PunishmentService:RemoveGlobal(player)
	local userId = getUserIdFromInput(player)
	if not userId then return false end
	GlobalPlayerDataList[userId] = nil
	return true
end

function PunishmentService:GiveGlobal(player)
	local userId = getUserIdFromInput(player)
	if not userId then return nil end

	if not GlobalPlayerDataList[userId] then
		local punishmentData = self:Load(userId)
		self:AddGlobal(userId,
			punishmentData.BanTime or 0,
			punishmentData.BanReason,
			punishmentData.Banner,
			punishmentData.MuteTime or 0,
			punishmentData.MuteReason,
			punishmentData.Muter)
	end
	return GlobalPlayerDataList[userId]
end

function PunishmentService:EditGlobal(player, key, value)
	local userId = getUserIdFromInput(player)
	if not userId then return nil end

	local playerData = GlobalPlayerDataList[userId]
	if not playerData then
		local punishmentData = self:Load(userId)
		self:AddGlobal(userId,
			punishmentData.BanTime or 0,
			punishmentData.BanReason,
			punishmentData.Banner,
			punishmentData.MuteTime or 0,
			punishmentData.MuteReason,
			punishmentData.Muter)
		playerData = GlobalPlayerDataList[userId]
	end

	if playerData then
		playerData[key] = value

		local punishmentData = self:Load(userId)
		if key == "BanTime" then
			punishmentData.BanTime = value
		elseif key == "BanReason" then
			punishmentData.BanReason = value
		elseif key == "Banner" then
			punishmentData.Banner = value
		elseif key == "PermaBan" then
			punishmentData.PermaBan = value and true or false
		elseif key == "MuteTime" then
			punishmentData.MuteTime = value
		elseif key == "PermaMute" then
			punishmentData.PermaMute = value and true or false
		elseif key == "MuteReason" then
			punishmentData.MuteReason = value
		elseif key == "Muter" then
			punishmentData.Muter = value
		end
		self:Save(userId, punishmentData)
	end
	return playerData
end

function PunishmentService:GetAll()
	return GlobalPlayerDataList
end

function PunishmentService:Make(player, punishmentType, reason, duration, admin)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "Geçersiz oyuncu veya UserId" end

	local data = self:Load(userId)
	table.insert(data.PunishmentLogs, {
		Type     = punishmentType,
		Reason   = reason,
		duration = duration,
		Admin    = admin,
		Time     = os.date("%Y-%m-%d %H:%M:%S"),
	})

	if punishmentType == "Mute" then
		data.PermaMute  = (duration == 0)
		data.MuteTime   = duration + os.time()
		data.MuteReason = reason
		data.Muter      = admin

		local success = self:Save(userId, data)
		local playerInstance = Players:GetPlayerByUserId(userId)
		if playerInstance and success then
			self:EditGlobal(userId, "MuteTime",   data.MuteTime)
			self:EditGlobal(userId, "MuteReason", reason)
			self:EditGlobal(userId, "Muter",      admin)
		end
		return success, data
	end

	if punishmentType == "Ban" then
		local success = self:Save(userId, data)
		return success, data
	end

	return false, "Invalid punishment type"
end

function PunishmentService:Remove(player, punishmentType)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "Geçersiz oyuncu veya UserId" end

	local data = self:Load(userId)

	if punishmentType == "Mute" then
		data.PermaMute  = false
		data.MuteTime   = 0
		data.MuteReason = ""
		data.Muter      = ""

		local success = self:Save(userId, data)
		local playerInstance = Players:GetPlayerByUserId(userId)
		if playerInstance and success then
			self:EditGlobal(userId, "MuteTime",   0)
			self:EditGlobal(userId, "MuteReason", nil)
			self:EditGlobal(userId, "Muter",      nil)
		end
		return success, data
	end

	if punishmentType == "Ban" then
		return true, data
	end

	return false, "Invalid punishment type"
end

local warningsCache = {}

local function loadWarnings(self, userId)
	local entry = warningsCache[userId]
	if not entry then
		local pd = self:Load(userId)
		entry = { warnings = pd.Warnings or {}, dirty = false, online = false }
		if Players:GetPlayerByUserId(userId) then entry.online = true end
		warningsCache[userId] = entry
	end
	return entry
end

local function persistWarnings(self, userId, entry)
	local pd = self:Load(userId)
	pd.Warnings = entry.warnings
	local ok, err = self:Save(userId, pd)
	if ok then entry.dirty = false end
	return ok, err
end

function PunishmentService:AddWarning(player, reason, admin)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "invalid player" end

	local entry = loadWarnings(self, userId)
	table.insert(entry.warnings, {
		Reason = tostring(reason or "No reason provided"),
		Admin  = tostring(admin or "system"),
		Time   = os.time(),
		Date   = os.date("%Y-%m-%d %H:%M:%S"),
	})
	entry.dirty = true

	if entry.online then
		return true, #entry.warnings
	end
	local ok, err = persistWarnings(self, userId, entry)
	if not ok then return false, err end
	return true, #entry.warnings
end

function PunishmentService:RemoveLastWarning(player)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "invalid player" end

	local entry = loadWarnings(self, userId)
	if #entry.warnings == 0 then return false, "no warnings to remove" end
	local removed = table.remove(entry.warnings)
	entry.dirty = true
	if not entry.online then persistWarnings(self, userId, entry) end
	return true, removed
end

function PunishmentService:GetWarnings(player)
	local userId = getUserIdFromInput(player)
	if not userId then return {} end
	return loadWarnings(self, userId).warnings
end

local notesCache = {}

local function loadNotes(self, userId)
	local entry = notesCache[userId]
	if not entry then
		local pd = self:Load(userId)
		entry = { notes = pd.Notes or {}, dirty = false, online = false }
		if Players:GetPlayerByUserId(userId) then entry.online = true end
		notesCache[userId] = entry
	end
	return entry
end

local function persistNotes(self, userId, entry)
	local pd = self:Load(userId)
	pd.Notes = entry.notes
	local ok, err = self:Save(userId, pd)
	if ok then entry.dirty = false end
	return ok, err
end

function PunishmentService:AddNote(player, text, admin)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "invalid player" end
	if not text or text == "" then return false, "empty note" end

	local entry = loadNotes(self, userId)
	table.insert(entry.notes, {
		Text  = tostring(text),
		Admin = tostring(admin or "system"),
		Time  = os.time(),
		Date  = os.date("%Y-%m-%d %H:%M:%S"),
	})
	entry.dirty = true

	if entry.online then
		return true, #entry.notes
	end
	local ok, err = persistNotes(self, userId, entry)
	if not ok then return false, err end
	return true, #entry.notes
end

function PunishmentService:RemoveNote(player, index)
	local userId = getUserIdFromInput(player)
	if not userId then return false, "invalid player" end

	local entry = loadNotes(self, userId)
	if not entry.notes[index] then return false, "no note at index "..tostring(index) end
	local removed = table.remove(entry.notes, index)
	entry.dirty = true
	if not entry.online then persistNotes(self, userId, entry) end
	return true, removed
end

function PunishmentService:GetNotes(player)
	local userId = getUserIdFromInput(player)
	if not userId then return {} end
	return loadNotes(self, userId).notes
end

Players.PlayerRemoving:Connect(function(player)
	GlobalPlayerDataList[player.UserId] = nil

	local wEntry = warningsCache[player.UserId]
	if wEntry and wEntry.dirty then
		persistWarnings(PunishmentService, player.UserId, wEntry)
	end
	warningsCache[player.UserId] = nil

	local nEntry = notesCache[player.UserId]
	if nEntry and nEntry.dirty then
		persistNotes(PunishmentService, player.UserId, nEntry)
	end
	notesCache[player.UserId] = nil
end)

game:BindToClose(function()
	for userId, entry in pairs(warningsCache) do
		if entry.dirty then persistWarnings(PunishmentService, userId, entry) end
	end
	for userId, entry in pairs(notesCache) do
		if entry.dirty then persistNotes(PunishmentService, userId, entry) end
	end
end)

return PunishmentService
