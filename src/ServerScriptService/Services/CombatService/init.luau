local ServerScriptService = game:GetService("ServerScriptService")

local Path = require(ServerScriptService.Path)
local StatesManager = require(script.StatesManager)
local WeaponsManager = require(Path:Search("SS_Managers", "WeaponsManager"))
local Registry = require(Path:Search("SS_Others", "WeaponsRegistry"))

local CombatService = {}

function CombatService:Process(player: Player, state: string, extra: any)
	if not player or not player.Parent or typeof(state) ~= "string" then return end

	local weapon = WeaponsManager:Get(player)
	if not weapon then return end

	local data = Registry:Get(weapon)
	if not data then return end

	local character = player.Character
	if not character then return end

	StatesManager:ProcessState(character, state, {
		Weapon = weapon,
		WeaponData = data,
		Client = extra,
	})
end

return CombatService
