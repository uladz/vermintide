--[[
	Development Console Window:
		Pop up a console window with debugging information

	DevConsole v1.0.0
	Author: IamLupo

	Opens a command line window that the game prints some debug information into.
	print() function can be used to display text on the console via lua scripts.
	Go to Mod Settings -> System -> Development Console Window to toggle.
	Off by default.

	Changelog
		1.0.0 - Release
--]]

local mod_name = "DevConsole"
DevConsole = {}
local mod = DevConsole

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_dev_console_window",
		["widget_type"] = "stepper",
		["text"] = "Development Console Window",
		["tooltip"] =  "Development Console Window\n" ..
			"Toggle development console window on / off.\n\n" ..
			"Pop up a console window with debugging information.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

mod.enabled = false

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("system", "System")

	Mods.option_menu:add_item("system", mod.widget_settings.ACTIVE, true)
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "print", function(func, ...)
	if mod.get(mod.widget_settings.ACTIVE) then
		CommandWindow.print(...)
	else
		func(...)
	end
end)

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, ...)
	safe_pcall(function()
		-- Open Command Window
		if mod.get(mod.widget_settings.ACTIVE) == true and mod.enabled == false then
			CommandWindow.open("Development command window")

			mod.enabled = true
		end

		-- Close Command Window
		if mod.get(mod.widget_settings.ACTIVE) == false and mod.enabled == true then
			CommandWindow.close()

			mod.enabled = false
		end
	end)

	func(...)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
