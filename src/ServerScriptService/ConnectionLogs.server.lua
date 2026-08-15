local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- ⚡ L'URL de ton Webhook modifiée avec le Proxy pour éviter le blocage de Discord
local WEBHOOK_URL = "https://webhook.lewisakura.moe/api/webhooks/1504140071702368270/d_OPrY9IAfbrsPJSoFLPS6n4nAaaGlrt9isLs6PPOQx2X9hhobGeT9e5ZwIWUVbhdrSt"

-- Tableau pour mémoriser à quelle heure chaque joueur s'est connecté
local joinTimes = {}

-- Petite fonction pour transformer les secondes en Heures, Minutes, Secondes
local function formatPlaytime(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60

	if h > 0 then
		return string.format("%d heure(s), %d minute(s) et %d seconde(s)", h, m, s)
	elseif m > 0 then
		return string.format("%d minute(s) et %d seconde(s)", m, s)
	else
		return string.format("%d seconde(s)", s)
	end
end

-- Fonction qui envoie le message à Discord
local function sendToDiscord(message)
	local data = {
		["content"] = message
	}

	-- On convertit en JSON pour que Discord comprenne
	local jsonData = HttpService:JSONEncode(data)

	-- On envoie avec un pcall pour éviter de faire planter le jeu si Discord a un bug
	pcall(function()
		HttpService:PostAsync(WEBHOOK_URL, jsonData)
	end)
end

-- ==========================================
-- 🟢 QUAND UN JOUEUR REJOINT
-- ==========================================
Players.PlayerAdded:Connect(function(player)
	-- On enregistre l'heure exacte à laquelle il arrive
	joinTimes[player.UserId] = os.time()

	-- On compte combien ils sont (le wait(1) laisse le temps au joueur de charger)
	task.wait(1)
	local playerCount = #Players:GetPlayers()

	-- On récupère l'ID du serveur (Roblox ne donne pas 1,2,3 mais un grand code. On prend juste les 6 premiers caractères pour que ce soit propre).
	local serverId = game.JobId ~= "" and string.sub(game.JobId, 1, 6) or "Studio"

	local message = string.format("🟢 Le joueur **%s** a rejoint le serveur **%s** et ils sont maintenant **%d** sur le serveur.", player.Name, serverId, playerCount)
	sendToDiscord(message)
end)

-- ==========================================
-- 🔴 QUAND UN JOUEUR QUITTE
-- ==========================================
Players.PlayerRemoving:Connect(function(player)
	-- On calcule le temps passé
	local joinedAt = joinTimes[player.UserId] or os.time()
	local playedTime = os.time() - joinedAt

	-- On nettoie la mémoire
	joinTimes[player.UserId] = nil

	local timeString = formatPlaytime(playedTime)

	local message = string.format("🔴 Le joueur **%s** a quitté, il a joué pendant **%s**.", player.Name, timeString)
	sendToDiscord(message)
end)