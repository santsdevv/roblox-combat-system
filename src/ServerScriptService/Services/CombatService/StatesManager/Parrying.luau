local ServerScriptService = game:GetService("ServerScriptService")

local Path = require(ServerScriptService.Path)
local Anims = require(Path:Search("RP_Services", "AnimationService"))

--[[
	Parry timeline:
	  [startup] -> [window: "Parrying" = true] -> [recovery] -> [cooldown]
	Any hit that lands during the window stuns the attacker instead.
]]

local Parrying = {}

local lastParry = setmetatable({}, { __mode = "k" })

function Parrying:Process(model: Model, context: {})
	if not model or not context then return end
	if model:GetAttribute("Stunned") or model:GetAttribute("AttackStun") then return end
	if model:GetAttribute("Parrying") or model:GetAttribute("BlockingRecovery") then return end

	local data = context.WeaponData
	local anims = data and data.Animations
	if not anims then return end

	local startup = data.ParryStartup or 0.12
	local window = data.ParryWindow or 0.22
	local recovery = data.ParryRecovery or 0.35
	local total = startup + window + recovery + (data.BlockCooldown or 1.5)

	local now = os.clock()
	if now - (lastParry[model] or -math.huge) < total - 0.15 then return end
	lastParry[model] = now

	-- Client already played the animation if it predicted the parry
	if context.Client ~= true then
		Anims:Play(model, anims.blockStart, {
			priority = Enum.AnimationPriority.Action2,
			fadeTime = 0.05,
		})
	end

	task.delay(startup, function()
		if not model.Parent then return end

		model:SetAttribute("Parrying", true)
		model:SetAttribute("BlockingRecovery", true)

		task.delay(window, function()
			if not model.Parent then return end

			model:SetAttribute("Parrying", nil)
			model:SetAttribute("BlockingRecovery", false)
		end)
	end)
end

return Parrying
