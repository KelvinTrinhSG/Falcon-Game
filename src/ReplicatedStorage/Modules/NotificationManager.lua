--!strict
-- ReplicatedStorage.Modules.NotificationManager.lua (Client-only module)

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting") -- ## ADDED ##

local NotificationManager = {}

local playerGui: PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local notificationFrame: Frame = playerGui:WaitForChild("GUI"):WaitForChild("Frames"):WaitForChild("Notifications")
local notificationTemplate: TextLabel = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("NotificationTemplate")

local TWEEN_INFO_FADE: TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local NOTIFICATION_LIFETIME: number = 5

-- ## ADDED ## Variables for the time shift effect
local ORIGINAL_CLOCK_TIME = 14.5
local isTimeShifted = false

-- Color definitions
local successStrokeColor = Color3.fromRGB(33, 100, 0)
local successGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

local errorStrokeColor = Color3.fromRGB(145, 0, 0)
local errorGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 85, 127))
})

local normalStrokeColor = Color3.fromRGB(145, 97, 0)
local normalGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

-- ## ADDED ## New styles for Legendary and Mythical
local legendaryStrokeColor = Color3.fromRGB(125, 0, 0)
local legendaryGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 0))
})

local mythicalStrokeColor = Color3.fromRGB(100, 33, 50)
local mythicalGradient = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 127)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 127))
})


-- ## NEW FUNCTION ## Handles the entire day-to-night-to-day animation
local function triggerTimeShift()
	if isTimeShifted then return end
	isTimeShifted = true

	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

	-- Transition to night
	local toNightTween = TweenService:Create(Lighting, tweenInfo, {ClockTime = 0})
	toNightTween:Play()
	toNightTween.Completed:Wait()

	-- Hold for 5 seconds
	task.wait(5)

	-- Transition back to day
	local toDayTween = TweenService:Create(Lighting, tweenInfo, {ClockTime = ORIGINAL_CLOCK_TIME})
	toDayTween:Play()
	toDayTween.Completed:Wait()

	isTimeShifted = false
end


function NotificationManager.show(message: string, messageType: string?)
	local newNotification: TextLabel = notificationTemplate:Clone()
	newNotification.Text = message

	local stroke: UIStroke? = newNotification:FindFirstChild("Stroke")
	local gradient: UIGradient? = newNotification:FindFirstChild("Gradient")
	local lifetime = NOTIFICATION_LIFETIME

	if not stroke or not gradient then
		if messageType == "Success" then
			newNotification.TextColor3 = successStrokeColor -- ✅ FIX APPLIED HERE
		elseif messageType == "Error" then
			newNotification.TextColor3 = errorStrokeColor -- ✅ FIX APPLIED HERE
		end
	else
		if messageType == "Success" then
			stroke.Color = successStrokeColor
			gradient.Color = successGradient
		elseif messageType == "Error" then
			stroke.Color = errorStrokeColor
			gradient.Color = errorGradient
		elseif messageType == "Legendary" then
			stroke.Color = legendaryStrokeColor
			gradient.Color = legendaryGradient
			lifetime = 7
			task.spawn(triggerTimeShift) -- ## ADDED ##
		elseif messageType == "Mythical" then
			stroke.Color = mythicalStrokeColor
			gradient.Color = mythicalGradient
			lifetime = 10
			task.spawn(triggerTimeShift) -- ## ADDED ##
		elseif messageType == "Normal" then
			stroke.Color = normalStrokeColor
			gradient.Color = normalGradient
		else
			stroke.Color = normalStrokeColor
			gradient.Color = normalGradient
		end
	end

	newNotification.Parent = notificationFrame

	newNotification.TextTransparency = 1
	if stroke then stroke.Transparency = 1 end

	local textFadeIn: Tween = TweenService:Create(newNotification, TWEEN_INFO_FADE, {TextTransparency = 0})
	local strokeFadeIn: Tween? = stroke and TweenService:Create(stroke, TWEEN_INFO_FADE, {Transparency = 0})

	textFadeIn:Play()
	if strokeFadeIn then strokeFadeIn:Play() end

	if messageType and messageType ~= "NotNormal" then
		local sound: Sound? = Workspace.Sounds:FindFirstChild(messageType)
		if sound then
			SoundService:PlayLocalSound(sound)
		end
	end

	task.wait(lifetime)

	local textFadeOut: Tween = TweenService:Create(newNotification, TWEEN_INFO_FADE, {TextTransparency = 1})
	local strokeFadeOut: Tween? = stroke and TweenService:Create(stroke, TWEEN_INFO_FADE, {Transparency = 1})

	textFadeOut:Play()
	if strokeFadeOut then strokeFadeOut:Play() end

	textFadeOut.Completed:Wait()
	newNotification:Destroy()
end

return NotificationManager