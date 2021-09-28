local mod_name = "BoltChargeSound"

Mods.hook.set(mod_name, "ActionTrueFlightBowAim.client_owner_start_action", function(func, self, new_action, t, chain_action_data)
	func(self, new_action, t, chain_action_data)
	
	self.played_bolt_aim_sound_1 = false
	self.played_bolt_aim_sound_2 = false
	self.played_bolt_aim_sound_3 = false
	self.bolt_aim_sound_time_1 = t + (new_action.bolt_aim_sound_delay_1 or 0)
	self.bolt_aim_sound_time_2 = t + (new_action.bolt_aim_sound_delay_2 or 0)
	self.bolt_aim_sound_time_3 = t + (new_action.bolt_aim_sound_delay_3 or 0)
end)

Mods.hook.set(mod_name, "ActionTrueFlightBowAim.client_owner_post_update", function(func, self, dt, t, world, can_damage)
	func(self, dt, t, world, can_damage)
	
	local current_action = self.current_action
	
	if not self.played_bolt_aim_sound_1 and self.bolt_aim_sound_time_1 <= t and not Managers.player:owner(self.owner_unit).bot_player then
		Managers.state.controller_features:add_effect("rumble", {
			rumble_effect = "aim_start"
		})

		local sound_event = current_action.bolt_aim_sound_event

		if sound_event then
			local wwise_world = self.wwise_world

			WwiseWorld.trigger_event(wwise_world, sound_event)
		end

		self.played_bolt_aim_sound_1 = true
	end
	
	if not self.played_bolt_aim_sound_2 and self.bolt_aim_sound_time_2 <= t and not Managers.player:owner(self.owner_unit).bot_player then
		Managers.state.controller_features:add_effect("rumble", {
			rumble_effect = "aim_start"
		})

		local sound_event = current_action.bolt_aim_sound_event

		if sound_event then
			local wwise_world = self.wwise_world

			WwiseWorld.trigger_event(wwise_world, sound_event)
		end

		self.played_bolt_aim_sound_2 = true
	end
	
	if not self.played_bolt_aim_sound_3 and self.bolt_aim_sound_time_3 <= t and not Managers.player:owner(self.owner_unit).bot_player then
		Managers.state.controller_features:add_effect("rumble", {
			rumble_effect = "aim_start"
		})

		local sound_event = current_action.bolt_aim_sound_event

		if sound_event then
			local wwise_world = self.wwise_world

			WwiseWorld.trigger_event(wwise_world, sound_event)
		end

		self.played_bolt_aim_sound_3 = true
	end
end)

Weapons.staff_spark_spear_template_1.actions.action_two.default.bolt_aim_sound_delay_1 = 0.5
Weapons.staff_spark_spear_template_1.actions.action_two.default.bolt_aim_sound_delay_2 = 0.8
Weapons.staff_spark_spear_template_1.actions.action_two.default.bolt_aim_sound_delay_3 = 1.25
Weapons.staff_spark_spear_template_1.actions.action_two.default.bolt_aim_sound_event = "player_combat_weapon_staff_fireball_fire"

Weapons.staff_spark_spear_template_1_co.actions.action_two.default.bolt_aim_sound_delay_1 = 0.5
Weapons.staff_spark_spear_template_1_co.actions.action_two.default.bolt_aim_sound_delay_2 = 0.8
Weapons.staff_spark_spear_template_1_co.actions.action_two.default.bolt_aim_sound_delay_3 = 1.25
Weapons.staff_spark_spear_template_1_co.actions.action_two.default.bolt_aim_sound_event = "player_combat_weapon_staff_fireball_fire"

Weapons.staff_spark_spear_template_1_t2.actions.action_two.default.bolt_aim_sound_delay_1 = 0.5
Weapons.staff_spark_spear_template_1_t2.actions.action_two.default.bolt_aim_sound_delay_2 = 0.8
Weapons.staff_spark_spear_template_1_t2.actions.action_two.default.bolt_aim_sound_delay_3 = 1.25
Weapons.staff_spark_spear_template_1_t2.actions.action_two.default.bolt_aim_sound_event = "player_combat_weapon_staff_fireball_fire"

Weapons.staff_spark_spear_template_1_t3.actions.action_two.default.bolt_aim_sound_delay_1 = 0.5
Weapons.staff_spark_spear_template_1_t3.actions.action_two.default.bolt_aim_sound_delay_2 = 0.8
Weapons.staff_spark_spear_template_1_t3.actions.action_two.default.bolt_aim_sound_delay_3 = 1.25
Weapons.staff_spark_spear_template_1_t3.actions.action_two.default.bolt_aim_sound_event = "player_combat_weapon_staff_fireball_fire"
