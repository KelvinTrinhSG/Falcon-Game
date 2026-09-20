local DefaultServerSoundEvent = nil
DefaultServerSoundEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultServerSoundEvent")
if DefaultServerSoundEvent == nil then
	DefaultServerSoundEvent = Instance.new("RemoteEvent", game:GetService("ReplicatedStorage"))
	DefaultServerSoundEvent.Name = "DefaultServerSoundEvent"
end

function CreateNewSound(name, id, looped, pitch, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Name = name
	sound.archivable = false
	sound.Parent = parent
	sound.Pitch = pitch
	sound.Looped = looped
	
	sound.MinDistance = 5
	sound.MaxDistance = 150
	sound.Volume = 0.65
	
	if DefaultServerSoundEvent then
		local CharacterSoundEvent = Instance.new("RemoteEvent", sound)
		CharacterSoundEvent.Name = "CharacterSoundEvent"
		local Players = game:GetService("Players")
		CharacterSoundEvent.OnServerEvent:connect(function(player, playing, resetPosition)
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= player then
					DefaultServerSoundEvent:FireClient(p, sound, playing, resetPosition)
				end
			end
		end)
	end
	return sound
end

local head = script.Parent:FindFirstChild("Head")
if head == nil then
	error("Sound script parent has no child Head.")
	return
end


CreateNewSound("GettingUp", 	"rbxasset://sounds/action_get_up.mp3",					false, 	1,		head)
CreateNewSound("Died", 		"rbxasset://sounds/uuhhh.mp3",							false, 	1,		head) 
CreateNewSound("FreeFalling", 	"rbxasset://sounds/action_falling.mp3",				true,	1,		head)
CreateNewSound("Jumping", 		"rbxasset://sounds/action_jump.mp3",					false,	1,		head)
CreateNewSound("Landing", 		"rbxasset://sounds/action_jump_land.mp3",				false,	1,		head)
CreateNewSound("Splash", 		"rbxasset://sounds/impact_water.mp3",					false, 	1,		head)
CreateNewSound("Running", 		"rbxasset://sounds/action_footsteps_plastic.mp3",		true, 	1.85,	head)
CreateNewSound("Swimming", 	"rbxasset://sounds/action_swim.mp3",					true,	1.6,	head)
CreateNewSound("Climbing", 	"rbxasset://sounds/action_footsteps_plastic.mp3",		true,	1,		head)