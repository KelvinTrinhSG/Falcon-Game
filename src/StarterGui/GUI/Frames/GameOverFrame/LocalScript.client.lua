local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FrameManager = require(ReplicatedStorage.Modules:WaitForChild("FrameManager"))

local gameOverFrame = script.Parent

-- Attention : vérifie bien que ton bouton Close est toujours directement dans GameOverFrame
local closeButton = gameOverFrame:WaitForChild("Close")

-- 1. NOUVEAU : On cible d'abord le dossier "StatsContainer"
local statsContainer = gameOverFrame:WaitForChild("StatsContainer")

-- 2. MODIFIÉ : On cherche les textes à l'intérieur du statsContainer
local waveLabel = statsContainer:WaitForChild("WaveLabel")
local killsLabel = statsContainer:WaitForChild("KillsLabel")
local damageLabel = statsContainer:WaitForChild("DamageLabel")
local timeLabel = statsContainer:WaitForChild("TimeLabel")

-- Quand le serveur dit qu'on a perdu et nous donne les stats :
ReplicatedStorage.Events:WaitForChild("ShowGameOver").OnClientEvent:Connect(function(wave, kills, damage, timeSeconds)

	-- On convertit les secondes en format "Minutes:Secondes" (ex: 02:45)
	local minutes = math.floor(timeSeconds / 60)
	local seconds = timeSeconds % 60
	local timeString = string.format("%02d:%02d", minutes, seconds)

	-- On met à jour les textes en anglais
	waveLabel.Text = "Wave Reached: " .. tostring(wave)
	killsLabel.Text = "Enemies Killed: " .. tostring(kills)
	damageLabel.Text = "Damage Dealt: " .. tostring(damage)
	timeLabel.Text = "Time Survived: " .. timeString

	-- On affiche l'interface
	FrameManager.open(gameOverFrame.Name)
end)

-- Quand on clique sur la croix rouge :
closeButton.MouseButton1Click:Connect(function()
	FrameManager.close(gameOverFrame.Name)
end)