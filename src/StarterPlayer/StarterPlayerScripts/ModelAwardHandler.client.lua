--!strict
-- Handles the award UI pop-up for unlocking new protection models.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local showModelAwardEvent = ReplicatedStorage.Events:WaitForChild("ShowModelAward")

local awardFrame = playerGui:WaitForChild("GUI"):WaitForChild("Frames"):WaitForChild("ModelAward")
local itemIcon = awardFrame:FindFirstChild("Icon")
local itemNameLabel = awardFrame:FindFirstChild("NameLabel")
local awardSound: Sound = awardFrame:WaitForChild("AwardSound")

awardFrame.AnchorPoint = Vector2.new(0.5, 0.5)
awardFrame.Position = UDim2.fromScale(0.5, 0.5)
awardFrame.Visible = false
local originalSize = awardFrame.Size
local originalTransparency = awardFrame.BackgroundTransparency
local tweenInfoIn = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfoOut = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)

showModelAwardEvent.OnClientEvent:Connect(function(modelName: string, imageId: string)
	if itemIcon and itemIcon:IsA("ImageLabel") then
		itemIcon.Image = imageId
	end
	if itemNameLabel and itemNameLabel:IsA("TextLabel") then
		itemNameLabel.Text = "" .. modelName
	end

	awardFrame.Size = UDim2.fromScale(0, 0)
	awardFrame.BackgroundTransparency = 1
	awardFrame.Visible = true

	local tweenIn = TweenService:Create(awardFrame, tweenInfoIn, {
		Size = originalSize,
		BackgroundTransparency = originalTransparency,
	})
	local tweenOut = TweenService:Create(awardFrame, tweenInfoOut, {
		Size = UDim2.fromScale(0, 0),
		BackgroundTransparency = 1,
	})

	tweenIn:Play()
	awardSound:Play()
	tweenIn.Completed:Wait()
	task.wait(3) -- Keep on screen
	tweenOut:Play()

	tweenOut.Completed:Once(function()
		awardFrame.Visible = false
	end)
end)