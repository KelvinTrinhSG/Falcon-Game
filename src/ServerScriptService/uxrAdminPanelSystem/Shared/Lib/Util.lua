local UtilModule = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players            = game:GetService("Players")
local DataStoreService   = game:GetService("DataStoreService")
local RunService         = game:GetService("RunService")

local shared = script.Parent.Parent

local Permissions = require(shared.Config.Permissions)
local Settings    = require(shared.Config.Settings)

local RuntimeRanks = {}
local PermRankStore = (RunService:IsServer()) and DataStoreService:GetDataStore("uxrAPS_PermRanks_v1") or nil

local rankByName  = {}
local nonAdminRank
for _, rank in ipairs(Permissions.Ranks) do
	rankByName[rank.Name] = rank
	if rank.Name == "NonAdmin" then nonAdminRank = rank end
end
nonAdminRank = nonAdminRank or Permissions.Ranks[#Permissions.Ranks]

function UtilModule.GetRankByName(name)
	return rankByName[name]
end

function UtilModule.GetAllRanks()
	return Permissions.Ranks
end


function UtilModule:SetRuntimeRank(userId, rankName)
	if rankName == nil or rankName == "" then
		RuntimeRanks[userId] = nil
	elseif rankByName[rankName] then
		RuntimeRanks[userId] = rankName
	end
end

function UtilModule:SetPermRank(userId, rankName)
	self:SetRuntimeRank(userId, rankName)
	if not PermRankStore then return end
	pcall(function()
		if rankName == nil or rankName == "" then
			PermRankStore:RemoveAsync(tostring(userId))
		else
			PermRankStore:SetAsync(tostring(userId), rankName)
		end
	end)
end

function UtilModule:LoadPermRank(userId)
	if not PermRankStore then return end
	local ok, rankName = pcall(PermRankStore.GetAsync, PermRankStore, tostring(userId))
	if ok and type(rankName) == "string" and rankByName[rankName] then
		RuntimeRanks[userId] = rankName
	end
end

local function playerMatchesAssignment(player, assignment)
	if not assignment then return false end

	for _, uid in ipairs(assignment.Players or {}) do
		if uid == player.UserId then return true end
	end

	for _, passId in ipairs(assignment.Gamepasses or {}) do
		local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync,
			MarketplaceService, player.UserId, passId)
		if ok and owns then return true end
	end

	for _, assetId in ipairs(assignment.Assets or {}) do
		local ok, owns = pcall(MarketplaceService.PlayerOwnsAsset,
			MarketplaceService, player, assetId)
		if ok and owns then return true end
	end

	for _, pair in ipairs(assignment.Groups or {}) do
		local groupId, requiredRankInGroup = pair[1], pair[2]
		if groupId then
			local ok, rankInGroup = pcall(player.GetRankInGroup, player, groupId)
			if ok and rankInGroup == requiredRankInGroup then return true end
		end
	end

	if player.Team then
		for _, teamName in ipairs(assignment.Teams or {}) do
			if player.Team.Name == teamName then return true end
		end
	end

	return false
end

function UtilModule:GetRank(player)
	if not player then return nonAdminRank end

	if Permissions.AutoRankOwner and player.UserId == game.CreatorId then
		local owner = rankByName["Owner"]
		if owner then return owner end
	end

	local override = RuntimeRanks[player.UserId]
	if override and rankByName[override] then
		return rankByName[override]
	end

	local matches = {}

	for _, rank in ipairs(Permissions.Ranks) do
		local assignment = Permissions.Assignments and Permissions.Assignments[rank.Name]
		if assignment and playerMatchesAssignment(player, assignment) then
			table.insert(matches, rank)
		end
	end

	if Permissions.VipServerOwnerRank and game.PrivateServerOwnerId == player.UserId then
		local r = rankByName[Permissions.VipServerOwnerRank]
		if r then table.insert(matches, r) end
	end
	if Permissions.FriendsRank then
		local ok, isFriend = pcall(player.IsFriendsWith, player, game.CreatorId)
		if ok and isFriend then
			local r = rankByName[Permissions.FriendsRank]
			if r then table.insert(matches, r) end
		end
	end
	if Permissions.FreeAdminRank then
		local r = rankByName[Permissions.FreeAdminRank]
		if r then table.insert(matches, r) end
	end

	if #matches == 0 then return nonAdminRank end

	local best = matches[1]
	for i = 2, #matches do
		if matches[i].Level > best.Level then best = matches[i] end
	end
	return best
end

function UtilModule:HasRank(player, requiredRankName)
	local mine = self:GetRank(player)
	local needed = rankByName[requiredRankName]
	if not needed then return false end
	return mine.Level >= needed.Level
end

function UtilModule:Allows(player, perm)
	if perm == nil then
		return self:HasRank(player, "Mod")
	end
	if type(perm) == "string" then
		return self:HasRank(player, perm)
	end
	if type(perm) == "table" then
		for _, name in ipairs(perm) do
			if type(name) == "string" and self:HasRank(player, name) then return true end
		end
		return false
	end
	return false
end

function UtilModule:CanRunCommand(player, cmd)
	if not cmd then return false end
	return self:Allows(player, cmd.Permission or cmd.CommandPermission)
end

function UtilModule:CanActOn(target, action)
	local rank
	if typeof(target) == "Instance" and target:IsA("Player") then
		rank = self:GetRank(target)
	elseif type(target) == "number" then
		local mock = { UserId = target, Name = "user" }
		rank = self:GetRank(mock)
	elseif type(target) == "string" then
		rank = self.GetRankByName(target)
	end
	if not rank or not rank.Flags then return true end
	if rank.Flags[action] == false then
		return false, ("%s rank is immune to %s"):format(rank.Name, action)
	end
	return true
end

function UtilModule.StandCharacterOn(char, part)
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (root and part) then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local lift = part.Size.Y / 2 + root.Size.Y / 2 + (humanoid and humanoid.HipHeight or 2)
	root.CFrame = part.CFrame * CFrame.new(0, lift, 0)
end

function UtilModule.GetPlayer(player, text)
	local TargetPlayer = nil
	if not text or text == "" then return nil end
	if text == Settings.Localization.Self  then return player end
	if text == Settings.Localization.All   then return "all" end
	if text == Settings.Localization.Other then return "other" end

	for _, v in pairs(Players:GetPlayers()) do
		if string.find(v.Name:lower(), text:lower()) then
			if TargetPlayer then return false end
			TargetPlayer = v
		end
	end
	return TargetPlayer
end

function UtilModule:Log(LogType, Message)
	if not Settings.Debug then return end
	if     LogType == "Warn"  then warn("[uxrAPS]: "..Message)
	elseif LogType == "Error" then warn("[uxrAPS ERROR]: "..Message)
	elseif LogType == "Info"  then print("[uxrAPS]: "..Message) end
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		RuntimeRanks[player.UserId] = nil
	end)
end

return UtilModule
