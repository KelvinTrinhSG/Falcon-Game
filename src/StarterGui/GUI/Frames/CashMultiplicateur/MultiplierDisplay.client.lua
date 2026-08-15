local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- On cible ta Frame (le fond) et le Texte à l'intérieur
local frame = script.Parent 
local textLabel = frame:WaitForChild("Value") -- ⚠️ Modifie "TextLabel" par le vrai nom de ton texte si besoin !

local function updateMultiplierUI()
	-- On récupère la valeur actuelle (ou 1 par défaut)
	local multiplier = player:GetAttribute("CashMultiplier") or 1

	if multiplier > 1 then
		-- Si c'est plus grand que 1 (ex: 1.5, 2, etc.), on AFFICHE
		frame.Visible = true
		textLabel.Text = "x" .. tostring(multiplier)
	else
		-- Si c'est 1 (ou moins, en cas de bug), on CACHE complètement l'interface
		frame.Visible = false
	end
end

-- 1. On lance la vérification dès que le joueur apparaît
updateMultiplierUI()

-- 2. On écoute le serveur au cas où le joueur achète un Gamepass en cours de partie !
player:GetAttributeChangedSignal("CashMultiplier"):Connect(updateMultiplierUI)