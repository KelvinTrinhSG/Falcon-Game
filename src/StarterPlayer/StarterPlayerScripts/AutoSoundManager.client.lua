--!strict
-- LOCATION: StarterPlayer > StarterPlayerScripts > AutoSoundManager

local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ⚡ Création automatique des groupes pour éviter TOUTE erreur ou oubli dans Studio
local sfxGroup = SoundService:FindFirstChild("SFXGroup")
if not sfxGroup then
	sfxGroup = Instance.new("SoundGroup")
	sfxGroup.Name = "SFXGroup"
	sfxGroup.Parent = SoundService
end

local musicGroup = SoundService:FindFirstChild("MusicGroup")
if not musicGroup then
	musicGroup = Instance.new("SoundGroup")
	musicGroup.Name = "MusicGroup"
	musicGroup.Parent = SoundService
end

-- ==========================================
-- 🎧 FONCTION DE TRI AUTOMATIQUE
-- ==========================================
local function autoAssignSound(instance: Instance)
	if instance:IsA("Sound") then
		local nameLower = string.lower(instance.Name)

		-- Tri intelligent selon le nom du fichier audio
		if string.find(nameLower, "music") or string.find(nameLower, "song") or string.find(nameLower, "theme") or string.find(nameLower, "bgm") then
			instance.SoundGroup = musicGroup
		else
			instance.SoundGroup = sfxGroup
		end
	end
end

-- Scan complet au démarrage
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do autoAssignSound(obj) end
for _, obj in ipairs(Workspace:GetDescendants()) do autoAssignSound(obj) end
for _, obj in ipairs(SoundService:GetDescendants()) do 
	if obj ~= sfxGroup and obj ~= musicGroup then autoAssignSound(obj) end 
end

-- Écoute en direct pendant la partie (Tourelles posées, vagues de Slimes...)
Workspace.DescendantAdded:Connect(autoAssignSound)
ReplicatedStorage.DescendantAdded:Connect(autoAssignSound)
SoundService.DescendantAdded:Connect(autoAssignSound)

print("🎧 AutoSoundManager : Tous les groupes (SFX & Music) sont opérationnels !")