local RunService = game:GetService("RunService")

local zombie = script.Parent
local humanoid = zombie:WaitForChild("Humanoid")
local zombieRoot = zombie:WaitForChild("HumanoidRootPart")

-- On cherche le modèle de slime
local slimeModel = zombie:WaitForChild("Slime#4")
local slimeRoot = slimeModel:WaitForChild("RootPart")

-- 1. Nettoyage : On détruit les vieux WeldConstraints pour éviter les conflits
for _, child in ipairs(zombieRoot:GetChildren()) do
	if child:IsA("WeldConstraint") then
		child:Destroy()
	end
end

-- 2. Sécurité interne : On soude les yeux/bouche au corps du slime
for _, part in ipairs(slimeModel:GetDescendants()) do
	if part:IsA("BasePart") and part ~= slimeRoot then
		local internalWeld = Instance.new("WeldConstraint")
		internalWeld.Part0 = slimeRoot
		internalWeld.Part1 = part
		internalWeld.Parent = slimeRoot

		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
	end
end
slimeRoot.Anchored = false
slimeRoot.CanCollide = false
slimeRoot.Massless = true

-- 3. Attache Dynamique ET Respect de l'orientation originale
-- ## LA CORRECTION EST ICI ##
-- On mémorise la position et la rotation exacte que tu as définie dans Studio
local originalC0 = zombieRoot.CFrame:Inverse() * slimeRoot.CFrame

local weld = Instance.new("Weld")
weld.Part0 = zombieRoot
weld.Part1 = slimeRoot
weld.C0 = originalC0 -- On applique l'offset original (position + rotation)
weld.Parent = zombieRoot

-- 4. Animation : Les réglages du rebond
local bounceSpeed = 15 -- Vitesse
local bounceHeight = 1.5 -- Hauteur
local timeElapsed = 0

RunService.Heartbeat:Connect(function(deltaTime)
	if humanoid.Health <= 0 then return end

	-- Détection fiable de la vitesse réelle
	local currentSpeed = Vector3.new(zombieRoot.AssemblyLinearVelocity.X, 0, zombieRoot.AssemblyLinearVelocity.Z).Magnitude

	if currentSpeed > 0.5 then
		-- S'il avance
		timeElapsed += deltaTime
		local bounce = math.abs(math.sin(timeElapsed * bounceSpeed)) * bounceHeight
		-- On applique le rebond PAR-DESSUS la position originale respectée
		weld.C0 = originalC0 * CFrame.new(0, bounce, 0)
	else
		-- S'il est à l'arrêt
		timeElapsed = 0
		weld.C0 = weld.C0:Lerp(originalC0, 0.2)
	end
end)