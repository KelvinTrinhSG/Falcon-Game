--!strict
-- LOCATION: ServerScriptService/DuchessEvent/DuchessEventController.server.lua
-- Duchess / Astro Toilet Event — config only, logic lives in EventClass.

local ServerStorage     = game:GetService("ServerStorage")
local Workspace         = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventClass        = require(script.Parent.EventClass)
local Spawner           = require(script.Parent.AstroToiletSpawner)
local EventSwordManager = require(script.Parent.EventSwordManager)

-- RemoteEvent để client báo player đã join event (click EventTeleport)
local eventsFolder = ReplicatedStorage:WaitForChild("Events")
local duchessEventJoin = Instance.new("RemoteEvent")
duchessEventJoin.Name   = "DuchessEventJoin"
duchessEventJoin.Parent = eventsFolder

duchessEventJoin.OnServerEvent:Connect(function(player)
	print("[DuchessEvent] DuchessEventJoin received from", player.Name)
	EventSwordManager.give(player)
end)

-- ============================================================
-- TitanTVMan teleport
-- ============================================================

local TITAN_TVMAN_DEFAULT = CFrame.new(12.165, 13.304, -114.671) * CFrame.Angles(0, 0, 0)
local TITAN_TVMAN_EVENT   = CFrame.new(12.165, 13.304, -111.828) * CFrame.Angles(0, math.rad(180), 0)

local function pivotTitanTVMan(cf: CFrame)
	local upgradedModels = Workspace:FindFirstChild("UpgradedTitanModels")
	local model = upgradedModels and (upgradedModels :: any):FindFirstChild("UpgradedTitanTVMan") :: Model?
	if not model then
		warn("[DuchessEvent] UpgradedTitanTVMan not found")
		return
	end
	model:PivotTo(cf)
end

local floorOriginalCFrame: CFrame? = nil

local function getFloor(): Model?
	local upgradedModels = Workspace:FindFirstChild("UpgradedTitanModels")
	local floor = upgradedModels and (upgradedModels :: any):FindFirstChild("Floor") :: Model?
	if not floor then
		warn("[DuchessEvent] UpgradedTitanModels/Floor not found")
	end
	return floor
end

local function lowerFloor()
	local floor = getFloor()
	if not floor then return end
	local cf = floor:GetPivot()
	floorOriginalCFrame = cf
	floor:PivotTo(CFrame.new(cf.X, -100, cf.Z) * CFrame.Angles(cf:ToEulerAnglesXYZ()))
end

local function restoreFloor()
	local floor = getFloor()
	if not floor then return end
	if not floorOriginalCFrame then
		warn("[DuchessEvent] floorOriginalCFrame not saved — skipping restore")
		return
	end
	floor:PivotTo(floorOriginalCFrame)
	floorOriginalCFrame = nil
end

local function setTouchPartEnabled(partName: string, enabled: boolean)
	local upgradedModels = Workspace:FindFirstChild("UpgradedTitanModels")
	local touchPartsFolder = upgradedModels and (upgradedModels :: any):FindFirstChild("TouchParts")
	local part = touchPartsFolder and (touchPartsFolder :: any):FindFirstChild(partName) :: BasePart?
	if not part then
		warn("[DuchessEvent] TouchParts/" .. partName .. " not found")
		return
	end
	(part :: BasePart).CanTouch = enabled
end

-- Kết quả event: "win" hoặc "lose" — reset mỗi lần start
local eventResult: string = "win"
local shieldHpConnection: RBXScriptConnection? = nil

-- ============================================================
-- Helpers
-- ============================================================

local function getEventFolders(): (Instance?, Instance?)
	local duchessWorkspace = Workspace:FindFirstChild("EventFolder")
		and Workspace.EventFolder:FindFirstChild("DuchessToiletEvent")
	local ssEventFolder = ServerStorage:FindFirstChild("EventFolder")
	local ssDuchess     = ssEventFolder and ssEventFolder:FindFirstChild("DuchessToiletEvent")
	return duchessWorkspace, ssDuchess
end

local function cloneInto(source: Instance?, parent: Instance?, label: string): boolean
	if not source then
		warn("[DuchessEvent] clone: " .. label .. " not found — skipping")
		return false
	end
	if parent and (parent :: any):FindFirstChild(source.Name) then
		warn("[DuchessEvent] clone: " .. source.Name .. " already exists in destination — skipping")
		return false
	end
	source:Clone().Parent = parent
	print("[DuchessEvent] Cloned " .. label)
	return true
end

local function destroyIn(parent: Instance?, name: string, label: string): boolean
	local target = parent and (parent :: any):FindFirstChild(name)
	if not target then
		warn("[DuchessEvent] destroy: " .. label .. " not found — skipping")
		return false
	end
	target:Destroy()
	print("[DuchessEvent] Destroyed " .. label)
	return true
end

-- Props được stash vào SS thay vì clone/destroy để không mất data
local stashedProps: Instance? = nil

local function stashProps(ws: Instance?)
	local props = ws and (ws :: any):FindFirstChild("Props")
	if not props then
		warn("[DuchessEvent] Props not found in Workspace — skipping stash")
		return
	end
	local ss = ServerStorage:FindFirstChild("EventFolder")
		and (ServerStorage :: any).EventFolder:FindFirstChild("DuchessToiletEvent")
	if not ss then
		warn("[DuchessEvent] SS DuchessToiletEvent not found — skipping stash")
		return
	end
	stashedProps = props
	props.Parent = ss
	print("[DuchessEvent] Props stashed to SS")
