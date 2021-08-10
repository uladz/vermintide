--[[
	The Stormvermin Mutation, by Grimalackt. Fool-proof version that will not cause issues if executed several times in a row.
--]]

local local_player = Managers.player

if not local_player.is_server and not mutationtoken then
	EchoConsole("You must be the host to activate mods.")
	return
end

if Managers.state.game_mode == nil or (Managers.state.game_mode._game_mode_key ~= "inn" and local_player.is_server) then
	EchoConsole("You must be in the inn to mutate the difficulty!")
	return
end

if not mutationtoken then
	mutationtoken = true

	if not deathwishtoken then
		deathwishtoken = false
	end

	if not Breeds_skaven_slave then
		Breeds_skaven_slave = Breeds.skaven_slave
	end

	if not Breeds_skaven_clan_rat then
		Breeds_skaven_clan_rat = Breeds.skaven_clan_rat
	end

	if not Breeds_skaven_gutter_runner then
		Breeds_skaven_gutter_runner = Breeds.skaven_gutter_runner
	end

	if not Breeds_skaven_pack_master then
		Breeds_skaven_pack_master = Breeds.skaven_pack_master
	end

	if not Breeds_skaven_poison_wind_globadier then
		Breeds_skaven_poison_wind_globadier = Breeds.skaven_poison_wind_globadier
	end

	if not Breeds_skaven_ratling_gunner then
		Breeds_skaven_ratling_gunner = Breeds.skaven_ratling_gunner
	end

	Breeds.skaven_slave = Breeds_skaven_clan_rat
	Breeds.skaven_clan_rat = Breeds.skaven_storm_vermin_commander

	Breeds.skaven_gutter_runner = Breeds.skaven_rat_ogre
	Breeds.skaven_pack_master = Breeds.skaven_rat_ogre
	Breeds.skaven_poison_wind_globadier = Breeds.skaven_rat_ogre
	Breeds.skaven_ratling_gunner = Breeds.skaven_rat_ogre

	Mods.hook.set("Gamemodes", "GameModeManager.complete_level", function(func, self)
		local total = 0
		local mission_system = Managers.state.entity:system("mission_system")
		local active_mission = mission_system.active_missions

		-- Add Death Wish Grimoires
		local rank = Managers.state.difficulty:get_difficulty_rank()

		if deathwishtoken and rank == 5 then
			for i = 1,2 do
				mission_system.request_mission(mission_system, "grimoire_hidden_mission", nil, Network.peer_id())
				mission_system.update_mission(mission_system, "grimoire_hidden_mission", true, nil, Network.peer_id(), nil, true)
			end
		end

		-- Add Onslaught Grimoire
		if onslaughttoken then
			mission_system.request_mission(mission_system, "grimoire_hidden_mission", nil, Network.peer_id())
			mission_system.update_mission(mission_system, "grimoire_hidden_mission", true, nil, Network.peer_id(), nil, true)
		end

		-- Add Mutation dice.
		if mutationtoken then
			for i = 1,5 do
				mission_system.request_mission(mission_system, "bonus_dice_hidden_mission", nil, Network.peer_id())
				mission_system.update_mission(mission_system, "bonus_dice_hidden_mission", true, nil, Network.peer_id(), nil, true)
			end
		end

		-- Calculate the total
		for name, obj in pairs(active_mission) do
			if name == "tome_bonus_mission" or name == "grimoire_hidden_mission" or name == "bonus_dice_hidden_mission" then
				total = total + obj.current_amount 
			end
		end
	
		-- Remove if there are to much total
		if active_mission.bonus_dice_hidden_mission then
			for i = 1, active_mission.bonus_dice_hidden_mission.current_amount do
				if total > 7 then
					mission_system.request_mission(mission_system,  "bonus_dice_hidden_mission", nil, Network.peer_id())
					mission_system.update_mission(mission_system,  "bonus_dice_hidden_mission", false, nil, Network.peer_id(), nil, true)
				
					total = total - 1
				end
			end
		end
	
		if active_mission.tome_bonus_mission then
			for i = 1, active_mission.tome_bonus_mission.current_amount do
				if total > 7 then
					mission_system.request_mission(mission_system,  "tome_bonus_mission", nil, Network.peer_id())
					mission_system.update_mission(mission_system,  "tome_bonus_mission", false, nil, Network.peer_id(), nil, true)
				
					total = total - 1
				end
			end
		end
	
		if active_mission.grimoire_hidden_mission then
			for i = 1, active_mission.grimoire_hidden_mission.current_amount do
				if total > 7 then
					mission_system.request_mission(mission_system,  "grimoire_hidden_mission", nil, Network.peer_id())
					mission_system.update_mission(mission_system,  "grimoire_hidden_mission", nil, Network.peer_id(), false, nil, true)
		
					total = total - 1
				end
			end
		end
	
		-- Call orginal function
		func(self)

		return
	end)

	Mods.hook.front("Gamemodes", "GameModeManager.complete_level")

	Mods.hook.set("Gamemodes", "IngamePlayerListUI.set_difficulty_name", function(func, self, name)
		local content = self.headers.content
		if (name == "Veteran" or name == "Champion" or name == "Heroic") and slayertoken then
			if name == "Heroic" and deathwishtoken and mutationtoken then
				content.game_difficulty = "Deathwish Mutated Slayer's Oath"
			elseif name == "Heroic" and deathwishtoken then
				content.game_difficulty = "Deathwish Slayer's Oath"
			elseif mutationtoken then 
				content.game_difficulty = name .. " Mutated Slayer's Oath"
			else
				content.game_difficulty = name .. " Slayer's Oath"
			end
		elseif (name == "Easy" or name == "Normal" or name == "Hard" or name == "Nightmare" or name == "Cataclysm") and onslaughttoken then
			if name == "Cataclysm" and deathwishtoken and mutationtoken then
				content.game_difficulty = "Deathwish Mutated Onslaught"
			elseif name == "Cataclysm" and deathwishtoken then
				content.game_difficulty = "Deathwish Onslaught"
			elseif mutationtoken then 
				content.game_difficulty = name .. " Mutated Onslaught"
			else
				content.game_difficulty = name .. " Onslaught"
			end
		elseif (name == "Cataclysm" or name == "Heroic") and deathwishtoken then
			if mutationtoken then
				content.game_difficulty = "Deathwish Mutated"
			else
				content.game_difficulty = "Deathwish"
			end
		elseif mutationtoken then
			content.game_difficulty = name .. " Mutated"
		else
			content.game_difficulty = name
		end
		return
	end)

	Mods.hook.front("Gamemodes", "IngamePlayerListUI.set_difficulty_name")

	Mods.hook.set("Gamemodes", "MatchmakingStateHostGame.host_game", function(func, self, next_level_key, difficulty, game_mode, private_game, required_progression)
		func(self, next_level_key, difficulty, game_mode, private_game, required_progression)

		local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
		local old_server_name = LobbyAux.get_unique_server_name()


		if (difficulty == "survival_hard" or difficulty == "survival_harder" or difficulty == "survival_hardest") and slayertoken then
			if difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
				lobby_data.unique_server_name = "||DW MUTATED SLAYER'S OATH|| " .. string.sub(old_server_name,1,15)
			elseif difficulty == "survival_hardest" and deathwishtoken then
				lobby_data.unique_server_name = "||Deathwish Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			elseif mutationtoken then 
				lobby_data.unique_server_name = "||Mutated Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			end
		elseif (difficulty == "easy" or difficulty == "normal" or difficulty == "hard" or difficulty == "harder" or difficulty == "hardest") and onslaughttoken then
			if difficulty == "hardest" and deathwishtoken and mutationtoken then
				lobby_data.unique_server_name = "||DW MUTATED ONSLAUGHT|| " .. string.sub(old_server_name,1,17)
			elseif difficulty == "hardest" and deathwishtoken then
				lobby_data.unique_server_name = "||Deathwish Onslaught|| " .. string.sub(old_server_name,1,17)
			elseif mutationtoken then 
				lobby_data.unique_server_name = "||Mutated Onslaught|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Onslaught|| " .. string.sub(old_server_name,1,17)
			end
		elseif (difficulty == "hardest" or difficulty == "survival_hardest") and deathwishtoken then
			if mutationtoken then
				lobby_data.unique_server_name = "||MUTATED DEATHWISH|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Deathwish Difficulty|| " .. string.sub(old_server_name,1,17)
			end
		elseif mutationtoken then
			lobby_data.unique_server_name = "||Stormvermin Mutation|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = old_server_name
		end

		Managers.matchmaking.lobby:set_lobby_data(lobby_data)
	end)

	--Instant set lobby data
	if not slayertoken then
		slayertoken = false
	end

	if not onslaughttoken then
		onslaughttoken = false
	end

	local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
	local old_server_name = LobbyAux.get_unique_server_name()

	if (lobby_data.difficulty == "survival_hard" or lobby_data.difficulty == "survival_harder" or lobby_data.difficulty == "survival_hardest") and slayertoken then
		if lobby_data.difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
			lobby_data.unique_server_name = "||DW MUTATED SLAYER'S OATH|| " .. string.sub(old_server_name,1,15)
		elseif lobby_data.difficulty == "survival_hardest" and deathwishtoken then
			lobby_data.unique_server_name = "||Deathwish Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		elseif mutationtoken then 
			lobby_data.unique_server_name = "||Mutated Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		end
	elseif (lobby_data.difficulty == "easy" or lobby_data.difficulty == "normal" or lobby_data.difficulty == "hard" or lobby_data.difficulty == "harder" or lobby_data.difficulty == "hardest") and onslaughttoken then
		if lobby_data.difficulty == "hardest" and deathwishtoken and mutationtoken then
			lobby_data.unique_server_name = "||DW MUTATED ONSLAUGHT|| " .. string.sub(old_server_name,1,17)
		elseif lobby_data.difficulty == "hardest" and deathwishtoken then
			lobby_data.unique_server_name = "||Deathwish Onslaught|| " .. string.sub(old_server_name,1,17)
		elseif mutationtoken then 
			lobby_data.unique_server_name = "||Mutated Onslaught|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Onslaught|| " .. string.sub(old_server_name,1,17)
		end
	elseif (lobby_data.difficulty == "hardest" or lobby_data.difficulty == "survival_hardest") and deathwishtoken then
		if mutationtoken then
			lobby_data.unique_server_name = "||MUTATED DEATHWISH|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Deathwish Difficulty|| " .. string.sub(old_server_name,1,17)
		end
	elseif mutationtoken and name ~= "" then
		lobby_data.unique_server_name = "||Stormvermin Mutation|| " .. string.sub(old_server_name,1,17)
	else
		lobby_data.unique_server_name = old_server_name
	end

	Managers.matchmaking.lobby:set_lobby_data(lobby_data)
	--End lobby data

	--Whispering newcomers
	Mods.hook.set("Gamemodes", "MatchmakingManager.rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, host_cookie, lobby_id, friend_join)
		-- get the peer_id out of the client_cookie
		local peer_id = tostring(client_cookie)
		for i=1,3 do
			peer_id = string.sub(peer_id, 1 + tonumber(tostring(string.find(peer_id,"-"))))
		end
		peer_id=string.sub(peer_id, 2)
		peer_id = string.reverse(peer_id)
		peer_id = string.sub(peer_id, 2)
		peer_id = string.reverse(peer_id)

		local function member_func()
			local members = {}
			for i,v in ipairs(self.lobby:members():get_members()) do
				if v == peer_id then
					return {v}
				end
			end
			return self.lobby:members():get_members()
		end

		local original_member_func = Managers.chat.channels[1].members_func
		Managers.chat.channels[1].members_func = member_func
		
		if (lobby_data.difficulty == "survival_hard" or lobby_data.difficulty == "survival_harder" or lobby_data.difficulty == "survival_hardest") and slayertoken then
			if lobby_data.difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset, Deathwish difficulty, Stormvermin Mutation. Yeah, they're suicidal."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif lobby_data.difficulty == "survival_hardest" and deathwishtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset, Deathwish difficulty. Die with honor, hero."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset, Stormvermin Mutation."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			else
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			end
		elseif (lobby_data.difficulty == "easy" or lobby_data.difficulty == "normal" or lobby_data.difficulty == "hard" or lobby_data.difficulty == "harder" or lobby_data.difficulty == "hardest") and onslaughttoken then
			if lobby_data.difficulty == "hardest" and deathwishtoken and mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught, Deathwish difficulty, Stormvermin Mutation. Yeah, they're suicidal."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif lobby_data.difficulty == "hardest" and deathwishtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught, Deathwish difficulty. Die with honor, hero."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif mutationtoken then 
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught, Stormvermin Mutation."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			else
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			end
		elseif (lobby_data.difficulty == "hardest" or lobby_data.difficulty == "survival_hardest") and deathwishtoken then
			if mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Deathwish difficulty, Stormvermin Mutation."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			else
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Deathwish difficulty."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			end
		elseif mutationtoken then
			Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Stormvermin Mutation."
			Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
		end

		Managers.chat.channels[1].members_func = original_member_func
		func(self, sender, client_cookie, host_cookie, lobby_id, friend_join)
		return
	end)

	Mods.hook.front("Gamemodes", "MatchmakingManager.rpc_matchmaking_request_join_lobby")
	--End whispers

	if deathwishtoken then
		Managers.chat:send_system_chat_message(1, "Mutated Deathwish ENABLED. I'd say good luck, but we both know that won't save you.", 0, true)
	else
		Managers.chat:send_system_chat_message(1, "Stormvermin Mutation ENABLED.", 0, true)
	end

