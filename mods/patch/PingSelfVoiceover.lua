--[[
	Override the "ping self" voiceover:
		This causes a predetermined line of dialogue to play when you ping yourself, instead
		of a random line of "help me" dialogue.

	author: walterr
--]]

local mod_name = "PingSelfVoiceover"
PingSelfVoiceover = {}
local mod = PingSelfVoiceover
local oi = OptionsInjector
 
mod.widget_settings = {
	DISABLED = {
		["save"] = "cb_ping_self_voiceover_off",
		["widget_type"] = "stepper",
		["text"] = "Override Ping Self Voiceover",
		["tooltip"] =  "Override Ping Self Voiceover\n" ..
			"Toggle override of voiceover when pinging self on / off.\n\n" ..
			"Changes your voiceover when you ping yourself to a \"This way\" message (only works" ..
			"if the host has this mod enabled).",
		["value_type"] = "boolean",
		["options"] = {
			{text = Localize("vmf_text_core_off"), value = false},
			{text = Localize("vmf_text_core_on"), value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case On
	},
	HK_TOGGLE = {
		["save"] = "cb_ping_self_hotkey_ping",
		["widget_type"] = "keybind",
		["text"] = "Ping",
		["default"] = {
			"home",
			oi.key_modifiers.NONE,
		},
		["exec"] = {"PingSelfVoiceover", "action/ping_self"},
	},
}

mod.voice_settings = {
	witch_hunter = { name = "pwh_objective_correct_path_this_way", index = 1 },
	empire_soldier = { name = "pes_objective_correct_path_this_way", index = 1 },
	dwarf_ranger = { name = "pdr_objective_correct_path_this_way", index = 3 },
	bright_wizard = { name = "pbw_objective_correct_path_this_way", index = 1 },
	wood_elf = { name = "pwe_objective_correct_path_this_way", index = 1 }
}

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("ping_self", "Ping Self Voiceover")

	--Mods.option_menu:add_item("ping_self", mod.widget_settings.DISABLED, true)
	Mods.option_menu:add_item("ping_self", mod.widget_settings.HK_TOGGLE, true)
end

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
