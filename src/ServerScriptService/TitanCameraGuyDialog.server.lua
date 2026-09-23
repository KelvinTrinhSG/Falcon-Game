--!strict
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local DEFAULT_TEXT = "Together we fight, or we become dust."
local CHEER_ANIM_ID  = "rbxassetid://119584069716590"
local CHEER_DURATION = 5

local leaderboardArea = Workspace:WaitForChild("LeaderboardArea")
local touchParts      = leaderboardArea:WaitForChild("TouchParts")
local touchPart       = touchParts:WaitForChild("TitanCameraMan")
local dialogLabel     = touchParts:WaitForChild("InteractPart"):WaitForChild("gui"):WaitForChild("dialog")

dialogLabel.Text = DEFAULT_TEXT

local resetThread: thread? = nil
local debounces: { [Player]: boolean } = {}

local function playAnimOnModel(model: Model, animId: string)
	if not model:IsA("Model") then return end

	local animFolder = model:FindFirstChild("Animations")
	if not animFolder then return end

	local idleAnim = animFolder:FindFirstChild("Idle") :: Animation?
	if not idleAnim then return end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	local anim = Instance.new("Animation")
	anim.AnimationId = animId
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action4
	track:Play()

	task.delay(CHEER_DURATION, function()
		track:Stop()
		local idleTrack = animator:LoadAnimation(idleAnim)
		idleTrack.Looped = true
		idleTrack:Play()
		print("[Cheer] Resumed Idle on:", model.Name)
	end)
end

local function playCheerOnModels()
	for _, model in ipairs(leaderboardArea:GetChildren()) do
		if model.Name == "LaserCameramanCar" then continue end
		playAnimOnModel(model, CHEER_ANIM_ID)
	end
end


touchPart.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end
	if debounces[player] then return end

	debounces[player] = true
	dialogLabel.Text = "Well fought, " .. player.Name .. ". The Alliance stands because of you."

	playCheerOnModels()

	if resetThread then task.cancel(resetThread) end
	resetThread = task.delay(CHEER_DURATION, function()
		dialogLabel.Text = DEFAULT_TEXT
		resetThread = nil
	end)

	task.delay(CHEER_DURATION, function()
		debounces[player] = nil
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	debounces[player] = nil
end)
