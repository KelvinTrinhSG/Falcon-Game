--!strict
-- LOCATION: ServerScriptService/Controllers/WeaponsShopController.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Modules = ReplicatedStorage.Modules
local WeaponConfigurations = require(Modules.WeaponConfigurations)
local ItemConfigsModule = require(Modules.ItemConfigurations)
local LimitedItems = ItemConfigsModule.LimitedItems
local ItemConfigurations = ItemConfigsModule.ItemConfigurations
local NumberFormatter = require(Modules.NumberFormatter)

local PlayerController
local CrateController
local BlocksShopController
local PlotController
local LimitedTurretController

local RESTOCK_INTERVAL_SECONDS = 300
local MAX_CRATES = 3

local ShopController = {}
local pendingSkips = {}

local purchaseItemEvent = ReplicatedStorage.Events:WaitForChild("PurchaseWeaponCrate")
local updateStocksEvent = ReplicatedStorage.Events:WaitForChild("UpdateWeaponStocks")
local getResetTime = ReplicatedStorage.Functions:WaitForChild("GetWeaponShopResetTime")
local getStocks = ReplicatedStorage.Functions:WaitForChild("GetWeaponShopStocks")
local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")
local promptSkipTimerRequest = ReplicatedStorage.Events:WaitForChild("PromptSkipTimerRequest")

local function getProductConfig(productId: number)
	for id, config in pairs(WeaponConfigurations.ShopProducts) do
		if config.ProductID == productId then return id, config, "ShopAction" end
	end
	for id, config in pairs(LimitedItems) do
		if config.ProductID == productId then return id, config, "LimitedTurret" end
	end
	for id, config in pairs(WeaponConfigurations.CashProducts) do
		if config.ProductID == productId then return id, config, "Cash" end
	end
	for id, config in pairs(WeaponConfigurations.StarterPack or {}) do
		if config.ProductID == productId then return id, config, "StarterPack" end
	end
	for id, config in pairs(WeaponConfigurations.Crates) do
		if config.ProductID == productId or (config.SkipTimerProductID and config.SkipTimerProductID == productId) then
			return id, config, "Crate"
		end
	end
	for id, config in pairs(ItemConfigurations) do
		if config.ProductID == productId then return id, config, "BlockOrTurret" end
	end
	local models = type(ItemConfigsModule.ModelConfigurations) == "table" and ItemConfigsModule.ModelConfigurations or {}
	for id, config in pairs(models) do
		if type(config) == "table" and config.PowerLevel and config.ProductID and config.ProductID == productId then 
			return id, config, "Model" 
		end
	end
	return nil, nil, nil
end

