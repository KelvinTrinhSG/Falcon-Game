--!strict
-- LOCATION: ServerScriptService/Controllers/PlotController.lua

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PlacementController
local PlayerController
local CrateController
local WaveController 
local TurretController

local ItemConfigsModule = require(ReplicatedStorage.Modules:WaitForChild("ItemConfigurations"))
local ModelConfigurations = ItemConfigsModule.ModelConfigurations

local CRATE_MODELS = ReplicatedStorage:WaitForChild("Crates")
local ShowNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

-- Controller Definition
local PlotController = {}
local PLOTS_FOLDER = Workspace:WaitForChild("Plots")
local ResetPlotEvent = ReplicatedStorage.Events:WaitForChild("ResetPlot")
local UpdateProtectionModelFX = ReplicatedStorage.Events:WaitForChild("UpdateProtectionModelFX")

-- ==========================================================
-- 🛡️ SÉCURITÉS DES DOSSIERS
-- ==========================================================
local PLOTS_V2_TEMPLATES = ReplicatedStorage:FindFirstChild("PlotsV2")
if not PLOTS_V2_TEMPLATES then
	warn("[PlotController] Dossier 'PlotsV2' introuvable ! Création d'un dossier vide par sécurité.")
	PLOTS_V2_TEMPLATES = Instance.new("Folder")
	PLOTS_V2_TEMPLATES.Name = "PlotsV2"
	PLOTS_V2_TEMPLATES.Parent = ReplicatedStorage
end

local HIDDEN_PLOTS_FOLDER = ReplicatedStorage:FindFirstChild("HiddenPlots")
if not HIDDEN_PLOTS_FOLDER then
	HIDDEN_PLOTS_FOLDER = Instance.new("Folder")
	HIDDEN_PLOTS_FOLDER.Name = "HiddenPlots"
	HIDDEN_PLOTS_FOLDER.Parent = ReplicatedStorage
end

-- ==========================================================
-- 👑 GET PLOT
-- ==========================================================
local function getPlotForPlayer(player: Player): Model?
	local plotNum = player:GetAttribute("PlotNumber")
	if plotNum then
		local plot = PLOTS_FOLDER:FindFirstChild("Plot" .. plotNum)
		if plot and plot:GetAttribute("OwnerId") == player.UserId then return plot end
	end

	for _, plot in ipairs(PLOTS_FOLDER:GetChildren()) do
		if plot:IsA("Model") and plot:GetAttribute("OwnerId") == player.UserId then
			return plot
		end
	end
	return nil
end

local function spawnPromotionalCrate(plot: Model)
	local spawnPart = plot:FindFirstChild("RobuxCrateSpawn")
	if not spawnPart then return end
	local crateTemplate = CRATE_MODELS:FindFirstChild("GodCrate")
	if not (crateTemplate and crateTemplate.PrimaryPart) then return end

	local promoCrate = crateTemplate:Clone()
	promoCrate.Name = "PromotionalGodCrate"
	promoCrate:SetPrimaryPartCFrame(spawnPart.CFrame * CFrame.new(0, 3, 0))
	promoCrate.Parent = plot
end

function PlotController:EquipModel(player: Player, modelName: string, forceEquip: boolean?)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local plot = getPlotForPlayer(player)
	if not plot then return end

	local plotHealthPart = plot:FindFirstChild("PlotHealth")
	if not plotHealthPart then return end

	local modelConfig = ModelConfigurations[modelName]
	if not modelConfig then 
		warn("[PlotController] Configuration introuvable pour le modèle : " .. tostring(modelName))
		return 
	end

	profile.Data.EquippedModel = modelName

	for _, child in ipairs(plotHealthPart:GetChildren()) do
		if child:IsA("Model") then child:Destroy() end
	end

	local modelTemplate = ReplicatedStorage.Models:FindFirstChild(modelName)
	if modelTemplate then
		local newModel = modelTemplate:Clone()
		if newModel.PrimaryPart then
			newModel:SetPrimaryPartCFrame(plotHealthPart.CFrame)
		end
		newModel.Parent = plotHealthPart
	end

	plotHealthPart:SetAttribute("Health", modelConfig.Health)
	UpdateProtectionModelFX:FireClient(player, modelConfig.ImageId, modelConfig.Health)

	if WaveController:IsPlayerFighting(player) then
		ReplicatedStorage.Events.WaveStateChanged:FireClient(player, true, modelConfig.Health, modelConfig.Health)
	end

	if not forceEquip then
		ShowNotificationEvent:FireClient(player, `{modelConfig.DisplayName} équipé !`, "Success")
	end
