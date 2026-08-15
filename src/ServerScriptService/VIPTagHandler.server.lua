--!strict
-- LOCATION: ServerScriptService/VIPTagHandler

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- L'ID de ton Gamepass VIP
local GAMEPASS_VIP = 1832112258

-- Fonction pour attacher le tag sur la tête du personnage
local function giveVIPTag(character: Model)
	local head = character:WaitForChild("Head", 5)
	local vipTagTemplate = ServerStorage:FindFirstChild("VIPTag")

	if head and vipTagTemplate then
		-- Vérifie qu'il n'en a pas déjà un (pour éviter les doublons)
		if head:FindFirstChild("VIPTag") then return end

		-- On clone le tag et on le soude à la tête
		local clonedTag = vipTagTemplate:Clone()
		clonedTag.Parent = head
	end
end

-- 1. Quand un joueur apparaît dans le jeu
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.spawn(function()
			-- On vérifie dans l'inventaire Roblox s'il possède le pass
			local success, hasVIP = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_VIP)
			end)

			-- S'il l'a, on lui met la couronne !
			if success and hasVIP then
				giveVIPTag(character)
			end
		end)
	end)
end)

-- 2. POLISH : Si le joueur achète le VIP en pleine partie !
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
	if passId == GAMEPASS_VIP and wasPurchased then
		if player.Character then
			giveVIPTag(player.Character)
			-- Tu peux même ajouter des paillettes ou un son de victoire ici plus tard !
		end
	end
end)