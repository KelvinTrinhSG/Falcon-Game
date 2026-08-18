local RunService = game:GetService("RunService")

local zombie = script.Parent
local humanoid = zombie:WaitForChild("Humanoid")
local zombieRoot = zombie:WaitForChild("HumanoidRootPart")

local slimeModel = zombie:WaitForChild("Toilet")
local slimeRoot = slimeModel:WaitForChild("RootPart")

-- 1. Xóa tất cả Weld/WeldConstraint cũ trên HumanoidRootPart
for _, child in ipairs(zombieRoot:GetChildren()) do
	if child:IsA("WeldConstraint") or child:IsA("Weld") then
		child:Destroy()
	end
end

-- 2. Hàn các part con của Toilet vào slimeRoot
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
slimeRoot.CanCollide = false

-- 3. Anchor slimeRoot — không dùng Weld để tránh physics explosion
-- CFrame sẽ được update mỗi frame thay vì dùng constraint
local originalC0 = zombieRoot.CFrame:Inverse() * slimeRoot.CFrame
slimeRoot.Anchored = true

-- 4. Load animation Walk
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

	-- Snap Toilet theo HumanoidRootPart mỗi frame, không cần constraint
	slimeRoot.CFrame = zombieRoot.CFrame * originalC0

	local isMoving = humanoid.MoveDirection.Magnitude > 0.1

	if isMoving and not isPlaying then
		walkTrack:Play()
		isPlaying = true
	elseif not isMoving and isPlaying then
		walkTrack:Stop()
		isPlaying = false
	end
end)
