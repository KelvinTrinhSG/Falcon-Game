--!strict
local RankManager = {}

-- wins = xToiletHP - 1
local RANKS = {
	{ wins = 25, name = "Supreme",     color = Color3.fromRGB(255, 220,  60), trail = { lifetime = 1.2,  emission = 1.0, height = 4.0 } },
	{ wins = 20, name = "Astro Titan", color = Color3.fromRGB( 80, 220, 255), trail = { lifetime = 1.0,  emission = 0.8, height = 3.5 } },
	{ wins = 16, name = "Titan",       color = Color3.fromRGB(255, 180,   0), trail = { lifetime = 0.75, emission = 0.7, height = 3.0 } },
	{ wins = 12, name = "Warlord",     color = Color3.fromRGB(220,  40,  40), trail = { lifetime = 0.65, emission = 0.6, height = 3.0 } },
	{ wins =  9, name = "Commander",   color = Color3.fromRGB(255,  90,  20), trail = { lifetime = 0.55, emission = 0.5, height = 3.0 } },
	{ wins =  7, name = "Elite",       color = Color3.fromRGB(255, 140,  40), trail = { lifetime = 0.5,  emission = 0.5, height = 2.5 } },
	{ wins =  5, name = "Shadow",      color = Color3.fromRGB(140,  60, 220), trail = { lifetime = 0.45, emission = 0.4, height = 2.5 } },
	{ wins =  4, name = "Enforcer",    color = Color3.fromRGB(180,  80, 255), trail = { lifetime = 0.4,  emission = 0.3, height = 2.5 } },
	{ wins =  3, name = "Vanguard",    color = Color3.fromRGB( 60, 120, 255), trail = { lifetime = 0.35, emission = 0.3, height = 2.0 } },
	{ wins =  2, name = "Operative",   color = Color3.fromRGB( 60, 200, 220), trail = { lifetime = 0.3,  emission = 0.2, height = 2.0 } },
	{ wins =  1, name = "Scout",       color = Color3.fromRGB( 80, 200,  80), trail = { lifetime = 0.25, emission = 0.0, height = 2.0 } },
	{ wins =  0, name = "Rookie",      color = Color3.fromRGB(160, 160, 160), trail = { lifetime = 0.2,  emission = 0.0, height = 2.0 } },
}

local function getRankData(xToiletHP: number)
	local wins = (xToiletHP or 1) - 1
	for _, rank in ipairs(RANKS) do
		if wins >= rank.wins then
			return rank
		end
	end
	return RANKS[#RANKS]
end

function RankManager.getRank(xToiletHP: number): string
	return getRankData(xToiletHP).name
end

function RankManager.getRankColor(xToiletHP: number): Color3
	return getRankData(xToiletHP).color
end

function RankManager.getTrailConfig(xToiletHP: number)
	return getRankData(xToiletHP).trail
end

function RankManager.getWins(xToiletHP: number): number
	return (xToiletHP or 1) - 1
end

return RankManager
