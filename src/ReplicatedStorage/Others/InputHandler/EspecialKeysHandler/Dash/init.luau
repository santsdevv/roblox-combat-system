-- // GAME SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- // MODULES
local Path = require(ReplicatedStorage.Path)
local DashClient = require(script.DashClient)
local StateManagerClient = require(Path:Search("RP_Managers", "StateManagerClient"))

-- // MEMBERS
local player: Player = PlayersService.LocalPlayer

local Dash = {}

function Dash:Process(key, lastKey)
	if not player or not player.Parent then return end

	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	if StateManagerClient:GetState() == "Dash" then return end
	if StateManagerClient:GetState() == "Stunned" then return end
	if not DashClient:IsCooldownReady() then return end

	local heldKey
	for i = #lastKey, 1, -1 do
		if UserInputService:IsKeyDown(Enum.KeyCode[lastKey[i]]) then
			heldKey = lastKey[i]
			break
		end
	end

	local direction = self:GetDashDirection(character)
	DashClient:Apply(character, direction, heldKey)
end

function Dash:GetDashDirection(character: Model): Vector3
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return character:WaitForChild("HumanoidRootPart").CFrame.LookVector end

	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude < 0.1 then
		return character:WaitForChild("HumanoidRootPart").CFrame.LookVector
	end

	return moveDirection.Unit
end

return Dash
