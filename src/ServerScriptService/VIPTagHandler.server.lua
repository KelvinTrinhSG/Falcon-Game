--!strict
-- LOCATION: ServerScriptService/VIPTagHandler
-- Attaches an AdminTag BillboardGui to the head of whitelisted admin players.

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

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

local function giveAdminTag(character: Model)
	local head = character:WaitForChild("Head", 5)
	local template = ServerStorage:FindFirstChild("AdminTag")
	if not head or not template then return end
	if head:FindFirstChild("AdminTag") then return end
	local cloned = template:Clone()
	cloned.Parent = head
end

Players.PlayerAdded:Connect(function(player)
	if not isAdmin(player.UserId) then return end
	player.CharacterAdded:Connect(function(character)
		giveAdminTag(character)
	end)
	if player.Character then
		giveAdminTag(player.Character)
	end
end)