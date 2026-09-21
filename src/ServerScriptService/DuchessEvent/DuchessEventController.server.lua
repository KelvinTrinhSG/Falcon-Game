--!strict
-- LOCATION: ServerScriptService/DuchessEvent/DuchessEventController.server.lua
-- Duchess / Astro Toilet Event — config only, logic lives in EventClass.

local ServerStorage = game:GetService("ServerStorage")
local Workspace     = game:GetService("Workspace")
local EventClass    = require(script.Parent.EventClass)

-- ============================================================
-- Folder helpers (Duchess-specific)
-- ============================================================

local function getEventFolders(): (Instance?, Instance?)
	local duchessWorkspace = Workspace:FindFirstChild("EventFolder")
		and Workspace.EventFolder:FindFirstChild("DuchessToiletEvent")
	local ssEventFolder = ServerStorage:FindFirstChild("EventFolder")
	local ssDuchess     = ssEventFolder and ssEventFolder:FindFirstChild("DuchessToiletEvent")
	return duchessWorkspace, ssDuchess
end

local function moveFolder(instance: Instance?, newParent: Instance?, label: string)
	if not instance then
		warn("[DuchessEvent] moveFolder: " .. label .. " not found — skipping")
		return
	end
	local ok, err = pcall(function()
		instance.Parent = newParent
	end)
	if ok then
		print("[DuchessEvent] Moved " .. label)
	else
		warn("[DuchessEvent] Failed to move " .. label .. ": " .. tostring(err))
	end
end

-- ============================================================
-- Instantiate event
-- ============================================================

EventClass.new({
	remotePrefix = "DuchessEvent",
	duration     = 240,
	scheduleMins = 30,
	notification = "⚔️ Astro Toilet is attacking! Defend the main base now!",
	notifType    = "Error",
	adminUserId  = 11115679011,

	onStart = function()
		local duchessWorkspace, ssDuchess = getEventFolders()
		-- Move Props: Workspace → ServerStorage
		moveFolder(
			duchessWorkspace and (duchessWorkspace :: any):FindFirstChild("Props"),
			ssDuchess,
			"Workspace/EventFolder/DuchessToiletEvent/Props"
		)
		-- Move Path: ServerStorage → Workspace
		moveFolder(
			ssDuchess and (ssDuchess :: any):FindFirstChild("Path"),
			duchessWorkspace,
			"ServerStorage/EventFolder/DuchessToiletEvent/Path"
		)
	end,

	onEnd = function()
		local duchessWorkspace, ssDuchess = getEventFolders()
		-- Move Path back: Workspace → ServerStorage
		moveFolder(
			duchessWorkspace and (duchessWorkspace :: any):FindFirstChild("Path"),
			ssDuchess,
			"Workspace/EventFolder/DuchessToiletEvent/Path"
		)
		-- Move Props back: ServerStorage → Workspace
		moveFolder(
			ssDuchess and (ssDuchess :: any):FindFirstChild("Props"),
			duchessWorkspace,
			"ServerStorage/EventFolder/DuchessToiletEvent/Props"
		)
	end,
})
