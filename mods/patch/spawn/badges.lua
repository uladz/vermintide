local mod = ItemSpawner

local list = {
	"endurance_badge_01",
	"endurance_badge_02",
	"endurance_badge_03",
	"endurance_badge_04",
	"endurance_badge_05"
}

local player_unit = Managers.player:local_player().player_unit
local player_pos = Unit.local_position(player_unit, 0)
local player_rot = Unit.local_rotation(player_unit, 0)

for y = 1, 5 do
	for x = 1, #list do
		local final_pos = player_pos + Vector3((x * 0.3) - 0.75, (y * 0.3) - 0.75, 0)

		Managers.state.network.network_transmit:send_rpc_server(
			'rpc_spawn_pickup_with_physics',
			NetworkLookup.pickup_names[list[x]],
			final_pos,
			player_rot,
			NetworkLookup.pickup_spawn_types['dropped']
		)
	end
end

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned badges")
end
