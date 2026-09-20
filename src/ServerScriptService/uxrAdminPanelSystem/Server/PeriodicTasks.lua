--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function waitFor(parent, name)
	local inst = parent:WaitForChild(name, 10)
	if not inst then
		warn("[uxrAPS] missing instance: "..parent:GetFullName().."/"..name)
	end
	return inst
end

local uxrWS = waitFor(Workspace, "uxrAdminPanelSystem")
local uxrRS = waitFor(ReplicatedStorage, "uxrAdminPanelSystem")
local WorkspaceBuilds = waitFor(uxrWS, "Builds")

local LocationService = require(script.Parent.Services.LocationService)
local PlayerDataManager = require(script.Parent.PlayerDataManager)
local CrossServer = require(script.Parent.CrossServer)

local PeriodicTasks = {}

function PeriodicTasks.init()
	task.spawn(function()
		while game.PrivateServerId == "" do
			local loc = LocationService.GetServerLocation({"country", "regionName"})
			CrossServer.publish("uxr.serverList.v2", {
				ServerId = game.JobId,
				Location = loc and loc[1] or nil,
				Players  = #Players:GetPlayers(),
			})
			task.wait(15)
		end
	end)

	task.spawn(function()
		local serversFolder = uxrRS.Core:WaitForChild("Servers", 10)
		if not serversFolder then return end
		while true do
			task.wait(20)
			local now = os.time()
			for _, child in ipairs(serversFolder:GetChildren()) do
				local last = child:GetAttribute("LastSeen")
				if last and (now - last) > 45 then
					child:Destroy()
				end
			end
		end
	end)

	task.spawn(function()
		while true do
			task.wait(5)
			for _, player in pairs(Players:GetPlayers()) do
				local before = PlayerDataManager:GiveLocalPlayerData(player)
				local wasGlobal = before and before.GlobalPlayerJailed
				if PlayerDataManager:CheckJailExpiry(player) then
					local playerData = PlayerDataManager:GiveLocalPlayerData(player)
					if playerData then
						if not playerData.LocalPlayerJailed and WorkspaceBuilds:FindFirstChild(player.Name.."JailCell") then
							WorkspaceBuilds:FindFirstChild(player.Name.."JailCell"):Destroy()
						end
						if wasGlobal and not playerData.GlobalPlayerJailed then
							player:LoadCharacter()
						end
					end
				end
			end
		end
	end)
end

return PeriodicTasks
