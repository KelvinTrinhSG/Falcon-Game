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

-- Buff invincible tất cả enemy đang active, tác dụng `duration` giây rồi tự hết
-- buffedSpheres: {[Model]: Part} — managed by the caller (DJYellowToiletBuff ZombieAI)
function EnemySkills.activateInvincibleBuff(caster: Model, duration: number, buffedSpheres: {[Model]: Part})
	local activeEnemies = Workspace:FindFirstChild("ActiveEnemies")
	if not activeEnemies then return end

	local endTime = os.clock() + duration

	local function applyToEnemy(enemyModel: Model)
		if enemyModel == caster then return end
		if not enemyModel:FindFirstChild("Goal") then return end
		if enemyModel:GetAttribute("InvincibleActive") then return end

		local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
		local targetRoot = enemyModel:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not targetRoot then return end

		enemyModel:SetAttribute("IsInvincible", true)
		enemyModel:SetAttribute("InvincibleActive", true)

		local sphere = Instance.new("Part")
		sphere.Shape = Enum.PartType.Ball
		sphere.Size = Vector3.new(5, 5, 5)
		local yOffset = if enemyModel:GetAttribute("IsFlying") then 1.9 else 0
		sphere.CFrame = (targetRoot :: BasePart).CFrame + Vector3.new(0, yOffset, 0)
		sphere.Anchored = false
		sphere.CanCollide = false
		sphere.CastShadow = false
		sphere.Massless = true
		sphere.Color = Color3.fromRGB(0, 120, 255)
		sphere.Material = Enum.Material.Neon
		sphere.Transparency = 0.7
		sphere.Parent = enemyModel

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = sphere
		weld.Part1 = targetRoot :: BasePart
		weld.Parent = sphere

		local ff = Instance.new("ForceField")
		ff.Visible = true
		ff.Parent = sphere

		buffedSpheres[enemyModel] = sphere

		local remaining = endTime - os.clock()
		task.delay(remaining, function()
			if buffedSpheres[enemyModel] ~= sphere then return end
			if enemyModel.Parent then
				enemyModel:SetAttribute("IsInvincible", nil)
				enemyModel:SetAttribute("InvincibleActive", nil)
			end
			sphere:Destroy()
			buffedSpheres[enemyModel] = nil
		end)
	end

	-- Áp dụng ngay cho tất cả enemy hiện tại
	for _, enemyModel in ipairs(activeEnemies:GetChildren()) do
		if enemyModel:IsA("Model") then
			applyToEnemy(enemyModel :: Model)
		end
	end

	-- Monitor enemy spawn mới trong suốt thời gian buff còn hiệu lực
	task.spawn(function()
		while os.clock() < endTime do
			for _, enemyModel in ipairs(activeEnemies:GetChildren()) do
				if enemyModel:IsA("Model") then
					applyToEnemy(enemyModel :: Model)
				end
			end
			task.wait(0.5)
		end
	end)
end

return EnemySkills
