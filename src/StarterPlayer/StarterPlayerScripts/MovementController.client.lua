local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- speeds
local WALK_SPEED = 40
local SPRINT_SPEED = 50

-- animation IDs
local ANIM_IDS = {
	idle = "rbxassetid://657595757",
	run  = "rbxassetid://657564596",
	jump = "rbxassetid://658409194",
	fall = "rbxassetid://657600338",
	climb = "rbxassetid://658360781",
}

local FADE = 0.2

local humanoid
local tracks = {}
local currentTrack
local currentName

local runningConnection
local stateConnection
local climbingConnection

local function play(name)
	local track = tracks[name]
	if not track or track == currentTrack then return end

	if currentTrack then
		currentTrack:Stop(FADE)
	end

	track:Play(FADE)
	currentTrack = track
	currentName = name
end

local function isAirOrClimbState()
	if not humanoid then return false end

	local state = humanoid:GetState()

	return state == Enum.HumanoidStateType.Jumping
		or state == Enum.HumanoidStateType.Freefall
		or state == Enum.HumanoidStateType.Climbing
end

-- Movement now only uses RUN, not walk
local function onRunning(speed)
	if not humanoid then return end

	if isAirOrClimbState() then
		return
	end

	if speed > 0.1 then
		play("run")

		if currentTrack then
			currentTrack:AdjustSpeed(speed / WALK_SPEED)
		end
	else
		play("idle")

		if currentTrack then
			currentTrack:AdjustSpeed(1)
		end
	end
end

local function onClimbing(speed)
	if not humanoid then return end

	play("climb")

	if currentTrack then
		-- Makes the climb animation move faster/slower based on climb speed.
		-- If the player stops on the ladder, the animation pauses.
		local climbAnimSpeed = math.clamp(math.abs(speed) / 8, 0, 2)
		currentTrack:AdjustSpeed(climbAnimSpeed)
	end
end

local function returnToGroundMovement()
	if not humanoid then return end

	local moveAmount = humanoid.MoveDirection.Magnitude

	if moveAmount > 0.1 then
		play("run")

		if currentTrack then
			currentTrack:AdjustSpeed(humanoid.WalkSpeed / WALK_SPEED)
		end
	else
		play("idle")

		if currentTrack then
			currentTrack:AdjustSpeed(1)
		end
	end
end

local function onStateChanged(_, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		play("jump")

		if currentTrack then
			currentTrack:AdjustSpeed(1)
		end

	elseif newState == Enum.HumanoidStateType.Freefall then
		play("fall")

		if currentTrack then
			currentTrack:AdjustSpeed(1)
		end

	elseif newState == Enum.HumanoidStateType.Climbing then
		play("climb")

		if currentTrack then
			currentTrack:AdjustSpeed(0)
		end

	elseif newState == Enum.HumanoidStateType.Landed
		or newState == Enum.HumanoidStateType.Running
		or newState == Enum.HumanoidStateType.RunningNoPhysics then

		returnToGroundMovement()
	end
end

local function disconnectOldConnections()
	if runningConnection then
		runningConnection:Disconnect()
		runningConnection = nil
	end

	if stateConnection then
		stateConnection:Disconnect()
		stateConnection = nil
	end

	if climbingConnection then
		climbingConnection:Disconnect()
		climbingConnection = nil
	end
end

local function setup()
	disconnectOldConnections()

	local character = player.Character or player.CharacterAdded:Wait()
	humanoid = character:WaitForChild("Humanoid")

	humanoid.WalkSpeed = WALK_SPEED

	local animator = humanoid:WaitForChild("Animator")

	-- Turn off Roblox default animation script
	local animate = character:WaitForChild("Animate", 5)
	if animate then
		animate.Disabled = true
	end

	tracks = {}
	currentTrack = nil
	currentName = nil

	for name, id in pairs(ANIM_IDS) do
		local anim = Instance.new("Animation")
		anim.AnimationId = id

		local track = animator:LoadAnimation(anim)

		if name == "idle" or name == "run" or name == "climb" then
			track.Looped = true
		else
			track.Looped = false
		end

		if name == "idle" then
			track.Priority = Enum.AnimationPriority.Idle
		elseif name == "run" or name == "climb" then
			track.Priority = Enum.AnimationPriority.Movement
		else
			track.Priority = Enum.AnimationPriority.Action
		end

		tracks[name] = track
	end

	runningConnection = humanoid.Running:Connect(onRunning)
	stateConnection = humanoid.StateChanged:Connect(onStateChanged)
	climbingConnection = humanoid.Climbing:Connect(onClimbing)

	play("idle")
end

setup()

player.CharacterAdded:Connect(function()
	task.wait(0.2)
	setup()
end)

-- Shift sprint, currently same speed as walk
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.LeftShift and humanoid then
		humanoid.WalkSpeed = SPRINT_SPEED
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift and humanoid then
		humanoid.WalkSpeed = WALK_SPEED
	end
end)
