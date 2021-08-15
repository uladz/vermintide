--[[
	Name: Medkit Use Info
	Author: VernonKun, Xq
	Updated: 3/21/2020

	This mod prints a message in console whenever someone uses a healing potion. Both players and
	bots healing is printed. Options allow to customize details of printed info.

	This mod is intended to work with QoL modpack. To "install" copy the file to
	"<games>\binaries\mods\patch" folder.
--]]

local mod_name = "MedkitUseInfo"

local SETTINGS =
{
	ENABLED = {
		["save"] =	"cb_medkit_use_info_enabled",
		["widget_type"]	=	"stepper",
		["text"] =	"Medkit Use Info",
		["tooltip"] =	"Interaction info:\n" ..
			"Prints out a local chat line of the target you are healing with a medkit.",
		["value_type"] =	"boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_medkit_use_info_character_name",
					"cb_medkit_use_info_displayed_name",
					"cb_medkit_use_info_on_self_heal",
				},
			}, {
				true,
				mode = "show",
				options = {
					"cb_medkit_use_info_character_name",
					"cb_medkit_use_info_displayed_name",
					"cb_medkit_use_info_on_self_heal",
				},
			},
		},
	},
	CHARACTER_NAME = {
		["save"] = "cb_medkit_use_info_character_name",
		["widget_type"] = "checkbox",
		["text"] = "Character Name",
		["default"] = false,
	},
	DISPLAYED_NAME = {
		["save"] = "cb_medkit_use_info_displayed_name",
		["widget_type"] = "checkbox",
		["text"] = "Displayed Name",
		["default"] = false,
	},
	INFO_ON_SELF = {
		["save"] = "cb_medkit_use_info_on_self_heal",
		["widget_type"] = "checkbox",
		["text"] = "Info on Self Heal",
		["default"] = false,
	},
}

local create_options = function()
	Mods.option_menu:add_group("medkit_use_info", "Medkit Use Info")
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.ENABLED, true)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.CHARACTER_NAME)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.DISPLAYED_NAME)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.INFO_ON_SELF)
end

local get = function(data)
	return Application.user_setting(data.save)
end

Mods.hook.set(mod_name, "InteractionDefinitions.heal.client.start", function(func, world, interactor_unit, interactable_unit, data, config, t)
	func(world, interactor_unit, interactable_unit, data, config, t)

	if get(SETTINGS.ENABLED) and interactable_unit ~= nil and (interactor_unit ~= interactable_unit or get(SETTINGS.INFO_ON_SELF)) then
		local self_unit = Managers.player:local_player().player_unit

		if interactor_unit == self_unit then
			local name_mapping =
			{
				bright_wizard	= "Sienna Fuegonasus",
				dwarf_ranger	= "Bardin Goreksson",
				empire_soldier	= "Markus Kruber",
				witch_hunter	= "Victor Saltzpyre",
				wood_elf	= "Kerillian",
			}
			local event_data_target_name = ScriptUnit.extension(interactable_unit, "dialogue_system").context.player_profile
			local character_name = name_mapping[event_data_target_name] or "invalid_target"

			local owner = Managers.player:unit_owner(interactable_unit)
			local displayed_name = owner:name() or "invalid target"

			local show_character_name = get(SETTINGS.CHARACTER_NAME)
			local show_displayed_name = get(SETTINGS.DISPLAYED_NAME)
			local target_is_bot = owner._cached_name == nil or owner.bot_player

			if show_character_name and show_displayed_name then
				if target_is_bot then
					EchoConsole("<Healing " .. character_name .. " (BOT)...>")
				else
					EchoConsole("<Healing " .. character_name .. " (" .. displayed_name .. ")...>")
				end
			elseif show_character_name then
				EchoConsole("<Healing " .. character_name .. "...>")
			elseif show_displayed_name then
				EchoConsole("<Healing " .. displayed_name .. "...>")
			end
		end
	end

	return
end)

create_options()
