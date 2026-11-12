-- // MODULES
local Weapons = require(script.Weapons)

local WeaponsRegistry = {}

function WeaponsRegistry:Get(name: string)
	if typeof(name) ~= "string" then return end

	return Weapons[name]
end

return WeaponsRegistry
