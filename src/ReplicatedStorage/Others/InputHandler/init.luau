local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Path = require(ReplicatedStorage.Path)
local SpecialKeys = require(script.EspecialKeysHandler)
local ClientCombat = require(script.Parent.ClientCombat)

local network = Path:Search("RP_Network", "CombatSystem")
local sendKey = network.SendKey

local InputHandler = {}

local available = false
local currentKey

-- [KeyName] = { Enum, isSpecialKey }
InputHandler.Keys = {
	MouseButton1 = { Enum.UserInputType.MouseButton1, false },
	F = { Enum.KeyCode.F, false },
	Q = { Enum.KeyCode.Q, true },
	One = { Enum.KeyCode.One, false },

	ButtonR2 = { Enum.KeyCode.ButtonR2, false },
	ButtonB = { Enum.KeyCode.ButtonB, false },
	ButtonA = { Enum.KeyCode.ButtonA, true },
	ButtonY = { Enum.KeyCode.ButtonY, false },
	ButtonX = { Enum.KeyCode.ButtonX, false },
	DPadUp = { Enum.KeyCode.DPadUp, false },
}

InputHandler.Types = {
	MouseButton1 = "m1",
	F = "parry",
	One = "equip",

	ButtonR2 = "m1",
	ButtonB = "parry",
	ButtonY = "equip",
	ButtonX = "equip",
	DPadUp = "equip",
}

local function keyName(input)
	local code = input.KeyCode.Name
	if code == "Unknown" or code == "None" then
		return input.UserInputType.Name
	end
	return code
end

function InputHandler:SetAvailable(tool: Tool?)
	available = tool ~= nil
end

function InputHandler.Init()
	UserInputService.InputBegan:Connect(function(input, busy)
		if busy then return end

		local name = keyName(input)
		local key = InputHandler.Keys[name]

		if not key then
			currentKey = name
			return
		end

		if key[2] then
			pcall(function()
				table.insert(SpecialKeys.LastKey, currentKey)
				SpecialKeys:Execute(name)
			end)
			return
		end

		local action = InputHandler.Types[name]
		if not action then return end

		local extra
		if action == "m1" then
			local ok, combo = ClientCombat:Attack()
			if not ok then return end
			extra = combo
		elseif action == "parry" then
			local ok, played = ClientCombat:Parry()
			if not ok then return end
			extra = played
		end

		sendKey:FireServer(action, extra)
	end)

	UserInputService.InputEnded:Connect(function(input, busy)
		if busy then return end

		local name = keyName(input)
		if InputHandler.Keys[name] then return end

		pcall(function()
			table.remove(SpecialKeys.LastKey, table.find(SpecialKeys.LastKey, name))
		end)
	end)
end

return InputHandler
