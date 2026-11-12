-- // GAME SERVICES
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")

-- // RP FOLDERS
local RP_Vfx:         Folder = ReplicatedStorage:WaitForChild("VFX")
local RP_Assets:      Folder = ReplicatedStorage:WaitForChild("Assets")
local RP_Others:      Folder = ReplicatedStorage:WaitForChild("Others")
local RP_Network:     Folder = ReplicatedStorage:WaitForChild("Network")
local RP_Services:    Folder = ReplicatedStorage:WaitForChild("Services")
local RP_Managers:    Folder = ReplicatedStorage:WaitForChild("Managers")
local RP_Controllers: Folder = ReplicatedStorage:WaitForChild("Controllers")

-- // SERVERSCRIPTSERVICE FOLDERS
local SS_Controllers: Folder = ServerScriptService:WaitForChild("Controllers")
local SS_Managers:    Folder = ServerScriptService:WaitForChild("Managers")
local SS_Others:      Folder = ServerScriptService:WaitForChild("Others")
local SS_Services:    Folder = ServerScriptService:WaitForChild("Services")

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
		StatesManagerClient = RP_Managers:WaitForChild("StateManagerClient"),
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

	-- // SERVER
	SS_Controllers = {
		self = SS_Controllers,
		CombatController = SS_Controllers:WaitForChild("CombatController"),
	},

	SS_Managers = {
		self = SS_Managers,
		WeaponsManager = SS_Managers:WaitForChild("WeaponsManager"),
	},

	SS_Others = {
		self = SS_Others,
		CombatStateMachine = SS_Others:WaitForChild("CombatStateMachine"),
		WeaponsRegistry = SS_Others:WaitForChild("WeaponsRegistry"),
	},

	SS_Services = {
		self = SS_Services,
		CombatService = SS_Services:WaitForChild("CombatService"),
	},
})
