--!strict
-- This controller manages all active turrets, finds targets, and handles firing logic.

-- Services
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Modules
local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)
local ItemConfigurations = ItemConfigsModule.ItemConfigurations
local LimitedItems = ItemConfigsModule.LimitedItems
local DamageHandler = require(ReplicatedStorage.Modules.DamageHandler)

local AllItemConfigs = {}
for id, config in pairs(ItemConfigurations) do
	AllItemConfigs[id] = config
end
for id, config in pairs(LimitedItems) do
	AllItemConfigs[id] = config
end

-- Events
local TurretFiredFX = ReplicatedStorage.Events:WaitForChild("TurretFiredFX")
local HighlightZombie = ReplicatedStorage.Events:WaitForChild("HighlightZombie")

-- CRÉATION AUTOMATIQUE DU SON
local soundsFolder = ReplicatedStorage:FindFirstChild("Sounds")
if not soundsFolder then
	soundsFolder = Instance.new("Folder")
	soundsFolder.Name = "Sounds"
	soundsFolder.Parent = ReplicatedStorage
end
local slimeDeathSound = soundsFolder:FindFirstChild("SlimeDeathSound")
if not slimeDeathSound then
	slimeDeathSound = Instance.new("Sound")
	slimeDeathSound.Name = "SlimeDeathSound"
	slimeDeathSound.SoundId = "rbxassetid://133222321566847"
	slimeDeathSound.Volume = 1
	slimeDeathSound.Parent = soundsFolder
end

-- Controller
local TurretController = {}
local _activeTurrets = {}
local _slowedEnemies = {} -- [enemyModel] = { thread, highlight }

local function applySlowEffect(hitModel: Model, slowConfig: {Duration: number, SpeedMultiplier: number})
	local humanoid = hitModel:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local existing = _slowedEnemies[hitModel]

	if existing then
		task.cancel(existing.thread)
	else
		local highlight = Instance.new("Highlight")
		highlight.Name = "SlowHighlight"
		highlight.FillColor = Color3.fromRGB(0, 120, 255)
		highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = hitModel

		_slowedEnemies[hitModel] = { highlight = highlight, thread = nil }
		existing = _slowedEnemies[hitModel]
	end

	humanoid:SetAttribute("SlowMultiplier", slowConfig.SpeedMultiplier)

	existing.thread = task.delay(slowConfig.Duration, function()
		if hitModel and hitModel.Parent then
			local h = hitModel:FindFirstChildOfClass("Humanoid")
			if h then
				h:SetAttribute("SlowMultiplier", 1)
			end
		end
		if existing.highlight and existing.highlight.Parent then
			existing.highlight:Destroy()
		end
		_slowedEnemies[hitModel] = nil
	end)
end

local function executeFireLogic(data, turretModel: Model)
	if not data.currentTarget then return end
	local targetRoot = data.currentTarget:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	local ownerId = data.plot:GetAttribute("OwnerId")
	local ownerPlayer = ownerId and Players:GetPlayerByUserId(ownerId)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local ignoreList = {turretModel}
	for _, item in ipairs(data.plot:GetChildren()) do
		if item:GetAttribute("IsPlacedItem") then
			table.insert(ignoreList, item)
		end
	end
	raycastParams.FilterDescendantsInstances = ignoreList

	for _, attachment in ipairs(data.attachments) do
		local origin = attachment.WorldPosition
		local direction = (targetRoot.Position - origin).Unit
		local result = Workspace:Raycast(origin, direction * data.config.Range, raycastParams)

		local hitSomething = false
		if result and result.Instance then
			local hitModel = nil
			local hitHumanoid = nil
			local currentObj = result.Instance

			while currentObj and currentObj ~= Workspace do
				if currentObj:IsA("Model") and currentObj:FindFirstChildOfClass("Humanoid") then
					hitModel = currentObj
					hitHumanoid = currentObj:FindFirstChildOfClass("Humanoid")
					break
				end
				currentObj = currentObj.Parent
			end

			if hitHumanoid and hitModel and hitModel:FindFirstChild("Goal") then
				local healthBefore = hitHumanoid.Health

