local game_mode_manager = Managers.state.game_mode
local round_started = game_mode_manager.is_round_started(game_mode_manager)

if round_started then
	EchoConsole("You may only kill your bots at the beginning of a match.")
	return
end

for i, player in pairs(Managers.player:bots()) do
	local status_extension = nil
	if player.player_unit then 
		status_extension = ScriptUnit.extension(player.player_unit, "status_system")
	end
	if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
		StatusUtils.set_dead_network(player.player_unit, true)
	end
end