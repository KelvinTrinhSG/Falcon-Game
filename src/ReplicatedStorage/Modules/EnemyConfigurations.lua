--!strict
-- This module contains data for each enemy type.

local EnemyConfigurations = {
	-- ==========================================
	-- CYCLE 1 (Vagues 1 à 10) - Début de partie
	-- Conçu pour être géré par Old Turret (DPS ~50) et Modern Turret
	-- ==========================================
	["SmallYellowToilet"] = {
		CashReward = 1,
		MaxHealth = 60, -- 2 tirs de Old Turret, ou 1 tir presque fatal de Modern Turret
		Damage = 5,     -- Il faut 10 coups pour casser un Cardboard Block
	},
	["SmallRedToilet"] = {
		CashReward = 2,
		MaxHealth = 35, -- Fragile mais rapide, meurt en 1 tir de Old Turret
		Damage = 3,
	},
	["LargeToilet"] = {
		CashReward = 3,
		MaxHealth = 250, -- Le premier tank. Résiste à 5 tirs de Old Turret
		Damage = 15,     -- Dangereux pour les petits blocs
	},

	-- ==========================================
	-- CYCLE 2 (Vagues 11 à 20) - Transition
	-- Conçu pour forcer l'achat de Laser Turret (175 Dmg)
	-- ==========================================
	["AssassinYellowToilet"] = {
		CashReward = 4,
		MaxHealth = 180, -- Le Laser Turret le tue presque en un coup
		Damage = 12,
	},
	["AssassinRedToilet"] = {
		CashReward = 5,
		MaxHealth = 100, -- L'équivalent du Fast, mais plus résistant
		Damage = 8,
	},
	["PoliceToilet"] = {
		CashReward = 6,
		MaxHealth = 650, -- Gros tank du cycle 2
		Damage = 30,     -- Commence à bien entamer le Steel/Plate Block
	},

	-- ==========================================
	-- CYCLE 3 (Vagues 21 à 30) - Mid Game
	-- Conçu pour Extreme Turret (250 Dmg) et Toxic (400 Dmg)
	-- ==========================================
	["GlassesYellowToilet"] = {
		CashReward = 7,
		MaxHealth = 450, -- Un tir de Toxic Turret ou 2 de Extreme
		Damage = 25,
	},
	["GlassesRedToilet"] = {
		CashReward = 8,
		MaxHealth = 280, -- L'ennemi rapide du cycle 3
		Damage = 18,
	},
	["GlitchToilet"] = {
		CashReward = 9,
		MaxHealth = 1800, -- Un vrai cauchemar sans bonnes tourelles
		Damage = 50,      -- Détruit le Cardboard instantanément, menace le Concrete Block
	},

	-- ==========================================
	-- CYCLE 4 (Vagues 31 à 40) - Late Game
	-- Conçu pour Bunker Turret (700 Dmg) et Stars (1000 Dmg)
	-- ==========================================
	["DJYellowToilet"] = {
		CashReward = 10,
		MaxHealth = 1200, -- Le standard de fin de partie
		Damage = 45,
	},
	["DJRedToilet"] = {
		CashReward = 11,
		MaxHealth = 850, -- L'ennemi rapide très coriace
		Damage = 35,
	},
	["DualBladeToilet"] = {
		CashReward = 12,
		MaxHealth = 8000, -- Le Boss final absolu. Nécessite beaucoup de puissance de feu.
		Damage = 120,     -- Brise très vite les murs, même le Netherite/Lava
	},

	-- ==========================================
	-- CYCLE 5 (Vagues 41 à 50) - Thème Nature
	-- Tourelles recommandées : Toxic (400 Dmg) & Bunker (700 Dmg)
	-- ==========================================
	["VacuumYellowToilet"] = {
		CashReward = 13,
		MaxHealth = 2000,
		Damage = 50,
	},
	["VacuumRedToilet"] = {
		CashReward = 14,
		MaxHealth = 4500, -- Très résistant, comme un arbre
		Damage = 80,
	},
	["FlyingBuzzsawToilet"] = {
		CashReward = 15,
		MaxHealth = 9000, -- Boss du cycle Nature
		Damage = 150,      -- Pique très fort, détruit le Concrete Block rapidement
	},

	-- ==========================================
	-- CYCLE 6 (Vagues 51 à 60) - Thème Animaux
	-- Tourelles recommandées : Bunker (700 Dmg) & Stars (1000 Dmg)
	-- ==========================================
	["DualBladeYellowToilet"] = {
		CashReward = 16,
		MaxHealth = 3500, -- Charge avec pas mal de PV
		Damage = 90,
	},
	["DualBladeRedToilet"] = {
		CashReward = 17,
		MaxHealth = 2800, -- Un peu moins de PV mais censé être rapide
		Damage = 70,
	},
	["FlyingRocketLauncherToilet"] = {
		CashReward = 18,
		MaxHealth = 25000, -- Le Boss Canard Géant ! Un vrai tank
		Damage = 200,      -- Très dangereux pour les murs
	},

	-- ==========================================
	-- CYCLE 7 (Vagues 61 à 70) - Thème Océan
	-- Tourelles recommandées : Stars (1000 Dmg) & Lava (2500 Dmg)
	-- ==========================================
	["HelicopterParasiteYellowToilet"] = {
		CashReward = 19,
		MaxHealth = 6000, 
		Damage = 120,
	},
	["HelicopterParasiteRedToilet"] = {
		CashReward = 20,
		MaxHealth = 15000, -- Un mastodonte des mers
		Damage = 250,      -- Brise le Netherite en 2 coups
	},
	["LargePoliceToilet"] = {
		CashReward = 25,
		MaxHealth = 50000, -- Le Boss Suprême des Slimes (Vague 70)
		Damage = 400,      -- One-shot quasiment tous les murs sauf la Lava
	},

	-- ==========================================
	-- CYCLE 8 (Vagues 71 à 80) - Thème Fruits/Légumes
	-- Tourelles recommandées : Stars (1000 Dmg) & Lava (2500 Dmg)
	-- ==========================================
	["LargeFlyingBuzzsawYellowToilet"] = {
		CashReward = 21,
		MaxHealth = 12000, 
		Damage = 150,
	},
	["LargeFlyingBuzzsawRedToilet"] = {
		CashReward = 22,
		MaxHealth = 25000, -- Plus lent mais très tanky
		Damage = 250,
	},
	["GiantDualBladeToilet"] = {
		CashReward = 23,
		MaxHealth = 60000, -- Le mini-boss pastèque, énorme sac à PV
		Damage = 350,
	},

	-- ==========================================
	-- CYCLE 9 (Vagues 81 à 100) - L'enfer Végétal
	-- ==========================================
	["GiantGlassesYellowToilet"] = {
		CashReward = 24,
		MaxHealth = 30000, 
		Damage = 200,
	},
	["GiantGlassesRedToilet"] = {
		CashReward = 25,
		MaxHealth = 35000,
		Damage = 250,
	},
	["SpiderToilet"] = {
		CashReward = 26,
		MaxHealth = 40000,
		Damage = 400,
	},

	["InfectedTitanSpeakerman"] = {
		CashReward = 27,
		MaxHealth = 50000, 
		Damage = 800,       
	},
	-- ==========================================
	-- CYCLE 10 (Vagues 101 à 120) - Nouveau plot univers
	-- ==========================================
	
	
	["QuadBladeStriderToilet"] = {
		CashReward = 28,
		MaxHealth = 60000,
		Damage = 900,
	},
	["UFOToilet"] = {
		CashReward = 29,
		MaxHealth = 70000,
		Damage = 1000,
	},
	["RocketToilet"] = {
		CashReward = 30,
		MaxHealth = 800000,
		Damage = 1100,
	},
	["StriderRocketToilet"] = {
		CashReward = 31,
		MaxHealth = 900000,
		Damage = 1250,
	},	
	
	
	-- ==========================================
	-- LES BOSS MAJEURS
	-- ==========================================
	["BossToilet"] = {
		CashReward = 50,
		MaxHealth = 35000, -- Très résistant, requiert Bunker/Stars Turret (Vague 40)
		Damage = 200,      -- Détruira très vite les blocs moyens
	},
	["BossToilet2"] = {
		CashReward = 150,
		MaxHealth = 150000, -- Un véritable titan pour la vague 80 (nécessite Lava/Stars Turrets)
		Damage = 500,       -- Détruit n'importe quel bloc quasi instantanément, sauf le Lava Block
	},
}

return EnemyConfigurations