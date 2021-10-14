--[[
	10/13/2021 (uladz) Ported parts of "chat" mod from VMF 0.17.4 to QoL. This allows to send
		"system" messages without character name and to animate messages.
--]]

local mod_name = "Chat"
Mods.chat = {}
local mod = Mods.chat

mod.message = nil
mod.animation = nil
mod.system = false

mod.on_message = function(message)
	mod.message = message

	-- Check action settings
	for _, item in ipairs(Mods.commands) do
		if type(item[1]) == "string" then
			if item[2] then -- has parameters
				if item[1] .. " " == string.sub(message, 1, item[1]:len() + 1) then
					local _, index_of_last_proceeding_space = string.find(message, "%s+")
					if index_of_last_proceeding_space ~= nil then
						local arguments = {}
						arguments = string.sub(message, (index_of_last_proceeding_space+1), message:len())
						Mods.exec(item[3], item[4], arguments)
						return false
					else
						Mods.exec(item[3], item[4])
						return false
					end
				end
			else -- has no parameters
				if item[1] == message then
					Mods.exec(item[3], item[4])
					return false
				end
			end
		end
	end

	-- process as normal message
	return true
end

mod.send = function(message)
	if Managers.chat:has_channel(1) then
		mod.system = true
		Managers.chat:send_chat_message(1, message)
		mod.system = false
	end
end

--[[
	Patch Chat:
		This allows me to filter out commands out the chat box and
		let the Mods.update.chat handle it.
--]]
Mods.hook.set(mod_name, "ChatManager.send_chat_message", function(func, self, channel_id, message)
	if mod.on_message(message) then
		fassert(self.has_channel(self, channel_id), "Haven't registered channel: %s", tostring(channel_id))

		local localization_param = ""
		local is_system_message = mod.system
		local pop_chat = true
		local my_peer_id = self.my_peer_id
		local is_dev = SteamHelper.is_dev(my_peer_id)

		if self.is_server then
			local members = self.channel_members(self, channel_id)
			for _, member in pairs(members) do
				if member ~= my_peer_id then
					RPC.rpc_chat_message(member, channel_id, my_peer_id, message, localization_param, is_system_message, pop_chat, is_dev)
				end
			end
		else
			local host_peer_id = self.host_peer_id
			if host_peer_id then
				RPC.rpc_chat_message(host_peer_id, channel_id, my_peer_id, message, localization_param, is_system_message, pop_chat, is_dev)
			end
		end

		self._add_message_to_list(self, channel_id, my_peer_id, message, is_system_message, pop_chat, is_dev)
	end

	return
end)

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, ...)
	func(...)

	-- Check Animation is active
	if mod.animation then
		mod.animation(...)
	end

	return
end)
