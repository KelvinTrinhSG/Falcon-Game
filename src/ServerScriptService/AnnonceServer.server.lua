local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalMessageEvent = ReplicatedStorage:FindFirstChild("GlobalMessageEvent")
if not GlobalMessageEvent then
	GlobalMessageEvent = Instance.new("RemoteEvent")
	GlobalMessageEvent.Name = "GlobalMessageEvent"
	GlobalMessageEvent.Parent = ReplicatedStorage
end

local NOM_DU_CANAL = "AnnonceGlobale"
local ADMIN_IDS = { 8912812154 } -- Ton ID

local function isAdmin(player)
	for _, id in ipairs(ADMIN_IDS) do
		if player.UserId == id then return true end
	end
	return false
end

-- Réception de l'annonce depuis MessagingService
MessagingService:SubscribeAsync(NOM_DU_CANAL, function(message)
	-- On envoie les données du tableau à tous les clients
	GlobalMessageEvent:FireAllClients(message.Data)
end)

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		if isAdmin(player) and string.sub(string.lower(msg), 1, 9) == "!annonce " then
			local texteAnnonce = string.sub(msg, 10)

			-- On prépare un tableau de données complet
			local data = {
				SenderName = player.DisplayName, -- Nom affiché
				SenderUserId = player.UserId,   -- Pour la photo
				Message = texteAnnonce          -- Le texte
			}

			pcall(function()
				MessagingService:PublishAsync(NOM_DU_CANAL, data)
			end)
		end
	end)
end)