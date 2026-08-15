--!strict
-- Located in: ReplicatedStorage/Modules/DamageHandler.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local HighlightZombie = ReplicatedStorage.Events:WaitForChild("HighlightZombie")

local DamageHandler = {}

function DamageHandler.dealDamage(source: Instance, target: Instance, damageAmount: number): boolean
	if not target or not target.Parent then return false end

	local humanoid = target:FindFirstChildOfClass("Humanoid")
	local healthAttribute = target:GetAttribute("Health")

	if humanoid then
		humanoid:TakeDamage(damageAmount)

		-- Only highlight if the target is still alive
		if humanoid.Health > 0 then
			HighlightZombie:FireAllClients(target)
		end

		return humanoid.Health <= 0

	elseif typeof(healthAttribute) == "number" then
		local newHealth = healthAttribute - damageAmount
		target:SetAttribute("Health", newHealth)

		if newHealth <= 0 then
			if target.Name ~= "PlotHealth" then
				target:Destroy()
			end
			return true
		end
	end

	return false
end

return DamageHandler