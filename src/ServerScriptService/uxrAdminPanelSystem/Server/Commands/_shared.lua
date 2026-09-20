--!nocheck

local Players              = game:GetService("Players")
local ServerStorage        = game:GetService("ServerStorage")
local ReplicatedStorage    = game:GetService("ReplicatedStorage")
local WorkspaceService     = game:GetService("Workspace")
local TeleportService      = game:GetService("TeleportService")
local MarketplaceService   = game:GetService("MarketplaceService")

local function waitFor(parent, name)
	local inst = parent:WaitForChild(name, 10)
	if not inst then
		warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name)
	end
	return inst
end

local uxrRS = waitFor(ReplicatedStorage, "uxrAdminPanelSystem")
local uxrSS = waitFor(ServerStorage, "uxrAdminPanelSystem")
local uxrWS = waitFor(WorkspaceService, "uxrAdminPanelSystem")
local apEvents = waitFor(waitFor(uxrRS, "Core"), "apEvents")
local Tools = uxrSS:FindFirstChild("Tools")
local Builds = uxrSS:FindFirstChild("Builds")
local WorkspaceBuilds = waitFor(uxrWS, "Builds")

local function liveFolder(name)
    local pkg = ServerStorage:FindFirstChild("uxrAdminPanelSystem")
    return pkg and pkg:FindFirstChild(name) or nil
end

local function giveTool(target, toolName)
    if not target or not target.Backpack then return false, "no Backpack" end
    local folder = liveFolder("Tools")
    if not folder then return false, "ServerStorage/uxrAdminPanelSystem/Tools missing" end
    local tool = folder:FindFirstChild(toolName)
    if not tool then return false, ("'%s' not in Storage/Tools"):format(toolName) end
    if not tool:IsA("Tool") then return false, ("'%s' is %s, not a Tool"):format(toolName, tool.ClassName) end
    tool:Clone().Parent = target.Backpack
    return true
end

local Permissions        = require(uxrRS.Config.Permissions)
local Settings           = require(uxrRS.Config.Settings)
local UtilModule         = require(uxrRS.Lib.Util)
local PlayerDataManager  = require(script.Parent.Parent.PlayerDataManager)


local function GetPlayer(text)
	local TargetPlayer = nil
	if text == Settings.Localization.Self then return "me" end
	if text == Settings.Localization.All then return "all" end
	if text == Settings.Localization.Other then return "other" end
	for i,v in pairs(game.Players:GetPlayers()) do
		if string.find(v.Name:lower(), text:lower()) then
			if TargetPlayer then
				return false
			end
			TargetPlayer = v
		end
	end
	if TargetPlayer then
		return TargetPlayer
	end
	if not TargetPlayer then
		return nil
	end
end

local function GetPlayerOrUserId(playerNameOrId)
	local player = GetPlayer(playerNameOrId)
	if player then
		return player
	end

	if tonumber(playerNameOrId) then
		return tonumber(playerNameOrId)
	end

	local success, userId
	success, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(playerNameOrId)
	end)

	if success and userId then
		return userId
	end

	return nil
end

local function waitForCharacter(player, timeout)
	timeout = timeout or 5
	if player.Character then return player.Character end

	local connection
	local character = nil
	connection = player.CharacterAdded:Connect(function(char)
		character = char
	end)

	local startTime = tick()
	while not character and (tick() - startTime) < timeout do
		task.wait(0.1)
	end

	if connection then connection:Disconnect() end
	return character
end

local function asPlayer(t)
	if typeof(t) == "Instance" and t:IsA("Player") then return t end
	if type(t) ~= "string" then return nil end
	return GetPlayer(t)
end

local function withCharacter(target, fn)
	local p = asPlayer(target); if not p then return end
	local char = p.Character
	if not char then
		local conn
		local got
		conn = p.CharacterAdded:Connect(function(c) got = c end)
		local t0 = os.clock()
		while not got and os.clock() - t0 < 5 do task.wait() end
		if conn then conn:Disconnect() end
		char = got
	end
	if char then fn(char) end
end

local function withHumanoid(target, fn)
	withCharacter(target, function(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then fn(hum, char) end
	end)
end

local function forEachBasePart(target, fn)
	withCharacter(target, function(char)
		for _, d in ipairs(char:GetDescendants()) do
			if d:IsA("BasePart") then fn(d) end
		end
	end)
end

local function ensureEffect(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then return existing end
	if existing then existing:Destroy() end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	return inst
end

local function removeEffect(parent, name)
	local e = parent:FindFirstChild(name)
	if e then e:Destroy() end
end

return {
	Players              = Players,
	ServerStorage        = ServerStorage,
	ReplicatedStorage    = ReplicatedStorage,
	WorkspaceService     = WorkspaceService,
	TeleportService      = TeleportService,
	MarketplaceService   = MarketplaceService,

	uxrRS                = uxrRS,
	uxrSS                = uxrSS,
	uxrWS                = uxrWS,
	apEvents             = apEvents,
	Tools                = Tools,
	Builds               = Builds,
	WorkspaceBuilds      = WorkspaceBuilds,
	liveFolder           = liveFolder,
	giveTool             = giveTool,

	Permissions          = Permissions,
	Settings             = Settings,
	UtilModule           = UtilModule,
	PlayerDataManager    = PlayerDataManager,

	GetPlayer            = GetPlayer,
	GetPlayerOrUserId    = GetPlayerOrUserId,
	waitForCharacter     = waitForCharacter,

	withCharacter        = withCharacter,
	withHumanoid         = withHumanoid,
	forEachBasePart      = forEachBasePart,
	ensureEffect         = ensureEffect,
	removeEffect         = removeEffect,
}
