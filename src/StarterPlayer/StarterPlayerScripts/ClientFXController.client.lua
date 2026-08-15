--!strict
-- LOCATION: StarterPlayerScripts/ClientFXController.lua
-- DESCRIPTION: Manages all client-side visual effects, including UI, cash, and in-world FX.

-- Services
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

-- Player and UI
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Modules
local ItemConfigurations = require(ReplicatedStorage.Modules.ItemConfigurations)
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)

-- Templates
local shineTemplate: ImageLabel? = ReplicatedStorage.Templates:WaitForChild("ShineEffectTemplate")


--================================================================
-- ## UI ELEMENT EFFECTS ##
--================================================================
local activeHoverTweens: {[GuiObject]: {Tween}} = {}
local activeShineThreads: {[GuiObject]: thread} = {}
local sunburstObjects: {[GuiObject]: boolean} = {}
local buttonStates: {[GuiObject]: {originalSize: UDim2, originalColor: Color3?}} = {}
local partButtonStates: {[BasePart]: {Debounce: boolean, Connections: {RBXScriptConnection}}} = {}

-- ... (All of the existing UI effect functions like applyButtonAnimation, etc. remain here)
local HOVER_TWEEN_INFO: TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CLICK_TWEEN_INFO: TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
local HOVER_SCALE: number = 1.05
local CLICK_SCALE: number = 0.95
local function getButtonColor(button: GuiButton): Color3?
	if button:IsA("TextButton") then return button.BackgroundColor3 end
	if button:IsA("ImageButton") then return button.ImageColor3 end
	return nil
end
local function tweenColor(button: GuiButton, tweenInfo: TweenInfo, color: Color3)
	local prop = button:IsA("TextButton") and "BackgroundColor3" or "ImageColor3"
	TweenService:Create(button, tweenInfo, {[prop] = color}):Play()
end
local function applyButtonAnimation(button: GuiButton)
	if buttonStates[button] then return end
	buttonStates[button] = { originalSize = button.Size, originalColor = getButtonColor(button) }
	button.MouseEnter:Connect(function()
		local state = buttonStates[button]
		local hoverSize = UDim2.new(state.originalSize.X.Scale * HOVER_SCALE, 0, state.originalSize.Y.Scale * HOVER_SCALE, 0)
		TweenService:Create(button, HOVER_TWEEN_INFO, {Size = hoverSize}):Play()
		if state.originalColor then tweenColor(button, HOVER_TWEEN_INFO, state.originalColor:Lerp(Color3.new(1, 1, 1), 0.1)) end
	end)
	button.MouseLeave:Connect(function()
		local state = buttonStates[button]
		TweenService:Create(button, HOVER_TWEEN_INFO, {Size = state.originalSize}):Play()
		if state.originalColor then tweenColor(button, HOVER_TWEEN_INFO, state.originalColor) end
	end)
	button.MouseButton1Down:Connect(function()
		local state = buttonStates[button]
		local clickSize = UDim2.new(state.originalSize.X.Scale * CLICK_SCALE, 0, state.originalSize.Y.Scale * CLICK_SCALE, 0)
		TweenService:Create(button, CLICK_TWEEN_INFO, {Size = clickSize}):Play()
		if state.originalColor then tweenColor(button, CLICK_TWEEN_INFO, state.originalColor:Lerp(Color3.new(0, 0, 0), 0.2)) end
	end)
	button.MouseButton1Up:Connect(function()
		local state = buttonStates[button]
		local hoverSize = UDim2.new(state.originalSize.X.Scale * HOVER_SCALE, 0, state.originalSize.Y.Scale * HOVER_SCALE, 0)
		TweenService:Create(button, CLICK_TWEEN_INFO, {Size = hoverSize}):Play()
		if state.originalColor then tweenColor(button, CLICK_TWEEN_INFO, state.originalColor:Lerp(Color3.new(1, 1, 1), 0.1)) end
	end)
