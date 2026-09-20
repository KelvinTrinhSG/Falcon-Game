--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function waitFor(parent, name)
	local inst = parent:WaitForChild(name, 10)
	if not inst then
		warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name)
	end
	return inst
end

local uxrWS = waitFor(Workspace, "uxrAdminPanelSystem")
local uxrRS = waitFor(ReplicatedStorage, "uxrAdminPanelSystem")
local apEvents = waitFor(waitFor(uxrRS, "Core"), "apEvents")
local WorkspaceBuilds = waitFor(uxrWS, "Builds")

local Permissions = require(uxrRS.Config.Permissions)
local Settings = require(uxrRS.Config.Settings)
local PlayerDataManager = require(script.Parent.PlayerDataManager)
local UtilModule = require(uxrRS.Lib.Util)

local PlayerLifecycle = {}

local function playerAdded(player)
	UtilModule:LoadPermRank(player.UserId)

	local rank = UtilModule:GetRank(player)
	if rank and rank.Level < 0 then
		player:Kick(string.format("You are %s — access denied.", rank.Name))
		return
	end

	local punishData = PlayerDataManager:LoadPunishmentData(player.UserId)

	if punishData.PermaMute or (punishData.MuteTime > 0 and punishData.MuteTime > os.time()) then apEvents.RemoteEvent:FireClient(player, "selfMute") end
	if PlayerDataManager.GiveServerData(PlayerDataManager).Lockdown then player:Kick(Settings.Messages.LockdownKick) end
	if PlayerDataManager.GiveServerData(PlayerDataManager).Locked then player:Kick(Settings.Messages.LockedKick) end

	local savedJailData = PlayerDataManager.GetSavedJailData and PlayerDataManager:GetSavedJailData(player.UserId)

	if savedJailData and savedJailData.GlobalJailEndTime == nil and savedJailData.GlobalPlayerJailed then
		PlayerDataManager:ClearSavedJailData(player.UserId)
		savedJailData = nil
	end

	PlayerDataManager:AddLocalPlayerData(
		player,
		false,
		false,
		0
	)

	if savedJailData then
		local playerData = PlayerDataManager:GiveLocalPlayerData(player)
		if playerData then
			playerData.LocalPlayerJailed = savedJailData.LocalPlayerJailed or false
			playerData.GlobalPlayerJailed = savedJailData.GlobalPlayerJailed or false
			playerData.LocalJailEndTime = savedJailData.LocalJailEndTime or 0
			playerData.GlobalJailEndTime = savedJailData.GlobalJailEndTime or 0

			if playerData.GlobalPlayerJailed or playerData.LocalPlayerJailed then

				task.spawn(function()
					local character = player.Character
					if not character then
						character = player.CharacterAdded:Wait()
					end
					task.wait(0.5)

					local jailExpired = PlayerDataManager:CheckJailExpiry(player)
					local updatedPlayerData = PlayerDataManager:GiveLocalPlayerData(player)

					if jailExpired then
						PlayerDataManager:ClearSavedJailData(player.UserId)
						return
					end

					if updatedPlayerData and updatedPlayerData.GlobalPlayerJailed then
						local cell = WorkspaceBuilds:FindFirstChild("PublicCell")
						local spawn = cell and cell:FindFirstChild("SpawnPart")
						if spawn then UtilModule.StandCharacterOn(character, spawn) end
					elseif updatedPlayerData and updatedPlayerData.LocalPlayerJailed then
						local jcell = WorkspaceBuilds:FindFirstChild(player.Name.."JailCell")
						local spawn = jcell and jcell:FindFirstChild("SpawnPart")
						if spawn then UtilModule.StandCharacterOn(character, spawn) end
					end
				end)
			end
		end
	end

	PlayerDataManager:AddGlobalPlayerData(
		player,
		0,
		nil,
		nil,
		punishData.MuteTime,
		punishData.MuteReason,
		punishData.Muter
	)
	player.CharacterAdded:Connect(function(character)
		if not PlayerDataManager:GiveServerData(PlayerDataManager).PVP then
			local Character = player.Character
			if Character then
				local ForceField = Instance.new("ForceField")
				ForceField.Name = "PVPField"
				ForceField.Visible = false
				ForceField.Parent = Character
			end
		end

		local jailExpired = PlayerDataManager:CheckJailExpiry(player)

		task.wait(0.1)

		local playerData = PlayerDataManager:GiveLocalPlayerData(player)
		if playerData then

			if playerData.GlobalPlayerJailed then
				local cell = WorkspaceBuilds:FindFirstChild("PublicCell")
				local spawn = cell and cell:FindFirstChild("SpawnPart")
				if spawn then UtilModule.StandCharacterOn(character, spawn) end
			elseif playerData.LocalPlayerJailed then
				local jcell = WorkspaceBuilds:FindFirstChild(player.Name.."JailCell")
				local spawn = jcell and jcell:FindFirstChild("SpawnPart")
				if spawn then UtilModule.StandCharacterOn(character, spawn) end
			end
		end
	end)
end

function PlayerLifecycle.init()
	for _, v in pairs(Players:GetPlayers()) do
		task.spawn(playerAdded, v)
	end

	Players.PlayerAdded:Connect(function(player)
		playerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		local playerData = PlayerDataManager:GiveLocalPlayerData(player)
		if playerData then
			PlayerDataManager:SaveJailData(player.UserId, {
				LocalPlayerJailed = playerData.LocalPlayerJailed,
				GlobalPlayerJailed = playerData.GlobalPlayerJailed,
				LocalJailEndTime = playerData.LocalJailEndTime,
				GlobalJailEndTime = playerData.GlobalJailEndTime
			})
		end

		PlayerDataManager:RemoveLocalPlayerData(player)
	end)

	game:BindToClose(function()
	end)
end

return PlayerLifecycle
