--!strict
-- This module contains data for all crates and weapons.

local WeaponConfigurations = {
	--RESTOCKS
	ShopProducts = {
		RestockBlocksShop = { ProductID = 3590907519}, -- Use your new DevProduct ID here
		RestockWeaponsShop = { ProductID = 3590907781}, -- Use your new DevProduct ID here
	},
	--CASH
	CashProducts = {
		Product1 = { ProductID = 3493289499, CashAmount = 5000 },
		Product2 = { ProductID = 3493290556, CashAmount = 20000 },
		Product3 = { ProductID = 3493290114, CashAmount = 75000 },
		Product4 = { ProductID = 3493290944, CashAmount = 250000 },
		Product5 = { ProductID = 3588689362, CashAmount = 1000000 },
	},
	--STARTER PACK
	StarterPack = {
		BeginnerPack = { 
			ProductID = 3588689957, 
			CashAmount = 5000, 
			TurretId = "ModernTurret" 
		},
	},
	--CRATES
	Crates = {
		--ROBUX
		GodCrate = {
			DisplayName = "GodCrate",
			ImageId = "rbxassetid://79655653446644",
			ProductID = 3493293425,
			Loot = {
				{Item = "PrismFang", Weight = 40},
				{Item = "SovereignSplitter", Weight = 35},
				{Item = "Crownbreaker", Weight = 10},
				{Item = "LightSword", Weight = 5},
			}
		},
		--SHOP
		WoodCrate = {
			DisplayName = "Wood Crate",
			Price = 600,
			ImageId = "rbxassetid://98370866657355",
			ProductID = 3493295534,
			SkipTimerProductID = 3590910161,
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
		MetalCrate = {
			DisplayName = "Metal Crate",
			Price = 4000,
			ImageId = "rbxassetid://75275480502344",
			ProductID = 3493297826,
			SkipTimerProductID = 3493295140,
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
		EarthCrate = {
			DisplayName = "Earth Crate",
			Price = 15000,
			ImageId = "rbxassetid://79965268850866",
			ProductID = 3493298349,
			SkipTimerProductID = 3590910686,
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
		WoodSword = { DisplayName = "Wood Sword", ImageId = "rbxassetid://126321981198719" }, -- 10
		--Wood
		StoneSword = { DisplayName = "Stone Sword", ImageId = "rbxassetid://98850338938642" }, -- 20
		ClassicSword = { DisplayName = "Classic Sword", ImageId = "rbxassetid://137083985660048" }, -- 35
		WhiteSword = { DisplayName = "WhiteSword", ImageId = "rbxassetid://107209992307667" }, -- 50
		--Metal
		BlueSword = { DisplayName = "Blue Sword", ImageId = "rbxassetid://106268955187746" }, -- 75
		IceSword = { DisplayName = "Ice Sword", ImageId = "rbxassetid://86285408542421" }, -- 100
		AzureSword = { DisplayName = "Azure Sword", ImageId = "rbxassetid://139447042654835" }, -- 150
		PinkSword = { DisplayName = "Pink Sword", ImageId = "rbxassetid://123160254672400" }, -- 200
		--Earth
		EasterSword = { DisplayName = "Easter Sword", ImageId = "rbxassetid://101114127129333" }, -- 300
		GemSword = { DisplayName = "GemSword", ImageId = "rbxassetid://122285053735268" }, -- 450
		PotOSword = { DisplayName = "Pot Sword", ImageId = "rbxassetid://108758775618579" }, -- 600
		EarthSword = { DisplayName = "Earth Sword", ImageId = "rbxassetid://73933794416777" }, -- 900
		--God
		PrismFang = { DisplayName = "Prism Fang", ImageId = "rbxassetid://138374599530188" }, -- 1500
		SovereignSplitter = { DisplayName = "Sovereign Splitter", ImageId = "rbxassetid://134644486162929" }, -- 2500
		Crownbreaker = { DisplayName = "Crown Breaker", ImageId = "rbxassetid://130895318777477" }, -- 4000
		LightSword = { DisplayName = "Light Sword", ImageId = "rbxassetid://131121345026857" }, -- 7000
	}
}

return WeaponConfigurations