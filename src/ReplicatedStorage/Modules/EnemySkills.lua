--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)

local EnemySkills = {}

function EnemySkills.explodeOnDeath(zombie: Model, radius: number)
	local rootPart = zombie:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local position = (rootPart :: BasePart).Position

	-- Visual: quả cầu đỏ neon + forcefield sparkle
	local sphere = Instance.new("Part")
	sphere.Shape = Enum.PartType.Ball
	sphere.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
	sphere.CFrame = CFrame.new(position)
	sphere.Anchored = true
	sphere.CanCollide = false
	sphere.CastShadow = false
	sphere.Color = Color3.fromRGB(220, 30, 30)
	sphere.Material = Enum.Material.Neon
	sphere.Transparency = 0.35
	sphere.Parent = Workspace

	local ff = Instance.new("ForceField")
	ff.Visible = true
	ff.Parent = sphere

	Debris:AddItem(sphere, 0.5)

	-- Damage logic
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {zombie}

	local parts = Workspace:GetPartBoundsInRadius(position, radius, overlapParams)

	local hitModels: {[Model]: boolean} = {}

	for _, part in ipairs(parts) do
		local model = part:FindFirstAncestorOfClass("Model")
		if not model or hitModels[model] then continue end
		hitModels[model] = true

		-- Bỏ qua player characters
		if Players:GetPlayerFromCharacter(model) then continue end

		-- Phá block, bỏ qua turret
		if model:GetAttribute("IsPlacedItem") then
			local config = nil
			if ItemConfigsModule.ItemConfigurations then
				config = ItemConfigsModule.ItemConfigurations[model.Name] or (ItemConfigsModule.LimitedItems and ItemConfigsModule.LimitedItems[model.Name])
			else
				config = (ItemConfigsModule :: any)[model.Name]
			end
			if config and config.Type == "Blocks" then
				model:SetAttribute("Health", 0)
				model:Destroy()
			end
			continue
		end

		-- Tiêu diệt enemy khác (có Goal = enemy đang active)
		if model:FindFirstChild("Goal") then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
		end
	end
end

return EnemySkills
