-- fix shield slam not being able to proc on single target (and the wonky proc code here in general)
-- 
-- Xq 2021
-- This adjustment is intended to work with QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "fix_shield_slam_proc"

local function calculate_attack_direction(action, weapon_rotation)
	local quaternion_axis = "forward"
	local attack_direction = Quaternion[quaternion_axis](weapon_rotation)

	return (action.invert_attack_direction and -attack_direction) or attack_direction
end

Mods.hook.set(mod_name , "ActionShieldSlam._hit", function(func, self, world, can_damage, owner_unit, current_action, item_name)
	local network_manager = Managers.state.network
	local physics_world = World.get_data(world, "physics_world")
	local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
	local item_name = item_name
	local unit_forward = Quaternion.forward(Unit.local_rotation(owner_unit, 0))
	local self_pos = POSITION_LOOKUP[owner_unit]
	local pos = self_pos + unit_forward * 1
	local radius = current_action.push_radius
	local collision_filter = "filter_melee_sweep"
	local actors, actors_n = PhysicsWorld.immediate_overlap(physics_world, "shape", "sphere", "position", pos, "size", radius, "types", "dynamics", "collision_filter", collision_filter, "use_global_table")
	local hit_units = self.hit_units
	local unit_get_data = Unit.get_data
	local hit_once = false
	local attack_direction = self.weapon_direction
	local target_breed_unit = self.target_breed_unit
	local target_breed_unit_health_extension = Unit.alive(target_breed_unit) and ScriptUnit.extension(target_breed_unit, "health_system")

	if target_breed_unit_health_extension and not target_breed_unit_health_extension:is_alive() then
		target_breed_unit = nil
	end

	for i = 1, actors_n, 1 do
		repeat
			local hit_actor = actors[i]
			local hit_unit = Actor.unit(hit_actor)
			local breed = unit_get_data(hit_unit, "breed")

			if breed and hit_units[hit_unit] == nil then
				hit_units[hit_unit] = true
				DamageUtils.buff_on_attack(owner_unit, hit_unit, "heavy_attack")

				if not target_breed_unit then
					local health_extension = ScriptUnit.extension(hit_unit, "health_system")

					if health_extension:is_alive() then
						target_breed_unit = hit_unit

						break
					end
				end

				if target_breed_unit == hit_unit then
					break
				end

				local attack_direction = Vector3.normalize(POSITION_LOOKUP[hit_unit] - pos)
				local node = Actor.node(hit_actor)
				local hit_zone = breed.hit_zones_lookup[node]
				local hit_zone_name = hit_zone.name
				local hit_unit_id = network_manager:unit_game_object_id(hit_unit)
				local hit_zone_id = NetworkLookup.hit_zones[hit_zone_name]
				local attack_template_id = NetworkLookup.attack_templates[current_action.push_attack_template]
				local attack_template_damage_type_name = current_action.push_attack_template_damage_type
				local attack_template_damage_type_id = NetworkLookup.attack_damage_values[attack_template_damage_type_name or "n/a"]

				self.weapon_system:rpc_weapon_blood(nil, attacker_unit_id, attack_template_damage_type_id)

				local stat = current_action.increment_stat_on_hit

				if stat then
					local statistics_db = Managers.player:statistics_db()
					local stats_id = self.owner:stats_id()

					statistics_db:increment_stat(stats_id, stat)
				end

				local backstab_multiplier = 1
				local hawkeye_multiplier = 0

				if self.is_server or LEVEL_EDITOR_TEST then
					self.weapon_system:rpc_attack_hit(nil, NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
				else
					network_manager.network_transmit:send_rpc_server("rpc_attack_hit", NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
					network_manager.network_transmit:send_rpc_server("rpc_weapon_blood", attacker_unit_id, attack_template_damage_type_id)
				end
			end

			if hit_units[hit_unit] == nil and ScriptUnit.has_extension(hit_unit, "damage_system") then
				local level_index, is_level_unit = Managers.state.network:game_object_or_level_id(hit_unit)

				if is_level_unit then
					local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
					local rot = first_person_extension:current_rotation()
					local attack_direction = calculate_attack_direction(current_action, rot)

					ActionShieldSlam:hit_level_object(hit_units, hit_unit, owner_unit, current_action, attack_direction, level_index, item_name)
				end
			end
		until true
	end

	if Unit.alive(target_breed_unit) and not self.hit_target_breed_unit then
		local network_manager = Managers.state.network
		local breed = Unit.get_data(target_breed_unit, "breed")
		local hit_zone_name, _ = next(breed.hit_zones)
		local target_position = POSITION_LOOKUP[target_breed_unit]
		local attack_direction = Vector3.normalize(target_position - POSITION_LOOKUP[owner_unit])
		local hit_unit_id = network_manager:unit_game_object_id(target_breed_unit)
		local attacker_unit_id = network_manager:unit_game_object_id(owner_unit)
		local hit_zone_id = NetworkLookup.hit_zones[hit_zone_name]
		local attack_template_name, attack_template_damage_type_name = ActionUtils.select_attack_template(self.current_action, self.is_critical_strike)
		local attack_template = AttackTemplates[attack_template_name]
		local attack_template_id = NetworkLookup.attack_templates[attack_template_name]
		local attack_template_damage_type_id = NetworkLookup.attack_damage_values[attack_template_damage_type_name or "n/a"]

		ActionSweep._play_character_impact(self, self.is_server, owner_unit, self.current_action, attack_template, attack_template_damage_type_name, target_breed_unit, target_position, breed, hit_zone_name, attack_direction)

		local backstab_multiplier = 1
		local hawkeye_multiplier = 0

		if self.is_server or LEVEL_EDITOR_TEST then
			self.weapon_system:rpc_attack_hit(nil, NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
		else
			network_manager.network_transmit:send_rpc_server("rpc_attack_hit", NetworkLookup.damage_sources[self.item_name], attacker_unit_id, hit_unit_id, attack_template_id, hit_zone_id, attack_direction, attack_template_damage_type_id, NetworkLookup.hit_ragdoll_actors["n/a"], backstab_multiplier, hawkeye_multiplier)
		end

		if self.is_critical_strike and self.critical_strike_particle_id then
			World.destroy_particles(self.world, self.critical_strike_particle_id)

			self.critical_strike_particle_id = nil
		end

		if not Managers.player:owner(self.owner_unit).bot_player then
			Managers.state.controller_features:add_effect("rumble", {
				rumble_effect = "handgun_fire"
			})
		end

		self.hit_target_breed_unit = true
	end

	self.state = "hit"
end)

