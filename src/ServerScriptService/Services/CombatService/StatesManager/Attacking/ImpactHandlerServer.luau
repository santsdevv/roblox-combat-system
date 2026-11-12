local ImpactHandlerServer = {}

function ImpactHandlerServer:Ragdoll(character: Model, active: boolean)
	if not character then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	if active then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
	else
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		rootPart.Anchored = true

		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero

		humanoid.PlatformStand = false
		humanoid.AutoRotate = true

		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

		task.defer(function()
			rootPart.Anchored = false
		end)
	end
end

function ImpactHandlerServer:Knockback(character: Model, direction: Vector3, force: number)
	if not character then return end

	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local rootPart: BasePart? = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
	bodyVelocity.Velocity = direction.Unit * force
	bodyVelocity.Parent = rootPart

	game:GetService("Debris"):AddItem(bodyVelocity, 0.15)
end

return ImpactHandlerServer
