--!strict
-- LOCATION: ServerScriptService/Controllers/BlockHealthBarController.lua
-- Updates HealthBarBillboardGui on placed blocks when their Health attribute changes.

-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local ItemConfigsModule = require(ReplicatedStorage.Modules.ItemConfigurations)

local AllItemConfigs: {[string]: any} = {}
for id, config in pairs(ItemConfigsModule.ItemConfigurations) do
	AllItemConfigs[id] = config
end
for id, config in pairs(ItemConfigsModule.LimitedItems) do
	AllItemConfigs[id] = config
end

-- Controller Definition
local BlockHealthBarController = {}

local function setupHealthBar(block: Model)
	local billboard = block:FindFirstChild("HealthBarBillboardGui", true)
	if not billboard then return end

	local bar = billboard:FindFirstChild("Bar")
	local hpText = billboard:FindFirstChild("Hp")
	if not bar or not hpText then return end

	local config = AllItemConfigs[block.Name]
	local maxHealth: number = (config and config.Health) or 100
	local barOriginalSize: UDim2 = bar.Size

	local adornee = block.PrimaryPart or block:FindFirstChildWhichIsA("BasePart")
	billboard.Adornee = adornee
	billboard.Enabled = false

	local function update()
		local currentHealth = math.max(0, block:GetAttribute("Health") or maxHealth)
		local pct = currentHealth / maxHealth

		bar.Size = UDim2.new(
			barOriginalSize.X.Scale * pct,
			barOriginalSize.X.Offset * pct,
			barOriginalSize.Y.Scale,
			barOriginalSize.Y.Offset
		)
		hpText.Text = math.floor(currentHealth) .. " / " .. math.floor(maxHealth)
		billboard.Enabled = currentHealth > 0
	end

	task.defer(update)
	block:GetAttributeChangedSignal("Health"):Connect(update)
end

function BlockHealthBarController:Init(_controllers: {[string]: any}) end

function BlockHealthBarController:Start()
	CollectionService:GetInstanceAddedSignal("Damageable"):Connect(setupHealthBar)
	for _, block in CollectionService:GetTagged("Damageable") do
		task.spawn(setupHealthBar, block)
	end
end

return BlockHealthBarController
