--!strict

-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

-- Modules
-- ## MODIFIED ## Updated to handle the new module structure
local ItemConfigsModule = require(script.Parent:WaitForChild("ItemConfigurations"))
local ItemConfigurations = ItemConfigsModule.ItemConfigurations
local LimitedItems = ItemConfigsModule.LimitedItems
local NotificationManager = require(script.Parent:WaitForChild("NotificationManager"))
local FrameManager = require(script.Parent:WaitForChild("FrameManager"))

-- ## ADDED ## Create one master table for all item configurations for easy lookups
local AllItemConfigs = {}
for id, config in pairs(ItemConfigurations) do
	AllItemConfigs[id] = config
end
for id, config in pairs(LimitedItems) do
	AllItemConfigs[id] = config
end


-- Events & Functions, Sounds, Folders & Player
local PlaceItemEvent = ReplicatedStorage.Events:WaitForChild("PlaceItemEvent")
local RemoveItemEvent = ReplicatedStorage.Events:WaitForChild("RemoveItemEvent")
local blockInventoryUpdatedEvent = ReplicatedStorage.Events:WaitForChild("BlockInventoryUpdated")
local getBlockInventoryFunc = ReplicatedStorage.Functions:WaitForChild("GetBlockInventory")
local ItemPlacedFX = ReplicatedStorage.Events:WaitForChild("ItemPlacedFX")
local ItemRemovedFX = ReplicatedStorage.Events:WaitForChild("ItemRemovedFX")
local SoundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local PlaceSound = SoundsFolder:WaitForChild("PlaceSound")
local DeleteSound = SoundsFolder:WaitForChild("DeleteSound")
local BLOCKS_MODELS = ReplicatedStorage:WaitForChild("Blocks")
local TURRETS_MODELS = ReplicatedStorage:FindFirstChild("Turrets")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- The Controller Object
local PlacementHandler = {}
local inventoryState = Instance.new("StringValue")
PlacementHandler.InventoryState = inventoryState

local placeButton: GuiButton?
local deleteButton: GuiButton?

PlacementHandler.State = {
	isActive = false,
	isDeleteMode = false,
	ghostModel = nil,
	currentItemId = nil,
	currentRotation = 0,
	canPlace = false,
	playerPlot = nil,
	highlightedItem = nil,
	currentInventory = {},
	originalRangePartTransparency = nil,
	selectionBox = nil,
	highlightColor = nil,
}
function PlacementHandler:GetInventory()
	return self.State.currentInventory
end

local GRID_SIZE = 4
local ROTATION_INCREMENT = 90
local GHOST_ITEM_TRANSPARENCY = 0.7
local DELETE_HIGHLIGHT_TRANSPARENCY = 0.3
local HIDDEN_POSITION = CFrame.new(0, -1000, 0)
local VALID_COLOR = Color3.fromRGB(0, 255, 0)
local INVALID_COLOR = Color3.fromRGB(255, 0, 0)
local GHOST_ITEM_TAG = "ClientGhostItem"
local Plane = {}
Plane.__index = Plane
function Plane.new(position, normal) return setmetatable({Position = position, Normal = normal.unit}, Plane) end
function Plane:RayIntersection(ray: Ray)
	local denominator = ray.Direction:Dot(self.Normal)
	if math.abs(denominator) > 0.0001 then
		local t = (self.Position - ray.Origin):Dot(self.Normal) / denominator
		if t >= 0 then return ray.Origin + ray.Direction * t end
	end
	return nil
end
local function findMyPlot()
	for _, plot in ipairs(Workspace.Plots:GetChildren()) do
		if plot:IsA("Model") and plot:GetAttribute("OwnerId") == player.UserId then
			return plot
		end
	end
	return nil
end

local function _PlaceCurrentItem()
	local State = PlacementHandler.State
	if not State.isActive or State.isDeleteMode then return end
	if not State.canPlace then
		NotificationManager.show("Not enough space!", "Error")
		return
	end
	local currentItemId = State.currentItemId
	if currentItemId then
		local ownedCount = State.currentInventory[currentItemId] or 0
		if ownedCount <= 0 then
			NotificationManager.show("Not enough stock!", "Error")
			FrameManager.open("Inventory")
			PlacementHandler:ExitAllModes()
			return
		end
	end
	if State.canPlace and State.ghostModel and currentItemId then
		PlaceItemEvent:FireServer(currentItemId, State.ghostModel:GetPrimaryPartCFrame(), State.playerPlot)
	end
end

