--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerController
local BlocksShopController
local WeaponsShopController

local ShopTimerController = {}

local TIMER_CHECK_INTERVAL = 5
local timeSinceLastCheck = 0

function ShopTimerController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	BlocksShopController = controllers.BlocksShopController
	WeaponsShopController = controllers.WeaponsShopController
end

function ShopTimerController:Start()
	RunService.Heartbeat:Connect(function(dt)
		timeSinceLastCheck += dt
		if timeSinceLastCheck < TIMER_CHECK_INTERVAL then
			return
		end
		timeSinceLastCheck = 0

		for _, player in ipairs(Players:GetPlayers()) do
			local profile = PlayerController:GetProfile(player)
			if profile then
				local currentTime = os.time()

				-- Check Blocks Shop timer
				if currentTime >= profile.Data.BlockShopNextRestock then
					print(`Player {player.Name}'s Blocks Shop is restocking automatically.`)
					BlocksShopController:Restock(player)
				end

				-- Check Weapons Shop timer
				if currentTime >= profile.Data.WeaponShopNextRestock then
					print(`Player {player.Name}'s Weapons Shop is restocking automatically.`)
					WeaponsShopController:Restock(player)
				end
			end
		end
	end)
end

return ShopTimerController