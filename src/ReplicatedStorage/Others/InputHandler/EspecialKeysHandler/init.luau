local modules = {}
for _, module in script:GetChildren() do
	if not module:IsA("ModuleScript") then continue end

	local ok, required = pcall(require, module)
	if ok and required then
		modules[module.Name] = required
	end
end

local EspecialKeysHandler = {}

EspecialKeysHandler.LastKey = {} --> manipulated by InputHandler
EspecialKeysHandler.Types = {
	Q = "Dash",
}

function EspecialKeysHandler:Execute(key)
	if not key then return end

	pcall(function()
		local type = EspecialKeysHandler.Types[key]
		if not type then return end

		local module = modules[type]
		if not module then return end

		module:Process(key, self.LastKey)
	end)
end

return EspecialKeysHandler
