--[[
	TeleportController Script
	
	Description: Manages the client-side logic for teleporting the player to various
	locations via UI buttons. Now includes success notifications.
	
	Location: StarterPlayerScripts
--]]
--!strict

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

-- Player and Plot References
local localPlayer: Player = Players.LocalPlayer
local PLOTS_FOLDER = Workspace:WaitForChild("Plots")
local SHOP_TELEPORT_PART = Workspace:WaitForChild("ShopTeleport")

local function teleportCharacter(targetCFrame: CFrame, successMessage: string)
	local character = localPlayer.Character
	if not character then
		warn("Teleport failed: Character not found.")
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		warn("Teleport failed: HumanoidRootPart not found.")
		return
	end

	-- We add a small vertical offset to prevent the player from getting stuck in the ground.
	humanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 3, 0)
	NotificationManager.show(successMessage, "Success")
end

-- ==========================================================
-- ⚡ RECHERCHE ULTRA-FIABLE DU TERRAIN
-- ==========================================================
local function getPlayerPlot(): Model?
	-- 1. On cherche d'abord avec le numéro de terrain exact attribué par le serveur
	local plotNum = localPlayer:GetAttribute("PlotNumber")
	if plotNum then
		local plot = PLOTS_FOLDER:FindFirstChild("Plot" .. tostring(plotNum))
		if plot and plot:GetAttribute("OwnerId") == localPlayer.UserId then
			return plot
		end
	end

	-- 2. Sécurité : On fouille tout le dossier au cas où
	for _, plot in ipairs(PLOTS_FOLDER:GetChildren()) do
		if plot:IsA("Model") and plot:GetAttribute("OwnerId") == localPlayer.UserId then
			return plot
		end
	end
	return nil
end

-- ==========================================================
-- Wave state (phải khai báo trước button handlers)
-- ==========================================================
local ReplicatedStorage_Events = ReplicatedStorage:WaitForChild("Events")

local isWaveActive = false
local isInDuchessEvent = false  -- true khi player đã click EventTeleport

ReplicatedStorage_Events:WaitForChild("WaveStateChanged").OnClientEvent:Connect(function(isActive: boolean)
	isWaveActive = isActive
end)

local WaveUIStateChanged = ReplicatedStorage_Events:WaitForChild("WaveUIStateChanged")
WaveUIStateChanged.OnClientEvent:Connect(function()
	-- HealthUIController sẽ set Bottom.Visible = true khi wave stop
	-- Override lại nếu player đang trong event
	if isInDuchessEvent then
		task.defer(function()
			if isInDuchessEvent and hudBottom then
				hudBottom.Visible = false
			end
		end)
	end
end)

local ToggleWaveStateEvent  = ReplicatedStorage_Events:WaitForChild("ToggleWaveState")
local DuchessEventJoin      = ReplicatedStorage_Events:WaitForChild("DuchessEventJoin")

-- ==========================================================
-- ⚡ CONNEXION DES BOUTONS (UNE SEULE FOIS !)
-- ==========================================================
local playerGui = localPlayer:WaitForChild("PlayerGui")
local buttonsContainer = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Top"):WaitForChild("Buttons")

local plotTeleportButton: TextButton    = buttonsContainer:WaitForChild("PlotTeleport")
local shopTeleportButton: TextButton    = buttonsContainer:WaitForChild("ShopTeleport")
local eventTeleportButton: TextButton   = buttonsContainer:WaitForChild("EventTeleport")

local hudTop    = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Top")
local hudBottom = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Bottom")

-- Connect Plot Teleport Button
plotTeleportButton.MouseButton1Click:Connect(function()
	local playerPlot = getPlayerPlot()

	if playerPlot then
		local spawnPart = playerPlot:FindFirstChild("SpawnPart")
		if spawnPart and spawnPart:IsA("BasePart") then
			teleportCharacter(spawnPart.CFrame, "Teleported to your plot!")
		else
			warn("Could not teleport to plot: SpawnPart is missing.")
		end
	else
		warn("Could not teleport to plot: Player plot not found.")
	end
end)

-- Connect Shop Teleport Button
shopTeleportButton.MouseButton1Click:Connect(function()
	if SHOP_TELEPORT_PART and SHOP_TELEPORT_PART:IsA("BasePart") then
		teleportCharacter(SHOP_TELEPORT_PART.CFrame, "Teleported to the shop!")
	else
		warn("Could not teleport to shop: ShopTeleport part is missing in Workspace.")
	end
end)

-- Connect Event Teleport Button
eventTeleportButton.MouseButton1Click:Connect(function()
	print("[TeleportController] EventTeleport clicked")
	if SHOP_TELEPORT_PART and SHOP_TELEPORT_PART:IsA("BasePart") then
		isInDuchessEvent  = true
		-- Thực hiện ngay lập tức trước khi teleportCharacter có thể yield
		if isWaveActive then
			ToggleWaveStateEvent:FireServer()
		end
		hudTop.Visible    = false
		hudBottom.Visible = false
		DuchessEventJoin:FireServer()
		print("[TeleportController] DuchessEventJoin fired")
		teleportCharacter(SHOP_TELEPORT_PART.CFrame, "Joined Event")
	else
		warn("Could not teleport to event: ShopTeleport part is missing in Workspace.")
	end
end)

local function restoreHUD()
	isInDuchessEvent = false
	if hudTop and hudTop.Parent then
		hudTop.Visible = true
	else
		warn("[TeleportController] HUD Top not found — cannot restore")
	end
	if hudBottom and hudBottom.Parent then
		hudBottom.Visible = true
	else
		warn("[TeleportController] HUD Bottom not found — cannot restore")
	end
end

ReplicatedStorage_Events:WaitForChild("DuchessEventEnd").OnClientEvent:Connect(function()
	pcall(restoreHUD)
end)