else
	mutationtoken = false

	if Breeds_skaven_slave then
		Breeds.skaven_slave = Breeds_skaven_slave
	end

	if Breeds_skaven_clan_rat then
		Breeds.skaven_clan_rat = Breeds_skaven_clan_rat
	end

	if Breeds_skaven_gutter_runner then
		Breeds.skaven_gutter_runner = Breeds_skaven_gutter_runner
	end

	if Breeds_skaven_pack_master then
		Breeds.skaven_pack_master = Breeds_skaven_pack_master
	end

	if Breeds_skaven_poison_wind_globadier then
		Breeds.skaven_poison_wind_globadier = Breeds_skaven_poison_wind_globadier
	end

	if Breeds_skaven_ratling_gunner then
		Breeds.skaven_ratling_gunner = Breeds_skaven_ratling_gunner
	end

	if not deathwishtoken and not onslaughttoken then
		Mods.hook.enable(false, "Gamemodes", "GameModeManager.complete_level")
	end

	if local_player.is_server then
		local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
		local old_server_name = LobbyAux.get_unique_server_name()

		if (lobby_data.difficulty == "survival_hard" or lobby_data.difficulty == "survival_harder" or lobby_data.difficulty == "survival_hardest") and slayertoken then
			if lobby_data.difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
				lobby_data.unique_server_name = "||DW MUTATED SLAYER'S OATH|| " .. string.sub(old_server_name,1,15)
			elseif lobby_data.difficulty == "survival_hardest" and deathwishtoken then
				lobby_data.unique_server_name = "||Deathwish Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			elseif mutationtoken then 
				lobby_data.unique_server_name = "||Mutated Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			end
		elseif (lobby_data.difficulty == "easy" or lobby_data.difficulty == "normal" or lobby_data.difficulty == "hard" or lobby_data.difficulty == "harder" or lobby_data.difficulty == "hardest") and onslaughttoken then
			if lobby_data.difficulty == "hardest" and deathwishtoken and mutationtoken then
				lobby_data.unique_server_name = "||DW MUTATED ONSLAUGHT|| " .. string.sub(old_server_name,1,17)
			elseif lobby_data.difficulty == "hardest" and deathwishtoken then
				lobby_data.unique_server_name = "||Deathwish Onslaught|| " .. string.sub(old_server_name,1,17)
			elseif mutationtoken then 
				lobby_data.unique_server_name = "||Mutated Onslaught|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Onslaught|| " .. string.sub(old_server_name,1,17)
			end
		elseif (lobby_data.difficulty == "hardest" or lobby_data.difficulty == "survival_hardest") and deathwishtoken then
			if mutationtoken then
				lobby_data.unique_server_name = "||MUTATED DEATHWISH|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Deathwish Difficulty|| " .. string.sub(old_server_name,1,17)
			end
		elseif mutationtoken then
			lobby_data.unique_server_name = "||Stormvermin Mutation|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = old_server_name
		end

		Managers.matchmaking.lobby:set_lobby_data(lobby_data)

		Managers.chat:send_system_chat_message(1, "Stormvermin Mutation DISABLED.", 0, true)
	end

end

Mods.hook.set("Gamemodes", "MatchmakingManager.update", function(func, self, dt, t)
	-- Call original function
	func(self, dt, t)
	
	if not local_player.is_server and mutationtoken and Managers.state.game_mode ~= nil then
		Mods.exec("commands", "Mutation")
		EchoConsole("The Stormvermin Mutation was disabled because you are no longer the server.")
	end
end)