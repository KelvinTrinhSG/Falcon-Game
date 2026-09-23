--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RankManager = require(ReplicatedStorage.Modules.RankManager)

local function applyTrail(player: Player, character: Model)
	local torso = character:WaitForChild("UpperTorso", 5) :: BasePart?
	if not torso then return end

	local xToiletHP = player:GetAttribute("xToiletHP") or 1
	local config = RankManager.getTrailConfig(xToiletHP)
	if not config then return end -- Rookie: no trail

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

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		applyTrail(player, character)
	end)
	if player.Character then
		applyTrail(player, player.Character)
	end
end)
