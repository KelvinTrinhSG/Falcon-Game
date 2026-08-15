--!strict
-- LOCATION: StarterPlayer.StarterPlayerScripts.CollectionEffectHandler
-- DESCRIPTION: Creates a visual popup effect when cash is collected.

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Modules & Assets
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)
local CollectionPopupTemplate = ReplicatedStorage.Templates:WaitForChild("CollectionPopupTemplate")
local CashCollectSound = Workspace.Sounds:WaitForChild("CashCollect")

-- Remotes
local showCollectionEffectEvent = ReplicatedStorage.Events:WaitForChild("ShowCollectionEffect")

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- A container for all popups
local effectContainer = Instance.new("ScreenGui")
effectContainer.Name = "CollectionEffectContainer"
effectContainer.ZIndexBehavior = Enum.ZIndexBehavior.Global
effectContainer.Parent = playerGui

showCollectionEffectEvent.OnClientEvent:Connect(function(amountCollected: number)
	-- Play the sound effect
	if CashCollectSound then
		CashCollectSound:Play()
	end

	-- Create a new popup from the template
	local popup = CollectionPopupTemplate:Clone()
	popup.Text = "+" .. NumberFormatter.formatNumber(amountCollected, "$")

	-- Position it randomly on the screen
	local screenSize = workspace.CurrentCamera.ViewportSize
	local randomX = math.random(screenSize.X * 0.2, screenSize.X * 0.8)
	local randomY = math.random(screenSize.Y * 0.2, screenSize.Y * 0.6)
	local startPosition = UDim2.fromOffset(randomX, randomY)
	local endPosition = startPosition + UDim2.fromOffset(0, -75) -- Move up

	popup.Position = startPosition
	popup.TextTransparency = 1
	popup.Parent = effectContainer

	-- Animate the popup
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local fadeIn = TweenService:Create(popup, tweenInfo, {
		Position = endPosition,
		TextTransparency = 0
	})

	local tweenInfoOut = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	local fadeOut = TweenService:Create(popup, tweenInfoOut, {
		Position = endPosition + UDim2.fromOffset(0, -50),
		TextTransparency = 1
	})

	fadeIn:Play()

	fadeIn.Completed:Wait()
	task.wait(0.5)

	fadeOut:Play()

	fadeOut.Completed:Connect(function()
		popup:Destroy()
	end)
end)