local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local damageLeaderboard = DataStoreService:GetOrderedDataStore("DamageLeaderboard_V2")

local boardModel = script.Parent
local guiPart = boardModel:WaitForChild("GUIPart")
local leaderboardGUI = guiPart:WaitForChild("LeaderboardGUI")
local scrollingFrame = leaderboardGUI:WaitForChild("ScrollingFrame")

local function updateLeaderboard()
	local success, errorMessage = pcall(function()
		local data = damageLeaderboard:GetSortedAsync(false, 30)
		local page = data:GetCurrentPage()

		for i = 1, 30 do
			local placeFrame = scrollingFrame:FindFirstChild("Place_" .. i)
			if placeFrame then
				placeFrame.Visible = false
			end
		end

		for rank, entry in ipairs(page) do
			local userId = tonumber(entry.key)
			local xTowerDam = entry.value

			local placeFrame = scrollingFrame:FindFirstChild("Place_" .. rank)
			if placeFrame then
				placeFrame.Visible = true

				local numberLabel = placeFrame:FindFirstChild("NumberLabel")
				if numberLabel then
					numberLabel.Text = "#" .. rank
				end

				local frame = placeFrame:FindFirstChild("Frame")
				if frame then
					local username = "Unknown"
					pcall(function()
						username = Players:GetNameFromUserIdAsync(userId)
					end)

					local headshot = "rbxasset://textures/ui/GuiImagePlaceholder.png"
					pcall(function()
						headshot = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
					end)

					frame.NamePlayerLeader.Text = username
					frame.AvatarPlayerLeader.Image = headshot
					frame.Value.Text = "x" .. tostring(xTowerDam)
				end
			end
		end
	end)

	if not success then
		warn("Erreur Leaderboard Damage : ", errorMessage)
	end
end

local function savePlayerDamage(player)
	local profile = PlayerController:GetProfile(player)
	if profile then
		pcall(function()
			damageLeaderboard:SetAsync(tostring(player.UserId), profile.Data.xTowerDam or 1)
		end)
	end
end

Players.PlayerRemoving:Connect(savePlayerDamage)

task.spawn(function()
	task.wait(40)
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerDamage(player)
		end
		updateLeaderboard()
		task.wait(60)
	end
end)
