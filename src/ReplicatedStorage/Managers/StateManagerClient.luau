local StateManagerClient = {}

local _currentState = "Idle"

function StateManagerClient:GetState(): string
	return _currentState
end

function StateManagerClient:SetState(state: string)
	_currentState = state
end

return StateManagerClient
