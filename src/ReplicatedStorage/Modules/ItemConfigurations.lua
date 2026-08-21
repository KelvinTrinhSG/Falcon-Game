--#ReplicatedStorage>Modules>ItemConfigurations
local ItemConfigurations = {
	--BLOCKS
	RockBlock = {
		DisplayName = "Rock Block",
		Type = "Blocks",
		Price = 25,
		ImageId = "rbxassetid://136783950073385",
		ProductID = 3589301743,
		Unlimited = false,
		Chance = 100,
		StockAmount = {Min = 1, Max = 7},
		Health = 75,
	},

	ConcreteBlock = {
		DisplayName = "Concrete Block",
		Type = "Blocks",
		Price = 75,
		ImageId = "rbxassetid://114128595436055",
		ProductID = 3589300930,
		Unlimited = false,
		Chance = 90,
		StockAmount = {Min = 1, Max = 7},
		Health = 100,
	},

	IceBlock = {
		DisplayName = "Ice Block",
		Type = "Blocks",
		Price = 150,
		ImageId = "rbxassetid://103260168489888",
		ProductID = 3589302472,
		Unlimited = false,
		Chance = 80,
		StockAmount = {Min = 1, Max = 7},
		Health = 100,
	},

	FireBlock = {
		DisplayName = "Fire Block",
		Type = "Blocks",
		Price = 400,
		ImageId = "rbxassetid://77293299946865",
		ProductID = 3589304848,
		Unlimited = false,
		Chance = 70,
		StockAmount = {Min = 1, Max = 7},
		Health = 125,
	},

	LavaBlock = {
		DisplayName = "Lava Block",
		Type = "Blocks",
		Price = 750,
		ImageId = "rbxassetid://115988803054884",
		ProductID = 3589305738,
		Unlimited = false,
		Chance = 60,
		StockAmount = {Min = 1, Max = 7},
		Health = 150,
	},

	ToxicBlock = {
		DisplayName = "Toxic Block",
		Type = "Blocks",
		Price = 1200,
		ImageId = "rbxassetid://77307474711071",
		ProductID = 3589306249,
		Unlimited = false,
		Chance = 50,
		StockAmount = {Min = 1, Max = 7},
		Health = 200,
	},

	GoldBlock = {
		DisplayName = "Gold Block",
		Type = "Blocks",
		Price = 2000,
		ImageId = "rbxassetid://76880802576509",
		ProductID = 3589273650,
		Unlimited = false,
		Chance = 40,
		StockAmount = {Min = 1, Max = 7},
		Health = 300,
	},

	PlasmaBlock = {
		DisplayName = "Plasma Block",
		Type = "Blocks",
		Price = 3500,
		ImageId = "rbxassetid://116185531123879",
		ProductID = 3589274300,
		Unlimited = false,
		Chance = 35,
		StockAmount = {Min = 1, Max = 7},
		Health = 500,
	},

	CyberBlock = {
		DisplayName = "Cyber Block",
		Type = "Blocks",
		Price = 6000,
		ImageId = "rbxassetid://94711260291584",
		ProductID = 3589279102,
		Unlimited = false,
		Chance = 30,
		StockAmount = {Min = 1, Max = 7},
		Health = 700,
	},	

	TitanBlock = {
		DisplayName = "Titan Block",
		Type = "Blocks",
		Price = 10000,
		ImageId = "rbxassetid://129725207947239",
		ProductID = 3589307181,
		Unlimited = false,
		Chance = 25,
		StockAmount = {Min = 1, Max = 7},
		Health = 1000,
	},

	--TURRETS
	OldTurret = {
		DisplayName = "Old Turret",
		Type = "Turrets",
		Price = 200,
		ImageId = "rbxassetid://79863737566861",
		ProductID = 3495738970,
		Unlimited = false,
		Chance = 100,
		StockAmount = {Min = 1, Max = 5},
		Damage = 50,
		Range = 10, -- Réduit de 15 à 10
		FireRate = 1,
		Health = 5000000000,
	},

	ModernTurret = {
		DisplayName = "Modern Turret",
		Type = "Turrets",
		Price = 500,
		ImageId = "rbxassetid://134127163464424",
		ProductID = 3495739477,
		Unlimited = false,
		Chance = 90,
		StockAmount = {Min = 1, Max = 5},
		Damage = 100,
		Range = 12, -- Réduit de 13 à 12
		FireRate = 0.5, -- Corrigé ! (Ajuste selon ton script : 0.5 ou 1.5)
		Health = 5000000000,
	},

	LaserTurret = {
		DisplayName = "Laser Turret",
		Type = "Turrets",
		Price = 1000,
		ImageId = "rbxassetid://138810171314082",
		ProductID = 3495739902,
		Unlimited = false,
		Chance = 80,
		StockAmount = {Min = 1, Max = 5},
		Damage = 175,
		Range = 18, -- Réduit de 35 à 18
		FireRate = 2,
		Health = 5000000000,
	},

	ExtremeTurret = {
		DisplayName = "Extreme Turret",
		Type = "Turrets",
		Price = 2500,
		ImageId = "rbxassetid://120922630413741",
		ProductID = 3590647772,
		Unlimited = false,
		Chance = 70,
		StockAmount = {Min = 1, Max = 5},
		Damage = 250,
		Range = 20, -- Réduit de 37.5 à 20
		FireRate = 2,
		Health = 5000000000,
	},

	ToxicTurret = {
		DisplayName = "Toxic Turret",
		Type = "Turrets",
		Price = 4000,
		ImageId = "rbxassetid://79148208455816",
		ProductID = 3590648594,
		Unlimited = false,
		Chance = 60,
		StockAmount = {Min = 1, Max = 5},
		Damage = 400,
		Range = 16, -- Le Toxic demande souvent un placement rapproché
		FireRate = 2,
		Health = 5000000000,
	},

	BunkerTurret = {
		DisplayName = "Bunker Turret",
		Type = "Turrets",
		Price = 7000,
		ImageId = "rbxassetid://110368994158233",
		ProductID = 3590649081,
		Unlimited = false,
		Chance = 50,
		StockAmount = {Min = 1, Max = 5},
		Damage = 700,
		Range = 24, -- Portée d'artillerie correcte
		FireRate = 1,
		Health = 5000000000,
	},

	StarsTurret = {
		DisplayName = "Stars Turret",
		Type = "Turrets",
		Price = 15000,
		ImageId = "rbxassetid://90506924551302",
		ProductID = 3590649517,
		Unlimited = false,
		Chance = 40,
		StockAmount = {Min = 1, Max = 5},
		Damage = 1000,
		Range = 28, -- Réduit de 45 à 28
		FireRate = 2,
		Health = 5000000000,
	},
	PirateTurret = {
		DisplayName = "Pirate Turret",
		Type = "Turrets",
		Price = 30000,
		ImageId = "rbxassetid://104918083676404", 
		ProductID = 3595356576,
		Unlimited = false,
		Chance = 30,
		StockAmount = {Min = 1, Max = 5},
		Damage = 1500,
		Range = 30, 
		FireRate = 1,
		Health = 5000000000,
	},
	VikingTurret = {
		DisplayName = "Viking Turret",
		Type = "Turrets",
		Price = 60000,
		ImageId = "rbxassetid://107433289761116", 
		ProductID = 3595356717,
		Unlimited = false,
		Chance = 20,
		StockAmount = {Min = 1, Max = 5},
		Damage = 3000,
		Range = 35, 
		FireRate = 1,
		Health = 5000000000,
	},
}

local LimitedItems = {
	LavaTurret = {
		DisplayName = "Lava Turret",
		Type = "Turrets",
		ImageId = "rbxassetid://131940710641018",
		ProductID = 3589846329,
		Damage = 2500,
		Range = 40, -- Réduit de 45 à 30 (la meilleure du jeu)
		FireRate = 2,
		Health = 5000000000,
	}
}

return {
	LimitedItems = LimitedItems,
	ItemConfigurations = ItemConfigurations
}