--!strict
-- DEV ONLY: chỉ chạy trong Roblox Studio
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local TARGET_ID = 11115679011

local function resetToiletHP(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn("[DEV_ResetToiletHP] Profile not found for", player.Name)
		return
	end

	profile.Data.xToiletHP = 1
	player:SetAttribute("xToiletHP", 1)
	print("[DEV_ResetToiletHP] Reset xToiletHP -> 1 for", player.Name)
end

Players.PlayerAdded:Connect(function(player)
	if player.UserId ~= TARGET_ID then return end
	task.wait(3) -- chờ profile load xong
	resetToiletHP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.UserId == TARGET_ID then
		task.wait(3)
		resetToiletHP(player)
	end
end
