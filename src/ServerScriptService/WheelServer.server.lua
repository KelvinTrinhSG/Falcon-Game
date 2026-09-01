local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local DataStoreService   = game:GetService("DataStoreService")
local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerScriptService = game:GetService("ServerScriptService")

local WeaponConfigurations = require(ReplicatedStorage.Modules:WaitForChild("WeaponConfigurations"))

local SpinWheelEvent     = Instance.new("RemoteEvent")
SpinWheelEvent.Name      = "SpinWheelEvent"
SpinWheelEvent.Parent    = ReplicatedStorage

local WheelCooldownEvent = Instance.new("RemoteEvent")
WheelCooldownEvent.Name  = "WheelCooldownEvent"
WheelCooldownEvent.Parent = ReplicatedStorage

local ShowNotificationEvent = ReplicatedStorage.Events:WaitForChild("ShowNotification")

local NB_SEGMENTS   = 8
local ANGLE_SEGMENT = 360 / NB_SEGMENTS
local COOLDOWN      = 1800

local Items = {
	{id="Item1", name="+1 Spin",         chance=40,  type="Spin",  amount=1},
	{id="Item2", name="$2,500 Cash",     chance=25,  type="Cash",  amount=2500},
	{id="Item3", name="Engineer Camera Guy", chance=15, type="Item",  itemId="EngineerCameraGuy"},
	{id="Item4", name="X3 WAVE Pass",    chance=0.5, type="Pass",  itemId="X3WavePass"},
	{id="Item5", name="Titan Crate",      chance=1.5, type="Crate", itemId="TitanCrate"},
	{id="Item6", name="+3 Spins",        chance=10,  type="Spin",  amount=3},
	{id="Item7", name="$7,500 BIG Cash", chance=3,   type="Cash",  amount=7500},
	{id="Item8", name="Plasma Block",    chance=5,   type="Item",  itemId="PlasmaBlock"},
}

local rng = Random.new()
local SpinData      = DataStoreService:GetDataStore("SpinWheelData_v2") 
local derniersSpins = {}
local antiSpamSave  = {} -- ⚡ Le fameux registre Anti-Spam !

local function charger(userId)
	local ok, val = pcall(function() return SpinData:GetAsync("spin_"..userId) end)
	return ok and val or nil
end

local function sauvegarder(userId, tableData)
	pcall(function() SpinData:SetAsync("spin_"..userId, tableData) end)
end

-- ⚡ Nouvelle fonction de sauvegarde sécurisée
local function sauvegarderJoueur(player, forceSave)
	local fs = player:FindFirstChild("FreeSpins")
	local rs = player:FindFirstChild("RobuxSpins")
	if fs and rs then
		local now = os.time()

		-- Si ce n'est pas une sauvegarde forcée, on bloque si ça fait moins de 8 secondes
		if not forceSave and antiSpamSave[player.UserId] and (now - antiSpamSave[player.UserId] < 8) then
			return 
		end
		antiSpamSave[player.UserId] = now

		local dataToSave = {
			LastSpin = derniersSpins[player.UserId] or 0,
			FreeSpins = fs.Value,
			RobuxSpins = rs.Value
		}
		sauvegarder(player.UserId, dataToSave)
	end
end

