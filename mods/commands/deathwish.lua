local local_player = Managers.player

if not local_player.is_server and not deathwishtoken then
	EchoConsole("You must be the host to activate mods.")
	return
end

if Managers.state.game_mode == nil or (Managers.state.game_mode._game_mode_key ~= "inn" and local_player.is_server) then
	EchoConsole("You must be in the inn to change the difficulty!")
	return
end

if mutationtoken then
	EchoConsole("You may not activate or deactivate Deathwish while the Stormvermin Mutation is already active.")
	return
end

if not deathwishtoken then
	deathwishtoken = true

	OriginalBreedsMaxHealth = {}
	for name, breed in pairs(Breeds) do
		OriginalBreedsMaxHealth[name] = breed.max_health[5]
	end

	Breeds.skaven_clan_rat.max_health[5] = 18

	Breeds.skaven_slave.max_health[5] = 9

	Breeds.skaven_gutter_runner.max_health[5] = 30

	Breeds.skaven_loot_rat.max_health[5] = 200

	Breeds.skaven_pack_master.max_health[5] = 72

	Breeds.skaven_poison_wind_globadier.max_health[5] = 30

	Breeds.skaven_ratling_gunner.max_health[5] = 30

	Breeds.skaven_storm_vermin.max_health[5] = 50

	Breeds.skaven_storm_vermin_commander.max_health[5] = 50

	BreedActions.skaven_clan_rat.first_attack.difficulty_damage.hardest = {
							20,
							10,
							5
						}

	BreedActions.skaven_clan_rat.running_attack.difficulty_damage.hardest = {
							20,
							10,
							5
						}


	BreedActions.skaven_clan_rat.normal_attack.difficulty_damage.hardest = {
							20,
							10,
							5
						}


	BreedActions.skaven_gutter_runner.target_pounced.difficulty_damage.hardest = {
							10,
							4,
							1
						}

	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.aoe_init_damage[5] = {
							20,
							2,
							0
						}

	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.aoe_dot_damage[5] = {
							30,
							0,
							0
						}

	BreedActions.skaven_poison_wind_globadier.suicide_run.aoe_init_damage[5] = {
							70,
							5,
							0
						}

	BreedActions.skaven_poison_wind_globadier.suicide_run.aoe_dot_damage[5] = {
							20,
							0,
							0
						}


	BreedActions.skaven_rat_ogre.melee_slam.difficulty_damage.hardest = {
							60,
							30,
							22.5
						}

	BreedActions.skaven_rat_ogre.melee_slam.blocked_difficulty_damage.hardest = {
							25,
							20,
							15
						}

	BreedActions.skaven_rat_ogre.melee_shove.difficulty_damage.hardest = {
							100,
							90,
							90
						}

	BreedActions.skaven_storm_vermin.special_attack_sweep.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_sweep.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin.special_attack_cleave.difficulty_damage.hardest = {
							150,
							75,
							45
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_cleave.difficulty_damage.hardest = {
							150,
							75,
							45
						}

	--Last Stand
	BreedActions.skaven_clan_rat.first_attack.difficulty_damage.survival_hardest = {
							30,
							15,
							7.5
						}

	BreedActions.skaven_clan_rat.running_attack.difficulty_damage.survival_hardest = {
							30,
							15,
							7.5
						}


	BreedActions.skaven_clan_rat.normal_attack.difficulty_damage.survival_hardest = {
							30,
							15,
							7.5
						}


	BreedActions.skaven_gutter_runner.target_pounced.difficulty_damage.survival_hardest = {
							15,
							6,
							1.5
						}

	BreedActions.skaven_rat_ogre.melee_slam.difficulty_damage.survival_hardest = {
							90,
							45,
							33.75
						}

	BreedActions.skaven_rat_ogre.melee_slam.blocked_difficulty_damage.survival_hardest = {
							37.5,
							30,
							22.5
						}

	BreedActions.skaven_rat_ogre.melee_shove.difficulty_damage.survival_hardest = {
							150,
							135,
							135
						}

	BreedActions.skaven_storm_vermin.special_attack_sweep.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_sweep.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin.special_attack_cleave.difficulty_damage.survival_hardest = {
							225,
							112.5,
							67.5
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_cleave.difficulty_damage.survival_hardest = {
							225,
							112.5,
							67.5
						}
	--LS Krench
	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.blocked_difficulty_damage.survival_hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.difficulty_damage.survival_hardest = {
							225,
							112.5,
							67.5
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.blocked_difficulty_damage.survival_hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.blocked_difficulty_damage.survival_hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_left.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_right.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.blocked_difficulty_damage.survival_hardest = {
							37.5,
							30,
							22.5
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.blocked_difficulty_damage.survival_hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.blocked_difficulty_damage.survival_hardest = {
							37.5,
							30,
							22.5
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.blocked_difficulty_damage.survival_hardest = {
							37.5,
							30,
							22.5
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.difficulty_damage.survival_hardest = {
							112.5,
							67.5,
							45
						}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.survival_hardest = {
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin"
						}
	--End LS Krench
	--End Last Stand
	--Krench
	Breeds.skaven_storm_vermin_champion.max_health[5] = 1400

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.blocked_difficulty_damage.hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.difficulty_damage.hardest = {
							150,
							75,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.blocked_difficulty_damage.hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.blocked_difficulty_damage.hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_left.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_right.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.blocked_difficulty_damage.hardest = {
							25,
							20,
							15
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.blocked_difficulty_damage.hardest = {
							20,
							20,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.blocked_difficulty_damage.hardest = {
							25,
							20,
							15
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.blocked_difficulty_damage.hardest = {
							25,
							20,
							15
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.difficulty_damage.hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.hardest = {
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin"
						}
	--End Krench

	AttackDamageValues.ratlinggun_very_hard = { 16, 2.5, 7.5, 8 }
	BreedActions.skaven_ratling_gunner.shoot_ratling_gun.attack_template_damage_type[4] = "ratlinggun_hard"

	DifficultySettings.hardest.amount_storm_vermin_patrol = 24


	Mods.hook.set("Gamemodes", "PlayerUnitHealthExtension._knock_down", function(func, self, unit)
		local rank = Managers.state.difficulty:get_difficulty_rank()

		if rank == 5 and Managers.state.game_mode._game_mode_key ~= "inn" then
			PlayerUnitHealthExtension.die(self, unit)
			return
		else

			self.state = "knocked_down"

			StatusUtils.set_knocked_down_network(unit, true)
			StatusUtils.set_wounded_network(unit, false, "knocked_down")

			return
		end
	end)

	Mods.hook.front("Gamemodes", "PlayerUnitHealthExtension._knock_down")

	Mods.hook.set("Gamemodes", "DamageUtils.add_damage_network", function(func, attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, damage_direction, damage_source, hit_ragdoll_actor, damaging_unit)
		local damage_amountfixed = (original_damage_amount / 1.5)
		local damage_amountff = (original_damage_amount * 1.5)
		local breed = Unit.get_data(attacked_unit, "breed")
		local rank = Managers.state.difficulty:get_difficulty_rank()

		if rank == 4 and damage_source == "skaven_ratling_gunner" and breed and (breed.name == "skaven_rat_ogre" or breed.name == "skaven_pack_master") then
			if hit_zone_name == "head" or hit_zone_name == "neck" then
				original_damage_amount = 6
			else
				original_damage_amount = 4
			end
		end

		if rank ~= 5 then
			func(attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, damage_direction, damage_source, hit_ragdoll_actor, damaging_unit)
		elseif breed ~= nil then
			if breed.name == "skaven_rat_ogre" then
				func(attacked_unit, attacker_unit, damage_amountfixed, hit_zone_name, damage_type, damage_direction, damage_source, hit_ragdoll_actor, damaging_unit)
			else
				func(attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, damage_direction, damage_source, hit_ragdoll_actor, damaging_unit)
			end
		elseif (Unit.get_data(attacker_unit, "breed") == nil and damage_type ~= "damage_over_time") then
			func(attacked_unit, attacker_unit, damage_amountff, hit_zone_name, damage_type, damage_direction, damage_source, hit_ragdoll_actor, damaging_unit)
		else
			func(attacked_unit, attacker_unit, original_damage_amount, hit_zone_name, damage_type, damage_direction, damage_source, hit_ragdoll_actor, damaging_unit)
		end
	end)

	Mods.hook.front("Gamemodes", "DamageUtils.add_damage_network")

	Mods.hook.set("Gamemodes", "RespawnHandler.update", function(func, self, dt, t, player_statuses)
		for _, status in ipairs(player_statuses) do
			if status.health_state == "dead" and not status.ready_for_respawn and not status.respawn_timer then
				local peer_id = status.peer_id
				local local_player_id = status.local_player_id
				local respawn_time = 30

				local rank = Managers.state.difficulty:get_difficulty_rank()

				if rank == 5 then
					respawn_time = 60
				end

				if peer_id or local_player_id then
					local player = Managers.player:player(peer_id, local_player_id)
					local player_unit = player.player_unit

					if Unit.alive(player_unit) then
						local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
						respawn_time = buff_extension.apply_buffs_to_value(buff_extension, respawn_time, StatBuffIndex.FASTER_RESPAWN)
					end
				end

				status.respawn_timer = t + respawn_time
			elseif status.health_state == "dead" and not status.ready_for_respawn and status.respawn_timer < t then
				status.respawn_timer = nil
				status.ready_for_respawn = true
			end
		end

		return 
	end)

	Mods.hook.front("Gamemodes", "RespawnHandler.update")

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
		elseif mutationtoken and name ~= "" then
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

	if not mutationtoken then
		mutationtoken = false
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
	elseif mutationtoken then
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

	Managers.chat:send_system_chat_message(1, "Deathwish difficulty ENABLED.", 0, true)

else
	deathwishtoken = false

	for name, breed in pairs(Breeds) do
		breed.max_health[5] = OriginalBreedsMaxHealth[name]
	end

	BreedActions.skaven_clan_rat.first_attack.difficulty_damage.hardest = {
							15,
							8,
							4
						}

	BreedActions.skaven_clan_rat.running_attack.difficulty_damage.hardest = {
							15,
							8,
							4
						}


	BreedActions.skaven_clan_rat.normal_attack.difficulty_damage.hardest = {
							15,
							8,
							4
						}


	BreedActions.skaven_gutter_runner.target_pounced.difficulty_damage.hardest = {
							5,
							2,
							0.5
						}

	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.aoe_init_damage[5] = {
							10,
							1,
							0
						}

	BreedActions.skaven_poison_wind_globadier.throw_poison_globe.aoe_dot_damage[5] = {
							15,
							0,
							0
						}

	BreedActions.skaven_poison_wind_globadier.suicide_run.aoe_init_damage[5] = {
							40,
							3,
							0
						}

	BreedActions.skaven_poison_wind_globadier.suicide_run.aoe_dot_damage[5] = {
							10,
							0,
							0
						}

	BreedActions.skaven_rat_ogre.melee_slam.difficulty_damage.hardest = {
							40,
							20,
							15
						}

	BreedActions.skaven_rat_ogre.melee_slam.blocked_difficulty_damage.hardest = {
							12,
							10,
							7.5
						}

	BreedActions.skaven_rat_ogre.melee_shove.difficulty_damage.hardest = {
							60,
							50,
							50
						}

	BreedActions.skaven_storm_vermin.special_attack_sweep.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_sweep.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin.special_attack_cleave.difficulty_damage.hardest = {
							100,
							50,
							30
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_cleave.difficulty_damage.hardest = {
							100,
							50,
							30
						}

	--Last Stand
	BreedActions.skaven_clan_rat.first_attack.difficulty_damage.survival_hardest = {
							22.5,
							12,
							6
						}

	BreedActions.skaven_clan_rat.running_attack.difficulty_damage.survival_hardest = {
							22.5,
							12,
							6
						}


	BreedActions.skaven_clan_rat.normal_attack.difficulty_damage.survival_hardest = {
							22.5,
							12,
							6
						}


	BreedActions.skaven_gutter_runner.target_pounced.difficulty_damage.survival_hardest = {
							7.5,
							3,
							0.75
						}

	BreedActions.skaven_rat_ogre.melee_slam.difficulty_damage.survival_hardest = {
							60,
							30,
							22.5
						}

	BreedActions.skaven_rat_ogre.melee_slam.blocked_difficulty_damage.survival_hardest = {
							18,
							15,
							11.25
						}

	BreedActions.skaven_rat_ogre.melee_shove.difficulty_damage.survival_hardest = {
							90,
							75,
							75
						}

	BreedActions.skaven_storm_vermin.special_attack_sweep.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_sweep.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin.special_attack_cleave.difficulty_damage.survival_hardest = {
							150,
							75,
							45
						}

	BreedActions.skaven_storm_vermin_commander.special_attack_cleave.difficulty_damage.survival_hardest = {
							150,
							75,
							45
						}
	--LS Krench
	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.blocked_difficulty_damage.survival_hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.difficulty_damage.survival_hardest = {
							150,
							75,
							45
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.blocked_difficulty_damage.survival_hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.blocked_difficulty_damage.survival_hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_left.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_right.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.blocked_difficulty_damage.survival_hardest = {
							18,
							15,
							11.25
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.blocked_difficulty_damage.survival_hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.blocked_difficulty_damage.survival_hardest = {
							18,
							15,
							11.25
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.blocked_difficulty_damage.survival_hardest = {
							18,
							15,
							11.25
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.difficulty_damage.survival_hardest = {
							75,
							45,
							30
						}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.survival_hardest = {
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin"
						}
	--End LS Krench
	--End Last Stand
	--Krench
	Breeds.skaven_storm_vermin_champion.max_health[5] = 800

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.blocked_difficulty_damage.hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_cleave.difficulty_damage.hardest = {
							100,
							50,
							30
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.blocked_difficulty_damage.hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.blocked_difficulty_damage.hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_left.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_sweep_right.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.blocked_difficulty_damage.hardest = {
							12,
							10,
							7.5
						}

	BreedActions.skaven_storm_vermin_champion.special_lunge_attack.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.blocked_difficulty_damage.hardest = {
							10,
							10,
							10
						}

	BreedActions.skaven_storm_vermin_champion.special_running_attack.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.blocked_difficulty_damage.hardest = {
							12,
							10,
							7.5
						}

	BreedActions.skaven_storm_vermin_champion.special_attack_shatter.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.blocked_difficulty_damage.hardest = {
							12,
							10,
							7.5
						}

	BreedActions.skaven_storm_vermin_champion.defensive_attack_shatter.difficulty_damage.hardest = {
							50,
							30,
							20
						}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.hardest = {
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin",
							"skaven_storm_vermin"
						}
	--End Krench

	AttackDamageValues.ratlinggun_very_hard = { 3, 0.5, 4, 2 }
	BreedActions.skaven_ratling_gunner.shoot_ratling_gun.attack_template_damage_type[4] = "ratlinggun_very_hard"

	DifficultySettings.hardest.amount_storm_vermin_patrol = 20

	Mods.hook.enable(false, "Gamemodes", "PlayerUnitHealthExtension._knock_down")

	Mods.hook.enable(false, "Gamemodes", "DamageUtils.add_damage_network")

	Mods.hook.enable(false, "Gamemodes", "RespawnHandler.update")


	if not onslaughttoken then
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
		Managers.chat:send_system_chat_message(1, "Deathwish difficulty DISABLED.", 0, true)
	else
		EchoConsole("Deathwish difficulty DISABLED.")
	end
end
