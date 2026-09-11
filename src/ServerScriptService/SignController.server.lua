--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local function setupSignForPlot(plot)
	local ownerSign = plot:FindFirstChild("OwnerSign")
	if not ownerSign then return end

	local screen = ownerSign:FindFirstChild("Screen")
	local surfaceGui = screen and screen:FindFirstChild("SurfaceGui")
	local frame = surfaceGui and surfaceGui:FindFirstChild("Frame")

	if not frame then 
		warn("Structure de la pancarte manquante dans " .. plot.Name)
		return 
	end

	local icon = frame:FindFirstChild("Icon", true)
	local nameText = frame:FindFirstChild("Count", true) 

	local function updateDisplay()
		local ownerId = plot:GetAttribute("OwnerId")

		if ownerId and ownerId > 0 then
			-- 1. NOM DU JOUEUR
			local successName, username = pcall(function()
				return Players:GetNameFromUserIdAsync(ownerId)
			end)

			if nameText then
				nameText.Text = successName and username or "Joueur " .. tostring(ownerId)
			end

			-- 2. PHOTO DE PROFIL
			local successImg, image = pcall(function()
				return Players:GetUserThumbnailAsync(ownerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)

			if icon then
				if successImg and image then
					icon.Image = image
				else
					warn("Impossible de charger l'image pour l'ID: " .. tostring(ownerId))
					icon.Image = "rbxassetid://15419830" 
				end
			end

		elseif ownerId and ownerId < 0 then
			-- CAS SPÉCIAL : Test Studio (ID négatif)
			if nameText then nameText.Text = "Mode Test" end
			if icon then icon.Image = "rbxassetid://15419830" end
		else
			-- LIBRE
			if nameText then nameText.Text = "Libre" end
			if icon then icon.Image = "" end 
		end
	end

	-- On écoute les changements
	plot:GetAttributeChangedSignal("OwnerId"):Connect(updateDisplay)
	-- On met à jour directement à la création
	updateDisplay()
end

local plotsFolder = Workspace:WaitForChild("Plots")

-- 1. On configure les terrains qui sont DÉJÀ là au lancement du jeu (Les terrains normaux)
for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("Model") then
		setupSignForPlot(plot)
	end
end

-- ==========================================================
-- ⚡ LA CORRECTION : Détecter les V2 qui spawnent en cours de route
-- ==========================================================
plotsFolder.ChildAdded:Connect(function(child)
	if child:IsA("Model") and string.find(child.Name, "Plot") then
		setupSignForPlot(child)
	end
end)