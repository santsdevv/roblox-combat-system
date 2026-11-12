-- // MODULES
local Utilities = require(script.Utilities)

-- // DEPENDENCIES
local Cooldowns = Utilities.Cooldowns

--[[
	Per-player object. Listens to the character's stun attributes and freezes
	movement (WalkSpeed / Jump) while they are active.
]]

local PlayersManager = {}
PlayersManager.__index = PlayersManager

function PlayersManager.new(player: Player)
	if not player or not player.Parent then return end

	local self = setmetatable({}, PlayersManager)

	self.Player = player :: Player
	self.Character = nil :: Model?
	self.Humanoid = nil :: Humanoid?

	self._Connections = {}

	return self
end

function PlayersManager:SetupCharacter()
	self._Connections.CharacterAdded = self.Player.CharacterAdded:Connect(function(character: Model)
		if not character then return end

		self.Character = character
		self.Humanoid = character:WaitForChild("Humanoid")
	end)
end

function PlayersManager:Start()
	local character: Model = self.Character

	if not character then
		self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
		character = self.Character
	end

	table.insert(self._Connections, character:GetAttributeChangedSignal("Stunned"):Connect(function()
		if character:GetAttribute("Stunned") then
			self:_ApplyStun(Cooldowns.Stun)
		end
	end))

	table.insert(self._Connections, character:GetAttributeChangedSignal("AttackStun"):Connect(function()
		if character:GetAttribute("AttackStun") then
			self:_ApplyStun(Cooldowns.Attack)
		end
	end))
end

function PlayersManager:_ApplyStun(duration: number)
	if self._stunTimer then
		task.cancel(self._stunTimer)
	end

	local character: Model? = self.Character
	if not character then return end

	local humanoid: Humanoid? = self.Humanoid
	if not humanoid then return end

	if not self._originalWalkSpeed then
		self._originalWalkSpeed = humanoid.WalkSpeed
		self._originalJumpPower = humanoid.JumpPower
		self._originalJumpHeight = humanoid.JumpHeight
	end

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0

	self._stunTimer = task.delay(duration, function()
		self:_RemoveStun()
	end)
end

function PlayersManager:_RemoveStun()
	self._stunTimer = nil

	local character: Model? = self.Character
	if not character then return end

	local humanoid: Humanoid? = self.Humanoid
	if not humanoid then return end

	humanoid.WalkSpeed = self._originalWalkSpeed or humanoid.WalkSpeed
	humanoid.JumpPower = self._originalJumpPower or humanoid.JumpPower
	humanoid.JumpHeight = self._originalJumpHeight or humanoid.JumpHeight

	self._originalWalkSpeed = nil
	self._originalJumpPower = nil
	self._originalJumpHeight = nil
end

function PlayersManager:Destroy()
	for _, connection in self._Connections do
		connection:Disconnect()
	end
end

return PlayersManager
