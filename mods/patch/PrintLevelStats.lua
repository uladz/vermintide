--[[
	Name: Print Level Stats
	Author: uladz
	Version: 1.0.0 (10/10/2021)

	Prints out spawned items statistics at the beginning of each map so you know what to expect.
	This is client-only mod, does not affect other players.

	This mod is intended to work with QoL modpack. To "install" copy the file to
	"<game>\binaries\mods\patch" folder. To enable go to "Options" -> "Mod Settings" ->
	"Gameplay Info" and turn on "Print Level Stats" option.

	Version history:
	1.0.0 Initial release.
--]]

local mod_name = "PrintLevelStats"
PrintLevelStats = {}
local mod = PrintLevelStats

--[[
  Variables
--]]

mod.widget_settings = {
	ENABLE = {
		["save"] = "cb_print_level_stats",
		["widget_type"] = "stepper",
		["text"] = "Print Level Stats",
		["tooltip"] = "Print Level Stats\n" ..
			"Prints out spawned items statistics at the beginning of each map so you know what to expect.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
}

mod.pickup_count = {}

--[[
  Options
]]--

mod.create_options = function()
	local group = "info_group"
	Mods.option_menu:add_group(group, "Gameplay Info")
	Mods.option_menu:add_item(group, mod.widget_settings.ENABLE, true)
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

Mods.hook.set(mod_name, "PickupSystem.on_add_extension", function (func, self, world, unit, extension_name, extension_init_data, ...)
	-- collect pickups spawning stats
	if mod.get(mod.widget_settings.ENABLE) then
		local pickup_name = extension_init_data.pickup_name
		if pickup_name then
			mod.pickup_count[pickup_name] = (mod.pickup_count[pickup_name] or 0) + 1
		end
	end

	return func(self, world, unit, extension_name, extension_init_data, ...)
end)

Mods.hook.set(mod_name, "PickupSystem.populate_pickups", function (func, self, checkpoint_data)
	mod.pickup_count = {} -- reset stats
	func(self, checkpoint_data)

	-- print pickups spawning stats
	if mod.get(mod.widget_settings.ENABLE) then
		EchoConsole("Level pickup stats:")
		local total = 0
		for pickup_name, count in pairs(mod.pickup_count) do
			EchoConsole(pickup_name .. " = " .. count)
			total = total + count
		end
		EchoConsole("total count = " .. total)
	end
end)

--[[
	Start
--]]

mod.create_options()
