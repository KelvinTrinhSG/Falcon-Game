local Remotes = game.ReplicatedStorage:WaitForChild("Remotes", math.huge)
local getTVManCooldown = Remotes:WaitForChild("getTVManCooldown", math.huge)

local timerLabel = workspace:WaitForChild("UpgradedTitanModels", math.huge)
	:WaitForChild("Floor", math.huge)
	:WaitForChild("RestockGUI", math.huge)
	:WaitForChild("TimerLabel", math.huge)

local function formatTime(seconds)
	local m = math.floor(seconds / 60)
	local s = math.floor(seconds % 60)
	return string.format("%02d:%02d", m, s)
end

while true do
	local remaining = getTVManCooldown:InvokeServer()

	if remaining > 0 then
		while remaining > 0 do
			timerLabel.Text = formatTime(remaining)
			task.wait(1)
			remaining -= 1
		end
	end

	timerLabel.Text = "Ready for Support"
	task.wait(5)
end
