local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- ==========================================
-- ⚙️ PARAMÈTRES
-- ==========================================
local VITESSE_MARCHE = 16
local VITESSE_SPRINT = 24
local DECALAGE_CAMERA = Vector3.new(1.5, 0, 0)

local isLocked = false

-- ==========================================
-- 🏃 SYSTÈME DE SPRINT (SHIFT)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		humanoid.WalkSpeed = VITESSE_SPRINT
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		humanoid.WalkSpeed = VITESSE_MARCHE
	end
end)

-- ==========================================
-- 🎯 SYSTÈME DE CAMERA LOCK (CTRL)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		isLocked = not isLocked 

		if isLocked then
			humanoid.AutoRotate = false 
			humanoid.CameraOffset = DECALAGE_CAMERA 
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter 
		else
			humanoid.AutoRotate = true
			humanoid.CameraOffset = Vector3.new(0, 0, 0) 
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default 
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if isLocked and humanoid.Health > 0 then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		local cameraLook = camera.CFrame.LookVector
		local targetLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
		rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + targetLook)
	end
end)