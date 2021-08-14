-- fix for rats skipping landing animation
-- 
-- Xq & VernonKun 2020
-- 
-- This adjustment is intended to work with QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "fix_rat_fall_anim_skip"


local clear_jump_climb_finished = function(blackboard)
	-- EchoConsole("jump_climb_finished set to nil")
	blackboard.jump_climb_finished = nil
	return
end

local set_jump_climb_finished = function(blackboard)
	-- EchoConsole("jump_climb_finished set to true")
	blackboard.jump_climb_finished = true
	return
end

local JUMP_CLIMB_FINISHED_DELAY	= 0.06	-- seconds
local JUMP_CLIMB_FAILSAFE_TIME	= 3		-- seconds
local mod_fall_data = {}

Mods.hook.set(mod_name , "BTFallAction.enter", function(func, self, unit, blackboard, t)
	local ret = func(self, unit, blackboard, t)
	clear_jump_climb_finished(blackboard)
	-- mod_fall_data[unit] = nil
	return ret
end)

Mods.hook.set(mod_name , "BTFallAction.run", function(func, self, unit, blackboard, t, dt)
	
	-- if not mod_fall_data[unit] then
		-- mod_fall_data[unit] =
		-- {
			-- land_start_time	= nil,
			-- last_climb_state	= "",
			-- last_climb_state_1	= "",
		-- }
	-- end
	
	if blackboard.climb_state ==  "waiting_to_collide_down" and blackboard.jump_climb_finished then
		clear_jump_climb_finished(blackboard)
	end

	-- if blackboard.climb_state == "waiting_to_land" and mod_fall_data[unit].last_climb_state_1 == "waiting_to_collide_down" then
		-- mod_fall_data[unit].land_start_time = t
	-- end
	
	-- local land_started		= mod_fall_data[unit].land_start_time
	-- local land_duration	= land_started and t - land_started
	
	-- if land_started and land_duration > JUMP_CLIMB_FAILSAFE_TIME then
		-- EchoConsole("stuck in fall loop:" .. tostring(unit))	
		-- set_jump_climb_finished(blackboard)
	-- end

	-- if land_started and blackboard.climb_state == "waiting_to_land" and blackboard.jump_climb_finished then
		-- EchoConsole(land_duration)
		-- if land_duration < JUMP_CLIMB_FINISHED_DELAY then
			-- EchoConsole("bugged land found")
			-- clear_jump_climb_finished(blackboard)
		-- else
			-- mod_fall_data[unit].land_start_time = nil
		-- end
	-- end

	local ret = func(self, unit, blackboard, t, dt)
	
	-- mod_fall_data[unit].last_climb_state_1 = mod_fall_data[unit].last_climb_state
	-- mod_fall_data[unit].last_climb_state = blackboard.climb_state
	
	
	-- for loop_unit,_ in pairs(mod_fall_data) do
		-- if not Unit.alive(loop_unit) then
			-- mod_fall_data[loop_unit] = nil
		-- end
	-- end
	
	return ret
end)

-- Mods.hook.set(mod_name , "BTFallAction.leave", function(func, self, unit, blackboard, t, reason)
	-- mod_fall_data[unit].land_start_time = nil

	-- func(self, unit, blackboard, t)
-- end)
