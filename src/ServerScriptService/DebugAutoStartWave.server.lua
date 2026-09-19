--!strict
-- Debug only: tự động set StartingWave cho Aplayer3210 sau 5s join
-- Chỉ hoạt động trong Roblox Studio, không lưu vĩnh viễn vào data

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local TARGET_USER_ID = 11115679011
local START_WAVE     = 10  -- ← chỉnh con số này để thay đổi wave bắt đầu
local DELAY_SECONDS  = 5

local PlayerController = require(ServerScriptService.Controllers.PlayerController)
local WaveController   = require(ServerScriptService.Controllers.WaveController)

local function applyOverride(player: Player)
	if player.UserId ~= TARGET_USER_ID then return end

	task.wait(DELAY_SECONDS)

	-- Chờ profile load xong
	local profile = PlayerController:GetProfile(player)
	local waited = 0
	while not profile and waited < 30 do
		task.wait(0.5)
		waited += 0.5
		profile = PlayerController:GetProfile(player)
	end

	if not profile then
		warn("[DebugAutoStartWave] Không lấy được profile sau 30s")
		return
	end

	local original = profile.Data.StartingWave
	profile.Data.StartingWave = START_WAVE
	print(string.format("[DebugAutoStartWave] StartingWave tạm thời = %d cho %s", START_WAVE, player.Name))

	-- Khôi phục ngay khi fight bắt đầu để không lưu vĩnh viễn
	task.spawn(function()
		local timeout = 120
		local elapsed = 0
		while elapsed < timeout do
			task.wait(0.5)
			elapsed += 0.5
			if WaveController:IsPlayerFighting(player) then
				profile.Data.StartingWave = original
				print(string.format("[DebugAutoStartWave] Đã khôi phục StartingWave = %d cho %s", original, player.Name))
				return
			end
		end
		profile.Data.StartingWave = original
		warn("[DebugAutoStartWave] Timeout – đã khôi phục StartingWave gốc mà không thấy fight bắt đầu")
	end)
end

Players.PlayerAdded:Connect(applyOverride)
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(applyOverride, p)
end
