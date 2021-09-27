local mod_name = "AssassinBehaviorTweak"

--This mod aims at making Gutter Runner's animations and behaviors more believeable in the physical sense, and in some sense more balanced for true solos

--Add 2 seconds delay to jump after spawn and after teleport (also hook BTPrepareForCrazyJumpAction.run, BTNinjaHighGroundAction.try_jump and BTNinjaVanishAction.vanish)

local SPECIAL_SPAWN_IDLE_TIME = 2
local special_spawn_idle_times = {}

Mods.hook.set(mod_name , "ConflictDirector.spawn_unit", function(func, self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, inventory_template, group_data, archetype_index)
	local unit = func(self, breed, spawn_pos, spawn_rot, spawn_category, spawn_animation, spawn_type, inventory_template, group_data, archetype_index)
	
	if unit and breed and breed.name == "skaven_gutter_runner" then
		local current_time = Managers.time:time("game")
		
		special_spawn_idle_times[unit] = current_time + SPECIAL_SPAWN_IDLE_TIME
		
		for key,value in pairs(special_spawn_idle_times) do
			if not Unit.alive(key) then
				special_spawn_idle_times[key] = nil
			end
		end
	end
	
	return unit
end)

local position_lookup = POSITION_LOOKUP
local unit_alive = Unit.alive

--Check facing direction before jumping (<10 degrees, angle requirement reduced at melee range to avoid merry-go-round)
--Fix crouching animation skip after crouching but unable to jump once
--Remove gliding motion (moving at full speed while in stand-up animation) after crouching but unable to jump
--Tweak behavior after crouching but unable to jump

Mods.hook.set(mod_name, "BTPrepareForCrazyJumpAction.run", function (func, self, unit, blackboard, t, dt)
	if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
		return "failed"
	end
	
	local locomotion = ScriptUnit.extension(unit, "locomotion_system")
	local breed = blackboard.breed

	if breed.jump_range < blackboard.target_dist then
		return "failed"
	end

	local target_unit = blackboard.target_unit

	if unit_alive(target_unit) then
		local status_extension = ScriptUnit.extension(target_unit, "status_system")
		local is_pounced_by_other = status_extension:is_pounced_down()

		if is_pounced_by_other then
			return "failed"
		end
	else
		return "failed"
	end

	if blackboard.move_closer_to_target then
		blackboard.navigation_extension:set_max_speed(blackboard.breed.run_speed)

		LocomotionUtils.follow_target(unit, blackboard, t, dt)
		locomotion:set_wanted_rotation(nil)

		if blackboard.move_closer_to_target_timer < t then
			local data = blackboard.jump_data
			local in_los, velocity, time_of_flight = BTPrepareForCrazyJumpAction.ready_to_jump(unit, blackboard, data, false)

			if in_los then
				BTPrepareForCrazyJumpAction.start_crawling(unit, blackboard, t, data)

				blackboard.move_closer_to_target = false
			else
				if blackboard.target_dist < 2 and GwNavQueries.raycango(blackboard.nav_world, POSITION_LOOKUP[unit], POSITION_LOOKUP[target_unit]) then
					BTPrepareForCrazyJumpAction.start_crawling(unit, blackboard, t, data)

					blackboard.move_closer_to_target = false
				else
					return "failed"
				end

				blackboard.move_closer_to_target_timer = t + 1
			end
		end
	else
		local target_position = POSITION_LOOKUP[target_unit]
		local rot = LocomotionUtils.look_at_position_flat(unit, target_position)

		locomotion:set_wanted_rotation(rot)

		local data = blackboard.jump_data

		if data.crouching then
			LocomotionUtils.follow_target(unit, blackboard, t, dt)

			local ai_rotation = Unit.local_rotation(unit, 0)
			local ai_unit_position = POSITION_LOOKUP[unit]
			local ai_unit_rotation = Quaternion.forward(ai_rotation)
			local ai_unit_direction = Vector3.normalize(ai_unit_rotation)
			local ai_unit_to_target_dir = Vector3.normalize(Vector3.flat(target_position - ai_unit_position))
			local dot = Vector3.dot(ai_unit_to_target_dir, ai_unit_direction)
			local target_distance = Vector3.length(target_position - ai_unit_position)
			local clamped_distance = math.clamp(target_distance, 1, 2.25) - 1
			local angle_requirement = 0.259 + (0.984-0.259) * (clamped_distance / 1.25)
			
			if blackboard.target_outside_navmesh then
				if not data.jump_at_target_outside_mesh then
					local network_manager = Managers.state.network

					network_manager:anim_event(unit, "idle")

					local navigation = blackboard.navigation_extension

					navigation:move_to(position_lookup[unit])

					data.jump_at_target_outside_mesh = true
				end
			else
				-- locomotion:set_wanted_rotation(nil)
			end

			if data.ready_crouch_time < t then
				local in_los, velocity, time_of_flight = BTPrepareForCrazyJumpAction.ready_to_jump(unit, blackboard, data, true)
				
				if in_los and dot > angle_requirement then
					return "done"
				end

				data.crouching = false
				blackboard.move_closer_to_target = true

				Managers.state.network:anim_event(unit, "to_upright")
				blackboard.navigation_extension:set_max_speed(1)
				blackboard.move_closer_to_target_timer = t + 0.5

				blackboard.remembered_threat_pos = nil
				data.ready_crouch_time = nil

				return "running"
			end
		else
			BTPrepareForCrazyJumpAction.start_crawling(unit, blackboard, t, data)
		end
	end

	return "running"
end)

