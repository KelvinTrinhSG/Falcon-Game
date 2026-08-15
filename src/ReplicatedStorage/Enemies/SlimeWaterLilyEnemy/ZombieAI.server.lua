--!strict
-- Located in each zombie model

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EnemyConfigurations = require(ReplicatedStorage.Modules.EnemyConfigurations)
local DamageHandler = require(ReplicatedStorage.Modules.DamageHandler)

local zombie = script.Parent
local humanoid = zombie:WaitForChild("Humanoid")
local rootPart = zombie:WaitForChild("HumanoidRootPart")

local ATTACK_RANGE = 4
local ATTACK_COOLDOWN = 1
local lastAttackTime = 0
local function getDamageableTarget(instance: Instance)
	if instance:IsA("Model") and instance:GetAttribute("IsPlacedItem") == true then
		return instance
	end
	if instance:IsA("BasePart") and instance.Name == "PlotHealth" then
		return instance
	end
	local model = instance:FindFirstAncestorOfClass("Model")
	if model and model:GetAttribute("IsPlacedItem") == true then
		return model
	end
	return nil
end
task.spawn(function()
	local goalValue = zombie:FindFirstChild("Goal")
	if not goalValue or not goalValue.Value then return end

	while humanoid.Health > 0 do
		local finalGoal = goalValue.Value
		if not finalGoal or not finalGoal.Parent then break end
		local ownerPlotValue = zombie:FindFirstChild("OwnerPlot")
		local ownerPlot = ownerPlotValue and ownerPlotValue.Value
		local targetToAttack: Instance?
		local closestTargetDist = ATTACK_RANGE + 1
		if ownerPlot then
			local thingsToCheck = ownerPlot:GetChildren()
			table.insert(thingsToCheck, ownerPlot:FindFirstChild("PlotHealth"))
			for _, child in ipairs(thingsToCheck) do
				if not child then continue end
				local target = getDamageableTarget(child)
				local primaryPart = target and (target:IsA("Model") and target.PrimaryPart or target)
				if target and primaryPart then
					local distance = (rootPart.Position - primaryPart.Position).Magnitude
					if distance < closestTargetDist then
						targetToAttack = target
						closestTargetDist = distance
					end
				end
			end
		end
		if not targetToAttack then
			local goalDistance = (rootPart.Position - finalGoal.Position).Magnitude
			if goalDistance <= ATTACK_RANGE then
				targetToAttack = finalGoal
			end
		end
		if targetToAttack then
			humanoid:MoveTo(rootPart.Position)
			if os.clock() - lastAttackTime >= ATTACK_COOLDOWN then
				lastAttackTime = os.clock()
				local enemyConfig = EnemyConfigurations[zombie.Name]
				local damage = enemyConfig and enemyConfig.Damage or 10
				DamageHandler.dealDamage(zombie, targetToAttack, damage)
			end
		else
			humanoid:MoveTo(finalGoal.Position)
		end
		task.wait(0.2)
	end
end)