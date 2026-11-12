local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Anims = require(ReplicatedStorage.Services.AnimationService)

local player = Players.LocalPlayer

local ClientCombat = {}

local combo = 0
local lastAttack = -math.huge
local lastParry = -math.huge
local current

local stuns = { "Stunned", "Parrying", "OnRagdoll", "AttackStun" }

local function alive(char)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function stunned(char)
	for _, name in stuns do
		if char:GetAttribute(name) then
			return true
		end
	end
	return false
end

local function attacks(char)
	local raw = char:GetAttribute("AttackAnims")
	if typeof(raw) ~= "string" or raw == "" then return end
	return string.split(raw, ",")
end

-- Plays the attack animation locally right away (client-side prediction)
-- and returns the combo index so the server can validate it.
function ClientCombat:Attack()
	local char = player.Character
	if not char or not alive(char) then return false end
	if not char:GetAttribute("WeaponEquipped") or stunned(char) then return false end

	local list = attacks(char)
	if not list then return true end

	local now = os.clock()
	if now - lastAttack < (char:GetAttribute("AttackCooldown") or 0.75) then return false end
	if now - lastAttack > (char:GetAttribute("ComboReset") or 2) then
		combo = 0
	end

	lastAttack = now
	combo = combo % #list + 1

	current = Anims:Play(char, list[combo], {
		priority = Enum.AnimationPriority.Action2,
		fadeTime = 0.05,
	})

	return true, combo
end

function ClientCombat:Parry()
	local char = player.Character
	if not char or not alive(char) then return false end
	if char:GetAttribute("Stunned") or char:GetAttribute("AttackStun") then return false end
	if char:GetAttribute("Parrying") or char:GetAttribute("BlockingRecovery") then return false end

	local id = char:GetAttribute("ParryAnim")
	if typeof(id) ~= "string" then return true end

	local now = os.clock()
	if now - lastParry < (char:GetAttribute("ParryCooldown") or 2.19) then return false end
	lastParry = now

	current = Anims:Play(char, id, {
		priority = Enum.AnimationPriority.Action2,
		fadeTime = 0.05,
	})

	return true, true
end

local function prepare(char)
	combo = 0
	lastAttack = -math.huge
	lastParry = -math.huge
	current = nil

	local humanoid = char:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	local function warm()
		local list = attacks(char) or {}
		local parry = char:GetAttribute("ParryAnim")
		if typeof(parry) == "string" then
			table.insert(list, parry)
		end

		local assets = {}
		for _, id in list do
			local track = Anims:LoadAnimation(char, id)
			if track then
				table.insert(assets, track.Animation)
			end
		end

		if #assets > 0 then
			task.spawn(pcall, ContentProvider.PreloadAsync, ContentProvider, assets)
		end
	end

	local function interrupt()
		if not (char:GetAttribute("AttackStun") or char:GetAttribute("Stunned")) then return end
		if current and current.IsPlaying then
			current:Stop(0.05)
		end
	end

	char:GetAttributeChangedSignal("AttackAnims"):Connect(warm)
	char:GetAttributeChangedSignal("ParryAnim"):Connect(warm)
	char:GetAttributeChangedSignal("AttackStun"):Connect(interrupt)
	char:GetAttributeChangedSignal("Stunned"):Connect(interrupt)

	warm()
end

function ClientCombat.Init()
	if player.Character then
		task.spawn(prepare, player.Character)
	end
	player.CharacterAdded:Connect(prepare)
end

return ClientCombat