local function _DeleteSelectedItem()
	local State = PlacementHandler.State
	if not State.isDeleteMode then return end

	if State.highlightedItem and State.highlightedItem.Model then
		RemoveItemEvent:FireServer(State.highlightedItem.Model)
	end
end

local function setGhostColor(model: Model, color: Color3)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "PlacementBox" and part.Name ~= "RangePart" then
			part.Color = color
		end
	end
end
function PlacementHandler:ExitAllModes()
	local State = self.State
	State.isActive = false
	State.isDeleteMode = false
	if State.ghostModel then
		local rangePart = State.ghostModel:FindFirstChild("RangePart")
		if rangePart and rangePart:IsA("BasePart") then
			rangePart.Transparency = State.originalRangePartTransparency or 1
		end
		State.ghostModel:Destroy()
		State.ghostModel = nil
	end
	if State.selectionBox then
		State.selectionBox:Destroy()
		State.selectionBox = nil
	end
	if State.highlightedItem then
		local item = State.highlightedItem
		for part, originalProperties in pairs(item.OriginalProperties) do
			if part and part.Parent then 
				part.Color = originalProperties.Color
				part.Transparency = originalProperties.Transparency
			end
		end
		State.highlightedItem = nil
	end
	State.currentItemId = nil
	State.currentRotation = 0
	State.originalRangePartTransparency = nil
	State.highlightColor = nil
end