local function processReceipt(receiptInfo: {[string]: any})
	local playerId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local player = Players:GetPlayerByUserId(playerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

	-- 🎡 ACHATS DE LA ROUE (SPINS)
	if productId == 3595244091 or productId == 3595244324 or productId == 3595244673 then
		local rs = player:FindFirstChild("RobuxSpins")
		if not rs then return Enum.ProductPurchaseDecision.NotProcessedYet end

		if productId == 3595244091 then
			rs.Value = rs.Value + 1
			showNotificationEvent:FireClient(player, "+1 Spin (x2 Luck) acheté !", "Success")
		elseif productId == 3595244324 then
			rs.Value = rs.Value + 3
			showNotificationEvent:FireClient(player, "+3 Spins (x2 Luck) achetés !", "Success")
		elseif productId == 3595244673 then
			rs.Value = rs.Value + 10
			showNotificationEvent:FireClient(player, "+10 Spins (x2 Luck) achetés !", "Success")
		end

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local profile = PlayerController:GetProfile(player)
	if not profile then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local itemId, config, productType = getProductConfig(productId)
	if not itemId or not config or not productType then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if productType == "LimitedTurret" then
		return LimitedTurretController:ProcessPurchase(player, itemId)
	elseif productType == "ShopAction" then
		if itemId == "RestockBlocksShop" then
			BlocksShopController:Restock(player, true)
			showNotificationEvent:FireClient(player, "Blocks Shop Restocked!", "Success")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif itemId == "RestockTurretsShop" then
			BlocksShopController:Restock(player, true)
			showNotificationEvent:FireClient(player, "Defenders Shop Restocked!", "Success")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif itemId == "RestockBasesShop" then
			BlocksShopController:Restock(player, true)
			showNotificationEvent:FireClient(player, "Bases Shop Restocked!", "Success")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif itemId == "RestockWeaponsShop" then
			ShopController:Restock(player, true)
			showNotificationEvent:FireClient(player, "Crates Shop Restocked!", "Success")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	elseif productType == "Model" then
		if not table.find(profile.Data.OwnedModels, itemId) then
			table.insert(profile.Data.OwnedModels, itemId)
			showNotificationEvent:FireClient(player, `Purchased {config.DisplayName}!`, "Success")

			if type(ItemConfigsModule.ModelConfigurations) == "table" then
				local equippedConfig = ItemConfigsModule.ModelConfigurations[profile.Data.EquippedModel]
				if equippedConfig and config.PowerLevel > equippedConfig.PowerLevel then
					PlotController:EquipModel(player, itemId)
					showNotificationEvent:FireClient(player, "New, better model automatically equipped!", "Success")
				end
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	elseif productType == "StarterPack" then
		if profile.Data.OwnsStarterPack then
			return Enum.ProductPurchaseDecision.PurchaseGranted 
		end
		local leaderstats = player:FindFirstChild("leaderstats")
		local cash = leaderstats and leaderstats:FindFirstChild("Cash")
		if cash then cash.Value += config.CashAmount end

		local inventory = profile.Data.BlockInventory
		local turretId = config.TurretId
		inventory[turretId] = (inventory[turretId] or 0) + 1
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)

		profile.Data.OwnsStarterPack = true
		player:SetAttribute("OwnsStarterPack", true) 

		local formattedCash = NumberFormatter.formatNumber(config.CashAmount)
		local turretConfig = ItemConfigurations[turretId] or LimitedItems[turretId]
		local turretDisplayName = turretConfig and turretConfig.DisplayName or turretId
		showNotificationEvent:FireClient(player, `Starter Pack Purchased! +${formattedCash} and 1x {turretDisplayName}!`, "Success")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif productType == "Cash" then
		local leaderstats = player:FindFirstChild("leaderstats")
		local cash = leaderstats and leaderstats:FindFirstChild("Cash")
		if cash then
			cash.Value += config.CashAmount
			local formattedCash = NumberFormatter.formatNumber(config.CashAmount)
			showNotificationEvent:FireClient(player, `You received ${formattedCash} cash!`, "Success")
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	elseif productType == "BlockOrTurret" then
		local inventory = profile.Data.BlockInventory
		if config.Type == "Blocks" then
			inventory[itemId] = (inventory[itemId] or 0) + 3
			showNotificationEvent:FireClient(player, `Purchased 3x {config.DisplayName}!`, "Success")
		else
			inventory[itemId] = (inventory[itemId] or 0) + 1
			showNotificationEvent:FireClient(player, `Purchased {config.DisplayName}!`, "Success")
		end
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)
		if not profile.Data.HasCompletedOnboarding and config.Type == "Turrets" then
			ReplicatedStorage.Events.UpdateOnboardingStep:FireClient(player, "Step2_PlaceTurret")
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif productType == "Crate" then
		if productId == WeaponConfigurations.Crates.TitanCrate.ProductID then
			local lootTable = config.Loot
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
			local weaponConfig = WeaponConfigurations.Weapons[chosenWeaponId]
			ReplicatedStorage.Events.ShowModelAward:FireClient(player, weaponConfig.DisplayName, weaponConfig.ImageId)
			ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(player, profile.Data.WeaponInventory)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		elseif productId == config.ProductID then
			if #profile.Data.Crates >= MAX_CRATES then return Enum.ProductPurchaseDecision.NotProcessedYet end
			local success = CrateController:PurchaseCrate(player, itemId, true)
			if success then
				showNotificationEvent:FireClient(player, "Purchase Successful!", "Success")
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		elseif config.SkipTimerProductID and productId == config.SkipTimerProductID then
			local crateToSkip = pendingSkips[player]
			if crateToSkip and crateToSkip.Parent then
				local spawnIndex = crateToSkip:GetAttribute("SpawnIndex")
				for _, crateData in ipairs(profile.Data.Crates) do
					if crateData.SpawnIndex == spawnIndex then crateData.UnlockTimestamp = 0; break end
				end
				crateToSkip:SetAttribute("UnlockTimestamp", 0)
				pendingSkips[player] = nil
				showNotificationEvent:FireClient(player, "Timer Skipped!", "Success")
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function ShopController:RequestSkipTimer(player: Player, crateModel: Model)
	local crateType = crateModel:GetAttribute("CrateType")
	if not crateType then return end
	local crateConfig = WeaponConfigurations.Crates[crateType]
	if not crateConfig or not crateConfig.SkipTimerProductID then return end
	pendingSkips[player] = crateModel
	promptSkipTimerRequest:FireClient(player, crateConfig.SkipTimerProductID)
