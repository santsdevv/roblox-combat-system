-- // GAME SERVICES
local PlayersService = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- // MODULES
local Path = require(ServerScriptService.Path)
local CombatStateMachine = require(Path:Search("SS_Others", "CombatStateMachine"))

-- Every child ModuleScript is a state handler (Attacking, Parrying, Equip, ...)
local states = {}
for _, state in script:GetChildren() do
	if not state:IsA("ModuleScript") then continue end

	states[state.Name] = require(state)
end

local StatesManager = {}

function StatesManager:ProcessState(character: Model, state: string, context: { Weapon: string, WeaponData: {} })
	if not character or typeof(state) ~= "string" then return end

	local player: Player? = PlayersService:GetPlayerFromCharacter(character)
	if not player then return end

	local handler = states[state]
	if not handler then return end

	if not CombatStateMachine:SetState(player, state) then return end

	handler:Process(character, context)
end

return StatesManager
