-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

-- Modules
local Maid = require(ReplicatedStorage.Modules.Maid)

-- Tool & Components
local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local blade = tool:WaitForChild("Blade")
local toolMaid = Maid.new()

-- Sounds
local HitSoundTemplate = handle:WaitForChild("HitSound")
local EquipSound = handle:WaitForChild("EquipSound")
local UnequipSound = handle:WaitForChild("UnequipSound")
for _, snd in handle:GetChildren() do
	if snd:IsA("Sound") then snd.Volume *= 0.2 end
end
local SwingSound = handle:WaitForChild("SwingSound1")

-- Events
local HighlightZombie = ReplicatedStorage.Events:WaitForChild("HighlightZombie")

local HITBOX_SIZE = Vector3.new(4, 4, 8)
local SWING_COOLDOWN = 0.8

local hitThisSwing = {}
local isSwinging = false

local function showDebugHitbox(cf: CFrame)
	local box = Instance.new("Part")
	box.Name = "DEBUG_Hitbox"
	box.Size = HITBOX_SIZE
	box.CFrame = cf
	box.Anchored = true
	box.CanCollide = false
	box.CanTouch = false
	box.CanQuery = false
	box.Transparency = 1
	box.Color = Color3.fromRGB(255, 100, 0)
	box.Material = Enum.Material.Neon
	box.Parent = Workspace
	Debris:AddItem(box, 0.1)
end

local function doHitbox()
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { tool.Parent }

	local hitboxCFrame = blade.CFrame
	showDebugHitbox(hitboxCFrame)

	local parts = Workspace:GetPartBoundsInBox(hitboxCFrame, HITBOX_SIZE, overlapParams)

	local damage = tool:GetAttribute("Damage") or 10
	local player = Players:GetPlayerFromCharacter(tool.Parent)

	for _, part in ipairs(parts) do
		local hitModel = part:FindFirstAncestorOfClass("Model")
		if not hitModel then continue end

		local humanoid = hitModel:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then continue end
		if not hitModel:FindFirstChild("Goal") then continue end
		if hitModel:GetAttribute("IsFlying") then continue end
		if hitThisSwing[hitModel] then continue end

		hitThisSwing[hitModel] = true
		humanoid:TakeDamage(damage)
		print(string.format("[SwordHit] %s chém %s | dmg: %d | HP còn: %.0f", tool.Name, hitModel.Name, damage, humanoid.Health))

		if player then
			HighlightZombie:FireClient(player, hitModel)
		end

		local sound = HitSoundTemplate:Clone()
		sound.Parent = humanoid.RootPart or hitModel.PrimaryPart
		sound:Play()
		Debris:AddItem(sound, 2)
	end
end

local function onActivated()
	if isSwinging then return end
	local character = tool.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

	isSwinging = true
	SwingSound:Play()
	hitThisSwing = {}
	print(string.format("[SwordSwing] %s swing | dmg: %d | hitbox: %s", tool.Name, tool:GetAttribute("Damage") or 10, tostring(HITBOX_SIZE)))

	local elapsed = 0
	local interval = 0.1
	local swingWindow = 0.7
	while elapsed < swingWindow do
		task.wait(interval)
		elapsed += interval
		doHitbox()
	end

	task.wait(SWING_COOLDOWN - swingWindow)
	isSwinging = false
end

tool.Equipped:Connect(function()
	EquipSound:Play()
	hitThisSwing = {}
	toolMaid:GiveTask(tool.Activated:Connect(onActivated))
end)

tool.Unequipped:Connect(function()
	UnequipSound:Play()
	hitThisSwing = {}
	toolMaid:DoCleaning()
end)
