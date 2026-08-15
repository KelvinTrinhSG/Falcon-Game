-- Cursor + Animation client-side handler
local Mouse_Icon = "rbxasset://textures/GunCursor.png"
local tool = script.Parent
local player = game:GetService("Players").LocalPlayer

-- Animation IDs
local ANIM_IDS = {
	"rbxassetid://98773100124195",
	"rbxassetid://86838992045761",
	"rbxassetid://126491412285246",
}
local tracks = {}
local swingCombo = 1
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

	for i, id in ipairs(ANIM_IDS) do
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		local track = animator:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		tracks[i] = track
	end
end

local function OnUnequipped()
	if mouse then mouse.Icon = "" end
	mouse = nil
	isSwinging = false
	swingCombo = 1
	for i, track in ipairs(tracks) do
		if track then
			track:Stop()
			track:Destroy()
			tracks[i] = nil
		end
	end
end

local function OnActivated()
	if isSwinging then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

	isSwinging = true
	local track = tracks[swingCombo]
	if track then
		track:Play()
		track.Stopped:Wait()
	end
	isSwinging = false
	swingCombo = (swingCombo % 3) + 1
end

tool.Equipped:Connect(OnEquipped)
tool.Unequipped:Connect(OnUnequipped)
tool.Activated:Connect(OnActivated)