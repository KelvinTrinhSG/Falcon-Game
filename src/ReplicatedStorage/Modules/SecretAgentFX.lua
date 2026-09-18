--!strict
-- Module: SecretAgentFX
-- Handles client-side visual effects for the SecretAgent turret's passive cash tick.
-- Call SecretAgentFX.init() once from a LocalScript.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SecretAgentFX = {}

function SecretAgentFX.init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local remotes = ReplicatedStorage:WaitForChild("Remotes", math.huge)
	local cashFXEvent = remotes:WaitForChild("SecretAgentCashFX", math.huge)

	local indicatorSource = ReplicatedStorage:WaitForChild("Models", math.huge):WaitForChild("CashIndicator", math.huge)
	local originalSize: UDim2 = indicatorSource.Size
	local pool: {BillboardGui} = {}
	local rng = Random.new()

	local function getIndicator(): BillboardGui
		if #pool > 0 then
			return table.remove(pool) :: BillboardGui
		end
		local clone = indicatorSource:Clone()
		clone.Parent = playerGui
		return clone :: BillboardGui
	end

	local function returnIndicator(indicator: BillboardGui)
		indicator.Adornee = nil
		indicator.Enabled = false
		indicator.Size = originalSize  -- reset về gốc trước khi pool lại
		table.insert(pool, indicator)
	end

	cashFXEvent.OnClientEvent:Connect(function(turretModel: Model)
		-- Emit money particle
		local placementBox = turretModel:FindFirstChild("PlacementBox", true)
		if placementBox then
			local moneyParticle = placementBox:FindFirstChild("Money")
			if moneyParticle and moneyParticle:IsA("ParticleEmitter") then
				moneyParticle:Emit(10)
			end
		end

		-- Float "+2" cash indicator
		local rootPart = turretModel.PrimaryPart
		if not rootPart then return end

		local indicator = getIndicator()
		local textLabel = indicator:FindFirstChildWhichIsA("TextLabel", true)
		if textLabel then
			textLabel.Text = "+2"
			textLabel.TextSize = 36
		end

		local startOffset = Vector3.new(
			rng:NextNumber(-1, 1),
			rng:NextNumber(2, 3),
			rng:NextNumber(-1, 1)
		)
		indicator.StudsOffset = startOffset
		indicator.Adornee = rootPart
		indicator.Enabled = true

		local tween = TweenService:Create(
			indicator,
			TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ StudsOffset = startOffset + Vector3.new(0, 3, 0), Size = UDim2.new(0, 0, 0, 0) }
		)
		tween.Completed:Once(function()
			returnIndicator(indicator)
			tween:Destroy()
		end)
		tween:Play()
	end)
end

return SecretAgentFX
