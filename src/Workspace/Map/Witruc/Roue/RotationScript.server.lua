local RunService = game:GetService("RunService")

local roue = script.Parent

-- ⚙️ CONFIGURATION
local vitesse = 45 -- Change ce nombre pour le faire tourner plus ou moins vite

-- Boucle qui s'exécute en boucle de manière ultra fluide
RunService.Heartbeat:Connect(function(deltaTime)
	-- Calcul de l'angle de rotation (vitesse * temps écoulé)
	local angle = math.rad(vitesse * deltaTime)

	-- ⚠️ CHOIX DE L'AXE :
	-- Selon comment ton moulin est orienté dans ton monde, il faut choisir le bon axe.
	-- Essaie de changer la place de "angle" (X, Y ou Z) si ça tourne de travers !

	-- Actuellement réglé sur l'axe Z (0, 0, angle) :
	local rotation = CFrame.Angles(0, 0, angle)

	-- Applique la rotation autour du centre (Pivot) du modèle
	roue:PivotTo(roue:GetPivot() * rotation)
end)