local TweenService       = game:GetService("TweenService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

local SpinWheelEvent     = ReplicatedStorage:WaitForChild("SpinWheelEvent")
local WheelCooldownEvent = ReplicatedStorage:WaitForChild("WheelCooldownEvent")

local gui           = script.Parent
local main          = gui:WaitForChild("Main")
local wheelBg       = main:WaitForChild("Wheel"):WaitForChild("WheelBg")
local spinButton    = main:WaitForChild("Spin")
local closeButton   = main:WaitForChild("CloseButton")
local fastToggle    = main:WaitForChild("FastSpinToggle")
local ratesToggle   = main:WaitForChild("RatesToggle")
local nextFreeLabel = spinButton:WaitForChild("NextFreeSpin")
local spinAmount    = spinButton:WaitForChild("SpinAmount")

local model            = workspace:WaitForChild("SpinWheel")
local surfaceWheelBg   = model:WaitForChild("Part1"):WaitForChild("SurfaceGui"):WaitForChild("Wheel"):WaitForChild("WheelBg")
local billboard        = model:WaitForChild("UI"):WaitForChild("BillboardGui")
local billboardWheelBg = billboard:WaitForChild("Wheel"):WaitForChild("WheelBg")
local billboardTime    = billboard:WaitForChild("Time")
local billboardTimeShadow = billboardTime:FindFirstChild("_Shadow")

local spinPad          = workspace:WaitForChild("SpinPad")

local isSpinning   = false
local isFastSpin   = false
local isOnCooldown = false

-- ⚡ On s'assure que tout est bien caché au lancement
gui.Enabled = false 
main.Visible = false

-- ==========================================
-- SYNC RECOMPENSES : SurfaceGui -> ScreenGui
-- ==========================================
local propMap = {{"ImageLabel","Image"},{"ItemName","Text"},{"Rate","Text"},{"Rarity","Text"}}
for i = 1, 8 do
	local src  = surfaceWheelBg:FindFirstChild("Item"..i)
	local dest = wheelBg:FindFirstChild("Item"..i)
	if src and dest then
		for _,p in ipairs(propMap) do
			local s = src:FindFirstChild(p[1])
			local d = dest:FindFirstChild(p[1])
			if s and d then d[p[2]] = s[p[2]] end
		end
	end
end

-- ==========================================
-- AFFICHAGE DES POURCENTAGES SUR LA ROUE
-- ==========================================
local chancesTextes = {
	Item1 = "40%",
	Item2 = "25%",
	Item3 = "15%",
	Item6 = "10%",
	Item8 = "5%",
	Item7 = "3%",
	Item5 = "1.5%",
	Item4 = "0.5%"
}

local ratesVisible = false
for i = 1, 8 do
	local itemName = "Item"..i
	local item = wheelBg:FindFirstChild(itemName)
	local rate = item and item:FindFirstChild("Rate")

	if rate then 
		rate.Text = chancesTextes[itemName] or "?%"
		rate.Visible = false 
	end
end

ratesToggle.MouseButton1Click:Connect(function()
	ratesVisible = not ratesVisible
	for i = 1, 8 do
		local item = wheelBg:FindFirstChild("Item"..i)
		local rate = item and item:FindFirstChild("Rate")
		if rate then rate.Visible = ratesVisible end
	end

	local ck = ratesToggle:FindFirstChild("Checkmark")
	if ck then ck.Visible = ratesVisible end
end)

-- ==========================================
-- IDLE ROTATION H24
-- ==========================================
local IDLE_SPEED = 12
local idleConn, idleBase, idleStart = nil, 0, 0
local function startIdle()
	idleBase = wheelBg.Rotation; idleStart = tick()
	if idleConn then idleConn:Disconnect() end
	idleConn = RunService.Heartbeat:Connect(function()
		local rot = idleBase + (tick() - idleStart) * IDLE_SPEED
		wheelBg.Rotation = rot
		surfaceWheelBg.Rotation = rot
		billboardWheelBg.Rotation = rot
	end)
end
local function stopIdle()
	if idleConn then idleConn:Disconnect(); idleConn = nil end
end
startIdle()

-- ==========================================
-- TIMER 30 MIN
-- ==========================================
local cancelTimer = nil
local function formatTime(s)
	return string.format("%02d:%02d", math.floor(s/60), s%60)
end
local function setTimerText(txt)
	nextFreeLabel.Text = txt
	billboardTime.Text = txt
	if billboardTimeShadow then billboardTimeShadow.Text = txt end
end

setTimerText("Chargement...")

local function startCooldown(seconds)
	isOnCooldown = true
	spinButton.Active = false
	if cancelTimer then cancelTimer() end
	local cancelled = false
	cancelTimer = function() cancelled = true end
	local rem = math.floor(seconds)

	task.spawn(function()
		while rem > 0 and not cancelled do
			setTimerText(formatTime(rem))
			task.wait(1)
			rem = rem - 1
		end
		if not cancelled then
			isOnCooldown = false
			spinButton.Active = true
			setTimerText("1 Free Spin")
		end
	end)
end

WheelCooldownEvent.OnClientEvent:Connect(function(remaining)
	startCooldown(remaining)
end)

-- ==========================================
-- FREESPINS & ROBUX SPINS (UI COUNT)
-- ==========================================
-- ==========================================
-- FREESPINS & ROBUX SPINS (UI COUNT)
-- ==========================================
local localPlayer = Players.LocalPlayer
task.spawn(function()
	local freeSpins = localPlayer:WaitForChild("FreeSpins", 10)
	local robuxSpins = localPlayer:WaitForChild("RobuxSpins", 10)
	if not freeSpins or not robuxSpins then return end

	-- Cette variable vérifie si l'interface est "réveillée" ou non.
	local hasLoadedFromSave = false

	local function updateSpinCount()
		local totalSpins = freeSpins.Value + robuxSpins.Value
		spinAmount.Text = tostring(totalSpins)

		if totalSpins > 0 then
			setTimerText(totalSpins .. " Free Spin" .. (totalSpins > 1 and "s" or ""))
			isOnCooldown = false
			spinButton.Active = true
			if cancelTimer then cancelTimer() end
		else
			-- On met à jour l'état que s'il n'y a pas de cooldown en cours et qu'on a déjà chargé.
			if not isOnCooldown and hasLoadedFromSave then
				setTimerText("Attente...")
			end
		end
	end

	-- L'astuce est ici : on n'affiche plus "Attente..." si le joueur vient de se connecter et que la sauvegarde est en cours
	if freeSpins.Value > 0 or robuxSpins.Value > 0 then
		hasLoadedFromSave = true
		updateSpinCount()
	end

	freeSpins.Changed:Connect(function()
		hasLoadedFromSave = true
		updateSpinCount()
	end)

	robuxSpins.Changed:Connect(function()
		hasLoadedFromSave = true
		updateSpinCount()
	end)
end)

-- ==========================================
-- DISTANCE AUTO-CLOSE
-- ==========================================
local MAX_DIST = 18
RunService.Heartbeat:Connect(function()
	if not main.Visible then return end
	local char = localPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")

	-- Ferme le menu si le joueur s'éloigne trop du SpinPad
	if hrp and (hrp.Position - spinPad.Position).Magnitude > MAX_DIST then
		main.Visible = false
		gui.Enabled = false -- ⚡ On s'assure que le ScreenGui se désactive !
	end
end)

-- ==========================================
-- HOVER BOUTONS
-- ==========================================
local function addHover(btn)
	if not btn then return end
	local sc = btn:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", btn)
	btn.MouseEnter:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.08}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1.0}):Play()
	end)
