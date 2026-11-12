local VFXController = {}

local function Attachment(particle, position)
	if not particle or not position then return end

	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	attachment.WorldPosition = position
	particle.Parent = attachment

	return attachment
end

function VFXController:Emit(particles_folder: Folder, position: Vector3 | Instance)
	if not particles_folder or not position then return end

	local particles = particles_folder:GetChildren()
	if #particles == 0 then return end

	for _, particle: ParticleEmitter in particles do
		local cloned_particle = particle:Clone()
		if typeof(position) == "Vector3" then
			Attachment(cloned_particle, position)
		else
			cloned_particle.Parent = position
		end

		cloned_particle:Emit(cloned_particle:GetAttribute("EmitCount"))

		task.delay(cloned_particle.Lifetime.Max, function()
			cloned_particle:Destroy()
		end)
	end
end

return VFXController