end

local function unstashProps(ws: Instance?)
	if not stashedProps then
		warn("[DuchessEvent] stashedProps is nil — skipping unstash")
		return
	end
	stashedProps.Parent = ws
	print("[DuchessEvent] Props restored to Workspace")
	stashedProps = nil
end

-- ============================================================
-- Instantiate event
-- ============================================================

local eventInstance = EventClass.new({
	remotePrefix = "DuchessEvent",
	duration     = 240,
	scheduleMins = 30,
	notification = "⚔️ Astro Toilet is attacking! Defend the main base now!",
	notifType    = "Error",
	adminUserId  = 11115679011,

	onStart = function()
		-- Reset kết quả về win (mặc định), ngắt listener cũ nếu còn
		eventResult = "win"
		if shieldHpConnection then
			shieldHpConnection:Disconnect()
			shieldHpConnection = nil
		end

		local ws, ss = getEventFolders()

		-- Di chuyển Props sang SS tạm thời
		stashProps(ws)
		-- Clone Path from ServerStorage into Workspace
		cloneInto((ss :: any):FindFirstChild("Path"),       ws, "SS/.../Path → Workspace")
		-- Clone TVManShield from ServerStorage into Workspace
		cloneInto((ss :: any):FindFirstChild("TVManShield"), ws, "SS/.../TVManShield → Workspace")
		-- Clone DuchessToilet từ SS vào Workspace/DuchessToiletFolder
		local ssDuchessFolder = (ss :: any):FindFirstChild("DuchessToiletFolder")
		local wsDuchessFolder = ws and (ws :: any):FindFirstChild("DuchessToiletFolder")
		local duchessToiletCloned = cloneInto(ssDuchessFolder and (ssDuchessFolder :: any):FindFirstChild("DuchessToilet"), wsDuchessFolder, "SS/.../DuchessToiletFolder/DuchessToilet → Workspace")
		-- Clone Blast vào Workspace chỉ khi DuchessToilet clone thành công
		if duchessToiletCloned then
			cloneInto((ss :: any):FindFirstChild("Blast"), ws, "SS/.../Blast → Workspace")
		end
		-- Set HP via Attribute (same pattern as blocks)
		local shield = ws and (ws :: any):FindFirstChild("TVManShield")
		if shield then
			shield:SetAttribute("Health", 100)
			CollectionService:AddTag(shield, "Damageable")
			-- Khi shield HP về 0 → lose, kết thúc event sớm
			shieldHpConnection = (shield :: any):GetAttributeChangedSignal("Health"):Connect(function()
				local hp = (shield :: any):GetAttribute("Health") or 0
				if hp <= 0 and eventInstance:getState() == "ACTIVE" then
					eventResult = "lose"
					print("[DuchessEvent] TVManShield destroyed — lose")
					eventInstance:_forceEnd()
				end
			end)
		else
			warn("[DuchessEvent] TVManShield not found after clone")
		end

		-- Teleport TitanTVMan to event position
		pivotTitanTVMan(TITAN_TVMAN_EVENT)
		-- Tắt cả 2 touch parts khi event bắt đầu
		setTouchPartEnabled("UpgradedTitanTVMan",     false)
		setTouchPartEnabled("UpgradedTitanTVManFail", false)
		-- Hạ Floor xuống để không cản đường AstroToilet
		lowerFloor()

		-- Start spawning AstroToilets (Path must be in Workspace first)
		Spawner.start()
	end,

	onEnd = function()
		-- Ngắt shield HP listener
		if shieldHpConnection then
			shieldHpConnection:Disconnect()
			shieldHpConnection = nil
		end

		-- Trả lại sword cũ cho tất cả player đã join event
		EventSwordManager.restoreAll()

		-- Stop spawner and destroy all live AstroToilets first
		Spawner.stop()

		local ws, ss = getEventFolders()

		-- Destroy Path in Workspace
		destroyIn(ws, "Path",        "Workspace/.../Path")
		-- Destroy TVManShield in Workspace
		destroyIn(ws, "TVManShield", "Workspace/.../TVManShield")
		-- Xóa DuchessToilet trong Workspace/DuchessToiletFolder
		local wsDuchessFolder = ws and (ws :: any):FindFirstChild("DuchessToiletFolder")
		destroyIn(wsDuchessFolder, "DuchessToilet", "Workspace/.../DuchessToiletFolder/DuchessToilet")
		-- Luôn xóa Blast khi hết event dù DuchessToilet có xóa được hay không
		destroyIn(ws, "Blast", "Workspace/.../Blast")
		-- Đưa Props về lại Workspace
		unstashProps(ws)

		-- Teleport TitanTVMan back to default position
		pivotTitanTVMan(TITAN_TVMAN_DEFAULT)
		-- Enable touch part theo kết quả event
		print("[DuchessEvent] Event result:", eventResult)
		if eventResult == "win" then
			setTouchPartEnabled("UpgradedTitanTVMan",     true)
			setTouchPartEnabled("UpgradedTitanTVManFail", false)
		else
			setTouchPartEnabled("UpgradedTitanTVMan",     false)
			setTouchPartEnabled("UpgradedTitanTVManFail", true)
		end
		-- Đưa Floor trở lại vị trí ban đầu
		restoreFloor()
	end,
})
