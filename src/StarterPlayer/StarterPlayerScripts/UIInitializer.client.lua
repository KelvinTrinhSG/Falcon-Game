--!strict

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Modules
local FrameManager = require(ReplicatedStorage.Modules.FrameManager)

-- Player
local player: Player = Players.LocalPlayer

local function initializeUI()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)

	local playerGui = player:WaitForChild("PlayerGui")
	local gui = playerGui:WaitForChild("GUI")
	local framesContainer = gui:WaitForChild("Frames")
	local hud = gui:WaitForChild("HUD")

	-- Connect the RobuxStore button
	local leftHud = hud:WaitForChild("Left")
	local robuxStoreButton = leftHud:FindFirstChild("RobuxStore")
	if robuxStoreButton then
		FrameManager.connect(robuxStoreButton, "RobuxStore", "Toggle")
	end
	
	-- ## ADDED ## Connect the Settings button (Engrenage)
	local settingsButton = hud:FindFirstChild("Settings")
	if settingsButton then
		FrameManager.connect(settingsButton, "Settings", "Toggle")
		end
	
	-- ## ADDED ## Connect the new LimitedTurret button
	local rightHud = hud:WaitForChild("Right", 10)
	if not rightHud then
		warn("[DEBUG] HUD/Right NOT FOUND after 10s")
		return
	end
	local limitedTurretButton = rightHud:FindFirstChild("LimitedTurret")
	if limitedTurretButton then
		FrameManager.connect(limitedTurretButton, "LimitedTurret", "Toggle")
	end

	local limitedTurretTitanTVButton = rightHud:FindFirstChild("LimitedTurretTitanTV")
	if limitedTurretTitanTVButton then
		FrameManager.connect(limitedTurretTitanTVButton, "LimitedTurretTitanTVMan", "Toggle")
	end

	local limitedTurretTitanSpeakermanButton = rightHud:FindFirstChild("LimitedTurretTitanSpeakerman")
	if limitedTurretTitanSpeakermanButton then
		FrameManager.connect(limitedTurretTitanSpeakermanButton, "LimitedTurretTitanSpeakerman", "Toggle")
	end

	-- Connects all "Close" buttons inside your frames
	for _, frame in ipairs(framesContainer:GetChildren()) do
		if frame:IsA("GuiObject") then
			local closeButton = frame:FindFirstChild("Close")
			if closeButton and (closeButton:IsA("TextButton") or closeButton:IsA("ImageButton")) then
				FrameManager.connect(closeButton, frame.Name, "Close")
			end
		end
	end
end

player.CharacterAdded:Connect(initializeUI)
if player.Character then
	initializeUI()
end