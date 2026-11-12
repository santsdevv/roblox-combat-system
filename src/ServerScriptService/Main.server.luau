local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Auto-load every server module and call Init() if present
local modules = {}
for _, module in script.Parent:GetDescendants() do
	if not module:IsA("ModuleScript") then continue end

	local ok, loaded = pcall(require, module)
	if ok and loaded then
		modules[module.Name] = loaded
		if typeof(loaded) == "table" and loaded.Init then
			pcall(loaded.Init)
		end
	end
end

local network = ReplicatedStorage:WaitForChild("Network"):WaitForChild("CombatSystem")
local sendKey = network:WaitForChild("SendKey")

local CombatController = require(ServerScriptService:WaitForChild("Controllers"):WaitForChild("CombatController"))

sendKey.OnServerEvent:Connect(function(player, action, extra)
	if not player.Parent or typeof(action) ~= "string" then return end

	local kind = typeof(extra)
	if kind ~= "number" and kind ~= "boolean" then
		extra = nil
	end

	CombatController:ProcessKey(player, action, extra)
end)

local function joined(player)
	local manager = modules.PlayersManager.new(player)
	manager:SetupCharacter()
	manager:Start()

	modules.WeaponsManager:Equip(player, "katana")
end

Players.PlayerAdded:Connect(joined)

for _, player in Players:GetPlayers() do
	task.spawn(joined, player)
end
