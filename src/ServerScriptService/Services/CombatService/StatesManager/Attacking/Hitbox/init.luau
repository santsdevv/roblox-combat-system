local Cast = require(script.Cast)

local Hitbox = {}
Hitbox.__index = Hitbox

function Hitbox.new(weapon: Instance, track: AnimationTrack, config: {})
	if not weapon or not track then return end

	return setmetatable({
		Weapon = weapon,
		AnimationTrack = track,
		Config = config,
	}, Hitbox)
end

function Hitbox:CreateHitbox()
	local cast = Cast.new(self)
	if cast then
		cast:Start()
	end
	return cast
end

return Hitbox
