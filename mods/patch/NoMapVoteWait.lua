local mod_name = "NoMapVoteWait"

Mods.hook.set(mod_name, "VoteTemplates.vote_for_level.on_complete", function(func, vote_result, ingame_context, data)
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

	-- Managers.state.game_mode:start_specific_level(next_level_key, 5)
	Managers.state.game_mode:start_specific_level(next_level_key)

	return next_level_key
end)
