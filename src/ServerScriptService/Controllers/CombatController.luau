local ServerScriptService = game:GetService("ServerScriptService")

local Path = require(ServerScriptService.Path)
local CombatService = require(Path:Search("SS_Services", "CombatService"))

-- client action -> server state module
local states = {
	m1 = "Attacking",
	parry = "Parrying",
	equip = "Equip",
}

local CombatController = {}

local function canAct(player)
	if not player or not player.Parent then return false end

	local character = player.Character
	if not character then return false end

	if character:GetAttribute("Stunned") then return false end
	if character:GetAttribute("Parrying") then return false end
	if character:GetAttribute("AttackStun") then return false end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

function CombatController:ProcessKey(player: Player, key: string, extra: any)
	if not player or typeof(key) ~= "string" then return end
	if not canAct(player) then return end

	local state = states[key]
	if not state then return end

	CombatService:Process(player, state, extra)
end

return CombatController
