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

-- State & Constants
local swingCombo = 1
local isSwinging = false
local isHolding = false
local hitDebounce = {}

-- Sounds & Animations
local HitSoundTemplate = handle:WaitForChild("HitSound")
local EquipSound = handle:WaitForChild("EquipSound")
local UnequipSound = handle:WaitForChild("UnequipSound")
-- Halve all sound volumes
for _, snd in handle:GetChildren() do
	if snd:IsA("Sound") then snd.Volume *= 0.1 end
end
local SwingSound1 = handle:WaitForChild("SwingSound1")
local SwingSound2 = handle:WaitForChild("SwingSound2")
local SwingSound3 = handle:WaitForChild("SwingSound3")

-- Events
local HighlightZombie = ReplicatedStorage.Events:WaitForChild("HighlightZombie")

local animations = {
	Swing1 = tool:WaitForChild("SwingAnimation1"),
	Swing2 = tool:WaitForChild("SwingAnimation2"),
	Swing3 = tool:WaitForChild("SwingAnimation3"),
}

local tracks = {}

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

	local currentSwingTrack: AnimationTrack?
	local currentSwingSound: Sound?

	if swingCombo == 1 then
		currentSwingTrack = tracks.Swing1
		currentSwingSound = SwingSound1
	elseif swingCombo == 2 then
		currentSwingTrack = tracks.Swing2
		currentSwingSound = SwingSound2
	else
		currentSwingTrack = tracks.Swing3
		currentSwingSound = SwingSound3
	end

	if currentSwingSound then currentSwingSound:Play() end
	if currentSwingTrack then currentSwingTrack:Play() end

	task.wait(currentSwingTrack and currentSwingTrack.Length or 0.5)
	isSwinging = false
	swingCombo = (swingCombo % 3) + 1
end

tool.Equipped:Connect(function()
	EquipSound:Play()
	local character = tool.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:WaitForChild("Animator")

	for name, anim in pairs(animations) do
		tracks[name] = animator:LoadAnimation(anim)
		tracks[name].Priority = Enum.AnimationPriority.Action
	end

	toolMaid:GiveTask(blade.Touched:Connect(onBladeTouched))
	toolMaid:GiveTask(tool.Activated:Connect(function()
		isHolding = true
		while isHolding do
			onActivated()
			task.wait()
		end
	end))
	toolMaid:GiveTask(tool.Deactivated:Connect(function()
		isHolding = false
	end))
end)

tool.Unequipped:Connect(function()
	UnequipSound:Play()
	isHolding = false
	isSwinging = false

	for name, track in pairs(tracks) do
		if track then
			track:Stop()
			track:Destroy()
			tracks[name] = nil
		end
	end

	swingCombo = 1
	toolMaid:DoCleaning()
end)