local mod_name = "CheatProtect"

--#### Item Spawning #######################

local NoCheatItemCount = {
	itemcount = -1,
	sender = nil
}

local NoCheatPosition = nil

local NoCheatTrade = {}

Mods.hook.set(mod_name, "InventorySystem.rpc_add_equipment",
function(func, self, sender, go_id, slot_id, item_name_id)
	func(self, sender, go_id, slot_id, item_name_id)
	if slot_id == 7 or slot_id == 8 or slot_id == 9 then
		local unit_storage = Managers.state.unit_spawner.unit_storage
		local items = unit_storage.map_goid_to_unit
		local count = 0
	
		for go_id, unit in pairs(items) do
			count = count + 1
		end

		NoCheatItemCount.itemcount = count
		NoCheatItemCount.sender = sender
		local player = Managers.player:player_from_peer_id(sender, 1)
		NoCheatPosition = POSITION_LOOKUP[player.player_unit]

		local is_a_trade = false
		if NoCheatTrade[sender] then
			local item_name = NetworkLookup.item_names[item_name_id]
			local item_data = ItemMasterList[item_name]
			if BackendUtils.get_item_template(item_data).pickup_data then
				local pickup_name = BackendUtils.get_item_template(item_data).pickup_data.pickup_name
				local pickup_name_id = NetworkLookup.pickup_names[pickup_name]
				for i, item in pairs(NoCheatTrade[sender]) do
					if item == pickup_name_id and not is_a_trade then
						is_a_trade = true
						NoCheatTrade[sender][i] = nil
					end
				end
			end
		end
	end
end)

Mods.hook.set(mod_name, "PickupSystem.rpc_spawn_pickup",
function(func, self, sender, pickup_name_id, position, rotation, spawn_type_id)
	local player = Managers.player:player_from_peer_id(sender, 1)

	local unit_storage = Managers.state.unit_spawner.unit_storage
	local items = unit_storage.map_goid_to_unit
	local count = 0
	
	for go_id, unit in pairs(items) do
		count = count + 1
	end

	if not (sender == Network.peer_id() or (count == NoCheatItemCount.itemcount and sender == NoCheatItemCount.sender)) then
		Managers.chat:send_system_chat_message(1, "CheatProtect : Blocked player '" .. player._cached_name .. "' attempted RPC_SPAWN_PICKUP (without physics) for item " .. NetworkLookup.pickup_names[pickup_name_id] .. ".", 0, true)
		return
	end
	func(self, sender, pickup_name_id, position, rotation, spawn_type_id)
end)

Mods.hook.set(mod_name, "PickupSystem.rpc_spawn_pickup_with_physics",
function(func, self, sender, pickup_name_id, position, rotation, spawn_type_id)
	local player = Managers.player:player_from_peer_id(sender, 1)
	if Unit.alive(player.player_unit) then
		local status_extension = ScriptUnit.extension(player.player_unit, "status_system")
		local position = POSITION_LOOKUP[player.player_unit]
		local is_a_trade = false
		
		if NoCheatTrade[sender] then
			for i, item in pairs(NoCheatTrade[sender]) do
				if item == pickup_name_id and not is_a_trade then
					is_a_trade = true
					NoCheatTrade[sender][i] = nil
				end
			end
		end

		if not (sender == Network.peer_id() or (status_extension and status_extension.dead) or (position == NoCheatPosition) or (is_a_trade)) then
			Managers.chat:send_system_chat_message(1, "CheatProtect : Blocked player '" .. player._cached_name .. "' attempted RPC_SPAWN_PICKUP_WITH_PHYSICS for item " .. NetworkLookup.pickup_names[pickup_name_id] .. ".", 0, true)
			return
		end
	end
	func(self, sender, pickup_name_id, position, rotation, spawn_type_id)
end)

