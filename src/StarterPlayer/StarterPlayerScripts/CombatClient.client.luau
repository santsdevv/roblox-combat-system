-- // GAME SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // MODULES
local Path = require(ReplicatedStorage.Path)
local VFXController = require(Path:Search("RP_Controllers", "VFXController"))

-- // NETWORK
local CombatSystem = Path:Search("RP_Network", "CombatSystem")

-- // MEMBERS
local Others: Folder = Path:Search("RP_Others", "self")

-- Auto-load every module inside ReplicatedStorage.Others and call Init() if present
local modules = {}
for _, module in Others:GetDescendants() do
	if not module:IsA("ModuleScript") then continue end

	local ok, required = pcall(require, module)
	if ok and required then
		modules[module.Name] = required
		if typeof(required) == "table" and required.Init then
			pcall(required.Init, required)
		end
	end
end

CombatSystem.Client.WeaponHandler.OnClientEvent:Connect(function(tool, enabled)
	local inputHandler = modules.InputHandler
	if enabled then
		inputHandler:SetAvailable(tool)
	else
		inputHandler:SetAvailable()
	end
end)

CombatSystem.Client.VFXEvent.OnClientEvent:Connect(function(folder, parent)
	if not folder or not parent then return end

	VFXController:Emit(folder, parent)
end)