Players.PlayerAdded:Connect(function(player)
	local fs = Instance.new("IntValue")
	fs.Name   = "FreeSpins"
	fs.Value  = 0
	fs.Parent = player

	local rs = Instance.new("IntValue")
	rs.Name   = "RobuxSpins"
	rs.Value  = 0
	rs.Parent = player

	task.spawn(function()
		task.wait(2)
		if not player or not player.Parent then return end

		local saved = charger(player.UserId)
		local lastSpin = 0
		local freeSpinsVal = 1
		local robuxSpinsVal = 0

		if type(saved) == "table" then
			lastSpin = saved.LastSpin or 0
			freeSpinsVal = saved.FreeSpins or 0
			robuxSpinsVal = saved.RobuxSpins or 0
		elseif type(saved) == "number" then 
			lastSpin = saved
			freeSpinsVal = (os.time() - lastSpin >= COOLDOWN) and 1 or 0
			robuxSpinsVal = 0
		end

		derniersSpins[player.UserId] = lastSpin

		if freeSpinsVal == 0 and lastSpin > 0 then
			local rem = COOLDOWN - (os.time() - lastSpin)
			if rem > 0 then
				WheelCooldownEvent:FireClient(player, rem)
				task.delay(rem, function()
					if player and player.Parent and player:FindFirstChild("FreeSpins") then
						if player.FreeSpins.Value == 0 then
							player.FreeSpins.Value = 1
						end
					end
				end)
			else
				freeSpinsVal = 1
			end
		end

		fs.Value = freeSpinsVal
		rs.Value = robuxSpinsVal
	end)

	task.spawn(function()
		local pcModule = ServerScriptService.Controllers:FindFirstChild("PlayerController")
		while not pcModule do task.wait(0.5) pcModule = ServerScriptService.Controllers:FindFirstChild("PlayerController") end
		local PlayerController = require(pcModule)
		local profile = PlayerController:GetProfile(player)
		while not profile do task.wait(0.5) profile = PlayerController:GetProfile(player) end

		if profile and profile.Data and profile.Data.HasX3WavePass then
			player:SetAttribute("HasX3WavePass", true)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	sauvegarderJoueur(player, true) -- ⚡ Force la sauvegarde en quittant
	derniersSpins[player.UserId] = nil
	antiSpamSave[player.UserId] = nil
end)

local function rollItem()
	local totalChance = 0
	for _, item in ipairs(Items) do
		totalChance = totalChance + item.chance
	end

	local randomNum = rng:NextNumber(0, totalChance)
	local current = 0

	for index, item in ipairs(Items) do
		current = current + item.chance
		if randomNum <= current then
			return index, item
		end
	end
	return 1, Items[1]
end

SpinWheelEvent.OnServerEvent:Connect(function(player, isFastSpin)
	local fs = player:FindFirstChild("FreeSpins")
	local rs = player:FindFirstChild("RobuxSpins")
	if not fs or not rs then return end

	local isLucky = false

	if rs.Value > 0 then
		rs.Value = rs.Value - 1
		isLucky = true
	elseif fs.Value > 0 then
		fs.Value = fs.Value - 1

		if fs.Value == 0 then
			local now = os.time()
			derniersSpins[player.UserId] = now
			WheelCooldownEvent:FireClient(player, COOLDOWN)
		end
	else
		return
	end

	local finalIndex, finalItem = rollItem()

	if isLucky then
		local index2, item2 = rollItem()
		if item2.chance < finalItem.chance then
			finalIndex = index2
			finalItem = item2
		end
	end

	local angle = (finalIndex-1)*ANGLE_SEGMENT + ANGLE_SEGMENT/2
	SpinWheelEvent:FireClient(player, angle, finalItem.id)

	local tempsAnimation = isFastSpin and 1.5 or 5

	task.delay(tempsAnimation, function()
		if not player or not player.Parent then return end

		local message = "🎉 You won: " .. finalItem.name .. "!"
		local colorTheme = finalItem.chance <= 5 and "Mythical" or "Success"
		ShowNotificationEvent:FireClient(player, message, colorTheme)

		if finalItem.type == "Spin" then
			player.FreeSpins.Value = player.FreeSpins.Value + finalItem.amount

		elseif finalItem.type == "Cash" then
			local leaderstats = player:FindFirstChild("leaderstats")
			local cash = leaderstats and leaderstats:FindFirstChild("Cash")
			if cash then cash.Value += finalItem.amount end

		elseif finalItem.type == "Item" or finalItem.type == "Crate" or finalItem.type == "Pass" then
			local pcModule = ServerScriptService.Controllers:FindFirstChild("PlayerController")
			if pcModule then
				local PlayerController = require(pcModule)
				local profile = PlayerController:GetProfile(player)
				if profile then

					if finalItem.type == "Item" then
						profile.Data.BlockInventory[finalItem.itemId] = (profile.Data.BlockInventory[finalItem.itemId] or 0) + 1
						ReplicatedStorage.Events.BlockInventoryUpdated:FireClient(player, profile.Data.BlockInventory)

					elseif finalItem.type == "Crate" then
						if finalItem.itemId == "TitanCrate" then
							local config = WeaponConfigurations.Crates.TitanCrate
							if config and config.Loot then
								local lootTable = config.Loot
								local totalWeight = 0
								for _, loot in ipairs(lootTable) do totalWeight += loot.Weight end
								local roll = math.random() * totalWeight
								local chosenWeaponId = lootTable[#lootTable].Item
								for _, loot in ipairs(lootTable) do
									if roll <= loot.Weight then chosenWeaponId = loot.Item; break else roll -= loot.Weight end
								end
								if chosenWeaponId and not table.find(profile.Data.WeaponInventory, chosenWeaponId) then
									table.insert(profile.Data.WeaponInventory, chosenWeaponId)
								end
								local weaponConfig = WeaponConfigurations.Weapons[chosenWeaponId]
								if weaponConfig then
									ReplicatedStorage.Events.ShowModelAward:FireClient(player, weaponConfig.DisplayName, weaponConfig.ImageId)
									ReplicatedStorage.Events.WeaponInventoryUpdated:FireClient(player, profile.Data.WeaponInventory)
								end
							end
						else
							local ccModule = ServerScriptService.Controllers:FindFirstChild("CrateController")
							if ccModule then
								local CrateController = require(ccModule)
								local success = CrateController:PurchaseCrate(player, finalItem.itemId, true)
								if not success then
									profile.Data.Crates = profile.Data.Crates or {}
									profile.Data.Crates[finalItem.itemId] = (profile.Data.Crates[finalItem.itemId] or 0) + 1
								end
							end
						end

					elseif finalItem.type == "Pass" then
						profile.Data.HasX3WavePass = true
						player:SetAttribute("HasX3WavePass", true)
					end
				end
			end
		end

		sauvegarderJoueur(player, false) -- ⚡ Sauvegarde douce (sera bloquée si trop rapide)
	end)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do 
		sauvegarderJoueur(player, true) -- ⚡ Force la sauvegarde finale
	end
end)