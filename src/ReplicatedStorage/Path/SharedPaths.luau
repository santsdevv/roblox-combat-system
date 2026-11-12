-- // GAME SERVICES
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // RP FOLDERS
local RP_Vfx:         Folder = ReplicatedStorage:WaitForChild("VFX")
local RP_Assets:      Folder = ReplicatedStorage:WaitForChild("Assets")
local RP_Others:      Folder = ReplicatedStorage:WaitForChild("Others")
local RP_Network:     Folder = ReplicatedStorage:WaitForChild("Network")
local RP_Services:    Folder = ReplicatedStorage:WaitForChild("Services")
local RP_Managers:    Folder = ReplicatedStorage:WaitForChild("Managers")
local RP_Controllers: Folder = ReplicatedStorage:WaitForChild("Controllers")

-- // PATHS
return table.freeze({
	RP_Vfx = {
		self = RP_Vfx,
		CombatSystem = RP_Vfx:WaitForChild("CombatSystem"),
	},

	RP_Assets = {
		self = RP_Assets,
		CombatSystem = RP_Assets:WaitForChild("CombatSystem"),
	},

	RP_Network = {
		self = RP_Network,
		CombatSystem = RP_Network:WaitForChild("CombatSystem"),
	},

	RP_Others = {
		self = RP_Others,
		InputHandler = RP_Others:WaitForChild("InputHandler"),
	},

	RP_Managers = {
		self = RP_Managers,
		StateManagerClient = RP_Managers:WaitForChild("StateManagerClient"),
	},

	RP_Controllers = {
		self = RP_Controllers,
		VFXController = RP_Controllers:WaitForChild("VFXController"),
		SoundController = RP_Controllers:WaitForChild("SoundController"),
	},

	RP_Services = {
		self = RP_Services,
		AnimationService = RP_Services:WaitForChild("AnimationService"),
	},
})
