--!strict
-- LOCATION: ServerScriptService/VIPTagHandler
-- Clones the VIPTag BillboardGui from ServerStorage and attaches it to whitelisted admin players.

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
	local template = ServerStorage:FindFirstChild("VIPTag")
	if not head or not template then return end
	if head:FindFirstChild("VIPTag") then return end

	local cloned = template:Clone()

	-- Override the label text with the Admin icon
	local label = cloned:FindFirstChildWhichIsA("TextLabel")
	if label then
		label.Text = "🔱 Admin"
	end

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
