local mod_name = "Animation"

--[[
	Game Version: All
	
	Error:
		<<Lua Error>> scripts/managers/network/game_network_manager.lua:771: State machine has no such event: jump_down in unit #ID[9383f5ad0f422c4f]<</Lua Error>>
		<<Lua Stack>>   [1] [C]: in function animation_event
		  [2] scripts/managers/network/game_network_manager.lua:771: in function anim_event
		  [3] scripts/entity_system/systems/behaviour/nodes/bt_spawning_action.lua:114: in function run
		  [4] scripts/entity_system/systems/behaviour/nodes/generated/bt_selector_critter_pig.lua:36: in function evaluate
		<</Lua Stack>>
		<<Lua Locals>>   [2] self = table: 1D0CBF60; unit = [Unit \'#ID[9383f5ad0f422c4f]\']; event = "jump_down"; go_id = 259; event_id = 459
		  [3] self = table: 1D115760; unit = [Unit \'#ID[9383f5ad0f422c4f]\']; blackboard = table: 97C2D160; t = 284.0412322152406; dt = 0.021754283457994461; locomotion_extension = table: 97C2D2C0; spawning_finished = true; nav_world = [unknown light userdata]; current_pos = Vector3(-208.029, -137.081, 15.8421); is_position_on_navmesh = true; altitude = 1.447582483291626; min_pos = Vector3(-208.029, -137.081, 1.44758)
		  [4] self = table: 1D115720; unit = [Unit \'#ID[9383f5ad0f422c4f]\']; blackboard = table: 97C2D160; t = 284.0412322152406; dt = 0.021754283457994461; Profiler_start = [function]; Profiler_stop = [function]; child_running = nil; children = table: 1D115740; node_spawn = table: 1D115760; condition_result = true
		<</Lua Locals>>
	
	Detail:
		Some enemies can have missing events on strange situations. Like spawning a pig and letting him fall.
--]]

Mods.hook.set(mod_name, "GameNetworkManager.anim_event", function(func, self, unit, event)
	local go_id = self.unit_storage:go_id(unit)

	fassert(go_id, "Unit storage does not have a game object id for %q", unit)

	local event_id = NetworkLookup.anims[event]


	local status, err = pcall(Unit.animation_event, unit, event)
	
	if not status then
		return
	end
	
	if self.game_session then
		if self.is_server then
			self.network_transmit:send_rpc_clients("rpc_anim_event", event_id, go_id)
		else
			self.network_transmit:send_rpc_server("rpc_anim_event", event_id, go_id)
		end
	end

	return 
end)