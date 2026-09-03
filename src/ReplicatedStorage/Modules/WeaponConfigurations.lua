--!strict
-- This module contains data for all crates and weapons.

local WeaponConfigurations = {
	--RESTOCKS
	ShopProducts = {
		RestockBasesShop = { ProductID = 3710668336 },
		RestockBlocksShop = { ProductID = 3710668255 },
		RestockTurretsShop = { ProductID = 3710668801 },
		RestockWeaponsShop = { ProductID = 3710668368 },
	},
	--CASH
	CashProducts = {
		Product1 = { ProductID = 3710671477, CashAmount = 1000 },
		Product2 = { ProductID = 3710671545, CashAmount = 5000 },
		Product3 = { ProductID = 3710671583, CashAmount = 25000 },
		Product4 = { ProductID = 3710671617, CashAmount = 100000 },
		Product5 = { ProductID = 3710671649, CashAmount = 250000 },
	},
	--STARTER PACK
	StarterPack = {
		BeginnerPack = { 
			ProductID = 3588689957, 
			CashAmount = 5000, 
			TurretId = "EngineerCameraGuy"
		},
	},
	--CRATES
	Crates = {
		--ROBUX
		TitanCrate = {
			DisplayName = "Titan Crate",
			ImageId = "rbxassetid://120439578077918",
			ProductID = 3710659624,
			Loot = {
				{Item = "PrismFang", Weight = 40},
				{Item = "SovereignSplitter", Weight = 35},
				{Item = "Crownbreaker", Weight = 10},
				{Item = "LightSword", Weight = 5},
			}
		},
		--SHOP
		BasicCrate = {
			DisplayName = "Basic Crate",
			Price = 600,
			ImageId = "rbxassetid://139710725000541",
			ProductID = 3710659532,
			SkipTimerProductID = 3710659838,
			Unlimited = false,
			Chance = 100,
			StockAmount = {Min = 1, Max = 5},
			UnlockTime = 60,
			Loot = {
				{Item = "StoneSword", Weight = 40},
				{Item = "ClassicSword", Weight = 25},
				{Item = "WhiteSword", Weight = 10},
			}
		},
		CameraCrate = {
			DisplayName = "Camera Crate",
			Price = 4000,
			ImageId = "rbxassetid://73525180630420",
			ProductID = 3710659561,
			SkipTimerProductID = 3710659872,
			Unlimited = false,
			Chance = 100,
			StockAmount = {Min = 1, Max = 4},
			UnlockTime = 300,
			Loot = {
				{Item = "BlueSword", Weight = 40},
				{Item = "IceSword", Weight = 30},
				{Item = "AzureSword", Weight = 15},
				{Item = "PinkSword", Weight = 5},
			}
		},
		SpeakerCrate = {
			DisplayName = "Speaker Crate",
			Price = 15000,
			ImageId = "rbxassetid://73742143095642",
			ProductID = 3710659593,
			SkipTimerProductID = 3710659904,
			Unlimited = false,
			Chance = 100,
			StockAmount = {Min = 1, Max = 3},
			UnlockTime = 900,
			Loot = {
				{Item = "EasterSword", Weight = 40},
				{Item = "GemSword", Weight = 30},
				{Item = "PotOSword", Weight = 20},
				{Item = "EarthSword", Weight = 10},
			}
		},
	},

	Weapons = {
		--Starter
		WoodSword = { DisplayName = "Simple Plunger", ImageId = "rbxassetid://79610656590032" }, -- 10
		--Wood
		StoneSword = { DisplayName = "Upgraded Plunger", ImageId = "rbxassetid://117547325913450" }, -- 20
		ClassicSword = { DisplayName = "Spike Plunger", ImageId = "rbxassetid://81886121617790" }, -- 35
		WhiteSword = { DisplayName = "Blue Sword", ImageId = "rbxassetid://90226630787229" }, -- 50
		--Metal
		BlueSword = { DisplayName = "White Sword", ImageId = "rbxassetid://139852795392041" }, -- 75
		IceSword = { DisplayName = "Red Sword", ImageId = "rbxassetid://116078406754070" }, -- 100
		AzureSword = { DisplayName = "Blue Cross Sword", ImageId = "rbxassetid://118698605379620" }, -- 150
		PinkSword = { DisplayName = "Pink Cross Sword", ImageId = "rbxassetid://81210037074644" }, -- 200
		--Earth
		EasterSword = { DisplayName = "Red Cross Sword", ImageId = "rbxassetid://125491454519337" }, -- 300
		GemSword = { DisplayName = "Eviscerator Axe", ImageId = "rbxassetid://104646480564542" }, -- 450
		PotOSword = { DisplayName = "Chain Sword", ImageId = "rbxassetid://121357990994950" }, -- 600
		EarthSword = { DisplayName = "Agent Katana", ImageId = "rbxassetid://125658051215157" }, -- 900
		--God
		PrismFang = { DisplayName = "Energized Arm Blade", ImageId = "rbxassetid://98454166948595" }, -- 1500
		SovereignSplitter = { DisplayName = "TV Man Sword", ImageId = "rbxassetid://112933347863376" }, -- 2500
		Crownbreaker = { DisplayName = "Mechanical Hammer", ImageId = "rbxassetid://92354199611433" }, -- 4000
		LightSword = { DisplayName = "Crescent Rose", ImageId = "rbxassetid://72717771975412" }, -- 7000
	}
}

return WeaponConfigurations