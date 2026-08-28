--!strict
-- LOCATION: ServerScriptService/Services/DebugService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)
local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations)

local REWARD = 1_000_000

local DebugService = Knit.CreateService({
	Name = "DebugService",
	Client = {},
})

local PlayerController
local WeaponController
local WaveController

-- ── CASH ──────────────────────────────────────────────────────────────

local function giveCash(player: Player, amount: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	if not cash then
		warn(string.format("[DebugService] leaderstats.Cash not found for %s", player.Name))
		return
	end
	cash.Value += amount
	print(string.format("[DebugService] +%d cash → %s (total: %d)", amount, player.Name, cash.Value))
end

function DebugService.Client:GiveSelf(player: Player)
	giveCash(player, REWARD)
end

function DebugService.Client:GiveById(player: Player, userId: number)
	local target = Players:GetPlayerByUserId(userId)
	if target then
		giveCash(target, REWARD)
	else
		warn(string.format("[DebugService] Không tìm thấy player với UserId: %d", userId))
	end
end

function DebugService.Client:GiveAll(_player: Player)
	for _, p in Players:GetPlayers() do
		giveCash(p, REWARD)
	end
end

-- ── SWORD ──────────────────────────────────────────────────────────────

local function giveSword(player: Player, swordName: string): boolean
	if not WeaponConfigurations.Weapons[swordName] then
		warn(string.format("[DebugService] Sword không tồn tại: '%s'", swordName))
		return false
	end

	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn(string.format("[DebugService] Không lấy được profile của %s", player.Name))
		return false
	end

	if not table.find(profile.Data.WeaponInventory, swordName) then
		table.insert(profile.Data.WeaponInventory, swordName)
	end

	profile.Data.LastEquippedWeapon = swordName
	player:SetAttribute("LastEquippedWeapon", swordName)
	WeaponController:EquipWeapon(player, swordName)
	ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(player, profile.Data.WeaponInventory)

	print(string.format("[DebugService] Gave '%s' → %s", swordName, player.Name))
	return true
end

-- Cấp sword cho bản thân
function DebugService.Client:GiveSwordSelf(player: Player, swordName: string)
	giveSword(player, swordName)
end

-- Cấp sword cho player theo UserId
function DebugService.Client:GiveSwordById(player: Player, userId: number, swordName: string)
	local target = Players:GetPlayerByUserId(userId)
	if target then
		giveSword(target, swordName)
	else
		warn(string.format("[DebugService] Không tìm thấy player với UserId: %d", userId))
	end
end

-- Cấp sword cho tất cả player
function DebugService.Client:GiveSwordAll(_player: Player, swordName: string)
	for _, p in Players:GetPlayers() do
		giveSword(p, swordName)
	end
end

-- ── BLOCK ─────────────────────────────────────────────────────────────

local BLOCK_AMOUNT = 10

local function giveAllBlocks(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn(string.format("[DebugService] Không lấy được profile của %s", player.Name))
		return
	end

	local inventory = profile.Data.BlockInventory

	for itemId, config in ItemConfigurations.ItemConfigurations do
		if config.Type == "Blocks" then
			inventory[itemId] = (inventory[itemId] or 0) + BLOCK_AMOUNT
		end
	end

	ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)
	print(string.format("[DebugService] Gave all blocks (%dx each) → %s", BLOCK_AMOUNT, player.Name))
end

function DebugService.Client:GiveBlockSelf(player: Player)
	giveAllBlocks(player)
end

function DebugService.Client:GiveBlockById(player: Player, userId: number)
	local target = Players:GetPlayerByUserId(userId)
	if target then
		giveAllBlocks(target)
	else
		warn(string.format("[DebugService] Không tìm thấy player với UserId: %d", userId))
	end
end

function DebugService.Client:GiveBlockAll(_player: Player)
	for _, p in Players:GetPlayers() do
		giveAllBlocks(p)
	end
end

-- ── TURRET ────────────────────────────────────────────────────────────

local function giveAllTurrets(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn(string.format("[DebugService] Không lấy được profile của %s", player.Name))
		return
	end

	local inventory = profile.Data.BlockInventory

	for turretId, config in ItemConfigurations.ItemConfigurations do
		if config.Type == "Turrets" then
			inventory[turretId] = (inventory[turretId] or 0) + 1
		end
	end

	for turretId, config in ItemConfigurations.LimitedItems do
		if config.Type == "Turrets" then
			inventory[turretId] = (inventory[turretId] or 0) + 1
		end
	end

	ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)
	print(string.format("[DebugService] Gave all turrets → %s", player.Name))
end

function DebugService.Client:GiveTurretSelf(player: Player)
	giveAllTurrets(player)
end

function DebugService.Client:GiveTurretById(player: Player, userId: number)
	local target = Players:GetPlayerByUserId(userId)
	if target then
		giveAllTurrets(target)
	else
		warn(string.format("[DebugService] Không tìm thấy player với UserId: %d", userId))
	end
end

function DebugService.Client:GiveTurretAll(_player: Player)
	for _, p in Players:GetPlayers() do
		giveAllTurrets(p)
	end
end

-- ── WAVE SPEED ────────────────────────────────────────────────────────

function DebugService.Client:SetWaveSpeed(player: Player, multiplier: number)
	WaveController:SetWaveSpeed(player, multiplier)
end

-- ── STARTING WAVE ─────────────────────────────────────────────────────

function DebugService.Client:SetStartingWave(player: Player, waveNumber: number)
	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn(string.format("[DebugService] Không lấy được profile của %s", player.Name))
		return
	end

	profile.Data.StartingWave = waveNumber
	print(string.format("[DebugService] StartingWave → %d cho %s", waveNumber, player.Name))
end

-- ── LIFECYCLE ─────────────────────────────────────────────────────────

function DebugService:KnitStart()
	-- Lấy controllers từ Bootstrap sau khi cả 2 hệ thống đã khởi động
	task.defer(function()
		PlayerController = require(ServerScriptService.Controllers.PlayerController)
		WeaponController = require(ServerScriptService.Controllers.WeaponController)
		WaveController = require(ServerScriptService.Controllers.WaveController)
	end)
end

return DebugService
