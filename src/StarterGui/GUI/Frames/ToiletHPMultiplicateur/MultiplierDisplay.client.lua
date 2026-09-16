local Players = game:GetService("Players")
local player = Players.LocalPlayer

local frame = script.Parent
local textLabel = frame:WaitForChild("Value")

local function updateDisplay()
	local xToiletHP = player:GetAttribute("xToiletHP") or 1

	if xToiletHP > 1 then
		frame.Visible = true
		textLabel.Text = "x" .. tostring(xToiletHP)
	else
		frame.Visible = false
	end
end

updateDisplay()

player:GetAttributeChangedSignal("xToiletHP"):Connect(updateDisplay)
