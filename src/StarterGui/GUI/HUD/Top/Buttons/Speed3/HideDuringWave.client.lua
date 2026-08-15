--!strict
-- LOCATION: GUI/HUD/Top/Buttons/Speed3/HideDuringWave

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shopButton = script.Parent

-- On va chercher l'événement qui prévient quand une vague commence ou se termine
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local waveStateChanged = eventsFolder:WaitForChild("WaveStateChanged")

-- Dès que le serveur nous annonce un changement de vague :
waveStateChanged.OnClientEvent:Connect(function(isActive: boolean)
	if isActive then
		-- Si le combat commence, on montre le bouton !
		shopButton.Visible = true
	else
		-- Si le combat est fini (ou que le joueur meurt/quitte le plot), on l'enleve !
		shopButton.Visible = false
	end
end)