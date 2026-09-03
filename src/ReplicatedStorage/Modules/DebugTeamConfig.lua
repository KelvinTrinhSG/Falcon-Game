--#ReplicatedStorage>Modules>DebugTeamConfig
local DebugTeamConfig = {
	Members = {
		{
			STT = 1,
			Team = "Kiên",
			PlayerName = "APlayer3210",
			UserId = 11115679011,
		},
		{
			STT = 2,
			Team = "Phúc",
			PlayerName = "Sinhvienbachkhoa11",
			UserId = 11336473710,
		},
		{
			STT = 3,
			Team = "Dương",
			PlayerName = "FPlayer3210",
			UserId = 11489030982,
		},
		{
			STT = 4,
			Team = "Nhi",
			PlayerName = "EPlayer3210",
			UserId = 11481072785,
		},
		{
			STT = 5,
			Team = "Bảo",
			PlayerName = "GPlayer3210",
			UserId = 11515319361,
		},
		{
			STT = 6,
			Team = "Thương",
			PlayerName = "CPlayer3210",
			UserId = 11469905691,
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
