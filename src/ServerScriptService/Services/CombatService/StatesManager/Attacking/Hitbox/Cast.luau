-- // GAME SERVICES
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--[[
	Blade hitbox driven by animation markers.

	Between the "HitStart" and "HitEnded" markers, every Heartbeat it spherecasts
	along the blade (StartAttachment -> EndAttachment) and also across the swept
	area between the previous and current frame, so fast swings don't tunnel
	through targets.
]]

local Cast = {}
Cast.__index = Cast

function Cast.new(box)
	if not box then return end

	local self = setmetatable({}, Cast)

	self.running = false
	self.HitboxObject = box
	self._connection = nil
	self._markers = {}
	self.Duration = box.Config and box.Config.Duration or 1
	self.HitRadius = box.Config and box.Config.HitRadius or 0.5
	self.hit = {}

	return self
end

local function getPoints(weapon)
	if not weapon or not weapon.Parent then return end

	local folder = weapon:FindFirstChild("HitAttachments")
	if not folder then return end

	local from = folder:FindFirstChild("StartAttachment")
	local to = folder:FindFirstChild("EndAttachment")
	if not from or not to then return end

	return from, to
end

function Cast:_BuildRaycastParams()
	local weapon = self.HitboxObject.Weapon
	local owner = weapon:FindFirstAncestorOfClass("Model")
		and Players:GetPlayerFromCharacter(weapon:FindFirstAncestorOfClass("Model"))
		or Players:GetPlayerFromCharacter(weapon:FindFirstAncestorOfClass("Model").Parent).Character

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { weapon, owner }

	return params
end

function Cast:_CheckMotionBetweenFrames(lastFrom, lastTo, from, to, radius, params)
	local pairsToCheck = {
		{ lastFrom, from },
		{ lastTo, to },
		{ lastFrom, to },
		{ lastTo, from },
	}

	for _, pair in pairsToCheck do
		if #self.hit > 0 then return end

		local dir = pair[2] - pair[1]
		if dir.Magnitude > 0 then
			local result = workspace:Spherecast(pair[1], radius, dir, params)
			if result then
				self:_ProcessRayResult(result)
			end
		end
	end
end

function Cast:Start()
	local box = self.HitboxObject
	local weapon = box.Weapon
	local track = box.AnimationTrack
	if not weapon or not track then return end

	local from, to = getPoints(weapon)
	if not from then return end

	self.running = true

	local radius = self.HitRadius
	local params = self:_BuildRaycastParams()
	local lastFrom, lastTo

	local function scan(dt)
		self.Duration -= dt

		if not self.running or self.Duration <= 0 or not from.Parent then
			self:Stop()
			return
		end

		local a = from.WorldPosition
		local b = to.WorldPosition

		local dir = b - a
		if dir.Magnitude > 0 then
			local result = workspace:Spherecast(a, radius, dir, params)
			if result then
				self:_ProcessRayResult(result)
			end
		end

		if self.running and lastFrom then
			self:_CheckMotionBetweenFrames(lastFrom, lastTo, a, b, radius, params)
		end

		lastFrom, lastTo = a, b
	end

	table.insert(self._markers, track:GetMarkerReachedSignal("HitStart"):Once(function()
		if not self.running or self._connection then return end
		self._connection = RunService.Heartbeat:Connect(scan)
	end))

	table.insert(self._markers, track:GetMarkerReachedSignal("HitEnded"):Once(function()
		self:Stop()
	end))

	local length = track.Length > 0 and track.Length or 2
	task.delay(length + self.Duration, function()
		self:Stop()
	end)

	return true
end

function Cast:Stop()
	self.running = false

	for _, marker in self._markers do
		marker:Disconnect()
	end
	table.clear(self._markers)

	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

function Cast:_ProcessRayResult(result: RaycastResult)
	if not result or #self.hit > 0 then return end

	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if not model or not model:FindFirstChildOfClass("Humanoid") then return end

	table.insert(self.hit, result.Instance)

	local config = self.HitboxObject.Config
	if config and config.OnHit then
		config.OnHit(config.Model, result.Instance, config.Damage)
	end

	self:Stop()
end

return Cast