end
local SUNBURST_ROTATION_SPEED = 20
local function applySunburstEffect(guiObject: GuiObject) sunburstObjects[guiObject] = true end
RunService.Heartbeat:Connect(function(dt: number)
	for guiObject, _ in pairs(sunburstObjects) do
		if guiObject.Parent then guiObject.Rotation += SUNBURST_ROTATION_SPEED * dt else sunburstObjects[guiObject] = nil end
	end
end)
local HOVER_OFFSET = 5
local HOVER_DURATION = 1.5
local HOVER_TWEEN_INFO_EFFECT = TweenInfo.new(HOVER_DURATION / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local function applyHoverEffect(guiObject: GuiObject)
	local originalPosition = guiObject.Position
	local targetPositionUp = originalPosition + UDim2.fromOffset(0, -HOVER_OFFSET)
	local tweenUp = TweenService:Create(guiObject, HOVER_TWEEN_INFO_EFFECT, {Position = targetPositionUp})
	local tweenDown = TweenService:Create(guiObject, HOVER_TWEEN_INFO_EFFECT, {Position = originalPosition})
	activeHoverTweens[guiObject] = {tweenUp, tweenDown}
	task.spawn(function()
		while guiObject.Parent do
			tweenUp:Play()
			tweenUp.Completed:Wait()
			if not guiObject.Parent then break end
			tweenDown:Play()
			tweenDown.Completed:Wait()
		end
		if activeHoverTweens[guiObject] then
			for _, tween in ipairs(activeHoverTweens[guiObject]) do tween:Cancel() end
			activeHoverTweens[guiObject] = nil
		end
	end)
end
local SHINE_MIN_DELAY, SHINE_MAX_DELAY, SHINE_FADE_IN_TIME, SHINE_FADE_OUT_TIME = 1, 4, 0.3, 0.7
local function applyShineEffect(guiObject: GuiObject)
	if not shineTemplate then return end
	activeShineThreads[guiObject] = task.spawn(function()
		while guiObject.Parent do
			task.wait(math.random() * (SHINE_MAX_DELAY - SHINE_MIN_DELAY) + SHINE_MIN_DELAY)
			if not guiObject.Parent then break end
			local newShine = shineTemplate:Clone()
			newShine.Position = UDim2.fromScale(math.random(), math.random())
			newShine.ImageTransparency = 1
			newShine.Rotation = math.random(-45, 45)
			newShine.Parent = guiObject
			local fadeIn = TweenService:Create(newShine, TweenInfo.new(SHINE_FADE_IN_TIME), {ImageTransparency = 0})
			local fadeOut = TweenService:Create(newShine, TweenInfo.new(SHINE_FADE_OUT_TIME), {ImageTransparency = 1})
			fadeIn:Play()
			fadeIn.Completed:Wait()
			if not newShine.Parent then break end
			fadeOut:Play()
			fadeOut.Completed:Wait()
			newShine:Destroy()
		end
	end)
end
local PRESS_DEPTH, PRESS_TWEEN_INFO, POP_UP_TWEEN_INFO = 0.4, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local function applyPressEffect(part: BasePart)
	if not part:IsA("BasePart") or partButtonStates[part] then return end
	local originalPosition = part.Position
	partButtonStates[part] = { Debounce = false, Connections = {} }
	local conn = part.Touched:Connect(function(hit)
		if partButtonStates[part].Debounce or not (localPlayer.Character and hit:IsDescendantOf(localPlayer.Character)) then return end
		partButtonStates[part].Debounce = true
		local press = TweenService:Create(part, PRESS_TWEEN_INFO, { Position = originalPosition - Vector3.new(0, PRESS_DEPTH, 0) })
		press:Play()
		press.Completed:Wait()
		local popUp = TweenService:Create(part, POP_UP_TWEEN_INFO, { Position = originalPosition })
		popUp:Play()
		popUp.Completed:Wait()
		partButtonStates[part].Debounce = false
	end)
	table.insert(partButtonStates[part].Connections, conn)
end

--================================================================
-- ## MODEL HOVER EFFECT ##
--================================================================
local activeModelHoverTweens = {}
local MODEL_HOVER_OFFSET = 0.5
local MODEL_HOVER_DURATION = 2
local MODEL_HOVER_TWEEN_INFO = TweenInfo.new(MODEL_HOVER_DURATION / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function applyModelHoverEffect(model: Model)
	-- ## MODIFIED ## Added a 1-second delay
	task.wait(1)

	-- Added model.Parent check in case the model is destroyed during the delay
	if not model:IsA("Model") or not model.Parent or not model.PrimaryPart then
		return
	end

	local primaryPart = model.PrimaryPart
	local originalCFrame = primaryPart.CFrame
	local targetCFrameUp = originalCFrame * CFrame.new(0, MODEL_HOVER_OFFSET, 0)

	local tweenUp = TweenService:Create(primaryPart, MODEL_HOVER_TWEEN_INFO, {CFrame = targetCFrameUp})
	local tweenDown = TweenService:Create(primaryPart, MODEL_HOVER_TWEEN_INFO, {CFrame = originalCFrame})

	activeModelHoverTweens[model] = {tweenUp, tweenDown}

	task.spawn(function()
		while model.Parent do
			tweenUp:Play()
			tweenUp.Completed:Wait()
			if not model.Parent then break end
			tweenDown:Play()
			tweenDown.Completed:Wait()
		end
		if activeModelHoverTweens[model] then
			for _, tween in ipairs(activeModelHoverTweens[model]) do tween:Cancel() end
			activeModelHoverTweens[model] = nil
		end
	end)
end

local function cleanupModelHoverEffect(model: Model)
	if activeModelHoverTweens[model] then
		for _, tween in ipairs(activeModelHoverTweens[model]) do
			tween:Cancel()
		end
		activeModelHoverTweens[model] = nil
	end
end

-- ... (The rest of the script, including Cash Animation, Item Damage, etc., is unchanged)
--================================================================
-- ## CASH ANIMATION, ITEM DAMAGE, TURRET FX, ZOMBIE HIGHLIGHTS ##
--================================================================
local cashAmountLabel = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Cash"):WaitForChild("Amount")
local oldCashValue = 0
local cashAnimConnection: RBXScriptConnection?
local function animateCashIncrease(startValue: number, endValue: number)
	local duration, startTime, delta = 0.5, os.clock(), endValue - startValue
	if cashAnimConnection then cashAnimConnection:Disconnect() end
	cashAnimConnection = RunService.Heartbeat:Connect(function()
		local progress = math.min((os.clock() - startTime) / duration, 1)
		local alpha = TweenService:GetValue(progress, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		cashAmountLabel.Text = NumberFormatter.formatNumber(math.floor(startValue + delta * alpha), "$")
		if progress >= 1 then
			if cashAnimConnection then cashAnimConnection:Disconnect() cashAnimConnection = nil end
		end
	end)
end
task.spawn(function()
	local leaderstats = localPlayer:WaitForChild("leaderstats")
	local cash = leaderstats:WaitForChild("Cash")
	oldCashValue = cash.Value
	cashAmountLabel.Text = NumberFormatter.formatNumber(cash.Value, "$")
	cash.Changed:Connect(function(newValue)
		if newValue > oldCashValue then animateCashIncrease(oldCashValue, newValue) else cashAmountLabel.Text = NumberFormatter.formatNumber(newValue, "$") end
		oldCashValue = newValue
	end)
end)
local itemDamageData = {}
local function updateItemColor(itemModel: Instance)
	local data = itemDamageData[itemModel]
	if not data then return end
	local config = ItemConfigurations[itemModel.Name]
	local currentHealth = itemModel:GetAttribute("Health")
	if not (config and config.Health and typeof(currentHealth) == "number") then return end

	local healthPercent = math.clamp(currentHealth / config.Health, 0, 1)
	local lerpAlpha = (1 - healthPercent) * 0.8
	for part, originalColor in pairs(data.originalColors) do
		if part.Parent then part.Color = originalColor:Lerp(Color3.new(0, 0, 0), lerpAlpha) end
	end
end
local function setupItemVFX(itemModel: Instance)
	if itemDamageData[itemModel] or not itemModel:GetAttribute("IsPlacedItem") then return end
	local config = ItemConfigurations[itemModel.Name]
	if not (itemModel:IsA("Model") and config and config.Health) then return end

	local data = { originalColors = {}, healthConnection = nil }
	for _, descendant in ipairs(itemModel:GetDescendants()) do
		if descendant:IsA("BasePart") then data.originalColors[descendant] = descendant.Color end
	end
	data.healthConnection = itemModel:GetAttributeChangedSignal("Health"):Connect(function() updateItemColor(itemModel) end)
	itemDamageData[itemModel] = data
	updateItemColor(itemModel)
end
local function cleanupItemVFX(itemModel: Instance)
	local data = itemDamageData[itemModel]
	if data then
		if data.healthConnection then data.healthConnection:Disconnect() end
		itemDamageData[itemModel] = nil
	end
end
task.spawn(function()
	local playerPlot: Model?
	while not playerPlot do
		for _, plot in ipairs(Workspace.Plots:GetChildren()) do
			if plot:IsA("Model") and plot:GetAttribute("OwnerId") == localPlayer.UserId then playerPlot = plot break end
		end
		if not playerPlot then task.wait(1) end
	end
	for _, child in ipairs(playerPlot:GetChildren()) do setupItemVFX(child) end
	playerPlot.ChildAdded:Connect(setupItemVFX)
	playerPlot.ChildRemoved:Connect(cleanupItemVFX)
end)
local turretFiredEvent = ReplicatedStorage.Events:WaitForChild("TurretFiredFX")
local effectsFolder = Workspace:FindFirstChild("Effects") or Instance.new("Folder", Workspace)
effectsFolder.Name = "Effects"
turretFiredEvent.OnClientEvent:Connect(function(turretModel: Model, startPos: Vector3, endPos: Vector3)
	local distance = (startPos - endPos).Magnitude
	local tracer = Instance.new("Part")
	tracer.Anchored, tracer.CanCollide, tracer.CanTouch, tracer.CastShadow = true, false, false, false
	tracer.Color, tracer.Material = Color3.new(1, 1, 0), Enum.Material.Neon
	tracer.Size = Vector3.new(0.1, 0.1, distance)
	tracer.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance / 2)
	tracer.Parent = effectsFolder
	Debris:AddItem(tracer, 0.1)
	if turretModel then
		local fireSound = turretModel:FindFirstChild("FireSound", true)
		if fireSound and fireSound:IsA("Sound") then fireSound:Play() end
	end
end)
local highlightZombieEvent = ReplicatedStorage.Events:WaitForChild("HighlightZombie")
highlightZombieEvent.OnClientEvent:Connect(function(zombieModel: Model)
	if not zombieModel or not zombieModel.Parent then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.Parent = zombieModel
	Debris:AddItem(highlight, 0.2)
end)

--================================================================
-- ## INITIALIZATION ##
--================================================================
local function setupTag(tagName: string, applyFn: (Instance) -> (), cleanupFn: (Instance) -> ())
	for _, instance in ipairs(CollectionService:GetTagged(tagName)) do task.spawn(applyFn, instance) end
	CollectionService:GetInstanceAddedSignal(tagName):Connect(applyFn)
	CollectionService:GetInstanceRemovedSignal(tagName):Connect(cleanupFn)
end
setupTag("ButtonAnimation", applyButtonAnimation, function(inst) buttonStates[inst] = nil end)
setupTag("SunburstEffect", applySunburstEffect, function(inst) sunburstObjects[inst] = nil end)
setupTag("HoverEffect", applyHoverEffect, function(inst) if activeHoverTweens[inst] then for _,t in pairs(activeHoverTweens[inst]) do t:Cancel() end activeHoverTweens[inst] = nil end end)
setupTag("ShineEffect", applyShineEffect, function(inst) if activeShineThreads[inst] then task.cancel(activeShineThreads[inst]) activeShineThreads[inst] = nil end end)
setupTag("PartButton", applyPressEffect, function(inst) if partButtonStates[inst] then for _,c in pairs(partButtonStates[inst].Connections) do c:Disconnect() end partButtonStates[inst] = nil end end)
setupTag("ModelHoverEffect", applyModelHoverEffect, cleanupModelHoverEffect)