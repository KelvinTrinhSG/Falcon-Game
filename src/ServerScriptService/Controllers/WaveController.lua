--!strict
-- LOCATION: ServerScriptService/Controllers/WaveController.lua

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService") 

-- Modules
local PlayerController
local TurretController
local PlacementController
local WeaponController
local PlotController 
local WaveConfigurations = require(ReplicatedStorage.Modules.WaveConfigurations)
local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations)
local EnemyConfigurations = require(ReplicatedStorage.Modules.EnemyConfigurations)

-- Constants
local INTERMISSION_TIME = 1
local FINAL_VICTORY_CASH = 1000
local GAMEPASS_X3_SPEED = 1968442351

-- Controller
local WaveController = {}
local _plotStates = {}
local _fightToggleDebounce = {}
local _autoWaveStates = {}
local _playerSpeeds = {} 

local activeEnemiesFolder = Workspace:FindFirstChild("ActiveEnemies")
if not activeEnemiesFolder then
	activeEnemiesFolder = Instance.new("Folder")
	activeEnemiesFolder.Name = "ActiveEnemies"
	activeEnemiesFolder.Parent = Workspace
end

-- Fonction pour trouver le Plot du joueur, compatible avec l'astuce du "Déguisement"
local function getPlotForPlayer(player: Player): Model?
	local plotNum = player:GetAttribute("PlotNumber")
	if plotNum then
		local plot = Workspace.Plots:FindFirstChild("Plot" .. tostring(plotNum))
		if plot and plot:IsA("Model") then
			return plot
		end
	end
	for _, plot in ipairs(Workspace.Plots:GetChildren()) do
		if plot:IsA("Model") and plot:GetAttribute("OwnerId") == player.UserId then
			return plot
		end
	end
	return nil
end

function WaveController:IsPlayerFighting(player: Player): boolean
	local plot = getPlotForPlayer(player)
	if not plot or not _plotStates[plot] then return false end
	return _plotStates[plot].IsActive
end

local function getRandomSpawnCFrame(spawnPart: BasePart): CFrame
	local size = spawnPart.Size
	local randomX = (math.random() - 0.5) * size.X
	local randomZ = (math.random() - 0.5) * size.Z
	local yOffset = size.Y / 2 + 3
	return spawnPart.CFrame * CFrame.new(randomX, yOffset, randomZ)
end

