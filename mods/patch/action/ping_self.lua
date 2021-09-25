safe_pcall(function()
	if not Application.user_setting(PingSelfVoiceover.widget_settings.ACTIVE.save) then
		return
	end

	local local_player = Managers.player:local_player()
	if local_player then

		local local_player_unit = local_player.player_unit
		if local_player_unit and Unit.alive(local_player_unit) then

			local local_character = SPProfiles[local_player.profile_index].character_vo
			local voice_setting = PingSelfVoiceover.voice_settings[local_character]
			local dialogue_system = Managers.state.entity._systems.dialogue_system
			local dialogue = dialogue_system.dialogues[voice_setting.name]

			if dialogue then
				local network = Managers.state.network
				local unit_id = network:unit_game_object_id(local_player_unit)

				-- Ping yourself
				network.network_transmit:send_rpc_server("rpc_ping_unit", unit_id, unit_id)

				if Application.user_setting(PingSelfVoiceover.widget_settings.VOICEOVER.save) then
					local dialogue_id = NetworkLookup.dialogues[voice_setting.name]
					local dialogue_index = voice_setting.index
					local go_id, is_level_unit = network:game_object_or_level_id(unit_id)

					-- Play dialogue
					network.network_transmit:send_rpc_server("rpc_play_dialogue_event",
						go_id, is_level_unit, dialogue_id, dialogue_index)
				end
			end
		end
	end
end)
