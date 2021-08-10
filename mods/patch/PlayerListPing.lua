local mod_name = "PlayerListPing"

Mods.PlayerListPing = {}

local me = Mods.PlayerListPing

Mods.hook.set(mod_name, "IngamePlayerListUI.update_player_information", function(func, self)
	-- Call orginal function
	func(self)
	
	local players = self.players
	local client_self_ping = 0

	if not Managers.player:local_player().is_server then
		for _, player in ipairs(players) do
			if player.is_server then
				client_self_ping = round(Network.ping(player.peer_id) * 1000, 0)
			end
		end
	end

	for _, player in ipairs(players) do
		local ping = 0
		local widget = player.widget
		
		if Managers.player:local_player().is_server then
			ping = round(Network.ping(player.peer_id) * 1000, 0)
		elseif player.peer_id == Network.peer_id() then
			ping = client_self_ping
		end
		
		-- other pings get from ping list
		if me[player.peer_id] ~= nil and me[player.peer_id] ~= 0 and player.peer_id ~= Network.peer_id() then
			ping = me[player.peer_id]
		end
		
		if ping ~= 0 then -- server get server ping results to ping 0
			widget.content.name = widget.content.name .. " (" .. tostring(ping) .. ")"
		end
	end
	
end)

local send_ping_t = 0
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	func(self, dt, t)
	
	-- Update Ping list
	if Managers.player.is_server then -- Server manage the ping list
		if t - send_ping_t > 2 then -- Once every 2 seconds the ping list updates
			local players = Managers.player:human_players()
			
			-- Update player ping
			for _, player in pairs(players) do
				me[player.peer_id] = round(Network.ping(player.peer_id) * 1000, 0)
			end
			
			-- Send ping list to all clients
			Mods.network.send_rpc_clients("rpc_playerlist_set_pings", me)
			
			send_ping_t = t
		end
	end
end)

-- Network
Mods.network.register("rpc_playerlist_set_pings", function(sender, ping_list)
	-- Only clients need the ping list
	if not Managers.player.is_server then
		me = ping_list
	end
end)