local function getRandomPathFolder(plot: Model): Folder?
	local pathFolder = plot:FindFirstChild("Path")
	local waypointsFolder = pathFolder and pathFolder:FindFirstChild("Waypoints")
	if not waypointsFolder then return nil end

	local pathFolders = {}
	for _, child in ipairs(waypointsFolder:GetChildren()) do
		if child:IsA("Folder") then
			table.insert(pathFolders, child)
		end
	end

	if #pathFolders > 0 then
		return pathFolders[math.random(1, #pathFolders)]
	end
	return waypointsFolder
end

local function getPathFolder(plot: Model, pathConfig: (string | {string})?): Folder?
	local pathFolder = plot:FindFirstChild("Path")
	local waypointsFolder = pathFolder and pathFolder:FindFirstChild("Waypoints")
	if not waypointsFolder then return nil end

	local function findNamed(name: string): Folder?
		local f = waypointsFolder:FindFirstChild(name)
		if f and f:IsA("Folder") then return f end
		warn("[WaveController] Path '" .. name .. "' không tìm thấy, dùng random.")
		return nil
	end

	if not pathConfig then
		return getRandomPathFolder(plot)
	elseif type(pathConfig) == "string" then
		return findNamed(pathConfig) or getRandomPathFolder(plot)
	elseif type(pathConfig) == "table" then
		local name = pathConfig[math.random(1, #pathConfig)]
		return findNamed(name) or getRandomPathFolder(plot)
	end
	return getRandomPathFolder(plot)
end

local function moveEnemyAlongWaypoints(enemy: Model, humanoid: Humanoid, plot: Model, state: table, goalValue: ObjectValue, enemyConfig: table, attackTrack: AnimationTrack?, preSelectedFolder: Folder?)
	local pathFolder = plot:FindFirstChild("Path")
	local waypointsFolder = pathFolder and pathFolder:FindFirstChild("Waypoints")
	local isFlying = enemy:GetAttribute("IsFlying") == true

	if not waypointsFolder then return end

	local waypoints = {}

	local sourceFolder = preSelectedFolder or getRandomPathFolder(plot)
	if not sourceFolder then return end

	for _, wp in ipairs(sourceFolder:GetChildren()) do
		if wp:IsA("BasePart") then
			table.insert(waypoints, wp)
		end
	end

	table.sort(waypoints, function(a, b)
		if a.Name == "End" then return false end
		if b.Name == "End" then return true end

		local numA = tonumber(a.Name)
		local numB = tonumber(b.Name)
		if numA and numB then return numA < numB end
		return a.Name < b.Name
	end)

	task.spawn(function()
		for _, wp in ipairs(waypoints) do
			if not enemy.Parent or humanoid.Health <= 0 or not state.IsActive then break end

			if goalValue then goalValue.Value = wp end

			local reached = false

			-- Gọi ngay lập tức để Humanoid bắt đầu di chuyển trong khi physics đang settle
			humanoid:MoveTo(wp.Position)

			while not reached and humanoid.Health > 0 and enemy.Parent and state.IsActive do
				task.wait(0.1)

				local rootPart = enemy:FindFirstChild("HumanoidRootPart")
				if not rootPart then break end

				local dist = (Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z) - Vector3.new(wp.Position.X, 0, wp.Position.Z)).Magnitude

				local requiredDistance = 1.5
				if wp.Name == "End" then requiredDistance = 5 end

				if dist <= requiredDistance then
					reached = true
					break
				end

				local isBlocked = false

				if not isFlying then
					local attackCooldown = enemy:GetAttribute("LastAttack") or 0
					local waveSpeedMultiplier = plot:GetAttribute("WaveSpeed") or 1
					local attackRate = (enemyConfig.AttackCooldown or 1) / waveSpeedMultiplier

					local hitboxCFrame = rootPart.CFrame * CFrame.new(0, 0, -1.5)
					local hitboxSize = Vector3.new(1.5, 4, 2)
					local overlapParams = OverlapParams.new()
					overlapParams.FilterType = Enum.RaycastFilterType.Include
					overlapParams.FilterDescendantsInstances = {plot}

					local partsInBox = Workspace:GetPartBoundsInBox(hitboxCFrame, hitboxSize, overlapParams)

					for _, part in ipairs(partsInBox) do
						local hitModel = part:FindFirstAncestorOfClass("Model")
						if hitModel and hitModel:GetAttribute("IsPlacedItem") then

							local config = nil
							if ItemConfigurations.ItemConfigurations then
								config = ItemConfigurations.ItemConfigurations[hitModel.Name] or ItemConfigurations.LimitedItems[hitModel.Name]
							else
								config = ItemConfigurations[hitModel.Name]
							end

							-- ⚡ CORRECTION : On s'assure que c'est un bloc et SURTOUT PAS une tourelle
							local isBlock = (config and config.Type == "Blocks")
							local isTurret = (config and config.Type == "Turrets")

							if isBlock and not isTurret then
								local health = hitModel:GetAttribute("Health")
								if health and health > 0 then
									isBlocked = true
									humanoid:MoveTo(rootPart.Position)

									local now = os.clock()
									if now - attackCooldown >= attackRate then
										enemy:SetAttribute("LastAttack", now)

										if attackTrack then
											attackTrack:Play()
										else
											if rootPart then
												rootPart.AssemblyLinearVelocity = (rootPart.CFrame.LookVector * 15) + Vector3.new(0, 20, 0)
											end
										end

										local dmg = enemyConfig.Damage or 10
										local newHealth = health - dmg
										hitModel:SetAttribute("Health", newHealth)

										if newHealth <= 0 then hitModel:Destroy() end
									end
									break
								end
							end
						end
					end
				end

				if not isBlocked then
					humanoid:MoveTo(wp.Position)
				end
			end
		end

		if humanoid.Health > 0 and enemy.Parent and state.IsActive then
			local coreBuilding = plot:FindFirstChild("Core1")
			if coreBuilding then
				local baseDamage = (enemyConfig and enemyConfig.BaseDamage) or 10
				local currentHealth = coreBuilding:GetAttribute("Health") or 0
				local newHealth = math.max(0, currentHealth - baseDamage)
				coreBuilding:SetAttribute("Health", newHealth)
			end
			humanoid.Health = 0
		end
	end)
end

local startNextWave
local stopFight
local startFight

startNextWave = function(player: Player, plot: Model)
	local state = _plotStates[plot]
	if not state or not state.IsActive then return end

	state.IsStartingNextWave = false

	local profile = PlayerController:GetProfile(player)
	if not profile then stopFight(plot, "manual"); return end
	state.CurrentWave += 1

	local waveConfig = WaveConfigurations[state.CurrentWave]

	if not waveConfig then
		local leaderstats = player:FindFirstChild("leaderstats")
		local cash = leaderstats and leaderstats:FindFirstChild("Cash")
		if cash then
			local multiplier = player:GetAttribute("CashMultiplier") or 1
			cash.Value += math.floor(FINAL_VICTORY_CASH * multiplier)
		end
		ReplicatedStorage.Events.ShowNotification:FireClient(player, "You've beaten all waves! Congratulations!", "Mythical")
		stopFight(plot, "win")
		return
	end

	if state.CurrentWave > profile.Data.HighestWave then
		profile.Data.HighestWave = state.CurrentWave
		local leaderstats = player:FindFirstChild("leaderstats")
		local highestWaveValue = leaderstats and leaderstats:FindFirstChild("Highest Wave")
		if highestWaveValue then highestWaveValue.Value = state.CurrentWave end
	end

	local totalEnemiesInWave = 0
	for _, group in ipairs(waveConfig.Enemies) do totalEnemiesInWave += group.Count end
	state.EnemiesKilledInWave = 0
	state.TotalEnemiesInWave = totalEnemiesInWave

	ReplicatedStorage.Events.WaveUIStateChanged:FireClient(player, true, state.CurrentWave, totalEnemiesInWave, waveConfig.IsBossWave)

	for _, group in ipairs(waveConfig.Enemies) do
		task.spawn(function()
			local enemyTemplate = ReplicatedStorage.Enemies:FindFirstChild(group.Enemy)
			if not enemyTemplate then return end
			for i = 1, group.Count do
				if not state.IsActive then return end
				local enemy = enemyTemplate:Clone()
				local humanoid = enemy:WaitForChild("Humanoid")
				local enemyConfig = EnemyConfigurations[enemy.Name]

				if enemyConfig and enemyConfig.MaxHealth then
					humanoid.MaxHealth = enemyConfig.MaxHealth
					humanoid.Health = enemyConfig.MaxHealth
				end

				if waveConfig.IsBossWave then
					humanoid.HumanoidDescription.HeightScale = 1
					humanoid.HumanoidDescription.WidthScale = 1
					humanoid.MaxSlopeAngle = 0
					humanoid.AutoJumpEnabled = false
					humanoid.JumpPower = 0
				end

				local baseWalkSpeed = (enemyConfig and enemyConfig.WalkSpeed) or humanoid.WalkSpeed
				local currentSpeed = _playerSpeeds[player] or 1
				humanoid.WalkSpeed = baseWalkSpeed * currentSpeed
				humanoid:SetAttribute("BaseWalkSpeed", baseWalkSpeed)

				if enemyConfig and enemyConfig.IsFlying then
					enemy:SetAttribute("IsFlying", true)
				end

				local goalValue = Instance.new("ObjectValue")
				goalValue.Name = "Goal"
				goalValue.Value = plot:FindFirstChild("Core1")
				goalValue.Parent = enemy

				local ownerPlotValue = Instance.new("ObjectValue")
				ownerPlotValue.Name = "OwnerPlot"
				ownerPlotValue.Value = plot
				ownerPlotValue.Parent = enemy

				for _, descendant in ipairs(enemy:GetDescendants()) do
					if descendant:IsA("BasePart") then
						descendant.CollisionGroup = "Zombies"
					end
				end

				local toiletModel = enemy:FindFirstChild("Toilet")
				if toiletModel then
					for _, descendant in ipairs(toiletModel:GetDescendants()) do
						if descendant:IsA("BasePart") then
							descendant.CanCollide = false
							descendant.Massless = true
						end
					end
				end

				if not enemy.PrimaryPart then
					enemy.PrimaryPart = enemy:FindFirstChild("HumanoidRootPart")
				end

				local selectedFolder = getPathFolder(plot, group.Path)
				local spawnWaypoint = selectedFolder and selectedFolder:FindFirstChild("1")
				if spawnWaypoint then
					enemy:SetPrimaryPartCFrame(getRandomSpawnCFrame(spawnWaypoint))
				else
					local fallback = plot:FindFirstChild("EnemySpawn")
					if fallback then
						enemy:SetPrimaryPartCFrame(getRandomSpawnCFrame(fallback))
					end
				end
				enemy.Parent = activeEnemiesFolder

				local rootPart = enemy:FindFirstChild("HumanoidRootPart")
				if rootPart then rootPart:SetNetworkOwner(nil) end

				if waveConfig.IsBossWave then
					local isTheRealBoss = (group.Enemy == "BossToilet" or group.Enemy == "BossToilet2")
					if isTheRealBoss then
						ReplicatedStorage.Events.BossWaveStarted:FireClient(player, humanoid, waveConfig.BossImageId)
					end
				end

				local attackTrack = nil
				local animator = humanoid:FindFirstChildOfClass("Animator")
				if not animator then
					animator = Instance.new("Animator")
					animator.Parent = humanoid
				end

				local attackAnim = enemy:FindFirstChild("AttackAnimation")
				if attackAnim and attackAnim:IsA("Animation") then
					attackTrack = animator:LoadAnimation(attackAnim)
				end

				moveEnemyAlongWaypoints(enemy, humanoid, plot, state, goalValue, enemyConfig, attackTrack, selectedFolder)

				local function onEnemyDeath()
					state.EnemiesKilledInWave += 1
					state.TotalKills += 1

					local reachedEnd = false
					local pathFolder = plot:FindFirstChild("Path")
					local waypointsFolder = pathFolder and pathFolder:FindFirstChild("Waypoints")
					local endPoint = nil

					if waypointsFolder then
						for _, folder in ipairs(waypointsFolder:GetChildren()) do
							if folder:IsA("Folder") then
								local ep = folder:FindFirstChild("End")
								if ep then
									if not endPoint or (rootPart and
										(rootPart.Position - ep.Position).Magnitude <
										(rootPart.Position - endPoint.Position).Magnitude)
									then
										endPoint = ep
									end
								end
							end
						end
						if not endPoint then
							endPoint = waypointsFolder:FindFirstChild("End")
						end
					end

					if rootPart and endPoint then
						local dist = (Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z) - Vector3.new(endPoint.Position.X, 0, endPoint.Position.Z)).Magnitude
						if dist <= 5 then reachedEnd = true end
					end

					if not reachedEnd and enemyConfig and enemyConfig.CashReward then
						local leaderstats = player:FindFirstChild("leaderstats")
						local cash = leaderstats and leaderstats:FindFirstChild("Cash")
						if cash then 
							local multiplier = player:GetAttribute("CashMultiplier") or 1
							cash.Value += math.floor(enemyConfig.CashReward * multiplier) 
						end
					end

					ReplicatedStorage.Events.ZombieKilled:FireClient(player, state.EnemiesKilledInWave, state.CurrentWave)
					enemy:Destroy() 

					if state.EnemiesKilledInWave >= state.TotalEnemiesInWave and state.IsActive and not state.IsStartingNextWave then
						state.IsStartingNextWave = true
						task.spawn(function()
							local completedWaveConfig = WaveConfigurations[state.CurrentWave]
							if completedWaveConfig.IsBossWave then ReplicatedStorage.Events.BossWaveEnded:FireClient(player) end

							if completedWaveConfig.CashReward then
								local leaderstats = player:FindFirstChild("leaderstats")
								local cash = leaderstats and leaderstats:FindFirstChild("Cash")
								if cash then
									local multiplier = player:GetAttribute("CashMultiplier") or 1
									local finalReward = math.floor(completedWaveConfig.CashReward * multiplier)
									cash.Value += finalReward
									ReplicatedStorage.Events.ShowCollectionEffect:FireClient(player, finalReward)
								end
							end

							if state.CurrentWave == 100 then
								if profile.Data.HighestWave < 100 then profile.Data.HighestWave = 100 end
								stopFight(plot, "win")
								ReplicatedStorage.Events.ShowNotification:FireClient(player, "INCROYABLE ! Tu as battu la vague 100 ! Ton Plot évolue en V2 !", "Mythical")
								return 
							end

							if profile and completedWaveConfig.UnlocksStartingWave then
								if completedWaveConfig.UnlocksStartingWave > profile.Data.StartingWave then
									profile.Data.StartingWave = completedWaveConfig.UnlocksStartingWave
									ReplicatedStorage.Events.ShowNotification:FireClient(player, `Checkpoint unlocked! You will now start at Wave {profile.Data.StartingWave}.`, "Normal")
								end
							end

							task.wait(INTERMISSION_TIME)
							if state.IsActive then startNextWave(player, plot) end
						end)
					end
				end

				humanoid.Died:Once(onEnemyDeath)

				local currentWaitSpeed = _playerSpeeds[player] or 1
				task.wait(group.DelayBetweenSpawns / currentWaitSpeed)
			end
		end)
	end
end

stopFight = function(plot: Model, reason: string)
	local state = _plotStates[plot]
	if not state then return end
	local player = Players:GetPlayerByUserId(plot:GetAttribute("OwnerId"))
	state.IsActive = false
	if state.HealthConnection then
		state.HealthConnection:Disconnect()
		state.HealthConnection = nil
	end
	for _, enemy in ipairs(activeEnemiesFolder:GetChildren()) do
		local ownerPlotValue = enemy:FindFirstChild("OwnerPlot")
		if ownerPlotValue and ownerPlotValue.Value == plot then
			enemy:Destroy()
		end
	end
	_plotStates[plot] = nil
	if player then
		if reason == "manual" then
			ReplicatedStorage.Events.EquipLastWeaponRequest:FireClient(player)
		end
		for _, itemModel in ipairs(plot:GetChildren()) do
			if itemModel:GetAttribute("IsPlacedItem") then
				local config = ItemConfigurations[itemModel.Name]
				if config and config.Type == "Turrets" then
					TurretController:RemoveTurret(itemModel)
				end
				itemModel:Destroy()
			end
		end
		task.wait(0.1)
		PlacementController:LoadPlacedItems(player, plot)
		local profile = PlayerController:GetProfile(player)
		if profile then
			local coreBuilding = plot:FindFirstChild("Core1")
			if coreBuilding then
				local maxHealth = coreBuilding:GetAttribute("MaxHealth") or 100
				coreBuilding:SetAttribute("Health", maxHealth)
			end
		end
		ReplicatedStorage.Events.WaveStateChanged:FireClient(player, false)
		ReplicatedStorage.Events.WaveUIStateChanged:FireClient(player, false)
		ReplicatedStorage.Events.BossWaveEnded:FireClient(player)

		if reason == "loss" and _autoWaveStates[player] == true then
			task.wait(1)
			if player.Parent then startFight(player) end
		end
	end
end

startFight = function(player: Player)
	local plot = getPlotForPlayer(player)
	if not plot then return end
	local profile = PlayerController:GetProfile(player)
	if not profile or _plotStates[plot] then return end

	local coreBuilding = plot:FindFirstChild("Core1")
	if not coreBuilding then return end
	local maxHealth = coreBuilding:GetAttribute("MaxHealth") or 100
	coreBuilding:SetAttribute("Health", maxHealth)

	plot:SetAttribute("TotalDamage", 0)

	_plotStates[plot] = {
		IsActive = true,
		CurrentWave = profile.Data.StartingWave - 1,
		EnemiesKilledInWave = 0,
		TotalEnemiesInWave = 0,
		TotalKills = 0,
		StartTime = os.clock(),
		IsStartingNextWave = false,
		HealthConnection = coreBuilding:GetAttributeChangedSignal("Health"):Connect(function()
			if coreBuilding:GetAttribute("Health") <= 0 then
				local state = _plotStates[plot]
				local reachedWave = state and state.CurrentWave or 0
				local totalKills = state and state.TotalKills or 0
				local timeSurvived = state and math.floor(os.clock() - state.StartTime) or 0
				local totalDamage = plot:GetAttribute("TotalDamage") or 0

				ReplicatedStorage.Events.ShowGameOver:FireClient(player, reachedWave, totalKills, totalDamage, timeSurvived)
				ReplicatedStorage.Events.ShowNotification:FireClient(player, "Your Core was destroyed!", "Error")
				stopFight(plot, "loss")
			end
		end)
	}

	ReplicatedStorage.Events.WaveStateChanged:FireClient(player, true, maxHealth, maxHealth)
	startNextWave(player, plot)
end

function WaveController:SetWaveSpeed(player: Player, multiplier: number)
	_playerSpeeds[player] = multiplier
	player:SetAttribute("WaveSpeedMultiplier", multiplier)
	local plot = getPlotForPlayer(player)
	if not plot then return end
	plot:SetAttribute("WaveSpeed", multiplier)
	for _, enemy in ipairs(activeEnemiesFolder:GetChildren()) do
		local ownerPlotValue = enemy:FindFirstChild("OwnerPlot")
		if ownerPlotValue and ownerPlotValue.Value == plot then
			local hum = enemy:FindFirstChild("Humanoid")
			if hum then
				local baseSpeed = hum:GetAttribute("BaseWalkSpeed") or 16
				hum.WalkSpeed = baseSpeed * multiplier
			end
		end
	end
	print(string.format("[WaveController] WaveSpeed x%g → %s", multiplier, player.Name))
end

function WaveController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	TurretController = controllers.TurretController
	PlacementController = controllers.PlacementController
	WeaponController = controllers.WeaponController
	PlotController = controllers.PlotController
end

function WaveController:Start()
	ReplicatedStorage.Events.SetAutoWave.OnServerEvent:Connect(function(player, isEnabled)
		_autoWaveStates[player] = isEnabled
	end)

	local changeSpeedEvent = ReplicatedStorage.Events:FindFirstChild("ChangeWaveSpeed")
	if changeSpeedEvent then
		changeSpeedEvent.OnServerEvent:Connect(function(player, multiplier)
			if multiplier ~= 1 and multiplier ~= 2 and multiplier ~= 3 then return end

			if multiplier == 3 then
				local success, hasPass = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_X3_SPEED)
				end)

				local hasWonPass = (player:GetAttribute("HasX3WavePass") == true)

				if not (success and hasPass) and not hasWonPass then return end
			end

			_playerSpeeds[player] = multiplier
			player:SetAttribute("WaveSpeedMultiplier", multiplier)

			local plot = getPlotForPlayer(player)
			if plot then
				plot:SetAttribute("WaveSpeed", multiplier)

				for _, enemy in ipairs(activeEnemiesFolder:GetChildren()) do
					local ownerPlotValue = enemy:FindFirstChild("OwnerPlot")
					if ownerPlotValue and ownerPlotValue.Value == plot then
						local hum = enemy:FindFirstChild("Humanoid")
						if hum then
							local baseSpeed = hum:GetAttribute("BaseWalkSpeed") or 16
							hum.WalkSpeed = baseSpeed * multiplier
						end
					end
				end
			end
		end)
	end

	ReplicatedStorage.Events.ToggleWaveState.OnServerEvent:Connect(function(player)
		if _fightToggleDebounce[player] then return end
		_fightToggleDebounce[player] = true

		local profile = PlayerController:GetProfile(player)

		if profile and profile.Data.OnboardingStep == "Step7_StartFight" then
			profile.Data.OnboardingStep = "Completed"
			ReplicatedStorage.Events.EndOnboarding:FireClient(player)
		end

		local plot = getPlotForPlayer(player)
		if not plot then 
			_fightToggleDebounce[player] = nil
			return 
		end
		if _plotStates[plot] and _plotStates[plot].IsActive then
			if _autoWaveStates[player] then
				_autoWaveStates[player] = false
				ReplicatedStorage.Events.AutoWaveStateChanged:FireClient(player, false)
			end
			stopFight(plot, "manual")
		else
			startFight(player)
		end
		task.delay(1, function()
			_fightToggleDebounce[player] = nil
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		_autoWaveStates[player] = nil 
		_playerSpeeds[player] = nil

		local plot = getPlotForPlayer(player)
		if not plot then return end
		local state = _plotStates[plot]
		if not state then return end
		state.IsActive = false
		if state.HealthConnection then state.HealthConnection:Disconnect() end
		for _, enemy in ipairs(activeEnemiesFolder:GetChildren()) do
			local ownerPlotValue = enemy:FindFirstChild("OwnerPlot")
			if ownerPlotValue and ownerPlotValue.Value == plot then enemy:Destroy() end
		end
		_plotStates[plot] = nil
	end)
end

return WaveController