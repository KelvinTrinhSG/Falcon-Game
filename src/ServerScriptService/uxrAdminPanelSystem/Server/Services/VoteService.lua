--!nocheck

local ServerStateService = require(script.Parent.ServerStateService)

local VoteService = {}

local function getUserIdFromInput(playerInput)
	if typeof(playerInput) == "Instance" and playerInput:IsA("Player") then
		return playerInput.UserId
	elseif typeof(playerInput) == "number" then
		return playerInput
	elseif typeof(playerInput) == "string" and tonumber(playerInput) then
		return tonumber(playerInput)
	end
	return nil
end

function VoteService:Start(name, questions)
	local serverData = ServerStateService:Get()
	serverData.Votes[name] = { questions }
	return serverData
end

function VoteService:GetInfo(voteID)
	return ServerStateService:Get().Votes[voteID]
end

function VoteService:Remove(name)
	local serverData = ServerStateService:Get()
	serverData.Votes[name] = nil
	return serverData
end

function VoteService:AddVoter(voteID, questionIndex, player)
	local userId = getUserIdFromInput(player)
	local serverData = ServerStateService:Get()
	if not userId then return serverData end

	local vote = serverData.Votes and serverData.Votes[voteID]
	if not vote then return serverData end

	if vote[2] and vote[2][userId] then
		return serverData
	end
	if not vote[2] then
		vote[2] = {}
	end
	if not vote[3] then
		local numberOfQuestions = #vote[1]
		vote[3] = {}
		for i = 1, numberOfQuestions do
			vote[3][i] = 0
		end
	end

	vote[2][userId] = true
	if vote[3] and vote[3][questionIndex] then
		vote[3][questionIndex] = vote[3][questionIndex] + 1
	end
	return serverData
end

return VoteService
