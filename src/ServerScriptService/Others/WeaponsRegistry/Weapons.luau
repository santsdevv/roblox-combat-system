-- // GAME SERVICES
local ServerStorage = game:GetService("ServerStorage")

--[[
	Weapon definitions.

	To add a weapon:
	  1. Add the model to ReplicatedStorage.Assets.CombatSystem.Weapons.<id>
	     (with a "Handler" part and a HitAttachments folder containing
	     StartAttachment / EndAttachment along the blade)
	  2. Add HoldingWeld / IdleWeld Motor6Ds to ReplicatedStorage.Assets.CombatSystem.Welds.Weapons.<id>
	  3. Add an entry below. attack_1..attack_N are played as a combo; the last one is the finisher.
	  Attack animations need "HitStart" and "HitEnded" markers; equip needs an "Equip" marker.
]]

return {
	sword = {
		Id = "sword",
		Damage = 10,

		Animations = {
			idle = "rbxassetid://126709957837483",
			equip = "rbxassetid://127131562414195",
			walk = "rbxassetid://85189463799220",
			attack = {
				attack_1 = "rbxassetid://126978408393833",
				attack_2 = "rbxassetid://132364471266375",
				attack_3 = "rbxassetid://125638363022731",
			},
			blockStart = "rbxassetid://139561130090163",
			blockEnd = "rbxassetid://91204923127333",
		},

		Cooldown = 0.75,
		ComboCooldown = 2,
		BlockCooldown = 1.5,

		Models = ServerStorage.Weapons.katana,
	},

	katana = {
		Id = "katana",
		Damage = 10,

		Animations = {
			idle = "rbxassetid://126709957837483",
			equip = "rbxassetid://116087658529503",
			unnequip = "rbxassetid://122930926587031",
			walk = "rbxassetid://85189463799220",
			attack = {
				attack_1 = "rbxassetid://126978408393833",
				attack_2 = "rbxassetid://132364471266375",
				attack_3 = "rbxassetid://125638363022731",
			},
			blockStart = "rbxassetid://139561130090163",
			blockEnd = "rbxassetid://91204923127333",
		},

		Cooldown = 0.75,
		ComboCooldown = 2,
		BlockCooldown = 1.5,

		-- Optional parry tuning (defaults shown)
		-- ParryStartup = 0.12,
		-- ParryWindow = 0.22,
		-- ParryRecovery = 0.35,

		ModelConfig = {
			Weapon = ServerStorage.Weapons.katana.Weapon,
			Sheathe = ServerStorage.Weapons.katana.Sheathe,
		},
	},
}
