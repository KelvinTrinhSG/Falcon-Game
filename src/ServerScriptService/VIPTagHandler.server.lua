--!strict
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RankManager = require(ReplicatedStorage.Modules.RankManager)

local ADMIN_IDS: { number } = {
	11515319361,
	11481072785,
	11115679011,
}

local function isAdmin(userId: number): boolean
	for _, id in ipairs(ADMIN_IDS) do
		if id == userId then return true end
	end
	return false
end

local function updateRankLabel(player: Player, rankLabel: any)
	local xToiletHP = player:GetAttribute("xToiletHP") or 1
	local highestWave = math.clamp(player:GetAttribute("HighestWave") or 1, 1, 60)
	rankLabel.Text = RankManager.getRank(xToiletHP) .. " " .. highestWave
	rankLabel.TextColor3 = RankManager.getRankColor(xToiletHP)
end

local function applyTag(player: Player, character: Model)
	local head = character:WaitForChild("Head", 5)
	local template = ServerStorage:FindFirstChild("VIPTag")
	if not head or not template then return end
	if head:FindFirstChild("VIPTag") then return end

	local cloned = template:Clone()

	local rankLabel = cloned:FindFirstChild("Rank")
	local nameLabel = cloned:FindFirstChildWhichIsA("TextLabel")

	if rankLabel then
		updateRankLabel(player, rankLabel)

		local conn = player:GetAttributeChangedSignal("HighestWave"):Connect(function()
			if rankLabel.Parent then
				updateRankLabel(player, rankLabel)
			end
		end)

		character.AncestryChanged:Connect(function()
			if not character.Parent then
				conn:Disconnect()
			end
		end)
	end

	if nameLabel then
		nameLabel.Text = if isAdmin(player.UserId) then "🔱 Admin" else player.Name
	end

	cloned.Parent = head
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		applyTag(player, character)
	end)
	if player.Character then
		applyTag(player, player.Character)
	end
end)
