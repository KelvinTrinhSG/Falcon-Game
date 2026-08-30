--!strict
-- LOCATION: StarterPlayerScripts/Controllers/DebugController.lua
-- Lệnh chat:
--   /giveme              → cấp 1M cash cho bản thân
--   /giveid <id>         → cấp 1M cash cho player theo UserId
--   /giveall             → cấp 1M cash cho tất cả player
--   /sword <Name>        → cấp sword cho bản thân
--   /swordid <id> <Name> → cấp sword cho player theo UserId
--   /swordall <Name>     → cấp sword cho tất cả player
--   /wavespeed <number>  → đặt tốc độ wave (vd: /wavespeed 2)
--   /startwave <number>  → chuyển đến wave mong muốn (lưu data)
--   /blockme             → cấp toàn bộ block cho bản thân (10 mỗi loại)
--   /blockid <id>        → cấp toàn bộ block cho player theo UserId (10 mỗi loại)
--   /blockall            → cấp toàn bộ block cho tất cả player (10 mỗi loại)
--   /turretme            → cấp toàn bộ turret cho bản thân
--   /turretid <id>       → cấp toàn bộ turret cho player theo UserId
--   /turretall           → cấp toàn bộ turret cho tất cả player
--   /baseme              → cấp toàn bộ base cho bản thân
--   /baseid <id>         → cấp toàn bộ base cho player theo UserId
--   /baseall             → cấp toàn bộ base cho tất cả player
--   /equipbase <CoreX>   → trang bị base cho bản thân (vd: /equipbase Core3)
--   /weaponme            → cấp toàn bộ weapon cho bản thân
--   /weaponid <id>       → cấp toàn bộ weapon cho player theo UserId
--   /weaponall           → cấp toàn bộ weapon cho tất cả player

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

		-- STARTING WAVE
		elseif cmd == "/startwave" then
			local waveNumber = tonumber(args[2])
			if waveNumber and waveNumber >= 1 then
				print(string.format("[Debug] Đặt StartingWave → %d...", waveNumber))
				DebugService:SetStartingWave(waveNumber)
			else
				warn("[Debug] Cú pháp: /startwave <number>  (vd: /startwave 10)")
			end

		-- BLOCK
		elseif cmd == "/blockme" then
			print("[Debug] Đang cấp toàn bộ block cho bản thân...")
			DebugService:GiveBlockSelf()

		elseif cmd == "/blockid" then
			local userId = tonumber(args[2])
			if userId then
				print(string.format("[Debug] Đang cấp toàn bộ block cho UserId: %d", userId))
				DebugService:GiveBlockById(userId)
			else
				warn("[Debug] Cú pháp: /blockid <UserId>")
			end

		elseif cmd == "/blockall" then
			print("[Debug] Đang cấp toàn bộ block cho tất cả người chơi...")
			DebugService:GiveBlockAll()

		-- TURRET
		elseif cmd == "/turretme" then
			print("[Debug] Đang cấp toàn bộ turret cho bản thân...")
			DebugService:GiveTurretSelf()

		elseif cmd == "/turretid" then
			local userId = tonumber(args[2])
			if userId then
				print(string.format("[Debug] Đang cấp toàn bộ turret cho UserId: %d", userId))
				DebugService:GiveTurretById(userId)
			else
				warn("[Debug] Cú pháp: /turretid <UserId>")
			end

		elseif cmd == "/turretall" then
			print("[Debug] Đang cấp toàn bộ turret cho tất cả người chơi...")
			DebugService:GiveTurretAll()

		-- BASE
		elseif cmd == "/baseme" then
			print("[Debug] Đang cấp toàn bộ base cho bản thân...")
			DebugService:GiveBaseSelf()

		elseif cmd == "/baseid" then
			local userId = tonumber(args[2])
			if userId then
				print(string.format("[Debug] Đang cấp toàn bộ base cho UserId: %d", userId))
				DebugService:GiveBaseById(userId)
			else
				warn("[Debug] Cú pháp: /baseid <UserId>")
			end

		elseif cmd == "/baseall" then
			print("[Debug] Đang cấp toàn bộ base cho tất cả người chơi...")
			DebugService:GiveBaseAll()

		elseif cmd == "/equipbase" then
			local baseId = args[2]
			if baseId then
				print(string.format("[Debug] Trang bị base '%s' cho bản thân...", baseId))
				DebugService:EquipBase(baseId)
			else
				warn("[Debug] Cú pháp: /equipbase <CoreX>  (vd: /equipbase Core3)")
			end

		-- WAVE SPEED
		elseif cmd == "/wavespeed" then
			local multiplier = tonumber(args[2])
			if multiplier then
				print(string.format("[Debug] Đặt wave speed x%g...", multiplier))
				DebugService:SetWaveSpeed(multiplier)
			else
				warn("[Debug] Cú pháp: /wavespeed <number>  (vd: /wavespeed 2)")
			end

		-- ALL WEAPONS
		elseif cmd == "/weaponme" then
			print("[Debug] Đang cấp toàn bộ weapon cho bản thân...")
			DebugService:GiveAllWeaponsSelf()

		elseif cmd == "/weaponid" then
			local userId = tonumber(args[2])
			if userId then
				print(string.format("[Debug] Đang cấp toàn bộ weapon cho UserId: %d", userId))
				DebugService:GiveAllWeaponsById(userId)
			else
				warn("[Debug] Cú pháp: /weaponid <UserId>")
			end

		elseif cmd == "/weaponall" then
			print("[Debug] Đang cấp toàn bộ weapon cho tất cả người chơi...")
			DebugService:GiveAllWeaponsAll()
		end
	end)
end

function DebugController:KnitInit() end

return DebugController
