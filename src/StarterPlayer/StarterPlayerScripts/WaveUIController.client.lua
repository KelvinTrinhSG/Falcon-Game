--!strict
-- Manages the wave progress bar UI and the next boss indicator.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- ## ADDED ## Require WaveConfigurations to know which waves have bosses
local WaveConfigurations = require(ReplicatedStorage.Modules.WaveConfigurations)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local waveBar = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Top"):WaitForChild("WaveBar")
local progressBar = waveBar:WaitForChild("Progress")
local textLabel = waveBar:WaitForChild("Text")
local mysteryLabel = waveBar:WaitForChild("Mystery")

local WaveUIStateChanged = ReplicatedStorage.Events:WaitForChild("WaveUIStateChanged")
local ZombieKilled = ReplicatedStorage.Events:WaitForChild("ZombieKilled")

local totalEnemiesInWave = 0
local currentWaveDisplaying = 0

local bossWaveNumbers = {}
for waveNum, config in pairs(WaveConfigurations) do
	if config.IsBossWave then
		table.insert(bossWaveNumbers, waveNum)
	end
end
table.sort(bossWaveNumbers)

local function updateNextBossLabel(currentWaveNumber: number)
	local nextBossWave: number? = nil

	for _, bossWave in ipairs(bossWaveNumbers) do
		if bossWave > currentWaveNumber then
			nextBossWave = bossWave
			break
		end
	end

	if nextBossWave then
		mysteryLabel.Text = `??? at Wave {nextBossWave}`
		mysteryLabel.Visible = true
	else
		mysteryLabel.Visible = false
	end
end


WaveUIStateChanged.OnClientEvent:Connect(function(isFighting: boolean, waveNumber: number?, totalEnemies: number?)
	waveBar.Visible = isFighting
	mysteryLabel.Visible = isFighting

	if isFighting and waveNumber and totalEnemies then
		totalEnemiesInWave = totalEnemies
		currentWaveDisplaying = waveNumber
		textLabel.Text = "Wave " .. tostring(waveNumber)
		progressBar:TweenSize(UDim2.new(0, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1)

		updateNextBossLabel(waveNumber)
	end
end)

ZombieKilled.OnClientEvent:Connect(function(killedCount: number, eventWaveNumber: number)
	if eventWaveNumber ~= currentWaveDisplaying then return end

	if totalEnemiesInWave > 0 then
		local percentage = math.clamp(killedCount / totalEnemiesInWave, 0, 1)
		progressBar:TweenSize(UDim2.new(percentage, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3)
	end
end)

waveBar.Visible = false
mysteryLabel.Visible = false