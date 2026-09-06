--!strict
-- Located in each zombie model

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local EnemyConfigurations = require(ReplicatedStorage.Modules.EnemyConfigurations)
local DamageHandler = require(ReplicatedStorage.Modules.DamageHandler)

-- ⚡ NOUVEAU : On importe les configurations de tes objets pour distinguer Blocs et Tourelles
local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)

local zombie = script.Parent
local humanoid = zombie:WaitForChild("Humanoid")
local rootPart = zombie:WaitForChild("HumanoidRootPart")

local ATTACK_RANGE = 4
local ATTACK_COOLDOWN = 1
local lastAttackTime = 0

local function getDamageableTarget(instance: Instance)
	-- 1. Si c'est le Core/Base (PlotHealth), on l'attaque toujours !
	if instance:IsA("BasePart") and instance.Name == "PlotHealth" then
		return instance
	end

	-- 2. On cherche si l'objet fait partie d'un modèle posé
	local model = nil
	if instance:IsA("Model") then
		model = instance
	else
		model = instance:FindFirstAncestorOfClass("Model")
	end

	-- 3. Si on trouve un modèle posé par le joueur
	if model and model:GetAttribute("IsPlacedItem") == true then

		-- On cherche sa configuration dans ItemConfigurations
		local config = nil
		if ItemConfigsModule.ItemConfigurations then
			config = ItemConfigsModule.ItemConfigurations[model.Name] or (ItemConfigsModule.LimitedItems and ItemConfigsModule.LimitedItems[model.Name])
		else
			config = ItemConfigsModule[model.Name]
		end

		-- ⚡ LA MAGIE EST ICI : On retourne le modèle SEULEMENT si c'est un bloc !
		if config and config.Type == "Blocks" then
			if not zombie:GetAttribute("IsFlying") then
				return model
			end
		end
	end

	-- Si ce n'est ni le Core, ni un Bloc (ex: c'est une tourelle), on l'ignore.
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

				-- On utilise notre fonction modifiée ici
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