end
addHover(spinButton); addHover(closeButton); addHover(fastToggle); addHover(ratesToggle)

-- =====================================
-- ACHAT DE SPINS (ROBUX) & AFFICHAGE PRIX
-- =====================================
local ROBUX_ICON = "\xee\x80\x82"

local ID_1_SPIN   = 3710799997
local ID_3_SPINS  = 3710800155
local ID_10_SPINS = 3710800204

local btn1Spin  = main:WaitForChild("1SpinRbx")
local btn3Spin  = main:WaitForChild("3SpinRbx")
local btn10Spin = main:WaitForChild("10SpinRbx")

addHover(btn1Spin)
addHover(btn3Spin)
addHover(btn10Spin)

local function actualiserPrix(bouton, idProduit)
	local textePrix = bouton:FindFirstChild("RobuxPrice")
	if textePrix then
		task.spawn(function()
			local succes, info = pcall(function()
				return MarketplaceService:GetProductInfo(idProduit, Enum.InfoType.Product)
			end)
			if succes and info and info.PriceInRobux then
				textePrix.Text = ROBUX_ICON .. info.PriceInRobux
			end
		end)
	end
end

actualiserPrix(btn1Spin, ID_1_SPIN)
actualiserPrix(btn3Spin, ID_3_SPINS)
actualiserPrix(btn10Spin, ID_10_SPINS)

btn1Spin.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(localPlayer, ID_1_SPIN)
end)

btn3Spin.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(localPlayer, ID_3_SPINS)
end)

btn10Spin.MouseButton1Click:Connect(function()
	MarketplaceService:PromptProductPurchase(localPlayer, ID_10_SPINS)
end)

-- ==========================================
-- OUVRIR AVEC LE SPINPAD / FERMER / FAST SPIN
-- ==========================================
local touchDebounce = false

spinPad.Touched:Connect(function(hit)
	if touchDebounce then return end

	local char = localPlayer.Character
	if char and hit:IsDescendantOf(char) then
		touchDebounce = true

		-- Ouvre le menu si ce n'est pas déjà fait
		if not main.Visible then
			gui.Enabled = true -- ⚡ On réactive de force le ScreenGui pour le rendre visible !
			main.Visible = true
		end

		task.wait(0.5) 
		touchDebounce = false
	end
end)

closeButton.MouseButton1Click:Connect(function()
	main.Visible = false
	gui.Enabled = false -- ⚡ On redésactive le ScreenGui pour nettoyer l'écran !
end)
fastToggle.MouseButton1Click:Connect(function()
	isFastSpin = not isFastSpin
	local ck = fastToggle:FindFirstChild("Checkmark")
	if ck then ck.Visible = isFastSpin end
end)

-- ==========================================
-- LANCEMENT SPIN
-- ==========================================
spinButton.MouseButton1Click:Connect(function()
	if isSpinning or isOnCooldown then return end
	isSpinning = true
	spinButton.Active = false

	SpinWheelEvent:FireServer(isFastSpin)
end)

-- ==========================================
-- RESULTAT SERVEUR ET ANIMATION
-- ==========================================
SpinWheelEvent.OnClientEvent:Connect(function(targetAngle, itemName)
	local duree      = isFastSpin and 1.5 or 5
	local extraSpins = isFastSpin and (360*3) or (360*5)

	stopIdle()

	local cur   = wheelBg.Rotation
	local base  = cur % 360
	local land  = 360 - targetAngle
	local final = cur + extraSpins + land - base

	local ti = TweenInfo.new(duree, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

	TweenService:Create(wheelBg,        ti, {Rotation=final}):Play()
	TweenService:Create(surfaceWheelBg, ti, {Rotation=final}):Play()

	local tw3 = TweenService:Create(billboardWheelBg, ti, {Rotation=final})
	tw3:Play()

	tw3.Completed:Connect(function()
		isSpinning = false
		startIdle()
	end)
end)