--!strict

local Extensions = require(script:WaitForChild("Extensions"))

local Bootstrap = {}

local isRunning: boolean = false
local controllers: {[string]: any} = {}

function Bootstrap(container: Instance)
	if isRunning then
		error("[Bootstrap] Already initialized!")
	end
	isRunning = true

	-- Load controllers
	for _, module: Instance in container:GetDescendants() do
		if module:IsA("ModuleScript") and module.Name:match("Controller$") then
			local controllerName: string = module.Name
			local success, requiredModule = pcall(require, module)
			if success then
				setmetatable(requiredModule, Extensions.Controller)
				requiredModule._bs_name = controllerName
				controllers[controllerName] = requiredModule
			end
		end
	end

	-- This block fixes the race condition by setting up instances first.
	local playerController = controllers.PlayerController
	if playerController and playerController.SetupSharedInstances then
		playerController:SetupSharedInstances()
	else
		warn("[Bootstrap] Could not find PlayerController to set up shared instances!")
	end

	-- Initialize controllers
	for _, controller in controllers do
		if controller.Init then
			controller:Init(controllers)
		end
	end

	-- Start controllers
	for _, controller in controllers do
		if controller.Start then
			task.spawn(function()
				pcall(controller.Start, controller, controllers)
			end)
		end
	end
end

return Bootstrap