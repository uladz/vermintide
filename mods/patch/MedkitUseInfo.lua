--[[
	Name: Medkit Use Info
	Author: VernonKun, Xq
	Updated by: uladz
	Version: 1.1.0 (9/2/2021)

	This mod prints a message in console whenever someone uses a healing potion. Both players and
	bots healing is printed. Options allow to customize details of printed info.

	This mod is intended to work with QoL modpack. To "install" copy the file to
	"<games>\binaries\mods\patch" folder.

	Version history:
	1.0.0 initial version by VernonKun, Xq on 3/21/2020
	1.1.0 added support for printing other player's and bots healing info, self healing and new
	      customization options; also now you can sent info to system chat to all players
--]]

local mod_name = "MedkitUseInfo"

local SETTINGS =
{
	ENABLED = {
		["save"] =	"cb_medkit_use_info_enabled",
		["widget_type"]	=	"stepper",
		["text"] =	"Medkit Use Info",
		["tooltip"] =	"Medkit Use Info\n" ..
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
					"cb_medkit_use_info_on_others_heal",
					"cb_medkit_use_show_only_player_heal",
					"cb_medkit_use_info_send_to_all",
				},
			}, {
				true,
				mode = "show",
				options = {
					"cb_medkit_use_info_character_name",
					"cb_medkit_use_info_displayed_name",
					"cb_medkit_use_info_on_self_heal",
					"cb_medkit_use_info_on_others_heal",
					"cb_medkit_use_show_only_player_heal",
					"cb_medkit_use_info_send_to_all",
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
	INFO_ON_OTHERS = {
		["save"] = "cb_medkit_use_info_on_others_heal",
		["widget_type"] = "checkbox",
		["text"] = "Info on Other's Healing",
		["default"] = false,
	},
	SHOW_ONLY_PLAYER = {
		["save"] = "cb_medkit_use_show_only_player_heal",
		["widget_type"] = "checkbox",
		["text"] = "Show Only Player's Healing",
		["default"] = false,
	},
	SEND_TO_ALL = {
		["save"] = "cb_medkit_use_info_send_to_all",
		["widget_type"] = "checkbox",
		["text"] = "Send to System Chat",
		["default"] = false,
	},
}

local create_options = function()
	Mods.option_menu:add_group("medkit_use_info", "Medkit Use Info")
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.ENABLED, true)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.CHARACTER_NAME)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.DISPLAYED_NAME)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.INFO_ON_SELF)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.INFO_ON_OTHERS)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.SHOW_ONLY_PLAYER)
	Mods.option_menu:add_item("medkit_use_info", SETTINGS.SEND_TO_ALL)
end

local get = function(data)
	return Application.user_setting(data.save)
end

Mods.hook.set(mod_name, "InteractionDefinitions.heal.client.start", function(func, world, interactor_unit, interactable_unit, data, config, t)
	func(world, interactor_unit, interactable_unit, data, config, t)

	if not get(SETTINGS.ENABLED) then
		return
	end

	local target_is_self = (interactor_unit == interactable_unit)
	local info_on_self = get(SETTINGS.INFO_ON_SELF)

 	if interactable_unit ~= nil and (not target_is_self or info_on_self) then
		local self_unit = Managers.player:local_player().player_unit
		local show_info_on_others = get(SETTINGS.INFO_ON_OTHERS)
		local show_only_player = get(SETTINGS.SHOW_ONLY_PLAYER)

		if interactor_unit == self_unit or (show_info_on_others and (not show_only_player or interactable_unit == self_unit)) then
			local name_mapping = {
				bright_wizard	= "Sienna Fuegonasus",
				dwarf_ranger = "Bardin Goreksson",
				empire_soldier = "Markus Kruber",
				witch_hunter = "Victor Saltzpyre",
				wood_elf = "Kerillian",
			}
			local target_profile = ScriptUnit.extension(interactable_unit, "dialogue_system").context.player_profile
			local target_char = name_mapping[target_profile]
			local target_owner = Managers.player:unit_owner(interactable_unit)
			local target_name = target_owner:name()

			local source_profile = ScriptUnit.extension(interactor_unit, "dialogue_system").context.player_profile
			local source_char = name_mapping[source_profile]
			local source_owner = Managers.player:unit_owner(interactor_unit)
			local source_name = source_owner:name()

			local show_character_name = get(SETTINGS.CHARACTER_NAME)
			local show_displayed_name = get(SETTINGS.DISPLAYED_NAME)
			local send_to_all = get(SETTINGS.SEND_TO_ALL)
			local target_is_bot = target_owner._cached_name == nil or target_owner.bot_player
			local source_is_bot = source_owner._cached_name == nil or source_owner.bot_player

			local msg = ""
			if show_character_name then
				msg = msg .. source_char
				if show_displayed_name then
					msg = msg .. " ("
					if source_is_bot then
						msg = msg .. "BOT"
					else
						msg = msg .. source_name
					end
					msg = msg .. ")"
				end
			elseif show_displayed_name then
				msg = msg .. source_name
			end

			msg = msg .. " healed "

			if target_is_self then
				local gen_mapping = {
					bright_wizard	= "her",
					dwarf_ranger = "him",
					empire_soldier = "him",
					witch_hunter = "him",
					wood_elf = "her",
				}
				local herhim = gen_mapping[source_profile]
				msg = msg .. " " .. herhim .. "self"
			else
				if show_character_name then
					msg = msg .. target_char
					if show_displayed_name then
						msg = msg .. " ("
						if target_is_bot then
							msg = msg .. "BOT"
						else
							msg = msg .. target_name
						end
						msg = msg .. ")"
					end
				elseif show_displayed_name then
					msg = msg .. target_name
				end
			end
			-- send message to all players
			if send_to_all then
				Managers.chat:send_system_chat_message(1, msg)
			else
				EchoConsole(msg)
			end
		end
	end

	return
end)

local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end
