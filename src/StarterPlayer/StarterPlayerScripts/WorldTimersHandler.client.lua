--!strict
-- This single script manages all in-world shop restock timers.

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Configuration mapping shop names to their objects and events
local blockShopResetTime = ReplicatedStorage.Functions:WaitForChild("GetBlockShopResetTime")
local updateBlockStocks = ReplicatedStorage.Events:WaitForChild("UpdateBlockStocks")

local shopConfigs = {
	BlocksShop = {
		TimerLabel = Workspace:WaitForChild("BlocksShop"):WaitForChild("RestockGUI"):WaitForChild("TimerLabel"),
		GetTimeFunc = blockShopResetTime,
		UpdateEvent = updateBlockStocks,
	},
	TurretsShop = {
		TimerLabel = Workspace:WaitForChild("TurretsShop"):WaitForChild("RestockGUI"):WaitForChild("TimerLabel"),
		GetTimeFunc = blockShopResetTime,
		UpdateEvent = updateBlockStocks,
	},
	WeaponsShop = {
		TimerLabel = Workspace:WaitForChild("WeaponsShop"):WaitForChild("RestockGUI"):WaitForChild("TimerLabel"),
		GetTimeFunc = ReplicatedStorage.Functions:WaitForChild("GetWeaponShopResetTime"),
		UpdateEvent = ReplicatedStorage.Events:WaitForChild("UpdateWeaponStocks"),
	}
}

-- A table to keep track of the active timer connections for each shop
local activeTimers: {[string]: RBXScriptConnection} = {}

-- Helper function to format seconds into a MM:SS string
local function formatRemaining(seconds: number): string
	if seconds <= 0 then return "00:00" end
	local min = math.floor(seconds / 60)
	local sec = seconds % 60
	return string.format("%02d:%02d", min, sec)
end

-- This is the core function that starts or restarts a timer for a specific shop
local function startTimer(shopName: string, label: TextLabel, getTimeFunc: RemoteFunction, newTimestamp: number?)
	-- Disconnect any existing timer for this shop to prevent multiple loops
	if activeTimers[shopName] then
		activeTimers[shopName]:Disconnect()
	end

	local function setupConnection(timestamp: number)
		-- Create a new Heartbeat connection to update the timer every frame
		activeTimers[shopName] = RunService.Heartbeat:Connect(function()
			local remaining = timestamp - os.time()
			label.Text = formatRemaining(remaining)
		end)
	end

	if newTimestamp then
		-- If a new time was provided by a restock event, use it directly
		setupConnection(newTimestamp)
	else
		-- Otherwise, this is an initial setup, so ask the server for the current time
		local success, serverTime = pcall(getTimeFunc.InvokeServer, getTimeFunc)
		if success and typeof(serverTime) == "number" then
			setupConnection(serverTime)
		else
			warn(`[WorldTimersHandler] Failed to get initial restock time for {shopName}.`)
			label.Text = "--:--"
		end
	end
end

-- Loop through all configured shops to set them up
for name, config in pairs(shopConfigs) do
	-- Start the initial timer for each shop when the player joins
	startTimer(name, config.TimerLabel, config.GetTimeFunc)

	-- Listen for the specific restock event for each shop
	config.UpdateEvent.OnClientEvent:Connect(function(stockData, newRestockTime)
		-- When a restock happens, restart the timer with the new time from the server
		startTimer(name, config.TimerLabel, config.GetTimeFunc, newRestockTime)
	end)
end