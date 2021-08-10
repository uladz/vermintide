local game_mode_manager = Managers.state.game_mode
local round_started = game_mode_manager.is_round_started(game_mode_manager)

if round_started then
	EchoConsole("You may only down your bots at the beginning of a match.")
	return
end

for i, player in pairs(Managers.player:bots()) do 

	local player_unit = Managers.player:player_from_peer_id(Network.peer_id()).player_unit

	if ScriptUnit.has_extension(player.player_unit, 'health_system') then
		if ScriptUnit.extension(player.player_unit, 'health_system'):is_alive() then
			DamageUtils.add_damage_network(player.player_unit, player_unit, 300, 'torso', 'cutting', Vector3(1, 0, 0), 'suicide')
		end
	end
end