end

-- ==========================================================
-- 🔍 LE SCANNER DE REMBOURSEMENT AUTOMATIQUE (VERSION BOÎTE 3D)
-- ==========================================================
local function getConfig(itemName: string)
	if ItemConfigsModule.ItemConfigurations then
		return ItemConfigsModule.ItemConfigurations[itemName] or (ItemConfigsModule.LimitedItems and ItemConfigsModule.LimitedItems[itemName])
	else
		return ItemConfigsModule[itemName]
	end
end

local function validateAndRefundPlacements(player: Player, plot: Model)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local pathFolder = plot:FindFirstChild("Path")
	if not pathFolder then return end

	local itemsRefunded = 0
	local itemsToRemove = {}

	for _, child in ipairs(plot:GetChildren()) do
		if child:GetAttribute("IsPlacedItem") == true then
			local config = getConfig(child.Name)

			if config then
				local cframe, size = child:GetBoundingBox()
				local checkCFrame = cframe * CFrame.new(0, -size.Y/2, 0)
				local checkSize = Vector3.new(size.X - 0.2, 4, size.Z - 0.2)

				local params = OverlapParams.new()
				params.FilterType = Enum.RaycastFilterType.Include
				params.FilterDescendantsInstances = {pathFolder}

				local overlappingParts = Workspace:GetPartBoundsInBox(checkCFrame, checkSize, params)
				local isOnPath = (#overlappingParts > 0)

				local isMisplaced = false
				if config.Type == "Turrets" and isOnPath then
					isMisplaced = true
				elseif config.Type == "Blocks" and not isOnPath then
					isMisplaced = true
				end

				if isMisplaced then
					local uniqueId = child:GetAttribute("UniqueId")
					table.insert(itemsToRemove, {Instance = child, UniqueId = uniqueId, Name = child.Name, Type = config.Type})
				end
			end
		end
	end

	for _, itemData in ipairs(itemsToRemove) do
		for i, savedItem in ipairs(profile.Data.PlacedItems) do
			if savedItem.UniqueId == itemData.UniqueId then
				table.remove(profile.Data.PlacedItems, i)
				break
			end
		end

		profile.Data.BlockInventory[itemData.Name] = (profile.Data.BlockInventory[itemData.Name] or 0) + 1
		itemsRefunded += 1

		CollectionService:RemoveTag(itemData.Instance, "PlacedItem")
		if itemData.Type == "Turrets" and TurretController then
			pcall(function() TurretController:RemoveTurret(itemData.Instance) end)
		end
		itemData.Instance:Destroy()
	end

	if itemsRefunded > 0 then
		ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, profile.Data.BlockInventory)
		task.delay(2, function()
			ShowNotificationEvent:FireClient(player, itemsRefunded .. " objets mal placés ont été remboursés dans ton inventaire !", "Warning")
		end)
	end
end

-- ==========================================================
-- 🧹 FONCTION DE NETTOYAGE UNIQUE
-- ==========================================================
local function cleanupPlot(plot: Model)
	local plotHealthPart = plot:FindFirstChild("PlotHealth")
	if plotHealthPart then
		CollectionService:RemoveTag(plotHealthPart, "Damageable")
	end

	for _, child in ipairs(plot:GetChildren()) do
		if child:GetAttribute("IsPlacedItem") == true then
			child:SetAttribute("UniqueId", nil) 
			CollectionService:RemoveTag(child, "PlacedItem")

			if TurretController then
				pcall(function() TurretController:RemoveTurret(child) end)
			end
			child:Destroy()
		elseif child.Name == "PromotionalGodCrate" or child.Name == "GodCrate" then
			child:Destroy()
		end
	end

	local crateFolder = plot:FindFirstChild("Crate")
	if crateFolder then
		for _, child in ipairs(crateFolder:GetChildren()) do
			if not string.find(child.Name, "Spawn") and child.Name ~= "Part" then
				child:Destroy()
			end
		end
	end

	if plotHealthPart then
		for _, modelChild in ipairs(plotHealthPart:GetChildren()) do
			if modelChild:IsA("Model") then
				modelChild:Destroy()
			end
		end
	end
end

