--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage     = game:GetService("ServerStorage")
local StarterGui        = game:GetService("StarterGui")
local Workspace         = game:GetService("Workspace")

local PACKAGE_NAME = "uxrAdminPanelSystem"

local pkg = script

local function deployFolder(srcFolder, parent)
	local existing = parent:FindFirstChild(PACKAGE_NAME)
	if existing then existing:Destroy() end
	local replica = Instance.new("Folder")
	replica.Name = PACKAGE_NAME
	for _, child in ipairs(srcFolder:GetChildren()) do
		child:Clone().Parent = replica
	end
	replica.Parent = parent
	return replica
end

local rsReplica = deployFolder(pkg.Shared, ReplicatedStorage)

local core = Instance.new("Folder"); core.Name = "Core"; core.Parent = rsReplica
local apEvents = Instance.new("Folder"); apEvents.Name = "apEvents"; apEvents.Parent = core
local re = Instance.new("RemoteEvent");    re.Name = "RemoteEvent";    re.Parent = apEvents
local rf = Instance.new("RemoteFunction"); rf.Name = "RemoteFunction"; rf.Parent = apEvents
local servers = Instance.new("Folder"); servers.Name = "Servers"; servers.Parent = core

local storageSrc = pkg:FindFirstChild("Storage")
if storageSrc then
	local toReenable = {}
	for _, d in ipairs(storageSrc:GetDescendants()) do
		if d:IsA("BaseScript") then
			if not d.Disabled then
				d.Disabled = true
				table.insert(toReenable, d)
			end
		elseif d:IsA("Sound") then
			pcall(function() d:Stop() end)
			d.Playing = false
			d.PlayOnRemove = false
		end
	end

	local existingStorage = ServerStorage:FindFirstChild(PACKAGE_NAME)
	if existingStorage then existingStorage:Destroy() end
	storageSrc.Name = PACKAGE_NAME
	storageSrc.Parent = ServerStorage

	for _, s in ipairs(toReenable) do
		if s.Parent then s.Disabled = false end
	end
end

do
	local existing = Workspace:FindFirstChild(PACKAGE_NAME)
	if existing then existing:Destroy() end
	local wsFolder = Instance.new("Folder"); wsFolder.Name = PACKAGE_NAME
	local builds   = Instance.new("Folder"); builds.Name = "Builds"; builds.Parent = wsFolder

	local storageBuilds = ServerStorage:FindFirstChild(PACKAGE_NAME)
	storageBuilds = storageBuilds and storageBuilds:FindFirstChild("Builds")
	local publicCell = storageBuilds and storageBuilds:FindFirstChild("PublicCell")
	if publicCell then publicCell:Clone().Parent = builds end

	wsFolder.Parent = Workspace
end

for _, child in ipairs(pkg.Client:GetChildren()) do
	if child:IsA("ScreenGui") and not StarterGui:FindFirstChild(child.Name) then
		child:Clone().Parent = StarterGui
	end
end

require(pkg.Server.Bootstrap)
