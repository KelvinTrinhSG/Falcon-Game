-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Modules
local Maid = require(ReplicatedStorage.Modules.Maid)

-- Tool & Components
local tool = script.Parent
local handle = tool:WaitForChild("Handle")
local blade = tool:WaitForChild("Blade")
local toolMaid = Maid.new()

-- State
local isSwinging = false
local hitDebounce = {}

-- Sounds
local HitSoundTemplate = handle:WaitForChild("HitSound")
local EquipSound = handle:WaitForChild("EquipSound")
local UnequipSound = handle:WaitForChild("UnequipSound")
local SwingSounds = {
	handle:WaitForChild("SwingSound1"),
	handle:WaitForChild("SwingSound2"),
	handle:WaitForChild("SwingSound3"),
}

-- Events
local HighlightZombie = ReplicatedStorage.Events:WaitForChild("HighlightZombie")

-- Swing sound counter (synced with client combo)
local swingCombo = 1

local function onBladeTouched(hit: BasePart)
	if not isSwinging or not hit or not hit.Parent then return end
	local hitModel = hit.Parent
	local humanoid = hitModel:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 and hitModel:FindFirstChild("Goal") and not hitDebounce[hitModel] then
		hitDebounce[hitModel] = true
		local damage = tool:GetAttribute("Damage") or 10
		humanoid:TakeDamage(damage)

		HighlightZombie:FireClient(Players:GetPlayerFromCharacter(tool.Parent), hitModel)

		local sound = HitSoundTemplate:Clone()
		sound.Parent = humanoid.RootPart or hitModel.PrimaryPart
		sound:Play()
		Debris:AddItem(sound, 2)
	end
end

local function onActivated()
	local character = tool.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead or isSwinging then return end

	isSwinging = true
	hitDebounce = {}

	-- Play swing sound
	local sound = SwingSounds[swingCombo]
	if sound then sound:Play() end

	-- Wait for the client animation to finish (approximate)
	local debounce = tool:GetAttribute("Debounce") or 0.5
	task.wait(debounce)

	isSwinging = false
	swingCombo = (swingCombo % 3) + 1
end

tool.Equipped:Connect(function()
	EquipSound:Play()
	swingCombo = 1
	toolMaid:GiveTask(blade.Touched:Connect(onBladeTouched))
	toolMaid:GiveTask(tool.Activated:Connect(onActivated))
end)

tool.Unequipped:Connect(function()
	UnequipSound:Play()
	isSwinging = false
	swingCombo = 1
	toolMaid:DoCleaning()
end)