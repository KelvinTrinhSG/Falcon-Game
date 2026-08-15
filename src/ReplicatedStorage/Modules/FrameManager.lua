--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FrameManager = {}

-- Event system to broadcast frame state changes
local frameOpenedCallbacks = {}
local frameClosedCallbacks = {}

function FrameManager.onFrameOpened(callback: (frameName: string) -> ())
	table.insert(frameOpenedCallbacks, callback)
end

function FrameManager.onFrameClosed(callback: (frameName: string) -> ())
	table.insert(frameClosedCallbacks, callback)
end

local playerGui: PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local framesContainer: Folder = playerGui:WaitForChild("GUI"):WaitForChild("Frames")
local TWEEN_INFO: TweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local currentlyOpenFrame: Frame? = nil
local framePositions: {[Frame]: UDim2} = {}
local activeTweens: {[Frame]: {Animation: Tween, CleanupThread: thread?}} = {} -- ## ADDED ##

-- ## NEW FUNCTION ## Safely cancels any ongoing tween and its cleanup task for a given frame.
local function cancelActiveTween(frame: Frame)
	local activeTweenInfo = activeTweens[frame]
	if activeTweenInfo then
		activeTweenInfo.Animation:Cancel()
		if activeTweenInfo.CleanupThread then
			task.cancel(activeTweenInfo.CleanupThread)
		end
		activeTweens[frame] = nil
	end
end

function FrameManager.getOpenFrameName()
	if currentlyOpenFrame and currentlyOpenFrame.Parent then
		return currentlyOpenFrame.Name
	end
	return nil
end

local function initializeFrame(frame: Frame)
	if not framePositions[frame] then
		framePositions[frame] = frame.Position
		local hiddenPosition: UDim2 = UDim2.new(framePositions[frame].X.Scale, framePositions[frame].X.Offset, 1.5, 0)
		frame.Position = hiddenPosition
		frame.Visible = false
	end
end

function FrameManager.close(frameName: string)
	local targetFrame: Frame? = framesContainer:FindFirstChild(frameName)
	if not targetFrame then return end

	-- Do nothing if it's already invisible and not the open frame (avoids closing an already closed frame)
	if not targetFrame.Visible and currentlyOpenFrame ~= targetFrame then return end

	cancelActiveTween(targetFrame) -- Cancel any other tweens on this frame

	if currentlyOpenFrame == targetFrame then
		currentlyOpenFrame = nil
	end

	for _, callback in ipairs(frameClosedCallbacks) do
		task.spawn(callback, frameName)
	end

	initializeFrame(targetFrame)
	local hiddenPosition: UDim2 = UDim2.new(framePositions[targetFrame].X.Scale, framePositions[targetFrame].X.Offset, 1.5, 0)
	local slideOutTween: Tween = TweenService:Create(targetFrame, TWEEN_INFO, {Position = hiddenPosition})

	-- Create a cleanup thread that will run after the animation
	local cleanupThread = task.spawn(function()
		slideOutTween.Completed:Wait()
		targetFrame.Visible = false
		activeTweens[targetFrame] = nil -- Remove from active list once done
	end)

	-- Track the new animation and its cleanup thread
	activeTweens[targetFrame] = {Animation = slideOutTween, CleanupThread = cleanupThread}
	slideOutTween:Play()
end

function FrameManager.open(frameName: string)
	local targetFrame: Frame? = framesContainer:FindFirstChild(frameName)
	if not targetFrame or currentlyOpenFrame == targetFrame then return end

	cancelActiveTween(targetFrame) -- Cancel any other tweens on this frame

	initializeFrame(targetFrame)
	if currentlyOpenFrame then
		FrameManager.close(currentlyOpenFrame.Name)
	end
	targetFrame.Visible = true
	local originalPosition: UDim2 = framePositions[targetFrame]
	local slideInTween: Tween = TweenService:Create(targetFrame, TWEEN_INFO, {Position = originalPosition})

	-- Track the new animation
	activeTweens[targetFrame] = {Animation = slideInTween}
	slideInTween:Play()

	currentlyOpenFrame = targetFrame

	for _, callback in ipairs(frameOpenedCallbacks) do
		task.spawn(callback, frameName)
	end
end

function FrameManager.connect(button: TextButton | ImageButton, frameName: string, action: "Toggle" | "Open" | "Close"?)
	local targetFrame: Frame? = framesContainer:FindFirstChild(frameName)
	if not button or not targetFrame then return end
	action = action or "Toggle"
	initializeFrame(targetFrame)
	button.MouseButton1Click:Connect(function()
		if action == "Close" then
			FrameManager.close(frameName)
		elseif action == "Open" then
			FrameManager.open(frameName)
		else -- Toggle
			if currentlyOpenFrame == targetFrame then
				FrameManager.close(frameName)
			else
				FrameManager.open(frameName)
			end
		end
	end)
end

return FrameManager