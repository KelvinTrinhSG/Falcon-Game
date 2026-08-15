--[[
	Defines the enemies and their counts for each wave.
	- CashReward: How much cash the player receives for clearing the wave.
	- Enemies: A list of enemy groups to spawn.
--]]

local WaveConfigurations = {
	-- ==========================================
	-- CYCLE 1 (Vagues 1 à 10)
	-- Slimes: SlimeEnemy, SlimeFastEnemy, SlimeBombonEnemy
	-- ==========================================
	[1] = {
		CashReward = 10,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[2] = {
		CashReward = 15,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[3] = {
		CashReward = 20,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[4] = {
		CashReward = 25,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[5] = {
		CashReward = 35,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeFastEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[6] = {
		CashReward = 45,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeFastEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[7] = {
		CashReward = 60,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeFastEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[8] = {
		CashReward = 80,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeFastEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeBombonEnemy", Count = 1, DelayBetweenSpawns = 3},
		}
	},
	[9] = {
		CashReward = 100,
		Enemies = {
			{Enemy = "SlimeEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeFastEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeBombonEnemy", Count = 2, DelayBetweenSpawns = 4},
		}
	},
	[10] = {
		CashReward = 150,
		UnlocksStartingWave = 5,
		Enemies = {
			{Enemy = "SlimeBombonEnemy", Count = 1, DelayBetweenSpawns = 2},
			{Enemy = "SlimeFastEnemy", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeBombonEnemy", Count = 2, DelayBetweenSpawns = 3},
			{Enemy = "SlimeYellowEnemy", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 2
		}
	},

	-- ==========================================
	-- CYCLE 2 (Vagues 11 à 20)
	-- Slimes: SlimeYellowEnemy, SlimeRedEnemy, SlimeBlueEnemy
	-- ==========================================
	[11] = {
		CashReward = 55,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[12] = {
		CashReward = 60,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[13] = {
		CashReward = 65,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[14] = {
		CashReward = 70,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeRedEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[15] = {
		CashReward = 75,
		UnlocksStartingWave = 10,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeRedEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[16] = {
		CashReward = 80,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeRedEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[17] = {
		CashReward = 85,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeRedEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeBlueEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[18] = {
		CashReward = 90,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeRedEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeBlueEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[19] = {
		CashReward = 95,
		Enemies = {
			{Enemy = "SlimeYellowEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeRedEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeBlueEnemy", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[20] = {
		CashReward = 150,
		UnlocksStartingWave = 15,
		Enemies = {
			{Enemy = "SlimeBlueEnemy", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "SlimeRedEnemy", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeYellowEnemy", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeBlueEnemy", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "SlimePinkMiniBobEnemy", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 3
		}
	},

	-- ==========================================
	-- CYCLE 3 (Vagues 21 à 30)
	-- Slimes: SlimePinkMiniBobEnemy, SlimePinkBobEnemy, SlimeCandleEnemy
	-- ==========================================
	[21] = {
		CashReward = 105,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[22] = {
		CashReward = 110,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[23] = {
		CashReward = 115,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[24] = {
		CashReward = 120,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimePinkBobEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[25] = {
		CashReward = 125,
		UnlocksStartingWave = 20,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimePinkBobEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[26] = {
		CashReward = 130,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePinkBobEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[27] = {
		CashReward = 135,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimePinkBobEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCandleEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[28] = {
		CashReward = 140,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePinkBobEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCandleEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[29] = {
		CashReward = 145,
		Enemies = {
			{Enemy = "SlimePinkMiniBobEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePinkBobEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCandleEnemy", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[30] = {
		CashReward = 200,
		UnlocksStartingWave = 25,
		Enemies = {
			{Enemy = "SlimeCandleEnemy", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "SlimePinkBobEnemy", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePinkMiniBobEnemy", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeCandleEnemy", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "SlimeCatEnemy", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 4
		}
	},

	-- ==========================================
	-- CYCLE 4 (Vagues 31 à 40)
	-- Slimes: SlimeCatEnemy, SlimeMonkeyEnemy, Boss 1
	-- ==========================================
	[31] = {
		CashReward = 155,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[32] = {
		CashReward = 160,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[33] = {
		CashReward = 165,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[34] = {
		CashReward = 170,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeMonkeyEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[35] = {
		CashReward = 175,
		UnlocksStartingWave = 30,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeMonkeyEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[36] = {
		CashReward = 180,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeMonkeyEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[37] = {
		CashReward = 185,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeMonkeyEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeTurtleEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[38] = {
		CashReward = 190,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeMonkeyEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeTurtleEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[39] = {
		CashReward = 195,
		Enemies = {
			{Enemy = "SlimeCatEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeMonkeyEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeTurtleEnemy", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[40] = {
		CashReward = 300,
		IsBossWave = true,
		UnlocksStartingWave = 35,
		BossImageId = "rbxassetid://79570261815183", -- L'image de ton SlimeBoss1
		Enemies = {
			{Enemy = "SlimeMonkeyEnemy", Count = 10, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeCatEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeBoss1", Count = 1, DelayBetweenSpawns = 3}, -- LE BOSS 1
			{Enemy = "SlimePlantEnemy", Count = 1, DelayBetweenSpawns = 1.5}, -- TEASING CYCLE 5
		}
	},

	-- ==========================================
	-- CYCLE 5 (Vagues 41 à 50)
	-- Slimes: SlimePlantEnemy, SlimeTreeEnemy, SlimeCactusEnemy
	-- ==========================================
	[41] = {
		CashReward = 205,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[42] = {
		CashReward = 210,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[43] = {
		CashReward = 215,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[44] = {
		CashReward = 220,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeTreeEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[45] = {
		CashReward = 225,
		UnlocksStartingWave = 40,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeTreeEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[46] = {
		CashReward = 230,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeTreeEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[47] = {
		CashReward = 235,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeTreeEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCactusEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[48] = {
		CashReward = 240,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 10, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeTreeEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCactusEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[49] = {
		CashReward = 245,
		Enemies = {
			{Enemy = "SlimePlantEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeTreeEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCactusEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[50] = {
		CashReward = 350,
		UnlocksStartingWave = 45,
		Enemies = {
			{Enemy = "SlimeCactusEnemy", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "SlimePlantEnemy", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeTreeEnemy", Count = 10, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeCactusEnemy", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "SlimeBullEnemy", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 6
		}
	},

	-- ==========================================
	-- CYCLE 6 (Vagues 51 à 60)
	-- Slimes: SlimeBullEnemy, SlimeReindeerEnemy, SlimeDuckEnemy
	-- ==========================================
	[51] = {
		CashReward = 255,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[52] = {
		CashReward = 260,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[53] = {
		CashReward = 265,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[54] = {
		CashReward = 270,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeReindeerEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[55] = {
		CashReward = 275,
		UnlocksStartingWave = 50,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeReindeerEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[56] = {
		CashReward = 280,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeReindeerEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[57] = {
		CashReward = 285,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeReindeerEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeDuckEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[58] = {
		CashReward = 290,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeReindeerEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeDuckEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[59] = {
		CashReward = 295,
		Enemies = {
			{Enemy = "SlimeBullEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeReindeerEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeDuckEnemy", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[60] = {
		CashReward = 400,
		UnlocksStartingWave = 55,
		Enemies = {
			{Enemy = "SlimeDuckEnemy", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "SlimeReindeerEnemy", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeBullEnemy", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeDuckEnemy", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "SlimeSharkEnemy", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 7
		}
	},

	-- ==========================================
	-- CYCLE 7 (Vagues 61 à 70)
	-- Slimes: SlimeSharkEnemy, SlimeOrcaEnemy, SlimeAxolotlEnemy
	-- ==========================================
	[61] = {
		CashReward = 305,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[62] = {
		CashReward = 310,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[63] = {
		CashReward = 315,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[64] = {
		CashReward = 320,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeOrcaEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[65] = {
		CashReward = 325,
		UnlocksStartingWave = 60,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeOrcaEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[66] = {
		CashReward = 330,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeOrcaEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[67] = {
		CashReward = 335,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeOrcaEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeAxolotlEnemy", Count = 1, DelayBetweenSpawns = 3},
		}
	},
	[68] = {
		CashReward = 340,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeOrcaEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeAxolotlEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[69] = {
		CashReward = 345,
		Enemies = {
			{Enemy = "SlimeSharkEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeOrcaEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeAxolotlEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[70] = {
		CashReward = 400,
		IsBossWave = false,
		UnlocksStartingWave = 65,
		Enemies = {
			{Enemy = "SlimeOrcaEnemy", Count = 10, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeSharkEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeAxolotlEnemy", Count = 1, DelayBetweenSpawns = 0},
			{Enemy = "SlimeTomatoEnemy", Count = 1, DelayBetweenSpawns = 3}, -- TEASING CYCLE 8
		}
	},

	-- ==========================================
	-- CYCLE 8 (Vagues 71 à 80)
	-- Slimes: SlimeTomatoEnemy, SlimePumpkinEnemy, Boss 2
	-- ==========================================
	[71] = {
		CashReward = 355,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[72] = {
		CashReward = 360,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[73] = {
		CashReward = 365,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[74] = {
		CashReward = 370,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimePumpkinEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[75] = {
		CashReward = 375,
		UnlocksStartingWave = 70,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimePumpkinEnemy", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[76] = {
		CashReward = 380,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePumpkinEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[77] = {
		CashReward = 385,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimePumpkinEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeWatermelonEnemy", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[78] = {
		CashReward = 390,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePumpkinEnemy", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SlimeWatermelonEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[79] = {
		CashReward = 395,
		Enemies = {
			{Enemy = "SlimeTomatoEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePumpkinEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeWatermelonEnemy", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[80] = {
		CashReward = 400,
		IsBossWave = true,
		UnlocksStartingWave = 70,
		BossImageId = "rbxassetid://130072194772346", -- L'image de ton SlimeBoss2
		Enemies = {
			{Enemy = "SlimePumpkinEnemy", Count = 10, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeWatermelonEnemy", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "SlimeBoss2", Count = 1, DelayBetweenSpawns = 1.5}, -- LE TITAN BOSS 2
		}
	},
	-- ==========================================
	-- L'ASCENSION FINALE (Vagues 81 à 100)
	-- Mobs: SlimeWaterLilyEnemy, SlimeGreenEnemy, SlimePlantEnemy, SlimeCactusEnemy
	-- ==========================================
	[81] = {
		CashReward = 405,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[82] = {
		CashReward = 410,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[83] = {
		CashReward = 415,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 15, DelayBetweenSpawns = 0.8},
		}
	},
	[84] = {
		CashReward = 420,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimeGreenEnemy", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[85] = {
		CashReward = 425,
		UnlocksStartingWave = 80,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeGreenEnemy", Count = 6, DelayBetweenSpawns = 1.2},
		}
	},
	[86] = {
		CashReward = 430,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeGreenEnemy", Count = 10, DelayBetweenSpawns = 1},
		}
	},
	[87] = {
		CashReward = 435,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeGreenEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimePlantEnemy", Count = 2, DelayBetweenSpawns = 2.5},
		}
	},
	[88] = {
		CashReward = 440,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 20, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimeGreenEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlantEnemy", Count = 4, DelayBetweenSpawns = 2},
		}
	},
	[89] = {
		CashReward = 445,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 20, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimeGreenEnemy", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlantEnemy", Count = 7, DelayBetweenSpawns = 1.5},
		}
	},
	[90] = {
		CashReward = 450,
		UnlocksStartingWave = 85,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 20, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimeGreenEnemy", Count = 20, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlantEnemy", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SlimeCactusEnemy", Count = 1, DelayBetweenSpawns = 3}, 
		}
	},
	[91] = {
		CashReward = 455,
		Enemies = {
			{Enemy = "SlimeGreenEnemy", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlantEnemy", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[92] = {
		CashReward = 460,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 35, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimeGreenEnemy", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlantEnemy", Count = 15, DelayBetweenSpawns = 1},
		}
	},
	[93] = {
		CashReward = 465,
		Enemies = {
			{Enemy = "SlimeGreenEnemy", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlantEnemy", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeCactusEnemy", Count = 2, DelayBetweenSpawns = 4},
		}
	},
	[94] = {
		CashReward = 470,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 40, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimeGreenEnemy", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlantEnemy", Count = 20, DelayBetweenSpawns = 0.8},
		}
	},
	[95] = {
		CashReward = 475,
		UnlocksStartingWave = 90,
		Enemies = {
			{Enemy = "SlimeGreenEnemy", Count = 35, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlantEnemy", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeCactusEnemy", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[96] = {
		CashReward = 480,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 40, DelayBetweenSpawns = 0.2},
			{Enemy = "SlimePlantEnemy", Count = 30, DelayBetweenSpawns = 0.6},
		}
	},
	[97] = {
		CashReward = 485,
		Enemies = {
			{Enemy = "SlimeGreenEnemy", Count = 40, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimePlantEnemy", Count = 35, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimeCactusEnemy", Count = 5, DelayBetweenSpawns = 2.5},
		}
	},
	[98] = {
		CashReward = 490,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 50, DelayBetweenSpawns = 0.2},
			{Enemy = "SlimeGreenEnemy", Count = 40, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimePlantEnemy", Count = 35, DelayBetweenSpawns = 0.5},
		}
	},
	[99] = {
		CashReward = 495,
		Enemies = {
			{Enemy = "SlimeGreenEnemy", Count = 50, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimePlantEnemy", Count = 45, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimeCactusEnemy", Count = 4, DelayBetweenSpawns = 2},
		}
	},
	[100] = {
		CashReward = 500,
		UnlocksStartingWave = 96,
		Enemies = {
			{Enemy = "SlimeWaterLilyEnemy", Count = 50, DelayBetweenSpawns = 0.15},
			{Enemy = "SlimeGreenEnemy", Count = 45, DelayBetweenSpawns = 0.2},
			{Enemy = "SlimePlantEnemy", Count = 35, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimeCactusEnemy", Count = 10, DelayBetweenSpawns = 1.5}, 
		}
	},
	
	-- ==========================================
	-- CYCLE 11 (Vagues 101 à 110) - L'Invasion Planétaire
	-- Mobs: SlimePlaneteGreenEnemy, SlimePlaneteYellowEnemy, SlimePlaneteBlackEnemy
	-- ==========================================
	[101] = {
		CashReward = 510,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 8, DelayBetweenSpawns = 1.2},
		}
	},
	[102] = {
		CashReward = 520,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[103] = {
		CashReward = 530,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 15, DelayBetweenSpawns = 0.8},
		}
	},
	[104] = {
		CashReward = 540,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 4, DelayBetweenSpawns = 1.5},
		}
	},
	[105] = {
		CashReward = 550,
		UnlocksStartingWave = 100,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 8, DelayBetweenSpawns = 1.2},
		}
	},
	[106] = {
		CashReward = 560,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[107] = {
		CashReward = 570,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 15, DelayBetweenSpawns = 1},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 3, DelayBetweenSpawns = 2},
		}
	},
	[108] = {
		CashReward = 580,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 6, DelayBetweenSpawns = 1.5},
		}
	},
	[109] = {
		CashReward = 590,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 22, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 10, DelayBetweenSpawns = 1.2},
		}
	},
	[110] = {
		CashReward = 600,
		UnlocksStartingWave = 105,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 35, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 15, DelayBetweenSpawns = 1},
			{Enemy = "SlimeGalaxyEnemy", Count = 2, DelayBetweenSpawns = 3}, -- Teasing galactique !
		}
	},

	-- ==========================================
	-- CYCLE 12 (Vagues 111 à 120) - La Menace Galactique
	-- Mobs: Tous les Slimes Planètes + SlimeGalaxyEnemy
	-- ==========================================
	[111] = {
		CashReward = 610,
		Enemies = {
			{Enemy = "SlimePlaneteYellowEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[112] = {
		CashReward = 620,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 15, DelayBetweenSpawns = 1},
		}
	},
	[113] = {
		CashReward = 630,
		Enemies = {
			{Enemy = "SlimePlaneteYellowEnemy", Count = 30, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeGalaxyEnemy", Count = 4, DelayBetweenSpawns = 2.5},
		}
	},
	[114] = {
		CashReward = 640,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 40, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 35, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 25, DelayBetweenSpawns = 0.8},
		}
	},
	[115] = {
		CashReward = 650,
		UnlocksStartingWave = 110,
		Enemies = {
			{Enemy = "SlimePlaneteYellowEnemy", Count = 40, DelayBetweenSpawns = 0.5},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 30, DelayBetweenSpawns = 0.8},
			{Enemy = "SlimeGalaxyEnemy", Count = 6, DelayBetweenSpawns = 2},
		}
	},
	[116] = {
		CashReward = 660,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 50, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 35, DelayBetweenSpawns = 0.6},
		}
	},
	[117] = {
		CashReward = 670,
		Enemies = {
			{Enemy = "SlimePlaneteYellowEnemy", Count = 45, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 40, DelayBetweenSpawns = 0.6},
			{Enemy = "SlimeGalaxyEnemy", Count = 8, DelayBetweenSpawns = 1.5},
		}
	},
	[118] = {
		CashReward = 680,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 60, DelayBetweenSpawns = 0.2},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 50, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 45, DelayBetweenSpawns = 0.5},
		}
	},
	[119] = {
		CashReward = 690,
		Enemies = {
			{Enemy = "SlimePlaneteYellowEnemy", Count = 60, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 55, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimeGalaxyEnemy", Count = 12, DelayBetweenSpawns = 1.2},
		}
	},
	[120] = {
		CashReward = 700, 
		UnlocksStartingWave = 115,
		Enemies = {
			{Enemy = "SlimePlaneteGreenEnemy", Count = 75, DelayBetweenSpawns = 0.2},
			{Enemy = "SlimePlaneteYellowEnemy", Count = 65, DelayBetweenSpawns = 0.3},
			{Enemy = "SlimePlaneteBlackEnemy", Count = 60, DelayBetweenSpawns = 0.4},
			{Enemy = "SlimeGalaxyEnemy", Count = 25, DelayBetweenSpawns = 1}, -- La horde Galactique !
		}
	},
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}

return WaveConfigurations