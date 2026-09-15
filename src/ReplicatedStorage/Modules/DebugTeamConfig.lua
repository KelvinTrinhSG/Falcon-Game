--#ReplicatedStorage>Modules>DebugTeamConfig
local DebugTeamConfig = {
	Members = {
		{
			STT = 1,
			Team = "Kiên",
			PlayerName = "APlayer3210",
			UserId = 11115679011,
		},
	},
}

local UserIdSet = {}
for _, member in ipairs(DebugTeamConfig.Members) do
	UserIdSet[member.UserId] = true
end

function DebugTeamConfig.IsDebugMember(userId: number): boolean
	return UserIdSet[userId] == true
end

return DebugTeamConfig
