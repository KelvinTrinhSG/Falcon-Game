local RunService = game:GetService("RunService")
local unicorn = script.Parent

if not unicorn.PrimaryPart then
	warn("ERREUR : Le modèle '" .. unicorn.Name .. "' n'a pas de PrimaryPart défini !")
	return
end

local baseCFrame = unicorn:GetPivot()
local temps = 0

local HAUTEUR_SAUT = 1.5
local VITESSE_SAUT = 5
local ANGLE_PENCHEMENT = 15

RunService.Heartbeat:Connect(function(dt)
	temps = temps + dt
	local sautY = math.abs(math.sin(temps * VITESSE_SAUT)) * HAUTEUR_SAUT
	local penchementZ = math.sin(temps * (VITESSE_SAUT / 2)) * ANGLE_PENCHEMENT

	local nouvellePosition = baseCFrame 
		* CFrame.new(0, sautY, 0) 
		* CFrame.Angles(0, 0, math.rad(penchementZ))

	unicorn:PivotTo(nouvellePosition)
end)