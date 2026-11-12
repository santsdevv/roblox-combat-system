return {
	Cooldowns = {
		AttackStun = 0.9,
		ParryStun = 2,
		OnRagdoll = 0.5,
	},

	Functions = {
		GetAttribute = function(model: Model, attribute: string): any
			return model:GetAttribute(attribute)
		end,

		SetAttribute = function(instance: Instance, name, value)
			if not instance or not name then return end

			instance:SetAttribute(name, value)
		end,

		SetAttackStun = function(array)
			local model = array.model
			if not model then return end

			model:SetAttribute("AttackStun", array.value)
		end,

		GetHumanoid = function(model: Model): Humanoid?
			return model:FindFirstChildOfClass("Humanoid")
		end,

		ValidateHumanoid = function(model: Model): boolean?
			if not model then return end

			local humanoid: Humanoid? = model:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			return true
		end,

		GetCharacter = function(instance: BasePart?): Model?
			if not instance then return end

			return instance:FindFirstAncestorOfClass("Model")
		end,

		GetChildrenByName = function(parent: Instance, name: string): Instance?
			if not parent or not name then return end

			return parent:FindFirstChild(name)
		end,
	},
}
