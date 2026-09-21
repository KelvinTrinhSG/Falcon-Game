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
	if playerStash[player] then
		warn("[EventSwordManager] give: already joined —", player.Name)
		return
	end

	print("[EventSwordManager] give:", player.Name)

	-- Tạo folder stash riêng cho player
	local folder = Instance.new("Folder")
	folder.Name   = tostring(player.UserId)
	folder.Parent = stashRoot
	playerStash[player] = folder

	-- Di chuyển tất cả tool của player vào stash, đánh dấu tool đang được equip
	local stashed = 0
	local char = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")
	for _, tool in getTools(player) do
		-- Đánh dấu nếu tool đang được equip (trong Character)
		if char and tool.Parent == char then
			tool:SetAttribute("WasEquipped", true)
		end
		tool.Parent = folder
		stashed += 1
	end
	print("[EventSwordManager] stashed", stashed, "tool(s) for", player.Name)

	-- Cấp event sword
	if not SWORD_TEMPLATE then
		warn("[EventSwordManager] SovereignSplitter template not found!")
		return
	end
	local clone = SWORD_TEMPLATE:Clone()
	clone:SetAttribute("IsEventTemp", true)
	-- Parent vào Character để auto-equip ngay lập tức
	local char = player.Character
	if char then
		clone.Parent = char
		print("[EventSwordManager] SovereignSplitter equipped to", player.Name)
	else
		warn("[EventSwordManager] no Character found for", player.Name)
		clone:Destroy()
	end
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

		-- Trả lại tools cũ: tool nào WasEquipped thì equip vào Character, còn lại vào Backpack
		if folder then
			for _, tool in folder:GetChildren() do
				if tool:GetAttribute("WasEquipped") and char then
					tool:SetAttribute("WasEquipped", nil)
					tool.Parent = char  -- equip luôn
				else
					local dest = backpack or char
					if dest then tool.Parent = dest end
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
