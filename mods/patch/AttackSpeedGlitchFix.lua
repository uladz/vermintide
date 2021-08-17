--[[
	Name: Attack Speed Weapon Glitch Fix
	Author: VernonKun (presumably)
	Updated: 6/19/2020

	This mod fixes some bugs in weapon actions when attack speed has increased from traits or speed
	potions. Most notably missing charged fireballs from Fireball Staff when there are >1 attack
	speed buffs, and double 3-bolt shots from Volley Crossbow, see my post here:
	https://steamcommunity.com/app/235540/discussions/1/3554966516820828406/
--]]

local mod_name = "AttackSpeedGlitchFix"

Mods.hook.set(mod_name, "WeaponUnitExtension.can_stop_hold_action", function(func, self, t)
	local current_time_in_action = t - self.action_time_started
	local current_action_settings = self.current_action_settings
	local minimum_hold_time = current_action_settings.minimum_hold_time

	if not minimum_hold_time then
		return true
	end

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")

	if buff_extension then
		minimum_hold_time = buff_extension:apply_buffs_to_value(minimum_hold_time, StatBuffIndex.RELOAD_SPEED)
--edit--
		local attack_speed_modifier = 1
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)

		minimum_hold_time = minimum_hold_time / attack_speed_modifier
--edit--
	end

	return minimum_hold_time < current_time_in_action
end)

Mods.hook.set(mod_name, "ActionStaff.client_owner_start_action", function(func, self, new_action, t)
	self.current_action = new_action
	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + (new_action.fire_time or 0)
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
end)

Mods.hook.set(mod_name, "ActionBow.client_owner_start_action", function(func, self, new_action, t, chain_action_data)
	self.current_action = new_action
	local input_extension = ScriptUnit.extension(self.owner_unit, "input_system")

	input_extension:reset_input_buffer()

	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + (new_action.fire_time or 0)
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.extra_buff_shot = false
end)

Mods.hook.set(mod_name, "ActionCrossbow.client_owner_start_action", function(func, self, new_action, t)
	self.current_action = new_action
	self.num_projectiles = new_action.num_projectiles
	self.multi_projectile_spread = new_action.multi_projectile_spread or 0.075

	if self.ammo_extension and self.num_projectiles then
		self.num_projectiles = math.min(self.num_projectiles, self.ammo_extension.current_ammo)
	end

	self.num_projectiles_shot = 1
	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + (new_action.fire_time or 0)
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.extra_buff_shot = false
	self.active_reload_time = new_action.active_reload_time and t + new_action.active_reload_time
end)

Mods.hook.set(mod_name, "ActionHandgun.client_owner_start_action", function(func, self, new_action, t)
	self.current_action = new_action

	if not Managers.player:owner(self.owner_unit).bot_player then
		Managers.state.controller_features:add_effect("rumble", {
			rumble_effect = "light_swing"
		})
	end

	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + new_action.fire_time
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.extra_buff_shot = false
	self.ammo_usage = new_action.ammo_usage
	self.overcharge_type = new_action.overcharge_type
	self.used_ammo = false
	self.active_reload_time = new_action.active_reload_time and t + new_action.active_reload_time

	if new_action.block then
		local status_extension = ScriptUnit.extension(self.owner_unit, "status_system")

		status_extension:set_blocking(true)
	end
end)

Mods.hook.set(mod_name, "ActionShotgun.client_owner_start_action", function(func, self, new_action, t)
	self.current_action = new_action
	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + new_action.fire_time
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.active_reload_time = new_action.active_reload_time and t + new_action.active_reload_time
	local spread_template_override = new_action.spread_template_override

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end

	self.extra_buff_shot = false
	local HAS_TOBII = rawget(_G, "Tobii") and Tobii.device_status() == Tobii.DEVICE_TRACKING and Application.user_setting("tobii_eyetracking")

	if HAS_TOBII and new_action.fire_at_gaze_setting and Application.user_setting(new_action.fire_at_gaze_setting) then
		local owner_unit = self.owner_unit

		if ScriptUnit.has_extension(owner_unit, "eyetracking_system") then
			local eyetracking_extension = ScriptUnit.extension(owner_unit, "eyetracking_system")

			self.start_gaze_rotation:store(eyetracking_extension:gaze_rotation())
		end
	end
end)

Mods.hook.set(mod_name, "ActionTrueFlightBow.client_owner_start_action", function(func, self, new_action, t, chain_action_data)
	self.current_action = new_action
	self.true_flight_template_id = TrueFlightTemplates[new_action.true_flight_template].lookup_id

	assert(self.true_flight_template_id)

	if chain_action_data then
		self.target = chain_action_data.target
	end

	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + (new_action.fire_time or 0)
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.extra_buff_shot = false
end)

