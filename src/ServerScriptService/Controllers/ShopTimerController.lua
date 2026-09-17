--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PlayerController
local BlocksShopController
local WeaponsShopController
local BaseShopController
local TurretsShopController

local ShopTimerController = {}

local TIMER_CHECK_INTERVAL = 5
local timeSinceLastCheck = 0

function ShopTimerController:Init(controllers: {[string]: any})
	PlayerController = controllers.PlayerController
	BlocksShopController = controllers.BlocksShopController
	WeaponsShopController = controllers.WeaponsShopController
	BaseShopController = controllers.BaseShopController
	TurretsShopController = controllers.TurretsShopController
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
					BlocksShopController:Restock(player)
				end

				-- Check Weapons Shop timer
				if currentTime >= profile.Data.WeaponShopNextRestock then
					WeaponsShopController:Restock(player)
				end

				-- Check Bases Shop timer
				if currentTime >= profile.Data.BaseShopNextRestock then
					BaseShopController:Restock(player)
				end

				-- Check Turrets Shop timer
				if currentTime >= (profile.Data.TurretsShopNextRestock or 0) then
					TurretsShopController:Restock(player)
				end
			end
		end
	end)
end

return ShopTimerController