end

function ShopController:Restock(player: Player, suppressNotification: boolean?)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end
	local newStock = {}
	for itemId, config in pairs(WeaponConfigurations.Crates) do
		if config.Unlimited or not config.Price then continue end
		if config.Chance and config.StockAmount then 
			if math.random() * 100 <= config.Chance then
				newStock[itemId] = math.random(config.StockAmount.Min, config.StockAmount.Max)
			else
				newStock[itemId] = 0
			end
		end
	end
	profile.Data.WeaponShopStock = newStock
	profile.Data.WeaponShopNextRestock = os.time() + RESTOCK_INTERVAL_SECONDS
	updateStocksEvent:FireClient(player, newStock)
	if not suppressNotification then
		showNotificationEvent:FireClient(player, "The Crate Shop has been restocked!", "Normal")
	end
end

local function onPurchaseRequest(player: Player, itemId: string)
	local profile = PlayerController:GetProfile(player)
	local config = WeaponConfigurations.Crates[itemId]
	if not profile or not config then return end
	local playerStock = profile.Data.WeaponShopStock
	if not config.Unlimited and (playerStock[itemId] or 0) <= 0 then
		showNotificationEvent:FireClient(player, "This item is out of stock!", "Error")
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	if not (cash and cash.Value >= config.Price) then
		showNotificationEvent:FireClient(player, "Not enough cash!", "Error")
		return
	end
	while not CrateController do task.wait() end
	local success = CrateController:PurchaseCrate(player, itemId)
	if success then
		cash.Value -= config.Price
		if not config.Unlimited then
			playerStock[itemId] -= 1
			updateStocksEvent:FireClient(player, playerStock)
		end
	end
end

function ShopController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	CrateController = controllers.CrateController
	BlocksShopController = controllers.BlocksShopController
	PlotController = controllers.PlotController
	LimitedTurretController = controllers.LimitedTurretController
end

function ShopController:Start()
	MarketplaceService.ProcessReceipt = processReceipt

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			local profile = nil
			for i = 1, 10 do
				if not PlayerController then break end
				profile = PlayerController:GetProfile(player)
				if profile then break end
				task.wait(1)
			end
			if profile and profile.Data.OwnsStarterPack then
				player:SetAttribute("OwnsStarterPack", true)
			end
		end)
	end)

	getResetTime.OnServerInvoke = function(player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.WeaponShopNextRestock
	end
	getStocks.OnServerInvoke = function(player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.WeaponShopStock
	end

	purchaseItemEvent.OnServerEvent:Connect(onPurchaseRequest)
end

return ShopController