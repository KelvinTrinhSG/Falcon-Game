--!nocheck

local LogService          = require(script.Parent.Services.LogService)
local PunishmentService   = require(script.Parent.Services.PunishmentService)
local JailService         = require(script.Parent.Services.JailService)
local PlayerStateService  = require(script.Parent.Services.PlayerStateService)
local ServerStateService  = require(script.Parent.Services.ServerStateService)
local VoteService         = require(script.Parent.Services.VoteService)

local PlayerDataManager = {}

function PlayerDataManager:GetUserIdFromInput(playerInput) return PlayerStateService:GetUserIdFromInput(playerInput) end
function PlayerDataManager:GetPlayerFromUserId(userId)     return PlayerStateService:GetPlayerFromUserId(userId) end

function PlayerDataManager:AddLog(admin, command, target, description)
	return LogService:Add(admin, command, target, description)
end
function PlayerDataManager:GiveLogs() return LogService:GetAll() end

function PlayerDataManager:LoadPunishmentData(player)        return PunishmentService:Load(player) end
function PlayerDataManager:SavePunishmentData(player, data)  return PunishmentService:Save(player, data) end
function PlayerDataManager:AddGlobalPlayerData(player, v1, v2, v3, v4, v5, v6)
	return PunishmentService:AddGlobal(player, v1, v2, v3, v4, v5, v6)
end
function PlayerDataManager:RemoveGlobalPlayerData(player)         return PunishmentService:RemoveGlobal(player) end
function PlayerDataManager:GiveGlobalPlayerData(player)           return PunishmentService:GiveGlobal(player) end
function PlayerDataManager:EditGlobalPlayerData(player, key, val) return PunishmentService:EditGlobal(player, key, val) end
function PlayerDataManager:GivePunishment(player, punishmentType, reason, duration, admin)
	return PunishmentService:Make(player, punishmentType, reason, duration, admin)
end
function PlayerDataManager:RemovePunishment(player, punishmentType) return PunishmentService:Remove(player, punishmentType) end
function PlayerDataManager:RemoveMute(player)                       return PunishmentService:Remove(player, "Mute") end
function PlayerDataManager.GetPunishmentData() return PunishmentService:GetAll() end

function PlayerDataManager:AddWarning(player, reason, admin)        return PunishmentService:AddWarning(player, reason, admin) end
function PlayerDataManager:RemoveLastWarning(player)                return PunishmentService:RemoveLastWarning(player) end
function PlayerDataManager:GetWarnings(player)                      return PunishmentService:GetWarnings(player) end

function PlayerDataManager:AddNote(player, text, admin)             return PunishmentService:AddNote(player, text, admin) end
function PlayerDataManager:RemoveNote(player, index)                return PunishmentService:RemoveNote(player, index) end
function PlayerDataManager:GetNotes(player)                         return PunishmentService:GetNotes(player) end

function PlayerDataManager:GetSavedJailData(userId)         return JailService:GetSaved(userId) end
function PlayerDataManager:SaveJailData(userId, jailData)   return JailService:Save(userId, jailData) end
function PlayerDataManager:ClearSavedJailData(userId)       return JailService:ClearSaved(userId) end
function PlayerDataManager:CheckJailExpiry(player)          return JailService:CheckExpiry(player) end

function PlayerDataManager:AddLocalPlayerData(player)               return PlayerStateService:Add(player) end
function PlayerDataManager:GiveLocalPlayerData(player)              return PlayerStateService:Give(player) end
function PlayerDataManager:RemoveLocalPlayerData(player)            return PlayerStateService:Remove(player) end
function PlayerDataManager:EditLocalPlayerData(player, key, value)  return PlayerStateService:Edit(player, key, value) end
function PlayerDataManager:SetJail(player, jailType, duration)      return PlayerStateService:SetJail(player, jailType, duration) end
function PlayerDataManager:RemoveJail(player, jailType)             return PlayerStateService:RemoveJail(player, jailType) end

function PlayerDataManager:GiveServerData() return ServerStateService:Get() end
function PlayerDataManager.GetServerData()  return ServerStateService:Get() end
function PlayerDataManager.EditServerData(key, value) return ServerStateService:Edit(key, value) end

function PlayerDataManager:AddWarp(name, x, y, z) return ServerStateService:AddWarp(name, x, y, z) end
function PlayerDataManager.RemoveWarp(name) return ServerStateService:RemoveWarp(name) end
function PlayerDataManager.GetWarp(name)    return ServerStateService:GetWarp(name) end
function PlayerDataManager.GetWarps()       return ServerStateService:GetWarps() end

function PlayerDataManager:StartVote(name, questions)                  return VoteService:Start(name, questions) end
function PlayerDataManager:GiveVoteInfo(voteID)                        return VoteService:GetInfo(voteID) end
function PlayerDataManager:RemoveVote(name)                            return VoteService:Remove(name) end
function PlayerDataManager:AddVoter(voteID, questionIndex, player)     return VoteService:AddVoter(voteID, questionIndex, player) end

return PlayerDataManager
