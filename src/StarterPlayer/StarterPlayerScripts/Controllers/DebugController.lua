--!strict
-- LOCATION: StarterPlayerScripts/Controllers/DebugController.lua
-- Lệnh chat:
--   /giveme              → cấp 1M cash cho bản thân
--   /giveid <id>         → cấp 1M cash cho player theo UserId
--   /giveall             → cấp 1M cash cho tất cả player
--   /sword <Name>        → cấp sword cho bản thân
--   /swordid <id> <Name> → cấp sword cho player theo UserId
--   /swordall <Name>     → cấp sword cho tất cả player

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

		-- CASH
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

		-- SWORD
		elseif cmd == "/sword" then
			local swordName = args[2]
			if swordName then
				print(string.format("[Debug] Đang cấp sword '%s' cho bản thân...", swordName))
				DebugService:GiveSwordSelf(swordName)
			else
				warn("[Debug] Cú pháp: /sword <SwordName>")
			end

		elseif cmd == "/swordid" then
			local userId = tonumber(args[2])
			local swordName = args[3]
			if userId and swordName then
				print(string.format("[Debug] Đang cấp sword '%s' cho UserId: %d", swordName, userId))
				DebugService:GiveSwordById(userId, swordName)
			else
				warn("[Debug] Cú pháp: /swordid <UserId> <SwordName>")
			end

		elseif cmd == "/swordall" then
			local swordName = args[2]
			if swordName then
				print(string.format("[Debug] Đang cấp sword '%s' cho tất cả player...", swordName))
				DebugService:GiveSwordAll(swordName)
			else
				warn("[Debug] Cú pháp: /swordall <SwordName>")
			end
		end
	end)
end

function DebugController:KnitInit() end

return DebugController
