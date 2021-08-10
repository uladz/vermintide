local mod_name = "DisconnectionResilience"

if not network_disconnect_token then
	network_disconnect_token = false
end

if not backend_disconnect_token then
	backend_disconnect_token = false
end

if not backend_reconnect_token then
	backend_reconnect_token = false
end

if not RESILIENCE_DISCONNECTED_PEERS then
	RESILIENCE_DISCONNECTED_PEERS = {}
end

local RPC_DISCO_RESIL_DISCONNECTED = "rpc_disco_resil_disconnected"

Mods.hook.set(mod_name, "StateIngame.connected_to_network", function (func, self)
	local result, err = pcall(func, self)
	if result == false and not network_disconnect_token then
		network_disconnect_token = true
		script_data.disable_gamemode_end = true
		EchoConsole("DisconnectionResilience : Lost connection to the network.")
		if not Managers.player.is_server then
			Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, true)
		end
	end
	if result == true and network_disconnect_token then
		network_disconnect_token = false
		if not backend_disconnect_token then
			script_data.disable_gamemode_end = false
			if Managers.state.debug.time_paused and Managers.player.is_server then
				Managers.state.debug.set_time_scale(Managers.state.debug, Managers.state.debug.time_scale_index)
			end

			if not Managers.player.is_server then
				Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, false)
			end
		end
		EchoConsole("DisconnectionResilience : Regained connection to the network.")
	end
	return true
end)

Mods.hook.set(mod_name, "BackendManager._update_error_handling", function (func, self)
	return
end)

Mods.hook.set(mod_name, "BackendManager._destroy_backend", function (func, self)
	return
end)

Mods.hook.set(mod_name, "BackendManager._post_error", function (func, ...)
	return
end)

Mods.hook.set(mod_name, "ProgressionUnlocks.is_unlocked", function (func, unlock_name, level)
	if (network_disconnect_token or backend_disconnect_token) and (unlock_name == "forge" or unlock_name == "altar" or unlock_name == "quests") then
		return
	end
	
	return func(unlock_name, level)		
end)

Mods.hook.set(mod_name, "InteractionDefinitions.forge_access.client.can_interact", function (func, ...)
	local experience = ScriptBackendProfileAttribute.get("experience")
	if experience == -1 or network_disconnect_token or backend_disconnect_token then
		return false
	end
	return func(...)
end)

Mods.hook.set(mod_name, "InteractionDefinitions.altar_access.client.can_interact", function (func, ...)
	local experience = ScriptBackendProfileAttribute.get("experience")
	if experience == -1 or network_disconnect_token or backend_disconnect_token then
		return false
	end
	return func(...)
end)

Mods.hook.set(mod_name, "InteractionDefinitions.quest_access.client.can_interact", function (func, ...)
	local experience = ScriptBackendProfileAttribute.get("experience")
	if experience == -1 or network_disconnect_token or backend_disconnect_token then
		return false
	end
	return func(...)
end)

local laststate = "connection_entities_loaded"
Mods.hook.set(mod_name, "ScriptBackend.update", function (func, ...)
	local CONNECTION_STATE_NAMES = {}
	CONNECTION_STATE_NAMES[Backend.CONNECTION_UNINITIALIZED] = "connection_uninitialized"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_INITIALIZED] = "connection_initialized"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_CONNECTING] = "connection_connecting"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_CONNECTED] = "connection_connected"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_WAITING_AUTH_TICKET] = "connection_waiting_auth_ticket"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_AUTHENTICATING] = "connection_authenticating"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_AUTHENTICATED] = "connection_authenticated"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_DISCONNECTING] = "connection_disconnecting"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_ENTITIES_LOADED] = "connection_entities_loaded"
	CONNECTION_STATE_NAMES[Backend.CONNECTION_ERROR] = "connection_error"
	local state = CONNECTION_STATE_NAMES[Backend.state()]
	if state ~= laststate then
		if state ~= "connection_initialized" then
			local status, err = pcall(EchoConsole, state)
		end
		laststate = state
	end

	if state == "connection_entities_loaded" and backend_disconnect_token then
		backend_disconnect_token = false
		backend_reconnect_token = false
		if not network_disconnect_token then
			script_data.disable_gamemode_end = false
			if Managers.state.debug and Managers.state.debug.time_paused and Managers.player.is_server then
				Managers.state.debug.set_time_scale(Managers.state.debug, Managers.state.debug.time_scale_index)
			end

			if Managers.player and not Managers.player.is_server and Managers.state.debug then
				Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, false)
			end
		end
		local status, err = pcall(EchoConsole, "DisconnectionResilience : Regained connection to the backend.")
	end

	if state == "connection_connecting" then
		backend_reconnect_token = false
	end

	if state == "connection_initialized" then
		if not backend_disconnect_token then
			local status, err = pcall(EchoConsole, "DisconnectionResilience : Lost connection to the backend.")
			backend_disconnect_token = true
			script_data.disable_gamemode_end = true

			if not Managers.player.is_server and Managers.state.debug then
				Mods.network.send_rpc_server(RPC_DISCO_RESIL_DISCONNECTED, true)
			end
		end
		if not backend_reconnect_token and not network_disconnect_token then
			local status, err = pcall(EchoConsole, "DisconnectionResilience : Attempting reconnection to the backend.")
			if err == nil then
				backend_reconnect_token = true
				Managers.backend = BackendManager:new()
				Managers.backend:signin()
			end
		end
	end

	local peer_is_disconnected = false

	for peer, bool in pairs(RESILIENCE_DISCONNECTED_PEERS) do
		if Managers.player:players_at_peer(peer) == nil then
			RESILIENCE_DISCONNECTED_PEERS[peer] = nil
			bool = false
		end		

		if bool then
			peer_is_disconnected = true
		end
	end

	if peer_is_disconnected then
		script_data.disable_gamemode_end = true
	elseif not network_disconnect_token and not backend_disconnect_token then
		script_data.disable_gamemode_end = false

		if Managers.state.debug and Managers.state.debug.time_paused and Managers.player.is_server then
			Managers.state.debug.set_time_scale(Managers.state.debug, Managers.state.debug.time_scale_index)
		end
	end

	return func(...)
