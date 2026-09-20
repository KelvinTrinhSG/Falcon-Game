--!strict
-- LOCATION: ServerScriptService/VIPTagHandler
-- Creates an Admin name tag above the head of whitelisted admin players.

local Players = game:GetService("Players")

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
	if not head then return end
	if head:FindFirstChild("AdminTag") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "AdminTag"
	billboard.Size = UDim2.new(0, 120, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "🔱 Admin"
	label.TextColor3 = Color3.fromRGB(255, 50, 50)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = billboard
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
