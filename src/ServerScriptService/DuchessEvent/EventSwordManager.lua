--!strict
-- LOCATION: ServerScriptService/DuchessEvent/EventSwordManager.lua
-- Quản lý sword tạm thời cho Duchess Event.
-- Khi player join event: stash sword cũ, cấp SovereignSplitter.
-- Khi event kết thúc: xóa SovereignSplitter, trả lại sword cũ.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local Players           = game:GetService("Players")

local EVENT_SWORD_NAME = "SovereignSplitter"
local SWORD_TEMPLATE   = ReplicatedStorage:WaitForChild("Weapons"):WaitForChild(EVENT_SWORD_NAME)

-- Tạo folder tạm trong ServerStorage để stash swords
local stashRoot = Instance.new("Folder")
stashRoot.Name   = "EventSwordStash"
stashRoot.Parent = ServerStorage

-- playerStash[player] = Folder chứa sword cũ
local playerStash: {[Player]: Folder} = {}

local EventSwordManager = {}

local function getTools(player: Player): {Tool}
	local tools: {Tool} = {}
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, v in backpack:GetChildren() do
			if v:IsA("Tool") then table.insert(tools, v) end
		end
	end
	local char = player.Character
	if char then
		for _, v in char:GetChildren() do
			if v:IsA("Tool") then table.insert(tools, v) end
		end
	end
	return tools
end

function EventSwordManager.give(player: Player)
	if playerStash[player] then return end -- đã join rồi

	-- Tạo folder stash riêng cho player
	local folder = Instance.new("Folder")
	folder.Name   = tostring(player.UserId)
	folder.Parent = stashRoot
	playerStash[player] = folder

	-- Di chuyển tất cả sword hiện tại của player vào stash
	for _, tool in getTools(player) do
		tool.Parent = folder
	end

	-- Cấp event sword
	local clone = SWORD_TEMPLATE:Clone()
	clone:SetAttribute("IsEventTemp", true)
	clone.Parent = player:FindFirstChildOfClass("Backpack") or player.Character
end

function EventSwordManager.restore(player: Player)
	-- Luôn xóa stash entry trước để tránh gọi lại 2 lần
	local folder = playerStash[player]
	playerStash[player] = nil

	local ok, err = pcall(function()
		-- Xóa event sword trong backpack và character
		local backpack = player:FindFirstChildOfClass("Backpack")
		local char     = player.Character
		for _, container in {backpack, char} do
			if not container then continue end
			for _, v in container:GetChildren() do
				if v:IsA("Tool") and v:GetAttribute("IsEventTemp") then
					v:Destroy()
				end
			end
		end

		-- Trả lại swords cũ vào backpack
		if folder then
			local dest = backpack or char
			if dest then
				for _, tool in folder:GetChildren() do
					tool.Parent = dest
				end
			end
		end
	end)

	if not ok then
		warn("[EventSwordManager] restore failed for", player.Name, "—", err)
	end

	-- Luôn dọn folder dù có lỗi
	if folder and folder.Parent then
		folder:Destroy()
	end
end

function EventSwordManager.restoreAll()
	local players: {Player} = {}
	for p in playerStash do table.insert(players, p) end
	for _, p in players do
		EventSwordManager.restore(p)
	end
end

-- Dọn dẹp khi player rời game
Players.PlayerRemoving:Connect(function(player)
	local folder = playerStash[player]
	if folder then
		folder:Destroy()
		playerStash[player] = nil
	end
end)

return EventSwordManager
