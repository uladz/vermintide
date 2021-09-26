--[[
	Name: Action Sweep Resistant Fix (idc about naming...)
	Author: VernonKun
	Updated: 5/16/2020

	Your melee weapon swings no longer stop when you hit the dead bodies of packmasters and ogres. The
	mod works on client side and affects only the player that has the mod installed.
--]]

local mod_name = "ActionSweepResistantFix"

local function calculate_attack_direction(action, weapon_rotation)
	local quaternion_axis = action.attack_direction or "forward"
	local attack_direction = Quaternion[quaternion_axis](weapon_rotation)

	return (action.invert_attack_direction and -attack_direction) or attack_direction
end

local SWEEP_RESULTS = {}

Mods.hook.set(mod_name, "ActionSweep._do_overlap", function (func, self, dt, t, unit, owner_unit, current_action, physics_world, can_damage, current_position, current_rotation)
	local drawer = self._drawer
	local current_time_in_action = t - self.action_time_started
	local current_rot_up = Quaternion.up(current_rotation)
	local hit_environment_rumble = false

	if self.attack_aborted then
		return
	end

	if not can_damage and not self.could_damage_last_update then
		local actual_last_position_current = current_position
		local last_position_current = Vector3(actual_last_position_current.x, actual_last_position_current.y, actual_last_position_current.z - self.down_offset)

		self.stored_position:store(last_position_current)
		self.stored_rotation:store(current_rotation)

		return
	end

	local final_frame = not can_damage and self.could_damage_last_update
	self.could_damage_last_update = can_damage
	local position_previous = self.stored_position:unbox()
	local rotation_previous = self.stored_rotation:unbox()
	local weapon_up_dir_previous = Quaternion.up(rotation_previous)
	local actual_position_current = current_position
	local position_current = Vector3(actual_position_current.x, actual_position_current.y, actual_position_current.z - self.down_offset)
	local rotation_current = current_rotation

	self.stored_position:store(position_current)
	self.stored_rotation:store(rotation_current)

	local weapon_half_extents = self.stored_half_extents:unbox()
	local weapon_half_length = weapon_half_extents.z
	local range_mod = current_action.range_mod or 1
	local width_mod = (current_action.width_mod and current_action.width_mod * 1.25) or 25
	local buff_extension = self.buff_extension
	local in_brawl_mode = buff_extension:has_buff_type("brawl_drunk")
	local is_inside_inn = Managers.state.game_mode:level_key() == "inn_level"

	if is_inside_inn and not in_brawl_mode then
		range_mod = 0.65 * range_mod
		width_mod = width_mod / 4
	end

	weapon_half_length = weapon_half_length * range_mod
	weapon_half_extents.x = weapon_half_extents.x * width_mod

	if script_data.debug_weapons then
		drawer:capsule(position_previous, position_previous + weapon_up_dir_previous * weapon_half_length * 2, 0.02)
		drawer:capsule(position_current, position_current + current_rot_up * weapon_half_length * 2, 0.01, Color(0, 0, 255))
		Debug.text("Missed target count: %d", self.missed_targets or 0)
	end

	local weapon_rot = current_rotation
	local middle_rot = Quaternion.lerp(rotation_previous, weapon_rot, 0.5)
	local position_start = position_previous + weapon_up_dir_previous * weapon_half_length
	local position_end = (position_previous + current_rot_up * weapon_half_length * 2) - Quaternion.up(rotation_previous) * weapon_half_length
	local max_num_hits = 5
	local attack_direction = calculate_attack_direction(current_action, weapon_rot)
	local player_manager = Managers.player
	local owner_player = player_manager:owner(owner_unit)
	local weapon_cross_section = Vector3(weapon_half_extents.x, weapon_half_extents.y, 0.0001)
	local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
	local friendly_fire_melee_allowed = DamageUtils.allow_friendly_fire_melee(difficulty_settings, owner_player)
	local collision_filter = (friendly_fire_melee_allowed and "filter_melee_sweep") or "filter_melee_sweep_no_player"

	if PhysicsWorld.start_reusing_sweep_tables then
		PhysicsWorld.start_reusing_sweep_tables()
	end

	local sweep_results1 = PhysicsWorld.linear_obb_sweep(physics_world, position_previous, position_previous + weapon_up_dir_previous * weapon_half_length * 2, weapon_cross_section, rotation_previous, max_num_hits, "collision_filter", collision_filter, "report_initial_overlap")
	local sweep_results2 = PhysicsWorld.linear_obb_sweep(physics_world, position_start, position_end, weapon_half_extents, rotation_previous, max_num_hits, "collision_filter", collision_filter, "report_initial_overlap")
	local sweep_results3 = PhysicsWorld.linear_obb_sweep(physics_world, position_previous + current_rot_up * weapon_half_length, position_current + current_rot_up * weapon_half_length, weapon_half_extents, rotation_current, max_num_hits, "collision_filter", collision_filter, "report_initial_overlap")
	local num_results1 = 0
	local num_results2 = 0
	local num_results3 = 0

	if sweep_results1 then
		num_results1 = #sweep_results1

		for i = 1, num_results1, 1 do
			SWEEP_RESULTS[i] = sweep_results1[i]
		end
	end

	if sweep_results2 then
		for i = 1, #sweep_results2, 1 do
			local info = sweep_results2[i]
			local this_actor = info.actor
			local found = nil

			for j = 1, num_results1, 1 do
				if SWEEP_RESULTS[j].actor == this_actor then
					found = true
				end
			end

			if not found then
				num_results2 = num_results2 + 1
				SWEEP_RESULTS[num_results1 + num_results2] = info
			end
		end
	end

	if sweep_results3 then
		for i = 1, #sweep_results3, 1 do
			local info = sweep_results3[i]
			local this_actor = info.actor
			local found = nil

			for j = 1, num_results1 + num_results2, 1 do
				if SWEEP_RESULTS[j].actor == this_actor then
					found = true
				end
			end

			if not found then
				num_results3 = num_results3 + 1
				SWEEP_RESULTS[num_results1 + num_results2 + num_results3] = info
			end
		end
	end

	for i = num_results1 + num_results2 + num_results3 + 1, #SWEEP_RESULTS, 1 do
		SWEEP_RESULTS[i] = nil
	end

	local first_person_extension = ScriptUnit.extension(self.owner_unit, "first_person_system")
	local owner_unit_direction = Quaternion.forward(Unit.local_rotation(owner_unit, 0))
	local owner_unit_pos = Unit.world_position(owner_unit, 0)
	local is_server = self.is_server
	local hit_units = self.hit_units
	local environment_unit_hit = false
	local max_targets = current_action.max_targets or 1

	for i = 1, num_results1 + num_results2 + num_results3, 1 do
		local result = SWEEP_RESULTS[i]
		local hit_actor = result.actor
		local hit_unit = Actor.unit(hit_actor)
		local hit_position = result.position
		local hit_armor = false

		if Unit.alive(hit_unit) and Vector3.is_valid(hit_position) then
			fassert(Vector3.is_valid(hit_position), "The hit position is not valid! Actor: %s, Unit: %s", hit_actor, hit_unit)
			assert(hit_unit, "hit_unit is nil.")

			local breed = Unit.get_data(hit_unit, "breed")
			local in_view = first_person_extension:is_within_default_view(hit_position)
			local hit_player = player_manager:is_player_unit(hit_unit) and player_manager:owner(hit_unit)
			local hit_self = hit_unit == owner_unit
			local is_character = breed or hit_player
			local damage_allowed = true
			local is_pvp_friendly_fire_melee = false

			if not hit_self and hit_player then
				local hit_unit_friendly_fire_melee = DamageUtils.allow_friendly_fire_melee(difficulty_settings, hit_player)

				if hit_unit_friendly_fire_melee then
					is_pvp_friendly_fire_melee = true
				else
					damage_allowed = false
				end
			end

			if is_character and hit_units[hit_unit] == nil and in_view and not hit_self and damage_allowed then
				hit_units[hit_unit] = true
				local health_extension = ScriptUnit.extension(hit_unit, "health_system")
				local number_of_hit_enemies = self.number_of_hit_enemies
				local attack_template_name, attack_template_damage_type_name = nil

				if current_action.use_target and self.target_breed_unit ~= nil then
					if hit_unit == self.target_breed_unit then
						if health_extension:is_alive() then
							self.number_of_hit_enemies = self.number_of_hit_enemies + 1
						end

						local attack_target_settings = current_action.default_target
						attack_template_name, attack_template_damage_type_name = ActionUtils.select_attack_template(attack_target_settings, self.is_critical_strike)
					end
				elseif self.number_of_hit_enemies < max_targets then
					if not hit_player and health_extension:is_alive() then
						self.number_of_hit_enemies = self.number_of_hit_enemies + 1
					end

					local targets = current_action.targets
					local actual_hit_enemy_index = math.max(self.number_of_hit_enemies, 1)
					local attack_target_settings = targets[actual_hit_enemy_index] or current_action.default_target
					attack_template_name, attack_template_damage_type_name = ActionUtils.select_attack_template(attack_target_settings, self.is_critical_strike)
				end

				if attack_template_name then
					local attack_template = AttackTemplates[attack_template_name]
					local attack_template_id = NetworkLookup.attack_templates[attack_template_name]
					local attack_template_damage_type_id = NetworkLookup.attack_damage_values[attack_template_damage_type_name or "n/a"]
					local hit_zone_name, armor_category = nil

					if breed then
						armor_category = breed.armor_category
						local node = Actor.node(hit_actor)
						local hit_zone = breed.hit_zones_lookup[node]
						hit_zone_name = hit_zone.name

						if hit_zone_name == "head" then
							local neck_position = Actor.position(hit_actor)
							local closest_sweep_point = Geometry.closest_point_on_line(neck_position, position_current, position_current + Quaternion.up(rotation_current) * weapon_half_length * 2)

							if math.abs(closest_sweep_point.z - neck_position.z) <= 0.1 then
								hit_zone_name = "neck"
							end
						end
--edit--
						--hit_armor = (health_extension:is_alive() and armor_category == 2) or armor_category == 3
						hit_armor = (health_extension:is_alive() and armor_category == 2) or (health_extension:is_alive() and armor_category == 3)
--edit--
					else
						hit_zone_name = "torso"
						armor_category = 4
						local status_extension = ScriptUnit.has_extension(hit_unit, "status_system")
						hit_armor = status_extension:is_blocking()
					end

					local abort_attack = self.number_of_hit_enemies == max_targets or hit_armor

					self:_play_hit_animations(owner_unit, current_action, abort_attack, hit_zone_name, armor_category)

					local network_manager = Managers.state.network
					local hit_unit_id = network_manager:unit_game_object_id(hit_unit)
					local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
					local hit_zone_id = NetworkLookup.hit_zones[hit_zone_name]
					local backstab_multiplier = 1

					if breed and AiUtils.unit_alive(hit_unit) then
						local hit_unit_pos = Unit.world_position(hit_unit, 0)
						local owner_to_hit_dir = Vector3.normalize(hit_unit_pos - owner_unit_pos)
						local hit_unit_direction = Quaternion.forward(Unit.local_rotation(hit_unit, 0))
						local hit_angle = Vector3.dot(hit_unit_direction, owner_to_hit_dir)

						if hit_angle >= 0.55 and hit_angle <= 1 then
							local procced = false
							backstab_multiplier, procced = self.buff_extension:apply_buffs_to_value(backstab_multiplier, StatBuffIndex.BACKSTAB_MULTIPLIER)

							if script_data.debug_legendary_traits then
								backstab_multiplier = 1.5
								procced = true
							end

							if procced then
								first_person_extension:play_hud_sound_event("hud_player_buff_backstab")
							end
						end
					end

					local predicted_damage = 0

					if breed or is_pvp_friendly_fire_melee then
						predicted_damage = self:_play_character_impact(is_server, owner_unit, current_action, attack_template, attack_template_damage_type_name, hit_unit, hit_position, breed, hit_zone_name, attack_direction, backstab_multiplier, is_pvp_friendly_fire_melee)
					end

					if Managers.state.controller_features and self.owner.local_player and not self.has_played_rumble_effect then
						if hit_armor then
							Managers.state.controller_features:add_effect("rumble", {
								rumble_effect = "hit_armor"
							})
						else
							local hit_rumble_effect = current_action.hit_rumble_effect or "hit_character"

							Managers.state.controller_features:add_effect("rumble", {
								rumble_effect = "hit_character"
							})
						end

						if abort_attack then
							self.has_played_rumble_effect = true
						end
					end

					local charge_value = current_action.charge_value
					local buff_result = DamageUtils.buff_on_attack(owner_unit, hit_unit, charge_value, predicted_damage)
					local show_blood = breed and not breed.no_blood_splatter_on_damage
					local statistics_db = Managers.player:statistics_db()
					local stat = current_action.increment_stat_on_hit

					if stat then
						local stats_id = self.owner:stats_id()

						statistics_db:increment_stat(stats_id, stat)
					end

					if show_blood then
						self.weapon_system:rpc_weapon_blood(nil, attacker_unit_id, attack_template_damage_type_id)

						local blood_position = Vector3(result.position.x, result.position.y, result.position.z + self.down_offset)

						Managers.state.blood:add_enemy_blood(blood_position, result.normal, result.actor)
					end

					if buff_result ~= "killing_blow" then
						local hawkeye_multiplier = 0

						if is_server or LEVEL_EDITOR_TEST then
							self.weapon_system:rpc_attack_hit(nil, NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
						else
							network_manager.network_transmit:send_rpc_server("rpc_attack_hit", NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)

							if show_blood then
								network_manager.network_transmit:send_rpc_server("rpc_weapon_blood", attacker_unit_id, attack_template_damage_type_id)
							end
						end
					else
						first_person_extension:play_hud_sound_event("Play_hud_matchmaking_countdown")
					end

					if abort_attack then
						break
					end
				end
			elseif not is_character and in_view then
				if ScriptUnit.has_extension(hit_unit, "ai_inventory_item_system") then
					if not self.hit_units[hit_unit] then
						Unit.flow_event(hit_unit, "break_shield")

						self.hit_units[hit_unit] = true
					end

					if Managers.state.controller_features and self.owner.local_player and not self.has_played_rumble_effect then
						Managers.state.controller_features:add_effect("rumble", {
							rumble_effect = "hit_shield"
						})

						self.has_played_rumble_effect = true
					end
				elseif hit_units[hit_unit] == nil and ScriptUnit.has_extension(hit_unit, "damage_system") then
					local level_index, is_level_unit = Managers.state.network:game_object_or_level_id(hit_unit)

					if is_level_unit then
						self:hit_level_object(hit_units, hit_unit, owner_unit, current_action, attack_direction, level_index)

						local hit_position = SWEEP_RESULTS[i].position
						local hit_normal = SWEEP_RESULTS[i].normal

						self:_play_environmental_effect(current_rotation, current_action, hit_unit, hit_position, hit_normal)

						hit_environment_rumble = true
					else
						self.hit_units[hit_unit] = hit_unit
						local targets = current_action.targets
						local attack_target_settings = targets[math.max(self.number_of_hit_enemies, 1)] or current_action.default_target
						local attack_template_name, attack_template_damage_type_name = ActionUtils.select_attack_template(attack_target_settings, self.is_critical_strike)
						local attack_template_id = NetworkLookup.attack_templates[attack_template_name]
						local attack_template_damage_type_id = NetworkLookup.attack_damage_values[attack_template_damage_type_name or "n/a"]
						local network_manager = Managers.state.network
						local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
						local hit_unit_id = network_manager:unit_game_object_id(hit_unit)
						local hit_zone_id = NetworkLookup.hit_zones.full
						local backstab_multiplier = 1
						local hawkeye_multiplier = 0

						if self.is_server or LEVEL_EDITOR_TEST then
							self.weapon_system:rpc_attack_hit(nil, NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
						else
							network_manager.network_transmit:send_rpc_server("rpc_attack_hit", NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
						end

						self:_play_hit_animations(owner_unit, current_action, true)

						local hit_normal = SWEEP_RESULTS[i].normal

						self:_play_environmental_effect(current_rotation, current_action, hit_unit, hit_position, hit_normal)

						hit_environment_rumble = true
					end
				elseif hit_units[hit_unit] == nil then
					if is_inside_inn and not in_brawl_mode then
						local abort_attack = true

						self:_play_hit_animations(owner_unit, current_action, abort_attack)
					end

					environment_unit_hit = i
					hit_environment_rumble = true
				end
			end
		end
	end

	if environment_unit_hit and not self.has_hit_environment and num_results1 + num_results2 > 0 then
		self.has_hit_environment = true
		local result = SWEEP_RESULTS[environment_unit_hit]
		local hit_actor = result.actor
		local hit_unit = Actor.unit(hit_actor)

		assert(hit_unit, "hit unit is nil")

		if unit ~= hit_unit then
			local hit_position = result.position
			local hit_normal = result.normal
			local hit_direction = attack_direction
			local unit_set_flow_variable = Unit.set_flow_variable

			self:_play_environmental_effect(current_rotation, current_action, hit_unit, hit_position, hit_normal)

			if Managers.state.controller_features and is_inside_inn and self.owner.local_player and not self.has_played_rumble_effect then
				Managers.state.controller_features:add_effect("rumble", {
					rumble_effect = "hit_environment"
				})

				self.has_played_rumble_effect = true
			end

			unit_set_flow_variable(hit_unit, "hit_actor", hit_actor)
			unit_set_flow_variable(hit_unit, "hit_direction", hit_direction)
			unit_set_flow_variable(hit_unit, "hit_position", hit_position)
			Unit.flow_event(hit_unit, "lua_simple_damage")
		end
	end

	if final_frame then
		self.attack_aborted = true
	end

	if Managers.state.controller_features and is_inside_inn and hit_environment_rumble and self.owner.local_player and not self.has_played_rumble_effect then
		Managers.state.controller_features:add_effect("rumble", {
			rumble_effect = "hit_environment"
		})

		self.has_played_rumble_effect = true
	end

	if script_data.debug_weapons then
		Debug.text("Has dedicated target: %s", self.target_breed_unit ~= nil)

		local pose = Matrix4x4.from_quaternion_position(rotation_previous, position_start)

		drawer:box_sweep(pose, weapon_half_extents, position_end - position_start, Color(0, 255, 0), Color(0, 100, 0))
		drawer:sphere(position_start, 0.1)
		drawer:sphere(position_end, 0.1, Color(255, 0, 255))
		drawer:vector(position_start, position_end - position_start)

		local pose = Matrix4x4.from_quaternion_position(rotation_current, position_previous + Quaternion.up(rotation_current) * weapon_half_length)

		drawer:box_sweep(pose, weapon_half_extents, position_current - position_previous)
	end

	if PhysicsWorld.stop_reusing_sweep_tables then
		PhysicsWorld.stop_reusing_sweep_tables()
	end
end)
