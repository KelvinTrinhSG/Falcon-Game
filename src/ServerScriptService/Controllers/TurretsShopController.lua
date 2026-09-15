--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations

local PlayerController

local RESTOCK_INTERVAL_SECONDS = 300

local TurretsShopController = {}

local showNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

local function getOrCreate(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = parent
	return obj
end

local updateStocksEvent: RemoteEvent
local getResetTime: RemoteFunction
local getStocks: RemoteFunction
local purchaseItemEvent: RemoteEvent

function TurretsShopController:Restock(player: Player, suppressNotification: boolean?)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local newStock = {}
	for itemId, config in pairs(ItemConfigurations) do
		if config.Type ~= "Turrets" then continue end
		if config.Unlimited then continue end

		if config.Chance and config.StockAmount then
			if math.random() * 100 <= config.Chance then
				newStock[itemId] = math.random(config.StockAmount.Min, config.StockAmount.Max)
			else
				newStock[itemId] = 0
			end
		end
	end

	profile.Data.TurretsShopStock = newStock
	profile.Data.TurretsShopNextRestock = os.time() + RESTOCK_INTERVAL_SECONDS

	updateStocksEvent:FireClient(player, newStock)
	if not suppressNotification then
		showNotificationEvent:FireClient(player, "The Turrets Shop has been restocked!", "Normal")
	end
end

local function onPurchaseRequest(player: Player, itemId: string)
	local profile = PlayerController:GetProfile(player)
	local config = ItemConfigurations[itemId]
	if not profile or not config or config.Type ~= "Turrets" then return end

	local playerStock = profile.Data.TurretsShopStock

	if not config.Unlimited then
		if (playerStock[itemId] or 0) <= 0 then
			showNotificationEvent:FireClient(player, "This item is out of stock!", "Error")
			return
		end
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	if not (cash and cash.Value >= config.Price) then
		showNotificationEvent:FireClient(player, "Not enough cash!", "Error")
		return
	end

	cash.Value -= config.Price

	if not config.Unlimited then
		playerStock[itemId] -= 1
		updateStocksEvent:FireClient(player, playerStock)
	end

	local inventory = profile.Data.BlockInventory
	inventory[itemId] = (inventory[itemId] or 0) + 1
	ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, inventory)
	showNotificationEvent:FireClient(player, "Purchased " .. config.DisplayName .. "!", "Success")

	if profile.Data.OnboardingStep == "Step3_BuyOldTurret" then
		profile.Data.OnboardingStep = "Step3b_BuyFirstBlock"
		ReplicatedStorage.Events.UpdateOnboardingStep:FireClient(player, "Step3b_BuyFirstBlock")
	end
end

function TurretsShopController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
end

function TurretsShopController:Start()
	local eventsFolder = ReplicatedStorage.Events
	local functionsFolder = ReplicatedStorage.Functions

	updateStocksEvent  = getOrCreate(eventsFolder, "RemoteEvent", "UpdateTurretStocks") :: RemoteEvent
	getResetTime       = getOrCreate(functionsFolder, "RemoteFunction", "GetTurretShopResetTime") :: RemoteFunction
	getStocks          = getOrCreate(functionsFolder, "RemoteFunction", "GetTurretShopStocks") :: RemoteFunction
	purchaseItemEvent  = getOrCreate(eventsFolder, "RemoteEvent", "PurchaseTurretItem") :: RemoteEvent

	getResetTime.OnServerInvoke = function(player: Player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.TurretsShopNextRestock
	end

	getStocks.OnServerInvoke = function(player: Player)
		local profile = PlayerController:GetProfile(player)
		while not profile do
			task.wait()
			profile = PlayerController:GetProfile(player)
		end
		return profile.Data.TurretsShopStock
	end

	purchaseItemEvent.OnServerEvent:Connect(onPurchaseRequest)
end

return TurretsShopController
