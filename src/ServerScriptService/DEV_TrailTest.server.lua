--!strict
-- DEV ONLY: chỉ chạy trong Roblox Studio
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RankManager = require(ReplicatedStorage.Modules.RankManager)

local TARGET_ID = 11115679011

local function applyTrail(player: Player, xToiletHP: number)
	local character = player.Character
	if not character then return end

	local torso = character:FindFirstChild("UpperTorso") :: BasePart?
	if not torso then return end

	-- Xoá trail cũ (chỉ xoá đúng những gì mình tạo ra)
	for _, obj in ipairs(torso:GetChildren()) do
		if (obj:IsA("Trail") and obj.Name == "RankTrail")
			or obj.Name == "TrailTop"
			or obj.Name == "TrailBottom"
		then
			obj:Destroy()
		end
	end

	local config = RankManager.getTrailConfig(xToiletHP)

	print(string.format("[TrailTest] xToiletHP=%d | Rank=%s | Trail=%s",
		xToiletHP,
		RankManager.getRank(xToiletHP),
		if config then "YES" else "NO (Rookie)"
	))

	if not config then return end

	local color = RankManager.getRankColor(xToiletHP)
	local half = config.height / 2

	local att0 = Instance.new("Attachment")
	att0.Name = "TrailTop"
	att0.Position = Vector3.new(0, half, 0)
	att0.Parent = torso

	local att1 = Instance.new("Attachment")
	att1.Name = "TrailBottom"
	att1.Position = Vector3.new(0, -half, 0)
	att1.Parent = torso

	local trail = Instance.new("Trail")
	trail.Name = "RankTrail"
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Lifetime = config.lifetime
	trail.LightEmission = config.emission
	trail.LightInfluence = 0.5
	trail.MinLength = 0.05
	trail.FaceCamera = true
	trail.Parent = torso
end

local function getTarget(): Player?
	for _, player in ipairs(Players:GetPlayers()) do
		if player.UserId == TARGET_ID then
			return player
		end
	end
	return nil
end

task.spawn(function()
	-- Chờ player vào
	local player: Player
	repeat
		task.wait(1)
		player = getTarget()
	until player ~= nil

	print("[TrailTest] Found target:", player.Name)

	local fakeXToiletHP = 1
	while true do
		applyTrail(player, fakeXToiletHP)
		fakeXToiletHP += 1
		task.wait(5)
	end
end)
