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
	-- Order: CameraGuy > EngineerCameraGuy > SpeakerGuy > TvGuy > NinjaCameraGuy
	--        > LargeScientistCameraman > LargeSpeakerGuy > LargeTvGuy > LaserCameramanCar > TitanCameraGuy
	CameraGuy = {
		DisplayName = "Camera Guy",
		Type = "Turrets",
		Price = 200,
		ImageId = "rbxassetid://87434168468506",
		ProductID = 3710656644,
		Unlimited = false,
		Chance = 100,
		StockAmount = {Min = 1, Max = 5},
		Damage = 50,
		Range = 10,
		FireRate = 1,
		Health = 5000000000,
	},

	EngineerCameraGuy = {
		DisplayName = "Engineer Camera Guy",
		Type = "Turrets",
		Price = 500,
		ImageId = "rbxassetid://127153357548293",
		ProductID = 3710656704,
		Unlimited = false,
		Chance = 90,
		StockAmount = {Min = 1, Max = 5},
		Damage = 100,
		Range = 12,
		FireRate = 0.5,
		Health = 5000000000,
	},

	SpeakerGuy = {
		DisplayName = "Speaker Guy",
		Type = "Turrets",
		Price = 1000,
		ImageId = "rbxassetid://95942695589812",
		ProductID = 3710656746,
		Unlimited = false,
		Chance = 80,
		StockAmount = {Min = 1, Max = 5},
		Damage = 175,
		Range = 18,
		FireRate = 2,
		Health = 5000000000,
	},

	TvGuy = {
		DisplayName = "TV Guy",
		Type = "Turrets",
		Price = 2500,
		ImageId = "rbxassetid://86656983607357",
		ProductID = 3710656794,
		Unlimited = false,
		Chance = 70,
		StockAmount = {Min = 1, Max = 5},
		Damage = 250,
		Range = 20,
		FireRate = 2,
		Health = 5000000000,
	},

	NinjaCameraGuy = {
		DisplayName = "Ninja Camera Guy",
		Type = "Turrets",
		Price = 4000,
		ImageId = "rbxassetid://135155583396631",
		ProductID = 3710656837,
		Unlimited = false,
		Chance = 60,
		StockAmount = {Min = 1, Max = 5},
		Damage = 400,
		Range = 16,
		FireRate = 2,
		Health = 5000000000,
	},

	LargeScientistCameraman = {
		DisplayName = "Large Scientist Cameraman",
		Type = "Turrets",
		Price = 7000,
		ImageId = "rbxassetid://111983598950365",
		ProductID = 3710656883,
		Unlimited = false,
		Chance = 50,
		StockAmount = {Min = 1, Max = 5},
		Damage = 700,
		Range = 24,
		FireRate = 1,
		Health = 5000000000,
	},

	LargeSpeakerGuy = {
		DisplayName = "Large Speaker Guy",
		Type = "Turrets",
		Price = 15000,
		ImageId = "rbxassetid://127572002232247",
		ProductID = 3710656915,
		Unlimited = false,
		Chance = 40,
		StockAmount = {Min = 1, Max = 5},
		Damage = 1000,
		Range = 28,
		FireRate = 2,
		Health = 5000000000,
	},

	LargeTvGuy = {
		DisplayName = "Large TV Guy",
		Type = "Turrets",
		Price = 30000,
		ImageId = "rbxassetid://134355068425451",
		ProductID = 3710656961,
		Unlimited = false,
		Chance = 30,
		StockAmount = {Min = 1, Max = 5},
		Damage = 1500,
		Range = 30,
		FireRate = 1,
		Health = 5000000000,
	},

	LaserCameramanCar = {
		DisplayName = "Laser Cameraman Car",
		Type = "Turrets",
		Price = 60000,
		ImageId = "rbxassetid://140634982638027",
		ProductID = 3710657003,
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
	TitanCameraGuy = {
		DisplayName = "Titan Camera Guy",
		Type = "Turrets",
		ImageId = "rbxassetid://121254234742118",
		ProductID = 3710657047,
		Damage = 2500,
		Range = 40, -- Réduit de 45 à 30 (la meilleure du jeu)
		FireRate = 2,
		Health = 5000000000,
	}
}

local BaseConfigurations = {
	Core1 = { DisplayName = "Camera Post",    Price = 0,     Health = 100 },
	Core2 = { DisplayName = "Speaker Station", Price = 2000,  Health = 150 },
	Core3 = { DisplayName = "Broadcast Tower", Price = 10000, Health = 250 },
	Core4 = { DisplayName = "Signal Fortress", Price = 25000, Health = 400 },
	Core5 = { DisplayName = "Titan Dominion",  Price = 60000, Health = 600 },
}

return {
	LimitedItems = LimitedItems,
	ItemConfigurations = ItemConfigurations,
	BaseConfigurations = BaseConfigurations
}