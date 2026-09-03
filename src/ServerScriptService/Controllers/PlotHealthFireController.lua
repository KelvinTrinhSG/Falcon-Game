--!strict
-- LOCATION: ServerScriptService/Controllers/PlotHealthFireController.lua
-- Watches Core1.Health on each Plot and updates Fire effects in Workspace/Map/Fires/<PlotName>/.
-- Server-side so all players see the correct state.

local Workspace = game:GetService("Workspace")

local PlotHealthFireController = {}

local PLOTS_FOLDER = Workspace:WaitForChild("Plots")
local FIRES_FOLDER = Workspace:WaitForChild("Map"):WaitForChild("Fires")
local FIRE_PARTS_COUNT = 5
local MAX_FIRE_SIZE = 50

local function getFireFolder(plot: Model): Folder?
	return FIRES_FOLDER:FindFirstChild(plot.Name) :: Folder?
end

local function collectFireParts(fireFolder: Folder): { BasePart }
	local parts: { BasePart } = {}
	for i = 1, FIRE_PARTS_COUNT do
		local part = fireFolder:FindFirstChild(tostring(i))
		if part and part:IsA("BasePart") then
			table.insert(parts, part :: BasePart)
		end
	end
	return parts
end

local function shuffleParts(parts: { BasePart }): { BasePart }
	local copy = table.clone(parts)
	for i = #copy, 2, -1 do
		local j = math.random(1, i)
		copy[i], copy[j] = copy[j], copy[i]
	end
	return copy
end

local function resetFires(fireFolder: Folder)
	for i = 1, FIRE_PARTS_COUNT do
		local part = fireFolder:FindFirstChild(tostring(i))
		if not part then continue end
		local fire = part:FindFirstChildOfClass("Fire")
		if fire then
			fire.Enabled = false
			fire.Size = 0
		end
	end
end

type WatchState = {
	fireParts: { BasePart },
	lastFiresVisible: number,
	currentShuffled: { BasePart },
	healthConn: RBXScriptConnection?,
	maxHealthConn: RBXScriptConnection?,
}

local function applyFires(state: WatchState, health: number, maxHealth: number)
	local damageFraction = 1 - math.clamp(health / maxHealth, 0, 1)
	local firesVisible = math.round(damageFraction * #state.fireParts)
	local fireSize = damageFraction * MAX_FIRE_SIZE

	if firesVisible ~= state.lastFiresVisible then
		state.lastFiresVisible = firesVisible
		state.currentShuffled = shuffleParts(state.fireParts)
	end

	for i, part in ipairs(state.currentShuffled) do
		local fire = part:FindFirstChildOfClass("Fire")
		if not fire then continue end
		if i <= firesVisible then
			fire.Enabled = true
			fire.Size = fireSize
		else
			fire.Enabled = false
			fire.Size = 0
		end
	end
end

local function connectCore1(core1: Instance, state: WatchState)
	if state.healthConn then state.healthConn:Disconnect() end
	if state.maxHealthConn then state.maxHealthConn:Disconnect() end

	local function onChanged()
		local health = core1:GetAttribute("Health")
		local maxHealth = core1:GetAttribute("MaxHealth")
		if not health or not maxHealth or maxHealth <= 0 then return end
		applyFires(state, health, maxHealth)
	end

	state.healthConn = core1:GetAttributeChangedSignal("Health"):Connect(onChanged)
	state.maxHealthConn = core1:GetAttributeChangedSignal("MaxHealth"):Connect(onChanged)
	onChanged()
end

local function startWatching(plot: Model, fireFolder: Folder): () -> ()
	local state: WatchState = {
		fireParts = collectFireParts(fireFolder),
		lastFiresVisible = -1,
		currentShuffled = {},
		healthConn = nil,
		maxHealthConn = nil,
	}

	local existing = plot:FindFirstChild("Core1")
	if existing then
		connectCore1(existing, state)
	end

	local childAddedConn = plot.ChildAdded:Connect(function(child)
		if child.Name == "Core1" then
			connectCore1(child, state)
		end
	end)

	return function()
		if state.healthConn then state.healthConn:Disconnect() end
		if state.maxHealthConn then state.maxHealthConn:Disconnect() end
		childAddedConn:Disconnect()
	end
end

local function setupPlot(plot: Model)
	if not plot:IsA("Model") then return end

	local fireFolder = getFireFolder(plot)
	if not fireFolder then return end

	resetFires(fireFolder)

	local stopWatching: (() -> ())?

	plot:GetAttributeChangedSignal("OwnerId"):Connect(function()
		local ownerId = plot:GetAttribute("OwnerId")

		if ownerId then
			stopWatching = startWatching(plot, fireFolder)
		else
			if stopWatching then
				stopWatching()
				stopWatching = nil
			end
			resetFires(fireFolder)
		end
	end)

	if plot:GetAttribute("OwnerId") then
		stopWatching = startWatching(plot, fireFolder)
	end
end

function PlotHealthFireController:Init(_controllers: { [string]: any }) end

function PlotHealthFireController:Start()
	for _, plot in ipairs(PLOTS_FOLDER:GetChildren()) do
		setupPlot(plot)
	end

	PLOTS_FOLDER.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			setupPlot(child)
		end
	end)
end

return PlotHealthFireController