-- ==========================================================
-- 🚀 UPGRADE AUTOMATIQUE DU TERRAIN EN V2 (EN DIRECT)
-- ==========================================================
function PlotController:UpgradePlotToV2(player: Player)
	local profile = PlayerController:GetProfile(player)
	if not profile then return end

	local plotNum = player:GetAttribute("PlotNumber")
	if not plotNum then return end

	local currentPlot = PLOTS_FOLDER:FindFirstChild("Plot" .. plotNum)
	-- Si le terrain n'existe pas ou s'il est DÉJÀ en V2, on annule
	if not currentPlot or currentPlot:GetAttribute("IsV2") then return end

	local v2Template = PLOTS_V2_TEMPLATES:FindFirstChild("Plot" .. plotNum .. "_v2")
	if not v2Template then return end

	-- 1. On nettoie (virtuellement) et on cache l'ancien terrain
	local exactCFrame = currentPlot:GetPivot()
	cleanupPlot(currentPlot)
	currentPlot.Parent = HIDDEN_PLOTS_FOLDER

	-- 2. On installe le nouveau terrain V2
	local assignedPlot = v2Template:Clone()
	assignedPlot.Name = "Plot" .. plotNum 
	assignedPlot:SetAttribute("IsV2", true) 
	assignedPlot:SetAttribute("OwnerId", player.UserId)
	assignedPlot:PivotTo(exactCFrame)
	assignedPlot.Parent = PLOTS_FOLDER

	local plotHealthPart = assignedPlot:FindFirstChild("PlotHealth")
	if plotHealthPart then
		CollectionService:AddTag(plotHealthPart, "Damageable")
	end

	spawnPromotionalCrate(assignedPlot)

	if profile.Data.EquippedModel then
		self:EquipModel(player, profile.Data.EquippedModel, true)
	end

	-- 3. On recharge et recalcule tout (Tourelles, blocus, caisses)
	PlacementController:LoadPlacedItems(player, assignedPlot)
	validateAndRefundPlacements(player, assignedPlot)
	CrateController:LoadPlayerCrates(player, assignedPlot)

	-- 4. On met à jour la sauvegarde
	profile.Data.HadV2Plot = true

	-- Petite notification de victoire !
	ShowNotificationEvent:FireClient(player, "🎉 TERRAIN V2 DÉBLOQUÉ ET INSTALLÉ !", "Success")
end

-- ==========================================================
-- 👑 ATTRIBUTION DU TERRAIN (AU CHARGEMENT)
-- ==========================================================
function PlotController:OnPlayerProfileLoaded(player: Player)
	while not PlacementController or not CrateController or not PlayerController or not WaveController do
		task.wait()
	end

	local profile = PlayerController:GetProfile(player)
	local isV2 = profile and profile.Data.HighestWave and profile.Data.HighestWave >= 100
	local hadV2LastTime = profile.Data.HadV2Plot == true
	local terrainChanged = false

	if isV2 ~= hadV2LastTime then
		terrainChanged = true
		profile.Data.HadV2Plot = isV2
	end

	local chosenPlotNum = nil
	local assignedPlot = nil

	for i = 1, 20 do
		local normalInWorkspace = PLOTS_FOLDER:FindFirstChild("Plot" .. i)
		if normalInWorkspace and not normalInWorkspace:GetAttribute("OwnerId") then
			chosenPlotNum = i
			break
		end
	end

	if chosenPlotNum then
		local normalPlot = PLOTS_FOLDER:FindFirstChild("Plot" .. chosenPlotNum)

		if isV2 then
			local v2Template = PLOTS_V2_TEMPLATES:FindFirstChild("Plot" .. chosenPlotNum .. "_v2")

			if v2Template then
				local exactCFrame = nil
				if normalPlot then 
					exactCFrame = normalPlot:GetPivot()
					normalPlot.Parent = HIDDEN_PLOTS_FOLDER 
				end

				assignedPlot = v2Template:Clone()
				assignedPlot.Name = "Plot" .. chosenPlotNum 
				assignedPlot:SetAttribute("IsV2", true) 
				assignedPlot:SetAttribute("OwnerId", player.UserId)

				if exactCFrame then
					assignedPlot:PivotTo(exactCFrame)
				end

				assignedPlot.Parent = PLOTS_FOLDER
			else
				assignedPlot = normalPlot
				if assignedPlot then assignedPlot:SetAttribute("OwnerId", player.UserId) end
			end
		else
			assignedPlot = normalPlot
			if assignedPlot then assignedPlot:SetAttribute("OwnerId", player.UserId) end
		end

		if assignedPlot then
			player:SetAttribute("PlotNumber", chosenPlotNum)

			local plotHealthPart = assignedPlot:FindFirstChild("PlotHealth")
			if plotHealthPart then CollectionService:AddTag(plotHealthPart, "Damageable") end

			spawnPromotionalCrate(assignedPlot)

			if profile then
				self:EquipModel(player, profile.Data.EquippedModel, true)
			end

			PlacementController:LoadPlacedItems(player, assignedPlot)

			if terrainChanged then
				validateAndRefundPlacements(player, assignedPlot)
			end

			CrateController:LoadPlayerCrates(player, assignedPlot)

			local spawnLocation = assignedPlot:FindFirstChild("SpawnPart")
			if spawnLocation and spawnLocation:IsA("SpawnLocation") then
				player.RespawnLocation = spawnLocation
				if player.Character then
					player.Character:SetPrimaryPartCFrame(spawnLocation.CFrame * CFrame.new(0, 3, 0))
				end
			end
		end
	else
		player:Kick("Sorry, all plots are currently taken! Please try a different server.")
	end
