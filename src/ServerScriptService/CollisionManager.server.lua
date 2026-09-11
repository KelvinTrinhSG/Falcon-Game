--!strict
-- LOCATION: ServerScriptService > CollisionManager

local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")

-- ==========================================
-- 1️⃣ CRÉATION DES GROUPES
-- ==========================================
-- On déclare nos deux groupes (au cas où ils n'existent pas encore)
pcall(function()
	PhysicsService:RegisterCollisionGroup("Zombies")
	PhysicsService:RegisterCollisionGroup("PlacedItems")
end)

-- ==========================================
-- 2️⃣ LA RÈGLE D'OR (L'anti-blocage)
-- ==========================================
-- On dit à Roblox : Les Zombies et les Objets Placés se traversent !
PhysicsService:CollisionGroupSetCollidable("Zombies", "PlacedItems", false)
-- Players cũng đi xuyên qua turret/block
PhysicsService:CollisionGroupSetCollidable("Players", "PlacedItems", false)

-- ==========================================
-- 3️⃣ APPLICATION AUTOMATIQUE
-- ==========================================
local plotsFolder = Workspace:WaitForChild("Plots")

-- Fonction qui met les tourelles/blocs dans le bon groupe
local function applyCollisionGroup(instance: Instance)
	if instance:IsA("Model") and instance:GetAttribute("IsPlacedItem") then

		-- On applique à toutes les pièces actuelles de l'objet
		for _, part in ipairs(instance:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CollisionGroup = "PlacedItems"
			end
		end

		-- On écoute si l'objet génère des nouvelles pièces (ex: balles, animations)
		instance.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.CollisionGroup = "PlacedItems"
			end
		end)
	end
end

-- On scanne les objets déjà posés au lancement du serveur
for _, descendant in ipairs(plotsFolder:GetDescendants()) do
	applyCollisionGroup(descendant)
end

-- On écoute en permanence chaque fois qu'un joueur pose une nouvelle tourelle/bloc
plotsFolder.DescendantAdded:Connect(applyCollisionGroup)

print("🛡️ CollisionManager : Slimes et Tourelles se traverseront sans se bloquer !")