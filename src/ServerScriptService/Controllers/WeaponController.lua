--!strict
-- This controller securely handles requests to equip, unequip, and select weapons.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WEAPONS_FOLDER = ReplicatedStorage:WaitForChild("Weapons")

local WaveController
local PlayerController
local WeaponController = {}

function WeaponController:UnequipWeapon(player: Player)
	local character = player.Character
	if not character then return end
	local existingTool = character:FindFirstChildOfClass("Tool")
	if existingTool then
		existingTool:Destroy()
	end
end

function WeaponController:EquipWeapon(player: Player, weaponName: string)
	local character = player.Character
	local profile = PlayerController:GetProfile(player)
	if not character or not profile then return end

	if not table.find(profile.Data.WeaponInventory, weaponName) then
		-- This can happen if the last equipped weapon was removed from their inventory later.
		-- Silently fail instead of printing a warning.
		return
	end

	self:UnequipWeapon(player)

	local weaponTemplate = WEAPONS_FOLDER:FindFirstChild(weaponName)
	if weaponTemplate then
		local newWeapon = weaponTemplate:Clone()
		newWeapon.Parent = character
		-- ## REMOVED ## No longer setting the attribute here.
	end
end

local function onEquipRequest(player: Player, weaponName: string)
	if WaveController:IsPlayerFighting(player) then return end
	WeaponController:EquipWeapon(player, weaponName)
end

local function onUnequipRequest(player: Player)
	WeaponController:UnequipWeapon(player)
end

local function onEquipLastRequest(player: Player)
	local lastWeapon = player:GetAttribute("LastEquippedWeapon")
	if typeof(lastWeapon) == "string" then
		WeaponController:EquipWeapon(player, lastWeapon)
	end
end

local function onSetSelectedWeapon(player: Player, weaponName: string)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	if table.find(profile.Data.WeaponInventory, weaponName) then
		player:SetAttribute("LastEquippedWeapon", weaponName)
		profile.Data.LastEquippedWeapon = weaponName
	end
end

function WeaponController:Init(controllers: {[string]: any})
	WaveController = controllers.WaveController
	PlayerController = controllers.PlayerController
end

function WeaponController:Start()
	ReplicatedStorage.Events.EquipWeaponRequest.OnServerEvent:Connect(onEquipRequest)
	ReplicatedStorage.Events.UnequipWeaponRequest.OnServerEvent:Connect(onUnequipRequest)
	ReplicatedStorage.Events.EquipLastWeaponRequest.OnServerEvent:Connect(onEquipLastRequest)
	ReplicatedStorage.Events.SetSelectedWeaponRequest.OnServerEvent:Connect(onSetSelectedWeapon) -- ## ADDED ##
end

return WeaponController