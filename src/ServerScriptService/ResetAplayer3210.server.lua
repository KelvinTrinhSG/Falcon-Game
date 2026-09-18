--!strict
-- Reset toàn bộ data của Aplayer3210 về trạng thái mới chơi lần đầu
-- XÓA script này sau khi đã dùng xong

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local TARGET_ID = 11115679011

local FRESH_DATA = {
	Cash = 300,
	Strength = 0,
	BlockInventory = {},
	PlacedItems = {},
	HighestWave = 0,
	HighestCompletedWave = 0,
	StartingWave = 1,
	xMoney = 1,
	xTowerDam = 1,
	xToiletHP = 1,
	OwnedModels = {"Gulf"},
	EquippedModel = "Gulf",
	OwnedBases = {"Core1"},
	EquippedBase = "Core1",
	OnboardingStep = "Step1_TeleportToShop",
	Crates = {},
	WeaponInventory = {"WoodSword"},
	LastEquippedWeapon = "WoodSword",
	BlockShopStock = {},
	BlockShopNextRestock = 0,
	WeaponShopStock = {},
	WeaponShopNextRestock = 0,
	BaseShopStock = {},
	BaseShopNextRestock = 0,
	TurretsShopStock = {},
	TurretsShopNextRestock = 0,
}

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local function deepCopy(t: {[any]: any}): {[any]: any}
	local copy = {}
	for k, v in pairs(t) do
		copy[k] = if type(v) == "table" then deepCopy(v) else v
	end
	return copy
end

local function resetPlayer(player: Player)
	if player.UserId ~= TARGET_ID then return end

	local profile = PlayerController:GetProfile(player)
	local waited = 0
	while not profile and waited < 30 do
		task.wait(0.5)
		waited += 0.5
		profile = PlayerController:GetProfile(player)
	end

	if not profile then
		warn("[ResetAplayer3210] Không tìm thấy profile sau 30s!")
		return
	end

	local newData = deepCopy(FRESH_DATA)
	for k, v in pairs(newData) do
		profile.Data[k] = v
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cash = leaderstats:FindFirstChild("Cash")
		local hw = leaderstats:FindFirstChild("Highest Wave")
		if cash then cash.Value = FRESH_DATA.Cash end
		if hw then hw.Value = FRESH_DATA.HighestWave end
	end

	print("[ResetAplayer3210] ✅ Data của", player.Name, "đã reset về trạng thái mới!")
end

Players.PlayerAdded:Connect(resetPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(resetPlayer, p)
end
