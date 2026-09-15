--!strict
-- This module contains data for each enemy type.

local EnemyConfigurations = {
	-- ==========================================
	-- CYCLE 1 (Vagues 1 à 10) - Début de partie
	-- Conçu pour être géré par Old Turret (DPS ~50) et Modern Turret
	-- ==========================================
	["SmallYellowToilet"] = {
		CashReward = 3,
		MaxHealth = 100,
		Damage = 5,
		AttackCooldown = 1,
		WalkSpeed = 10,
		BaseDamage = 10,
	},
	["SmallRedToilet"] = {
		CashReward = 5,
		MaxHealth = 75,
		Damage = 3,
		AttackCooldown = 0.5,
		WalkSpeed = 25,
		BaseDamage = 12,
	},
	["LargeToilet"] = {
		CashReward = 7,
		MaxHealth = 500,
		Damage = 15,
		AttackCooldown = 2,
		WalkSpeed = 6,
		BaseDamage = 20,
	},

	-- ==========================================
	-- CYCLE 2 (Vagues 11 à 20) - Transition
	-- Conçu pour forcer l'achat de Laser Turret (175 Dmg)
	-- ==========================================
	["AssassinYellowToilet"] = {
		CashReward = 400,
		MaxHealth = 16000,
		Damage = 1200,
		AttackCooldown = 1,
		WalkSpeed = 10,
		BaseDamage = 100,
		IsStealthed = true,
	},
	["AssassinRedToilet"] = {
		CashReward = 700,
		MaxHealth = 12000,
		Damage = 720,
		AttackCooldown = 0.5,
		WalkSpeed = 25,
		BaseDamage = 110,
		IsStealthed = true,
	},
	["PoliceToilet"] = {
		CashReward = 1700,
		MaxHealth = 400000,
		Damage = 3600,
		AttackCooldown = 2,
		WalkSpeed = 6,
		BaseDamage = 120,
	},

	-- ==========================================
	-- CYCLE 3 (Vagues 21 à 30) - Mid Game
	-- Conçu pour Extreme Turret (250 Dmg) et Toxic (400 Dmg)
	-- ==========================================
	["GlassesYellowToilet"] = {
		CashReward = 400,
		MaxHealth = 80000,
		Damage = 1200,
		AttackCooldown = 1,
		WalkSpeed = 10,
		BaseDamage = 100,
	},
	["GlassesRedToilet"] = {
		CashReward = 700,
		MaxHealth = 60000,
		Damage = 720,
		AttackCooldown = 0.5,
		WalkSpeed = 25,
		BaseDamage = 110,
	},
	["GlitchToilet"] = {
		CashReward = 9,
		MaxHealth = 9000,
		Damage = 150,
		WalkSpeed = 12,
		BaseDamage = 60,
		ExplosionRadius = 6,
	},

	-- ==========================================
	-- CYCLE 4 (Vagues 31 à 40) - Late Game
	-- Conçu pour Bunker Turret (700 Dmg) et Stars (1000 Dmg)
	-- ==========================================
	["DJYellowToilet"] = {
		CashReward = 8500,
		MaxHealth = 128000,
		Damage = 5760,
		AttackCooldown = 1,
		WalkSpeed = 10,
		BaseDamage = 150,
		Summon = { Enemy = "HelicopterParasiteRedToilet", Count = 3, Cooldown = 8 },
	},
	["DJRedToilet"] = {
		CashReward = 14875,
		MaxHealth = 96000,
		Damage = 3456,
		AttackCooldown = 0.5,
		WalkSpeed = 25,
		BaseDamage = 160,
		Summon = { Enemy = "FlyingBuzzsawToilet", Count = 3, Cooldown = 6 },
	},
	["DualBladeToilet"] = {
		CashReward = 1700,
		MaxHealth = 80000,
		Damage = 3600,
		AttackCooldown = 2,
		WalkSpeed = 6,
		BaseDamage = 120,
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
		BaseDamage = 30,
	},
	["VacuumRedToilet"] = {
		CashReward = 14,
		MaxHealth = 1400,
		Damage = 80,
		WalkSpeed = 25,
		BaseDamage = 40,
	},
	["FlyingBuzzsawToilet"] = {
		CashReward = 850,
		MaxHealth = 40000,
		Damage = 720,
		AttackCooldown = 2,
		WalkSpeed = 6,
		BaseDamage = 70,
		IsFlying = true,
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
		BaseDamage = 35,
	},
	["DualBladeRedToilet"] = {
		CashReward = 17,
		MaxHealth = 2800,
		Damage = 70,
		WalkSpeed = 25,
		BaseDamage = 45,
	},
	["FlyingRocketLauncherToilet"] = {
		CashReward = 18,
		MaxHealth = 25000,
		Damage = 200,
		WalkSpeed = 10,
		BaseDamage = 70,
		IsFlying = true,
	},

	-- ==========================================
	-- CYCLE 7 (Vagues 61 à 70) - Thème Océan
	-- Tourelles recommandées : Stars (1000 Dmg) & Lava (2500 Dmg)
	-- ==========================================
	["HelicopterParasiteYellowToilet"] = {
		CashReward = 200,
		MaxHealth = 8000,
		Damage = 240,
		WalkSpeed = 10,
		BaseDamage = 50,
		IsFlying = true,
	},
	["HelicopterParasiteRedToilet"] = {
		CashReward = 350,
		MaxHealth = 6000,
		Damage = 144,
		WalkSpeed = 25,
		AttackCooldown = 0.5,
		BaseDamage = 60,
		IsFlying = true,
	},
	["LargePoliceToilet"] = {
		CashReward = 25,
		MaxHealth = 50000,
		Damage = 400,
		WalkSpeed = 8,
		BaseDamage = 80,
		ExplosionRadius = 10,
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
		BaseDamage = 50,
		IsFlying = true,
	},
	["LargeFlyingBuzzsawRedToilet"] = {
		CashReward = 22,
		MaxHealth = 8000,
		Damage = 250,
		WalkSpeed = 25,
		BaseDamage = 65,
		IsFlying = true,
	},
	["GiantDualBladeToilet"] = {
		CashReward = 23,
		MaxHealth = 60000,
		Damage = 350,
		WalkSpeed = 10,
		BaseDamage = 90,
	},

	-- ==========================================
	-- CYCLE 9 (Vagues 81 à 100) - L'enfer Végétal
	-- ==========================================
	["GiantGlassesYellowToilet"] = {
		CashReward = 24,
		MaxHealth = 30000,
		Damage = 200,
		WalkSpeed = 10,
		BaseDamage = 60,
	},
	["GiantGlassesRedToilet"] = {
		CashReward = 25,
		MaxHealth = 22000,
		Damage = 250,
		WalkSpeed = 25,
		BaseDamage = 75,
	},
	["SpiderToilet"] = {
		CashReward = 26,
		MaxHealth = 40000,
		Damage = 400,
		WalkSpeed = 14,
		BaseDamage = 85,
		ExplosionRadius = 8,
	},
	["InfectedTitanSpeakerman"] = {
		CashReward = 27,
		MaxHealth = 50000,
		Damage = 800,
		WalkSpeed = 10,
		BaseDamage = 100,
	},
	-- ==========================================
	-- CYCLE 10 (Vagues 101 à 120) - Nouveau plot univers
	-- ==========================================
	
	
	["QuadBladeStriderToilet"] = {
		CashReward = 28,
		MaxHealth = 60000,
		Damage = 900,
		WalkSpeed = 12,
		BaseDamage = 70,
	},
	["UFOToilet"] = {
		CashReward = 36125,
		MaxHealth = 640000,
		Damage = 17280,
		AttackCooldown = 2,
		WalkSpeed = 6,
		BaseDamage = 180,
		IsFlying = true,
	},
	["RocketToilet"] = {
		CashReward = 30,
		MaxHealth = 800000,
		Damage = 1100,
		WalkSpeed = 12,
		BaseDamage = 100,
		IsFlying = true,
	},
	["StriderRocketToilet"] = {
		CashReward = 31,
		MaxHealth = 900000,
		Damage = 1250,
		WalkSpeed = 10,
		BaseDamage = 120,
	},	
	
	
	-- ==========================================
	-- LES BOSS MAJEURS
	-- ==========================================
	["BossToilet"] = {
		CashReward = 1000,
		MaxHealth = 20000,
		Damage = 600,
		WalkSpeed = 4,
		BaseDamage = 200,
	},
	["BossToilet2"] = {
		CashReward = 3000,
		MaxHealth = 3200000,
		Damage = 144000,
		WalkSpeed = 4,
		BaseDamage = 1200,
	},
}

return EnemyConfigurations