--[[
  Name: Ping Self Voiceover (ported from VMF)
	Author: Walterr
	Updated: uladz (since 1.2.0)
	Version: 1.2.1
	Link: https://www.nexusmods.com/vermintide/mods/23

	Override the "ping self" voiceover. This causes a predetermined line of dialogue to play when you
	ping yourself, instead of a random line of "help me" dialogue. Options in Mod Settings -> Ping
	Self Voiceover. Off by default. Home key (default) will ping self.

	Version history:
		1.0.0 Release.
		1.1.0 Fix: This way can not be played in the inn.
		1.2.0 Ported from VMF to QoL.
		1.2.1 Added an option to disable voiceover and just ping yourself visually. Rewrote ping action
			function to properly send voiceover via RPC to a host. Fixed crash on host side due to assert
			rpc_play_dialogue_event.
--]]

local mod_name = "PingSelfVoiceover"
PingSelfVoiceover = {}
local mod = PingSelfVoiceover
local oi = OptionsInjector

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_ping_self_active",
		["widget_type"] = "stepper",
		["text"] = "Enable Ping Self Feature",
		["tooltip"] =  "Enable Ping Self Feature\n" ..
			"Toggle pinging self feature on / off.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2, -- Default second option is enabled. In this case On
	},
	VOICEOVER = {
		["save"] = "cb_ping_self_voiceover",
		["widget_type"] = "stepper",
		["text"] = "Override Ping Self Voiceover",
		["tooltip"] =  "Override Ping Self Voiceover\n" ..
			"Enables voiceover when you ping yourself, will play \"This way\" message.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2, -- Default second option is enabled. In this case On
	},
	HK_TOGGLE = {
		["save"] = "cb_ping_self_hotkey_ping",
		["widget_type"] = "keybind",
		["text"] = "Ping",
		["default"] = {
			"home",
			oi.key_modifiers.NONE,
		},
		["exec"] = {"patch/action", "ping_self"},
	},
}

mod.voice_settings = {
	witch_hunter = {
		name = "pwh_objective_correct_path_this_way",
		index = 1
	},
	empire_soldier = {
		name = "pes_objective_correct_path_this_way",
		index = 1
	},
	dwarf_ranger = {
		name = "pdr_objective_correct_path_this_way",
		index = 3
	},
	bright_wizard = {
		name = "pbw_objective_correct_path_this_way",
		index = 1
	},
	wood_elf = {
		name = "pwe_objective_correct_path_this_way",
		index = 1
	},
}

--[[
  Options
--]]

mod.create_options = function()
	local group = "ping_self"
	Mods.option_menu:add_group(group, "Ping Self Voiceover")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVE, true)
	Mods.option_menu:add_item(group, mod.widget_settings.VOICEOVER, true)
	Mods.option_menu:add_item(group, mod.widget_settings.HK_TOGGLE, true)
end

--[[
  Hooks
--]]

Mods.hook.set(mod_name, "DialogueSystem.rpc_play_dialogue_event", function(orig_func, self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
	if self.is_server then
		local network = Managers.state.network
		local dialogue_name = NetworkLookup.dialogues[dialogue_id]
		local dialogue = self.dialogues[dialogue_name]
		local sound_event = dialogue.sound_events[dialogue_index]
		local dialogue_actor_unit = network:game_object_or_level_unit(go_id, is_level_unit)
		local extension = self.unit_extension_data[dialogue_actor_unit]
		local wwise_source_id = WwiseUtils.make_unit_auto_source(self.world, extension.play_unit, extension.voice_node)
		local source_id = self.wwise_world:trigger_event(sound_event, wwise_source_id)
		network.network_transmit:send_rpc_clients("rpc_play_dialogue_event", go_id, is_level_unit, dialogue_id, dialogue_index)
	else
		return orig_func(self, sender, go_id, is_level_unit, dialogue_id, dialogue_index)
	end
end)

--[[
  Start
--]]

local status, err = pcall(mod.create_options)
if err ~= nil then
	EchoConsole(err)
end
