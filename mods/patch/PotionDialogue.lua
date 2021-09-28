--[[
	Name: Potion Dialogue
	Author: Aussiemon
	Updated: uladz (since 1.1.0)
	Version: 1.1.0 (9/25/2021)
	Link: https://github.com/Aussiemon/Vermintide-JHF-Mods/blob/original_release/mods/patch/PotionDialogue.lua

	Plays unused character-specific dialogue when a potion is consumed.

	Version history:
		1.0.0 Uptaken from GIT, last update 2/6/2018.
		1.1.0 Refactored code and changed options to better fit QoL mod options.
--]]

local mod_name = "PotionDialogue"
PotionDialogue = {}
local mod = PotionDialogue

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_potion_dialogue_enabled",
		["widget_type"] = "stepper",
		["text"] = "Potion Dialogue",
		["tooltip"] = "Potion Dialogue\n" ..
			"Plays unused character-specific dialogue when a potion is consumed.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
}

mod.stance_equivalents_all = {
	damage_boost_potion_weak = "offensive",
	speed_boost_potion_weak = "defensive",
	damage_boost_potion_medium = "offensive",
	speed_boost_potion_medium = "defensive",
	speed_boost_potion = "defensive",
	damage_boost_potion = "offensive"
}

mod.stance_equivalents_limited = {
	speed_boost_potion = "defensive",
	damage_boost_potion = "offensive"
}

-- Optimization locals
local Unit_alive = Unit.alive
local ScriptUnit_extension_input = ScriptUnit.extension_input
local FrameTable_alloc_table = FrameTable.alloc_table
local Application_user_setting = Application.user_setting

--[[
  Options
--]]

mod.create_options = function()
	local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVE, true)
end

--[[
  Functions
--]]

mod.trigger_potion_dialogue_event = function(action_extension)
	local current_action = action_extension.current_action
	local owner_unit = action_extension.owner_unit
	local buff_template = current_action.buff_template

	if buff_template and mod.stance_equivalents_all[buff_template] and Unit_alive(owner_unit) then
		local dialogue_input = ScriptUnit_extension_input(owner_unit, "dialogue_system")
		local event_data = FrameTable_alloc_table()
		event_data.stance_type = mod.stance_equivalents_all[buff_template]

		dialogue_input:trigger_networked_dialogue_event("stance_triggered", event_data)
	end
end

local get = function(data)
	return Application_user_setting(data.save)
end

--[[
  Hooks
--]]

Mods.hook.set(mod_name, "ActionPotion.finish", function (func, self, reason, ...)

	-- Play dialogue events
	if get(mod.widget_settings.ACTIVE) and reason == "action_complete" then
		mod.trigger_potion_dialogue_event(self)
	end

	local result = func(self, reason, ...)
	return result
end)

--[[
  Start
--]]

mod.create_options()
