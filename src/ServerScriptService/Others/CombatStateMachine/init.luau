-- // DEPENDENCIES
local Config = require(script.Config)

local CombatStateMachine = {}
CombatStateMachine.States = {} :: Config.State

local AllowedTransitions: Config.Transitions = {
	Dead = {},
	Null = { "Idle" },
	Idle = { "Attacking", "Blocking", "Stunned", "Dead" },
	Stunned = { "Idle", "Dead" },
	Blocking = { "Idle", "Stunned", "Dead" },
	Attacking = { "Idle", "Stunned", "Dead" },
}

function CombatStateMachine:GetState(player: Player): string?
	if not player then return nil end
	return self.States[player.UserId] or "Null"
end

function CombatStateMachine:CanTransition(player: Player, transition: string): boolean
	if not player or typeof(transition) ~= "string" then return false end

	local currentState = self:GetState(player) or "Null"
	local allowed = AllowedTransitions[currentState]
	if not allowed then return true end

	for _, state in ipairs(allowed) do
		if state == transition then
			return true
		end
	end

	-- TODO: return false here once every state handler resets back to "Idle".
	-- Right now the transition table is informative only; validation is done
	-- through character attributes (Stunned, AttackStun, Parrying...).
	return true
end

function CombatStateMachine:SetState(player: Player, newState: string): boolean
	if not player or not newState then return false end

	if not self:CanTransition(player, newState) then
		return false
	end

	self.States[player.UserId] = newState

	return true
end

return CombatStateMachine
