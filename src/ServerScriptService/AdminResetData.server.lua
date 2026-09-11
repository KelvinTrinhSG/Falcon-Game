--!strict
-- LOCATION: ServerScriptService/AdminResetData.server.lua
-- Script tạm thời: reset data admin về snapshot đã lưu
-- XÓA script này sau khi đã dùng xong

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ADMIN_ID = 11115679011
local PlayerController = require(ServerScriptService.Controllers.PlayerController)

local TARGET_DATA = {
	Cash = 12552,
	Strength = 0,
	HighestWave = 21,
	StartingWave = 15,
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
		LaserCameramanCar = 0,
	},
	BlockShopNextRestock = 1789109956,
	BlockShopStock = {
		CameraGuy = 2,
		EngineerCameraGuy = 2,
		SpeakerGuy = 1,
		TvGuy = 4,
		LargeTvGuy = 1,
		LargeSpeakerGuy = 0,
		LargeScientistCameraman = 0,
		LaserCameramanCar = 1,
		RockBlock = 1,
		ConcreteBlock = 6,
		IceBlock = 7,
		FireBlock = 0,
		LavaBlock = 7,
		ToxicBlock = 0,
		GoldBlock = 0,
		PlasmaBlock = 0,
		CyberBlock = 0,
		TitanBlock = 0,
	},
	WeaponShopNextRestock = 1789109956,
	WeaponShopStock = {
		BasicCrate = 1,
		CameraCrate = 4,
		SpeakerCrate = 2,
	},
	BaseShopNextRestock = 1789109956,
	BaseShopStock = {
		Core1 = 1,
		Core2 = 1,
		Core3 = 1,
		Core4 = 1,
		Core5 = 1,
	},
	PlacedItems = {
		{UniqueId="5fe1e990-a184-4ba3-b7f9-e15a64d2a39e", ItemId="CameraGuy",          Position={-20.03265380859375,3.5,-4,0}},
		{UniqueId="41966e8f-0c21-4f8e-85fe-0fa8bf4b0f13", ItemId="RockBlock",           Position={-24.057655334472656,2.4749999046325684,-0.02500152587890625,0}},
		{UniqueId="ec30a5d0-c648-4250-886d-12dcd543b4ef", ItemId="TvGuy",               Position={-28.03265380859375,3.5,4,0}},
		{UniqueId="d4ae8dab-79af-4a92-9b80-11a303f988b7", ItemId="SpeakerGuy",          Position={-28.03265380859375,3.5,-4,0}},
		{UniqueId="14d56d23-038b-46dd-b315-f844d13b5718", ItemId="CameraGuy",           Position={-20.03265380859375,3.5,4,0}},
		{UniqueId="c09f8b8a-12d8-41f1-b1f4-be6fe41deb7f", ItemId="SpeakerGuy",         Position={-16.03265380859375,3.5,4,0}},
		{UniqueId="b6391f4a-3c27-4e13-830b-42c9c5138855", ItemId="EngineerCameraGuy",   Position={-4.03265380859375,3.5,0,0}},
		{UniqueId="d2159264-556c-48a9-89f9-75a9e3cf3eb8", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,4,0}},
		{UniqueId="c669684e-1f12-4592-977b-4270643587b6", ItemId="TvGuy",               Position={-28.03265380859375,3.5,8,0}},
		{UniqueId="5f1d648c-bb98-4990-8902-03ba1bab448b", ItemId="SpeakerGuy",          Position={-16.03265380859375,3.5,-4,0}},
		{UniqueId="65e65704-822c-46c6-b9be-c5a0f12fd056", ItemId="SpeakerGuy",          Position={-4.03265380859375,3.5,4,0}},
		{UniqueId="a9155ca4-4259-4fd8-a3bd-4c05563793fd", ItemId="SpeakerGuy",          Position={-4.03265380859375,3.5,-4,0}},
		{UniqueId="63cb014d-0539-49b2-b354-e632ca574b4d", ItemId="TvGuy",               Position={-32.03265380859375,3.5,-4,0}},
		{UniqueId="409f3db8-1e94-4bff-892f-f89907b1444e", ItemId="SpeakerGuy",          Position={-28.03265380859375,3.5,-8,0}},
		{UniqueId="7be6fba4-d69b-4c24-82e7-5c65cf328058", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,-4,0}},
		{UniqueId="79b2d58e-25cd-4202-9dcc-d91e27ea3c20", ItemId="EngineerCameraGuy",   Position={-4.03265380859375,3.5,8,0}},
		{UniqueId="6fe27017-4c9e-40ec-ac30-f175a6f4443a", ItemId="EngineerCameraGuy",   Position={-4.03265380859375,3.5,-8,0}},
		{UniqueId="aaa4e733-1887-4d89-8a66-1a498f54bf73", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,8,0}},
		{UniqueId="5c22edda-50b2-4df3-9502-e7ea64a9680d", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,-8,0}},
		{UniqueId="f25e54a1-3e97-4b02-9941-bcdfe770523b", ItemId="TvGuy",               Position={3.96734619140625,3.5,0,0}},
		{UniqueId="d1c77ba0-9fa9-4245-853a-276517d4c0cf", ItemId="EngineerCameraGuy",   Position={11.96734619140625,3.5,4,0}},
		{UniqueId="010f0474-ebb1-47b0-bfb4-252abe4c99d5", ItemId="EngineerCameraGuy",   Position={11.96734619140625,3.5,-4,0}},
		{UniqueId="d786fe54-9f40-4c4f-b482-57218a24a889", ItemId="EngineerCameraGuy",   Position={15.96734619140625,3.5,-4,0}},
		{UniqueId="bd82eee8-14f0-45d6-8d7a-f6c26e6ad08f", ItemId="CameraGuy",           Position={15.96734619140625,3.5,4,0}},
		{UniqueId="42fa986b-944d-4105-a534-eef66332d4eb", ItemId="CameraGuy",           Position={19.96734619140625,3.5,4,0}},
		{UniqueId="5c87061d-2199-4d40-b298-6c8b381a6442", ItemId="CameraGuy",           Position={23.96734619140625,3.5,4,0}},
		{UniqueId="6ef68959-f513-4516-be9f-8c3efb201306", ItemId="CameraGuy",           Position={23.96734619140625,3.5,-4,0}},
		{UniqueId="02d0d7f6-2a80-45e2-984c-99d0c27bf53f", ItemId="CameraGuy",           Position={19.96734619140625,3.5,-4,0}},
		{UniqueId="9b49ef6f-fe79-40ce-b78c-718b4cf31fdf", ItemId="TvGuy",               Position={3.96734619140625,3.5,4,0}},
		{UniqueId="ed271a76-b506-4185-b844-42b2716c3f76", ItemId="TvGuy",               Position={3.96734619140625,3.5,8,0}},
		{UniqueId="d9b13953-4912-4a58-9b94-a0eeae6945cf", ItemId="TvGuy",               Position={3.96734619140625,3.5,-4,0}},
		{UniqueId="84f50c09-9b73-41a0-a70a-749b46c1e588", ItemId="TvGuy",               Position={3.96734619140625,3.5,-8,0}},
		{UniqueId="545ba1a4-b657-413e-b7a8-c4b4feb31e9d", ItemId="SpeakerGuy",          Position={11.96734619140625,3.5,8,0}},
		{UniqueId="74f35165-9563-4e67-9825-87dc271584c6", ItemId="EngineerCameraGuy",   Position={11.96734619140625,3.5,-8,0}},
		{UniqueId="8f72bf0a-638e-4387-88fc-b40626103640", ItemId="CameraGuy",           Position={11.96734619140625,3.5,12,0}},
		{UniqueId="9e1fbcb1-56c1-4133-a7fa-c490e8a0a035", ItemId="CameraGuy",           Position={11.96734619140625,3.5,-12,0}},
		{UniqueId="e9dfe5bc-b6c6-4a51-9d6c-dc04a3c7ca27", ItemId="LaserCameramanCar",   Position={-34.03265380859375,5,6,0}},
		{UniqueId="f1fd4843-179b-4f59-a82f-b79403e52763", ItemId="TvGuy",               Position={-20.03265380859375,3.5,8,0}},
		{UniqueId="73462b63-b613-422b-a121-8e4267dfc678", ItemId="TvGuy",               Position={-20.03265380859375,3.5,12,0}},
		{UniqueId="d58dd965-001f-4b1c-ac16-ba0de7a4a1b7", ItemId="TvGuy",               Position={-20.03265380859375,3.5,-8,0}},
		{UniqueId="1bc5ea55-be68-4840-a5e7-ced70c59db68", ItemId="TvGuy",               Position={-20.03265380859375,3.5,-12,0}},
		{UniqueId="94125a9c-cf87-4b91-af8b-820ded4bccf8", ItemId="TvGuy",               Position={-28.03265380859375,3.5,-12,0}},
		{UniqueId="2ab06a4f-1c3b-4fea-b9da-0f0478e46db9", ItemId="SpeakerGuy",          Position={-20.03265380859375,3.5,16,0}},
		{UniqueId="e371a669-acb2-4880-864e-364df07d7170", ItemId="SpeakerGuy",          Position={-28.03265380859375,3.5,12,0}},
		{UniqueId="2a5de1eb-3f6f-4682-b950-2d18ba64ac69", ItemId="SpeakerGuy",          Position={-32.03265380859375,3.5,12,0}},
		{UniqueId="2e73f20b-86b1-4ab6-9747-c5a0d33fcac1", ItemId="SpeakerGuy",          Position={-32.03265380859375,3.5,-12,0}},
		{UniqueId="6e8a20e4-890b-4d26-9503-eee8124e170e", ItemId="SpeakerGuy",          Position={-20.03265380859375,3.5,-16,0}},
		{UniqueId="8ce90d89-7f9a-49e2-ad49-ef3ce479e211", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,-12,0}},
		{UniqueId="a03e23e5-f0e9-479b-9d81-e1db7d985b20", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,12,0}},
		{UniqueId="0fd3d34a-3010-411c-9302-f3d50b907e88", ItemId="EngineerCameraGuy",   Position={-12.03265380859375,3.5,-16,0}},
		{UniqueId="338c7232-2186-4d37-b805-ec5b22216a5f", ItemId="TvGuy",               Position={-40.03265380859375,3.5,-12,0}},
		{UniqueId="1f3b7857-0042-4825-8baa-ca4bc1d9267b", ItemId="TvGuy",               Position={-36.03265380859375,3.5,-12,0}},
		{UniqueId="839c5742-7066-49d8-94a5-594ee6ef39f0", ItemId="TvGuy",               Position={-36.03265380859375,3.5,20,0}},
		{UniqueId="93e0f0c4-708d-46bb-a49e-5f431ed0d656", ItemId="TvGuy",               Position={-36.03265380859375,3.5,12,0}},
		{UniqueId="bb6c6722-a4e9-445c-afe6-728a90feaf23", ItemId="SpeakerGuy",          Position={-32.03265380859375,3.5,20,0}},
		{UniqueId="33c258c9-2f1a-4d83-9510-d6dccd5bb733", ItemId="SpeakerGuy",          Position={-28.03265380859375,3.5,20,0}},
		{UniqueId="37891603-93bd-4953-8689-200650aab230", ItemId="SpeakerGuy",          Position={-24.03265380859375,3.5,20,0}},
		{UniqueId="02b51640-433d-4560-8242-afe54e9345eb", ItemId="SpeakerGuy",          Position={-28.03265380859375,3.5,-20,0}},
		{UniqueId="7c45dde6-e843-4537-a69b-e0cc659a7960", ItemId="TvGuy",               Position={-36.03265380859375,3.5,-20,0}},
		{UniqueId="8366cf4e-e3b4-4ccf-8815-3dbbf8ac0da4", ItemId="EngineerCameraGuy",   Position={-32.03265380859375,3.5,-20,0}},
		{UniqueId="1514dc98-cdcd-4af3-a2fb-dff93e23e1f8", ItemId="EngineerCameraGuy",   Position={-24.03265380859375,3.5,-20,0}},
		{UniqueId="60d5589b-daa5-4667-a60e-63ccd55a41a2", ItemId="EngineerCameraGuy",   Position={-16.03265380859375,3.5,-8,0}},
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

	task.wait(2)

	local profile = PlayerController:GetProfile(player)
	if not profile then
		warn("[AdminResetData] Không tìm thấy profile!")
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

	print("[AdminResetData] ✅ Data của", player.Name, "đã được reset về snapshot!")
end

Players.PlayerAdded:Connect(resetAdminData)
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(resetAdminData, p)
end
