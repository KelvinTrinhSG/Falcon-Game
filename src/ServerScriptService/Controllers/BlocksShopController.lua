--!strict
-- Manages the per-player logic for the BlocksShop (CASH PURCHASES ONLY)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations
local LimitedItems = ItemConfigsModule.LimitedItems

local PlayerController
local LimitedTurretController

local RESTOCK_INTERVAL_SECONDS = 180
local GUARANTEED_ITEMS = {"CarboardBlock", "CameraGuy"}

local ShopController = {}

local purchaseItemEvent = ReplicatedStorage.Events:WaitForChild("PurchaseBlockItem")
local updateStocksEvent = ReplicatedStorage.Events:WaitForChild("UpdateBlockStocks")
local getResetTime = ReplicatedStorage.Functions:WaitForChild("GetBlockShopResetTime")
local getStocks = ReplicatedStorage.Functions:WaitForChild("GetBlockShopStocks")
local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")
local blockInventoryUpdatedEvent = ReplicatedStorage.Events:WaitForChild("BlockInventoryUpdated")

local FIRST_TIME_MAX_ITEMS = {"CameraGuy", "RockBlock"}

function ShopController:Restock(player: Player, suppressNotification: boolean?, isFirstTime: boolean?)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local newStock = {}
	for _, itemId in ipairs(GUARANTEED_ITEMS) do
		local config = ItemConfigurations[itemId]
		if config and config.StockAmount then
			if isFirstTime and table.find(FIRST_TIME_MAX_ITEMS, itemId) then
				newStock[itemId] = config.StockAmount.Max
			else
				newStock[itemId] = math.random(config.StockAmount.Min, config.StockAmount.Max)
			end
		end
	end
	for itemId, config in pairs(ItemConfigurations) do
		if config.Unlimited or table.find(GUARANTEED_ITEMS, itemId) then continue end

		if config.Chance and config.StockAmount then
			if isFirstTime and table.find(FIRST_TIME_MAX_ITEMS, itemId) then
				newStock[itemId] = config.StockAmount.Max
			elseif math.random() * 100 <= config.Chance then
				newStock[itemId] = math.random(config.StockAmount.Min, config.StockAmount.Max)
			else
				newStock[itemId] = 0
			end
		end
	end

	-- Cách A: turret Titan (LimitedItems) roll chung vào kho shop này, giống 9 turret thường.
	-- CHỈ roll turret đang được track kho global (nằm trong STOCK_KEYS). Turret chưa track
	-- thì KHÔNG set newStock[itemId] (để nil) -> client ẩn hẳn card cho tới khi D1 thêm key.
	-- Turret đã track thì LUÔN có entry mỗi restock: trúng Chance -> 1..Max, trượt -> 0.
	for itemId, config in pairs(LimitedItems) do
		if config.Chance and config.StockAmount
			and LimitedTurretController and LimitedTurretController:IsStockTracked(itemId) then
			local finalStock = 0
			if math.random() * 100 <= config.Chance then
				local rolled = math.random(config.StockAmount.Min, config.StockAmount.Max)
				-- GetStock đọc DataStore — bọc pcall để lỗi kho global không làm hỏng cả lượt Restock
				local ok, globalRemaining = pcall(function()
					return LimitedTurretController:GetStock(itemId)
				end)
				if ok and type(globalRemaining) == "number" then
					finalStock = math.max(0, math.min(rolled, globalRemaining))
				end
			end
			newStock[itemId] = finalStock
		end
	end

	profile.Data.BlockShopStock = newStock
	profile.Data.BlockShopNextRestock = os.time() + RESTOCK_INTERVAL_SECONDS

	print(`[Shop] Restock xong cho {player.Name}:`, newStock)
	updateStocksEvent:FireClient(player, newStock)
	if not suppressNotification then
		showNotificationEvent:FireClient(player, "The Blocks Shop has been restocked!", "Normal")
	end
end

local function onPurchaseRequest(player: Player, itemId: string)
	local profile = PlayerController:GetProfile(player)
	local config = ItemConfigurations[itemId]
	-- D2 (Cách A): turret Titan nằm ở bảng LimitedItems, không phải ItemConfigurations
	local isLimited = false
	if not config then
		config = LimitedItems[itemId]
		isLimited = true
	end
	if not profile or not config then return end
	local playerStock = profile.Data.BlockShopStock

	if not config.Unlimited then
		if (playerStock[itemId] or 0) <= 0 then
			showNotificationEvent:FireClient(player, "This item is out of stock!", "Error")
			return
		end
	end

	-- D2: turret Titan còn phải check kho global toàn server (lớp 1).
	-- Đây chỉ là cửa chặn sớm cho UX; cửa chặn thật là ConsumeStock bên dưới (có hoàn tiền).
	if isLimited then
		if not LimitedTurretController then
			showNotificationEvent:FireClient(player, "Sorry, this item just sold out!", "Error")
			return
		end
		local ok, remaining = pcall(function()
			return LimitedTurretController:GetStock(itemId)
		end)
		if ok and type(remaining) == "number" and remaining <= 0 then
			showNotificationEvent:FireClient(player, "Sorry, this item just sold out!", "Error")
			return
		end
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")

	if cash and cash.Value >= config.Price then
		cash.Value -= config.Price

		-- D2: trừ kho global cho turret Titan; nếu vừa hết sạch thì hoàn tiền
		if isLimited then
			local consumed = LimitedTurretController and LimitedTurretController:ConsumeStock(itemId)
			if not consumed then
				cash.Value += config.Price
				showNotificationEvent:FireClient(player, "Sorry, this item just sold out!", "Error")
				return
			end
		end

		if not config.Unlimited then
			playerStock[itemId] -= 1
			updateStocksEvent:FireClient(player, playerStock)
		end

		local inventory = profile.Data.BlockInventory
		inventory[itemId] = (inventory[itemId] or 0) + 1
		showNotificationEvent:FireClient(player, `Purchased {config.DisplayName}!`, "Success")
		blockInventoryUpdatedEvent:FireClient(player, inventory)

		-- ==========================================
		-- ⚡ LE NOUVEAU SYSTÈME DE TUTORIEL
		-- ==========================================

		-- 1. Le joueur est à l'étape "Acheter Tourelle" et achète une Tourelle
		if profile.Data.OnboardingStep == "Step3_BuyOldTurret" and config.Type == "Turrets" then
			profile.Data.OnboardingStep = "Step3b_BuyFirstBlock"
			ReplicatedStorage.Events.UpdateOnboardingStep:FireClient(player, "Step3b_BuyFirstBlock")

			-- 2. Le joueur est à la nouvelle étape "Acheter Bloc" et achète un Bloc
		elseif profile.Data.OnboardingStep == "Step3b_BuyFirstBlock" and config.Type == "Blocks" then
			profile.Data.OnboardingStep = "Step4_TeleportToPlot"
			ReplicatedStorage.Events.UpdateOnboardingStep:FireClient(player, "Step4_TeleportToPlot")
		end
		-- ==========================================

	else
		showNotificationEvent:FireClient(player, "Not enough cash!", "Error")
	end
end

function ShopController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	LimitedTurretController = controllers.LimitedTurretController
end

function ShopController:Start()
	getResetTime.OnServerInvoke = function(player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.BlockShopNextRestock
	end
	getStocks.OnServerInvoke = function(player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.BlockShopStock
	end

	purchaseItemEvent.OnServerEvent:Connect(onPurchaseRequest)
end

return ShopController