DamageHandler.dealDamage(turretModel, hitModel, data.config.Damage)

				if data.config.SlowEffect then
					applySlowEffect(hitModel, data.config.SlowEffect)
				end

				local currentDamage = data.plot:GetAttribute("TotalDamage") or 0
				data.plot:SetAttribute("TotalDamage", currentDamage + data.config.Damage)

				if healthBefore > 0 and hitHumanoid.Health <= 0 then
					if slimeDeathSound then
						local root = hitModel.PrimaryPart or hitModel:FindFirstChild("HumanoidRootPart")
						if root then
							local soundAnchor = Instance.new("Part")
							soundAnchor.Size = Vector3.new(1, 1, 1)
							soundAnchor.Position = root.Position
							soundAnchor.Transparency = 1
							soundAnchor.Anchored = true
							soundAnchor.CanCollide = false
							soundAnchor.CanQuery = false
							soundAnchor.Parent = Workspace

							local sfx = slimeDeathSound:Clone()
							sfx.Parent = soundAnchor
							sfx:Play()

							Debris:AddItem(soundAnchor, 2)
						end
					end
				end

				if ownerPlayer then
					TurretFiredFX:FireClient(ownerPlayer, turretModel, origin, result.Position)
				end
				hitSomething = true
			end
		end

		if not hitSomething and ownerPlayer then
			TurretFiredFX:FireClient(ownerPlayer, turretModel, origin, origin + direction * data.config.Range)
		end
	end
end

local function setFX(turretModel: Model, enabled: boolean)
	task.spawn(function()
		local vfxPart = turretModel:FindFirstChild("TVVFXs", true)
		if not vfxPart then return end
		for _, desc in ipairs(vfxPart:GetDescendants()) do
			if desc:IsA("Light") or desc:IsA("ParticleEmitter") or desc:IsA("Beam") then
				desc.Enabled = enabled
			end
		end
	end)
end


function TurretController:AddTurret(turretModel: Model, plot: Model)
	local config = AllItemConfigs[turretModel.Name]
	if not config then
		warn(`[TurretController] Could not find configuration for turret named '{turretModel.Name}'`)
		return
	end

	local attachments = {}
	for _, descendant in ipairs(turretModel:GetDescendants()) do
		if descendant:IsA("Attachment") and descendant.Name == "FirePoint" then
			table.insert(attachments, descendant)
		end
	end

	local head = turretModel:FindFirstChild("Head")

	local data = {
		config = config,
		plot = plot,
		lastFireTime = 0,
		attachments = attachments,
		originalHeadCFrame = head and head.PrimaryPart and turretModel.PrimaryPart.CFrame:ToObjectSpace(head.PrimaryPart.CFrame),
		currentTarget = nil,
		lockOnTime = 0,
		attackTrack = nil,
		idleTrack = nil,
		fxEnabled = false,
	}
	_activeTurrets[turretModel] = data
	setFX(turretModel, false)

	if not data.originalHeadCFrame then
		warn("Could not store original CFrame for turret:", turretModel.Name)
	end

	local animator = turretModel:FindFirstChildWhichIsA("Animator", true)
	if animator then
		local attackAnim = turretModel:FindFirstChild("Attack")
		local idleAnim = turretModel:FindFirstChild("Idle")

		if attackAnim and attackAnim:IsA("Animation") then
			local attackTrack = animator:LoadAnimation(attackAnim)
			attackTrack.Priority = Enum.AnimationPriority.Action
			data.attackTrack = attackTrack
		end

		if idleAnim and idleAnim:IsA("Animation") then
			local idleTrack = animator:LoadAnimation(idleAnim)
			idleTrack.Priority = Enum.AnimationPriority.Idle
			idleTrack:Play()
			data.idleTrack = idleTrack
		end
	end
end

function TurretController:RemoveTurret(turretModel: Model)
	if _activeTurrets[turretModel] then
		_activeTurrets[turretModel] = nil
	end
end

function TurretController:ResetTurretRotation(turretModel: Model)
	local data = _activeTurrets[turretModel]
	local head = turretModel:FindFirstChild("Head")

	if data and data.originalHeadCFrame and head and head.PrimaryPart and turretModel.PrimaryPart then
		local resetWorldCFrame = turretModel.PrimaryPart.CFrame * data.originalHeadCFrame
		head:SetPrimaryPartCFrame(resetWorldCFrame)
	end
end