Mods.hook.set(mod_name, "ActionChargedProjectile.client_owner_start_action", function(func, self, new_action, t, chain_action_data)
	self.current_action = new_action
	self.state = "waiting_to_shoot"

	if chain_action_data then
		self.charge_level = chain_action_data.charge_level
	else
		self.charge_level = 0
	end

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + new_action.fire_time
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.extra_buff_shot = false
	local spread_template_override = new_action.spread_template_override

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end

	local loaded_projectile_settings = new_action.loaded_projectile_settings

	if loaded_projectile_settings then
		local inventory_extension = ScriptUnit.extension(self.owner_unit, "inventory_system")

		inventory_extension:set_loaded_projectile_override(loaded_projectile_settings)
	end
end)

Mods.hook.set(mod_name, "ActionGeiser.client_owner_start_action", function(func, self, new_action, t, chain_action_data)
	self.current_action = new_action
	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + (new_action.fire_time or 0)
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.radius = chain_action_data.radius
	self.height = chain_action_data.height
	self.charge_value = chain_action_data.charge_value
	self.position = chain_action_data.position
	self.targeting_effect_id = chain_action_data.targeting_effect_id

	table.clear(self._damage_buffer)

	self._damage_buffer_index = 1
end)

Mods.hook.set(mod_name, "ActionBeam.client_owner_start_action", function(func, self, new_action, t)
	self.current_action = new_action
	local current_action = self.current_action
	self.state = "waiting_to_shoot"

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local attack_speed_modifier = 1

	if buff_extension then
		attack_speed_modifier = math.max(ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit), 1)
	end

	--self.time_to_shoot = t + new_action.fire_time
	self.time_to_shoot = t + (new_action.fire_time or 0) / attack_speed_modifier
	self.current_target = nil
	self.damage_timer = 0
	self.overcharge_timer = 0
	self.ramping_interval = 1
	local world = self.world
	local beam_effect = new_action.particle_effect_trail
	local beam_effect_3p = new_action.particle_effect_trail_3p
	local beam_end_effect = new_action.particle_effect_target
	local beam_effect_id = NetworkLookup.effects[beam_effect_3p]
	local beam_end_effect_id = NetworkLookup.effects[beam_end_effect]
	self.beam_effect = World.create_particles(world, beam_effect, Vector3.zero())
	self.beam_end_effect = World.create_particles(world, beam_end_effect, Vector3.zero())
	self.beam_effect_length_id = World.find_particles_variable(world, beam_effect, "trail_length")
	local go_id = self.unit_id

	if self.is_server or LEVEL_EDITOR_TEST then
		self.network_transmit:send_rpc_clients("rpc_start_beam", go_id, beam_effect_id, beam_end_effect_id, new_action.range)
	else
		self.network_transmit:send_rpc_server("rpc_start_beam", go_id, beam_effect_id, beam_end_effect_id, new_action.range)
	end

	local status_extension = ScriptUnit.extension(self.owner_unit, "status_system")

	if not status_extension:is_zooming() then
		status_extension:set_zooming(true)
	end

	local overcharge_extension = self.overcharge_extension

	if self.overcharge_extension then
		self.overcharge_extension:add_charge(current_action.overcharge_type)
	end

	self.overcharge_target_hit = false
	local charge_sound_name = new_action.charge_sound_name

	if charge_sound_name then
		local wwise_playing_id, wwise_source_id = ActionUtils.start_charge_sound(self.wwise_world, self.weapon_unit, new_action)
		self.charging_sound_id = wwise_playing_id
		self.wwise_source_id = wwise_source_id
	end

	local charge_sound_husk_name = current_action.charge_sound_husk_name

	if charge_sound_husk_name then
		ActionUtils.play_husk_sound_event(charge_sound_husk_name, self.owner_unit)
	end
end)

Mods.hook.set(mod_name, "ActionAim.client_owner_start_action", function(func, self, new_action, t)
	local owner_unit = self.owner_unit
	self.current_action = new_action
	self.zoom_condition_function = new_action.zoom_condition_function
	self.played_aim_sound = false

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local time_scale = new_action.anim_time_scale or 1

	if buff_extension then
		time_scale = math.max(ActionUtils.apply_attack_speed_buff(time_scale, self.owner_unit), 1)
	end

	-- self.aim_sound_time = t + (new_action.aim_sound_delay or 0)
	-- self.aim_zoom_time = t + (new_action.aim_zoom_delay or 0)
	self.aim_sound_time = t + (new_action.aim_sound_delay or 0) / time_scale
	self.aim_zoom_time = t + (new_action.aim_zoom_delay or 0) / time_scale
	local spread_template_override = new_action.spread_template_override

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end

	local HAS_TOBII = rawget(_G, "Tobii") and Tobii.device_status() == Tobii.DEVICE_TRACKING and Application.user_setting("tobii_eyetracking")

	if new_action.aim_at_gaze_setting and Application.user_setting(new_action.aim_at_gaze_setting) and HAS_TOBII and ScriptUnit.has_extension(owner_unit, "eyetracking_system") then
		local eyetracking_extension = ScriptUnit.extension(owner_unit, "eyetracking_system")
		local gaze_rotation = eyetracking_extension:gaze_rotation()
		local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")

		first_person_extension:force_look_rotation(gaze_rotation, 0)
	end

	local loaded_projectile_settings = new_action.loaded_projectile_settings

	if loaded_projectile_settings then
		local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")

		inventory_extension:set_loaded_projectile_override(loaded_projectile_settings)
	end
end)

