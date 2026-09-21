--!strict
-- LOCATION: ServerScriptService/DuchessEvent/DuchessEventController.server.lua
-- Duchess / Astro Toilet Event — config only, logic lives in EventClass.

local ServerStorage     = game:GetService("ServerStorage")
local Workspace         = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local EventClass        = require(script.Parent.EventClass)
local Spawner           = require(script.Parent.AstroToiletSpawner)

-- ============================================================
-- TitanTVMan teleport
-- ============================================================

local TITAN_TVMAN_DEFAULT = CFrame.new(12.165, 13.304, -114.671) * CFrame.Angles(0, 0, 0)
local TITAN_TVMAN_EVENT   = CFrame.new(12.165, 13.304, -111.828) * CFrame.Angles(0, math.rad(180), 0)

local function pivotTitanTVMan(cf: CFrame)
	local upgradedModels = Workspace:FindFirstChild("UpgradedTitanModels")
	local model = upgradedModels and (upgradedModels :: any):FindFirstChild("UpgradedTitanTVMan") :: Model?
	if not model then
		warn("[DuchessEvent] UpgradedTitanTVMan not found")
		return
	end
	model:PivotTo(cf)
end

-- ============================================================
-- Helpers
-- ============================================================

local function getEventFolders(): (Instance?, Instance?)
	local duchessWorkspace = Workspace:FindFirstChild("EventFolder")
		and Workspace.EventFolder:FindFirstChild("DuchessToiletEvent")
	local ssEventFolder = ServerStorage:FindFirstChild("EventFolder")
	local ssDuchess     = ssEventFolder and ssEventFolder:FindFirstChild("DuchessToiletEvent")
	return duchessWorkspace, ssDuchess
end

local function cloneInto(source: Instance?, parent: Instance?, label: string)
	if not source then
		warn("[DuchessEvent] clone: " .. label .. " not found — skipping")
		return
	end
	if parent and (parent :: any):FindFirstChild(source.Name) then
		warn("[DuchessEvent] clone: " .. source.Name .. " already exists in destination — skipping")
		return
	end
	source:Clone().Parent = parent
	print("[DuchessEvent] Cloned " .. label)
end

local function destroyIn(parent: Instance?, name: string, label: string)
	local target = parent and (parent :: any):FindFirstChild(name)
	if not target then
		warn("[DuchessEvent] destroy: " .. label .. " not found — skipping")
		return
	end
	target:Destroy()
	print("[DuchessEvent] Destroyed " .. label)
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
		local ws, ss = getEventFolders()

		-- Destroy Props in Workspace
		destroyIn(ws, "Props",       "Workspace/.../Props")
		-- Clone Path from ServerStorage into Workspace
		cloneInto((ss :: any):FindFirstChild("Path"),       ws, "SS/.../Path → Workspace")
		-- Clone TVManShield from ServerStorage into Workspace
		cloneInto((ss :: any):FindFirstChild("TVManShield"), ws, "SS/.../TVManShield → Workspace")
		-- Set HP via Attribute (same pattern as blocks)
		local shield = ws and (ws :: any):FindFirstChild("TVManShield")
		if shield then
			shield:SetAttribute("Health", 100)
			CollectionService:AddTag(shield, "Damageable")
		else
			warn("[DuchessEvent] TVManShield not found after clone")
		end

		-- Teleport TitanTVMan to event position
		pivotTitanTVMan(TITAN_TVMAN_EVENT)

		-- Start spawning AstroToilets (Path must be in Workspace first)
		Spawner.start()
	end,

	onEnd = function()
		-- Stop spawner and destroy all live AstroToilets first
		Spawner.stop()

		local ws, ss = getEventFolders()

		-- Destroy Path in Workspace
		destroyIn(ws, "Path",        "Workspace/.../Path")
		-- Destroy TVManShield in Workspace
		destroyIn(ws, "TVManShield", "Workspace/.../TVManShield")
		-- Clone Props from ServerStorage back into Workspace
		cloneInto((ss :: any):FindFirstChild("Props"),      ws, "SS/.../Props → Workspace")

		-- Teleport TitanTVMan back to default position
		pivotTitanTVMan(TITAN_TVMAN_DEFAULT)
	end,
})
