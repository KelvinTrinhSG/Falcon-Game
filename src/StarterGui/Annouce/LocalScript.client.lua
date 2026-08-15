local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GlobalMessageEvent = ReplicatedStorage:WaitForChild("GlobalMessageEvent")

local gui = script.Parent
local uiScale = gui:FindFirstChild("UIScale") -- On cible l'UIScale
local holder = gui:WaitForChild("Holder")
local container = holder:WaitForChild("Container")
local template = container:WaitForChild("Template")

template.Visible = false

GlobalMessageEvent.OnClientEvent:Connect(function(data)
	-- ==========================================
	-- 1. DÉBLOCAGE DE SÉCURITÉ MAXIMUM
	-- ==========================================
	gui.Enabled = true
	holder.Visible = true
	container.Visible = true

	-- Si l'UIScale était à 0, on le force à 1 (taille normale)
	if uiScale then
		uiScale.Scale = 1
	end

	-- Puisque Holder est un CanvasGroup, on force son opacité pour le rendre visible
	if holder:IsA("CanvasGroup") then
		holder.GroupTransparency = 0
	end

	-- ==========================================
	-- 2. CRÉATION DU MESSAGE
	-- ==========================================
	local newMsg = template:Clone()
	newMsg.Name = "Annonce_" .. tostring(data.SenderUserId)
	newMsg.Message.Text = data.Message
	newMsg.Owner.Text = data.SenderName

	pcall(function()
		local content = Players:GetUserThumbnailAsync(data.SenderUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		newMsg.ProfilePicture.Icon.Image = content
	end)

	-- On force les textes et l'image à être 100% visibles
	newMsg.BackgroundTransparency = template.BackgroundTransparency
	newMsg.ProfilePicture.BackgroundTransparency = template.ProfilePicture.BackgroundTransparency
	newMsg.Message.TextTransparency = 0
	newMsg.Owner.TextTransparency = 0
	newMsg.ProfilePicture.Icon.ImageTransparency = 0

	newMsg.Visible = true
	newMsg.Parent = container

	local s = Instance.new("Sound", workspace)
	s.SoundId = "rbxassetid://2865227271"
	s:Play()
	game.Debris:AddItem(s, 2)

	task.delay(10, function()
		if newMsg then newMsg:Destroy() end
	end)
end)