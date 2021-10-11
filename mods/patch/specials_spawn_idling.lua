-- A mod that forces specials to idle for a moment after spawning by denying their target selection
-- Xq 2021
-- This adjustment is intended to work with QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "specials_spawn_idling"

local debug_print_variables = function(...)
	local print_string = false
	for _,data in pairs({...}) do
		if not print_string then
			print_string = tostring(data)
		else
			print_string = print_string .. " | " .. tostring(data)
		end
	end
	
	EchoConsole(print_string)
	
	return
end

local debug_print_table = function(arg)
	EchoConsole("-----------------------------")
	for key, value in pairs(arg) do
		debug_print_variables(key, value)
	end
end

local SPECIAL_SPAWN_IDLE_TIME = 2
local special_spawn_idle_times = {}
local affected_specials =
{
	skaven_gutter_runner			= true,
	-- skaven_pack_master				= false,
	skaven_poison_wind_globadier	= true,
	-- skaven_ratling_gunner			= false,
}

-- order selected specials to idle a bit after they spawn
Mods.hook.set(mod_name , "ConflictDirector.spawn_unit", function(func, self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, inventory_template, group_data, archetype_index)
	local unit = func(self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, inventory_template, group_data, archetype_index)
	
	if unit and breed and affected_specials[breed.name] then
		local current_time = Managers.time:time("game")
		if breed.special then
			special_spawn_idle_times[unit] = current_time + SPECIAL_SPAWN_IDLE_TIME
		end
		
		for key,value in pairs(special_spawn_idle_times) do
			if not Unit.alive(key) then
				special_spawn_idle_times[key] = nil
			end
		end
	end
	
	return unit
end)

-- order assassins to idle a bit after they TP
Mods.hook.set(mod_name , "BTNinjaVanishAction.vanish", function(func, unit, blackboard)
    for key,value in pairs(special_spawn_idle_times) do
        if not Unit.alive(key) then
            special_spawn_idle_times[key] = nil
        end
    end

    local current_time = Managers.time:time("game")
    
    special_spawn_idle_times[unit] = current_time + SPECIAL_SPAWN_IDLE_TIME
    
    return func(unit, blackboard)
end)

-- prevent gas rats from throwing
Mods.hook.set(mod_name , "BTThrowPoisonGlobeAction.run", function(func, self, unit, blackboard, t, dt)
	if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
		return "failed"
	end
	
	return func(self, unit, blackboard, t, dt)
end)

-- prevent assassins from jumping
Mods.hook.set(mod_name , "BTPrepareForCrazyJumpAction.run", function(func, self, unit, blackboard, t, dt)
	if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
		return "failed"
	end
	
	return func(self, unit, blackboard, t, dt)
end)

Mods.hook.set(mod_name , "BTNinjaHighGroundAction.try_jump", function(func, self, unit, blackboard, t, pos1, force_idle)
	if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
		return
	end
	
	return func(self, unit, blackboard, t, pos1, force_idle)
end)



