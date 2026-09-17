local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- On charge les contrôleurs nécessaires
local PlayerController = require(ServerScriptService:WaitForChild("Controllers"):WaitForChild("PlayerController"))
local CrateController = require(ServerScriptService:WaitForChild("Controllers"):WaitForChild("CrateController"))

-- On récupère les événements
local redeemCodeEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("RedeemCodeEvent")
local showNotificationEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ShowNotification")
local blockInventoryUpdatedEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("BlockInventoryUpdated")

-- ==========================================
-- 🎁 LA LISTE DES CODES SECRETS
-- ==========================================
local CODES = {
	["FREEITEM"] = {RewardType = "Crate", RewardItem = "CameraCrate"},
	["CASH2K"]   = {RewardType = "Cash",  Amount = 2000},
	["GOLD3"]    = {RewardType = "Block", RewardItem = "GoldBlock", Amount = 3},
}

redeemCodeEvent.OnServerEvent:Connect(function(player, codeText)
	local profile = PlayerController:GetProfile(player)

	if not profile then return end

	-- On crée le dossier des codes utilisés s'il n'existe pas
	if not profile.Data.UsedCodes then
		profile.Data.UsedCodes = {}
	end

	-- On vérifie si le joueur a déjà utilisé ce code
	if profile.Data.UsedCodes[codeText] then
		showNotificationEvent:FireClient(player, "Code already used!", "Error")
		return
	end

	local codeInfo = CODES[codeText]

	if codeInfo then

		-- 📦 SI C'EST UNE CAISSE :
		if codeInfo.RewardType == "Crate" then
			local success = CrateController:PurchaseCrate(player, codeInfo.RewardItem, true)

			if success then
				profile.Data.UsedCodes[codeText] = true
				showNotificationEvent:FireClient(player, "Reward: +1 " .. codeInfo.RewardItem, "Success")
			else
				showNotificationEvent:FireClient(player, "Your plot is full (Max 3 crates)!", "Error")
			end

			-- 💰 SI C'EST DE L'ARGENT :
		elseif codeInfo.RewardType == "Cash" then
			local leaderstats = player:FindFirstChild("leaderstats")
			local cash = leaderstats and leaderstats:FindFirstChild("Cash")
			if cash then
				cash.Value += codeInfo.Amount
				profile.Data.UsedCodes[codeText] = true
				showNotificationEvent:FireClient(player, "Reward: +$" .. codeInfo.Amount .. " Cash", "Success")
			end

			-- 🎡 SI CE SONT DES SPINS (ROUE) :
		elseif codeInfo.RewardType == "Spin" then
			local freeSpins = player:FindFirstChild("FreeSpins")
			if freeSpins then
				freeSpins.Value += codeInfo.Amount
				profile.Data.UsedCodes[codeText] = true
				showNotificationEvent:FireClient(player, "Reward: +" .. codeInfo.Amount .. " Spins", "Success")
			end

			-- 🧱 SI CE SONT DES BLOCS :
		elseif codeInfo.RewardType == "Block" then
			-- On s'assure que l'inventaire de blocs existe
			if not profile.Data.BlockInventory then
				profile.Data.BlockInventory = {}
			end

			-- On ajoute la quantité de blocs
			local itemId = codeInfo.RewardItem
			local amount = codeInfo.Amount

			profile.Data.BlockInventory[itemId] = (profile.Data.BlockInventory[itemId] or 0) + amount
			profile.Data.UsedCodes[codeText] = true

			-- On actualise le menu en bas de l'écran du joueur
			blockInventoryUpdatedEvent:FireClient(player, profile.Data.BlockInventory)

			showNotificationEvent:FireClient(player, "Reward: +" .. amount .. " " .. itemId, "Success")
		end

	else
		-- Si le code tapé n'est pas dans la liste
		showNotificationEvent:FireClient(player, "Invalid code.", "Error")
	end
end)