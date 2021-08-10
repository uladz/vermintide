Mods.chat = {
	message = "",
	
	update = function(message)
		Mods.chat.message = message
		
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
		
		return true
	end,
}

--[[
	Patch Chat:
		This allows me to filter out commands out the chat box and
		let the Mods.update.chat handle it.
--]]
local mod_name = "Chat"
Mods.hook.set(mod_name, "ChatManager.send_chat_message", function(func, self, channel_id, message)
	if Mods.chat.update(message) then
		func(self, channel_id, message)
	end
	
	return 
end)