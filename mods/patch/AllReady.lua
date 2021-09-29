--[[
	Name: All Ready
	Author: IamLupo
	Updated: uladz (since 1.1.0)
	Version: 1.1.1 (9/25/2021)
	Link: https://www.nexusmods.com/vermintide/mods/4

	This mod allows you to start the game without having to wait for other people to Ready up (F2).
	Toggle this mod on and off in Mod Settings -> Gameplay Tweaks -> All Ready. Off by default.

	Version history:
		1.0.0 Release.
		1.0.1 Added german language.
		1.1.0 Ported to QoL from VMF, only english.
		1.1.1 Code cleanup, menu option moved to "Gameplay Tweaks" to better fit QoL.
--]]

local mod_name = "AllReady"
AllReady = {}
local mod = AllReady

--[[
  Variables
]]--

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

--[[
  Options
]]--

mod.create_options = function()
	local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVE, true)
end

--[[
  Functions
]]--

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

--[[
  Hooks
]]--

Mods.hook.set(mod_name, "MatchmakingManager.all_peers_ready", function(func, ...)
	if mod.get(mod.widget_settings.ACTIVE) then
		return true
	else
		return func(...)
	end
end)

--[[
  Start
]]--

mod.create_options()
