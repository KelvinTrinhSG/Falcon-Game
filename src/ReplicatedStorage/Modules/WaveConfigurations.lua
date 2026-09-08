--!strict
--[[
	Wave configurations - balanced, max 15 enemies per wave.
	Source of truth: WAVES_BALANCED.md

	Intro rule: every new enemy type gets one solo wave (×3) before being mixed.
--]]

local WaveConfigurations = {
	-- ==========================================
	-- CYCLE 1 (Waves 1-10) - Khởi Đầu
	-- ==========================================
	[1] = {
		CashReward = 10,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 3, DelayBetweenSpawns = 3, Path = "WayPoints1"},
		},
	},
	[2] = {
		CashReward = 15,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 5, DelayBetweenSpawns = 3, Path = {"WayPoints2", "WayPoints3"}},
		},
	},
	[3] = {
		CashReward = 20,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 7, DelayBetweenSpawns = 3, Path = {"WayPoints1", "WayPoints2", "WayPoints3"}},
		},
	},
	[4] = {
		CashReward = 30,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 9, DelayBetweenSpawns = 3, Path = {"WayPoints1", "WayPoints2", "WayPoints3", "WayPoints4", "WayPoints5"}},
		},
	},
	-- SmallRedToilet solo intro
	[5] = {
		CashReward = 40,
		Enemies = {
			{Enemy = "SmallRedToilet", Count = 3, DelayBetweenSpawns = 1.5, Path = "WayPoints1"},
		},
	},
	[6] = {
		CashReward = 50,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "SmallRedToilet",    Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	-- LargeToilet solo intro
	[7] = {
		CashReward = 65,
		Enemies = {
			{Enemy = "LargeToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[8] = {
		CashReward = 80,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 7, DelayBetweenSpawns = 0.8},
			{Enemy = "SmallRedToilet",    Count = 4, DelayBetweenSpawns = 1.1},
			{Enemy = "LargeToilet",       Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[9] = {
		CashReward = 100,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "SmallRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "LargeToilet",       Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[10] = {
		CashReward = 150,
		UnlocksStartingWave = 5,
		Enemies = {
			{Enemy = "SmallYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "SmallRedToilet",    Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "LargeToilet",       Count = 2, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 2 (Waves 11-20) - Transition
	-- ==========================================
	-- HelicopterParasiteYellowToilet solo intro
	[11] = {
		CashReward = 60,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	[12] = {
		CashReward = 65,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[13] = {
		CashReward = 70,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- HelicopterParasiteRedToilet solo intro
	[14] = {
		CashReward = 75,
		Enemies = {
			{Enemy = "HelicopterParasiteRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[15] = {
		CashReward = 80,
		UnlocksStartingWave = 10,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "HelicopterParasiteRedToilet",    Count = 3, DelayBetweenSpawns = 1.4},
		},
	},
	[16] = {
		CashReward = 85,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 7, DelayBetweenSpawns = 0.9},
			{Enemy = "HelicopterParasiteRedToilet",    Count = 4, DelayBetweenSpawns = 1.2},
		},
	},
	-- PoliceToilet solo intro
	[17] = {
		CashReward = 90,
		Enemies = {
			{Enemy = "PoliceToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[18] = {
		CashReward = 95,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "HelicopterParasiteRedToilet",    Count = 4, DelayBetweenSpawns = 1.1},
			{Enemy = "PoliceToilet",                   Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[19] = {
		CashReward = 100,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "HelicopterParasiteRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "PoliceToilet",                   Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[20] = {
		CashReward = 160,
		UnlocksStartingWave = 15,
		Enemies = {
			{Enemy = "HelicopterParasiteYellowToilet", Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "HelicopterParasiteRedToilet",    Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "PoliceToilet",                   Count = 2, DelayBetweenSpawns = 2.5},
			{Enemy = "GlassesYellowToilet",            Count = 1, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 3 (Waves 21-30) - Mid Game
	-- ==========================================
	[21] = {
		CashReward = 110,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 2, DelayBetweenSpawns = 1.3},
		},
	},
	[22] = {
		CashReward = 115,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 3, DelayBetweenSpawns = 1.1},
		},
	},
	[23] = {
		CashReward = 120,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 4, DelayBetweenSpawns = 1.0},
		},
	},
	-- GlassesRedToilet solo intro
	[24] = {
		CashReward = 125,
		Enemies = {
			{Enemy = "GlassesRedToilet", Count = 1, DelayBetweenSpawns = 1.5},
		},
	},
	[25] = {
		CashReward = 130,
		UnlocksStartingWave = 20,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 4, DelayBetweenSpawns = 0.9},
			{Enemy = "GlassesRedToilet",    Count = 1, DelayBetweenSpawns = 1.3},
		},
	},
	-- FlyingBuzzsawToilet solo intro
	[26] = {
		CashReward = 140,
		Enemies = {
			{Enemy = "FlyingBuzzsawToilet", Count = 1, DelayBetweenSpawns = 3.0},
		},
	},
	[27] = {
		CashReward = 150,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 3, DelayBetweenSpawns = 0.9},
			{Enemy = "GlassesRedToilet",    Count = 2, DelayBetweenSpawns = 1.1},
			{Enemy = "FlyingBuzzsawToilet", Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[28] = {
		CashReward = 160,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 3, DelayBetweenSpawns = 0.8},
			{Enemy = "GlassesRedToilet",    Count = 2, DelayBetweenSpawns = 1.0},
			{Enemy = "FlyingBuzzsawToilet", Count = 1, DelayBetweenSpawns = 2.5},
		},
	},
	[29] = {
		CashReward = 170,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 2, DelayBetweenSpawns = 0.8},
			{Enemy = "GlassesRedToilet",    Count = 2, DelayBetweenSpawns = 1.0},
			{Enemy = "FlyingBuzzsawToilet", Count = 1, DelayBetweenSpawns = 2.5},
		},
	},
	[30] = {
		CashReward = 215,
		UnlocksStartingWave = 25,
		Enemies = {
			{Enemy = "GlassesYellowToilet", Count = 2, DelayBetweenSpawns = 0.8},
			{Enemy = "GlassesRedToilet",    Count = 2, DelayBetweenSpawns = 0.9},
			{Enemy = "FlyingBuzzsawToilet", Count = 1, DelayBetweenSpawns = 2.3},
			{Enemy = "DJYellowToilet",      Count = 1, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 4 (Waves 31-40) - Late Game
	-- ==========================================
	[31] = {
		CashReward = 165,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	[32] = {
		CashReward = 170,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[33] = {
		CashReward = 175,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- DJRedToilet solo intro
	[34] = {
		CashReward = 180,
		Enemies = {
			{Enemy = "DJRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[35] = {
		CashReward = 185,
		UnlocksStartingWave = 30,
		Enemies = {
			{Enemy = "DJYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "DJRedToilet",    Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	-- DualBladeToilet solo intro
	[36] = {
		CashReward = 195,
		Enemies = {
			{Enemy = "DualBladeToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[37] = {
		CashReward = 205,
		Enemies = {
			{Enemy = "DJYellowToilet",  Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "DJRedToilet",     Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "DualBladeToilet", Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[38] = {
		CashReward = 215,
		Enemies = {
			{Enemy = "DJYellowToilet",  Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "DJRedToilet",     Count = 4, DelayBetweenSpawns = 1.1},
			{Enemy = "DualBladeToilet", Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[39] = {
		CashReward = 225,
		Enemies = {
			{Enemy = "DJYellowToilet",  Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "DJRedToilet",     Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "DualBladeToilet", Count = 3, DelayBetweenSpawns = 2.3},
		},
	},
	[40] = {
		CashReward = 320,
		IsBossWave = true,
		UnlocksStartingWave = 35,
		BossImageId = "rbxassetid://81446192290144",
		Enemies = {
			{Enemy = "DJRedToilet",        Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "DJYellowToilet",     Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "BossToilet",         Count = 1, DelayBetweenSpawns = 3.0},
			{Enemy = "VacuumYellowToilet", Count = 1, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 5 (Waves 41-50) - Nature
	-- ==========================================
	[41] = {
		CashReward = 220,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	[42] = {
		CashReward = 225,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[43] = {
		CashReward = 230,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- VacuumRedToilet solo intro
	[44] = {
		CashReward = 235,
		Enemies = {
			{Enemy = "VacuumRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[45] = {
		CashReward = 240,
		UnlocksStartingWave = 40,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "VacuumRedToilet",    Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	-- GlitchToilet solo intro
	[46] = {
		CashReward = 250,
		Enemies = {
			{Enemy = "GlitchToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[47] = {
		CashReward = 260,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "VacuumRedToilet",    Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "GlitchToilet",       Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[48] = {
		CashReward = 270,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "VacuumRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "GlitchToilet",       Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[49] = {
		CashReward = 280,
		Enemies = {
			{Enemy = "VacuumYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "VacuumRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "GlitchToilet",       Count = 3, DelayBetweenSpawns = 2.3},
		},
	},
	[50] = {
		CashReward = 370,
		UnlocksStartingWave = 45,
		Enemies = {
			{Enemy = "VacuumYellowToilet",    Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "VacuumRedToilet",       Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "GlitchToilet",          Count = 3, DelayBetweenSpawns = 2.3},
			{Enemy = "DualBladeYellowToilet", Count = 1, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 6 (Waves 51-60) - Animals
	-- ==========================================
	[51] = {
		CashReward = 270,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	[52] = {
		CashReward = 275,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[53] = {
		CashReward = 280,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- DualBladeRedToilet solo intro
	[54] = {
		CashReward = 285,
		Enemies = {
			{Enemy = "DualBladeRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[55] = {
		CashReward = 290,
		UnlocksStartingWave = 50,
		Enemies = {
			{Enemy = "DualBladeYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "DualBladeRedToilet",    Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	-- FlyingRocketLauncherToilet solo intro
	[56] = {
		CashReward = 300,
		Enemies = {
			{Enemy = "FlyingRocketLauncherToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[57] = {
		CashReward = 310,
		Enemies = {
			{Enemy = "DualBladeYellowToilet",      Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "DualBladeRedToilet",          Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "FlyingRocketLauncherToilet",  Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[58] = {
		CashReward = 320,
		Enemies = {
			{Enemy = "DualBladeYellowToilet",      Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "DualBladeRedToilet",          Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "FlyingRocketLauncherToilet",  Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[59] = {
		CashReward = 330,
		Enemies = {
			{Enemy = "DualBladeYellowToilet",      Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "DualBladeRedToilet",          Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "FlyingRocketLauncherToilet",  Count = 3, DelayBetweenSpawns = 2.3},
		},
	},
	[60] = {
		CashReward = 420,
		UnlocksStartingWave = 55,
		Enemies = {
			{Enemy = "DualBladeYellowToilet",   Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "DualBladeRedToilet",       Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "FlyingRocketLauncherToilet", Count = 3, DelayBetweenSpawns = 2.3},
			{Enemy = "AssassinYellowToilet",     Count = 1, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 7 (Waves 61-70) - Ocean
	-- ==========================================
	[61] = {
		CashReward = 320,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	[62] = {
		CashReward = 325,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[63] = {
		CashReward = 330,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- AssassinRedToilet solo intro
	[64] = {
		CashReward = 335,
		Enemies = {
			{Enemy = "AssassinRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[65] = {
		CashReward = 340,
		UnlocksStartingWave = 60,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "AssassinRedToilet",    Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	-- LargePoliceToilet solo intro
	[66] = {
		CashReward = 350,
		Enemies = {
			{Enemy = "LargePoliceToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[67] = {
		CashReward = 360,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "AssassinRedToilet",    Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "LargePoliceToilet",    Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[68] = {
		CashReward = 370,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "AssassinRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "LargePoliceToilet",    Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[69] = {
		CashReward = 380,
		Enemies = {
			{Enemy = "AssassinYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "AssassinRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "LargePoliceToilet",    Count = 2, DelayBetweenSpawns = 2.3},
		},
	},
	[70] = {
		CashReward = 420,
		UnlocksStartingWave = 65,
		Enemies = {
			{Enemy = "AssassinYellowToilet",           Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "AssassinRedToilet",               Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "LargePoliceToilet",               Count = 3, DelayBetweenSpawns = 2.3},
			{Enemy = "LargeFlyingBuzzsawYellowToilet",  Count = 1, DelayBetweenSpawns = 2.5},
		},
	},

	-- ==========================================
	-- CYCLE 8 (Waves 71-80) - Fruits
	-- ==========================================
	[71] = {
		CashReward = 370,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	[72] = {
		CashReward = 375,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[73] = {
		CashReward = 380,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- LargeFlyingBuzzsawRedToilet solo intro
	[74] = {
		CashReward = 385,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[75] = {
		CashReward = 390,
		UnlocksStartingWave = 70,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "LargeFlyingBuzzsawRedToilet",    Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	-- GiantDualBladeToilet solo intro
	[76] = {
		CashReward = 400,
		Enemies = {
			{Enemy = "GiantDualBladeToilet", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[77] = {
		CashReward = 410,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "LargeFlyingBuzzsawRedToilet",    Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "GiantDualBladeToilet",           Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[78] = {
		CashReward = 420,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "LargeFlyingBuzzsawRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "GiantDualBladeToilet",           Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[79] = {
		CashReward = 430,
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "LargeFlyingBuzzsawRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "GiantDualBladeToilet",           Count = 3, DelayBetweenSpawns = 2.3},
		},
	},
	[80] = {
		CashReward = 420,
		IsBossWave = true,
		UnlocksStartingWave = 70,
		BossImageId = "rbxassetid://94670596503261",
		Enemies = {
			{Enemy = "LargeFlyingBuzzsawRedToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantDualBladeToilet",        Count = 3, DelayBetweenSpawns = 1.5},
			{Enemy = "BossToilet2",                 Count = 1, DelayBetweenSpawns = 2.0},
		},
	},

	-- ==========================================
	-- CYCLE 9 (Waves 81-100) - Veggie Hell
	-- ==========================================
	[81] = {
		CashReward = 430,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 4, DelayBetweenSpawns = 1.2},
		},
	},
	[82] = {
		CashReward = 440,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[83] = {
		CashReward = 450,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- GiantGlassesRedToilet solo intro
	[84] = {
		CashReward = 460,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[85] = {
		CashReward = 470,
		UnlocksStartingWave = 80,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 8, DelayBetweenSpawns = 0.9},
			{Enemy = "GiantGlassesRedToilet",    Count = 3, DelayBetweenSpawns = 1.3},
		},
	},
	-- SpiderToilet solo intro
	[86] = {
		CashReward = 480,
		Enemies = {
			{Enemy = "SpiderToilet", Count = 3, DelayBetweenSpawns = 2.5},
		},
	},
	[87] = {
		CashReward = 490,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "GiantGlassesRedToilet",    Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "SpiderToilet",             Count = 1, DelayBetweenSpawns = 2.3},
		},
	},
	[88] = {
		CashReward = 500,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantGlassesRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "SpiderToilet",             Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	[89] = {
		CashReward = 510,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantGlassesRedToilet",    Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "SpiderToilet",             Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	-- InfectedTitanSpeakerman solo intro (milestone)
	[90] = {
		CashReward = 520,
		UnlocksStartingWave = 85,
		Enemies = {
			{Enemy = "InfectedTitanSpeakerman", Count = 3, DelayBetweenSpawns = 3.0},
		},
	},
	[91] = {
		CashReward = 460,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 3, DelayBetweenSpawns = 0.8},
			{Enemy = "GiantGlassesRedToilet",    Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "SpiderToilet",             Count = 4, DelayBetweenSpawns = 1.8},
			{Enemy = "InfectedTitanSpeakerman",  Count = 1, DelayBetweenSpawns = 2.8},
		},
	},
	[92] = {
		CashReward = 470,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 4, DelayBetweenSpawns = 0.7},
			{Enemy = "GiantGlassesRedToilet",    Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "SpiderToilet",             Count = 4, DelayBetweenSpawns = 1.5},
			{Enemy = "InfectedTitanSpeakerman",  Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[93] = {
		CashReward = 480,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet",   Count = 6, DelayBetweenSpawns = 0.8},
			{Enemy = "SpiderToilet",            Count = 5, DelayBetweenSpawns = 1.5},
			{Enemy = "InfectedTitanSpeakerman", Count = 2, DelayBetweenSpawns = 2.5},
		},
	},
	[94] = {
		CashReward = 490,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 3, DelayBetweenSpawns = 0.7},
			{Enemy = "GiantGlassesRedToilet",    Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "SpiderToilet",             Count = 5, DelayBetweenSpawns = 1.5},
			{Enemy = "InfectedTitanSpeakerman",  Count = 2, DelayBetweenSpawns = 2.3},
		},
	},
	[95] = {
		CashReward = 500,
		UnlocksStartingWave = 90,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet",   Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "SpiderToilet",            Count = 6, DelayBetweenSpawns = 1.3},
			{Enemy = "InfectedTitanSpeakerman", Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	[96] = {
		CashReward = 510,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 2, DelayBetweenSpawns = 0.7},
			{Enemy = "GiantGlassesRedToilet",    Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "SpiderToilet",             Count = 5, DelayBetweenSpawns = 1.3},
			{Enemy = "InfectedTitanSpeakerman",  Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	[97] = {
		CashReward = 520,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet",   Count = 4, DelayBetweenSpawns = 0.7},
			{Enemy = "SpiderToilet",            Count = 7, DelayBetweenSpawns = 1.2},
			{Enemy = "InfectedTitanSpeakerman", Count = 3, DelayBetweenSpawns = 1.8},
		},
	},
	[98] = {
		CashReward = 530,
		Enemies = {
			{Enemy = "GiantGlassesYellowToilet", Count = 2, DelayBetweenSpawns = 0.6},
			{Enemy = "GiantGlassesRedToilet",    Count = 4, DelayBetweenSpawns = 0.7},
			{Enemy = "SpiderToilet",             Count = 6, DelayBetweenSpawns = 1.2},
			{Enemy = "InfectedTitanSpeakerman",  Count = 3, DelayBetweenSpawns = 1.8},
		},
	},
	[99] = {
		CashReward = 540,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet",   Count = 3, DelayBetweenSpawns = 0.7},
			{Enemy = "SpiderToilet",            Count = 7, DelayBetweenSpawns = 1.1},
			{Enemy = "InfectedTitanSpeakerman", Count = 4, DelayBetweenSpawns = 1.5},
		},
	},
	[100] = {
		CashReward = 550,
		UnlocksStartingWave = 96,
		Enemies = {
			{Enemy = "GiantGlassesRedToilet",   Count = 2, DelayBetweenSpawns = 0.6},
			{Enemy = "SpiderToilet",            Count = 6, DelayBetweenSpawns = 1.1},
			{Enemy = "InfectedTitanSpeakerman", Count = 5, DelayBetweenSpawns = 1.5},
		},
	},

	-- ==========================================
	-- CYCLE 10 (Waves 101-110) - Planetary
	-- ==========================================
	[101] = {
		CashReward = 545,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 4, DelayBetweenSpawns = 1.3},
		},
	},
	[102] = {
		CashReward = 555,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 6, DelayBetweenSpawns = 1.1},
		},
	},
	[103] = {
		CashReward = 565,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 8, DelayBetweenSpawns = 1.0},
		},
	},
	-- UFOToilet solo intro
	[104] = {
		CashReward = 575,
		Enemies = {
			{Enemy = "UFOToilet", Count = 3, DelayBetweenSpawns = 1.5},
		},
	},
	[105] = {
		CashReward = 585,
		UnlocksStartingWave = 100,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "UFOToilet",              Count = 5, DelayBetweenSpawns = 1.3},
		},
	},
	-- RocketToilet solo intro
	[106] = {
		CashReward = 595,
		Enemies = {
			{Enemy = "RocketToilet", Count = 3, DelayBetweenSpawns = 2.5},
		},
	},
	[107] = {
		CashReward = 605,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "UFOToilet",              Count = 6, DelayBetweenSpawns = 1.1},
			{Enemy = "RocketToilet",           Count = 1, DelayBetweenSpawns = 2.3},
		},
	},
	[108] = {
		CashReward = 615,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "UFOToilet",              Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "RocketToilet",           Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	[109] = {
		CashReward = 625,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "UFOToilet",              Count = 6, DelayBetweenSpawns = 1.0},
			{Enemy = "RocketToilet",           Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	[110] = {
		CashReward = 640,
		UnlocksStartingWave = 105,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 4, DelayBetweenSpawns = 0.8},
			{Enemy = "UFOToilet",              Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "RocketToilet",           Count = 4, DelayBetweenSpawns = 1.8},
		},
	},

	-- ==========================================
	-- CYCLE 11 (Waves 111-120) - Galactic
	-- ==========================================
	-- StriderRocketToilet solo intro
	[111] = {
		CashReward = 650,
		Enemies = {
			{Enemy = "StriderRocketToilet", Count = 3, DelayBetweenSpawns = 2.5},
		},
	},
	[112] = {
		CashReward = 660,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 3, DelayBetweenSpawns = 0.7},
			{Enemy = "UFOToilet",              Count = 5, DelayBetweenSpawns = 0.9},
			{Enemy = "RocketToilet",           Count = 5, DelayBetweenSpawns = 1.5},
			{Enemy = "StriderRocketToilet",    Count = 2, DelayBetweenSpawns = 2.3},
		},
	},
	[113] = {
		CashReward = 670,
		Enemies = {
			{Enemy = "UFOToilet",           Count = 6, DelayBetweenSpawns = 0.9},
			{Enemy = "RocketToilet",        Count = 5, DelayBetweenSpawns = 1.5},
			{Enemy = "StriderRocketToilet", Count = 2, DelayBetweenSpawns = 2.3},
		},
	},
	[114] = {
		CashReward = 680,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 3, DelayBetweenSpawns = 0.7},
			{Enemy = "UFOToilet",              Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "RocketToilet",           Count = 5, DelayBetweenSpawns = 1.3},
			{Enemy = "StriderRocketToilet",    Count = 2, DelayBetweenSpawns = 2.0},
		},
	},
	[115] = {
		CashReward = 690,
		UnlocksStartingWave = 110,
		Enemies = {
			{Enemy = "UFOToilet",           Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "RocketToilet",        Count = 6, DelayBetweenSpawns = 1.3},
			{Enemy = "StriderRocketToilet", Count = 3, DelayBetweenSpawns = 2.0},
		},
	},
	[116] = {
		CashReward = 700,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 2, DelayBetweenSpawns = 0.7},
			{Enemy = "UFOToilet",              Count = 5, DelayBetweenSpawns = 0.8},
			{Enemy = "RocketToilet",           Count = 5, DelayBetweenSpawns = 1.2},
			{Enemy = "StriderRocketToilet",    Count = 3, DelayBetweenSpawns = 1.8},
		},
	},
	[117] = {
		CashReward = 710,
		Enemies = {
			{Enemy = "UFOToilet",           Count = 4, DelayBetweenSpawns = 0.7},
			{Enemy = "RocketToilet",        Count = 7, DelayBetweenSpawns = 1.1},
			{Enemy = "StriderRocketToilet", Count = 3, DelayBetweenSpawns = 1.8},
		},
	},
	[118] = {
		CashReward = 720,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 2, DelayBetweenSpawns = 0.6},
			{Enemy = "UFOToilet",              Count = 4, DelayBetweenSpawns = 0.7},
			{Enemy = "RocketToilet",           Count = 5, DelayBetweenSpawns = 1.1},
			{Enemy = "StriderRocketToilet",    Count = 4, DelayBetweenSpawns = 1.5},
		},
	},
	[119] = {
		CashReward = 730,
		Enemies = {
			{Enemy = "UFOToilet",           Count = 3, DelayBetweenSpawns = 0.7},
			{Enemy = "RocketToilet",        Count = 7, DelayBetweenSpawns = 1.0},
			{Enemy = "StriderRocketToilet", Count = 4, DelayBetweenSpawns = 1.5},
		},
	},
	[120] = {
		CashReward = 750,
		UnlocksStartingWave = 115,
		Enemies = {
			{Enemy = "QuadBladeStriderToilet", Count = 1, DelayBetweenSpawns = 0.6},
			{Enemy = "UFOToilet",              Count = 3, DelayBetweenSpawns = 0.6},
			{Enemy = "RocketToilet",           Count = 5, DelayBetweenSpawns = 1.0},
			{Enemy = "StriderRocketToilet",    Count = 6, DelayBetweenSpawns = 1.2},
		},
	},
}

return WaveConfigurations
