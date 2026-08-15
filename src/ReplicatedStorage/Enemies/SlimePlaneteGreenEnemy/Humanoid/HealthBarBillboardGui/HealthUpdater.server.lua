local billboard = script.Parent
local bar = billboard:WaitForChild("Bar")
local hpText = billboard:WaitForChild("Hp")

-- On remonte pour trouver le modèle de l'ennemi et son Humanoid
-- BillboardGui -> HumanoidRootPart -> Modèle Ennemi
local character = billboard.Parent.Parent 
local humanoid = character:WaitForChild("Humanoid")

-- On sauvegarde la taille initiale de ta barre de vie (au cas où elle ne serait pas de {1,0}, {1,0})
local originalSize = bar.Size

local function updateHealth()
	-- On s'assure que la vie ne descend pas en dessous de 0
	local currentHealth = math.max(0, humanoid.Health)
	local maxHealth = humanoid.MaxHealth

	-- On calcule le pourcentage de vie restante (de 0 à 1)
	local healthPercent = currentHealth / maxHealth

	-- On réduit la taille horizontale (X) de la barre en fonction du pourcentage
	-- Utilise Scale pour que ça soit fluide
	bar.Size = UDim2.new(originalSize.X.Scale * healthPercent, originalSize.X.Offset * healthPercent, originalSize.Y.Scale, originalSize.Y.Offset)

	-- On met à jour le texte
	hpText.Text = math.floor(currentHealth) .. " / " .. math.floor(maxHealth)

	-- Optionnel : Cacher la barre si l'ennemi est full vie ou mort
	if currentHealth <= 0 then
		billboard.Enabled = false
	else
		billboard.Enabled = true
	end
end

-- On connecte la fonction pour qu'elle s'active à chaque fois que la vie change
humanoid.HealthChanged:Connect(updateHealth)

-- On l'appelle une fois au début pour afficher les bons HP dès le spawn
updateHealth()