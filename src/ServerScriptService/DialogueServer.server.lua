local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Remotes
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local createDialogueEvent = Instance.new("RemoteEvent")
createDialogueEvent.Name = "createDialogueEvent"
createDialogueEvent.Parent = Remotes

local hideDialogueEvent = Instance.new("RemoteEvent")
hideDialogueEvent.Name = "hideDialogueEvent"
hideDialogueEvent.Parent = Remotes

local setDialogueImageEvent = Instance.new("RemoteEvent")
setDialogueImageEvent.Name = "setDialogueImageEvent"
setDialogueImageEvent.Parent = Remotes

local getTVManCooldown = Instance.new("RemoteFunction")
getTVManCooldown.Name = "getTVManCooldown"
getTVManCooldown.Parent = Remotes

local secretAgentCashFX = Instance.new("RemoteEvent")
secretAgentCashFX.Name = "SecretAgentCashFX"
secretAgentCashFX.Parent = Remotes

-- Constants
local RunService = game:GetService("RunService")
local TEST_USER_ID = 11115679011
local COOLDOWN = RunService:IsStudio() and 10 or 600
local DIALOGUE_DURATION = 6
local NPC_DISPLAY_NAME = "Titan TV Man"
local NPC_WORKSPACE_NAME = "UpgradedTitanTVMan"
local NPC_COLOR = Color3.fromRGB(100, 200, 255)

-- Reward tables
local CASH_REWARDS = {
	low  = { min = 200,   max = 400   },
	mid  = { min = 5000,  max = 8000  },
	high = { min = 40000, max = 60000 },
}

local TURRET_REWARDS = {
	low  = { "CameraGuy", "TvGuy", "EngineerCameraGuy" },
	mid  = { "LaserCameramanCar", "LargeTvGuy", "LargeScientistCameraman" },
	high = { "TitanCameraGuy", "TitanTVMan" },
}

local BLOCK_REWARDS = {
	low  = { "RockBlock", "ConcreteBlock", "IceBlock" },
	mid  = { "LavaBlock", "ToxicBlock", "GoldBlock" },
	high = { "PlasmaBlock", "GoldBlock" },
}

local WEAPON_REWARDS = {
	low  = { "StoneSword", "ClassicSword" },
	mid  = { "BlueSword", "IceSword" },
	high = { "EasterSword", "GemSword" },
}

local DISPLAY_NAMES = {
	CameraGuy               = "Camera Guy",
	TvGuy                   = "TV Guy",
	EngineerCameraGuy       = "Engineer Camera Guy",
	LaserCameramanCar       = "Laser Cameraman Car",
	LargeTvGuy              = "Large TV Guy",
	LargeScientistCameraman = "Large Scientist Cameraman",
	TitanCameraGuy          = "Titan Camera Guy",
	TitanTVMan              = "Titan TV Man",
	RockBlock               = "Rock Block",
	ConcreteBlock           = "Concrete Block",
	IceBlock                = "Ice Block",
	LavaBlock               = "Lava Block",
	ToxicBlock              = "Toxic Block",
	GoldBlock               = "Gold Block",
	PlasmaBlock             = "Plasma Block",
	StoneSword              = "Upgraded Plunger",
	ClassicSword            = "Spike Plunger",
	BlueSword               = "Blue Sword",
	IceSword                = "Red Sword",
	EasterSword             = "Red Cross Sword",
	GemSword                = "Eviscerator Axe",
}

local COOLDOWN_LINES = {
	"Hold on, brother! I'm preparing your support package. Please wait {time} more.",
	"I'm working on it, comrade! Your supply drop will be ready in {time}. Stay strong!",
	"Easy there! I'm gathering resources for you. Come back in {time}, I'll have it ready.",
	"Support is being loaded, soldier! Return in {time} and I'll hook you up.",
	"Not just yet, friend. I need {time} more to get your package ready. Don't go too far!",
}

local READY_LINES = {
	"Support is ready, brother! I've got {item} for you. Go make them pay!",
	"Your supply drop has arrived! Here's {item} — use it well, comrade!",
	"Finally ready! Take this {item} and show those enemies what we're made of!",
}

