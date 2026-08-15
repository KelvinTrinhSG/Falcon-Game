--!strict
--[[
	SCRIPT: SoundHandler (LocalScript)
	LOCATION: GUI.Frames.RobuxStore
	DESCRIPTION: Plays a sound when this frame becomes visible.
--]]

local frame = script.Parent
local storeSound: Sound? = frame:WaitForChild("StoreSound")

-- Check if the sound object exists and is a sound
if not storeSound or not storeSound:IsA("Sound") then
	warn("Could not find a valid 'StoreSound' object in the frame.")
	return
end

-- This function runs whenever a property of the frame changes
frame:GetPropertyChangedSignal("Visible"):Connect(function()
	-- If the property that changed was "Visible" and it's now true...
	if frame.Visible then
		-- ...play the sound.
		storeSound:Play()
	end
end)