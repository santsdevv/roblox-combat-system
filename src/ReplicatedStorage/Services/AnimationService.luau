local AnimationService = {}
AnimationService.__index = AnimationService

AnimationService.Tracks = {}

local function getAnimator(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return animator
end

function AnimationService:LoadAnimation(character: Model, id: string): AnimationTrack?
	if not character or not id then return end

	local cache = self.Tracks[character]
	if cache and cache[id] then
		return cache[id]
	end

	local animator = getAnimator(character)
	if not animator then return end

	local anim = Instance.new("Animation")
	anim.AnimationId = id

	local track = animator:LoadAnimation(anim)

	if not cache then
		cache = {}
		self.Tracks[character] = cache
		character.Destroying:Once(function()
			self.Tracks[character] = nil
		end)
	end

	cache[id] = track
	return track
end

function AnimationService:Play(character: Model, id: string, config: {}?): AnimationTrack?
	local track = self:LoadAnimation(character, id)
	if not track then return end

	config = config or {}

	track.Priority = config.priority or Enum.AnimationPriority.Action
	track.Looped = config.looped or false
	track:Play(config.fadeTime or 0.1, config.weight or 1, config.speed or 1)

	return track
end

function AnimationService:Stop(character: Model, id: string, fadeTime: number?)
	local cache = self.Tracks[character]
	if not cache then return end

	local track = cache[id]
	if track and track.IsPlaying then
		track:Stop(fadeTime or 0.1)
	end
end

function AnimationService:StopAll(character: Model)
	local cache = self.Tracks[character]
	if not cache then return end

	for _, track in cache do
		if track.IsPlaying then
			track:Stop()
		end
	end
end

function AnimationService:ClearCharacter(character: Model)
	self:StopAll(character)
	self.Tracks[character] = nil
end

function AnimationService:Destroy()
	for character in self.Tracks do
		self:ClearCharacter(character)
	end
	table.clear(self.Tracks)
end

return AnimationService
