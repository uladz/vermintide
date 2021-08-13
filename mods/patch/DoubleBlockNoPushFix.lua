--[[
	Double Block No Push Fix
	By: VernonKun

	Without the fix, if you take any melee weapon and double tap right click to block, your next push
	will be cancelled and you might get hit trying to push. This mod fixes the bug.

	The bug is also described in doom_hamster's video (0:14 - 3:23):
	https://www.youtube.com/watch?v=umKIgEUDXaY

	Codes are copied and modified from Vermintide 2 source code, as the same bug is officially fixed
	there.

	Installation: Place the file under mods/patch.
--]]

local mod_name = "DoubleBlockNoPushFix"

local AllMeleeWeaponTemplates = {}

local function enter_function_with_delay_hook(func, attacker_unit, input_extension, remaining_time)
	return input_extension:reset_release_input_with_delay(remaining_time)
end

if not DoubleBlockNoPushFixToken then
	DoubleBlockNoPushFixToken = true

	for item_name, item in pairs(ItemMasterList) do
		if item.slot_type == "melee" then
			if not table.contains(AllMeleeWeaponTemplates, item.template) then
				AllMeleeWeaponTemplates[#AllMeleeWeaponTemplates+1] = item.template
			end
		end
	end
end

for _, template in pairs(AllMeleeWeaponTemplates) do
	Mods.hook.set(mod_name, "Weapons." .. template .. ".actions.action_two.default.enter_function", enter_function_with_delay_hook)
end

PlayerInputExtension.reset_release_input_with_delay = function (self, delay)
	self._release_input_delay = (self._release_input_delay and self._release_input_delay + delay) or delay
end

PlayerBotInput.reset_release_input_with_delay = function (self)
	return true
end

Mods.hook.set(mod_name, "PlayerInputExtension.update", function(func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)

	if self._release_input_delay then
		self._release_input_delay = self._release_input_delay - dt

		if self._release_input_delay <= 0 then
			self._release_input_delay = nil

			self:reset_release_input()
		end
	end
end)

local action_classes = {
	charge = ActionCharge,
	dummy = ActionDummy,
	wield = ActionWield,
	handgun = ActionHandgun,
	interaction = ActionInteraction,
	self_interaction = ActionSelfInteraction,
	push_stagger = ActionPushStagger,
	sweep = ActionSweep,
	block = ActionBlock,
	throw = ActionThrow,
	staff = ActionStaff,
	bow = ActionBow,
	true_flight_bow = ActionTrueFlightBow,
	true_flight_bow_aim = ActionTrueFlightBowAim,
	crossbow = ActionCrossbow,
	cancel = ActionCancel,
	buff = ActionPotion,
	handgun_lock_targeting = ActionHandgunLockTargeting,
	handgun_lock = ActionHandgunLock,
	bullet_spray_targeting = ActionBulletSprayTargeting,
	bullet_spray = ActionBulletSpray,
	aim = ActionAim,
	shotgun = ActionShotgun,
	shield_slam = ActionShieldSlam,
	charged_projectile = ActionChargedProjectile,
	beam = ActionBeam,
	geiser_targeting = ActionGeiserTargeting,
	geiser = ActionGeiser,
	instant_wield = ActionInstantWield,
	throw_grimoire = ActionThrowGrimoire,
	healing_draught = ActionHealingDraught
}

local function create_attack(item_name, attack_kind, world, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	return action_classes[attack_kind]:new(world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
end

local interupting_action_data = {}

Mods.hook.set(mod_name, "WeaponUnitExtension.start_action", function(func, self, action_name, sub_action_name, actions, t)
	local first_person_extension = ScriptUnit.extension(self.owner_unit, "first_person_system")
	local current_action_settings = self.current_action_settings
	local new_action = action_name
	local new_sub_action = sub_action_name

	table.clear(interupting_action_data)

	if t < self.cooldown_timer and new_action then
		local action_settings = self:get_action(new_action, new_sub_action, actions)

		if action_settings.cooldown ~= nil then
			new_action, new_sub_action = nil
		end
	end

	if new_action then
		local action_settings = self:get_action(new_action, new_sub_action, actions)
		local action_kind = action_settings.kind
		self.actions[action_kind] = self.actions[action_kind] or create_attack(self.item_name, action_kind, self.world, self.is_server, self.owner_unit, self.actual_damage_unit, self.first_person_unit, self.unit, self.weapon_system)
	end

	local ammo_extension = self.ammo_extension

	if ammo_extension ~= nil and new_action then
		local action = self:get_action(new_action, new_sub_action, actions)
		local ammo_requirement = action.ammo_requirement or action.ammo_usage or 0
		local ammo_count = ammo_extension:ammo_count()
		local action_can_abort_reload = (action.can_abort_reload == nil and true) or action.can_abort_reload

		if ammo_extension:is_reloading() then
			if ammo_requirement <= ammo_count and action_can_abort_reload then
				ammo_extension:abort_reload()
			else
				new_action, new_sub_action = nil
			end
		elseif ammo_count < ammo_requirement then
			if ammo_extension:total_remaining_ammo() == 0 then
				local dialogue_input = ScriptUnit.extension_input(self.owner_unit, "dialogue_system")
				local event_data = FrameTable.alloc_table()
				event_data.fail_reason = "out_of_ammo"
				event_data.item_name = self.item_name or "UNKNOWN WEAPON"
				local event_name = "reload_failed"

				dialogue_input:trigger_dialogue_event(event_name, event_data)
			end

			new_action, new_sub_action = nil
		end
	end

	local chain_action_data = nil

	if new_action and current_action_settings then
		interupting_action_data.new_action = new_action
		interupting_action_data.new_sub_action = new_sub_action
		chain_action_data = self:_finish_action("new_interupting_action", interupting_action_data)
	end

	if new_action then
		local owner_unit = self.owner_unit
		local locomotion_extension = ScriptUnit.extension(owner_unit, "locomotion_system")

		if locomotion_extension:is_stood_still() then
			local look_rotation = first_person_extension:current_rotation()

			locomotion_extension:set_stood_still_target_rotation(look_rotation)
		end

		local first_person_unit = self.first_person_unit

		Unit.animation_event(first_person_unit, "equip_interrupt")

		current_action_settings = self:get_action(new_action, new_sub_action, actions)
		self.current_action_settings = current_action_settings

		table.clear(self.chain_action_sound_played)

		for action_name, chain_info in pairs(current_action_settings.allowed_chain_actions) do
			self.chain_action_sound_played[action_name] = false
		end

		local action_kind = current_action_settings.kind
		local action = self.actions[action_kind]
		local time_to_complete = current_action_settings.total_time

		if current_action_settings.scale_total_time_on_mastercrafted then
			local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")

			if buff_extension then
				time_to_complete = buff_extension:apply_buffs_to_value(time_to_complete, StatBuffIndex.RELOAD_SPEED)
			end
		end

		local event = current_action_settings.anim_event

		for _, data in pairs(self.action_buff_data) do
			table.clear(data)
		end

		local buff_data = current_action_settings.buff_data

		if buff_data then
			ActionUtils.init_action_buff_data(self.action_buff_data, buff_data, t)

			self.buff_data = buff_data
		end

		action:client_owner_start_action(current_action_settings, t, chain_action_data)

		local aim_assist_ramp_multiplier = current_action_settings.aim_assist_ramp_multiplier

		if aim_assist_ramp_multiplier then
			local aim_assist_max_ramp_multiplier = current_action_settings.aim_assist_max_ramp_multiplier
			local aim_assist_ramp_decay_delay = current_action_settings.aim_assist_ramp_decay_delay

			first_person_extension:increase_aim_assist_multiplier(aim_assist_ramp_multiplier, aim_assist_max_ramp_multiplier, aim_assist_ramp_decay_delay)
		end

		if self.ammo_extension then
			if self.ammo_extension:total_remaining_ammo() == 0 then
				event = current_action_settings.anim_event_no_ammo_left or event
			elseif self.ammo_extension:total_remaining_ammo() == 1 then
				event = current_action_settings.anim_event_last_ammo or event
			end
		end

		self.action_time_started = t
		self.action_time_done = t + time_to_complete

		if current_action_settings.cooldown then
			self.cooldown_timer = t + current_action_settings.cooldown
		end
--edit--
		-- if current_action_settings.enter_function then
			-- local input_extension = ScriptUnit.extension(owner_unit, "input_system")

			-- current_action_settings.enter_function(owner_unit, input_extension)
		-- end
		if current_action_settings.enter_function then
			local minimum_hold_time = self:get_scaled_min_hold_time(current_action_settings)
			local push_start_time = self:get_scaled_push_start_time(current_action_settings)
			local input_extension = ScriptUnit.extension(owner_unit, "input_system")
			--local remaining_time = (self.action_time_started + minimum_hold_time) - t
			--local remaining_time = (self.action_time_started + push_start_time) - t
			local remaining_time = (self.action_time_started + math.min(minimum_hold_time, push_start_time)) - t

			current_action_settings.enter_function(owner_unit, input_extension, remaining_time)
		end
--edit--
		if event then
			local anim_time_scale = current_action_settings.anim_time_scale or 1
			anim_time_scale = ActionUtils.apply_attack_speed_buff(anim_time_scale, owner_unit)
			local go_id = Managers.state.unit_storage:go_id(owner_unit)
			local event_id = NetworkLookup.anims[event]
			local variable_id = NetworkLookup.anims.attack_speed

			if not LEVEL_EDITOR_TEST then
				if self.is_server then
					Managers.state.network.network_transmit:send_rpc_clients("rpc_anim_event_variable_float", event_id, go_id, variable_id, anim_time_scale)
				else
					Managers.state.network.network_transmit:send_rpc_server("rpc_anim_event_variable_float", event_id, go_id, variable_id, anim_time_scale)
				end
			end

			if PLATFORM ~= "win32" and event == "attack_shoot" then
				anim_time_scale = anim_time_scale * 1.2
			end

			local first_person_variable_id = Unit.animation_find_variable(first_person_unit, "attack_speed")

			Unit.animation_set_variable(first_person_unit, first_person_variable_id, anim_time_scale)
			Unit.animation_event(first_person_unit, event)

			local third_person_variable_id = Unit.animation_find_variable(owner_unit, "attack_speed")

			Unit.animation_set_variable(owner_unit, third_person_variable_id, anim_time_scale)
			Unit.animation_event(owner_unit, event)

			if current_action_settings.apply_recoil then
				local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
				local user_setting = Application.user_setting
				local HAS_TOBII = rawget(_G, "Tobii") and Tobii.device_status() == Tobii.DEVICE_TRACKING and user_setting("tobii_eyetracking")
				local tobii_extended_view_enabled = user_setting("tobii_extended_view")

				if not HAS_TOBII or (HAS_TOBII and not tobii_extended_view_enabled) then
					first_person_extension:apply_recoil(current_action_settings.recoil_factor)
				end
			end
		end
	end
end)

WeaponUnitExtension.get_scaled_min_hold_time = function (self, action)
	local minimum_hold_time = action.minimum_hold_time

	if not minimum_hold_time then
		return 0
	end

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local scaled_min_hold_time = minimum_hold_time

	if buff_extension then
		scaled_min_hold_time = buff_extension:apply_buffs_to_value(scaled_min_hold_time, StatBuffIndex.RELOAD_SPEED)

		if scaled_min_hold_time > 0 then
			local attack_speed_modifier = 1
			attack_speed_modifier = ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit)

			scaled_min_hold_time = scaled_min_hold_time / attack_speed_modifier
		end
	end

	return scaled_min_hold_time
end

local function find_chained_attack(attack_chain, sub_action_name)
	for i, link in ipairs(attack_chain) do
		if link.input == "action_one" and link.action == "action_one" and link.sub_action == sub_action_name then
			return i, link
		end
	end
	return nil, nil
end

WeaponUnitExtension.get_scaled_push_start_time = function (self, action)
	local allowed_chain_actions = action.allowed_chain_actions
	if not allowed_chain_actions then
		return 0
	end

	local _, push_chain_action = find_chained_attack(allowed_chain_actions, "push")
	if not push_chain_action then
		return 0
	end

	local push_start_time = push_chain_action.start_time

	local buff_extension = ScriptUnit.extension(self.owner_unit, "buff_system")
	local scaled_push_start_time = push_start_time

	if buff_extension then
		scaled_push_start_time = buff_extension:apply_buffs_to_value(scaled_push_start_time, StatBuffIndex.RELOAD_SPEED)

		if scaled_push_start_time > 0 then
			local attack_speed_modifier = 1
			attack_speed_modifier = ActionUtils.apply_attack_speed_buff(attack_speed_modifier, self.owner_unit)

			scaled_push_start_time = scaled_push_start_time / attack_speed_modifier
		end
	end

	return scaled_push_start_time
end
