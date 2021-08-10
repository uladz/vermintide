local WARNING = {
	["save"] = "cb_weapon_model_warning",
	["widget_type"] = "stepper",
	["text"] = "Load Change Weapon Models Mod",
	["tooltip"] = "Load Change Weapon Models Mod\n" ..
			"Because of its potentially unstable nature, and also due to the stress it puts on the Mod Settings menu, " ..
			"the Change Weapon Model mod is not loaded by default, unless this option is enabled.\n\n" ..
			"While using this mod, any changes to the model of a currently equipped weapon can cause you to crash " ..
			"if the inventory is used without reequipping the weapon, and the mod settings menu may take longer to load.\n\n" ..
			"Changes to this option will require you to use the /reload command or restart your game for them to apply.",
	["value_type"] = "boolean",
	["options"] = {
		{text = "Off", value = false},
		{text = "On", value = true},
	},
	["default"] = 1, -- Default first option is enabled. In this case Off
}

local function create_options()
	Mods.option_menu:add_group("weapon_model", "Change Weapon Models")

	Mods.option_menu:add_item("weapon_model", WARNING, true)
end
 
local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end