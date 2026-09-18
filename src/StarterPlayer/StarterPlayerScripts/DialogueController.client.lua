local StarterGui = game:GetService("StarterGui")
local LocalizationService = game:GetService("LocalizationService")

local Remotes = game.ReplicatedStorage:WaitForChild("Remotes", math.huge)
local createDialogueEvent = Remotes:WaitForChild("createDialogueEvent", math.huge)
local hideDialogueEvent = Remotes:WaitForChild("hideDialogueEvent", math.huge)
local setDialogueImageEvent = Remotes:WaitForChild("setDialogueImageEvent", math.huge)

local richText = require(game.ReplicatedStorage.Modules.RichText)

local player = game.Players.LocalPlayer
local dialogueFrame = player.PlayerGui:WaitForChild("MainGui", math.huge):WaitForChild("DialogueFrame", math.huge)

local function swooshSound()
	local sound = Instance.new("Sound", game.ReplicatedStorage)
	sound.PlaybackSpeed = 1
	sound.Volume = 1
	sound.PlayOnRemove = true
	sound.SoundId = "rbxassetid://4845387138"
	sound:Destroy()
end

hideDialogueEvent.OnClientEvent:Connect(function()
	swooshSound()
	dialogueFrame:TweenPosition(UDim2.new(0.5, 0, 2, 0), .1)
end)

createDialogueEvent.OnClientEvent:Connect(function(english, spanish)
	if dialogueFrame.Position ~= UDim2.new(0.5, 0, 0.85, 0) then
		dialogueFrame:TweenPosition(UDim2.new(0.5, 0, 0.85, 0), .1)
	end

	local ln = LocalizationService.RobloxLocaleId
	local content = english
	if ln == "es-es" and spanish then
		content = spanish
	end

	local textObject = richText:New(dialogueFrame.textFrame, content)
	textObject:Animate(true)
end)

-- Viewport

local function cleanVPF()
	local model = dialogueFrame.ViewportFrame:FindFirstChildOfClass("Model")
	if model then model:Destroy() end

	local cam = dialogueFrame.ViewportFrame:FindFirstChildOfClass("Camera")
	if cam then cam:Destroy() end
end

setDialogueImageEvent.OnClientEvent:Connect(function(charName, color, workspaceName)
	dialogueFrame.nameLabel.TextColor3 = color
	dialogueFrame.nameLabel.Text = charName

	local lookupName = workspaceName or charName
	print("[Dialogue] Looking for:", lookupName)

	local vpCharacter = game.Workspace:FindFirstChild("UpgradedTitanModels")
		and game.Workspace.UpgradedTitanModels:FindFirstChild(lookupName)
	if not vpCharacter then
		warn("[Dialogue] Not found in UpgradedTitanModels:", lookupName)
		return
	end
	print("[Dialogue] Found model:", vpCharacter.Name)

	cleanVPF()

	local obj = vpCharacter:Clone()
	obj.Parent = dialogueFrame.ViewportFrame
	print("[Dialogue] Cloned into ViewportFrame")

	if not obj.PrimaryPart then
		warn("[Dialogue] Model has no PrimaryPart")
		return
	end

	if not obj:FindFirstChild("Head") then
		warn("[Dialogue] Model has no Head")
		return
	end

	local cam = Instance.new("Camera")
	cam.Parent = dialogueFrame.ViewportFrame
	cam.CFrame = CFrame.new(15, 16, -130) * CFrame.Angles(0, math.rad(180), 0)
	dialogueFrame.ViewportFrame.CurrentCamera = cam

	dialogueFrame.ViewportFrame.Ambient = Color3.fromRGB(180, 180, 180)
	dialogueFrame.ViewportFrame.LightDirection = Vector3.new(-1, -1, -1)

	print("[Dialogue] Camera set. CFrame:", cam.CFrame)
end)
