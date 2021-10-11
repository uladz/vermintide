local mod = ItemSpawner

local list = {
	"all_ammo_small",
	"fire_grenade_t2",
	"frag_grenade_t2",
	"healing_draught",
	"first_aid_kit",
	"speed_boost_potion",
	"damage_boost_potion"
}

local player_unit = Managers.player:local_player().player_unit
local player_pos = Unit.local_position(player_unit, 0)
local player_rot = Unit.local_rotation(player_unit, 0)

local pickup_spawn_type = NetworkLookup.pickup_spawn_types['dropped']

for y = 1, 4 do
	for x = 1, #list do
		local final_pos = player_pos + Vector3((x * 0.3) - 0.9, (y * 0.3) - 0.9, 0)

		Managers.state.network.network_transmit:send_rpc_server(
			'rpc_spawn_pickup_with_physics',
			NetworkLookup.pickup_names[list[x]],
			final_pos,
			player_rot,
			pickup_spawn_type
		)
	end
end

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned package")
end
