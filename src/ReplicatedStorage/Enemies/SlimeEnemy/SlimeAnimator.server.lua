local RunService = game:GetService("RunService")

local zombie = script.Parent
local humanoid = zombie:WaitForChild("Humanoid")
local zombieRoot = zombie:WaitForChild("HumanoidRootPart")

local slimeModel = zombie:WaitForChild("Toilet")
local slimeRoot = slimeModel:WaitForChild("RootPart")

-- 1. Xóa tất cả WeldConstraint cũ trên HumanoidRootPart để tránh xung đột
for _, child in ipairs(zombieRoot:GetChildren()) do
	if child:IsA("WeldConstraint") or child:IsA("Weld") then
		child:Destroy()
	end
end

-- 2. Hàn tất cả part con của model Toilet vào RootPart của nó
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

-- 3. Gắn Toilet vào HumanoidRootPart bằng Weld (có C0 để animate)
local originalC0 = zombieRoot.CFrame:Inverse() * slimeRoot.CFrame

local weld = Instance.new("Weld")
weld.Part0 = zombieRoot
weld.Part1 = slimeRoot
weld.C0 = originalC0
weld.Parent = zombieRoot

-- 4. Animation nảy
local bounceSpeed = 15
local bounceHeight = 1.5
local timeElapsed = 0

RunService.Heartbeat:Connect(function(deltaTime)
	if humanoid.Health <= 0 then return end

	local currentSpeed = Vector3.new(zombieRoot.AssemblyLinearVelocity.X, 0, zombieRoot.AssemblyLinearVelocity.Z).Magnitude

	if currentSpeed > 0.5 then
		timeElapsed += deltaTime
		local bounce = math.abs(math.sin(timeElapsed * bounceSpeed)) * bounceHeight
		weld.C0 = originalC0 * CFrame.new(0, bounce, 0)
	else
		timeElapsed = 0
		weld.C0 = weld.C0:Lerp(originalC0, 0.2)
	end
end)