--Remove instant jump design

Mods.hook.set(mod_name, "BTNinjaHighGroundAction.try_jump", function (func, self, unit, blackboard, t, pos1, force_idle)
	if special_spawn_idle_times[unit] and t < special_spawn_idle_times[unit] then
		return
	end
	
	local has_jump_data = blackboard.jump_data
	
	local ret = func(self, unit, blackboard, t, pos1, force_idle)
	
	if not has_jump_data and blackboard.jump_data then
		blackboard.jump_data.delay_jump_start = true
	end
	
	return ret
end)

--Normalize jump speed to avoid lightspeed jumps

Mods.hook.set(mod_name, "BTPrepareForCrazyJumpAction.test_trajectory", function (func, blackboard, p1, p2, segment_list, multiple_raycasts)
	local in_los, velocity, time_of_flight = func(blackboard, p1, p2, segment_list, multiple_raycasts)
	
	local jump_speed = blackboard.breed.jump_speed
	local to_target_dir = Vector3.normalize(p2 - p1)
	local dot = Vector3.dot(to_target_dir, Vector3(0, 0, 1))
	local height = p1.z - p2.z
	
	if dot < -0.5 and height > 2 and height < 6 then
		jump_speed = 5
	end
	
	if velocity and jump_speed then
		velocity = Vector3.normalize(velocity) * jump_speed
	end
	
	return in_los, velocity, time_of_flight
end)

--Reduce grab radius (1m -> 0.7m) to avoid assassin grabbing player while not physically touching the player

local use_overlap = true

Mods.hook.set(mod_name, "BTCrazyJumpAction.check_colliding_players", function (func, self, unit, blackboard, pos)
	if use_overlap then
		local radius = 0.7
		local hit_actors, actor_count = PhysicsWorld.immediate_overlap(self.physics_world, "shape", "sphere", "position", pos, "size", radius, "types", "both", "collision_filter", "filter_player_and_husk_trigger", "use_global_table")

		if actor_count > 0 then
			for i = 1, actor_count, 1 do
				local hit_actor = hit_actors[i]
				local hit_unit = Actor.unit(hit_actor)

				if AiUtils.is_of_interest_to_gutter_runner(unit, hit_unit, blackboard) then
					blackboard.jump_data.target_unit = hit_unit
					blackboard.target_unit = hit_unit

					return hit_unit
				end
			end
		end
	else
		local shortest_dist_squared = 4
		local hit_unit = nil

		for i = 1, #PLAYER_AND_BOT_UNITS, 1 do
			local player_unit = PLAYER_AND_BOT_UNITS[i]
			local player_pos = position_lookup[player_unit]
			local dist_squared = Vector3.distance_squared(pos, player_pos)

			if dist_squared < shortest_dist_squared then
				hit_unit = player_unit
				shortest_dist_squared = dist_squared
			end
		end

		return hit_unit
	end
end)

--Fix assassin fake teleport

Mods.hook.set(mod_name , "BTNinjaVanishAction.vanish", function(func, unit, blackboard)
    for key,value in pairs(special_spawn_idle_times) do
        if not Unit.alive(key) then
            special_spawn_idle_times[key] = nil
        end
    end

    local current_time = Managers.time:time("game")
    
    special_spawn_idle_times[unit] = current_time + SPECIAL_SPAWN_IDLE_TIME
	
	blackboard.navigation_extension:set_enabled(false)
	blackboard.locomotion_extension:set_wanted_velocity(Vector3.zero())
	blackboard.locomotion_extension:set_movement_type("snap_to_navmesh")
	
	func(unit, blackboard)
end)

