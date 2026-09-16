--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local BASE_RES = Vector2.new(1920, 1080)

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameWinGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- UIScale: tự điều chỉnh theo viewport
local uiScale = Instance.new("UIScale")
uiScale.Parent = screenGui

local function updateScale()
	local vp = camera.ViewportSize
	uiScale.Scale = math.min(vp.X / BASE_RES.X, vp.Y / BASE_RES.Y)
end
updateScale()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)

-- Overlay
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.Position = UDim2.fromScale(0, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.45
overlay.BorderSizePixel = 0
overlay.Parent = screenGui

-- Main frame (dùng offset sau khi scale để giữ tỉ lệ cố định)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(1400, 560)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 20)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 2.5
stroke.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -60, 0, 90)
title.Position = UDim2.new(0, 30, 0, 28)
title.BackgroundTransparency = 1
title.Text = "YOU WIN!"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.Parent = mainFrame

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, -60, 0, 40)
subtitle.Position = UDim2.new(0, 30, 0, 122)
subtitle.BackgroundTransparency = 1
subtitle.Text = "You have completed all waves!"
subtitle.TextColor3 = Color3.fromRGB(190, 190, 210)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.FredokaOne
subtitle.Parent = mainFrame

-- Divider
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -80, 0, 2)
divider.Position = UDim2.new(0, 40, 0, 178)
divider.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
divider.BackgroundTransparency = 0.65
divider.BorderSizePixel = 0
divider.Parent = mainFrame

-- Buttons container (hàng ngang)
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -60, 0, 300)
buttonsFrame.Position = UDim2.new(0, 30, 0, 196)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 14)
listLayout.Parent = buttonsFrame

local BUTTONS = {
	{ name = "PlayAgain",       text = "Play Again",       image = "", color = Color3.fromRGB(50, 170, 80),  order = 1 },
	{ name = "PlayAgainMoney",  text = "x2 Money",         image = "", color = Color3.fromRGB(210, 155, 10), order = 2 },
	{ name = "PlayAgainDamage", text = "x2 Tower Damage",  image = "", color = Color3.fromRGB(210, 50, 50),  order = 3 },
	{ name = "PlayAgainHP",     text = "x2 Toilet HP",     image = "", color = Color3.fromRGB(120, 50, 210), order = 4 },
}

for _, data in ipairs(BUTTONS) do
	local btn = Instance.new("TextButton")
	btn.Name = data.name
	btn.LayoutOrder = data.order
	btn.Size = UDim2.new(0.25, -11, 1, 0)
	btn.BackgroundColor3 = data.color
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = true
	btn.ClipsDescendants = true
	btn.Parent = buttonsFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

	-- ImageLabel (4/5 trên)
	local img = Instance.new("ImageLabel")
	img.Name = "Icon"
	img.Size = UDim2.new(1, 0, 0.8, 0)
	img.Position = UDim2.fromScale(0, 0)
	img.BackgroundTransparency = 1
	img.Image = data.image
	img.ScaleType = Enum.ScaleType.Fit
	img.Parent = btn

	-- TextLabel (1/5 dưới)
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, 0, 0.2, 0)
	label.Position = UDim2.fromScale(0, 0.8)
	label.BackgroundTransparency = 1
	label.Text = data.text
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Parent = btn
end

screenGui.Enabled = false
screenGui.Parent = playerGui

-- Hiện GUI khi server fire GameWin
local gameWinEvent = ReplicatedStorage.Events:WaitForChild("GameWin")
local playAgainMoneyBtn = buttonsFrame:WaitForChild("PlayAgainMoney")
local playAgainMoneyLabel = playAgainMoneyBtn:WaitForChild("Label")
local playAgainDamageBtn = buttonsFrame:WaitForChild("PlayAgainDamage")
local playAgainDamageLabel = playAgainDamageBtn:WaitForChild("Label")
local playAgainHPBtn = buttonsFrame:WaitForChild("PlayAgainHP")
local playAgainHPLabel = playAgainHPBtn:WaitForChild("Label")

gameWinEvent.OnClientEvent:Connect(function(xMoney: number, xTowerDam: number, xToiletHP: number)
	playAgainMoneyLabel.Text = "x" .. ((xMoney or 1) + 1) .. " Money"
	playAgainDamageLabel.Text = "x" .. ((xTowerDam or 1) + 1) .. " Tower Damage"
	playAgainHPLabel.Text = "x" .. ((xToiletHP or 1) + 1) .. " Toilet HP"
	screenGui.Enabled = true
end)

-- Wire nút Play Again
local playAgainEvent = ReplicatedStorage.Events:WaitForChild("PlayAgain")
local playAgainBtn = buttonsFrame:WaitForChild("PlayAgain")
playAgainBtn.MouseButton1Click:Connect(function()
	playAgainBtn.Active = false
	playAgainEvent:FireServer()
end)

-- Wire nút x2 Money
local playAgainMoneyEvent = ReplicatedStorage.Events:WaitForChild("PlayAgainMoney")
playAgainMoneyBtn.MouseButton1Click:Connect(function()
	playAgainMoneyBtn.Active = false
	playAgainMoneyEvent:FireServer()
end)

-- Wire nút x2 Tower Damage
local playAgainDamageEvent = ReplicatedStorage.Events:WaitForChild("PlayAgainDamage")
playAgainDamageBtn.MouseButton1Click:Connect(function()
	playAgainDamageBtn.Active = false
	playAgainDamageEvent:FireServer()
end)

-- Wire nút x2 Toilet HP
local playAgainHPEvent = ReplicatedStorage.Events:WaitForChild("PlayAgainHP")
playAgainHPBtn.MouseButton1Click:Connect(function()
	playAgainHPBtn.Active = false
	playAgainHPEvent:FireServer()
end)
