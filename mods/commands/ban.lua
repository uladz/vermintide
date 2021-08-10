if Mods.ban.kicked.peer_id ~= "" then
	if Mods.ban.exist(Mods.ban.kicked.peer_id) then
		EchoConsole("Player " .. Mods.ban.kicked.name .. " is already banned.")
		return
	end

	Mods.ban.add_player(Mods.ban.kicked.peer_id, Mods.ban.kicked.name)
	
	-- Confirmation message
	EchoConsole("Banned player " .. Mods.ban.kicked.name .. ".")
else
	EchoConsole("There are no recently kicked players to ban.")
end