--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RankManager = require(ReplicatedStorage.Modules.RankManager)

local function clearTrail(torso: BasePart)
	for _, obj in ipairs(torso:GetChildren()) do
		if (obj:IsA("Trail") and obj.Name == "RankTrail")
			or obj.Name == "TrailTop"
			or obj.Name == "TrailBottom"
		then
			obj:Destroy()
		end
	end
end

local function applyTrail(player: Player, character: Model)
	local torso = character:WaitForChild("UpperTorso", 5) :: BasePart?
	if not torso then
		warn("[TrailHandler] UpperTorso not found for", player.Name)
		return
	end

	local xToiletHP = player:GetAttribute("xToiletHP") or 1
	local config = RankManager.getTrailConfig(xToiletHP)

clearTrail(torso)
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

local function setupPlayer(player: Player)
	player.CharacterAdded:Connect(function(character)
		-- Chờ xToiletHP được set từ PlayerController (tránh race condition)
		if not player:GetAttribute("xToiletHP") then
			player:GetAttributeChangedSignal("xToiletHP"):Wait()
		end
		applyTrail(player, character)
	end)

	if player.Character then
		applyTrail(player, player.Character)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end
