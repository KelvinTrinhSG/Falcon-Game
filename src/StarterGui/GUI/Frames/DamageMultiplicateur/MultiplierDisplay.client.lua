local Players = game:GetService("Players")
local player = Players.LocalPlayer

local frame = script.Parent
local textLabel = frame:WaitForChild("Value")

local function updateDisplay()
	local xTowerDam = player:GetAttribute("xTowerDam") or 1

	if xTowerDam > 1 then
		frame.Visible = true
		textLabel.Text = "x" .. tostring(xTowerDam)
	else
		frame.Visible = false
	end
end

updateDisplay()

player:GetAttributeChangedSignal("xTowerDam"):Connect(updateDisplay)
