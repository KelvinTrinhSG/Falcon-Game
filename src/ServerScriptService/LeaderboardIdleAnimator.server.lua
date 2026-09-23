--!strict
local Workspace = game:GetService("Workspace")

local leaderboardArea = Workspace:WaitForChild("LeaderboardArea")

for _, model in ipairs(leaderboardArea:GetChildren()) do
	local animationsFolder = model:FindFirstChild("Animations")
	if not animationsFolder then continue end

	local idleAnim = animationsFolder:FindFirstChild("Idle")
	if not idleAnim then continue end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then continue end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then continue end

	local track = animator:LoadAnimation(idleAnim)
	track.Looped = true
	track:Play()
end