end

-- ==========================================================
-- 👑 QUAND LE JOUEUR QUITTE
-- ==========================================================
local function onPlayerRemoving(player: Player)
	player.RespawnLocation = nil
	local plotNum = player:GetAttribute("PlotNumber")

	if not plotNum then return end 

	local plot = PLOTS_FOLDER:FindFirstChild("Plot" .. plotNum)
	if plot then
		cleanupPlot(plot)

		if plot:GetAttribute("IsV2") then
			plot:Destroy() 

			local hiddenNormalPlot = HIDDEN_PLOTS_FOLDER:FindFirstChild("Plot" .. plotNum)
			if hiddenNormalPlot then
				hiddenNormalPlot:SetAttribute("OwnerId", nil)
				hiddenNormalPlot.Parent = PLOTS_FOLDER
			end
		else
			plot:SetAttribute("OwnerId", nil)
		end
	end
end

local function setupPlot(plot: Model)
	if not plot:IsA("Model") then return end
	if plot:GetAttribute("OwnerId") ~= nil then return end
	plot:SetAttribute("OwnerId", nil)
end

function PlotController:Init(controllers: {[string]: any})
	PlacementController = controllers.PlacementController
	PlayerController = controllers.PlayerController
	CrateController = controllers.CrateController
	WaveController = controllers.WaveController
	TurretController = controllers.TurretController 
end

function PlotController:Start()
	for _, plot in ipairs(PLOTS_FOLDER:GetChildren()) do
		setupPlot(plot)
	end
	PLOTS_FOLDER.ChildAdded:Connect(setupPlot)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			task.wait(0.5) 
			local plot = getPlotForPlayer(player) 
			if not plot then return end

			local spawnPart = plot:FindFirstChild("SpawnPart")
			if spawnPart and character:FindFirstChild("HumanoidRootPart") then
				if spawnPart:IsA("SpawnLocation") then
					player.RespawnLocation = spawnPart
				end
				character:SetPrimaryPartCFrame(spawnPart.CFrame * CFrame.new(0, 3, 0))
			end
		end)
	end)

	ResetPlotEvent.OnServerEvent:Connect(function(player)
		PlacementController:ResetPlotItems(player)
	end)

	ReplicatedStorage.Events.EquipModelRequest.OnServerEvent:Connect(function(player, modelName)
		self:EquipModel(player, modelName)
	end)

	-- ⚡ LE DÉTECTEUR AUTOMATIQUE (Vérifie toutes les 5 secondes en arrière-plan)
	task.spawn(function()
		while true do
			task.wait(5)
			for _, player in ipairs(Players:GetPlayers()) do
				local profile = PlayerController:GetProfile(player)
				if profile and profile.Data.HighestWave and profile.Data.HighestWave >= 100 then
					local plotNum = player:GetAttribute("PlotNumber")
					if plotNum then
						local plot = PLOTS_FOLDER:FindFirstChild("Plot" .. plotNum)
						-- S'il a le niveau pour la V2 mais qu'il est toujours sur la V1, on le met à jour !
						if plot and not plot:GetAttribute("IsV2") then
							self:UpgradePlotToV2(player)
						end
					end
				end
			end
		end
	end)
end

return PlotController