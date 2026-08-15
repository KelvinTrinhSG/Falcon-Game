--!strict
local PhysicsService = game:GetService("PhysicsService")
local PhysicsController = {}
function PhysicsController:Start()
	pcall(PhysicsService.RegisterCollisionGroup, PhysicsService, "Players")
	pcall(PhysicsService.RegisterCollisionGroup, PhysicsService, "Zombies")
	PhysicsService:CollisionGroupSetCollidable("Zombies", "Zombies", false)
	PhysicsService:CollisionGroupSetCollidable("Zombies", "Players", false)
	PhysicsService:CollisionGroupSetCollidable("Players", "Players", false)
	print("Custom collision groups for Players and Zombies have been configured.")
end
return PhysicsController