Mods.hook.set(mod_name, "InventorySystem.rpc_give_equipment",
function(func, self, sender, game_object_id, slot_id, item_name_id, position)
	func(self, sender, game_object_id, slot_id, item_name_id, position)
	local unit = self.unit_storage:unit(game_object_id)
	if Unit.alive(unit) and not ScriptUnit.extension(unit, "status_system"):is_dead() then
		local owner = Managers.player:owner(unit)
		if owner.remote then
			local item_name = NetworkLookup.item_names[item_name_id]
			local item_data = ItemMasterList[item_name]
			local pickup_name = BackendUtils.get_item_template(item_data).pickup_data.pickup_name
			local pickup_name_id = NetworkLookup.pickup_names[pickup_name]
			local victim = owner.network_id(owner)

			if not NoCheatTrade[victim] then
				NoCheatTrade[victim] = {}
			end

			NoCheatTrade[victim][#NoCheatTrade[victim] + 1] = pickup_name_id
		end
	end
end)

Mods.hook.set(mod_name, "GameNetworkManager.game_object_created", function(func, self, go_id, owner_id)
	local go_type_id = GameSession.game_object_field(self.game_session, go_id, "go_type")
	local go_type = NetworkLookup.go_types[go_type_id]

	if tostring(go_type) == "pickup_unit" and owner_id ~= Network.peer_id() and Managers.player.is_server then
		local player = Managers.player:player_from_peer_id(owner_id, 1)
		local item_name_id = GameSession.game_object_field(Managers.state.network:game(), go_id, "pickup_name")
		local item_name = NetworkLookup.pickup_names[item_name_id]

		Managers.chat:send_system_chat_message(1, "CheatProtect : Blocked player '" .. player._cached_name .. "' attempted spawning non-owned item '" .. item_name .. "'. This is an advanced anti-cheat bypass attempt, immediate removal of the player is recommended.", 0, true)
		return
	end

	func(self, go_id, owner_id)
end)

--#### Heal Requests #######################

Mods.hook.set(mod_name, "DamageSystem.rpc_request_heal",
function(func, self, sender, unit_go_id, heal_amount, heal_type_id)
	local player = Managers.player:player_from_peer_id(sender, 1)
	local heal_type = NetworkLookup.heal_types[heal_type_id]
	local unit = self.unit_storage:unit(unit_go_id)
	local health_extension = ScriptUnit.extension(unit, "health_system")
	local current_damage = health_extension.current_damage(health_extension)

	if (heal_amount > 120 and heal_type ~= "buff") 
	or (heal_type == "bandage" and heal_amount ~= round(current_damage * 0.8, 3))
	or (heal_type == "proc" and heal_amount ~= 5 and heal_amount ~= 10 and heal_amount ~= 40) 
	or (heal_type == "healing_draught" and heal_amount ~= 75) 
	or (heal_type == "bandage_trinket" and heal_amount > round(current_damage * 0.2, 3))
	or (heal_type == "potion" or heal_type == "buff_shared_medpack" or heal_type == "heal_on_killing_blow")
	or (heal_type == "buff" and (heal_amount ~= 150 and heal_amount ~= 100))
	or (heal_type == "buff" and Managers.state.game_mode._game_mode_key ~= "inn") then 
		Managers.chat:send_system_chat_message(1, "CheatProtect : Blocked player '" .. player._cached_name .. "' attempted heal for " .. heal_amount .. " with heal type " .. heal_type .. ".", 0, true)
		return
	end

	func(self, sender, unit_go_id, heal_amount, heal_type_id)
	return
end)


--#### Teleport protection ##################

Mods.hook.set(mod_name, "LocomotionSystem.rpc_teleport_unit_to", function(func, self, sender, game_object_id, position, rotation)
	local local_player = Managers.player:local_player()
	local target_unit = self.unit_storage:unit(game_object_id)
	local player = Managers.player:player_from_peer_id(sender, 1)
	
	-- Server can not get this rpc call
	-- Nobody can teleport you to a different position
	if Managers.player.is_server or (target_unit and local_player and local_player.player_unit == target_unit) then
		local victim_name = "UNKNOWN"
		for _, player in pairs(Managers.player:human_players()) do
			if player.player_unit == target_unit then
				victim_name = player._cached_name
			end
		end

		if Managers.player.is_server then
			Managers.chat:send_system_chat_message(1, "CheatProtect : Blocked player '" .. player._cached_name .. "' attempted RPC_TELEPORT_UNIT_TO on '" .. victim_name .. "'.", 0, true)
		else
			Managers.chat:send_system_chat_message(1, "CheatProtect [By " .. local_player._cached_name .. "] : Blocked player '" .. player._cached_name .. "' attempted RPC_TELEPORT_UNIT_TO on '" .. victim_name .. "'.", 0, true)
		end
		return
	end
	
	func(self, sender, game_object_id, position, rotation)
end)

--#### Chat impersonation ###################
Mods.hook.set(mod_name, "ChatManager.rpc_chat_message",
function(func, self, sender, channel_id, message_sender, message, localization_param, is_system_message, pop_chat, is_dev)
	if Managers.player.is_server then
		--[[
			If someone sends a message is a different peer_id
		--]]
		if sender ~= message_sender then
			local player = Managers.player:player_from_peer_id(sender, 1)
			local victim = Managers.player:player_from_peer_id(message_sender, 1)
			
			if player and victim then
				-- Cheater Detected
				Managers.chat:send_system_chat_message(1, "CheatProtect : Blocked player '" .. player._cached_name .. "' attempted chat impersonation of player '" .. victim._cached_name .. "'.", 0, true)
				return
			end
		end
	else
		--[[
			If someone sends a rpc_chat_message with message_sender as our peer_id
			it needs to be reported.
			The case is, people send message as a proxy through the server,
			This means the "sender" parameter is always the server peer_id. We can
			not know for sure who it officially sended the orginal message.
		--]]
		local local_player = Managers.player:local_player()
		
		if local_player and local_player.peer_id == message_sender then
			-- Cheater Detected
			Managers.chat:send_system_chat_message(1, "CheatProtect [By " .. local_player._cached_name .. "] : The above message by " .. local_player._cached_name .. " was not sent by that player, but by an impersonator in the lobby.", 0, true)
		end
	end
	
	func(self, sender, channel_id, message_sender, message, localization_param, is_system_message, pop_chat, is_dev)
end)

--#### Illegitimate Endurance Badges and Grimoires #######################
 
--[[ Assumptions:
    For a host with CheatProtect, illegitimate endurance badges spawned by clients are impossible.
    For a host with CheatProtect, illegitimate grimoires added by clients are impossible.
    No wave completion at or past 300 is legitimate.
    Number of legitimate endurance badges earned will never exceed 1/2 of waves completed.
    On Cataclysm difficulty and higher, no more than 5 grimoires are potentially legal.
    On Nightmare difficulty and lower, no more than 3 grimoires are potentially legal.
--]]
 
local endurance_mission_names = {
    endurance_badge_01_mission = true,
    endurance_badge_02_mission = true,
    endurance_badge_03_mission = true,
    endurance_badge_04_mission = true,
    endurance_badge_05_mission = true
}
   
local function check_endurance_badge_missions(mission_system, ingame)
    local level_end_missions = mission_system.level_end_missions
    local caught_dangerous_action = false
   
    -- Check for endurance badges outside of survival mode
    if level_end_missions and not level_end_missions["survival_wave"] then
        for mission_name, _ in pairs(endurance_mission_names) do
            if level_end_missions[mission_name] then
                level_end_missions[mission_name].evaluate_at_level_end = false
                level_end_missions[mission_name].current_amount = 0
               
                caught_dangerous_action = true
            end
        end
       
    -- Check for too many endurance badges inside survival mode
    elseif level_end_missions and level_end_missions["survival_wave"] then
        local waves_completed = level_end_missions["survival_wave"].wave_completed or 0
       
        -- Sanity-check waves completed (prevents inflated numbers to bypass badge limit)
        if waves_completed >= 300 then
            level_end_missions["survival_wave"].wave_completed = 1
            level_end_missions["survival_wave"].text = "Wave 1 Completed"
            waves_completed = 1
           
            if not ingame then
                EchoConsole("CheatProtect: Blocked attempt by a lobby player to inflate number of completed waves for your account. Such attempts can permanently affect account progression.")
            else
		local local_player = Managers.player:local_player()
                Managers.chat:send_system_chat_message(1, "CheatProtect [By " .. local_player._cached_name .. "] : Lobby likely has inflated number of waves completed. Leave now or risk permanent alteration of your account progression.", 0, true)
            end
        end
       
        for mission_name, _ in pairs(endurance_mission_names) do
            if level_end_missions[mission_name] then
                local badges_collected = level_end_missions[mission_name].current_amount
               
                -- EchoConsole("[Debug] badges_collected: "..tostring(badges_collected)..", waves_completed: "..tostring(waves_completed)..", half of waves: "..tostring((waves_completed / 2))..", comparison: "..tostring((badges_collected > (waves_completed / 2))))
               
                if badges_collected and (badges_collected > (waves_completed / 2)) then
                    level_end_missions[mission_name].evaluate_at_level_end = false
                    level_end_missions[mission_name].current_amount = 0
                   
                    caught_dangerous_action = true
                end
            end
        end
    end
   
    -- Warn the player / lobby
    if caught_dangerous_action then
        if not ingame then
            EchoConsole("CheatProtect: Blocked attempt by a lobby player to flood your account with illegitimate endurance badges. Such attempts can permanently affect account progression.")
        else
	    local local_player = Managers.player:local_player()
            Managers.chat:send_system_chat_message(1, "CheatProtect [By " .. local_player._cached_name .. "] : Lobby has spawned illegitimate endurance badges. Leave now or risk permanent alteration of your account progression.", 0, true)
        end
    end
end
 
local function check_grimoire_missions(mission_system)
    local active_missions = mission_system.active_missions
    local grimoire_mission = active_missions["grimoire_hidden_mission"]
    local rank = Managers.state.difficulty:get_difficulty_rank()
   
    -- Check for illegal number of grimoires (accounting for onslaught / deathwish)
    if grimoire_mission then
        --EchoConsole("Difficulty: " .. tostring(rank) .. ", Grimoire Count: " .. tostring(grimoire_mission.current_amount))
        if rank == 5 and grimoire_mission.current_amount > 5 then
            EchoConsole("CheatProtect: Blocked attempt by a lobby player to add illegitimate grimoires. Such attempts can permanently affect your account progression.")
            grimoire_mission.current_amount = 0
        elseif rank < 5 and grimoire_mission.current_amount > 3 then
            EchoConsole("CheatProtect: Blocked attempt by a lobby player to add illegitimate grimoires. Such attempts can permanently affect your account progression.")
            grimoire_mission.current_amount = 0
        end
    end
end
 
-- Protects the player at the endgame screen
Mods.hook.set(mod_name, "MissionSystem.evaluate_level_end_missions",
function(func, self, ...)
    check_endurance_badge_missions(self, false)
    check_grimoire_missions(self)
   
    func(self, ...)
    return
end)
 
-- Protects the player as a client, ingame
Mods.hook.set(mod_name, "MissionSystem.rpc_update_mission",
function(func, self, peer_id, mission_name_id, sync_data, ...)
    func(self, peer_id, mission_name_id, sync_data, ...)
   
    check_endurance_badge_missions(self, true)
    return
end)
 
-- Protects the player when survival game is counted as a loss, but illegal badges were acquired
Mods.hook.set(mod_name, "StateInGameRunning.gm_event_end_conditions_met",
function(func, self, reason, checkpoint_available, ...)
    local game_mode_key = Managers.state.game_mode:game_mode_key()
    local game_won = reason and reason == "won"
    if game_mode_key == "survival" and not game_won then
        local mission_system = Managers.state.entity:system("mission_system")
        check_endurance_badge_missions(mission_system, false)
    end
   
    func(self, reason, checkpoint_available, ...)
    return
end)