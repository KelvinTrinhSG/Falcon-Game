-- Cursor + Animation client-side handler
local Mouse_Icon = "rbxasset://textures/GunCursor.png"
local tool = script.Parent
local player = game:GetService("Players").LocalPlayer

local ANIM_ID = "rbxassetid://111717843133410"
local track = nil
local isSwinging = false
local mouse = nil

local function OnEquipped(toolMouse)
	mouse = toolMouse
	if mouse then mouse.Icon = Mouse_Icon end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator = humanoid:FindFirstChildOfClass("Animator")
				or humanoid:WaitForChild("Animator")

	local anim = Instance.new("Animation")
	anim.AnimationId = ANIM_ID
	track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
end

local function OnUnequipped()
	if mouse then mouse.Icon = "" end
	mouse = nil
	isSwinging = false
	if track then
		track:Stop()
		track:Destroy()
		track = nil
	end
end

local function OnActivated()
	if isSwinging then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

	isSwinging = true
	if track then
		track:Play()
		track.Stopped:Wait()
	end
	isSwinging = false
end

tool.Equipped:Connect(OnEquipped)
tool.Unequipped:Connect(OnUnequipped)
tool.Activated:Connect(OnActivated)