function TurretController:Start()
	RunService.Heartbeat:Connect(function(deltaTime)
		local enemiesFolder = Workspace:FindFirstChild("ActiveEnemies")
		if not enemiesFolder then return end

		local now = os.clock()

		for turretModel, data in pairs(_activeTurrets) do
			if not turretModel.PrimaryPart or not turretModel.Parent then
				self:RemoveTurret(turretModel)
				continue
			end

			local turretPosition = turretModel.PrimaryPart.Position
			local closestTarget = nil

			if data.config.TargetingMode == "FastestFarthest" then
				-- Priority 1: farthest distance within range | Priority 2: highest WalkSpeed (tiebreaker)
				local bestSpeed = -1
				local bestDist = -1
				for _, enemy in ipairs(enemiesFolder:GetChildren()) do
					local humanoid = enemy:FindFirstChildOfClass("Humanoid")
					local ownerPlotVal = enemy:FindFirstChild("OwnerPlot")
					local rootPart = enemy:FindFirstChild("HumanoidRootPart")
					if ownerPlotVal and ownerPlotVal.Value == data.plot and rootPart and humanoid and humanoid.Health > 0 then
						local dist = (rootPart.Position - turretPosition).Magnitude
						if dist <= data.config.Range then
							local speed = humanoid.WalkSpeed
							if dist > bestDist or (dist == bestDist and speed > bestSpeed) then
								closestTarget = enemy
								bestSpeed = speed
								bestDist = dist
							end
						end
					end
				end
			elseif data.config.TargetingMode == "HighestHP" then
				-- Priority: highest current HP within range
				local bestHP = -1
				for _, enemy in ipairs(enemiesFolder:GetChildren()) do
					local humanoid = enemy:FindFirstChildOfClass("Humanoid")
					local ownerPlotVal = enemy:FindFirstChild("OwnerPlot")
					local rootPart = enemy:FindFirstChild("HumanoidRootPart")
					if ownerPlotVal and ownerPlotVal.Value == data.plot and rootPart and humanoid and humanoid.Health > 0 then
						local dist = (rootPart.Position - turretPosition).Magnitude
						if dist <= data.config.Range and humanoid.Health > bestHP then
							closestTarget = enemy
							bestHP = humanoid.Health
						end
					end
				end
			else
				-- Default: closest enemy within range
				local closestDist = data.config.Range
				for _, enemy in ipairs(enemiesFolder:GetChildren()) do
					local humanoid = enemy:FindFirstChildOfClass("Humanoid")
					local ownerPlotVal = enemy:FindFirstChild("OwnerPlot")
					local rootPart = enemy:FindFirstChild("HumanoidRootPart")
					if ownerPlotVal and ownerPlotVal.Value == data.plot and rootPart and humanoid and humanoid.Health > 0 then
						local dist = (rootPart.Position - turretPosition).Magnitude
						if dist < closestDist then
							closestTarget = enemy
							closestDist = dist
						end
					end
				end
			end

			if closestTarget ~= data.currentTarget then
				data.lockOnTime = now
				data.currentTarget = closestTarget
			end

			local head = turretModel:FindFirstChild("Head")
			if head and head.PrimaryPart and data.currentTarget and data.currentTarget.PrimaryPart then
				local headPart = head.PrimaryPart
				local targetPosition = data.currentTarget.PrimaryPart.Position
				local lookAtPoint = Vector3.new(targetPosition.X, headPart.Position.Y, targetPosition.Z)
				local newCFrame = CFrame.lookAt(headPart.Position, lookAtPoint)
				head:SetPrimaryPartCFrame(newCFrame)
			end

			local waveSpeedMultiplier = data.plot:GetAttribute("WaveSpeed") or 1
			local currentCooldown = data.config.Cooldown / waveSpeedMultiplier

			if not data.currentTarget then
				if data.attackTrack and data.attackTrack.IsPlaying then data.attackTrack:Stop() end
				if data.idleTrack and not data.idleTrack.IsPlaying then data.idleTrack:Play() end
				if data.fxEnabled then
					data.fxEnabled = false
					setFX(turretModel, false)
				end
				continue
			end

			if now - data.lastFireTime < currentCooldown then
				continue
			end

			if now - data.lockOnTime >= 0.1 then
				data.lastFireTime = now
				if data.idleTrack and data.idleTrack.IsPlaying then data.idleTrack:Stop() end
				if data.attackTrack then
					data.attackTrack:Stop()
					data.attackTrack:Play()
					data.attackTrack:AdjustSpeed(waveSpeedMultiplier)
				end
				if not data.fxEnabled then
					data.fxEnabled = true
					setFX(turretModel, true)
				end
				executeFireLogic(data, turretModel)
			end
		end
	end)
end

return TurretController
