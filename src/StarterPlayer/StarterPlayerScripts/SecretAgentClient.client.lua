local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationManager = require(ReplicatedStorage.Modules.NotificationManager)

local eventRemote = ReplicatedStorage:WaitForChild("Events", math.huge)
	:WaitForChild("SecretAgentEventNotify", math.huge)

eventRemote.OnClientEvent:Connect(function(action: string)
	if action == "start" then
		NotificationManager.show("Secret Agent has appeared! Go find them!", "Info")
	elseif action == "end" then
		NotificationManager.show("The Secret Agent Event has ended.", "Info")
	elseif action == "collect" then
		NotificationManager.show("You collected a Secret Agent turret!", "Success")
	end
end)
