--[[
	Name: Player List Show Bots
	Author: VernonKun (presumably)
	Updated: 5/31/2021

	Mod which shows bots in the Player List screen alongside with real players.
--]]

local mod_name = "PlayerListShowBots"
local temp_players = {}

Mods.hook.set(mod_name, "IngamePlayerListUI.update_player_list", function(func, self)
	local player_manager = self.player_manager

	table.clear(temp_players)

	local update_widgets = false
	local players = self.players
	local num_players = self.num_players
	local removed_players = 0

	for i = num_players, 1, -1 do
		local data = players[i]
		local peer_id = data.peer_id
		local player = player_manager:player_from_peer_id(peer_id, data.local_player_id)

		if not player then
			table.remove(players, i)

			update_widgets = true
			removed_players = removed_players + 1
		else
			temp_players[peer_id] = true

			if not data.is_local_player then
				local widget = data.widget
				local ping = self:get_ping_by_peer_id(peer_id)
				local ping_color = self:get_ping_color_by_ping_value(ping)
				widget.style.ping_texture.color = ping_color
				local chat_button_hotspot = widget.content.chat_button_hotspot

				if chat_button_hotspot.on_pressed then
					chat_button_hotspot.on_pressed = nil

					if chat_button_hotspot.is_selected then
						self:remove_ignore_chat_message_from_peer_id(peer_id)

						chat_button_hotspot.is_selected = nil
					else
						self:ignore_chat_message_from_peer_id(peer_id)

						chat_button_hotspot.is_selected = true
					end
				end

				local voice_button_hotspot = widget.content.voice_button_hotspot

				if voice_button_hotspot.on_pressed then
					voice_button_hotspot.on_pressed = nil

					if voice_button_hotspot.is_selected then
						self:remove_ignore_voice_message_from_peer_id(peer_id)

						voice_button_hotspot.is_selected = nil
					else
						self:ignore_voice_message_from_peer_id(peer_id)

						voice_button_hotspot.is_selected = true
					end
				end

				local profile_button_hotspot = widget.content.profile_button_hotspot

				if profile_button_hotspot.on_pressed then
					profile_button_hotspot.on_pressed = nil

					self:show_profile_by_peer_id(peer_id)
				end

				local is_server = data.is_server
				local kick_button_hotspot = widget.content.kick_button_hotspot

				if not is_server and kick_button_hotspot.on_pressed then
					kick_button_hotspot.on_pressed = nil

					self:kick_player(data.player)
				end
			end
		end
	end

	self.num_players = num_players - removed_players
--edit--
	-- local players = Managers.player:human_players()
	local players = Managers.player:players()
--edit--

	for _, player in pairs(players) do
		if not temp_players[player:network_id()] then
			self:add_player(player)

			update_widgets = true
		end
	end

	if update_widgets then
		self:update_widgets()
	end

	self:update_player_information()
end)