function PlacementHandler:EnterPlacementMode(itemId: string)
	self:ExitAllModes()
	local template = BLOCKS_MODELS:FindFirstChild(itemId) or TURRETS_MODELS:FindFirstChild(itemId)
	if not (template and template.PrimaryPart) then return end
	local ghost = template:Clone()
	CollectionService:AddTag(ghost, GHOST_ITEM_TAG)
	for _, part in ipairs(ghost:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "PlacementBox" then
			part.Transparency = GHOST_ITEM_TRANSPARENCY
			part.CanCollide = false
			part.Anchored = true
		end
	end
	local placementBox = ghost:FindFirstChild("PlacementBox")
	if placementBox and placementBox:IsA("BasePart") then
		placementBox.Transparency = 1
	else
		warn("Placement mode: Ghost model missing 'PlacementBox' part:", itemId)
	end

	-- ## MODIFIED ## Look for the item's config in the new master table
	local itemConfig = AllItemConfigs[itemId]

	if itemConfig and itemConfig.Type == "Turrets" then
		local rangePart = ghost:FindFirstChild("RangePart")
		if rangePart and rangePart:IsA("BasePart") and itemConfig.Range then
			local radius = itemConfig.Range
			local diameter = radius * 2
			self.State.originalRangePartTransparency = rangePart.Transparency
			rangePart.Size = Vector3.new(0.25, diameter, diameter)
			rangePart.Transparency = GHOST_ITEM_TRANSPARENCY
			rangePart.CanCollide = false
		end
	end
	self.State.ghostModel = ghost
	self.State.currentItemId = itemId
	self.State.isActive = true
	self.State.isDeleteMode = false
	ghost.Parent = Workspace
end
function PlacementHandler:EnterDeleteMode()
	if self.State.isDeleteMode then
		self:ExitAllModes()
	else
		self:ExitAllModes()
		self.State.isActive = true
		self.State.isDeleteMode = true
	end
end


function PlacementHandler:_UpdatePlacementPreview()
	local guiObjects = playerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
	local isOverInteractiveGui = false
	for _, object in ipairs(guiObjects) do
		if object:IsA("GuiButton") then
			isOverInteractiveGui = true
			break
		end
	end
	if isOverInteractiveGui then
		return
	end

	local State = self.State
	if not (State.ghostModel and State.ghostModel.PrimaryPart and State.playerPlot) then return end
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local plotBase = State.playerPlot:FindFirstChild("Base")
	if not plotBase then return end
	local plane = Plane.new(plotBase.Position, plotBase.CFrame.UpVector)
	local cameraRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
	local hitPos = plane:RayIntersection(cameraRay)
	if not hitPos then
		State.ghostModel:SetPrimaryPartCFrame(HIDDEN_POSITION)
		State.canPlace = false
		if State.selectionBox and State.highlightColor ~= INVALID_COLOR then
			State.selectionBox.Color3 = INVALID_COLOR
			State.highlightColor = INVALID_COLOR
		end
		return
	end

	local plotCFrame = plotBase.CFrame:ToObjectSpace(CFrame.new(hitPos))
	local halfPlotSize = plotBase.Size / 2
	local placementBox = State.ghostModel:FindFirstChild("PlacementBox")
	if not placementBox then return end

	local boxSize = placementBox.Size
	local shiftedX = plotCFrame.X + halfPlotSize.X
	local snappedCornerX = math.floor(shiftedX / GRID_SIZE) * GRID_SIZE
	local x = (snappedCornerX + boxSize.X / 2) - halfPlotSize.X
	local shiftedZ = plotCFrame.Z + halfPlotSize.Z
	local snappedCornerZ = math.floor(shiftedZ / GRID_SIZE) * GRID_SIZE
	local z = (snappedCornerZ + boxSize.Z / 2) - halfPlotSize.Z
	local halfBoxSize = boxSize / 2
	x = math.clamp(x, -halfPlotSize.X + halfBoxSize.X, halfPlotSize.X - halfBoxSize.X)
	z = math.clamp(z, -halfPlotSize.Z + halfBoxSize.Z, halfPlotSize.Z - halfBoxSize.Z)
	local y = (halfPlotSize.Y) + (State.ghostModel.PrimaryPart.Size.Y / 2)
	local targetPos = plotBase.CFrame * CFrame.new(x, y, z)
	State.ghostModel:SetPrimaryPartCFrame(targetPos * CFrame.Angles(0, math.rad(State.currentRotation), 0))

	local isOverlappingItem = false
	local isTouchingPath = false

	if placementBox then
		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = {State.ghostModel}
		local partsInBox = Workspace:GetPartsInPart(placementBox, overlapParams)

		local pathFolder = State.playerPlot:FindFirstChild("Path")
		-- NOUVEAU : On cherche le bâtiment Core1
		local coreBuilding = State.playerPlot:FindFirstChild("Core1")

		for _, part in ipairs(partsInBox) do
			local model = part:FindFirstAncestorOfClass("Model")

			-- Condition 1 : Touche un objet posé ou le Core1
			if (model and model:GetAttribute("IsPlacedItem")) or (coreBuilding and part:IsDescendantOf(coreBuilding)) or part.Name == "Core1" then
				isOverlappingItem = true
			end

			-- Condition 2 : Touche le chemin
			if pathFolder and part:IsDescendantOf(pathFolder) then
				isTouchingPath = true
			end
		end
	end

	-- Différenciation Block / Tourelle
	local itemConfig = AllItemConfigs[State.currentItemId]
	local isTurret = (itemConfig and itemConfig.Type == "Turrets")

	if isTurret then
		-- Tourelles: Ne doit PAS toucher le chemin, ne rien chevaucher
		State.canPlace = not isTouchingPath and not isOverlappingItem
	else
		-- Blocks: Doit OBLIGATOIREMENT toucher le chemin, ne rien chevaucher
		State.canPlace = isTouchingPath and not isOverlappingItem
	end

	if not State.selectionBox then
		State.selectionBox = Instance.new("SelectionBox")
		State.selectionBox.LineThickness = 0.2
		State.selectionBox.SurfaceColor3 = VALID_COLOR
		State.selectionBox.Color3 = VALID_COLOR
		State.selectionBox.Transparency = 0
		State.selectionBox.Adornee = placementBox
		State.selectionBox.Parent = placementBox
		State.highlightColor = VALID_COLOR
	end
	local targetColor = State.canPlace and VALID_COLOR or INVALID_COLOR
	if State.highlightColor ~= targetColor then
		State.selectionBox.Color3 = targetColor
		State.highlightColor = targetColor
	end
end

function PlacementHandler:_UpdateDeleteHighlight()
	local guiObjects = playerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
	local isOverInteractiveGui = false
	for _, object in ipairs(guiObjects) do
		if object:IsA("GuiButton") then
			isOverInteractiveGui = true
			break
		end
	end
	if isOverInteractiveGui then
		return
	end

	local State = self.State
	local targetPart = mouse.Target
	local topLevelModel: Model? = nil
	if targetPart and State.playerPlot then
		local currentAncestor = targetPart
		while currentAncestor and currentAncestor.Parent ~= State.playerPlot do
			currentAncestor = currentAncestor.Parent
		end
		if currentAncestor and currentAncestor:GetAttribute("IsPlacedItem") then
			topLevelModel = currentAncestor
		end
	end
	if State.highlightedItem and State.highlightedItem.Model ~= topLevelModel then
		for part, originalProperties in pairs(State.highlightedItem.OriginalProperties) do
			if part and part.Parent then
				part.Color = originalProperties.Color
				part.Transparency = originalProperties.Transparency
			end
		end
		if State.selectionBox then
			State.selectionBox:Destroy()
			State.selectionBox = nil
		end
		State.highlightedItem = nil
	end
	if topLevelModel and not State.highlightedItem then
		local originalProperties = {}
		local placementBox = topLevelModel:FindFirstChild("PlacementBox")
		for _, part in ipairs(topLevelModel:GetDescendants()) do
			if part:IsA("BasePart") then
				originalProperties[part] = {Color = part.Color, Transparency = part.Transparency}
				part.Color = INVALID_COLOR
				if part.Name == "PlacementBox" then
					part.Transparency = 1
				else
					part.Transparency = DELETE_HIGHLIGHT_TRANSPARENCY
				end
			end
		end
		State.highlightedItem = {Model = topLevelModel, OriginalProperties = originalProperties}
		if placementBox and not State.selectionBox then
			State.selectionBox = Instance.new("SelectionBox")
			State.selectionBox.LineThickness = 0.2
			State.selectionBox.Color3 = INVALID_COLOR
			State.selectionBox.Transparency = 0
			State.selectionBox.Adornee = placementBox
			State.selectionBox.Parent = placementBox
			State.highlightColor = INVALID_COLOR
		end
	end
	if not topLevelModel and State.selectionBox then
		State.selectionBox:Destroy()
		State.selectionBox = nil
	end
end

function PlacementHandler:_Update()
	local State = self.State

	if UserInputService.TouchEnabled then
		if placeButton then
			placeButton.Visible = (State.isActive and not State.isDeleteMode)
		end
		if deleteButton then
			deleteButton.Visible = State.isDeleteMode
		end
	end

	if not State.isActive then return end

	if State.playerPlot and not State.playerPlot.Parent then
		State.playerPlot = nil
	end
	if not State.playerPlot then
		State.playerPlot = findMyPlot()
		if not State.playerPlot then return end
	end
	if State.isDeleteMode then
		self:_UpdateDeleteHighlight()
	else
		self:_UpdatePlacementPreview()
	end
end

function PlacementHandler:_HandleInput(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end
	local State = self.State
	if State.isDeleteMode then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin then
			if not UserInputService.TouchEnabled then
				_DeleteSelectedItem()
			end
		elseif input.KeyCode == Enum.KeyCode.Q and input.UserInputState == Enum.UserInputState.Begin then
			self:ExitAllModes()
		end
	elseif State.isActive and not State.isDeleteMode then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin then
			if not UserInputService.TouchEnabled then
				_PlaceCurrentItem()
			end
		elseif input.KeyCode == Enum.KeyCode.R and input.UserInputState == Enum.UserInputState.Begin then
			State.currentRotation = (State.currentRotation + ROTATION_INCREMENT) % 360
		elseif input.KeyCode == Enum.KeyCode.Q and input.UserInputState == Enum.UserInputState.Begin then
			self:ExitAllModes()
		end
	end
end

function PlacementHandler:Init()
	RunService.Heartbeat:Connect(function() self:_Update() end)
	UserInputService.InputBegan:Connect(function(i, gp) self:_HandleInput(i, gp) end)

	local hud = playerGui:WaitForChild("GUI"):WaitForChild("HUD")

	placeButton = hud:FindFirstChild("PlaceButton")
	if placeButton then
		if UserInputService.TouchEnabled then
			placeButton.MouseButton1Click:Connect(_PlaceCurrentItem)
		end
		placeButton.Visible = false
	end

	deleteButton = hud:FindFirstChild("DeleteButton")
	if deleteButton then
		if UserInputService.TouchEnabled then
			deleteButton.MouseButton1Click:Connect(_DeleteSelectedItem)
		end
		deleteButton.Visible = false
	end

	ItemPlacedFX.OnClientEvent:Connect(function() PlaceSound:Play() end)
	ItemRemovedFX.OnClientEvent:Connect(function() DeleteSound:Play() end)

	blockInventoryUpdatedEvent.OnClientEvent:Connect(function(newInventory)
		self.State.currentInventory = newInventory
		inventoryState.Value = HttpService:JSONEncode(newInventory)
		if self.State.isActive and not self.State.isDeleteMode and self.State.currentItemId then
			if (self.State.currentInventory[self.State.currentItemId] or 0) <= 0 then
				self:ExitAllModes()
				FrameManager.open("Inventory")
			end
		end
	end)

	local success, initialInventory = pcall(function()
		return getBlockInventoryFunc:InvokeServer()
	end)
	if success and initialInventory then
		self.State.currentInventory = initialInventory
		inventoryState.Value = HttpService:JSONEncode(initialInventory)
	else
		warn("[PlacementHandler] Failed to get initial inventory. Error:", tostring(initialInventory))
	end
end

return PlacementHandler