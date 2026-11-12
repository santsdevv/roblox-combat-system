local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Path = require(ServerScriptService.Path)
local Utils = require(script.Utilities)
local Impact = require(script.ImpactHandlerServer)
local Hitbox = require(script.Hitbox)
local Sound = require(Path:Search("RP_Controllers", "SoundController"))
local Anims = require(Path:Search("RP_Services", "AnimationService"))

local assets = Path:Search("RP_Assets", "CombatSystem")
local network = Path:Search("RP_Network", "CombatSystem")
local vfx = Path:Search("RP_Vfx", "CombatSystem")
local vfxEvent = network.Client.VFXEvent

local hitAnim = assets.Animations.Combat.Hit.AnimationId
local parryAnim = assets.Animations.Combat.Parry.AnimationId

local tools = Utils.Functions
local timers = Utils.Cooldowns
local weak = { __mode = "k" }
local blocked = { "Stunned", "Parrying", "OnRagdoll", "AttackStun" }

local Attacking = {}
Attacking.__index = Attacking

Attacking.cooldown = setmetatable({}, weak)
Attacking.combo = setmetatable({}, weak)
Attacking.lastHit = setmetatable({}, weak)
Attacking.attackStunned = setmetatable({}, weak)

-- Attacker got parried: play parry reaction and stun them
local function parried(model)
	Anims:Play(model, parryAnim, {
		priority = Enum.AnimationPriority.Action3,
		fadeTime = 0.05,
	})

	Sound:Play("parry", model, true)

	local torso = model:FindFirstChild("Torso")
	if torso then
		vfxEvent:FireAllClients(vfx.Impact, torso.Position)
	end

	tools.SetAttribute(model, "Stunned", true)
	task.delay(timers.ParryStun, tools.SetAttribute, model, "Stunned", nil)
end

-- Token-based stun so overlapping hits extend instead of cutting each other short
local function stun(target)
	local token = (Attacking.attackStunned[target] or 0) + 1
	Attacking.attackStunned[target] = token

	tools.SetAttribute(target, "AttackStun", true)

	task.delay(timers.AttackStun, function()
		if Attacking.attackStunned[target] ~= token then return end

		Attacking.attackStunned[target] = nil
		tools.SetAttribute(target, "AttackStun", nil)
	end)
end

local function landHit(character, target, damage, finisher)
	if not tools.ValidateHumanoid(character) or not tools.ValidateHumanoid(target) then return end

	local torso = target:FindFirstChild("Torso")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not torso or not root then return end

	vfxEvent:FireAllClients(vfx.HitBlood, torso)
	Anims:Play(target, hitAnim, {
		priority = Enum.AnimationPriority.Action3,
		fadeTime = 0.05,
	})
	Sound:Play("successful_hit", torso, true)

	stun(target)

	local humanoid = tools.GetHumanoid(target)
	if not humanoid then return end

	local push = root.CFrame.LookVector

	if finisher then
		tools.SetAttribute(target, "OnRagdoll", true)
		Impact:Knockback(target, push, 20)
		task.delay(timers.OnRagdoll, tools.SetAttribute, target, "OnRagdoll", nil)
	else
		Impact:Knockback(target, push, 4)
	end

	humanoid:TakeDamage(damage or 15)
end

function Attacking._OnHit(character: Model, instance: Instance, damage: number, finisher: boolean)
	if not instance then return end

	local target = tools.GetCharacter(instance)
	if not target or not tools.ValidateHumanoid(character) then return end
	if tools.GetAttribute(character, "AttackStun") then return end

	if tools.GetAttribute(target, "Parrying") then
		parried(character)
		return
	end

	landHit(character, target, damage, finisher)
end

local function attackList(data)
	local attack = data.Animations and data.Animations.attack
	if not attack then return end

	local list = {}
	while attack["attack_" .. (#list + 1)] do
		table.insert(list, attack["attack_" .. (#list + 1)])
	end

	return list
end

-- Accepts the client's predicted combo index only if it is plausible
local function pickCombo(model, total, asked, now, reset)
	local following = (Attacking.combo[model] or 0) % total + 1
	local expired = now - (Attacking.lastHit[model] or -math.huge) > reset
	local expected = expired and 1 or following

	if typeof(asked) == "number" and (asked == 1 or asked == expected or asked == following) then
		return asked
	end

	return expected
end

function Attacking:Process(model: Model, context: {})
	if not model or not context then return end
	if not tools.GetAttribute(model, "WeaponEquipped") then return end

	for _, name in blocked do
		if tools.GetAttribute(model, name) then return end
	end

	if not tools.ValidateHumanoid(model) then return end

	local data = context.WeaponData
	if not data or typeof(context.Weapon) ~= "string" then return end

	local weapon = model:FindFirstChild(context.Weapon)
	if not weapon then return end

	local blade = weapon:FindFirstChild("Handler") or weapon

	local list = attackList(data)
	if not list or #list == 0 then return end

	local now = os.clock()
	if now - (Attacking.cooldown[model] or -math.huge) < (data.Cooldown or 1) - 0.15 then return end

	local predicted = typeof(context.Client) == "number"
	local combo = pickCombo(model, #list, context.Client, now, data.ComboCooldown or 2)

	Attacking.cooldown[model] = now
	Attacking.lastHit[model] = now
	Attacking.combo[model] = combo

	-- If the client already played the animation, the server track runs almost
	-- invisibly (weight 0.001) just to drive the hitbox markers.
	local track = Anims:Play(model, list[combo], {
		priority = Enum.AnimationPriority.Action2,
		fadeTime = 0.05,
		weight = predicted and 0.001 or 1,
	})
	if not track then return end

	-- Compensate half of the player's ping so the hitbox lines up with what they saw
	local player = predicted and Players:GetPlayerFromCharacter(model)
	if player then
		local ok, ping = pcall(player.GetNetworkPing, player)
		if ok and ping > 0 then
			track.TimePosition = math.min(ping / 2, 0.12)
		end
	end

	Sound:Play("slash", model, true)

	local damage = data.Damage
	local finisher = combo == #list

	local box = Hitbox.new(blade, track, {
		Model = model,
		Tool = blade,
		Damage = damage,
		OnHit = function(character, instance)
			Attacking._OnHit(character, instance, damage, finisher)
		end,
	})

	if box then
		box:CreateHitbox()
	end
end

return Attacking
