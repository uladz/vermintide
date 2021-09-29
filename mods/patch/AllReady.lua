--[[
	Patch all_peers_ready:
		This allows you to start the game without other people have to vote.
--]]

local mod_name = "AllReady"
AllReady = {}
local mod = AllReady

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_all_ready",
		["widget_type"] = "stepper",
		["text"] = "All Ready",
		["tooltip"] =  "All Ready\n" ..
			"Lets you start the game without waiting for other players to be ready.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

mod.get = Application.user_setting

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
Mods.hook.set(mod_name, "MatchmakingManager.all_peers_ready", function(func, ...)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		return true
	else
		return func(...)
	end
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
