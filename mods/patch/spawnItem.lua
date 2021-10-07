--[[
	Uptaken from VMF 0.17.4, version as of 6/27/2017.
	SpawnItemFunc v1.0.0
	This mod allows other mods that spawn items to work.

	Changelog
		1.0.0 - Release
]]

Mods.spawnItem = function(pickup_name)
	local local_player_unit = Managers.player:local_player().player_unit

	safe_pcall(function()
		Managers.state.network.network_transmit:send_rpc_server(
			'rpc_spawn_pickup_with_physics',
			NetworkLookup.pickup_names[pickup_name],
			Unit.local_position(local_player_unit, 0),
			Unit.local_rotation(local_player_unit, 0),
			NetworkLookup.pickup_spawn_types['dropped']
		)
	end)
end
