local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local textLabel = script.Parent
local touchPart = textLabel.Parent.Parent.Parent.Parent
local player = Players.LocalPlayer -- ⚡ Fonctionne maintenant car on est en RunContext = Client !

local targetDate = os.time({
	year = 2026, month = 5, day = 27, hour = 20, min = 0, sec = 0    
})

local EVENT_ID = "8229257102275773101" -- A mettre la nouvelle 
local debounce = false

local function updateTimer()
	local currentTime = os.time()
	local timeLeft = targetDate - currentTime

	if timeLeft > 0 then
		local days = math.floor(timeLeft / 86400)
		local hours = math.floor((timeLeft % 86400) / 3600)
		local minutes = math.floor((timeLeft % 3600) / 60)
		local seconds = timeLeft % 60
		textLabel.Text = string.format("%dd:%02dh:%02dm:%02ds", days, hours, minutes, seconds)
	else
		textLabel.Text = "Update out now!"
	end
end

RunService.Heartbeat:Connect(updateTimer)

if touchPart and touchPart:IsA("BasePart") then
	touchPart.Touched:Connect(function(hit)
		if debounce then return end

		-- On vérifie que c'est bien NOTRE joueur qui touche la pièce
		if hit.Parent == player.Character then
			debounce = true

			local success, err = pcall(function() 
				-- On demande la fenêtre d'événement (sans la variable player cette fois !)
				SocialService:PromptRsvpToEventAsync(EVENT_ID) 
			end)

			if not success then
				warn("❌ Erreur Event RSVP : " .. tostring(err))
			end

			task.wait(5)
			debounce = false
		end
	end)
end