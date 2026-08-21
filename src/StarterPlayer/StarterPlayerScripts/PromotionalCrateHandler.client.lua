--!strict
-- Manages the ProximityPrompt and a Touched event for the permanent promotional crate.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)
local player = Players.LocalPlayer

task.spawn(function()
	local playerPlot: Model?
	while not playerPlot do
		local plotNum = player:GetAttribute("PlotNumber")
		if plotNum then
			playerPlot = Workspace.Plots:FindFirstChild("Plot" .. tostring(plotNum))
		end
		task.wait(1)
	end

	local promoCrate = playerPlot:WaitForChild("PromotionalTitanCrate", 10)
	if not promoCrate then
		return 
	end

	if not promoCrate.PrimaryPart then
		return
	end

	local godCrateConfig = WeaponConfigurations.Crates.TitanCrate
	if not godCrateConfig then
		return
	end

	if not (godCrateConfig.ProductID and godCrateConfig.ProductID > 0) then
		return
	end

	-- 1. ProximityPrompt Interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = godCrateConfig.DisplayName
	prompt.ActionText = "Buy"
	prompt.MaxActivationDistance = 20
	prompt.RequiresLineOfSight = false
	prompt.Parent = promoCrate.PrimaryPart

	prompt.Triggered:Connect(function()
		MarketplaceService:PromptProductPurchase(player, godCrateConfig.ProductID)
	end)

	-- 2. Touched Interaction
	local touchDebounce = false
	promoCrate.PrimaryPart.Touched:Connect(function(hit)
		if touchDebounce then return end
		if not player.Character or not hit:IsDescendantOf(player.Character) then return end

		touchDebounce = true
		MarketplaceService:PromptProductPurchase(player, godCrateConfig.ProductID)
		task.delay(3, function()
			touchDebounce = false
		end)
	end)

end)