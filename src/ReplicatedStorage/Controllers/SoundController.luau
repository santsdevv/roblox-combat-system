-- // GAME SERVICES
local SoundService = game:GetService("SoundService")

-- // MEMBERS
local Sounds = SoundService:WaitForChild("Sounds")
local ActiveSounds = {}

-- // MODULE
local SoundController = {}

function SoundController:Play(soundName: string, parent: Instance?, allowOverlap: boolean?)
	local soundParent = parent or SoundService

	local parentSounds = ActiveSounds[soundParent]
	if not parentSounds then
		parentSounds = {}
		ActiveSounds[soundParent] = parentSounds
	end

	local activeSounds = parentSounds[soundName] or {}

	if not allowOverlap then
		for _, activeSound in activeSounds do
			activeSound:Stop()
			activeSound:Destroy()
		end

		table.clear(activeSounds)
	end

	local template = Sounds:FindFirstChild(soundName, true)
	if not template or not template:IsA("Sound") then return end

	local sound = template:Clone()
	sound.Parent = soundParent

	table.insert(activeSounds, sound)
	parentSounds[soundName] = activeSounds

	sound.Ended:Once(function()
		local currentParentSounds = ActiveSounds[soundParent]
		if not currentParentSounds then return end

		local currentSounds = currentParentSounds[soundName]
		if not currentSounds then return end

		local index = table.find(currentSounds, sound)
		if index then
			table.remove(currentSounds, index)
		end

		if #currentSounds == 0 then
			currentParentSounds[soundName] = nil
		end

		if not next(currentParentSounds) then
			ActiveSounds[soundParent] = nil
		end

		sound:Destroy()
	end)

	sound:Play()

	return sound
end

function SoundController:Stop(soundName: string, parent: Instance?)
	for soundParent, parentSounds in ActiveSounds do
		if parent and soundParent ~= parent then
			continue
		end

		local activeSounds = parentSounds[soundName]
		if not activeSounds then continue end

		for _, sound in activeSounds do
			sound:Stop()
			sound:Destroy()
		end

		parentSounds[soundName] = nil

		if not next(parentSounds) then
			ActiveSounds[soundParent] = nil
		end
	end
end

function SoundController:StopAll()
	for _, parentSounds in ActiveSounds do
		for _, activeSounds in parentSounds do
			for _, sound in activeSounds do
				sound:Stop()
				sound:Destroy()
			end
		end
	end

	table.clear(ActiveSounds)
end

return SoundController
