--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local playAgainEvent    = Instance.new("RemoteEvent")
playAgainEvent.Name     = "PlayAgain"
playAgainEvent.Parent   = ReplicatedStorage.Events

local playAgainMoneyEvent  = Instance.new("RemoteEvent")
playAgainMoneyEvent.Name   = "PlayAgainMoney"
playAgainMoneyEvent.Parent = ReplicatedStorage.Events

local playAgainDamageEvent  = Instance.new("RemoteEvent")
playAgainDamageEvent.Name   = "PlayAgainDamage"
playAgainDamageEvent.Parent = ReplicatedStorage.Events

local gameWinEvent    = Instance.new("RemoteEvent")
gameWinEvent.Name     = "GameWin"
gameWinEvent.Parent   = ReplicatedStorage.Events

local function checkCompleted(player: Player, profile: any): boolean
	local highestCompleted = profile.Data.HighestCompletedWave or 0
	if highestCompleted < 60 then
		warn("[PlayAgainController] Player", player.Name, "has not completed wave 60 (HighestCompletedWave =", highestCompleted, ")")
		return false
	end
	return true
end

local function resetAndTeleport(player: Player, profile: any)
	profile.Data.Cash                   = 300
	profile.Data.Strength               = 0
	profile.Data.BlockInventory         = {}
	profile.Data.PlacedItems            = {}
	profile.Data.HighestWave            = 0
	profile.Data.HighestCompletedWave   = 0
	profile.Data.StartingWave           = 1
	profile.Data.OwnedModels            = {"Gulf"}
	profile.Data.EquippedModel          = "Gulf"
	profile.Data.OwnedBases             = {"Core1"}
	profile.Data.EquippedBase           = "Core1"
	profile.Data.OnboardingStep         = "Completed"
	profile.Data.Crates                 = {}
	profile.Data.WeaponInventory        = {"WoodSword"}
	profile.Data.LastEquippedWeapon     = "WoodSword"
	profile.Data.BlockShopStock         = {}
	profile.Data.BlockShopNextRestock   = 0
	profile.Data.WeaponShopStock        = {}
	profile.Data.WeaponShopNextRestock  = 0
	profile.Data.BaseShopStock          = {}
	profile.Data.BaseShopNextRestock    = 0
	profile.Data.TurretsShopStock       = {}
	profile.Data.TurretsShopNextRestock = 0
	-- xMoney, xTowerDam, xToiletHP không reset

	local success, err = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, {player})
	end)
	if not success then
		warn("[PlayAgainController] TeleportAsync failed:", err)
		player:Kick("Restarting... Please rejoin.")
	end
end

-- Nút Play Again
playAgainEvent.OnServerEvent:Connect(function(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile or not checkCompleted(player, profile) then return end
	resetAndTeleport(player, profile)
end)

-- Nút x2 Money
playAgainMoneyEvent.OnServerEvent:Connect(function(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile or not checkCompleted(player, profile) then return end
	profile.Data.xMoney = (profile.Data.xMoney or 1) + 1
	resetAndTeleport(player, profile)
end)

-- Nút x2 Tower Damage
playAgainDamageEvent.OnServerEvent:Connect(function(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile or not checkCompleted(player, profile) then return end
	profile.Data.xTowerDam = (profile.Data.xTowerDam or 1) + 1
	resetAndTeleport(player, profile)
end)
