-- fix for rats skipping animation when jumping across gaps
-- 
-- Xq & VernonKun 2020
-- 
-- This adjustment is intended to work with QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "fix_rat_jump_across_teleport"

local clear_jump_start_finished = function(blackboard)
	-- EchoConsole("jump_start_finished set to nil")
	blackboard.jump_start_finished = nil
	return
end

Mods.hook.set(mod_name , "BTJumpAcrossAction.enter", function(func, self, unit, blackboard, t)
	local ret = func(self, unit, blackboard, t)
	
	clear_jump_start_finished(blackboard)
	
	return ret
end)

Mods.hook.set(mod_name , "BTJumpAcrossAction.run", function(func, self, unit, blackboard, t, dt)
	if blackboard.jump_state ==  "moving_towards_smartobject_entrance" and blackboard.jump_start_finished then
		clear_jump_start_finished(blackboard)
	end
	
	return func(self, unit, blackboard, t, dt)
end)

