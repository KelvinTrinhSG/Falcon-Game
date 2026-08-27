local RunService = game:GetService("RunService")

local zombie = script.Parent
local humanoid = zombie:WaitForChild("Humanoid")
local zombieRoot = zombie:WaitForChild("HumanoidRootPart")

local slimeModel = zombie:WaitForChild("Toilet")
local slimeRoot = slimeModel:WaitForChild("RootPart")

-- 1. Xóa tất cả WeldConstraint/Weld cũ trên HumanoidRootPart
for _, child in ipairs(zombieRoot:GetChildren()) do
	if child:IsA("WeldConstraint") or child:IsA("Weld") then
		child:Destroy()
	end
end

-- 2. Hàn tất cả part con của Toilet vào RootPart của nó
for _, part in ipairs(slimeModel:GetDescendants()) do
	if part:IsA("BasePart") and part ~= slimeRoot then
		local internalWeld = Instance.new("WeldConstraint")
		internalWeld.Part0 = slimeRoot
		internalWeld.Part1 = part
		internalWeld.Parent = slimeRoot

		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
	end
end
slimeRoot.Anchored = false
slimeRoot.CanCollide = false
slimeRoot.Massless = true

-- 3. Gắn Toilet vào HumanoidRootPart
local originalC0 = zombieRoot.CFrame:Inverse() * slimeRoot.CFrame

local weld = Instance.new("Weld")
weld.Part0 = zombieRoot
weld.Part1 = slimeRoot
weld.C0 = originalC0
weld.Parent = zombieRoot

-- 4. Load animation Walk qua AnimationController/Animator
local animController = slimeModel:WaitForChild("AnimationController")
local animator = animController:WaitForChild("Animator")

local walkAnim = Instance.new("Animation")
walkAnim.AnimationId = "rbxassetid://122351479381147"

local walkTrack = animator:LoadAnimation(walkAnim)
walkTrack.Priority = Enum.AnimationPriority.Movement
walkTrack.Looped = true

local isPlaying = false

RunService.Heartbeat:Connect(function()
	if humanoid.Health <= 0 then
		if isPlaying then
			walkTrack:Stop()
			isPlaying = false
		end
		return
	end

	local currentSpeed = Vector3.new(zombieRoot.AssemblyLinearVelocity.X, 0, zombieRoot.AssemblyLinearVelocity.Z).Magnitude

	if currentSpeed > 0.5 and not isPlaying then
		walkTrack:Play()
		isPlaying = true
	elseif currentSpeed <= 0.5 and isPlaying then
		walkTrack:Stop()
		isPlaying = false
	end
end)
