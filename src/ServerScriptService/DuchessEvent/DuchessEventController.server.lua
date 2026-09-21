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
local DuchessEndTrigger  = getOrCreateRemote("DuchessEndTrigger")
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

local VALID_TRANSITIONS: {[string]: string} = {
	[STATE.IDLE]     = STATE.STARTING,
	[STATE.STARTING] = STATE.ACTIVE,
	[STATE.ACTIVE]   = STATE.ENDING,
	[STATE.ENDING]   = STATE.IDLE,
}

local currentState: string = STATE.IDLE
local stateHandlers: {[string]: () -> ()} = {}

local EVENT_DURATION  = 240
local TEST_PLAYER_ID  = 11115679011

local hardTimerThread: thread? = nil  -- cancelled on early end
local schedulerThread: thread? = nil  -- cancelled on re-schedule

-- Forward declarations
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
-- Folder helpers
-- ============================================================

local function moveFolder(instance: Instance?, newParent: Instance?, label: string)
	if not instance then
		warn("[DuchessEvent] moveFolder: " .. label .. " not found — skipping")
		return
	end
	local ok, err = pcall(function()
		instance.Parent = newParent
	end)
	if ok then
		print("[DuchessEvent] Moved " .. label .. " → " .. (newParent and newParent:GetFullName() or "nil"))
	else
		warn("[DuchessEvent] Failed to move " .. label .. ": " .. tostring(err))
	end
end

local function getEventFolders(): (Instance?, Instance?, Instance?)
	local duchessWorkspace = Workspace:FindFirstChild("EventFolder")
		and Workspace.EventFolder:FindFirstChild("DuchessToiletEvent")
	local ssEventFolder = ServerStorage:FindFirstChild("EventFolder")
	local ssDuchess     = ssEventFolder and ssEventFolder:FindFirstChild("DuchessToiletEvent")
	return duchessWorkspace, ssDuchess, ssEventFolder
end

-- ============================================================
-- State Handlers
-- ============================================================

stateHandlers[STATE.STARTING] = function()
	local duchessWorkspace, ssDuchess = getEventFolders()

	-- Move Props out of Workspace into ServerStorage
	moveFolder(
		duchessWorkspace and duchessWorkspace:FindFirstChild("Props"),
		ssDuchess,
		"Workspace/EventFolder/DuchessToiletEvent/Props"
	)
	-- Move Path from ServerStorage into Workspace
	moveFolder(
		ssDuchess and ssDuchess:FindFirstChild("Path"),
		duchessWorkspace,
		"ServerStorage/EventFolder/DuchessToiletEvent/Path"
	)

	ShowNotification:FireAllClients("⚔️ Astro Toilet is attacking! Defend the main base now!", "Error")
	DuchessEventStart:FireAllClients(os.time(), EVENT_DURATION)

	-- Hard lock: cancel any previous, schedule new
	if hardTimerThread then task.cancel(hardTimerThread) end
	hardTimerThread = task.delay(EVENT_DURATION, forceEnd)

	transitionTo(STATE.ACTIVE)
end

stateHandlers[STATE.ACTIVE] = function()
	-- Waiting for hard timer or admin to call forceEnd()
end

stateHandlers[STATE.ENDING] = function()
	-- Cancel hard timer if admin ended early
	if hardTimerThread then
		task.cancel(hardTimerThread)
		hardTimerThread = nil
	end

	-- Notify clients first so GUI disappears immediately
	DuchessEventEnd:FireAllClients()

	-- Reverse folder moves
	local duchessWorkspace, ssDuchess = getEventFolders()

	moveFolder(
		duchessWorkspace and duchessWorkspace:FindFirstChild("Path"),
		ssDuchess,
		"Workspace/EventFolder/DuchessToiletEvent/Path"
	)
	moveFolder(
		ssDuchess and ssDuchess:FindFirstChild("Props"),
		duchessWorkspace,
		"ServerStorage/EventFolder/DuchessToiletEvent/Props"
	)

	task.delay(0.5, function()
		transitionTo(STATE.IDLE)
	end)
end

stateHandlers[STATE.IDLE] = function()
	scheduleNextEvent()
end

-- ============================================================
-- Scheduler
-- ============================================================

local function getSecondsToNextTrigger(): number
	local now          = os.time()
	local minInHr      = math.floor(now / 60) % 60
	local secInMin     = now % 60
	local minRemainder = minInHr % 30
	local minsToNext   = 30 - minRemainder
	local secsToNext   = minsToNext * 60 - secInMin
	if secsToNext <= 0 then
		secsToNext = secsToNext + 1800
	end
	return secsToNext
end

scheduleNextEvent = function()
	-- Cancel any existing scheduler before creating a new one
	if schedulerThread then
		task.cancel(schedulerThread)
		schedulerThread = nil
	end
	local delay = getSecondsToNextTrigger()
	schedulerThread = task.delay(delay, function()
		schedulerThread = nil
		triggerEvent()
	end)
end

-- ============================================================
-- Admin remotes
-- ============================================================

DuchessTestTrigger.OnServerEvent:Connect(function(player: Player)
	if player.UserId == TEST_PLAYER_ID then
		triggerEvent()
	end
end)

DuchessEndTrigger.OnServerEvent:Connect(function(player: Player)
	if player.UserId == TEST_PLAYER_ID then
		forceEnd()
	end
end)

-- ============================================================
-- Boot
-- ============================================================

scheduleNextEvent()
