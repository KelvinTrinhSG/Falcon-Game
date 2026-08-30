--!strict

-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Modules
local ProfileService = require(ServerScriptService.Modules:WaitForChild("ProfileService"))

-- Controller Definition
local PlayerController = {}

-- IDs des Gamepasses
local GAMEPASS_VIP = 1832112258
local GAMEPASS_X2 = 1831404291

local ProfileTemplate = {
	Cash = 250,
	Strength = 0,
	BlockInventory = {},
	PlacedItems = {},
	HighestWave = 0,
	StartingWave = 1,
	OwnedModels = {"Gulf"},
	EquippedModel = "Gulf",
	OwnedBases = {"Core1"},
	EquippedBase = "Core1",
	OnboardingStep = "Step1_TeleportToShop",
	Crates = {},
	WeaponInventory = { "WoodSword" },
	LastEquippedWeapon = "WoodSword",
	BlockShopStock = {},
	BlockShopNextRestock = 0,
	WeaponShopStock = {},
	WeaponShopNextRestock = 0,
}

local GameProfileStore = ProfileService.New(
	"PlayerDataV12",
	ProfileTemplate
)

local _profiles = {}
local _controllers = {}

function PlayerController:GetProfile(player: Player)
	return _profiles[player]
end

function PlayerController:SetupSharedInstances() end

-- ==========================================
-- 👥 FONCTION POUR RECALCULER LE MULTIPLICATEUR (GAMEPASS + AMIS)
-- ==========================================
local function UpdateAllPlayersMultiplier()
	for _, p1 in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			local friendCount = 0

			-- On compte combien d'amis p1 a dans le serveur
			for _, p2 in ipairs(Players:GetPlayers()) do
				if p1 ~= p2 and p1:IsFriendsWith(p2.UserId) then
					friendCount += 1
				end
			end

			-- On récupère la base (1 par défaut, ou 1.5/2 si VIP/X2)
			local baseMult = p1:GetAttribute("BaseCashMultiplier") or 1

			-- Calcul final : Base + (0.25 par ami)
			local finalMult = baseMult + (friendCount * 0.25)

			-- On met à jour l'attribut officiel du joueur
			p1:SetAttribute("CashMultiplier", finalMult)

			-- Optionnel: Tu peux aussi stocker le nombre d'amis pour ton GUI
			p1:SetAttribute("ActiveFriendsCount", friendCount)
		end)
	end
end

local function onPlayerAdded(player: Player)
	local profileKey = tostring(player.UserId)
	local profile = GameProfileStore:StartSessionAsync(profileKey, {Steal = true})

	if not profile then
		player:Kick("Failed to load your data. Please rejoin.")
		return
	end

	profile:Reconcile()
	profile:AddUserId(player.UserId)
	_profiles[player] = profile

	-- ==========================================
	-- ⚡ CORRECTION : CRÉATION IMMÉDIATE DU LEADERSTATS
	-- ==========================================
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = profile.Data.Cash
	cash.Parent = leaderstats

	local highestWave = Instance.new("IntValue")
	highestWave.Name = "Highest Wave"
	highestWave.Value = profile.Data.HighestWave
	highestWave.Parent = leaderstats

	leaderstats.Parent = player

	-- 💾 SAUVEGARDE EN TEMPS RÉEL (CASH ET NIVEAU)
	cash:GetPropertyChangedSignal("Value"):Connect(function()
		profile.Data.Cash = cash.Value
	end)

	highestWave:GetPropertyChangedSignal("Value"):Connect(function()
		profile.Data.HighestWave = highestWave.Value
	end)
	-- ==========================================

	if profile.Data.LastEquippedWeapon then
		player:SetAttribute("LastEquippedWeapon", profile.Data.LastEquippedWeapon)
	end

	local weaponInventoryUpdatedEvent = ReplicatedStorage.Events:WaitForChild("WeaponInventoryUpdated")
	weaponInventoryUpdatedEvent:FireClient(player, profile.Data.WeaponInventory)

	local blockInventoryUpdatedEvent = ReplicatedStorage.Events:WaitForChild("BlockInventoryUpdated")
	blockInventoryUpdatedEvent:FireClient(player, profile.Data.BlockInventory)

	ReplicatedStorage.Events:WaitForChild("CrateDataUpdated"):FireClient(player, profile.Data.Crates)

	task.wait() 
	if not next(profile.Data.BlockShopStock) then
		_controllers.BlocksShopController:Restock(player)
	end
	if not next(profile.Data.WeaponShopStock) then
		_controllers.WeaponsShopController:Restock(player)
	end

	if profile.Data.OnboardingStep and profile.Data.OnboardingStep ~= "Completed" then
		ReplicatedStorage.Events.UpdateOnboardingStep:FireClient(player, profile.Data.OnboardingStep)
	end

	_controllers.PlotController:OnPlayerProfileLoaded(player)

	-- ==========================================
	-- 💰 GESTION DU MULTIPLICATEUR DE BASE (GAMEPASSES)
	-- ==========================================
	task.spawn(function()
		local baseMultiplier = 1
		local hasX2 = false
		local hasVIP = false

		pcall(function() hasX2 = MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_X2) end)
		pcall(function() hasVIP = MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_VIP) end)

		if hasX2 then
			baseMultiplier = 2
		elseif hasVIP then
			baseMultiplier = 1.5
		end

		-- On sauvegarde la base du joueur AVANT de compter les amis
		player:SetAttribute("BaseCashMultiplier", baseMultiplier)

		-- On lance le recalcul pour tout le monde
		UpdateAllPlayersMultiplier()
	end)

	print(`Player {player.Name} joined and data was loaded successfully.`)
