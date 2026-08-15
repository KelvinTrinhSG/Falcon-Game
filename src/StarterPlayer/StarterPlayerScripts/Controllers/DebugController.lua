--!strict
-- LOCATION: StarterPlayerScripts/Controllers/DebugController.lua
-- Lệnh chat:
--   /giveme        → cấp 1M cho bản thân
--   /giveid <id>   → cấp 1M cho player theo UserId
--   /giveall       → cấp 1M cho tất cả player

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.knit)

local DebugController = Knit.CreateController({ Name = "DebugController" })

local DebugService

function DebugController:KnitStart()
	DebugService = Knit.GetService("DebugService")

	Players.LocalPlayer.Chatted:Connect(function(message: string)
		local args = message:split(" ")
		local cmd = string.lower(args[1])

		if cmd == "/giveme" then
			print("[Debug] Đang cấp 1M cho bản thân...")
			DebugService:GiveSelf()

		elseif cmd == "/giveid" then
			local userId = tonumber(args[2])
			if userId then
				print(string.format("[Debug] Đang cấp 1M cho UserId: %d", userId))
				DebugService:GiveById(userId)
			else
				warn("[Debug] Cú pháp: /giveid <UserId>")
			end

		elseif cmd == "/giveall" then
			print("[Debug] Đang cấp 1M cho toàn bộ người chơi...")
			DebugService:GiveAll()
		end
	end)
end

function DebugController:KnitInit() end

return DebugController
