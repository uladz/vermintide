local mod, mod_name, oi = Mods.get_mod("PingSelfVoiceover")

safe_pcall(function()
	local local_player = Managers.player:local_player()
	
	if local_player then
		local local_player_unit = local_player.player_unit
		
		if local_player_unit and Unit.alive(local_player_unit) then
			local unit_id = Managers.state.network:unit_game_object_id(local_player_unit)
			local local_character = SPProfiles[local_player.profile_index].character_vo
			local voice_setting = mod.voice_settings[local_character]
			
			local dialogue_system = Managers.state.entity._systems.dialogue_system
			
			if dialogue_system.dialogues[voice_setting.name] then
				local dialogue = NetworkLookup.dialogues[voice_setting.name]
				local go_id, is_level_unit = Managers.state.network:game_object_or_level_id(unit_id)
				
				local human_players = Managers.player:human_players()
				for _, player in pairs(human_players) do
					-- Ping yourself
					Managers.state.network.network_transmit:send_rpc(
						"rpc_ping_unit", player.peer_id, unit_id, unit_id)
					
					-- Play dialogue
					Managers.state.network.network_transmit:send_rpc(
						"rpc_play_dialogue_event", player.peer_id,
						go_id, is_level_unit, dialogue, voice_setting.index)
				end
			end
		end
	end
end)