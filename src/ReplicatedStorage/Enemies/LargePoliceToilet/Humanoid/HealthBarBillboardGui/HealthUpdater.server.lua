local billboard = script.Parent
local bar = billboard:WaitForChild("Bar")
local hpText = billboard:WaitForChild("Hp")

-- BillboardGui is inside Humanoid (not a BasePart), so we must set Adornee
-- to HumanoidRootPart for it to render at the correct 3D position above the enemy
local character = billboard.Parent.Parent
local humanoid = billboard.Parent

-- Set Adornee to HumanoidRootPart so the billboard renders above the enemy
local rootPart = character:WaitForChild("HumanoidRootPart")
billboard.Adornee = rootPart

local originalSize = bar.Size

local function updateHealth()
	local currentHealth = math.max(0, humanoid.Health)
	local maxHealth = humanoid.MaxHealth

	if maxHealth <= 0 then return end

	local healthPercent = currentHealth / maxHealth

	bar.Size = UDim2.new(
		originalSize.X.Scale * healthPercent,
		originalSize.X.Offset * healthPercent,
		originalSize.Y.Scale,
		originalSize.Y.Offset
	)

	hpText.Text = math.floor(currentHealth) .. " / " .. math.floor(maxHealth)

	billboard.Enabled = currentHealth > 0 and currentHealth < maxHealth
end

humanoid.HealthChanged:Connect(updateHealth)

-- Also re-run when MaxHealth changes (e.g. set by WaveController after spawn)
humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth)

-- Wait one frame so WaveController has time to set MaxHealth/Health before reading
task.defer(updateHealth)
