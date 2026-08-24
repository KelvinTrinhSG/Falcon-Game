--!strict
-- LOCATION: ServerScriptService > SettingsDataStore

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SettingsDataStore = DataStoreService:GetDataStore("PlayerSettings_v5") -- Version v4 propre
local SaveSettingsEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SaveSettingsEvent")

local sessionSettings = {}

-- 📥 CHARGEMENT : Quand un joueur rejoint la partie
Players.PlayerAdded:Connect(function(player)
	local userId = tostring(player.UserId)
	local success, savedData = pcall(function()
		return SettingsDataStore:GetAsync(userId)
	end)

	if success and type(savedData) == "table" then
		sessionSettings[player] = {
			SFX = savedData.SFX or 1,
			Music = savedData.Music or 1
		}
	else
		sessionSettings[player] = {
			SFX = 1,
			Music = 1
		}
	end

	SaveSettingsEvent:FireClient(player, sessionSettings[player])
end)

-- 📤 RECEPTION : Quand un joueur bouge sa barre
SaveSettingsEvent.OnServerEvent:Connect(function(player, settingName, newValue)
	if type(settingName) == "string" and type(newValue) == "number" then
		if not sessionSettings[player] then return end
		sessionSettings[player][settingName] = math.clamp(newValue, 0, 1)
	end
end)

-- 💾 SAUVEGARDE FINALE : Quand le joueur s'en va
Players.PlayerRemoving:Connect(function(player)
	local userId = tostring(player.UserId)
	local dataToSave = sessionSettings[player]

	if dataToSave then
		pcall(function()
			SettingsDataStore:SetAsync(userId, dataToSave)
		end)
	end
	sessionSettings[player] = nil
end)