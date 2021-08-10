local mod_name = "NoSkins"

local user_setting = Application.user_setting
local set_user_setting = Application.set_user_setting

local MOD_SETTINGS = {
	SALTZPYRE = {
		["save"] = "cb_noskin_saltzpyre",
		["widget_type"] = "stepper",
		["text"] = "Disable Saltzpyre Skin",
		["tooltip"] = "Disable Saltzpyre Skin\n" ..
				"Disables the DLC skin for Saltzpyre, if you have it.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
	KERILLIAN = {
		["save"] = "cb_noskin_kerillian",
		["widget_type"] = "stepper",
		["text"] = "Disable Kerillian Skin",
		["tooltip"] = "Disable Kerillian Skin\n" ..
				"Disables the DLC skin for Kerillian, if you have it.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
	BARDIN = {
		["save"] = "cb_noskin_bardin",
		["widget_type"] = "stepper",
		["text"] = "Disable Bardin Skin",
		["tooltip"] = "Disable Bardin Skin\n" ..
				"Disables the DLC skin for Bardin, if you have it.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
	SIENNA = {
		["save"] = "cb_noskin_sienna",
		["widget_type"] = "stepper",
		["text"] = "Disable Sienna Skin",
		["tooltip"] = "Disable Sienna Skin\n" ..
				"Disables the DLC skin for Sienna, if you have it.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
	KRUBER = {
		["save"] = "cb_noskin_kruber",
		["widget_type"] = "stepper",
		["text"] = "Disable Kruber Skin",
		["tooltip"] = "Disable Kruber Skin\n" ..
				"Disables the DLC skin for Kruber, if you have it.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
}


local profile_dlc_skins = {}
Mods.hook.set(mod_name, "UnlockManager.get_skin_settings", function(func, self, profile_name)
	if (profile_name == "witch_hunter" and user_setting(MOD_SETTINGS.SALTZPYRE.save)) or
	(profile_name == "wood_elf" and user_setting(MOD_SETTINGS.KERILLIAN.save)) or
	(profile_name == "dwarf_ranger" and user_setting(MOD_SETTINGS.BARDIN.save)) or
	(profile_name == "bright_wizard" and user_setting(MOD_SETTINGS.SIENNA.save)) or
	(profile_name == "empire_soldier" and user_setting(MOD_SETTINGS.KRUBER.save)) then
		local base_skin = nil

		table.clear(profile_dlc_skins)

		for _, skin_settings in pairs(SkinSettings) do
			local skin_profile_name = skin_settings.profile_name

			if skin_profile_name == profile_name then
				local unlock_type = skin_settings.unlock_type

				if unlock_type == "default" then
					base_skin = skin_settings
				end
			end
		end

		return base_skin
	else
		return func(self, profile_name)
	end
end)

local function create_options()
	Mods.option_menu:add_group("noskin", "DLC Skin Disabler")

	Mods.option_menu:add_item("noskin", MOD_SETTINGS.SALTZPYRE, true)
	Mods.option_menu:add_item("noskin", MOD_SETTINGS.KERILLIAN, true)
	Mods.option_menu:add_item("noskin", MOD_SETTINGS.BARDIN, true)
	Mods.option_menu:add_item("noskin", MOD_SETTINGS.SIENNA, true)
	Mods.option_menu:add_item("noskin", MOD_SETTINGS.KRUBER, true)
end
 
local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end