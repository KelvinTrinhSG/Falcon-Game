--!strict
-- Fixes camera zoom-into-turret by setting CanCollide=false on turret parts locally.
-- Server physics unaffected; only affects local camera occlusion detection.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations

local player = Players.LocalPlayer

local function fixTurretCollision(model: Model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "PlacementBox" then
			part.CanCollide = false
		end
	end
end

local function watchPlot(plot: Model)
	for _, child in ipairs(plot:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("IsPlacedItem") then
			local config = ItemConfigurations[child.Name]
			if config and config.Type == "Turrets" then
				fixTurretCollision(child :: Model)
			end
		end
	end

	plot.ChildAdded:Connect(function(child)
		if not child:IsA("Model") then return end
		task.defer(function()
			if not child.Parent then return end
			if not child:GetAttribute("IsPlacedItem") then return end
			local config = ItemConfigurations[child.Name]
			if config and config.Type == "Turrets" then
				fixTurretCollision(child :: Model)
			end
		end)
	end)
end

local function init()
	local plots = Workspace:WaitForChild("Plots")

	local function tryWatch(plot: Instance)
		if not plot:IsA("Model") then return end
		local function onOwnerChanged()
			if (plot :: Model):GetAttribute("OwnerId") == player.UserId then
				watchPlot(plot :: Model)
			end
		end
		plot:GetAttributeChangedSignal("OwnerId"):Connect(onOwnerChanged)
		onOwnerChanged()
	end

	for _, plot in ipairs(plots:GetChildren()) do
		tryWatch(plot)
	end
	plots.ChildAdded:Connect(tryWatch)
end

init()