end

local function onPlayerRemoving(player: Player)
	local profile = _profiles[player]
	if profile then
		profile:EndSession()
		_profiles[player] = nil
		print(`Player {player.Name} left. Data session ended.`)
	end

	-- On recalcule le boost des joueurs restants
	UpdateAllPlayersMultiplier()
end

function PlayerController:Init(controllers: {[string]: any})
	_controllers = controllers
end

function PlayerController:Start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	-- ==========================================
	-- 🛒 MISE À JOUR DU MULTIPLICATEUR EN DIRECT (Si achat en jeu)
	-- ==========================================
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if wasPurchased then
			local currentBase = player:GetAttribute("BaseCashMultiplier") or 1

			if gamePassId == GAMEPASS_X2 then
				player:SetAttribute("BaseCashMultiplier", 2)
				UpdateAllPlayersMultiplier()
			elseif gamePassId == GAMEPASS_VIP and currentBase < 2 then
				player:SetAttribute("BaseCashMultiplier", 1.5)
				UpdateAllPlayersMultiplier()
			end
		end
	end)

	local getBlockInventoryFunc = ReplicatedStorage.Functions:WaitForChild("GetBlockInventory")
	getBlockInventoryFunc.OnServerInvoke = function(player: Player)
		local profile = _profiles[player]
		while not profile do task.wait() profile = _profiles[player] end
		return profile.Data.BlockInventory
	end

	local getWeaponInventoryFunc = ReplicatedStorage.Functions:WaitForChild("GetWeaponInventory")
	getWeaponInventoryFunc.OnServerInvoke = function(player: Player)
		local profile = _profiles[player]
		while not profile do task.wait() profile = _profiles[player] end
		return profile.Data.WeaponInventory
	end

	local getOwnedModelsFunc = ReplicatedStorage.Functions:WaitForChild("GetOwnedModels")
	getOwnedModelsFunc.OnServerInvoke = function(player: Player)
		local profile = _profiles[player]
		while not profile do task.wait() profile = _profiles[player] end
		return profile.Data.OwnedModels
	end

	local getEquippedModelFunc = ReplicatedStorage.Functions:WaitForChild("GetEquippedModel")
	getEquippedModelFunc.OnServerInvoke = function(player: Player)
		local profile = _profiles[player]
		while not profile do task.wait() profile = _profiles[player] end
		return profile.Data.EquippedModel
	end

	local onboardingProgression = {
		["Step1_TeleportToShop"] = "Step2_OpenDefenceShop",
		["Step2_OpenDefenceShop"] = "Step3_BuyOldTurret",
		["Step3_BuyOldTurret"] = "Step3b_BuyFirstBlock",
		["Step3b_BuyFirstBlock"] = "Step4_TeleportToPlot",
		["Step4_TeleportToPlot"] = "Step5_OpenInventory",
		["Step5_OpenInventory"] = "Step6_PlaceOldTurret",
		["Step6_PlaceOldTurret"] = "Step6b_PlaceRockBlock", -- ⚡ AJOUTÉ : On demande de poser le bloc après la tourelle
		["Step6b_PlaceRockBlock"] = "Step7_StartFight",      -- ⚡ MODIFIÉ : Puis on lance le combat
	}
	
	ReplicatedStorage.Events.OnboardingStepCompleted.OnServerEvent:Connect(function(player, completedStepName)
		local profile = _profiles[player]
		if not (profile and profile.Data.OnboardingStep == completedStepName) then return end

		local nextStep = onboardingProgression[completedStepName]
		if nextStep then
			profile.Data.OnboardingStep = nextStep
			ReplicatedStorage.Events.UpdateOnboardingStep:FireClient(player, nextStep)
		end
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
end

return PlayerController