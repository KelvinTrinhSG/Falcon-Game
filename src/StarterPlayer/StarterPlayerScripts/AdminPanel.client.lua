--!strict
-- LOCATION: StarterPlayerScripts/AdminPanel.client.lua
-- GUI chỉ hiện cho admin (UserId 11115679011)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local ADMIN_ID = 11115679011

if player.UserId ~= ADMIN_ID then return end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 210, 0, 44)
frame.Position = UDim2.new(0, 10, 0.5, -22)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -8, 1, -8)
button.Position = UDim2.new(0, 4, 0, 4)
button.BackgroundColor3 = Color3.fromRGB(220, 80, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "[ADMIN] Log My Data"
button.Font = Enum.Font.GothamBold
button.TextSize = 13
button.BorderSizePixel = 0
button.AutoButtonColor = true
button.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = button

-- Chờ RemoteFunction từ server
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local adminGetData = eventsFolder:WaitForChild("AdminGetData", 10)

if not adminGetData then
	warn("[AdminPanel] Không tìm thấy AdminGetData RemoteFunction!")
	return
end

button.MouseButton1Click:Connect(function()
	button.Text = "Loading..."
	button.Active = false

	local ok, data = pcall(function()
		return adminGetData:InvokeServer()
	end)

	if ok and data then
		print("\n========== MY DATA (CLIENT) ==========")
		local function printTable(t: {[any]: any}, indent: string)
			indent = indent or "  "
			for k, v in pairs(t) do
				if type(v) == "table" then
					print(indent .. tostring(k) .. ":")
					printTable(v, indent .. "  ")
				else
					print(indent .. tostring(k) .. " = " .. tostring(v))
				end
			end
		end
		printTable(data, "  ")
		print("======================================\n")
		button.Text = "Done! Check Output"
		button.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
	else
		warn("[AdminPanel] Lỗi hoặc không có data:", tostring(data))
		button.Text = "Error!"
		button.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	end

	task.wait(2)
	button.Text = "[ADMIN] Log My Data"
	button.BackgroundColor3 = Color3.fromRGB(220, 80, 0)
	button.Active = true
end)
