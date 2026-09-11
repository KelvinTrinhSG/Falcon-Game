--!strict
-- LOCATION: ServerScriptService/AdminDataLogger.server.lua
-- Chỉ phục vụ admin (UserId 11115679011)

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ADMIN_ID = 11115679011

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local eventsFolder = ReplicatedStorage:WaitForChild("Events")

local adminGetData = Instance.new("RemoteFunction")
adminGetData.Name = "AdminGetData"
adminGetData.Parent = eventsFolder

local function dumpTable(t: {[any]: any}, indent: string): string
	indent = indent or "  "
	local lines = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			table.insert(lines, indent .. tostring(k) .. ":")
			table.insert(lines, dumpTable(v, indent .. "  "))
		else
			table.insert(lines, indent .. tostring(k) .. " = " .. tostring(v))
		end
	end
	return table.concat(lines, "\n")
end

adminGetData.OnServerInvoke = function(player: Player)
	if player.UserId ~= ADMIN_ID then return nil end

	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn("[AdminDataLogger] Không tìm thấy profile của", player.Name)
		return nil
	end

	print("\n========== ADMIN DATA DUMP ==========")
	print("Player : " .. player.Name .. " | UserId : " .. tostring(player.UserId))
	print(dumpTable(profile.Data, "  "))
	print("=====================================\n")

	return profile.Data
end
