-- // GAME SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // DEPENDENCIES
local welds = ReplicatedStorage.Assets.CombatSystem.Welds.Weapons

local AnimationService = require(ReplicatedStorage:WaitForChild("Services").AnimationService)
local SoundController = require(ReplicatedStorage:WaitForChild("Controllers").SoundController)

-- // MODULE
local Equip = {}

Equip.States = {} --> { [character] = "equipped" | "unequipped" }
Equip.LiveStates = {} --> { [character] = true } while an equip/unequip animation is running
Equip.Welds = {} --> { [character] = Motor6D }
Equip.IdleAnimations = {} --> { [character] = AnimationTrack }

local function Weld(character: Model, weapon: Model | BasePart, typeOfWeld: string): Motor6D?
	if not character or not weapon or not typeOfWeld then return end

	local modelWelds = welds[weapon.Name]
	if not modelWelds then return end

	local currentWeld = Equip.Welds[character] or character:FindFirstChild("WeaponWeld")

	if not currentWeld then
		currentWeld = Instance.new("Motor6D")
		currentWeld.Parent = character
	end

	if typeOfWeld == "Holding" then
		local holdingWeld = modelWelds.HoldingWeld
		if not holdingWeld then return end

		currentWeld.Name = "HoldingWeld"
		currentWeld.Part0 = character["Right Arm"]
		currentWeld.Part1 = weapon.Handler or weapon
		currentWeld.C1 = holdingWeld.C1
		currentWeld.Parent = character

		Equip.Welds[character] = currentWeld
	elseif typeOfWeld == "Idle" then
		local idleWeld = modelWelds.IdleWeld
		if not idleWeld then return end

		currentWeld.Name = "IdleWeld"
		currentWeld.Part0 = character["Torso"]
		currentWeld.Part1 = weapon.Handler or weapon
		currentWeld.C1 = idleWeld.C1
		currentWeld.Parent = character

		Equip.Welds[character] = currentWeld
	end

	return currentWeld
end

function Equip:Process(character: Model, context: {})
	if not character or not context then return end
	if not character.Parent then return end

	if character:GetAttribute("Stunned") then return end
	if character:GetAttribute("AttackStun") then return end

	local weaponId: string = context.WeaponData.Id
	if not weaponId then return end

	local modelWelds = welds[weaponId]
	if not modelWelds then return end

	local weaponModel = character:FindFirstChild(weaponId)
	if not weaponModel then return end

	local currentState = Equip.States[character]

	if currentState == "unequipped" or not currentState then
		if Equip.LiveStates[character] then return end
		Equip.LiveStates[character] = true

		SoundController:Play("weapon_equip", character)

		local equipTrack = AnimationService:Play(character, context.WeaponData.Animations.equip)
		equipTrack:GetMarkerReachedSignal("Equip"):Wait()

		Weld(character, weaponModel, "Holding")

		Equip.States[character] = "equipped"

		local idleTrack = AnimationService:Play(character, context.WeaponData.Animations.idle)
		idleTrack.Priority = Enum.AnimationPriority.Action
		idleTrack.Looped = true
		Equip.IdleAnimations[character] = idleTrack

		character:SetAttribute("WeaponEquipped", true)
		Equip.LiveStates[character] = nil
	elseif currentState == "equipped" then
		if Equip.LiveStates[character] then return end
		Equip.LiveStates[character] = true

		if Equip.IdleAnimations[character] then
			Equip.IdleAnimations[character]:Stop()
		end

		local track = AnimationService:Play(character, context.WeaponData.Animations.unnequip)
		track.Ended:Wait()

		Weld(character, weaponModel, "Idle")

		Equip.States[character] = "unequipped"

		character:SetAttribute("WeaponEquipped", nil)
		Equip.LiveStates[character] = nil
	end
end

return Equip
