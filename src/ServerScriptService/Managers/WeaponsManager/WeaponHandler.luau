-- // GAME SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // DEPENDENCIES
local Assets: Folder = ReplicatedStorage.Assets.CombatSystem
local Weapons: Folder = Assets.Weapons
local Welds: Folder = Assets.Welds.Weapons

local WeaponHandler = {}

-- Clones the weapon onto the character's back (idle/sheathed position)
function WeaponHandler:Equip(character: Model, weaponName: string)
	if not weaponName then return end

	local weaponModel = Weapons:FindFirstChild(weaponName)
	if not weaponModel then return end

	local weaponWelds = Welds:FindFirstChild(weaponName)
	if not weaponWelds then return end

	-- TODO: sheathe logic
	local weaponClone = weaponModel:Clone()
	local idleWeld = weaponWelds.IdleWeld:Clone()

	idleWeld.Name = "WeaponWeld"
	idleWeld.Part0 = character["Torso"]
	idleWeld.Part1 = weaponClone.Handler or weaponClone
	idleWeld.Parent = character

	weaponClone.Parent = character
end

return WeaponHandler
