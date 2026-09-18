local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

-- Config
local IS_STUDIO   = RunService:IsStudio()
local DURATION    = IS_STUDIO and 60 or 300  -- 60 giây khi test, 5 phút production
local SPAWN_COUNT = 2

-- Paths
local placeHolders   = workspace:WaitForChild("EventPlaces", math.huge)
	:WaitForChild("SecretAgentEvent", math.huge)
	:WaitForChild("PlaceHolders", math.huge)

local agentModelSrc  = ReplicatedStorage:WaitForChild("Models", math.huge)
	:WaitForChild("SecretAgentModel", math.huge)

-- Remotes
local eventRemote = Instance.new("RemoteEvent")
eventRemote.Name  = "SecretAgentEventNotify"
eventRemote.Parent = ReplicatedStorage:WaitForChild("Events")

-- State
local isEventActive      = false
local eventStartedAt     = 0
local spawnedAgents      = {}   -- { model }
local collectedThisEvent = {}   -- { [player] = true }
local touchDebounce      = {}   -- { [player] = true }

-- Helpers
local function getProfile(player)
	return PlayerController:GetProfile(player)
end

local function shuffleAndPick(parts, count)
	local pool = table.clone(parts)
	for i = #pool, 2, -1 do
		local j = math.random(1, i)
		pool[i], pool[j] = pool[j], pool[i]
	end
	local result = {}
	for i = 1, math.min(count, #pool) do
		table.insert(result, pool[i])
	end
	return result
end

local function setupTouch(model)
	local placementBox = model:WaitForChild("PlacementBox", 5)
	if not placementBox then
		warn("[SecretAgentEvent] No PlacementBox in model", model:GetFullName())
		return
	end

	placementBox.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end
		if touchDebounce[player] then return end
		if collectedThisEvent[player] then return end
		if not isEventActive then return end
		if not model.Parent then return end

		touchDebounce[player] = true

		-- Xóa model ngay
		local idx = table.find(spawnedAgents, model)
		if idx then table.remove(spawnedAgents, idx) end
		model:Destroy()

		-- Cấp reward
		collectedThisEvent[player] = true
		local profile = getProfile(player)
		if profile then
			profile.Data.BlockInventory["SecretAgent"] = (profile.Data.BlockInventory["SecretAgent"] or 0) + 1
			ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, profile.Data.BlockInventory)
			print(string.format("[SecretAgentEvent] %s collected SecretAgent (now has %d)", player.Name, profile.Data.BlockInventory["SecretAgent"]))
		else
			warn("[SecretAgentEvent] No profile for", player.Name)
		end

		eventRemote:FireClient(player, "collect")

		-- Kết thúc event ngay nếu tất cả agent đã bị collect
		if #spawnedAgents == 0 then
			print("[SecretAgentEvent] All agents collected — ending event early")
			endEvent()
		end
	end)
end

local function startEvent()
	if isEventActive then return end
	isEventActive = true
	eventStartedAt = os.time()
	collectedThisEvent = {}
	touchDebounce = {}
	spawnedAgents = {}

	local holderParts = placeHolders:GetChildren()
	local picked = shuffleAndPick(holderParts, SPAWN_COUNT)

	for _, holder in ipairs(picked) do
		local model = agentModelSrc:Clone()
		model:PivotTo(holder.CFrame)
		model.Parent = workspace
		table.insert(spawnedAgents, model)
		print(string.format("[SecretAgentEvent] Spawned '%s' at %s | parent = %s", model.Name, tostring(holder.CFrame.Position), model.Parent.Name))
		setupTouch(model)
	end

	print(string.format("[SecretAgentEvent] Event started — spawned %d agents", #spawnedAgents))
	eventRemote:FireAllClients("start", eventStartedAt, DURATION)
end

local function endEvent()
	if not isEventActive then return end
	isEventActive = false

	for _, model in ipairs(spawnedAgents) do
		if model.Parent then model:Destroy() end
	end
	spawnedAgents = {}
	collectedThisEvent = {}
	touchDebounce = {}

	print("[SecretAgentEvent] Event ended")
	eventRemote:FireAllClients("end")
end

-- Cleanup khi player rời game
Players.PlayerRemoving:Connect(function(player)
	collectedThisEvent[player] = nil
	touchDebounce[player] = nil
end)

-- Scheduler
local lastSecond = -1

RunService.Heartbeat:Connect(function()
	local now = os.time()
	if now == lastSecond then return end
	lastSecond = now

	if IS_STUDIO then
		-- Studio: start mỗi 70 giây, end sau DURATION giây
		local pos = now % 70
		if pos == 0 then
			startEvent()
			eventStartedAt = now
		elseif isEventActive and (now - eventStartedAt) >= DURATION then
			endEvent()
		end
	else
		-- Production: start đúng đầu mỗi giờ UTC (:00:00), end sau DURATION giây
		local t = os.date("!*t", now)
		if t.min == 0 and t.sec == 0 then
			startEvent()
			eventStartedAt = now
		elseif isEventActive and (now - eventStartedAt) >= DURATION then
			endEvent()
		end
	end
end)

print(string.format("[SecretAgentEvent] Loaded | DURATION=%ds | Studio=%s", DURATION, tostring(IS_STUDIO)))
