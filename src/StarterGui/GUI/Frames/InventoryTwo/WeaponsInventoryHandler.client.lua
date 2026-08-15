--!strict
-- Populates the weapon inventory UI and handles weapon selection.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponConfigurations = require(ReplicatedStorage.Modules.WeaponConfigurations)

-- On accède au dossier qui contient tes modèles 3D d'armes
local weaponsFolder = ReplicatedStorage:WaitForChild("Weapons")

local player = Players.LocalPlayer
local inventoryFrame = script.Parent
local scrollingFrame = inventoryFrame:WaitForChild("ScrollingFrame")
local template = ReplicatedStorage.Templates:WaitForChild("WeaponsInventoryTemplate")

-- Variables pour l'affichage des stats
local statWeaponsFrame = inventoryFrame:WaitForChild("Stat Weapons")
local statCountText = statWeaponsFrame:WaitForChild("Count")

local setSelectedWeaponRequest = ReplicatedStorage.Events:WaitForChild("SetSelectedWeaponRequest")
local equipWeaponRequest = ReplicatedStorage.Events:WaitForChild("EquipWeaponRequest")

local myWeapons = {}
local selectedTemplate: GuiObject? = nil

-- Color definitions
local DEFAULT_FRAME_STROKE_COLOR = Color3.fromRGB(85, 0, 127)
local SELECTED_FRAME_STROKE_COLOR = Color3.fromRGB(0, 255, 0)
local DEFAULT_DESIGN_COLOR = Color3.fromRGB(170, 0, 255)
local SELECTED_DESIGN_COLOR = Color3.fromRGB(0, 255, 0)
local DEFAULT_TEXT_STROKE_COLOR = Color3.fromRGB(85, 0, 127)
local SELECTED_TEXT_STROKE_COLOR = Color3.fromRGB(0, 110, 0)

-- ⚡ MODIFIÉ : Fonction qui va lire l'attribut et afficher "Weapon stats : X"
local function updateStatDisplay(weaponId: string?)
	if not weaponId then
		statCountText.Text = "Weapon stats : 0"
		return
	end

	-- On cherche le modèle 3D de l'arme dans ReplicatedStorage.Weapons
	local weaponModel = weaponsFolder:FindFirstChild(weaponId)

	if weaponModel then
		-- On lit l'attribut "Damage" (Sensible à la casse : "Damage" avec un D majuscule)
		local dmg = weaponModel:GetAttribute("Damage")

		if dmg then
			statCountText.Text = "Weapon stats : " .. tostring(dmg)
		else
			statCountText.Text = "Weapon stats : 0" -- Si l'arme n'a pas d'attribut Damage
		end
	else
		statCountText.Text = "Weapon stats : 0" -- Si le modèle 3D est introuvable
	end
end

local function populateInventory()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if not child:IsA("UILayout") then child:Destroy() end
	end
	selectedTemplate = nil

	local lastEquippedWeapon = player:GetAttribute("LastEquippedWeapon")

	-- On met à jour les stats avec l'arme déjà équipée à l'ouverture
	updateStatDisplay(lastEquippedWeapon)

	for _, weaponId in ipairs(myWeapons) do
		local weaponConfig = WeaponConfigurations.Weapons[weaponId]
		if weaponConfig then
			local item = template:Clone()
			item.Name = weaponId

			-- Find all the necessary UI elements
			local textLabel = item:FindFirstChild("Text")
			local imageLabel = item:FindFirstChild("Image")
			local design = item:FindFirstChild("Design")
			local frameStroke = design and design:FindFirstChild("Stroke")
			local textStroke = textLabel and textLabel:FindFirstChild("Stroke")

			-- Set Text and Image
			if textLabel and textLabel:IsA("TextLabel") then
				textLabel.Text = weaponConfig.DisplayName
			end
			if imageLabel and imageLabel:IsA("ImageLabel") then
				imageLabel.Image = weaponConfig.ImageId
			end

			-- Check if this is the currently selected weapon to set initial colors
			if weaponId == lastEquippedWeapon then
				if frameStroke then frameStroke.Color = SELECTED_FRAME_STROKE_COLOR end
				if design then design.BackgroundColor3 = SELECTED_DESIGN_COLOR end
				if textStroke then textStroke.Color = SELECTED_TEXT_STROKE_COLOR end
				selectedTemplate = item
			end

			if item:IsA("GuiButton") then
				item.MouseButton1Click:Connect(function()
					-- Reset the previously selected item to default colors
					if selectedTemplate then
						local oldDesign = selectedTemplate:FindFirstChild("Design")
						local oldFrameStroke = oldDesign and oldDesign:FindFirstChild("Stroke")
						local oldTextLabel = selectedTemplate:FindFirstChild("Text")
						local oldTextStroke = oldTextLabel and oldTextLabel:FindFirstChild("Stroke")

						if oldFrameStroke then oldFrameStroke.Color = DEFAULT_FRAME_STROKE_COLOR end
						if oldDesign then oldDesign.BackgroundColor3 = DEFAULT_DESIGN_COLOR end
						if oldTextStroke then oldTextStroke.Color = DEFAULT_TEXT_STROKE_COLOR end
					end

					-- Highlight the new item
					if frameStroke then frameStroke.Color = SELECTED_FRAME_STROKE_COLOR end
					if design then design.BackgroundColor3 = SELECTED_DESIGN_COLOR end
					if textStroke then textStroke.Color = SELECTED_TEXT_STROKE_COLOR end
					selectedTemplate = item

					-- On met à jour les stats quand on clique sur l'arme
					updateStatDisplay(weaponId)

					-- Tell the server about our new selection and to equip it
					setSelectedWeaponRequest:FireServer(weaponId)
					equipWeaponRequest:FireServer(weaponId)
				end)
			end
			item.Parent = scrollingFrame
		end
	end
end

ReplicatedStorage.Events.WeaponInventoryUpdated.OnClientEvent:Connect(function(newInventory)
	myWeapons = newInventory
	if inventoryFrame.Visible then
		populateInventory()
	end
end)

inventoryFrame:GetPropertyChangedSignal("Visible"):Connect(function()
	if inventoryFrame.Visible then
		populateInventory()
	end
end)

task.spawn(function()
	local getInventoryFunc = ReplicatedStorage.Functions:WaitForChild("GetWeaponInventory")
	local success, result = pcall(function()
		return getInventoryFunc:InvokeServer()
	end)
	if success and result then
		myWeapons = result
		if inventoryFrame.Visible then
			populateInventory()
		end
	else
		warn("WeaponsInventoryHandler: Could not get initial inventory. Error: " .. tostring(result))
	end
end)