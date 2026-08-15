--!strict
-- Manages crate purchasing, spawning, unlocking, and opening via touch events.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local PlayerController
local WeaponsShopController

local CRATE_MODELS = ReplicatedStorage:WaitForChild("Crates")
local MAX_CRATES = 3

local CrateController = {}
local crateInteractionDebounce = {}

-- ## MODIFIED ## Removed the redundant and problematic time check from this function.
local function onOpenCrate(player: Player, crateModel: Model)
	local profile = PlayerController:GetProfile(player)
	if not profile or not crateModel.Parent then return end

	local spawnIndex = crateModel:GetAttribute("SpawnIndex")
	local crateDataIndex = -1
	for i, data in ipairs(profile.Data.Crates) do
		if data.SpawnIndex == spawnIndex then crateDataIndex = i; break end
	end
	if crateDataIndex == -1 then return end

	local crateType = profile.Data.Crates[crateDataIndex].Type
	local lootTable = WeaponConfigurations.Crates[crateType].Loot
	local totalWeight = 0
	for _, loot in ipairs(lootTable) do totalWeight += loot.Weight end

	local roll = math.random() * totalWeight
	local chosenWeaponId: string = lootTable[#lootTable].Item
	for _, loot in ipairs(lootTable) do
		if roll <= loot.Weight then chosenWeaponId = loot.Item; break else roll -= loot.Weight end
	end

	if chosenWeaponId and not table.find(profile.Data.WeaponInventory, chosenWeaponId) then
		table.insert(profile.Data.WeaponInventory, chosenWeaponId)
	end

	table.remove(profile.Data.Crates, crateDataIndex)
	crateModel:Destroy()
	local weaponConfig = WeaponConfigurations.Weapons[chosenWeaponId]
	ReplicatedStorage.Events.ShowModelAward:FireClient(player, weaponConfig.DisplayName, weaponConfig.ImageId)
	ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(player, profile.Data.WeaponInventory)
	ReplicatedStorage.Events.CrateDataUpdated:FireClient(player, profile.Data.Crates)
end

local function getPlotForPlayer(player: Player): Model?
	local plotNum = player:GetAttribute("PlotNumber")
	if plotNum then
		local plot = Workspace.Plots:FindFirstChild("Plot" .. tostring(plotNum))
		if plot and plot:IsA("Model") then return plot end
	end
	for _, plot in ipairs(Workspace.Plots:GetChildren()) do
		if plot:IsA("Model") and plot:GetAttribute("OwnerId") == player.UserId then return plot end
	end
	return nil
end

function CrateController:SpawnCrateModel(plot: Model, crateData: table)
	local crateTemplate = CRATE_MODELS:FindFirstChild(crateData.Type)
	local crateSpawns = plot:FindFirstChild("Crate")
	if not crateTemplate or not crateSpawns or not crateTemplate.PrimaryPart then return end

	local spawnPart = crateSpawns:FindFirstChild("CrateSpawn" .. crateData.SpawnIndex)
	if not spawnPart then return end

	local newCrate = crateTemplate:Clone()
	newCrate:SetAttribute("OwnerId", plot:GetAttribute("OwnerId"))
	newCrate:SetAttribute("UnlockTimestamp", crateData.UnlockTimestamp)
	newCrate:SetAttribute("SpawnIndex", crateData.SpawnIndex)
	newCrate:SetAttribute("CrateType", crateData.Type)
	newCrate:SetPrimaryPartCFrame(spawnPart.CFrame * CFrame.new(0, 3, 0))
	newCrate.Parent = crateSpawns

	newCrate.PrimaryPart.Touched:Connect(function(hit)
		if crateInteractionDebounce[newCrate] then return end

		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or player.UserId ~= newCrate:GetAttribute("OwnerId") then
			return
		end

		crateInteractionDebounce[newCrate] = true

		-- ## ADDED ## Final debug print to check the time value just before the decision
		local unlockTime = newCrate:GetAttribute("UnlockTimestamp")
		print(`[CrateController] Touched by owner. CurrentTime: {os.time()}, UnlockTime: {unlockTime}`)

		if os.time() >= unlockTime then
			onOpenCrate(player, newCrate)
		else
			while not WeaponsShopController do task.wait() end
			WeaponsShopController:RequestSkipTimer(player, newCrate)
			task.delay(2, function()
				crateInteractionDebounce[newCrate] = nil
			end)
		end
	end)
end

-- ... (Rest of script is the same)
function CrateController:PurchaseCrate(player: Player, crateId: string, isRobuxPurchase: boolean?): boolean
	local profile = PlayerController:GetProfile(player)
	local plot = getPlotForPlayer(player)
	if not profile or not plot then return false end
	if #profile.Data.Crates >= MAX_CRATES then
		if not isRobuxPurchase then
			ReplicatedStorage.Events.ShowNotification:FireClient(player, "All crate slots are full!", "Error")
		end
		return false
	end
	local usedIndexes = {}
	for _, existingCrate in ipairs(profile.Data.Crates) do
		usedIndexes[existingCrate.SpawnIndex] = true
	end
	local spawnIndex = -1
	for i = 1, MAX_CRATES do
		if not usedIndexes[i] then spawnIndex = i; break end
	end
	if spawnIndex == -1 then return false end
	local crateConfig = WeaponConfigurations.Crates[crateId]
	local unlockTimestamp = os.time() + crateConfig.UnlockTime
	local crateData = {Type = crateId, SpawnIndex = spawnIndex, UnlockTimestamp = unlockTimestamp}
	table.insert(profile.Data.Crates, crateData)
	self:SpawnCrateModel(plot, crateData)
	if not isRobuxPurchase then
		ReplicatedStorage.Events.ShowNotification:FireClient(player, "Crate purchased and placed on your plot!", "Success")
	end
	ReplicatedStorage.Events.CrateDataUpdated:FireClient(player, profile.Data.Crates)
	return true
end

function CrateController:LoadPlayerCrates(player: Player, plot: Model)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end
	for _, crateData in ipairs(profile.Data.Crates) do
		self:SpawnCrateModel(plot, crateData)
	end
end

function CrateController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	WeaponsShopController = controllers.WeaponsShopController
end

function CrateController:Start() end

return CrateController