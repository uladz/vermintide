local mod_name = "Ban"
--[[
	Ban:
		This allows you to ban players that keeps annoying you.
--]]

local check_time = 0
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	-- Call orginal function
	func(self, dt, t)

	if Managers.player.is_server then -- can only ban when server
		if t - check_time > 1 then -- check once ever second to ban
			Mods.ban.check_players()

			check_time = t
		end
	end
end)

Mods.hook.set(mod_name, "MatchmakingManager.rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, host_cookie, lobby_id, friend_join)
	local id = self.lobby:id()
	id = tostring(id)
	lobby_id = tostring(lobby_id)
	local reply = "lobby_ok"
	local lobby_id_match = (LobbyInternal.lobby_id_match and LobbyInternal.lobby_id_match(id, lobby_id)) or id == lobby_id
	local is_game_mode_ended = (Managers.state.game_mode and Managers.state.game_mode:is_game_mode_ended()) or false
	local is_searching_for_players = self._state.NAME == "MatchmakingStateSearchPlayers" or self._state.NAME == "MatchmakingStateIngame"
	local handshaker_host = self.handshaker_host
	local valid_cookies = (handshaker_host and handshaker_host.validate_cookies(handshaker_host, sender, client_cookie, host_cookie)) or false

	-- get the peer_id out of the client_cookie
	local peer_id = tostring(client_cookie)
	for i=1,3 do
		peer_id = string.sub(peer_id, 1 + tonumber(tostring(string.find(peer_id,"-"))))
	end
	peer_id=string.sub(peer_id, 2)
	peer_id = string.reverse(peer_id)
	peer_id = string.sub(peer_id, 2)
	peer_id = string.reverse(peer_id)

	if not lobby_id_match then
		reply = "lobby_id_mismatch"
	elseif is_game_mode_ended then
		reply = "game_mode_ended"
	elseif not friend_join and not is_searching_for_players then
		reply = "not_searching_for_players"
	elseif not valid_cookies then
		reply = "obsolete_request"
	end

	for _, ban_player in ipairs(Mods.ban.list) do
		if ban_player.peer_id == peer_id then
			reply = "not_searching_for_players"

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

			Managers.chat:send_chat_message(1, "You have been banned from this lobby. This is an automated message.")

			Managers.chat.channels[1].members_func = original_member_func
		end
	end

	local reply_id = NetworkLookup.game_ping_reply[reply]

	self.network_transmit:send_rpc("rpc_matchmaking_request_join_lobby_reply", sender, client_cookie, host_cookie, reply_id)

	return
end)

local function is_kicked(peer_id)
	if Mods.ban.kicked.peer_id and Mods.ban.kicked.peer_id == tostring(peer_id) and Mods.ban.kicked.kicking_time and Managers.state.network:network_time() - Mods.ban.kicked.kicking_time > 3 then
		Mods.ban.kicked.kicking_time = nil
		return true
	end
	return false
end

local new_connections = {}

-- added "or is_kicked(peer_id)" and commented out the ch_printf and kicking_time reset
Mods.hook.set(mod_name, "ConnectionHandler.update", function(func, self, dt)

	table.clear(new_connections)

	local num_new_connections = 0
	local pending_connects = self.pending_connects
	local current_connections = self.current_connections
	local connected_value = self.last_connected_value - 3

	for peer_id, _ in pairs(pending_connects) do
		if Network.has_connection(peer_id) and not Network.is_broken(peer_id) then
			pending_connects[peer_id] = nil
			current_connections[peer_id] = connected_value

			self.update_peer(self, peer_id, PeerConnectionState.Connected)
		end
	end

	local pending_disconnects = self.pending_disconnects

	for peer_id, _ in pairs(pending_disconnects) do
		if not Network.is_used(peer_id) then
			if Network.has_connection(peer_id) then
				Network.destroy_connection(peer_id)
			end

			if Mods.ban.kicked.peer_id and Mods.ban.kicked.peer_id == tostring(peer_id) then -- added
				Mods.ban.kicked.kicking_time = nil
			end

			pending_disconnects[peer_id] = nil
			current_connections[peer_id] = nil

			self.update_peer(self, peer_id, PeerConnectionState.Disconnected)
		end
	end

	local running_connections = Network.connections()

	for i, peer_id in ipairs(running_connections) do
		if not Network.is_broken(peer_id) then
			if not current_connections[peer_id] and not pending_connects[peer_id] then
				num_new_connections = num_new_connections + 1
				new_connections[num_new_connections] = peer_id

				self.update_peer(self, peer_id, PeerConnectionState.Connecting)

				pending_connects[peer_id] = connected_value
			else
				current_connections[peer_id] = connected_value
			end
		end
	end

	local peer_states = self.peer_states
	local broken_connections = self.broken_connections
	local num_broken_connections = self.num_broken_connections

	for peer_id, peer_connected_value in pairs(current_connections) do
		if Network.is_broken(peer_id) or is_kicked(peer_id) then -- added "or is_kicked(peer_id)"
			if peer_states[peer_id] ~= PeerConnectionState.Broken then
				-- ch_printf("Peer %q is now broken.", peer_id)
				self.update_peer(self, peer_id, PeerConnectionState.Broken)
			end

			num_broken_connections = num_broken_connections + 1
			broken_connections[num_broken_connections] = peer_id
			current_connections[peer_id] = nil
			self.pending_disconnects[peer_id] = true
		elseif not Network.is_used(peer_id) then
			-- ch_printf("Destroying connection to peer %q since it's not used.", peer_id)
			Network.destroy_connection(peer_id)

			current_connections[peer_id] = nil
			num_broken_connections = num_broken_connections + 1
			broken_connections[num_broken_connections] = peer_id
		else
			assert(connected_value == peer_connected_value)
		end
	end

	self.num_broken_connections = num_broken_connections
	self.last_connected_value = connected_value

	return new_connections, num_new_connections
end)

Mods.hook.set(mod_name, "IngamePlayerListUI.update", function(func, self, dt)
	-- Call orginal function
	func(self, dt)

	-- Kick
	if self.active then
		local players = self.players
		if Managers.player.is_server then -- can only kick when server
			for i, player in ipairs(players) do
				if player.peer_id ~= Network.peer_id() then -- can't kick yourself
					local content = self.player_list_widgets[i].content
					content.show_kick_button = true
					content.kick_button_hotspot.disable_button = false
					if content.kick_button_hotspot.input_pressed then -- button was pressed
						Managers.state.network.network_transmit:send_rpc("rpc_kick_peer", player.peer_id)
						content.kick_button_hotspot.input_pressed = false

						if Mods.ban then
							-- Save last player that has been kicked
							Mods.ban.kicked.peer_id = tostring(player.peer_id)
							Mods.ban.kicked.name = tostring(player.widget.content.name)
							Mods.ban.kicked.kicking_time = Managers.state.network:network_time()
						end
					end
				end
			end
		end
	end
end)