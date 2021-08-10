Mods.network = {
	_calls = {},
}
local me = Mods.network

Mods.network.register = function(name, callback)
	me._calls[name] = callback
end

Mods.network.get = function(name)
	return me._calls[name]
end

-- NetworkTransmit calls
Mods.network.send_rpc = function (rpc_name, peer_id, ...)
	local args = table.pack(...)
	
	Managers.state.network.network_transmit:send_rpc(
		"rpc_chat_message", peer_id, 2, Network.peer_id(), rpc_name, table.serialization(args), false, true, false
	)
end

Mods.network.send_rpc_server = function(rpc_name, ...)
	local args = table.pack(...)
	
	Managers.state.network.network_transmit:send_rpc_server(
		"rpc_chat_message", 2, Network.peer_id(), rpc_name, table.serialization(args), false, true, false
	)
end

Mods.network.send_rpc_clients = function (rpc_name, ...)
	local args = table.pack(...)
	
	Managers.state.network.network_transmit:send_rpc_clients(
		"rpc_chat_message", 2, Network.peer_id(), rpc_name, table.serialization(args), false, true, false
	)
end

Mods.network.send_rpc_clients_except = function (rpc_name, except, ...)
	local args = table.pack(...)
	
	Managers.state.network.network_transmit:send_rpc_clients_except(
		"rpc_chat_message", except, 2, Network.peer_id(), rpc_name, table.serialization(args), false, true, false
	)
end

Mods.network.send_rpc_all = function(rpc_name, ...)
	local args = table.pack(...)
	
	Managers.state.network.network_transmit:send_rpc_all(
		"rpc_chat_message", 2, Network.peer_id(), rpc_name, table.serialization(args), false, true, false
	)
end

Mods.network.send_rpc_all_except = function(rpc_name, except, ...)
	local args = table.pack(...)
	
	Managers.state.network.network_transmit:send_rpc_all_except(
		"rpc_chat_message", except, 2, Network.peer_id(), rpc_name, table.serialization(args), false, true, false
	)
end

-- Handler
Mods.hook.set(mod_name, "ChatManager.rpc_chat_message", function(func, self, sender, channel_id, ...)
	-- Debug
	--EchoConsole("channel_id: " .. tostring(channel_id))
	
	if channel_id == 1 then
		func(self, sender, channel_id, ...)
	else
		local args = table.pack(...)
		
		local rpc_call = args[2]
		local parameter = table.deserialization(args[3])
		
		-- Debug
		--EchoConsole("rpc_call: " .. tostring(rpc_call))
		
		local callback = me.get(rpc_call)
		if callback then
			-- Call rpc function
			callback(sender, unpack(parameter))
		end
	end
end)
Mods.hook.front(mod_name, "ChatManager.rpc_chat_message")