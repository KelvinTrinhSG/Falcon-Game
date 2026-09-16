local Players = game:GetService("Players")
local player = Players.LocalPlayer

local frame = script.Parent
local textLabel = frame:WaitForChild("Value")

local function updateMultiplierUI()
	local cashMult = player:GetAttribute("CashMultiplier") or 1
	local xMoney = player:GetAttribute("xMoney") or 1
	local total = cashMult * xMoney

	if total > 1 then
		frame.Visible = true
		textLabel.Text = "x" .. tostring(math.floor(total * 100) / 100)
	else
		frame.Visible = false
	end
end

updateMultiplierUI()

player:GetAttributeChangedSignal("CashMultiplier"):Connect(updateMultiplierUI)
player:GetAttributeChangedSignal("xMoney"):Connect(updateMultiplierUI)
