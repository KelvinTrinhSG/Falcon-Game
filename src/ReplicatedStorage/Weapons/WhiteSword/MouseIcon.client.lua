--Made by Luckymaxer (Modified)

local Mouse_Icon = "rbxasset://textures/GunCursor.png"
local Tool = script.Parent

local Mouse = nil

local function OnEquipped(ToolMouse)
	Mouse = ToolMouse
	if Mouse then
		Mouse.Icon = Mouse_Icon
	end
end

local function OnUnequipped()
	if Mouse then
		Mouse.Icon = "" -- Resets the cursor to the default arrow
	end
	Mouse = nil
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)