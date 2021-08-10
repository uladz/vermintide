--[[
	Author: grasmann
	
	This script will add an options seperator into the mod settings
--]]
pcall(function()
	local cache = OptionsInjector.ModSettings.cache
	-- Only add a seperator if the previous widget isn't one already
	if cache[#cache].name ~= "seperator" then
		OptionsInjector.CreateEmptyLine()
	end
end)