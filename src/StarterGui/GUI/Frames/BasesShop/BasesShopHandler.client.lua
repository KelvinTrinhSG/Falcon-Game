--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local BaseConfigurations = ItemConfigsModule.BaseConfigurations
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)

local player = Players.LocalPlayer
local shopFrame = script.Parent
local scrollingFrame = shopFrame:WaitForChild("ScrollingFrame")
local itemTemplate = ReplicatedStorage.Templates:WaitForChild("BasesTemplate")

local purchaseBaseEvent = ReplicatedStorage.Events:WaitForChild("PurchaseBase")
local equipBaseEvent    = ReplicatedStorage.Events:WaitForChild("EquipBase")
local baseDataUpdatedEvent = ReplicatedStorage.Events:WaitForChild("BaseDataUpdated")
local getBaseDataFunc   = ReplicatedStorage.Functions:WaitForChild("GetBaseData")

local ownedBases: {string} = {}
local equippedBase: string = "Core1"

-- Sort bases by tier (Core1 → Core5)
local TIER_ORDER = {"Core1", "Core2", "Core3", "Core4", "Core5"}

local function populateShop()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end

	for _, baseId in ipairs(TIER_ORDER) do
		local config = BaseConfigurations[baseId]
		if not config then continue end

		local item = itemTemplate:Clone()
		item.Name = baseId

		local isOwned    = table.find(ownedBases, baseId) ~= nil
		local isEquipped = equippedBase == baseId

		local nameLabel: TextLabel? = item:FindFirstChild("ItemName")
		if nameLabel then nameLabel.Text = config.DisplayName end

		local healthLabel: TextLabel? = item:FindFirstChild("ItemHealth")
		if healthLabel then healthLabel.Text = "HP: " .. config.Health end

		local priceLabel: TextLabel? = item:FindFirstChild("ItemPrice")
		if priceLabel then
			priceLabel.Text = if config.Price == 0 then "Free" else NumberFormatter.formatNumber(config.Price, "$")
		end

		local buyButton: TextButton? = item:FindFirstChild("BuyButton")
		local equipButton: TextButton? = item:FindFirstChild("EquipButton")
		local equippedLabel: TextLabel? = item:FindFirstChild("EquippedLabel")

		if isEquipped then
			if buyButton then buyButton.Visible = false end
			if equipButton then equipButton.Visible = false end
			if equippedLabel then equippedLabel.Visible = true end
		elseif isOwned then
			if buyButton then buyButton.Visible = false end
			if equippedLabel then equippedLabel.Visible = false end
			if equipButton then
				equipButton.Visible = true
				equipButton.MouseButton1Click:Connect(function()
					equipBaseEvent:FireServer(baseId)
				end)
			end
		else
			if equippedLabel then equippedLabel.Visible = false end
			if equipButton then equipButton.Visible = false end
			if buyButton then
				buyButton.Visible = true
				buyButton.MouseButton1Click:Connect(function()
					purchaseBaseEvent:FireServer(baseId)
				end)
			end
		end

		item.Parent = scrollingFrame
	end
end

baseDataUpdatedEvent.OnClientEvent:Connect(function(newOwned: {string}, newEquipped: string)
	ownedBases = newOwned
	equippedBase = newEquipped
	if shopFrame.Visible then
		populateShop()
	end
end)

shopFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if shopFrame.Visible then
		populateShop()
	end
end)

-- Load initial data
local success, owned, equipped = pcall(getBaseDataFunc.InvokeServer, getBaseDataFunc)
if success and owned then
	ownedBases = owned
	equippedBase = equipped or "Core1"
else
	warn("[BasesShopHandler] Could not get initial base data.")
end
