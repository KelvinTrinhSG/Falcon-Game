--!strict
-- Manages all visual elements and client-side triggers for the multi-step onboarding.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("GUI")

-- Modules
local FrameManager = require(ReplicatedStorage.Modules.FrameManager)

-- Events
local UpdateOnboardingStepEvent = ReplicatedStorage.Events:WaitForChild("UpdateOnboardingStep")
local EndOnboardingEvent = ReplicatedStorage.Events:WaitForChild("EndOnboarding")
local OnboardingStepCompletedEvent = ReplicatedStorage.Events:WaitForChild("OnboardingStepCompleted")

-- UI & World References
local instructionsLabel = gui.Frames:WaitForChild("Instructions")
local beamTemplate = ReplicatedStorage.Templates:WaitForChild("OnboardingBeam")
local onboardingStepValue = ReplicatedStorage:WaitForChild("OnboardingStep")

local hudTopButtons = gui.HUD.Top.Buttons
local shopTeleportButton = hudTopButtons:WaitForChild("ShopTeleport")
local plotTeleportButton = hudTopButtons:WaitForChild("PlotTeleport")
local waveButton = hudTopButtons:WaitForChild("WaveButton")

local hudBottomButtons = gui.HUD.Bottom
local inventoryButton = hudBottomButtons:WaitForChild("Inventory")

local blocksShopModel = Workspace:WaitForChild("BlocksShop")

local onboardingImages = {
	ShopTeleport = shopTeleportButton:WaitForChild("Onboarding"),
	PlotTeleport = plotTeleportButton:WaitForChild("Onboarding"),
	WaveButton = waveButton:WaitForChild("Onboarding"),
	Inventory = inventoryButton:WaitForChild("Onboarding"),
}

-- State
local currentStep = ""
local beam: Beam?
local attachment0: Attachment?
local attachment1: Attachment?

local function cleanup()
	instructionsLabel.Visible = false
	for _, image in pairs(onboardingImages) do
		image.Visible = false
	end
	if beam then beam:Destroy() beam = nil end
	if attachment0 then attachment0:Destroy() attachment0 = nil end
	if attachment1 then attachment1:Destroy() attachment1 = nil end
end

local function setStep(stepName: string)
	if currentStep == stepName then return end
	cleanup()
	currentStep = stepName
	onboardingStepValue.Value = stepName
	print("Onboarding step:", stepName)

	if stepName == "Step1_TeleportToShop" then
		instructionsLabel.Text = "Teleport to the shop!"
		instructionsLabel.Visible = true
		onboardingImages.ShopTeleport.Visible = true

	elseif stepName == "Step2_OpenDefenceShop" then
		instructionsLabel.Text = "Walk to the Defence Shop!"
		instructionsLabel.Visible = true
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			player.CharacterAdded:Wait()
		end
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

		if not blocksShopModel.PrimaryPart then
			warn("[OnboardingHandler] The 'BlocksShop' model in Workspace is missing its PrimaryPart! The beam cannot be created.")
			return
		end

		if humanoidRootPart then
			attachment0 = Instance.new("Attachment")
			attachment0.Parent = humanoidRootPart
			attachment1 = Instance.new("Attachment")
			attachment1.Parent = blocksShopModel.PrimaryPart
			beam = beamTemplate:Clone()
			beam.Attachment0 = attachment1
			beam.Attachment1 = attachment0
			beam.Parent = humanoidRootPart
		end

	elseif stepName == "Step3_BuyOldTurret" then
		instructionsLabel.Text = "Buy an old turret!"
		instructionsLabel.Visible = true

		-- ==========================================
		-- ⚡ LA NOUVELLE ÉTAPE DU BLOC
		-- ==========================================
		-- ==========================================
		-- ⚡ LA NOUVELLE ÉTAPE DU BLOC (AVEC LA FLÈCHE)
		-- ==========================================
	elseif stepName == "Step3b_BuyFirstBlock" then
		instructionsLabel.Text = "Buy a block for defense!"
		instructionsLabel.Visible = true

		-- On recrée le laser vers la boutique de défense
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			player.CharacterAdded:Wait()
		end
		local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

		if blocksShopModel.PrimaryPart and humanoidRootPart then
			attachment0 = Instance.new("Attachment")
			attachment0.Parent = humanoidRootPart
			attachment1 = Instance.new("Attachment")
			attachment1.Parent = blocksShopModel.PrimaryPart
			beam = beamTemplate:Clone()
			beam.Attachment0 = attachment1
			beam.Attachment1 = attachment0
			beam.Parent = humanoidRootPart
		end
		-- ==========================================e
		-- ==========================================

	elseif stepName == "Step4_TeleportToPlot" then
		instructionsLabel.Text = "Teleport to your plot!"
		instructionsLabel.Visible = true
		onboardingImages.PlotTeleport.Visible = true

	elseif stepName == "Step5_OpenInventory" then
		instructionsLabel.Text = "Open your inventory!"
		instructionsLabel.Visible = true
		onboardingImages.Inventory.Visible = true
		
	elseif stepName == "Step6_PlaceOldTurret" then
		instructionsLabel.Text = "Place down your old turret!"
		instructionsLabel.Visible = true

		-- ==========================================
		-- ⚡ AJOUTÉ : Instruction pour poser le bloc de carton
		-- ==========================================
	elseif stepName == "Step6b_PlaceCardboardBlock" then
		instructionsLabel.Text = "Place down your Cardboard Block!"
		instructionsLabel.Visible = true
		-- ==========================================

	elseif stepName == "Step7_StartFight" then
		instructionsLabel.Text = "Start the fight!"
		instructionsLabel.Visible = true
		onboardingImages.WaveButton.Visible = true

	elseif stepName == "Completed" then
		cleanup()
	end
end

UpdateOnboardingStepEvent.OnClientEvent:Connect(setStep)
EndOnboardingEvent.OnClientEvent:Connect(cleanup)

shopTeleportButton.MouseButton1Click:Connect(function()
	if currentStep == "Step1_TeleportToShop" then
		OnboardingStepCompletedEvent:FireServer("Step1_TeleportToShop")
	end
end)

plotTeleportButton.MouseButton1Click:Connect(function()
	if currentStep == "Step4_TeleportToPlot" then
		OnboardingStepCompletedEvent:FireServer("Step4_TeleportToPlot")
	end
end)

inventoryButton.MouseButton1Click:Connect(function()
	if currentStep == "Step5_OpenInventory" then
		-- This step is completed by the FrameManager connection below.
	end
end)

FrameManager.onFrameOpened(function(frameName)
	if frameName == "BlocksShop" and currentStep == "Step2_OpenDefenceShop" then
		OnboardingStepCompletedEvent:FireServer("Step2_OpenDefenceShop")
	elseif frameName == "Inventory" and currentStep == "Step5_OpenInventory" then
		OnboardingStepCompletedEvent:FireServer("Step5_OpenInventory")
	end
end)