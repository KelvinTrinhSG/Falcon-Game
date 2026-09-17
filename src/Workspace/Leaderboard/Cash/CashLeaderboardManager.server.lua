local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- Crée la base de données spéciale pour le classement
local cashLeaderboard = DataStoreService:GetOrderedDataStore("CashLeaderboard_V1")

-- 1. CORRECTION DU CHEMIN (ScrollingFrame est à côté de Top)
local boardModel = script.Parent
local guiPart = boardModel:WaitForChild("GUIPart")
local leaderboardGUI = guiPart:WaitForChild("LeaderboardGUI")
local scrollingFrame = leaderboardGUI:WaitForChild("ScrollingFrame")

-- ==========================================
-- 💵 FONCTION POUR FORMATER L'ARGENT ($1K, $1M...)
-- ==========================================
local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi"}

local function formatCash(value)
	local index = 1
	while value >= 1000 and index < #suffixes do
		value = value / 1000
		index = index + 1
	end

	if index == 1 then
		return "$" .. tostring(math.floor(value))
	else
		-- Formate avec 1 chiffre après la virgule (ex: 1.5M) 
		-- Le gsub enlève le ".0" si c'est un chiffre rond (ex: 1.0K devient 1K)
		local formatted = string.format("%.1f", value):gsub("%.0$", "")
		return "$" .. formatted .. suffixes[index]
	end
end

-- ==========================================
-- 🔄 FONCTION DE MISE À JOUR DU PANNEAU
-- ==========================================
local function updateLeaderboard()
	local success, errorMessage = pcall(function()
		-- 2. ON DEMANDE MAINTENANT LE TOP 30 (au lieu de 10)
		local data = cashLeaderboard:GetSortedAsync(false, 30)
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
			local cashValue = entry.value

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

					-- ⚡ ON APPLIQUE LE FORMATAGE ICI
					frame.Value.Text = formatCash(cashValue)
				end
			end
		end
	end)

	if not success then
		warn("Erreur Leaderboard : ", errorMessage)
	end
end

-- ==========================================
-- 💾 SAUVEGARDER L'ARGENT POUR LE CLASSEMENT
-- ==========================================
local function savePlayerCash(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local cash = leaderstats and leaderstats:FindFirstChild("Cash")

	if cash then
		pcall(function()
			cashLeaderboard:SetAsync(tostring(player.UserId), cash.Value)
		end)
	end
end

Players.PlayerRemoving:Connect(savePlayerCash)

-- ==========================================
-- ⏱️ BOUCLE DE RAFRAÎCHISSEMENT (Toutes les 60s)
-- ==========================================
task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerCash(player)
		end

		updateLeaderboard()
		task.wait(60) 
	end
end)