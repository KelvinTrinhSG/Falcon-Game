--!strict
-- LOCATION: ServerScriptService/AdminResetData30.server.lua
-- Script tạm thời: reset data admin về snapshot wave 30
-- XÓA script này sau khi đã dùng xong

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ADMIN_ID = 11115679011
local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local TARGET_DATA = {
	Cash = 89159,
	Strength = 0,
	HighestWave = 32,
	StartingWave = 25,
	OnboardingStep = "Completed",
	EquippedModel = "Gulf",
	OwnedModels = {"Gulf"},
	EquippedBase = "Core1",
	OwnedBases = {"Core1"},
	LastEquippedWeapon = "WoodSword",
	WeaponInventory = {"WoodSword"},
	Crates = {},
	BlockInventory = {
		CameraGuy = 0,
		EngineerCameraGuy = 0,
		SpeakerGuy = 0,
		TvGuy = 0,
		RockBlock = 0,
		LargeTvGuy = 0,
		LargeSpeakerGuy = 0,
		LargeScientistCameraman = 0,
		LaserCameramanCar = 0,
	},
	BlockShopNextRestock = 1789354414,
	BlockShopStock = {
		CameraGuy = 1,
		EngineerCameraGuy = 3,
		SpeakerGuy = 1,
		TvGuy = 5,
		LargeTvGuy = 5,
		LargeSpeakerGuy = 0,
		LargeScientistCameraman = 2,
		LaserCameramanCar = 2,
		RockBlock = 7,
		ConcreteBlock = 3,
		IceBlock = 0,
		FireBlock = 2,
		LavaBlock = 4,
		ToxicBlock = 7,
		GoldBlock = 0,
		PlasmaBlock = 0,
		CyberBlock = 0,
		TitanBlock = 0,
	},
	WeaponShopNextRestock = 1789354464,
	WeaponShopStock = {
		BasicCrate = 3,
		CameraCrate = 1,
		SpeakerCrate = 2,
	},
	BaseShopNextRestock = 1789354464,
	BaseShopStock = {
		Core1 = 1,
		Core2 = 1,
		Core3 = 1,
		Core4 = 1,
		Core5 = 1,
	},
	PlacedItems = {
		{UniqueId="41966e8f-0c21-4f8e-85fe-0fa8bf4b0f13", ItemId="RockBlock",               Position={-24.057655334472656,2.4749999046325684,-0.02500152587890625,0}},
		{UniqueId="ec30a5d0-c648-4250-886d-12dcd543b4ef", ItemId="TvGuy",                   Position={-28.03265380859375,3.5,4,0}},
		{UniqueId="d2159264-556c-48a9-89f9-75a9e3cf3eb8", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,4,0}},
		{UniqueId="c669684e-1f12-4592-977b-4270643587b6", ItemId="TvGuy",                   Position={-28.03265380859375,3.5,8,0}},
		{UniqueId="7be6fba4-d69b-4c24-82e7-5c65cf328058", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,-4,0}},
		{UniqueId="aaa4e733-1887-4d89-8a66-1a498f54bf73", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,8,0}},
		{UniqueId="5c22edda-50b2-4df3-9502-e7ea64a9680d", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,-8,0}},
		{UniqueId="f25e54a1-3e97-4b02-9941-bcdfe770523b", ItemId="TvGuy",                   Position={3.96734619140625,3.5,0,0}},
		{UniqueId="42fa986b-944d-4105-a534-eef66332d4eb", ItemId="CameraGuy",               Position={19.96734619140625,3.5,4,0}},
		{UniqueId="5c87061d-2199-4d40-b298-6c8b381a6442", ItemId="CameraGuy",               Position={23.96734619140625,3.5,4,0}},
		{UniqueId="9b49ef6f-fe79-40ce-b78c-718b4cf31fdf", ItemId="TvGuy",                   Position={3.96734619140625,3.5,4,0}},
		{UniqueId="ed271a76-b506-4185-b844-42b2716c3f76", ItemId="TvGuy",                   Position={3.96734619140625,3.5,8,0}},
		{UniqueId="d9b13953-4912-4a58-9b94-a0eeae6945cf", ItemId="TvGuy",                   Position={3.96734619140625,3.5,-4,0}},
		{UniqueId="84f50c09-9b73-41a0-a70a-749b46c1e588", ItemId="TvGuy",                   Position={3.96734619140625,3.5,-8,0}},
		{UniqueId="8f72bf0a-638e-4387-88fc-b40626103640", ItemId="CameraGuy",               Position={11.96734619140625,3.5,12,0}},
		{UniqueId="9e1fbcb1-56c1-4133-a7fa-c490e8a0a035", ItemId="CameraGuy",               Position={11.96734619140625,3.5,-12,0}},
		{UniqueId="e9dfe5bc-b6c6-4a51-9d6c-dc04a3c7ca27", ItemId="LaserCameramanCar",       Position={-34.03265380859375,5,6,0}},
		{UniqueId="73462b63-b613-422b-a121-8e4267dfc678", ItemId="TvGuy",                   Position={-20.03265380859375,3.5,12,0}},
		{UniqueId="1bc5ea55-be68-4840-a5e7-ced70c59db68", ItemId="TvGuy",                   Position={-20.03265380859375,3.5,-12,0}},
		{UniqueId="94125a9c-cf87-4b91-af8b-820ded4bccf8", ItemId="TvGuy",                   Position={-28.03265380859375,3.5,-12,0}},
		{UniqueId="2ab06a4f-1c3b-4fea-b9da-0f0478e46db9", ItemId="SpeakerGuy",              Position={-20.03265380859375,3.5,16,0}},
		{UniqueId="e371a669-acb2-4880-864e-364df07d7170", ItemId="SpeakerGuy",              Position={-28.03265380859375,3.5,12,0}},
		{UniqueId="2a5de1eb-3f6f-4682-b950-2d18ba64ac69", ItemId="SpeakerGuy",              Position={-32.03265380859375,3.5,12,0}},
		{UniqueId="2e73f20b-86b1-4ab6-9747-c5a0d33fcac1", ItemId="SpeakerGuy",              Position={-32.03265380859375,3.5,-12,0}},
		{UniqueId="6e8a20e4-890b-4d26-9503-eee8124e170e", ItemId="SpeakerGuy",              Position={-20.03265380859375,3.5,-16,0}},
		{UniqueId="8ce90d89-7f9a-49e2-ad49-ef3ce479e211", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,-12,0}},
		{UniqueId="a03e23e5-f0e9-479b-9d81-e1db7d985b20", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,12,0}},
		{UniqueId="0fd3d34a-3010-411c-9302-f3d50b907e88", ItemId="EngineerCameraGuy",       Position={-12.03265380859375,3.5,-16,0}},
		{UniqueId="338c7232-2186-4d37-b805-ec5b22216a5f", ItemId="TvGuy",                   Position={-40.03265380859375,3.5,-12,0}},
		{UniqueId="1f3b7857-0042-4825-8baa-ca4bc1d9267b", ItemId="TvGuy",                   Position={-36.03265380859375,3.5,-12,0}},
		{UniqueId="839c5742-7066-49d8-94a5-594ee6ef39f0", ItemId="TvGuy",                   Position={-36.03265380859375,3.5,20,0}},
		{UniqueId="93e0f0c4-708d-46bb-a49e-5f431ed0d656", ItemId="TvGuy",                   Position={-36.03265380859375,3.5,12,0}},
		{UniqueId="bb6c6722-a4e9-445c-afe6-728a90feaf23", ItemId="SpeakerGuy",              Position={-32.03265380859375,3.5,20,0}},
		{UniqueId="33c258c9-2f1a-4d83-9510-d6dccd5bb733", ItemId="SpeakerGuy",              Position={-28.03265380859375,3.5,20,0}},
		{UniqueId="37891603-93bd-4953-8689-200650aab230", ItemId="SpeakerGuy",              Position={-24.03265380859375,3.5,20,0}},
		{UniqueId="02b51640-433d-4560-8242-afe54e9345eb", ItemId="SpeakerGuy",              Position={-28.03265380859375,3.5,-20,0}},
		{UniqueId="7c45dde6-e843-4537-a69b-e0cc659a7960", ItemId="TvGuy",                   Position={-36.03265380859375,3.5,-20,0}},
		{UniqueId="8366cf4e-e3b4-4ccf-8815-3dbbf8ac0da4", ItemId="EngineerCameraGuy",       Position={-32.03265380859375,3.5,-20,0}},
		{UniqueId="1514dc98-cdcd-4af3-a2fb-dff93e23e1f8", ItemId="EngineerCameraGuy",       Position={-24.03265380859375,3.5,-20,0}},
		{UniqueId="df99317c-1ce7-47a7-b3a3-a3944313162b", ItemId="LaserCameramanCar",       Position={-38.03265380859375,5,-6,0}},
		{UniqueId="4be3c43f-653e-4856-82b4-12d2af8aa941", ItemId="LargeTvGuy",              Position={-18.03265380859375,5.5,6,0}},
		{UniqueId="cdaf5764-0936-4098-943f-dda331597dc9", ItemId="CameraGuy",               Position={3.96734619140625,3.5,12,0}},
		{UniqueId="9612abe7-78e5-4e0f-993c-7a8557a2a872", ItemId="LargeTvGuy",              Position={-30.03265380859375,5.5,-6,0}},
		{UniqueId="74c35327-4504-4377-b1e9-ba4f94dddf84", ItemId="SpeakerGuy",              Position={-40.03265380859375,3.5,4,0}},
		{UniqueId="883a096f-24d9-4828-acd4-36ff42c7b549", ItemId="SpeakerGuy",              Position={-40.03265380859375,3.5,12,0}},
		{UniqueId="8c833792-fe40-477c-be58-52c6be0554c5", ItemId="TvGuy",                   Position={-40.03265380859375,3.5,20,0}},
		{UniqueId="cd3039d4-73b9-4d11-a62d-f908c1d0c00c", ItemId="LargeScientistCameraman", Position={-18.03265380859375,5,-6,0}},
		{UniqueId="cb7fc2c7-0984-458f-b2d5-b6505e04c4f9", ItemId="TvGuy",                   Position={-4.03265380859375,3.5,-12,0}},
		{UniqueId="fdc598c8-07fe-4b2c-83ed-b8f471054b50", ItemId="EngineerCameraGuy",       Position={-0.03265380859375,3.5,-12,0}},
		{UniqueId="303b8a99-c0ce-4577-8a27-93b765246ac8", ItemId="CameraGuy",               Position={3.96734619140625,3.5,-12,0}},
		{UniqueId="ac754c8b-f911-4339-8a06-107a8f339346", ItemId="SpeakerGuy",              Position={-4.03265380859375,3.5,-20,0}},
		{UniqueId="f818ee1d-f117-4c4c-b860-ae1783362f9d", ItemId="LargeTvGuy",              Position={13.96734619140625,5.5,6,0}},
		{UniqueId="cfb2ee61-b597-4bb0-9bc9-38413c010a9a", ItemId="EngineerCameraGuy",       Position={27.96734619140625,3.5,4,0}},
		{UniqueId="690c2c32-ae38-4484-b3f8-02917b61f71f", ItemId="CameraGuy",               Position={27.96734619140625,3.5,-4,0}},
		{UniqueId="248e2e06-a283-47c9-ab46-ccb01e17afa5", ItemId="SpeakerGuy",              Position={31.96734619140625,3.5,4,0}},
		{UniqueId="5a6fc6e9-b797-4d12-ace1-9253c02c7947", ItemId="SpeakerGuy",              Position={31.96734619140625,3.5,-4,0}},
		{UniqueId="bab7ba53-4702-4b60-9b4c-ced43aabe76c", ItemId="SpeakerGuy",              Position={35.96734619140625,3.5,-4,0}},
		{UniqueId="c94b5f4c-6f81-4a5f-9a76-fa1b58958bb0", ItemId="LargeSpeakerGuy",         Position={-2.03265380859375,5.5,2,0}},
		{UniqueId="eeb1f284-2dfc-4d25-8848-15d58aef0b74", ItemId="LargeSpeakerGuy",         Position={-2.03265380859375,5.5,-6,0}},
		{UniqueId="cbbe8c8f-3a76-4ba7-aa50-bf8d85f8a407", ItemId="SpeakerGuy",              Position={7.96734619140625,3.5,20,0}},
		{UniqueId="81a386a9-1e7c-48d6-a29e-5fbd39daec9a", ItemId="SpeakerGuy",              Position={3.96734619140625,3.5,20,0}},
		{UniqueId="e7b85428-7608-4ecf-adea-f6cd72ef54f0", ItemId="EngineerCameraGuy",       Position={11.96734619140625,3.5,-16,0}},
		{UniqueId="fdb2430c-374b-4ffc-9f22-8b23e2ea2a25", ItemId="EngineerCameraGuy",       Position={7.96734619140625,3.5,-20,0}},
		{UniqueId="4d2fa96b-efe6-4f83-974b-6d54aabab7f9", ItemId="LaserCameramanCar",       Position={-2.03265380859375,5,22,0}},
		{UniqueId="5227c483-6285-462d-83a2-c5296311b789", ItemId="LargeSpeakerGuy",         Position={-14.03265380859375,5.5,18,0}},
		{UniqueId="db726caf-7c10-416c-9ea6-3aff78ebb02b", ItemId="LargeSpeakerGuy",         Position={13.96734619140625,5.5,-6,0}},
		{UniqueId="b084fbfb-afa3-4bfc-b134-6ba0387059c7", ItemId="EngineerCameraGuy",       Position={15.96734619140625,3.5,-12,0}},
		{UniqueId="23bad666-5db6-410c-ba71-d6bae913100d", ItemId="EngineerCameraGuy",       Position={15.96734619140625,3.5,-16,0}},
		{UniqueId="0cbfd8f8-2ce1-413f-b34a-a944e60f6df6", ItemId="EngineerCameraGuy",       Position={3.96734619140625,3.5,-20,0}},
		{UniqueId="7b6f2f9e-daab-4388-a89f-62f500d68ae0", ItemId="LargeSpeakerGuy",         Position={-2.03265380859375,5.5,10,0}},
		{UniqueId="19130b96-c536-48d0-9a60-44a08304af2c", ItemId="LargeTvGuy",              Position={21.96734619140625,5.5,-6,0}},
		{UniqueId="3f30e13a-e685-4864-a8a1-6b7f2144df17", ItemId="TvGuy",                   Position={11.96734619140625,3.5,16,0}},
		{UniqueId="0068d7bb-5c0d-4068-b7da-48badcf6da60", ItemId="SpeakerGuy",              Position={11.96734619140625,3.5,-20,0}},
		{UniqueId="0c22ba91-76dc-4556-802d-0325ec12ae5b", ItemId="CameraGuy",               Position={-8.03265380859375,3.5,-20,0}},
		{UniqueId="6b08c50f-5c07-4f42-8c47-7f81a6478a9d", ItemId="CameraGuy",               Position={-12.03265380859375,3.5,-20,0}},
		{UniqueId="24cac1a3-e699-44b6-90fc-981177eef7b4", ItemId="EngineerCameraGuy",       Position={-8.03265380859375,3.5,20,0}},
	},
}

local function deepCopy(t: {[any]: any}): {[any]: any}
	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

local function resetAdminData(player: Player)
	if player.UserId ~= ADMIN_ID then return end

	local profile = PlayerController:GetProfile(player)
	local waited = 0
	while not profile and waited < 30 do
		task.wait(0.5)
		waited += 0.5
		profile = PlayerController:GetProfile(player)
	end

	if not profile then
		warn("[AdminResetData30] Không tìm thấy profile sau 30s!")
		return
	end

	local newData = deepCopy(TARGET_DATA)
	for k, v in pairs(newData) do
		profile.Data[k] = v
	end

	-- Sync leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cash = leaderstats:FindFirstChild("Cash")
		local hw = leaderstats:FindFirstChild("Highest Wave")
		if cash then cash.Value = profile.Data.Cash end
		if hw then hw.Value = profile.Data.HighestWave end
	end

	print("[AdminResetData30] ✅ Data của", player.Name, "đã được reset về snapshot wave 30!")
end

Players.PlayerAdded:Connect(resetAdminData)
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(resetAdminData, p)
end
