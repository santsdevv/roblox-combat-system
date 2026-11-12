local SharedPaths = require(script:WaitForChild("SharedPaths"))

local Path = {}

function Path:Search(folder: string, path: string?)
	if not folder then return end

	local success, result = pcall(function()
		if path then
			return SharedPaths[folder][path]
		else
			return SharedPaths[folder]
		end
	end)

	if not success then warn(result) return end

	return result
end

return Path
