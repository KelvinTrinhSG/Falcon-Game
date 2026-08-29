--!strict

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Define the Controller Module
local ShopController = {}

-- Events
local openShopFrameEvent: RemoteEvent = ReplicatedStorage.Events:WaitForChild("OpenShopFrame")

local shops = {
	WeaponsShop = Workspace:WaitForChild("WeaponsShop"),
	BlocksShop = Workspace:WaitForChild("BlocksShop"),
	TurretsShop = Workspace:WaitForChild("TurretsShop"),
	BasesShop = Workspace:WaitForChild("BasesShop"),
}

-- State
local debounce = {}

local function setupShopTrigger(shopName: string, shopModel: Model)
	local touchPart = shopModel:FindFirstChild("Touch")

	if not (touchPart and touchPart:IsA("BasePart")) then
		warn(`Shop trigger part not found for '{shopName}'. Please add a BasePart named "Touch" to the model.`)
		return
	end

	touchPart.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		if not player then return end
		if debounce[player] then return end

		debounce[player] = true

		print(`Player {player.Name} touched the {shopName} trigger.`)
		openShopFrameEvent:FireClient(player, shopName)

		task.delay(1, function()
			debounce[player] = nil
		end)
	end)

	print(`Successfully set up trigger for {shopName}.`)
end

function ShopController:Start()
	for name, model in pairs(shops) do
		setupShopTrigger(name, model)
	end
end

return ShopController