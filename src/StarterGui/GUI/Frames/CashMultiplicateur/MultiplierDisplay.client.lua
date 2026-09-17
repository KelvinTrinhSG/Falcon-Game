local Players = game:GetService("Players")
local player = Players.LocalPlayer

local frame = script.Parent
local textLabel = frame:WaitForChild("Value")

local function updateMultiplierUI()
	local cashMult = player:GetAttribute("CashMultiplier") or 1
	local xMoney = player:GetAttribute("xMoney") or 1
	local total = cashMult * xMoney

	warn("[MultiplierGUI] cashMult:", cashMult, "| xMoney:", xMoney, "| total:", total, "| frame.Visible will be:", total > 1)

	if total > 1 then
		frame.Visible = true
		textLabel.Text = "x" .. tostring(math.floor(total * 100) / 100)
	else
		frame.Visible = false
	end
end

updateMultiplierUI()

player:GetAttributeChangedSignal("CashMultiplier"):Connect(function()
	warn("[MultiplierGUI] CashMultiplier changed ->", player:GetAttribute("CashMultiplier"))
	updateMultiplierUI()
end)
player:GetAttributeChangedSignal("xMoney"):Connect(updateMultiplierUI)

-- Fallback: recheck sau 3s và 6s phòng trường hợp server set trước khi signal connect
task.delay(3, updateMultiplierUI)
task.delay(6, updateMultiplierUI)
