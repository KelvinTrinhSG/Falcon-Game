--!strict
-- LOCATION: ServerScriptService/DuchessEvent/EventClass.lua
-- Generic server-side Event OOP class.
-- Each instance is fully independent: own FSM, own timers, own remotes.
--
-- Usage:
--   local EventClass = require(script.Parent.EventClass)
--   local myEvent = EventClass.new({
--       remotePrefix = "MyEvent",
--       duration     = 240,
--       scheduleMins = 30,
--       notification = "Something is happening!",
--       notifType    = "Error",
--       adminUserId  = 12345,
--       onStart      = function() ... end,
--       onEnd        = function() ... end,
--   })

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Shared Events folder (created once, reused by all instances)
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

-- ============================================================
-- FSM constants
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

-- ============================================================
-- EventClass
-- ============================================================

local EventClass = {}
EventClass.__index = EventClass

export type EventConfig = {
	remotePrefix  : string,
	duration      : number,
	scheduleMins  : number,
	notification  : string,
	notifType     : string?,
	adminUserId   : number,
	onStart       : (() -> ())?,
	onEnd         : (() -> ())?,
}

function EventClass.new(config: EventConfig)
	local self = setmetatable({}, EventClass)

	self._config          = config
	self._state           = STATE.IDLE
	self._hardTimerThread = nil :: thread?
	self._schedulerThread = nil :: thread?
	self._showNotif       = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowNotification") :: RemoteEvent

	-- Each event owns its 4 remotes, namespaced by remotePrefix
	local p = config.remotePrefix
	self._remotes = {
		Start       = getOrCreateRemote(p .. "Start"),
		End         = getOrCreateRemote(p .. "End"),
		TestTrigger = getOrCreateRemote(p .. "TestTrigger"),
		EndTrigger  = getOrCreateRemote(p .. "EndTrigger"),
	}

	-- Wire admin remotes
	self._remotes.TestTrigger.OnServerEvent:Connect(function(player: Player)
		if player.UserId == config.adminUserId then
			self:trigger()
		end
	end)
	self._remotes.EndTrigger.OnServerEvent:Connect(function(player: Player)
		if player.UserId == config.adminUserId then
			self:_forceEnd()
		end
	end)

	self:_scheduleNext()
	return self
end

-- ============================================================
-- FSM internals
-- ============================================================

function EventClass:_transitionTo(newState: string)
	if VALID_TRANSITIONS[self._state] ~= newState then
		warn(string.format("[%s] Blocked invalid transition: %s -> %s",
			self._config.remotePrefix, self._state, newState))
		return
	end
	self._state = newState

	if newState == STATE.STARTING then self:_onStarting()
	elseif newState == STATE.ACTIVE   then self:_onActive()
	elseif newState == STATE.ENDING   then self:_onEnding()
	elseif newState == STATE.IDLE     then self:_onIdle()
	end
end

function EventClass:_forceEnd()
	if self._state == STATE.ACTIVE or self._state == STATE.STARTING then
		self:_transitionTo(STATE.ENDING)
	end
end

-- ============================================================
-- State handlers
-- ============================================================

function EventClass:_onStarting()
	local cfg = self._config

	-- Run custom start logic (folder moves, spawns, etc.)
	if cfg.onStart then
		local ok, err = pcall(cfg.onStart)
		if not ok then
			warn(string.format("[%s] onStart error: %s", cfg.remotePrefix, tostring(err)))
		end
	end

	-- Broadcast to all clients
	self._showNotif:FireAllClients(cfg.notification, cfg.notifType or "Error")
	self._remotes.Start:FireAllClients(os.time(), cfg.duration)

	-- Hard lock: event MUST end after duration
	if self._hardTimerThread then task.cancel(self._hardTimerThread) end
	self._hardTimerThread = task.delay(cfg.duration, function()
		self:_forceEnd()
	end)

	self:_transitionTo(STATE.ACTIVE)
end

function EventClass:_onActive()
	-- Waiting for hard timer or admin EndTrigger
end

function EventClass:_onEnding()
	-- Cancel hard timer if admin ended early
	if self._hardTimerThread then
		task.cancel(self._hardTimerThread)
		self._hardTimerThread = nil
	end

	-- Notify clients immediately so GUI disappears
	self._remotes.End:FireAllClients()

	-- Run custom end logic
	local cfg = self._config
	if cfg.onEnd then
		local ok, err = pcall(cfg.onEnd)
		if not ok then
			warn(string.format("[%s] onEnd error: %s", cfg.remotePrefix, tostring(err)))
		end
	end

	task.delay(0.5, function()
		self:_transitionTo(STATE.IDLE)
	end)
end

function EventClass:_onIdle()
	self:_scheduleNext()
end

-- ============================================================
-- Scheduler
-- ============================================================

function EventClass:_getSecondsToNextTrigger(): number
	local mins     = self._config.scheduleMins
	local now      = os.time()
	local minInHr  = math.floor(now / 60) % 60
	local secInMin = now % 60
	local secsToNext = (mins - (minInHr % mins)) * 60 - secInMin
	if secsToNext <= 0 then
		secsToNext = secsToNext + mins * 60
	end
	return secsToNext
end

function EventClass:_scheduleNext()
	if self._schedulerThread then
		task.cancel(self._schedulerThread)
		self._schedulerThread = nil
	end
	local delay = self:_getSecondsToNextTrigger()
	self._schedulerThread = task.delay(delay, function()
		self._schedulerThread = nil
		self:trigger()
	end)
end

-- ============================================================
-- Public API
-- ============================================================

function EventClass:trigger()
	if self._state ~= STATE.IDLE then
		warn(string.format("[%s] Trigger blocked — state: %s",
			self._config.remotePrefix, self._state))
		return
	end
	self:_transitionTo(STATE.STARTING)
end

function EventClass:getState(): string
	return self._state
end

return EventClass