local ranged_enter_function = function(attacker_unit, input_extension)
	input_extension:clear_input_buffer()

	return input_extension:reset_release_input()
end

Weapons.repeating_crossbow_template_1.actions.action_one.default.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1.actions.action_one.zoomed_shot.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1.actions.action_two.default.enter_function = ranged_enter_function

Weapons.repeating_crossbow_template_1_co.actions.action_one.default.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1_co.actions.action_one.zoomed_shot.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1_co.actions.action_two.default.enter_function = ranged_enter_function

Weapons.repeating_crossbow_template_1_t2.actions.action_one.default.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1_t2.actions.action_one.zoomed_shot.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function

Weapons.repeating_crossbow_template_1_t3.actions.action_one.default.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1_t3.actions.action_one.zoomed_shot.enter_function = ranged_enter_function
Weapons.repeating_crossbow_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function

Weapons.crossbow_template_1.actions.action_two.default.enter_function = ranged_enter_function
Weapons.crossbow_template_1_co.actions.action_two.default.enter_function = ranged_enter_function
Weapons.crossbow_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function
Weapons.crossbow_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function

-- Weapons.brace_of_drakefirepistols_template_1.actions.weapon_reload.default.enter_function = ranged_enter_function
-- Weapons.brace_of_drakefirepistols_template_1_co.actions.weapon_reload.default.enter_function = ranged_enter_function
-- Weapons.brace_of_drakefirepistols_template_1_t2.actions.weapon_reload.default.enter_function = ranged_enter_function
-- Weapons.brace_of_drakefirepistols_template_1_t3.actions.weapon_reload.default.enter_function = ranged_enter_function

--Affect Repeater Reload Fix?
Weapons.repeating_pistol_template_1.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_pistol_template_1_co.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_pistol_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_pistol_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function

Weapons.repeating_handgun_template_1.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_handgun_template_1_co.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_handgun_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_handgun_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function

local ranged_enter_function_2 = function(attacker_unit, input_extension)
	input_extension:clear_input_buffer()
end

Weapons.handgun_template_1.actions.action_one.default.enter_function = ranged_enter_function_2
Weapons.handgun_template_1_co.actions.action_one.default.enter_function = ranged_enter_function_2
Weapons.handgun_template_1_t2.actions.action_one.default.enter_function = ranged_enter_function_2
Weapons.handgun_template_1_t3.actions.action_one.default.enter_function = ranged_enter_function_2

Weapons.grudge_raker_template_1.actions.action_two.default.enter_function = ranged_enter_function_2
Weapons.grudge_raker_template_1_co.actions.action_two.default.enter_function = ranged_enter_function_2
Weapons.grudge_raker_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function_2
Weapons.grudge_raker_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function_2

Weapons.blunderbuss_template_1.actions.action_two.default.enter_function = ranged_enter_function_2
Weapons.blunderbuss_template_1_co.actions.action_two.default.enter_function = ranged_enter_function_2
Weapons.blunderbuss_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function_2
Weapons.blunderbuss_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function_2

local ranged_enter_function_3 = function(attacker_unit, input_extension)
	input_extension:reset_release_input()
	input_extension:clear_input_buffer()
end

-- Weapons.staff_fireball_fireball_template_1.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_fireball_template_1_co.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_fireball_template_1_t2.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_fireball_template_1_t3.actions.weapon_reload.default.enter_function = ranged_enter_function_3

-- Weapons.staff_fireball_geiser_template_1.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_geiser_template_1_co.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_geiser_template_1_t2.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_geiser_template_1_t3.actions.weapon_reload.default.enter_function = ranged_enter_function_3

-- Weapons.staff_fireball_geiser_template_1.actions.action_two.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_geiser_template_1_co.actions.action_two.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_geiser_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function_3
-- Weapons.staff_fireball_geiser_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function_3

-- Weapons.staff_blast_beam_template_1.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_blast_beam_template_1_co.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_blast_beam_template_1_t2.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_blast_beam_template_1_t3.actions.weapon_reload.default.enter_function = ranged_enter_function_3

-- Weapons.staff_blast_beam_template_1.actions.action_two.default.enter_function = ranged_enter_function_3
-- Weapons.staff_blast_beam_template_1_co.actions.action_two.default.enter_function = ranged_enter_function_3
-- Weapons.staff_blast_beam_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function_3
-- Weapons.staff_blast_beam_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function_3

-- Weapons.staff_spark_spear_template_1.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_spark_spear_template_1_co.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_spark_spear_template_1_t2.actions.weapon_reload.default.enter_function = ranged_enter_function_3
-- Weapons.staff_spark_spear_template_1_t3.actions.weapon_reload.default.enter_function = ranged_enter_function_3
