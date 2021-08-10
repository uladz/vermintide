local mod_name = "Mods.whisper"

Mods.whisper = {}

Mods.hook.set(mod_name, "ChatGui._update_chat_messages", function (func, self)
	local added_chat_messages = FrameTable.alloc_table()

	self.chat_manager:get_chat_messages(added_chat_messages)

	for i,v in ipairs(added_chat_messages) do
		if Mods.whisper.last_whisper and v.message == "<"..Mods.whisper.last_whisper..">" then
			table.remove(added_chat_messages, i)
			Mods.whisper.last_whisper = nil
			break
		end
	end

	local history_max_size = 30
	local num_new = #added_chat_messages
	local show_new_messages = false

	if 0 < num_new then
		local message_tables = self.chat_output_widget.content.message_tables
		local num_current = #message_tables

		if history_max_size < num_new + num_current then
			local num_to_remove = (num_new + num_current) - history_max_size

			for i = 1, num_to_remove, 1 do
				table.remove(message_tables, 1)
			end
		end

		local font_material, font_size, font_name = unpack(Fonts.arial)
		num_current = #message_tables

		for i = 1, num_new, 1 do
			local new_message = added_chat_messages[i]
			local new_message_table = {}

			if new_message.is_system_message then
				local message = string.format("%s", tostring(new_message.message))
				new_message_table.is_dev = new_message.is_dev
				new_message_table.is_system = true
				new_message_table.message = message
				show_new_messages = new_message.pop_chat
			else
				local player = Managers.player:player_from_peer_id(new_message.message_sender)
				local ingame_display_name = nil

				if player then
					local profile_index = self.profile_synchronizer:profile_by_peer(player.peer_id, player.local_player_id(player))
					ingame_display_name = (SPProfiles[profile_index] and SPProfiles[profile_index].ingame_short_display_name) or nil
				end

				local localized_display_name = ingame_display_name and Localize(ingame_display_name)
				local sender = (rawget(_G, "Steam") and Steam.user_name(new_message.message_sender)) or tostring(new_message.message_sender)
				local message = string.format("%s", tostring(new_message.message))
				new_message_table.is_dev = new_message.is_dev
				new_message_table.is_system = false
				new_message_table.sender = (ingame_display_name and string.format("%s (%s): ", sender, localized_display_name)) or string.format("%s: ", sender)
				new_message_table.message = message
				show_new_messages = true
			end

			message_tables[num_current + i] = new_message_table
		end
	end

	return show_new_messages
end)

--[[ 
How to use :


local lobby = Managers.matchmaking:active_lobby()
local function member_func()
	return lobby:members():get_members()
end

		local function member_func()
			local members = {}
			for i,v in ipairs(self.lobby:members():get_members()) do
				if v == wanted_peer_id then
					return {v}
				end
			end
			return self.lobby:members():get_members()
		end


local original_member_func = Managers.chat.channels[1].members_func
Managers.chat.channels[1].members_func = member_func

Mods.whisper.last_whisper = "This is a whisper."
Managers.chat:send_chat_message(1, Mods.whisper.last_whisper)

Managers.chat.channels[1].members_func = original_member_func

--]]