--!nocheck

local ServerStateService = {}

local ServerData = {
	ServerClosed    = false,
	Locked          = false,
	PVP             = true,
	Lockdown        = false,
	Disco           = false,
	AmbientDefault  = Color3.fromRGB(255, 255, 255),
	Warps           = {},
	Votes           = {},
}

function ServerStateService:Get()
	return ServerData
end

function ServerStateService:Edit(key, value)
	if ServerData then
		ServerData[key] = value
	end
	return ServerData
end

function ServerStateService:AddWarp(name, x, y, z)
	ServerData.Warps[name:lower()] = { x, y, z }
	return ServerData
end

function ServerStateService:RemoveWarp(name)
	if ServerData.Warps[name:lower()] then
		ServerData.Warps[name:lower()] = nil
	end
	return ServerData
end

function ServerStateService:GetWarp(name)
	if ServerData.Warps and ServerData.Warps[name:lower()] then
		return ServerData.Warps[name:lower()]
	end
	return nil
end

function ServerStateService:GetWarps()
	return ServerData.Warps or {}
end

return ServerStateService
