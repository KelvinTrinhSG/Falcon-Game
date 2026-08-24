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
			{Enemy = "SmallYellowToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[2] = {
		CashReward = 15,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[3] = {
		CashReward = 20,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[4] = {
		CashReward = 25,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[5] = {
		CashReward = 35,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "SmallRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[6] = {
		CashReward = 45,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SmallRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[7] = {
		CashReward = 60,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SmallRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[8] = {
		CashReward = 80,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "SmallRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "LargeToilet", Count = 1, DelayBetweenSpawns = 3},
		}
	},
	[9] = {
		CashReward = 100,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SmallRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "LargeToilet", Count = 2, DelayBetweenSpawns = 4},
		}
	},
	[10] = {
		CashReward = 150,
		UnlocksStartingWave = 5,
		Enemies = {
			{Enemy = "LargeToilet", Count = 1, DelayBetweenSpawns = 2},
			{Enemy = "SmallRedToilet", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "SmallYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "LargeToilet", Count = 2, DelayBetweenSpawns = 3},
			{Enemy = "AssassinYellowToilet", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 2
		}
	},

	-- ==========================================
	-- CYCLE 2 (Vagues 11 à 20)
	-- Slimes: SlimeYellowEnemy, SlimeRedEnemy, SlimeBlueEnemy
	-- ==========================================
	[11] = {
		CashReward = 55,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[12] = {
		CashReward = 60,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[13] = {
		CashReward = 65,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[14] = {
		CashReward = 70,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "AssassinRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[15] = {
		CashReward = 75,
		UnlocksStartingWave = 10,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "AssassinRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[16] = {
		CashReward = 80,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "AssassinRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[17] = {
		CashReward = 85,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "AssassinRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "PoliceToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[18] = {
		CashReward = 90,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "AssassinRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "PoliceToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[19] = {
		CashReward = 95,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "AssassinRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "PoliceToilet", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[20] = {
		CashReward = 150,
		UnlocksStartingWave = 15,
		Enemies = {
			{Enemy = "PoliceToilet", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "AssassinRedToilet", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "AssassinYellowToilet", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "PoliceToilet", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "GlassesYellowToilet", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 3
		}
	},

	-- ==========================================
	-- CYCLE 3 (Vagues 21 à 30)
	-- Slimes: SlimePinkMiniBobEnemy, SlimePinkBobEnemy, SlimeCandleEnemy
	-- ==========================================
	[21] = {
		CashReward = 105,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[22] = {
		CashReward = 110,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[23] = {
		CashReward = 115,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[24] = {
		CashReward = 120,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "GlassesRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[25] = {
		CashReward = 125,
		UnlocksStartingWave = 20,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "GlassesRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[26] = {
		CashReward = 130,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "GlassesRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[27] = {
		CashReward = 135,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "GlassesRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "GlitchToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[28] = {
		CashReward = 140,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "GlassesRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "GlitchToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[29] = {
		CashReward = 145,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "GlassesRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "GlitchToilet", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[30] = {
		CashReward = 200,
		UnlocksStartingWave = 25,
		Enemies = {
			{Enemy = "GlitchToilet", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "GlassesRedToilet", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "GlassesYellowToilet", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "GlitchToilet", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "DJYellowToilet", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 4
		}
	},

	-- ==========================================
	-- CYCLE 4 (Vagues 31 à 40)
	-- Slimes: SlimeCatEnemy, SlimeMonkeyEnemy, Boss 1
	-- ==========================================
	[31] = {
		CashReward = 155,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[32] = {
		CashReward = 160,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[33] = {
		CashReward = 165,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[34] = {
		CashReward = 170,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "DJRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[35] = {
		CashReward = 175,
		UnlocksStartingWave = 30,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "DJRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[36] = {
		CashReward = 180,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "DJRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[37] = {
		CashReward = 185,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "DJRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "DualBladeToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[38] = {
		CashReward = 190,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "DJRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "DualBladeToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[39] = {
		CashReward = 195,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "DJRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "DualBladeToilet", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[40] = {
		CashReward = 300,
		IsBossWave = true,
		UnlocksStartingWave = 35,
		BossImageId = "rbxassetid://79570261815183", -- L'image de ton SlimeBoss1
		Enemies = {
			{Enemy = "DJRedToilet", Count = 10, DelayBetweenSpawns = 0.5},
			{Enemy = "DJYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "BossToilet", Count = 1, DelayBetweenSpawns = 3}, -- LE BOSS 1
			{Enemy = "VacuumYellowToilet", Count = 1, DelayBetweenSpawns = 1.5}, -- TEASING CYCLE 5
		}
	},

	-- ==========================================
	-- CYCLE 5 (Vagues 41 à 50)
	-- Slimes: SlimePlantEnemy, SlimeTreeEnemy, SlimeCactusEnemy
	-- ==========================================
	[41] = {
		CashReward = 205,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[42] = {
		CashReward = 210,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[43] = {
		CashReward = 215,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[44] = {
		CashReward = 220,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "VacuumRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[45] = {
		CashReward = 225,
		UnlocksStartingWave = 40,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "VacuumRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[46] = {
		CashReward = 230,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "VacuumRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[47] = {
		CashReward = 235,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "VacuumRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "FlyingBuzzsawToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[48] = {
		CashReward = 240,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 10, DelayBetweenSpawns = 0.8},
			{Enemy = "VacuumRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "FlyingBuzzsawToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[49] = {
		CashReward = 245,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "VacuumRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "FlyingBuzzsawToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[50] = {
		CashReward = 350,
		UnlocksStartingWave = 45,
		Enemies = {
			{Enemy = "FlyingBuzzsawToilet", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "VacuumYellowToilet", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "VacuumRedToilet", Count = 10, DelayBetweenSpawns = 0.8},
			{Enemy = "FlyingBuzzsawToilet", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "DualBladeYellowToilet", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 6
		}
	},

	-- ==========================================
	-- CYCLE 6 (Vagues 51 à 60)
	-- Slimes: SlimeBullEnemy, SlimeReindeerEnemy, SlimeDuckEnemy
	-- ==========================================
	[51] = {
		CashReward = 255,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[52] = {
		CashReward = 260,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[53] = {
		CashReward = 265,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[54] = {
		CashReward = 270,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "DualBladeRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[55] = {
		CashReward = 275,
		UnlocksStartingWave = 50,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "DualBladeRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[56] = {
		CashReward = 280,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "DualBladeRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[57] = {
		CashReward = 285,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "DualBladeRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "FlyingRocketLauncherToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[58] = {
		CashReward = 290,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "DualBladeRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "FlyingRocketLauncherToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[59] = {
		CashReward = 295,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "DualBladeRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "FlyingRocketLauncherToilet", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[60] = {
		CashReward = 400,
		UnlocksStartingWave = 55,
		Enemies = {
			{Enemy = "FlyingRocketLauncherToilet", Count = 2, DelayBetweenSpawns = 2},
			{Enemy = "DualBladeRedToilet", Count = 15, DelayBetweenSpawns = 0.5},
			{Enemy = "DualBladeYellowToilet", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "FlyingRocketLauncherToilet", Count = 3, DelayBetweenSpawns = 3},
			{Enemy = "HelicopterParasiteYellowToilet", Count = 1, DelayBetweenSpawns = 2.5}, -- TEASING CYCLE 7
		}
	},

	-- ==========================================
	-- CYCLE 7 (Vagues 61 à 70)
	-- Slimes: SlimeSharkEnemy, SlimeOrcaEnemy, SlimeAxolotlEnemy
	-- ==========================================
	[61] = {
		CashReward = 305,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[62] = {
		CashReward = 310,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[63] = {
		CashReward = 315,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[64] = {
		CashReward = 320,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "HelicopterParasiteRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[65] = {
		CashReward = 325,
		UnlocksStartingWave = 60,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "HelicopterParasiteRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[66] = {
		CashReward = 330,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "HelicopterParasiteRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[67] = {
		CashReward = 335,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "HelicopterParasiteRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "LargePoliceToilet", Count = 1, DelayBetweenSpawns = 3},
		}
	},
	[68] = {
		CashReward = 340,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "HelicopterParasiteRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "LargePoliceToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[69] = {
		CashReward = 345,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "HelicopterParasiteRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "LargePoliceToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[70] = {
		CashReward = 400,
		IsBossWave = false,
		UnlocksStartingWave = 65,
		Enemies = {
			{Enemy = "HelicopterParasiteRedToilet", Count = 10, DelayBetweenSpawns = 0.5},
			{Enemy = "HelicopterParasiteYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "LargePoliceToilet", Count = 1, DelayBetweenSpawns = 0},
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 1, DelayBetweenSpawns = 3}, -- TEASING CYCLE 8
		}
	},

	-- ==========================================
	-- CYCLE 8 (Vagues 71 à 80)
	-- Slimes: SlimeTomatoEnemy, SlimePumpkinEnemy, Boss 2
	-- ==========================================
	[71] = {
		CashReward = 355,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[72] = {
		CashReward = 360,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[73] = {
		CashReward = 365,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[74] = {
		CashReward = 370,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[75] = {
		CashReward = 375,
		UnlocksStartingWave = 70,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 5, DelayBetweenSpawns = 1.2},
		}
	},
	[76] = {
		CashReward = 380,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[77] = {
		CashReward = 385,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "GiantDualBladeToilet", Count = 2, DelayBetweenSpawns = 3},
		}
	},
	[78] = {
		CashReward = 390,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 8, DelayBetweenSpawns = 1},
			{Enemy = "GiantDualBladeToilet", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[79] = {
		CashReward = 395,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "GiantDualBladeToilet", Count = 4, DelayBetweenSpawns = 3},
		}
	},
	[80] = {
		CashReward = 400,
		IsBossWave = true,
		UnlocksStartingWave = 70,
		BossImageId = "rbxassetid://130072194772346", -- L'image de ton SlimeBoss2
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 10, DelayBetweenSpawns = 0.5},
			{Enemy = "GiantDualBladeToilet", Count = 5, DelayBetweenSpawns = 1},
			{Enemy = "BossToilet2", Count = 1, DelayBetweenSpawns = 1.5}, -- LE TITAN BOSS 2
		}
	},
	-- ==========================================
	-- L'ASCENSION FINALE (Vagues 81 à 100)
	-- Mobs: SlimeWaterLilyEnemy, SlimeGreenEnemy, SlimePlantEnemy, SlimeCactusEnemy
	-- ==========================================
	[81] = {
		CashReward = 405,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 8, DelayBetweenSpawns = 1},
		}
	},
	[82] = {
		CashReward = 410,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 12, DelayBetweenSpawns = 0.8},
		}
	},
	[83] = {
		CashReward = 415,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
		}
	},
	[84] = {
		CashReward = 420,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "GiantGlassesRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		}
	},
	[85] = {
		CashReward = 425,
		UnlocksStartingWave = 80,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantGlassesRedToilet", Count = 6, DelayBetweenSpawns = 1.2},
		}
	},
	[86] = {
		CashReward = 430,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantGlassesRedToilet", Count = 10, DelayBetweenSpawns = 1},
		}
	},
	[87] = {
		CashReward = 435,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantGlassesRedToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "SpiderToilet", Count = 2, DelayBetweenSpawns = 2.5},
		}
	},
	[88] = {
		CashReward = 440,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 20, DelayBetweenSpawns = 0.6},
			{Enemy = "GiantGlassesRedToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "SpiderToilet", Count = 4, DelayBetweenSpawns = 2},
		}
	},
	[89] = {
		CashReward = 445,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 20, DelayBetweenSpawns = 0.5},
			{Enemy = "GiantGlassesRedToilet", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "SpiderToilet", Count = 7, DelayBetweenSpawns = 1.5},
		}
	},
	[90] = {
		CashReward = 450,
		UnlocksStartingWave = 85,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 20, DelayBetweenSpawns = 0.4},
			{Enemy = "GiantGlassesRedToilet", Count = 20, DelayBetweenSpawns = 0.6},
			{Enemy = "SpiderToilet", Count = 10, DelayBetweenSpawns = 1},
			{Enemy = "InfectedTitanSpeakerman", Count = 1, DelayBetweenSpawns = 3}, 
		}
	},
	[91] = {
		CashReward = 455,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SpiderToilet", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[92] = {
		CashReward = 460,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 35, DelayBetweenSpawns = 0.3},
			{Enemy = "GiantGlassesRedToilet", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "SpiderToilet", Count = 15, DelayBetweenSpawns = 1},
		}
	},
	[93] = {
		CashReward = 465,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "SpiderToilet", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "InfectedTitanSpeakerman", Count = 2, DelayBetweenSpawns = 4},
		}
	},
	[94] = {
		CashReward = 470,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 40, DelayBetweenSpawns = 0.3},
			{Enemy = "GiantGlassesRedToilet", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "SpiderToilet", Count = 20, DelayBetweenSpawns = 0.8},
		}
	},
	[95] = {
		CashReward = 475,
		UnlocksStartingWave = 90,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet", Count = 35, DelayBetweenSpawns = 0.5},
			{Enemy = "SpiderToilet", Count = 25, DelayBetweenSpawns = 0.8},
			{Enemy = "InfectedTitanSpeakerman", Count = 3, DelayBetweenSpawns = 3},
		}
	},
	[96] = {
		CashReward = 480,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 40, DelayBetweenSpawns = 0.2},
			{Enemy = "SpiderToilet", Count = 30, DelayBetweenSpawns = 0.6},
		}
	},
	[97] = {
		CashReward = 485,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet", Count = 40, DelayBetweenSpawns = 0.4},
			{Enemy = "SpiderToilet", Count = 35, DelayBetweenSpawns = 0.6},
			{Enemy = "InfectedTitanSpeakerman", Count = 5, DelayBetweenSpawns = 2.5},
		}
	},
	[98] = {
		CashReward = 490,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 50, DelayBetweenSpawns = 0.2},
			{Enemy = "GiantGlassesRedToilet", Count = 40, DelayBetweenSpawns = 0.4},
			{Enemy = "SpiderToilet", Count = 35, DelayBetweenSpawns = 0.5},
		}
	},
	[99] = {
		CashReward = 495,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet", Count = 50, DelayBetweenSpawns = 0.3},
			{Enemy = "SpiderToilet", Count = 45, DelayBetweenSpawns = 0.4},
			{Enemy = "InfectedTitanSpeakerman", Count = 4, DelayBetweenSpawns = 2},
		}
	},
	[100] = {
		CashReward = 500,
		UnlocksStartingWave = 96,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 50, DelayBetweenSpawns = 0.15},
			{Enemy = "GiantGlassesRedToilet", Count = 45, DelayBetweenSpawns = 0.2},
			{Enemy = "SpiderToilet", Count = 35, DelayBetweenSpawns = 0.3},
			{Enemy = "InfectedTitanSpeakerman", Count = 10, DelayBetweenSpawns = 1.5}, 
		}
	},
	
	-- ==========================================
	-- CYCLE 11 (Vagues 101 à 110) - L'Invasion Planétaire
	-- Mobs: SlimePlaneteGreenEnemy, SlimePlaneteYellowEnemy, SlimePlaneteBlackEnemy
	-- ==========================================
	[101] = {
		CashReward = 510,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 8, DelayBetweenSpawns = 1.2},
		}
	},
	[102] = {
		CashReward = 520,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[103] = {
		CashReward = 530,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 15, DelayBetweenSpawns = 0.8},
		}
	},
	[104] = {
		CashReward = 540,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 12, DelayBetweenSpawns = 1},
			{Enemy = "UFOToilet", Count = 4, DelayBetweenSpawns = 1.5},
		}
	},
	[105] = {
		CashReward = 550,
		UnlocksStartingWave = 100,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 15, DelayBetweenSpawns = 0.8},
			{Enemy = "UFOToilet", Count = 8, DelayBetweenSpawns = 1.2},
		}
	},
	[106] = {
		CashReward = 560,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "UFOToilet", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[107] = {
		CashReward = 570,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "UFOToilet", Count = 15, DelayBetweenSpawns = 1},
			{Enemy = "RocketToilet", Count = 3, DelayBetweenSpawns = 2},
		}
	},
	[108] = {
		CashReward = 580,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "UFOToilet", Count = 18, DelayBetweenSpawns = 0.8},
			{Enemy = "RocketToilet", Count = 6, DelayBetweenSpawns = 1.5},
		}
	},
	[109] = {
		CashReward = 590,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "UFOToilet", Count = 22, DelayBetweenSpawns = 0.8},
			{Enemy = "RocketToilet", Count = 10, DelayBetweenSpawns = 1.2},
		}
	},
	[110] = {
		CashReward = 600,
		UnlocksStartingWave = 105,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 35, DelayBetweenSpawns = 0.5},
			{Enemy = "UFOToilet", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "RocketToilet", Count = 15, DelayBetweenSpawns = 1},
			{Enemy = "StriderRocketToilet", Count = 2, DelayBetweenSpawns = 3}, -- Teasing galactique !
		}
	},

	-- ==========================================
	-- CYCLE 12 (Vagues 111 à 120) - La Menace Galactique
	-- Mobs: Tous les Slimes Planètes + SlimeGalaxyEnemy
	-- ==========================================
	[111] = {
		CashReward = 610,
		Enemies = {
			{Enemy = "UFOToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "RocketToilet", Count = 12, DelayBetweenSpawns = 1},
		}
	},
	[112] = {
		CashReward = 620,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 30, DelayBetweenSpawns = 0.5},
			{Enemy = "UFOToilet", Count = 25, DelayBetweenSpawns = 0.6},
			{Enemy = "RocketToilet", Count = 15, DelayBetweenSpawns = 1},
		}
	},
	[113] = {
		CashReward = 630,
		Enemies = {
			{Enemy = "UFOToilet", Count = 30, DelayBetweenSpawns = 0.6},
			{Enemy = "RocketToilet", Count = 20, DelayBetweenSpawns = 0.8},
			{Enemy = "StriderRocketToilet", Count = 4, DelayBetweenSpawns = 2.5},
		}
	},
	[114] = {
		CashReward = 640,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 40, DelayBetweenSpawns = 0.4},
			{Enemy = "UFOToilet", Count = 35, DelayBetweenSpawns = 0.5},
			{Enemy = "RocketToilet", Count = 25, DelayBetweenSpawns = 0.8},
		}
	},
	[115] = {
		CashReward = 650,
		UnlocksStartingWave = 110,
		Enemies = {
			{Enemy = "UFOToilet", Count = 40, DelayBetweenSpawns = 0.5},
			{Enemy = "RocketToilet", Count = 30, DelayBetweenSpawns = 0.8},
			{Enemy = "StriderRocketToilet", Count = 6, DelayBetweenSpawns = 2},
		}
	},
	[116] = {
		CashReward = 660,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 50, DelayBetweenSpawns = 0.3},
			{Enemy = "RocketToilet", Count = 35, DelayBetweenSpawns = 0.6},
		}
	},
	[117] = {
		CashReward = 670,
		Enemies = {
			{Enemy = "UFOToilet", Count = 45, DelayBetweenSpawns = 0.4},
			{Enemy = "RocketToilet", Count = 40, DelayBetweenSpawns = 0.6},
			{Enemy = "StriderRocketToilet", Count = 8, DelayBetweenSpawns = 1.5},
		}
	},
	[118] = {
		CashReward = 680,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 60, DelayBetweenSpawns = 0.2},
			{Enemy = "UFOToilet", Count = 50, DelayBetweenSpawns = 0.3},
			{Enemy = "RocketToilet", Count = 45, DelayBetweenSpawns = 0.5},
		}
	},
	[119] = {
		CashReward = 690,
		Enemies = {
			{Enemy = "UFOToilet", Count = 60, DelayBetweenSpawns = 0.3},
			{Enemy = "RocketToilet", Count = 55, DelayBetweenSpawns = 0.4},
			{Enemy = "StriderRocketToilet", Count = 12, DelayBetweenSpawns = 1.2},
		}
	},
	[120] = {
		CashReward = 700, 
		UnlocksStartingWave = 115,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 75, DelayBetweenSpawns = 0.2},
			{Enemy = "UFOToilet", Count = 65, DelayBetweenSpawns = 0.3},
			{Enemy = "RocketToilet", Count = 60, DelayBetweenSpawns = 0.4},
			{Enemy = "StriderRocketToilet", Count = 25, DelayBetweenSpawns = 1}, -- La horde Galactique !
		}
	},
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}

return WaveConfigurations