-- Helpers
local function formatTime(seconds)
	local m = math.floor(seconds / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d", m, s)
end

local function formatCash(amount)
	local s = tostring(math.floor(amount))
	local result = ""
	local count = 0
	for i = #s, 1, -1 do
		count += 1
		result = string.sub(s, i, i) .. result
		if count % 3 == 0 and i > 1 then
			result = "," .. result
		end
	end
	return result
end

local function getTier(wave)
	if wave < 20 then return "low"
	elseif wave < 40 then return "mid"
	else return "high" end
end

local function pickRandom(t)
	return t[math.random(1, #t)]
end

local function getProfile(player)
	local PlayerController = require(ServerScriptService.Controllers.PlayerController)
	return PlayerController:GetProfile(player)
end

local function getCooldownRemaining(player)
	local profile = getProfile(player)
	if not profile then return 0 end
	local last = profile.Data.TitanTVManLastSupport or 0
	return math.max(0, COOLDOWN - (os.time() - last))
end

local function openDialogue(player, text)
	setDialogueImageEvent:FireClient(player, NPC_DISPLAY_NAME, NPC_COLOR, NPC_WORKSPACE_NAME)
	createDialogueEvent:FireClient(player, text)
	task.delay(DIALOGUE_DURATION, function()
		if player and player.Parent then
			hideDialogueEvent:FireClient(player)
		end
	end)
end

local function giveReward(player, wave)
	local profile = getProfile(player)
	if not profile then return nil end

	local tier = getTier(wave)
	local roll = math.random(1, 100)
	local itemName

	if roll <= 50 then
		local range = CASH_REWARDS[tier]
		local amount = math.random(range.min, range.max)
		local leaderstats = player:FindFirstChild("leaderstats")
		local cash = leaderstats and leaderstats:FindFirstChild("Cash")
		if cash then cash.Value += amount end
		itemName = formatCash(amount) .. " Cash"

	elseif roll <= 75 then
		local blockId = pickRandom(BLOCK_REWARDS[tier])
		profile.Data.BlockInventory[blockId] = (profile.Data.BlockInventory[blockId] or 0) + 1
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, profile.Data.BlockInventory)
		itemName = DISPLAY_NAMES[blockId]

	elseif roll <= 90 then
		local turretId = pickRandom(TURRET_REWARDS[tier])
		profile.Data.BlockInventory[turretId] = (profile.Data.BlockInventory[turretId] or 0) + 1
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, profile.Data.BlockInventory)
		itemName = DISPLAY_NAMES[turretId]

	else
		local weaponId = pickRandom(WEAPON_REWARDS[tier])
		if not table.find(profile.Data.WeaponInventory, weaponId) then
			table.insert(profile.Data.WeaponInventory, weaponId)
		end
		ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(player, profile.Data.WeaponInventory)
		itemName = DISPLAY_NAMES[weaponId]
	end

	profile.Data.TitanTVManLastSupport = os.time()

	local line = pickRandom(READY_LINES)
	return string.gsub(line, "{item}", itemName)
end

-- RemoteFunction: client hỏi còn bao nhiêu giây
getTVManCooldown.OnServerInvoke = function(player)
	return getCooldownRemaining(player)
end

-- Touch
local touchPart = workspace:WaitForChild("UpgradedTitanModels", math.huge)
	:WaitForChild("TouchParts", math.huge)
	:WaitForChild(NPC_WORKSPACE_NAME, math.huge)

local debounce = {}

touchPart.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	if RunService:IsStudio() and player.UserId ~= TEST_USER_ID then return end
	if debounce[player] then return end
	debounce[player] = true

	local remaining = getCooldownRemaining(player)

	if remaining > 0 then
		print(string.format("[TVMan] %s — cooldown, %.0fs remaining", player.Name, remaining))
		local line = pickRandom(COOLDOWN_LINES)
		line = string.gsub(line, "{time}", formatTime(remaining))
		openDialogue(player, line)
	else
		local profile = getProfile(player)
		local wave = profile and (profile.Data.HighestWave or 0) or 0
		print(string.format("[TVMan] %s — ready, HighestWave=%d, tier=%s", player.Name, wave, getTier(wave)))
		local rewardLine = giveReward(player, wave)
		if rewardLine then
			print(string.format("[TVMan] %s — rewarded: %s", player.Name, rewardLine))
			openDialogue(player, rewardLine)
		else
			warn(string.format("[TVMan] %s — giveReward returned nil (profile missing?)", player.Name))
		end
	end

	task.delay(DIALOGUE_DURATION + 1, function()
		debounce[player] = nil
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	debounce[player] = nil
end)

