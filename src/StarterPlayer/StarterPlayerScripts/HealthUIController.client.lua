--!strict
-- LOCATION: StarterPlayerScripts/HealthUIController.lua
-- DESCRIPTION: Manages both the Plot Health and Boss Health bars on the player's HUD.

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local FrameManager = require(Modules:WaitForChild("FrameManager"))
local NumberFormatter = require(Modules:WaitForChild("NumberFormatter"))

-- Player and UI References
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local hud = playerGui:WaitForChild("GUI"):WaitForChild("HUD")

-- Events
local WaveStateChangedEvent = ReplicatedStorage.Events:WaitForChild("WaveStateChanged")
local UpdateProtectionModelFX = ReplicatedStorage.Events:WaitForChild("UpdateProtectionModelFX")
local BossWaveStarted = ReplicatedStorage.Events:WaitForChild("BossWaveStarted")
local BossWaveEnded = ReplicatedStorage.Events:WaitForChild("BossWaveEnded")
local WaveUIStateChanged = ReplicatedStorage.Events:WaitForChild("WaveUIStateChanged")

-------------------------------------------------------------------
-- ## PLOT HEALTH UI ##
-------------------------------------------------------------------

local plotHealthFrame = hud:WaitForChild("PlotHealth")
local plotProgressBar = plotHealthFrame:WaitForChild("Progress")
local plotTextLabel = plotHealthFrame:WaitForChild("Text")
local plotModelImage = plotHealthFrame:WaitForChild("Image")
local bottomFrame = hud:WaitForChild("Bottom")

local plotHealthConnection: RBXScriptConnection?
local plotHealthPart: Instance? 
local plotMaxHealth = 50

local function updatePlotHealthUI(currentHealth: number, newMaxHealth: number)
	plotMaxHealth = newMaxHealth
	currentHealth = math.clamp(currentHealth, 0, plotMaxHealth)
	local percentage = currentHealth / plotMaxHealth

	plotProgressBar:TweenSize(UDim2.new(percentage, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
	plotTextLabel.Text = NumberFormatter.formatNumber(math.floor(currentHealth)) .. " / " .. NumberFormatter.formatNumber(plotMaxHealth)
end

task.spawn(function()
	local playerPlot: Model?
	while not playerPlot do
		for _, plot in ipairs(Workspace.Plots:GetChildren()) do
			if plot:IsA("Model") and plot:GetAttribute("OwnerId") == localPlayer.UserId then
				playerPlot = plot
				break
			end
		end
		if not playerPlot then
			task.wait(1)
		end
	end

	plotHealthPart = playerPlot:WaitForChild("Core1")

	if plotHealthPart then
		if plotHealthConnection then plotHealthConnection:Disconnect() end
		plotHealthConnection = plotHealthPart:GetAttributeChangedSignal("Health"):Connect(function()
			updatePlotHealthUI(plotHealthPart:GetAttribute("Health"), plotMaxHealth)
		end)
	end
end)

UpdateProtectionModelFX.OnClientEvent:Connect(function(imageId: string, newMaxHealth: number?)
	-- ⚡ SÉCURITÉ : S'il n'y a pas d'image, on met une case vide sans faire planter le jeu
	plotModelImage.Image = imageId or ""

	if newMaxHealth and plotHealthPart then
		updatePlotHealthUI(newMaxHealth, newMaxHealth)
	end
end)

WaveStateChangedEvent.OnClientEvent:Connect(function(isFighting: boolean, currentHealth: number?, newMaxHealth: number?)
	plotHealthFrame.Visible = isFighting
	bottomFrame.Visible = not isFighting

	if isFighting and currentHealth and newMaxHealth then
		updatePlotHealthUI(currentHealth, newMaxHealth)
	end

	if isFighting then
		local openFrameName = FrameManager.getOpenFrameName()
		if openFrameName then
			FrameManager.close(openFrameName)
		end
	end
end)


-------------------------------------------------------------------
-- ## BOSS HEALTH UI ## 
-------------------------------------------------------------------

local bossHealthFrame = hud:WaitForChild("BossHealth")
local bossProgressBar = bossHealthFrame:WaitForChild("Progress")
local bossTextLabel = bossHealthFrame:WaitForChild("Text")
local bossImage = bossHealthFrame:WaitForChild("Image")
local bossHealthConnection: RBXScriptConnection?

local function updateBossHealthUI(humanoid: Humanoid)
	local currentHealth = humanoid.Health
	local maxHealth = humanoid.MaxHealth
	local percentage = math.clamp(currentHealth / maxHealth, 0, 1)

	bossProgressBar:TweenSize(UDim2.new(percentage, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2)
	bossTextLabel.Text = `BOSS: {math.floor(currentHealth)} / {maxHealth}`
end

BossWaveStarted.OnClientEvent:Connect(function(bossHumanoid: Humanoid, imageId: string)
	if not bossHumanoid then return end
	if bossHealthConnection then bossHealthConnection:Disconnect() end

	-- ⚡ SÉCURITÉ : Même chose ici pour éviter le crash des Boss sans image
	bossImage.Image = imageId or ""

	bossHealthFrame.Visible = true
	updateBossHealthUI(bossHumanoid)
	bossHealthConnection = bossHumanoid.HealthChanged:Connect(function()
		updateBossHealthUI(bossHumanoid)
	end)
end)

BossWaveEnded.OnClientEvent:Connect(function()
	bossHealthFrame.Visible = false
	if bossHealthConnection then
		bossHealthConnection:Disconnect()
		bossHealthConnection = nil
	end
end)


-------------------------------------------------------------------
-- ## INITIAL SETUP ##
-------------------------------------------------------------------
plotHealthFrame.Visible = false
bottomFrame.Visible = true
bossHealthFrame.Visible = false