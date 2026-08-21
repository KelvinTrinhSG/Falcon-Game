--!strict

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
-- ## MODIFIED ## Correctly require and separate the configuration tables
local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations
local LimitedItems = ItemConfigsModule.LimitedItems

local PlacementHandler  = require(ReplicatedStorage.Modules:WaitForChild("PlacementHandler"))
local FrameManager = require(ReplicatedStorage.Modules.FrameManager)

-- UI, Events, and State
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local inventoryFrame = script.Parent
local scrollingFrame = inventoryFrame:WaitForChild("ScrollingFrame")
local blocksInventoryTemplate = ReplicatedStorage.Templates:WaitForChild("BlocksInventoryTemplate")
local turretsInventoryTemplate = ReplicatedStorage.Templates:WaitForChild("TurretsInventoryTemplate")
local plotResetButton = inventoryFrame:WaitForChild("PlotReset")
local onboardingStepValue = ReplicatedStorage:WaitForChild("OnboardingStep")
local instructionsLabel = playerGui:WaitForChild("GUI"):WaitForChild("Frames"):WaitForChild("Instructions")
local ResetPlotEvent = ReplicatedStorage.Events:WaitForChild("ResetPlot")

-- ## ADDED ## Create one master table for all item configurations for easy lookups
local AllItemConfigs = {}
for id, config in pairs(ItemConfigurations) do
	AllItemConfigs[id] = config
end
for id, config in pairs(LimitedItems) do
	AllItemConfigs[id] = config
end


local function populateInventory()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("UILayout") then continue end
		child:Destroy()
	end

	local inventoryData = PlacementHandler:GetInventory()

	local itemsToDisplay = {}
	for itemId, count in pairs(inventoryData) do
		-- ## MODIFIED ## Look for the item's config in the new master table
		local config = AllItemConfigs[itemId]
		if config and count > 0 then
			table.insert(itemsToDisplay, {Id = itemId, Config = config, Count = count})
		end
	end
	table.sort(itemsToDisplay, function(a, b) return a.Config.DisplayName < b.Config.DisplayName end)

	for _, itemData in ipairs(itemsToDisplay) do
		local config = itemData.Config
		local template = if config.Type == "Blocks" then blocksInventoryTemplate else turretsInventoryTemplate
		local item = template:Clone()
		item.Name = itemData.Id

		local itemImage: ImageLabel? = item:FindFirstChild("Image")
		if itemImage then itemImage.Image = config.ImageId end

		local itemText: TextLabel? = item:FindFirstChild("Text")
		if itemText then itemText.Text = `{config.DisplayName} (x{itemData.Count})` end

		local onboardingImage = item:FindFirstChild("Onboarding")
		if onboardingImage then
			if onboardingStepValue.Value == "Step6_PlaceOldTurret" and itemData.Id == "OldTurret" then
				onboardingImage.Visible = true
				instructionsLabel.Text = "Select your old turret!"
				instructionsLabel.Visible = true

				-- ==========================================
				-- ⚡ L'AJOUT POUR LA FLÈCHE DU BLOC
				-- ==========================================
			elseif onboardingStepValue.Value == "Step6b_PlaceRockBlock" and itemData.Id == "RockBlock" then
				onboardingImage.Visible = true
				instructionsLabel.Text = "Select your Rock Block!"
				instructionsLabel.Visible = true
				-- ==========================================

			else
				onboardingImage.Visible = false
			end
		end

		item.MouseButton1Click:Connect(function()
			PlacementHandler:EnterPlacementMode(itemData.Id)
		end)

		item.Parent = scrollingFrame
	end
end

-- Listen for the state object to change to handle real-time updates.
PlacementHandler.InventoryState.Changed:Connect(function()
	if inventoryFrame.Visible then
		populateInventory()
	end
end)

inventoryFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if inventoryFrame.Visible then
		populateInventory()
	end
end)

onboardingStepValue.Changed:Connect(function()
	if inventoryFrame.Visible then
		populateInventory()
	end
end)

plotResetButton.MouseButton1Click:Connect(function()
	ResetPlotEvent:FireServer()
end)