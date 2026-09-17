local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local toiletHPLeaderboard = DataStoreService:GetOrderedDataStore("ToiletHPLeaderboard_V1")

local boardModel = script.Parent
local guiPart = boardModel:WaitForChild("GUIPart")
local leaderboardGUI = guiPart:WaitForChild("LeaderboardGUI")
local scrollingFrame = leaderboardGUI:WaitForChild("ScrollingFrame")

local function updateLeaderboard()
	local success, errorMessage = pcall(function()
		local data = toiletHPLeaderboard:GetSortedAsync(false, 30)
		local page = data:GetCurrentPage()

		for i = 1, 30 do
			local placeFrame = scrollingFrame:FindFirstChild("Place_" .. i)
			if placeFrame then
				placeFrame.Visible = false
			end
		end

		for rank, entry in ipairs(page) do
			local userId = tonumber(entry.key)
			local xToiletHP = entry.value

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
					frame.Value.Text = "x" .. tostring(xToiletHP)
				end
			end
		end
	end)

	if not success then
		warn("Erreur Leaderboard ToiletHP : ", errorMessage)
	end
end

local function savePlayerToiletHP(player)
	local profile = PlayerController:GetProfile(player)
	if profile then
		pcall(function()
			toiletHPLeaderboard:SetAsync(tostring(player.UserId), profile.Data.xToiletHP or 1)
		end)
	end
end

Players.PlayerRemoving:Connect(savePlayerToiletHP)

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			savePlayerToiletHP(player)
		end

		updateLeaderboard()
		task.wait(60)
	end
end)
