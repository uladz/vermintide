Mods.ban = {
	filename = "Ban_list",
	
	list = {},
	
	-- Last player kicked
	kicked = {
		peer_id = "",
		name = "",
	},
}

local ban_player_template = {
	peer_id = "",
	name = "",
}

--
-- Add Player to ban list
--
Mods.ban.add_player = function(peer_id, name)
	if peer_id ~= Network.peer_id() then -- can't ban yourself
		if not Mods.ban.exist(peer_id) then -- can't ban players twice
			local ban_player = table.clone(ban_player_template)
			
			ban_player.peer_id = tostring(peer_id)
			ban_player.name = name
			
			-- insert player into ban list
			table.insert(Mods.ban.list, ban_player)
			
			-- Save Ban list
			Mods.ban.save()
		end
	end
end

--
-- Check Player is already banned
--
Mods.ban.exist = function(peer_id)
	for _, player in ipairs(Mods.ban.list) do
		if player.peer_id == tostring(peer_id) then
			return true
		end
	end
	
	return false
end

--
-- Save ban list
--
Mods.ban.save = function()
	local file_path = "mods/patch/storage/" .. Mods.ban.filename .. ".lua"
	
	local file = io.open(file_path, "w+")
	if file ~= nil then
		file:write("Mods.ban.list = {\n")
		
		for _, player in ipairs(Mods.ban.list) do
			file:write("	{\n")
			file:write("		peer_id = \"" .. player.peer_id .. "\",\n")
			file:write("		name = \"" .. player.name .. "\",\n")
			file:write("	},\n")
		end
		
		file:write("}\n")
		file:close()
	end
end

--
-- Load ban list
--
Mods.ban.load = function()
	Mods.exec("patch/storage", Mods.ban.filename)
end

--
-- Check players how needs to get banned
--
Mods.ban.check_players = function()
	local human_players = Managers.player:human_players()
		
	for _, player in pairs(human_players) do
		for _, ban_player in ipairs(Mods.ban.list) do
			if ban_player.peer_id == tostring(player.peer_id) then
				EchoConsole("Automatically kicked " .. ban_player.name .. " because player is banned.")
				Managers.state.network.network_transmit:send_rpc("rpc_kick_peer", player.peer_id)
			end
		end
	end
end

-- Load ban list
Mods.ban.load()
