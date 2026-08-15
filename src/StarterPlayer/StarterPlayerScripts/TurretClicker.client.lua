local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local PlacementHandler = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("PlacementHandler"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")
local turretInfoGui = playerGui:WaitForChild("TurretInfo")
local mainFrame = turretInfoGui:WaitForChild("Frame")
local exitBtn = mainFrame:WaitForChild("Exit")

-- 🌟 UI & STATS VARIABLES
local uiScale = mainFrame:WaitForChild("UIScale")
local itemNameText = mainFrame:WaitForChild("ItemName")
local itemImage = mainFrame:WaitForChild("Design"):WaitForChild("Image")

local statsFolder = mainFrame:WaitForChild("Stats")
local damageFrame = statsFolder:WaitForChild("Damage")
local damageCount = damageFrame:WaitForChild("Frame"):WaitForChild("Count")
local damageTitle = damageFrame:WaitForChild("Frame"):WaitForChild("Title")
local statIcon = damageFrame:WaitForChild("ItemIcon")

local fastFrame = statsFolder:WaitForChild("Fast")
local fireRateCount = fastFrame:WaitForChild("Frame"):WaitForChild("Count")

-- ⚡ NOUVEAU : CRÉATION DU TRAIT BLANC (SÉLECTION CLIC)
local selectionHighlight = Instance.new("Highlight")
selectionHighlight.Name = "SelectionOutline"
selectionHighlight.FillTransparency = 1 
selectionHighlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
selectionHighlight.OutlineTransparency = 0 -- Très visible
selectionHighlight.Parent = playerGui 

-- ⚡ NOUVEAU : CRÉATION DU TRAIT BLANC (SURVOL SOURIS)
local hoverHighlight = Instance.new("Highlight")
hoverHighlight.Name = "HoverOutline"
hoverHighlight.FillTransparency = 1
hoverHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
hoverHighlight.OutlineTransparency = 0.6 -- Un peu plus transparent pour différencier du clic
hoverHighlight.Parent = playerGui

-- 🖼️ ICÔNES POUR LES STATISTIQUES
local IMAGE_HP = "rbxassetid://86839486830710"
local DEFAULT_STAT_ICON = statIcon.Image 

-- 📦 CHARGEMENT DES CONFIGURATIONS
local ItemConfigsModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ItemConfigurations"))
local AllConfigs = {}
if ItemConfigsModule.ItemConfigurations then
	for id, config in pairs(ItemConfigsModule.ItemConfigurations) do AllConfigs[id] = config end
end
if ItemConfigsModule.LimitedItems then
	for id, config in pairs(ItemConfigsModule.LimitedItems) do AllConfigs[id] = config end
end

-- Paramètres de base
turretInfoGui.Enabled = false
mainFrame.AnchorPoint = Vector2.new(1, 0.5)

-- ==========================================
-- 📱 DÉTECTION TÉLÉPHONE VS PC
-- ==========================================
local isMobile = UserInputService.TouchEnabled
local TARGET_SCALE = isMobile and 0.6 or 1.0

-- ==========================================
-- 🎨 CONFIG ANIMATIONS
-- ==========================================
local OPEN_DURATION = 0.35
local CLOSE_DURATION = 0.2
local BUTTON_ZOOM = 1.15
local BUTTON_TWEEN_TIME = 0.12

local RIGHT_POS = UDim2.new(1, -20, 0.5, 0) 
local HIDDEN_POS = UDim2.new(1, -20, 0.6, 0) 

-- ==========================================
-- 🚀 FONCTION D'OUVERTURE
-- ==========================================
local function openMenu(turretModel)
	local config = AllConfigs[turretModel.Name]

	-- On active le trait de sélection, et on cache le trait de survol
	selectionHighlight.Adornee = turretModel
	hoverHighlight.Adornee = nil

	if config then
		itemNameText.Text = config.DisplayName or turretModel.Name
		local stats = config.TurretConfig or config

		if config.Type == "Blocks" then
			damageTitle.Text = "HP OF BLOCK"
			damageCount.Text = tostring(stats.Health or 0)
			statIcon.Image = IMAGE_HP 
			fastFrame.Visible = false
		else
			damageTitle.Text = "DAMAGE"
			damageCount.Text = tostring(stats.Damage or stats.dmg or 0)
			statIcon.Image = DEFAULT_STAT_ICON 
			fastFrame.Visible = true
			fireRateCount.Text = tostring(stats.Cooldown or stats.FireRate or stats.Rate or stats.Speed or 0)
		end

		local imgId = config.ImageId or config.Icon or config.Image
		if imgId then
			if type(imgId) == "number" or not string.find(tostring(imgId), "rbxassetid") then
				itemImage.Image = "rbxassetid://" .. tostring(imgId)
			else
				itemImage.Image = tostring(imgId)
			end
		end
	else
		itemNameText.Text = turretModel.Name
		damageCount.Text = "?"
		fireRateCount.Text = "?"
		damageTitle.Text = "STATS"
		statIcon.Image = DEFAULT_STAT_ICON
		fastFrame.Visible = true
	end

	uiScale.Scale = 0
	mainFrame.Position = HIDDEN_POS
	turretInfoGui.Enabled = true

	local tweenInfo = TweenInfo.new(OPEN_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	TweenService:Create(uiScale, tweenInfo, {Scale = TARGET_SCALE}):Play()
	TweenService:Create(mainFrame, tweenInfo, {Position = RIGHT_POS}):Play()
end

-- ==========================================
-- ❌ FONCTION DE FERMETURE
-- ==========================================
local function closeMenu()
	selectionHighlight.Adornee = nil

	local tweenInfo = TweenInfo.new(CLOSE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(uiScale, tweenInfo, {Scale = 0}):Play()
	local posTween = TweenService:Create(mainFrame, tweenInfo, {Position = HIDDEN_POS})
	posTween:Play()

	posTween.Completed:Connect(function()
		turretInfoGui.Enabled = false
	end)
end

-- ==========================================
-- ✨ GESTION DE LA WAVE 
-- ==========================================
local isWaveActive = false
local WaveUIStateChanged = ReplicatedStorage:WaitForChild("Events"):WaitForChild("WaveUIStateChanged")

WaveUIStateChanged.OnClientEvent:Connect(function(isFighting)
	isWaveActive = isFighting
	if isFighting and turretInfoGui.Enabled then
		closeMenu()
	end
end)

-- ==========================================
-- ✨ EFFETS DU BOUTON EXIT
-- ==========================================
local originalBtnSize = exitBtn.Size

exitBtn.MouseEnter:Connect(function()
	local tweenInfo = TweenInfo.new(BUTTON_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(exitBtn, tweenInfo, {
		Size = UDim2.new(originalBtnSize.X.Scale * BUTTON_ZOOM, originalBtnSize.X.Offset * BUTTON_ZOOM, originalBtnSize.Y.Scale * BUTTON_ZOOM, originalBtnSize.Y.Offset * BUTTON_ZOOM)
	}):Play()
end)

exitBtn.MouseLeave:Connect(function()
	local tweenInfo = TweenInfo.new(BUTTON_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(exitBtn, tweenInfo, { Size = originalBtnSize }):Play()
end)

exitBtn.MouseButton1Click:Connect(closeMenu)

-- ==========================================
-- 🔒 FERMETURE SI UN AUTRE GUI S'OUVRE
-- ==========================================
local robuxStore = playerGui:WaitForChild("StoreRobux"):WaitForChild("RobuxStore")

robuxStore:GetPropertyChangedSignal("Visible"):Connect(function()
	if robuxStore.Visible and turretInfoGui.Enabled then
		closeMenu()
	end
end)

local wasDeleteMode = false
RunService.Heartbeat:Connect(function()
	local isDeleteMode = PlacementHandler.State.isDeleteMode
	if isDeleteMode and not wasDeleteMode and turretInfoGui.Enabled then
		closeMenu()
	end
	wasDeleteMode = isDeleteMode
end)

-- ==========================================
-- 🖱️ DÉTECTION DU SURVOL DE LA SOURIS (HOVER)
-- ==========================================
mouse.Move:Connect(function()
	-- On annule tout s'il y a une vague ou le mode suppression
	if isWaveActive or PlacementHandler.State.isDeleteMode then 
		hoverHighlight.Adornee = nil
		return 
	end

	local target = mouse.Target
	if not target then 
		hoverHighlight.Adornee = nil
		return 
	end

	local turretModel = nil
	local currentObj = target

	while currentObj and currentObj ~= workspace do
		if currentObj:IsA("Model") and CollectionService:HasTag(currentObj, "PlacedItem") then
			turretModel = currentObj
			break
		end
		currentObj = currentObj.Parent
	end

	-- Si c'est bien une tourelle ou un bloc à nous
	if turretModel then
		local plot = turretModel.Parent
		if plot and plot:GetAttribute("OwnerId") == player.UserId then

			-- On ne met pas le contour de survol si on a DÉJÀ cliqué dessus (pour éviter de superposer 2 traits)
			if turretModel == selectionHighlight.Adornee then
				hoverHighlight.Adornee = nil
			else
				hoverHighlight.Adornee = turretModel
			end
			return
		end
	end

	-- Si la souris est dans le vide ou sur le sol, on enlève le trait
	hoverHighlight.Adornee = nil
end)

-- ==========================================
-- 🖱️ DÉTECTION DU CLIC
-- ==========================================
mouse.Button1Down:Connect(function()
	if isWaveActive or PlacementHandler.State.isDeleteMode then return end

	local target = mouse.Target
	if not target then return end

	local turretModel = nil
	local currentObj = target

	while currentObj and currentObj ~= workspace do
		if currentObj:IsA("Model") and CollectionService:HasTag(currentObj, "PlacedItem") then
			turretModel = currentObj
			break
		end
		currentObj = currentObj.Parent
	end

	if turretModel then
		local plot = turretModel.Parent
		if plot and plot:GetAttribute("OwnerId") == player.UserId then
			openMenu(turretModel)
		end
	end
end)