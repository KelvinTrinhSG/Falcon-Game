while wait() do
	local ok, err = pcall(function()
		game.StarterGui:SetCore("ResetButtonCallback", false)
	end)
	if ok then break end
end