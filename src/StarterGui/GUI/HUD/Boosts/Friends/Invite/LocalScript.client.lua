local SocialService = game:GetService("SocialService")
local player = game.Players.LocalPlayer

script.Parent.MouseButton1Click:Connect(function()
	SocialService:PromptGameInvite(player)
end)