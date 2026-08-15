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
-- ⚡ CONNEXION DES BOUTONS (UNE SEULE FOIS !)
-- ==========================================================
local playerGui = localPlayer:WaitForChild("PlayerGui")
local buttonsContainer = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Top"):WaitForChild("Buttons")

local plotTeleportButton: TextButton = buttonsContainer:WaitForChild("PlotTeleport")
local shopTeleportButton: TextButton = buttonsContainer:WaitForChild("ShopTeleport")

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