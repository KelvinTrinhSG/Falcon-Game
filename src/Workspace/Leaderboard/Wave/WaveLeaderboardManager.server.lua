local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Crée une base de données spéciale pour les Vagues (nom différent de l'argent !)
local waveLeaderboard = DataStoreService:GetOrderedDataStore("WaveLeaderboard_V1")

-- Le chemin vers ton interface Wave
local boardModel = script.Parent
local guiPart = boardModel:WaitForChild("GUIPart")
local leaderboardGUI = guiPart:WaitForChild("LeaderboardGUI")
local scrollingFrame = leaderboardGUI:WaitForChild("ScrollingFrame")

-- ==========================================
-- 🔄 FONCTION DE MISE À JOUR DU PANNEAU
-- ==========================================
local function updateLeaderboard()
	local success, errorMessage = pcall(function()
		-- Récupère le Top 30 des plus hautes vagues
		local data = waveLeaderboard:GetSortedAsync(false, 30)
		local page = data:GetCurrentPage()

		-- On cache les 30 cases d'abord
		for i = 1, 30 do
			local placeFrame = scrollingFrame:FindFirstChild("Place_" .. i)
			if placeFrame then
				placeFrame.Visible = false
			end
		end

		-- On remplit avec les données
		for rank, entry in ipairs(page) do
			local userId = tonumber(entry.key)
			local waveValue = entry.value

			local placeFrame = scrollingFrame:FindFirstChild("Place_" .. rank)
			if placeFrame then
				placeFrame.Visible = true

				local numberLabel = placeFrame:FindFirstChild("NumberLabel")
				if numberLabel then
					numberLabel.Text = "#" .. rank
				end

				local frame = placeFrame:FindFirstChild("Frame")
				if frame then
					local username = "Joueur Inconnu"
					pcall(function()
						username = Players:GetNameFromUserIdAsync(userId)
					end)

					local headshot = "rbxasset://textures/ui/GuiImagePlaceholder.png"
					pcall(function()
						headshot = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
					end)

					frame.NamePlayerLeader.Text = username
					frame.AvatarPlayerLeader.Image = headshot

					-- On affiche juste le numéro de la vague (ex: 25)
					-- Si tu préfères afficher "Vague 25", remplace par : frame.Value.Text = "Wave " .. tostring(waveValue)
					frame.Value.Text = tostring(waveValue)
				end
			end
		end
	end)

	if not success then
		warn("Erreur Leaderboard Wave : ", errorMessage)
	end
end

-- ==========================================
-- 💾 SAUVEGARDER LA PLUS HAUTE VAGUE
-- ==========================================
local function savePlayerWave(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	-- Attention au nom exact ! Chez toi c'est "Highest Wave" avec un espace.
	local highestWave = leaderstats and leaderstats:FindFirstChild("Highest Wave")

	if highestWave then
		pcall(function()
			waveLeaderboard:SetAsync(tostring(player.UserId), highestWave.Value)
		end)
	end
end

Players.PlayerRemoving:Connect(savePlayerWave)

-- ==========================================
-- ⏱️ BOUCLE DE RAFRAÎCHISSEMENT (Toutes les 60s)
-- ==========================================
task.spawn(function()
	while true do
		-- On sauvegarde les joueurs actuellement en jeu
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerWave(player)
		end

		-- On met à jour l'affichage
		updateLeaderboard()

		task.wait(60) 
	end
end)