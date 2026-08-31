--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LimitedItems = require(ReplicatedStorage.Modules.ItemConfigurations).LimitedItems
local player = Players.LocalPlayer

local touchPartsFolder = Workspace:WaitForChild("UpgradedTitanModels"):WaitForChild("TouchParts")

local ENTRIES = {
	{ part = touchPartsFolder:WaitForChild("UpgradedTitanTVMan",      math.huge), itemId = "UpgradedTitanTVMan" },
	{ part = touchPartsFolder:WaitForChild("UpgradedTitanCameraGuy",  math.huge), itemId = "UpgradedTitanCameraGuy" },
	{ part = touchPartsFolder:WaitForChild("UpgradedTitanSpeakerman", math.huge), itemId = "UpgradedTitanSpeakerman" },
}

local debounce: {[string]: boolean} = {}

for _, entry in ipairs(ENTRIES) do
	local part = entry.part :: BasePart
	local itemId = entry.itemId
	local config = LimitedItems[itemId]
	if not config then
		warn("[UpgradedTitanTouchHandler] No config for:", itemId)
		continue
	end

	part.Touched:Connect(function(hit)
		if debounce[itemId] then return end
		if hit.Parent ~= player.Character then return end

		debounce[itemId] = true
		MarketplaceService:PromptProductPurchase(player, config.ProductID)
		task.delay(3, function()
			debounce[itemId] = false
		end)
	end)
end
