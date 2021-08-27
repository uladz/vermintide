--[[
	Name: No Map Vote Wait
	Author: VernonKun (presumably)
	Version: 1.1.0
	Updated: uladz

	Allows to skip waiting for the next map vote results confirmation at the end of a mission. I.e. it
	will skip 5 second timeout after majority voted for the next map.

	Version history:
	1.0.0 initial version by VernonKun on 1/22/2021
	1.1.0 added mod option menu entry to enable/disable this tweak
--]]

local mod_name = "NoMapVoteWait"

local MOD_SETTINGS = {
	ENABLED = {
		["save"] = "cb_no_map_vote_wait",
		["widget_type"] = "stepper",
		["text"] = "No Map Vote Wait",
		["tooltip"] = "No Map Vote Wait\n" ..
			"Skip 5 sec wait after majority voted for the next map at the end of a mission.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
  },
}

local create_options = function()
	Mods.option_menu:add_group("tweaks", "Gameplay Tweaks")

	Mods.option_menu:add_item("tweaks",MOD_SETTINGS.ENABLED, true)
end

local get = function(data)
	return Application.user_setting(data.save)
end

Mods.hook.set(mod_name, "VoteTemplates.vote_for_level.on_complete", function(func, vote_result, ingame_context, data)
	if get(MOD_SETTINGS.ENABLED) then
		local level_transition_handler = ingame_context.level_transition_handler
		local next_level_key = "inn_level"
		local next_level_difficulty = nil

		if vote_result == 1 then
			next_level_key = data[1]
			next_level_difficulty = data[3]
		elseif vote_result == 2 then
			next_level_key = data[2]
			next_level_difficulty = data[4]
		end

		if next_level_difficulty then
			Managers.state.difficulty:set_difficulty(next_level_difficulty)
		end

		-- vanilla code
		-- Managers.state.game_mode:start_specific_level(next_level_key, 5)

		-- new code skips 5 sec wait timer
		Managers.state.game_mode:start_specific_level(next_level_key)

		return next_level_key
	else
		func(vote_result, ingame_context, data)
	end
end)

local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end
