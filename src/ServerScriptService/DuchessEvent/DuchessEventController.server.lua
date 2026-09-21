--!strict
-- LOCATION: ServerScriptService/DuchessEvent/DuchessEventController.server.lua
-- Astro Toilet Event — FSM-based server controller
-- States: IDLE -> STARTING -> ACTIVE -> ENDING -> IDLE

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Workspace         = game:GetService("Workspace")

-- Ensure Events folder exists
local eventsFolder: Folder = ReplicatedStorage:FindFirstChild("Events") :: Folder
if not eventsFolder then
	eventsFolder = Instance.new("Folder")
	eventsFolder.Name = "Events"
	eventsFolder.Parent = ReplicatedStorage
end

local function getOrCreateRemote(name: string): RemoteEvent
	local existing = eventsFolder:FindFirstChild(name)
	if existing then return existing :: RemoteEvent end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = eventsFolder
	return remote
end

local DuchessEventStart  = getOrCreateRemote("DuchessEventStart")
local DuchessEventEnd    = getOrCreateRemote("DuchessEventEnd")
local DuchessTestTrigger = getOrCreateRemote("DuchessTestTrigger")
local ShowNotification   = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowNotification")

-- ============================================================
-- FSM
-- ============================================================

local STATE = {
	IDLE     = "IDLE",
	STARTING = "STARTING",
	ACTIVE   = "ACTIVE",
	ENDING   = "ENDING",
}

-- Only forward transitions are valid
local VALID_TRANSITIONS: {[string]: string} = {
	[STATE.IDLE]     = STATE.STARTING,
	[STATE.STARTING] = STATE.ACTIVE,
	[STATE.ACTIVE]   = STATE.ENDING,
	[STATE.ENDING]   = STATE.IDLE,
}

local currentState: string = STATE.IDLE
local stateHandlers: {[string]: () -> ()} = {}

local EVENT_DURATION = 240 -- 4 minutes, hard-coded
local TEST_PLAYER_ID = 11115679011

-- Forward declaration
local scheduleNextEvent: () -> ()
local transitionTo: (newState: string) -> ()

transitionTo = function(newState: string)
	if VALID_TRANSITIONS[currentState] ~= newState then
		warn(string.format("[DuchessEvent] Blocked invalid transition: %s -> %s", currentState, newState))
		return
	end
	currentState = newState
	local handler = stateHandlers[newState]
	if handler then
		handler()
	end
end

local function forceEnd()
	-- Called by hard timer — bypasses normal checks
	if currentState == STATE.ACTIVE or currentState == STATE.STARTING then
		transitionTo(STATE.ENDING)
	end
end

local function triggerEvent()
	if currentState ~= STATE.IDLE then
		warn("[DuchessEvent] Trigger blocked — current state: " .. currentState)
		return
	end
	transitionTo(STATE.STARTING)
end

-- ============================================================
-- State Handlers
-- ============================================================

local function moveFolder(instance: Instance?, newParent: Instance?, label: string)
	if not instance then
		warn("[DuchessEvent] moveFolder: " .. label .. " not found — skipping")
		return
	end
	instance.Parent = newParent
	print("[DuchessEvent] Moved " .. label .. " → " .. (newParent and newParent:GetFullName() or "nil"))
end

stateHandlers[STATE.STARTING] = function()
	-- 1. Move Props out of Workspace into ServerStorage
	local duchessWorkspace = Workspace:FindFirstChild("EventFolder")
		and Workspace.EventFolder:FindFirstChild("DuchessToiletEvent")
	local props = duchessWorkspace and duchessWorkspace:FindFirstChild("Props")
	local ssEventFolder = ServerStorage:FindFirstChild("EventFolder")
	local ssDuchess = ssEventFolder and ssEventFolder:FindFirstChild("DuchessToiletEvent")
	moveFolder(props, ssDuchess, "Workspace/EventFolder/DuchessToiletEvent/Props")

	-- 2. Move Path from ServerStorage into Workspace
	local pathFolder = ssEventFolder and ssEventFolder:FindFirstChild("Path")
	moveFolder(pathFolder, duchessWorkspace, "ServerStorage/EventFolder/Path")

	-- Notify all clients
	ShowNotification:FireAllClients("⚔️ Astro Toilet is attacking! Defend the main base now!", "Error")

	-- Tell clients to start countdown (pass startTime so client can calc remaining after delay)
	DuchessEventStart:FireAllClients(os.time(), EVENT_DURATION)

	-- HARD LOCK: event ends after exactly 4 minutes, no matter what
	task.delay(EVENT_DURATION, forceEnd)

	transitionTo(STATE.ACTIVE)
end

stateHandlers[STATE.ACTIVE] = function()
	-- Waiting for hard timer to fire forceEnd()
end

stateHandlers[STATE.ENDING] = function()
	DuchessEventEnd:FireAllClients()

	task.delay(0.5, function()
		transitionTo(STATE.IDLE)
	end)
end

stateHandlers[STATE.IDLE] = function()
	scheduleNextEvent()
end

-- ============================================================
-- Scheduler: fires at every :00 and :30 of the hour
-- ============================================================

local function getSecondsToNextTrigger(): number
	local now      = os.time()
	local minInHr  = math.floor(now / 60) % 60   -- 0-59
	local secInMin = now % 60                      -- 0-59
	-- minutes until the next :00 or :30 boundary
	local minRemainder = minInHr % 30
	local minsToNext   = 30 - minRemainder
	local secsToNext   = minsToNext * 60 - secInMin
	-- Guard: if we're exactly on the boundary, wait a full 30 min
	if secsToNext <= 0 then
		secsToNext = secsToNext + 1800
	end
	return secsToNext
end

scheduleNextEvent = function()
	local delay = getSecondsToNextTrigger()
	task.delay(delay, function()
		triggerEvent()
	end)
end

-- ============================================================
-- Test trigger (admin only)
-- ============================================================

DuchessTestTrigger.OnServerEvent:Connect(function(player: Player)
	if player.UserId == TEST_PLAYER_ID then
		triggerEvent()
	end
end)

-- ============================================================
-- Boot
-- ============================================================

scheduleNextEvent()
