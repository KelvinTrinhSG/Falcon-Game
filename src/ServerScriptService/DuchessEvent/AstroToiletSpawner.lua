--!strict
-- LOCATION: ServerScriptService/DuchessEvent/AstroToiletSpawner.lua
-- Spawns AstroToilet models every 5s during the Duchess event
-- and moves each one through the waypoints 1 → 2 → … → End.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local PhysicsService    = game:GetService("PhysicsService")
local Players           = game:GetService("Players")

-- ============================================================
-- Collision groups: AstroToilets ↔ Players = no collision
-- Both groups still collide with Default (floor/environment)
-- ============================================================

local ASTRO_GROUP   = "AstroToilets"
local PLAYERS_GROUP = "Players"

pcall(function() PhysicsService:RegisterCollisionGroup(ASTRO_GROUP) end)
pcall(function() PhysicsService:RegisterCollisionGroup(PLAYERS_GROUP) end)
PhysicsService:CollisionGroupSetCollidable(ASTRO_GROUP, PLAYERS_GROUP, false)

local function setCollisionGroup(model: Model, groupName: string)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = groupName
		end
	end
end

local function onCharacterAdded(character: Model)
	-- Wait a frame so all parts exist before assigning
	task.defer(function()
		setCollisionGroup(character, PLAYERS_GROUP)
	end)
end

-- Apply to all current and future players
for _, player in Players:GetPlayers() do
	if player.Character then onCharacterAdded(player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)

local SPAWN_INTERVAL     = 5    -- seconds between spawns
local WAYPOINT_THRESHOLD = 4    -- studs — "close enough" to advance to next waypoint
local WAYPOINT_TIMEOUT   = 30   -- seconds before force-advancing to next waypoint
local MOVE_TICK          = 0.1  -- how often to re-issue MoveTo (prevents Roblox 8s timeout)

-- AstroToilet models source
local astroToiletsFolder = ReplicatedStorage
	:WaitForChild("EventFolder")
	:WaitForChild("DuchessToiletEvent")
	:WaitForChild("AstroToilets")

-- ============================================================
-- Waypoint helpers
-- ============================================================

local function getWaypointsFolder(): Folder?
	local eventFolder = Workspace:FindFirstChild("EventFolder")
	local duchess     = eventFolder and eventFolder:FindFirstChild("DuchessToiletEvent")
	local path        = duchess and duchess:FindFirstChild("Path")
	return path and path:FindFirstChild("Waypoints") :: Folder?
end

local function getOrderedWaypoints(folder: Folder): {BasePart}
	local waypoints: {BasePart} = {}
	local i = 1
	while true do
		local wp = folder:FindFirstChild(tostring(i))
		if not wp or not wp:IsA("BasePart") then break end
		table.insert(waypoints, wp)
		i += 1
	end
	local endWp = folder:FindFirstChild("End")
	if endWp and endWp:IsA("BasePart") then
		table.insert(waypoints, endWp)
	end
	return waypoints
end

-- ============================================================
-- Per-AstroToilet movement (runs in its own coroutine)
-- ============================================================

local function moveAlongWaypoints(model: Model, waypoints: {BasePart})
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local rootPart = model:FindFirstChild("HumanoidRootPart") :: BasePart?

	if not humanoid or not rootPart then
		warn("[AstroToiletSpawner] Model missing Humanoid or HumanoidRootPart — destroying")
		model:Destroy()
		return
	end

	for _, waypoint in ipairs(waypoints) do
		if humanoid.Health <= 0 or not model.Parent then break end

		local elapsed = 0
		-- Keep re-issuing MoveTo to avoid Roblox's 8s auto-timeout
		while elapsed < WAYPOINT_TIMEOUT do
			if humanoid.Health <= 0 or not model.Parent then break end

			humanoid:MoveTo(waypoint.Position)

			task.wait(MOVE_TICK)
			elapsed += MOVE_TICK

			local dist = (rootPart.Position - waypoint.Position).Magnitude
			if dist <= WAYPOINT_THRESHOLD then break end
		end

		if humanoid.Health <= 0 or not model.Parent then break end
	end

	-- Reached End (or died/removed)
	if model.Parent then
		model:Destroy()
	end
end

-- ============================================================
-- Spawner state
-- ============================================================

local isActive          = false
local spawnLoopThread: thread? = nil
local activeModels: {Model} = {}  -- track all live clones for cleanup
local spawnIndex        = 0

local function spawnOne()
	local waypointsFolder = getWaypointsFolder()
	if not waypointsFolder then
		warn("[AstroToiletSpawner] Waypoints folder not found in Workspace — skipping spawn")
		return
	end

	local waypoints = getOrderedWaypoints(waypointsFolder)
	if #waypoints == 0 then
		warn("[AstroToiletSpawner] No waypoints found — skipping spawn")
		return
	end

	local models = astroToiletsFolder:GetChildren()
	if #models == 0 then
		warn("[AstroToiletSpawner] No AstroToilet models in ReplicatedStorage — skipping spawn")
		return
	end

	-- Cycle through the 4 models in order
	spawnIndex = (spawnIndex % #models) + 1
	local template = models[spawnIndex]
	if not template:IsA("Model") then return end

	local clone = template:Clone()

	-- Position clone at first waypoint
	local firstWp = waypoints[1]
	if clone.PrimaryPart then
		clone:SetPrimaryPartCFrame(CFrame.new(firstWp.Position))
	elseif clone:FindFirstChild("HumanoidRootPart") then
		(clone:FindFirstChild("HumanoidRootPart") :: BasePart).CFrame = CFrame.new(firstWp.Position)
	end

	-- Parent into Workspace under DuchessToiletEvent folder
	local duchess = Workspace:FindFirstChild("EventFolder")
		and Workspace.EventFolder:FindFirstChild("DuchessToiletEvent")
	clone.Parent = duchess or Workspace

	-- No collision with players
	setCollisionGroup(clone, ASTRO_GROUP)

	table.insert(activeModels, clone)

	-- Clean from list when destroyed
	clone.AncestryChanged:Connect(function()
		if not clone.Parent then
			for i, m in ipairs(activeModels) do
				if m == clone then
					table.remove(activeModels, i)
					break
				end
			end
		end
	end)

	-- Move in its own coroutine
	task.spawn(moveAlongWaypoints, clone, waypoints)
end

-- ============================================================
-- Public API
-- ============================================================

local Spawner = {}

function Spawner.start()
	if isActive then return end
	isActive    = true
	spawnIndex  = 0
	activeModels = {}

	spawnLoopThread = task.spawn(function()
		while isActive do
			spawnOne()
			task.wait(SPAWN_INTERVAL)
		end
	end)
end

function Spawner.stop()
	isActive = false

	if spawnLoopThread then
		task.cancel(spawnLoopThread)
		spawnLoopThread = nil
	end

	-- Destroy all live AstroToilets
	for _, model in ipairs(activeModels) do
		if model and model.Parent then
			model:Destroy()
		end
	end
	activeModels = {}
	spawnIndex   = 0
end

return Spawner
