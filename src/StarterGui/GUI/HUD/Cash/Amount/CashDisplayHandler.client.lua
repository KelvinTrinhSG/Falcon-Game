--!strict
-- This script animates the cash display on the HUD.

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Modules & Player
local player = Players.LocalPlayer
local NumberFormatter = require(ReplicatedStorage.Modules.NumberFormatter)

-- UI Elements
local playerGui = player:WaitForChild("PlayerGui")
local amountLabel = playerGui:WaitForChild("GUI"):WaitForChild("HUD"):WaitForChild("Cash"):WaitForChild("Amount")

-- State
local oldCashValue = 0
local connection: RBXScriptConnection?

-- Smoothly animates the cash value counting up
local function animateCashIncrease(startValue: number, endValue: number)
	local duration = 0.5
	local startTime = os.clock()
	local delta = endValue - startValue

	if connection then
		connection:Disconnect()
	end

	-- Use Heartbeat for UI updates that are not tied to the camera
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		local progress = math.min(elapsed / duration, 1)

		local alpha = TweenService:GetValue(progress, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local current = math.floor(startValue + delta * alpha)

		amountLabel.Text = NumberFormatter.formatNumber(current, "$")

		if progress >= 1 then
			amountLabel.Text = NumberFormatter.formatNumber(endValue, "$")
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end)
end

-- ## MODIFIED ## This function now only updates the text, without the red color flash.
local function animateCashDecrease(newValue: number)
	amountLabel.Text = NumberFormatter.formatNumber(newValue, "$")
end


local function onCashChanged(newValue: number)
	if newValue > oldCashValue then
		animateCashIncrease(oldCashValue, newValue)
	elseif newValue < oldCashValue then
		animateCashDecrease(newValue)
	else
		-- This case is for the initial setup
		amountLabel.Text = NumberFormatter.formatNumber(newValue, "$")
	end

	oldCashValue = newValue
end

-- Initialization: Wait for leaderstats and connect to the Cash value
task.spawn(function()
	local leaderstats = player:WaitForChild("leaderstats")
	local cash = leaderstats:WaitForChild("Cash")

	if cash then
		oldCashValue = cash.Value
		amountLabel.Text = NumberFormatter.formatNumber(cash.Value, "$")
		cash.Changed:Connect(onCashChanged)
	end
end)