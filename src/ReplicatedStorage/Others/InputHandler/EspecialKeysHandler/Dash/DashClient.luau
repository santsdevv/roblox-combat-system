-- // GAME SERVICES
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- // MODULES
local Path = require(ReplicatedStorage.Path)
local AnimationService = require(Path:Search("RP_Services", "AnimationService"))
local StatesManagerClient = require(Path:Search("RP_Managers", "StateManagerClient"))

-- // ANIMATIONS
local Assets_CombatSystem: Folder = Path:Search("RP_Assets", "CombatSystem")

-- // MEMBERS
local camera = workspace.CurrentCamera

local DashClient = {}

local DASH_SPEED = 20
local DASH_DURATION = 1
local DASH_COOLDOWN = 1.0
local DASH_RECOVERY = 0.15

local _cooldownEnd = 0
local _activeDash = nil
local _currentAnimation = nil

local direction_animations = {
	W = Assets_CombatSystem.Animations.Dash.DashFront,
	S = Assets_CombatSystem.Animations.Dash.DashBack,
	A = Assets_CombatSystem.Animations.Dash.DashLeft,
	D = Assets_CombatSystem.Animations.Dash.DashRight,
}

local function ShiftLockActive(): boolean
	return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

local function GetCameraDirection(): Vector3
	local cameraLook = camera.CFrame.LookVector
	return Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
end

local function GetAnimationKey(lastKey: string?, dashDirection: Vector3, rootPart: BasePart): string
	if ShiftLockActive() and direction_animations[lastKey] ~= nil then
		return lastKey
	end

	local relative = rootPart.CFrame:VectorToObjectSpace(dashDirection)
	local x, z = relative.X, relative.Z

	if math.abs(x) > math.abs(z) then
		return x > 0 and "D" or "A"
	end

	return z > 0 and "S" or "W"
end

function DashClient:IsCooldownReady(): boolean
	return tick() >= _cooldownEnd
end

function DashClient:Apply(character: Model, direction: Vector3?, lastKey: string?)
	if not character then return end

	local humanoid: Humanoid? = character:FindFirstChildOfClass("Humanoid")
	local rootPart: BasePart? = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end

	StatesManagerClient:SetState("Dash")

	local dashDirection: Vector3
	if direction and direction.Magnitude > 0.1 then
		dashDirection = direction.Unit
	else
		dashDirection = GetCameraDirection()
	end

	local animKey = GetAnimationKey(lastKey, dashDirection, rootPart)
	local animationData = direction_animations[animKey] or direction_animations.W
	local animation = animationData.AnimationId

	local track: AnimationTrack = AnimationService:Play(character, animation)
	track.Priority = Enum.AnimationPriority.Action2
	if track.Length > 0 then
		track:AdjustSpeed(track.Length / DASH_DURATION)
	end
	track:GetMarkerReachedSignal("DashStart"):Wait()

	local originalWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = DASH_SPEED

	humanoid:MoveTo(rootPart.Position + dashDirection * 50)

	local startTime = tick()
	_activeDash = {
		Character = character,
		Humanoid = humanoid,
		OriginalWalkSpeed = originalWalkSpeed,
		Direction = dashDirection,
		StartTime = startTime,
		EndTime = startTime + DASH_DURATION,
		RecoveryEnd = startTime + DASH_DURATION + DASH_RECOVERY,
		Connection = nil,
	}

	_activeDash.Connection = RunService.Heartbeat:Connect(function()
		self:_Update()
	end)

	_currentAnimation = track
	_cooldownEnd = startTime + DASH_COOLDOWN
end

function DashClient:_Update()
	if not _activeDash then return end

	local now = tick()
	local elapsed = now - _activeDash.StartTime
	local t = math.clamp(elapsed / DASH_DURATION, 0, 1)

	if _activeDash.Humanoid then
		local startSpeed = DASH_SPEED
		local endSpeed = _activeDash.OriginalWalkSpeed
		_activeDash.Humanoid.WalkSpeed = startSpeed + (endSpeed - startSpeed) * t
	end

	if now >= _activeDash.EndTime then
		if _activeDash.Humanoid then
			_activeDash.Humanoid.WalkSpeed = _activeDash.OriginalWalkSpeed
		end

		if _currentAnimation then
			_currentAnimation:Stop(0.15)
			_currentAnimation = nil
		end
	end

	if now >= _activeDash.RecoveryEnd then
		self:_Cleanup()
		StatesManagerClient:SetState("Idle")
	end
end

function DashClient:_Cleanup()
	if not _activeDash then return end

	if _activeDash.Connection then
		_activeDash.Connection:Disconnect()
	end

	if _activeDash.Humanoid then
		_activeDash.Humanoid.WalkSpeed = _activeDash.OriginalWalkSpeed
	end

	_activeDash = nil
end

function DashClient:ForceCancel()
	self:_Cleanup()
	StatesManagerClient:SetState("Idle")
end

return DashClient
