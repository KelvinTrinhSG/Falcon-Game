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

-- Time-based per-enemy cooldown (works across hold-to-attack loop)
local lastHitTime = {}

local function onBladeTouched(hit: BasePart)
	if not hit or not hit.Parent then return end

	local hitModel = hit:FindFirstAncestorOfClass("Model")
	if not hitModel then return end

	local humanoid = hitModel:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	if not hitModel:FindFirstChild("Goal") then return end

	local debounce = tool:GetAttribute("Debounce") or 0.5
	local now = tick()
	if (now - (lastHitTime[hitModel] or 0)) < debounce then return end
	lastHitTime[hitModel] = now

	local damage = tool:GetAttribute("Damage") or 10
	humanoid:TakeDamage(damage)

	HighlightZombie:FireClient(Players:GetPlayerFromCharacter(tool.Parent), hitModel)

	local sound = HitSoundTemplate:Clone()
	sound.Parent = humanoid.RootPart or hitModel.PrimaryPart
	sound:Play()
	Debris:AddItem(sound, 2)
end

local function onActivated()
	local character = tool.Parent
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end
	SwingSound:Play()
end

tool.Equipped:Connect(function()
	EquipSound:Play()
	lastHitTime = {}
	toolMaid:GiveTask(blade.Touched:Connect(onBladeTouched))
	toolMaid:GiveTask(tool.Activated:Connect(onActivated))
end)

tool.Unequipped:Connect(function()
	UnequipSound:Play()
	lastHitTime = {}
	toolMaid:DoCleaning()
end)
