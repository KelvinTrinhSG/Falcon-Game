--!strict
-- This module contains data for each enemy type.

local EnemyConfigurations = {
	-- ==========================================
	-- CYCLE 1 (Vagues 1 à 10) - Début de partie
	-- Conçu pour être géré par Old Turret (DPS ~50) et Modern Turret
	-- ==========================================
	["SmallYellowToilet"] = {
		CashReward = 1,
		MaxHealth = 60,
		Damage = 5,
		WalkSpeed = 10,
	},
	["SmallRedToilet"] = {
		CashReward = 2,
		MaxHealth = 35,
		Damage = 3,
		WalkSpeed = 15,
	},
	["LargeToilet"] = {
		CashReward = 3,
		MaxHealth = 250,
		Damage = 15,
		WalkSpeed = 8,
	},

	-- ==========================================
	-- CYCLE 2 (Vagues 11 à 20) - Transition
	-- Conçu pour forcer l'achat de Laser Turret (175 Dmg)
	-- ==========================================
	["AssassinYellowToilet"] = {
		CashReward = 4,
		MaxHealth = 180,
		Damage = 12,
		WalkSpeed = 10,
	},
	["AssassinRedToilet"] = {
		CashReward = 5,
		MaxHealth = 100,
		Damage = 8,
		WalkSpeed = 15,
	},
	["PoliceToilet"] = {
		CashReward = 6,
		MaxHealth = 650,
		Damage = 30,
		WalkSpeed = 9,
	},

	-- ==========================================
	-- CYCLE 3 (Vagues 21 à 30) - Mid Game
	-- Conçu pour Extreme Turret (250 Dmg) et Toxic (400 Dmg)
	-- ==========================================
	["GlassesYellowToilet"] = {
		CashReward = 7,
		MaxHealth = 450,
		Damage = 25,
		WalkSpeed = 11,
	},
	["GlassesRedToilet"] = {
		CashReward = 8,
		MaxHealth = 280,
		Damage = 18,
		WalkSpeed = 16,
	},
	["GlitchToilet"] = {
		CashReward = 9,
		MaxHealth = 1800,
		Damage = 50,
		WalkSpeed = 12,
	},

	-- ==========================================
	-- CYCLE 4 (Vagues 31 à 40) - Late Game
	-- Conçu pour Bunker Turret (700 Dmg) et Stars (1000 Dmg)
	-- ==========================================
	["DJYellowToilet"] = {
		CashReward = 10,
		MaxHealth = 1200,
		Damage = 45,
		WalkSpeed = 11,
	},
	["DJRedToilet"] = {
		CashReward = 11,
		MaxHealth = 850,
		Damage = 35,
		WalkSpeed = 17,
	},
	["DualBladeToilet"] = {
		CashReward = 12,
		MaxHealth = 8000,
		Damage = 120,
		WalkSpeed = 10,
	},

	-- ==========================================
	-- CYCLE 5 (Vagues 41 à 50) - Thème Nature
	-- Tourelles recommandées : Toxic (400 Dmg) & Bunker (700 Dmg)
	-- ==========================================
	["VacuumYellowToilet"] = {
		CashReward = 13,
		MaxHealth = 2000,
		Damage = 50,
		WalkSpeed = 11,
	},
	["VacuumRedToilet"] = {
		CashReward = 14,
		MaxHealth = 4500,
		Damage = 80,
		WalkSpeed = 17,
	},
	["FlyingBuzzsawToilet"] = {
		CashReward = 15,
		MaxHealth = 9000,
		Damage = 150,
		WalkSpeed = 12,
	},

	-- ==========================================
	-- CYCLE 6 (Vagues 51 à 60) - Thème Animaux
	-- Tourelles recommandées : Bunker (700 Dmg) & Stars (1000 Dmg)
	-- ==========================================
	["DualBladeYellowToilet"] = {
		CashReward = 16,
		MaxHealth = 3500,
		Damage = 90,
		WalkSpeed = 12,
	},
	["DualBladeRedToilet"] = {
		CashReward = 17,
		MaxHealth = 2800,
		Damage = 70,
		WalkSpeed = 18,
	},
	["FlyingRocketLauncherToilet"] = {
		CashReward = 18,
		MaxHealth = 25000,
		Damage = 200,
		WalkSpeed = 10,
	},

	-- ==========================================
	-- CYCLE 7 (Vagues 61 à 70) - Thème Océan
	-- Tourelles recommandées : Stars (1000 Dmg) & Lava (2500 Dmg)
	-- ==========================================
	["HelicopterParasiteYellowToilet"] = {
		CashReward = 19,
		MaxHealth = 6000,
		Damage = 120,
		WalkSpeed = 12,
	},
	["HelicopterParasiteRedToilet"] = {
		CashReward = 20,
		MaxHealth = 15000,
		Damage = 250,
		WalkSpeed = 19,
	},
	["LargePoliceToilet"] = {
		CashReward = 25,
		MaxHealth = 50000,
		Damage = 400,
		WalkSpeed = 8,
	},

	-- ==========================================
	-- CYCLE 8 (Vagues 71 à 80) - Thème Fruits/Légumes
	-- Tourelles recommandées : Stars (1000 Dmg) & Lava (2500 Dmg)
	-- ==========================================
	["LargeFlyingBuzzsawYellowToilet"] = {
		CashReward = 21,
		MaxHealth = 12000,
		Damage = 150,
		WalkSpeed = 9,
	},
	["LargeFlyingBuzzsawRedToilet"] = {
		CashReward = 22,
		MaxHealth = 25000,
		Damage = 250,
		WalkSpeed = 9,
	},
	["GiantDualBladeToilet"] = {
		CashReward = 23,
		MaxHealth = 60000,
		Damage = 350,
		WalkSpeed = 10,
	},

	-- ==========================================
	-- CYCLE 9 (Vagues 81 à 100) - L'enfer Végétal
	-- ==========================================
	["GiantGlassesYellowToilet"] = {
		CashReward = 24,
		MaxHealth = 30000,
		Damage = 200,
		WalkSpeed = 10,
	},
	["GiantGlassesRedToilet"] = {
		CashReward = 25,
		MaxHealth = 35000,
		Damage = 250,
		WalkSpeed = 10,
	},
	["SpiderToilet"] = {
		CashReward = 26,
		MaxHealth = 40000,
		Damage = 400,
		WalkSpeed = 14,
	},
	["InfectedTitanSpeakerman"] = {
		CashReward = 27,
		MaxHealth = 50000,
		Damage = 800,
		WalkSpeed = 10,
	},
	-- ==========================================
	-- CYCLE 10 (Vagues 101 à 120) - Nouveau plot univers
	-- ==========================================
	
	
	["QuadBladeStriderToilet"] = {
		CashReward = 28,
		MaxHealth = 60000,
		Damage = 900,
		WalkSpeed = 12,
	},
	["UFOToilet"] = {
		CashReward = 29,
		MaxHealth = 70000,
		Damage = 1000,
		WalkSpeed = 14,
	},
	["RocketToilet"] = {
		CashReward = 30,
		MaxHealth = 800000,
		Damage = 1100,
		WalkSpeed = 12,
	},
	["StriderRocketToilet"] = {
		CashReward = 31,
		MaxHealth = 900000,
		Damage = 1250,
		WalkSpeed = 10,
	},	
	
	
	-- ==========================================
	-- LES BOSS MAJEURS
	-- ==========================================
	["BossToilet"] = {
		CashReward = 50,
		MaxHealth = 35000,
		Damage = 200,
		WalkSpeed = 8,
	},
	["BossToilet2"] = {
		CashReward = 150,
		MaxHealth = 150000,
		Damage = 500,
		WalkSpeed = 8,
	},
}

return EnemyConfigurations