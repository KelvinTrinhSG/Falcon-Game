--!strict
-- LOCATION: ServerScriptService/Services/DebugService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)

local REWARD = 1_000_000

local DebugService = Knit.CreateService({
	Name = "DebugService",
	Client = {},
})

local function giveCash(player: Player, amount: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")
	if not cash then
		warn(string.format("[DebugService] leaderstats.Cash not found for %s", player.Name))
		return
	end
	cash.Value += amount
	print(string.format("[DebugService] +%d cash → %s (total: %d)", amount, player.Name, cash.Value))
end

-- Cấp tiền cho người gọi lệnh
function DebugService.Client:GiveSelf(player: Player)
	giveCash(player, REWARD)
end

-- Cấp tiền cho người chơi theo UserId
function DebugService.Client:GiveById(player: Player, userId: number)
	local target = Players:GetPlayerByUserId(userId)
	if target then
		giveCash(target, REWARD)
	else
		warn(string.format("[DebugService] Không tìm thấy player với UserId: %d", userId))
	end
end

-- Cấp tiền cho toàn bộ người chơi
function DebugService.Client:GiveAll(_player: Player)
	for _, p in Players:GetPlayers() do
		giveCash(p, REWARD)
	end
end

function DebugService:KnitStart() end

return DebugService
