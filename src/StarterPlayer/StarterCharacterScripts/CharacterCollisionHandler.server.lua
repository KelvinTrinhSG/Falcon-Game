--!strict
local character = script.Parent
task.wait()
for _, descendant in ipairs(character:GetDescendants()) do
	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = "Players"
	end
end