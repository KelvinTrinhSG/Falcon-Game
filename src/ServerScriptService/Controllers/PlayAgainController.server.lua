--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local playAgainEvent = Instance.new("RemoteEvent")
playAgainEvent.Name = "PlayAgain"
playAgainEvent.Parent = ReplicatedStorage.Events

local gameWinEvent = Instance.new("RemoteEvent")
gameWinEvent.Name = "GameWin"
gameWinEvent.Parent = ReplicatedStorage.Events

playAgainEvent.OnServerEvent:Connect(function(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local highestCompleted = profile.Data.HighestCompletedWave or 0
	if highestCompleted < 60 then
		warn("[PlayAgainController] Player", player.Name, "has not completed wave 60 (HighestCompletedWave =", highestCompleted, ")")
		return
	end

	-- Reset toàn bộ data về mặc định, giữ OnboardingStep = "Completed"
	profile.Data.Cash                 = 300
	profile.Data.Strength             = 0
	profile.Data.BlockInventory       = {}
	profile.Data.PlacedItems          = {}
	profile.Data.HighestWave          = 0
	profile.Data.HighestCompletedWave = 0
	profile.Data.StartingWave         = 1
	profile.Data.OwnedModels          = {"Gulf"}
	profile.Data.EquippedModel        = "Gulf"
	profile.Data.OwnedBases           = {"Core1"}
	profile.Data.EquippedBase         = "Core1"
	profile.Data.OnboardingStep       = "Completed"
	profile.Data.Crates               = {}
	profile.Data.WeaponInventory      = {"WoodSword"}
	profile.Data.LastEquippedWeapon   = "WoodSword"
	profile.Data.BlockShopStock       = {}
	profile.Data.BlockShopNextRestock = 0
	profile.Data.WeaponShopStock      = {}
	profile.Data.WeaponShopNextRestock = 0
	profile.Data.BaseShopStock        = {}
	profile.Data.BaseShopNextRestock  = 0
	profile.Data.TurretsShopStock     = {}
	profile.Data.TurretsShopNextRestock = 0

	-- Teleport lại cùng place để load lại game với data mới
	local success, err = pcall(function()
		TeleportService:TeleportAsync(game.PlaceId, {player})
	end)
	if not success then
		warn("[PlayAgainController] TeleportAsync failed:", err)
		player:Kick("Restarting... Please rejoin.")
	end
end)
