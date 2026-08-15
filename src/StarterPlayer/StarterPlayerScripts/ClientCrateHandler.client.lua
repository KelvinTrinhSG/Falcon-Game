--!strict
-- Manages the client-side visual timer for placed crates.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local crateGUITemplate = ReplicatedStorage.Templates:WaitForChild("CrateGUITemplate")

local activeCrateUpdaters = {}

local COUNTDOWN_STROKE_COLOR = Color3.fromRGB(50, 50, 50)
local READY_STROKE_COLOR = Color3.fromRGB(120, 78, 0)

-- ⚡ CORRECTION : Format identique au menu (Minutes:Secondes)
local function formatTime(seconds: number): string
	if seconds < 0 then seconds = 0 end
	local minutes = math.floor(seconds / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02i:%02i", minutes, secs)
end

local function setupCrate(crateModel: Model)
	-- ⚡ CORRECTION : On attend que le PrimaryPart ET les attributs arrivent du serveur !
	while not crateModel.PrimaryPart or crateModel:GetAttribute("OwnerId") == nil or crateModel:GetAttribute("UnlockTimestamp") == nil do
		task.wait()
		-- Sécurité : si la caisse est supprimée avant même d'avoir chargé
		if not crateModel.Parent then return end 
	end

	local ownerId = crateModel:GetAttribute("OwnerId")
	if ownerId ~= player.UserId then return end

	local gui = crateGUITemplate:Clone()
	gui.Parent = crateModel.PrimaryPart

	local timerLabel = gui:WaitForChild("TimerLabel")
	local textStroke = timerLabel:FindFirstChild("Stroke")
	local textGradient = timerLabel:FindFirstChild("Gradient")

	activeCrateUpdaters[crateModel] = RunService.Heartbeat:Connect(function()
		local unlockTimestamp = crateModel:GetAttribute("UnlockTimestamp")

		-- Sécurité si l'attribut disparaît
		if typeof(unlockTimestamp) ~= "number" then
			if activeCrateUpdaters[crateModel] then
				activeCrateUpdaters[crateModel]:Disconnect()
				activeCrateUpdaters[crateModel] = nil
			end
			return
		end

		local remaining = unlockTimestamp - os.time()

		if remaining > 0 then
			timerLabel.Text = formatTime(remaining)
			if textStroke then textStroke.Color = COUNTDOWN_STROKE_COLOR end
			if textGradient then textGradient.Enabled = false end
		else
			timerLabel.Text = "Ready!"
			if textStroke then textStroke.Color = READY_STROKE_COLOR end
			if textGradient then textGradient.Enabled = true end

			-- On arrête la boucle une fois que c'est prêt pour optimiser le jeu
			if activeCrateUpdaters[crateModel] then
				activeCrateUpdaters[crateModel]:Disconnect()
				activeCrateUpdaters[crateModel] = nil
			end
		end
	end)
end

local function cleanupCrate(crateModel: Model)
	if activeCrateUpdaters[crateModel] then
		activeCrateUpdaters[crateModel]:Disconnect()
		activeCrateUpdaters[crateModel] = nil
	end
end

task.spawn(function()
	local playerPlot: Model?

	-- On attend de trouver le terrain du joueur
	while not playerPlot do
		local plotNum = player:GetAttribute("PlotNumber")
		if plotNum then 
			playerPlot = Workspace.Plots:FindFirstChild("Plot"..tostring(plotNum)) 
		end
		task.wait(1)
	end

	local crateFolder = playerPlot:WaitForChild("Crate")

	-- On charge les caisses déjà présentes
	for _, child in ipairs(crateFolder:GetChildren()) do
		if child:IsA("Model") then 
			task.spawn(setupCrate, child) -- task.spawn évite de bloquer la boucle si une caisse charge lentement
		end
	end

	-- On écoute les nouvelles caisses
	crateFolder.ChildAdded:Connect(function(child)
		if child:IsA("Model") then 
			task.spawn(setupCrate, child)
		end
	end)

	-- On nettoie quand on les ramasse
	crateFolder.ChildRemoved:Connect(cleanupCrate)
end)