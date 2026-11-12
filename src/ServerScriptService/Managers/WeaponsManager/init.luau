local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Manager = require(script.Manager)
local WeaponHandler = require(script.WeaponHandler)
local Registry = require(ServerScriptService.Others.WeaponsRegistry)
local Anims = require(ReplicatedStorage.Services.AnimationService)

local combat = ReplicatedStorage.Assets.CombatSystem.Animations.Combat

local WeaponsManager = {}

-- Pre-load every animation so the first swing doesn't hitch
local function warm(character, ids)
	task.spawn(function()
		local humanoid = character:WaitForChild("Humanoid", 10)
		if not humanoid then return end

		for _, id in ids do
			local track = Anims:LoadAnimation(character, id)
			if track and not track.IsPlaying then
				track:Play(0, 0.001, 0)
				track:Stop(0)
			end
		end
	end)
end

-- Replicate weapon data to the client through character attributes
local function share(character, name)
	local data = Registry:Get(name)
	local anims = data and data.Animations
	if not anims then return end

	local attack = anims.attack or {}
	local list = {}
	while attack["attack_" .. (#list + 1)] do
		table.insert(list, attack["attack_" .. (#list + 1)])
	end

	local parry = (data.ParryStartup or 0.12)
		+ (data.ParryWindow or 0.22)
		+ (data.ParryRecovery or 0.35)
		+ (data.BlockCooldown or 1.5)

	character:SetAttribute("AttackAnims", table.concat(list, ","))
	character:SetAttribute("ParryAnim", anims.blockStart)
	character:SetAttribute("AttackCooldown", data.Cooldown or 1)
	character:SetAttribute("ComboReset", data.ComboCooldown or 2)
	character:SetAttribute("ParryCooldown", parry)

	local ids = table.clone(list)
	for _, id in { anims.blockStart, anims.equip, anims.unnequip, anims.idle } do
		table.insert(ids, id)
	end
	for _, anim in { combat:FindFirstChild("Hit"), combat:FindFirstChild("Parry") } do
		table.insert(ids, anim.AnimationId)
	end

	warm(character, ids)
end

local function setup(player, character, name)
	WeaponHandler:Equip(character, name)
	share(character, name)
	Manager[player.UserId] = name
end

function WeaponsManager:Equip(player: Player, name: string)
	if not player or not player.Parent or not name then return end

	local character = player.Character or player.CharacterAdded:Wait()
	if not character then return end

	setup(player, character, name)

	player.CharacterAdded:Connect(function(newCharacter)
		setup(player, newCharacter, name)
	end)
end

function WeaponsManager:Get(player: Player): string?
	if not player then return end
	return Manager[player.UserId]
end

return WeaponsManager