end)

Mods.hook.set(mod_name, "GameModeManager.complete_level", function (func, self)
	func(self)
	if script_data.disable_gamemode_end and Managers.state.game_mode._game_mode_key ~= "inn" then
		Managers.chat:send_system_chat_message(1, "DisconnectionResilience : Victory was achieved. Freezing game state until connection to the network and backend is reestablished for all players.", 0, true)
		Managers.state.debug.set_time_paused(Managers.state.debug)
	end
end)

if not FAILURE_WAS_ANNOUNCED then
	FAILURE_WAS_ANNOUNCED = false
end
if not FAILURE_TIMESTAMP then
	FAILURE_TIMESTAMP = 0
end
Mods.hook.set(mod_name, "GameModeAdventure.evaluate_end_conditions", function(func, self, round_started, dt, t)
	if not script_data.disable_gamemode_end then
		FAILURE_WAS_ANNOUNCED = false
		FAILURE_TIMESTAMP = 0
		return func(self, round_started, dt, t)
	end

	local spawn_manager = Managers.state.spawn
	local humans_dead = spawn_manager.all_humans_dead(spawn_manager)
	local level_failed = self._level_failed

	if (humans_dead or level_failed) and not FAILURE_WAS_ANNOUNCED then
		Managers.chat:send_system_chat_message(1, "DisconnectionResilience : You were defeated. Freezing game state until connection to the network and backend is reestablished for all players.", 0, true)
		FAILURE_WAS_ANNOUNCED = true
		FAILURE_TIMESTAMP = t
	end

	if FAILURE_WAS_ANNOUNCED and not Managers.state.debug.time_paused then
		if t - 3 > FAILURE_TIMESTAMP then
			Managers.state.debug.set_time_paused(Managers.state.debug)
		end
	end

	return false
end)

Mods.hook.set(mod_name, "GameModeSurvival.evaluate_end_conditions", function(func, self, round_started, dt, t)
	if not script_data.disable_gamemode_end then
		FAILURE_WAS_ANNOUNCED = false
		FAILURE_TIMESTAMP = 0
		return func(self, round_started, dt, t)
	end

	local spawn_manager = Managers.state.spawn
	local humans_dead = spawn_manager.all_humans_dead(spawn_manager)
	local level_failed = self._level_failed

	if (humans_dead or level_failed) and not FAILURE_WAS_ANNOUNCED then
		Managers.chat:send_system_chat_message(1, "DisconnectionResilience : You were defeated. Freezing game state until connection to the network and backend is reestablished for all players.", 0, true)
		FAILURE_WAS_ANNOUNCED = true
		FAILURE_TIMESTAMP = t
	end

	if FAILURE_WAS_ANNOUNCED and not Managers.state.debug.time_paused then
		if t - 3 > FAILURE_TIMESTAMP then
			Managers.state.debug.set_time_paused(Managers.state.debug)
		end
	end

	return false
end)

Mods.network.register(RPC_DISCO_RESIL_DISCONNECTED, function(sender_id, peer_is_disconnected)
	local player = Managers.player:player_from_peer_id(sender_id, 1)
	local player_name = player._cached_name

	if peer_is_disconnected and not RESILIENCE_DISCONNECTED_PEERS[sender_id] then
		EchoConsole("DisconnectionResilience : Player '" .. player_name .. "' has been disconnected from the game network.")
	elseif not peer_is_disconnected and RESILIENCE_DISCONNECTED_PEERS[sender_id] then
		EchoConsole("DisconnectionResilience : Player '" .. player_name .. "' has been reconnected to the game network.")
	end

	RESILIENCE_DISCONNECTED_PEERS[sender_id] = peer_is_disconnected	

	for peer_id, is_dc in pairs(RESILIENCE_DISCONNECTED_PEERS) do
		if Managers.player:players_at_peer(peer_id) == nil then
			RESILIENCE_DISCONNECTED_PEERS[peer_id] = nil
		end
	end
end)