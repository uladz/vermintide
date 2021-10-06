local mod_name = "NoLobbyFix"

Mods.hook.set(mod_name, "LobbyInternal.get_lobby", function(func, lobby_browser, index)
	local lobby_data = lobby_browser:lobby(index)
	local lobby_data_all = lobby_browser:data_all(index)
	lobby_data_all.id = lobby_data.id
	local formatted_lobby_data = {}

	for key, value in pairs(lobby_data_all) do
		formatted_lobby_data[string.lower(key)] = value
	end

	return formatted_lobby_data
end)