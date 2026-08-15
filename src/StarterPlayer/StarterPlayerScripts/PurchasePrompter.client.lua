--!strict
-- LOCATION: StarterPlayerScripts/PurchasePrompter.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local promptSkipTimerRequest = ReplicatedStorage.Events:WaitForChild("PromptSkipTimerRequest")

promptSkipTimerRequest.OnClientEvent:Connect(function(productId: number)
	MarketplaceService:PromptProductPurchase(player, productId)
end)