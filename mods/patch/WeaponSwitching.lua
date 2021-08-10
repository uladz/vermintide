local mod_name = "WeaponSwitching"

local oi = OptionsInjector

local get = Application.user_setting
local set = Application.set_user_setting
local save = Application.save_user_settings

local MOD_SETTINGS = {
	WEAPONSWITCHING = {
		["save"] = "cb_weapon_switching_enabled",
		["widget_type"] = "stepper",
		["text"] = "Enabled",
		["tooltip"] = "Weapon Switching Fix\n" ..
			"Fixes cases of weapon switch input not being queued up properly, " ..
			"and weapons refusing to switch when holding the right mouse button.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
}

local mod = WeaponSwitching

local function validate_action(unit, action_name, sub_action_name, action_settings, input_extension, inventory_extension, only_check_condition, ammo_extension)
	local skip_hold = action_settings.do_not_validate_with_hold
	local hold_input = not skip_hold and action_settings.hold_input
	local wield_input = CharacterStateHelper.wield_input(input_extension, inventory_extension, action_name)
	local buffered_input = input_extension.get_buffer(input_extension, action_name)
	local action_input = input_extension.get(input_extension, action_name)
	local action_hold_input = hold_input and input_extension.get(input_extension, hold_input)
	local allow_toggle = action_settings.allow_hold_toggle and input_extension.toggle_alternate_attack
	local hold_or_toggle_input = (allow_toggle and action_input) or (not allow_toggle and (action_input or action_hold_input))

	if only_check_condition or wield_input or buffered_input or hold_or_toggle_input then
		local condition_func = action_settings.condition_func
		local condition_passed = nil

		if condition_func then
			condition_passed = condition_func(unit, input_extension, ammo_extension)
		else
			condition_passed = true
		end

		if condition_passed then
			if not wield_input and not action_settings.keep_buffer then
				input_extension.reset_input_buffer(input_extension)
			end

			return action_name, sub_action_name
		end
	end

	return
end

local weapon_action_interrupt_damage_types = {
	cutting = true
}
local interupting_action_data = {}
Mods.hook.set(mod_name, "CharacterStateHelper.update_weapon_actions", function(func, t, unit, input_extension, inventory_extension, damage_extension)
	if not get(MOD_SETTINGS.WEAPONSWITCHING.save) then
		return func(t, unit, input_extension, inventory_extension, damage_extension)
	end

	Profiler.start("weapon_action")

	local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper._get_item_data_and_weapon_extensions(inventory_extension)

	table.clear(interupting_action_data)

	if not item_data then
		Profiler.stop("weapon_action")

		return
	end

	local new_action, new_sub_action, current_action_settings, current_action_extension, current_action_hand = nil
	current_action_settings, current_action_extension, current_action_hand = CharacterStateHelper._get_current_action_data(left_hand_weapon_extension, right_hand_weapon_extension)
	local item_template = BackendUtils.get_item_template(item_data)
	local recent_damage_type = damage_extension.recently_damaged(damage_extension)
	local status_extension = ScriptUnit.extension(unit, "status_system")
	local can_interrupt, reloading = nil
	local player = Managers.player:owner(unit)
	local is_bot_player = player and player.bot_player

	if recent_damage_type and weapon_action_interrupt_damage_types[recent_damage_type] then
		local ammo_extension = (left_hand_weapon_extension and left_hand_weapon_extension.ammo_extension) or (right_hand_weapon_extension and right_hand_weapon_extension.ammo_extension)

		if ammo_extension then
			if left_hand_weapon_extension and left_hand_weapon_extension.ammo_extension then
				reloading = left_hand_weapon_extension.ammo_extension:is_reloading()
			end

			if right_hand_weapon_extension and right_hand_weapon_extension.ammo_extension then
				reloading = right_hand_weapon_extension.ammo_extension:is_reloading()
			end
		end

		if (current_action_settings and current_action_settings.uninterruptible) or script_data.uninterruptible or reloading or is_bot_player then
			can_interrupt = false
		else
			can_interrupt = status_extension.hitreact_interrupt(status_extension)
		end

		if can_interrupt and not status_extension.is_disabled(status_extension) then
			if current_action_settings then
				current_action_extension.stop_action(current_action_extension, "interrupted")
			end

			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")

			CharacterStateHelper.play_animation_event(unit, "hit_reaction")
			status_extension.set_pushed(status_extension, true)
			Profiler.stop("weapon_action")

			return
		end
	end

	if current_action_settings then
		new_action, new_sub_action = CharacterStateHelper._get_streak_action_data(item_template, current_action_extension, current_action_settings, input_extension, inventory_extension, unit, t)

		if not new_action then
			new_action, new_sub_action = CharacterStateHelper._get_chain_action_data(item_template, current_action_extension, current_action_settings, input_extension, inventory_extension, unit, t, is_bot_player)
		end

		if not new_action then
			if current_action_settings.allow_hold_toggle and input_extension.toggle_alternate_attack then
				local input_id = current_action_settings.lookup_data.action_name

				if input_id and input_extension.get(input_extension, input_id, true) and current_action_extension.can_stop_hold_action(current_action_extension, t) then
					current_action_extension.stop_action(current_action_extension, "hold_input_released")
				end
			else
				local input_id = current_action_settings.hold_input

				if input_id and not input_extension.get(input_extension, input_id) and current_action_extension.can_stop_hold_action(current_action_extension, t) then
					current_action_extension.stop_action(current_action_extension, "hold_input_released")
				end
			end
		end
	elseif item_template.next_action then
		local action_data = item_template.next_action
		local action_name = action_data.action
		local only_check_condition = true
		local sub_actions = item_template.actions[action_name]

		for sub_action_name, action_settings in pairs(sub_actions) do
			if sub_action_name ~= "default" and action_settings.condition_func then
				new_action, new_sub_action = validate_action(unit, action_name, sub_action_name, action_settings, input_extension, inventory_extension, only_check_condition)

				if new_action and new_sub_action then
					break
				end
			end
		end

		if not new_action then
			local action_settings = item_template.actions[action_name].default
			new_action, new_sub_action = validate_action(unit, action_name, "default", action_settings, input_extension, inventory_extension, only_check_condition)
		end

		item_template.next_action = nil
	else
		local ammo_extension = (left_hand_weapon_extension and left_hand_weapon_extension.ammo_extension) or (right_hand_weapon_extension and right_hand_weapon_extension.ammo_extension)

		local action_wield_action_name = "action_wield"
		if item_template and item_template.actions[action_wield_action_name] then
			local action_settings = item_template.actions[action_wield_action_name].default
			new_action, new_sub_action = validate_action(unit, action_wield_action_name, "default", action_settings, input_extension, inventory_extension, false, ammo_extension)
		end

		if not new_action then
			local action_reload_action_name = "weapon_reload"
			if (
					item_template and item_template.actions[action_reload_action_name]
					and ( input_extension.get(input_extension, "weapon_reload", false) or input_extension.get(input_extension, "weapon_reload_hold", false) )
				) then
				new_action = action_reload_action_name
				new_sub_action = "default"
			end
		end

		if not new_action then
			for action_name, sub_actions in pairs(item_template.actions) do
				for sub_action_name, action_settings in pairs(sub_actions) do
					if sub_action_name ~= "default" and action_settings.condition_func then
						new_action, new_sub_action = validate_action(unit, action_name, sub_action_name, action_settings, input_extension, inventory_extension, false, ammo_extension)

						if new_action and new_sub_action then
							break
						end
					end
				end

				if not new_action then
					local action_settings = item_template.actions[action_name].default
					new_action, new_sub_action = validate_action(unit, action_name, "default", action_settings, input_extension, inventory_extension, false, ammo_extension)
				end

				if new_action then
					break
				end
			end
		end
	end

	if new_action and new_sub_action then
		local actions = item_template.actions
		local new_action_settings = actions[new_action][new_sub_action]
		local weapon_action_hand = new_action_settings.weapon_action_hand or "right"

		if weapon_action_hand == "both" then
			Profiler.stop("weapon_action")

			return
		end

		if weapon_action_hand == "either" then
			if right_hand_weapon_extension then
				weapon_action_hand = "right"
			else
				weapon_action_hand = "left"
			end
		end

		interupting_action_data.new_action = new_action
		interupting_action_data.new_sub_action = new_sub_action

		if weapon_action_hand == "left" then
			assert(left_hand_weapon_extension, "tried to start a left hand weapon action without a left hand wielded unit")

			if current_action_hand == "right" then
				right_hand_weapon_extension.stop_action(right_hand_weapon_extension, "new_interupting_action", interupting_action_data)
			end

			left_hand_weapon_extension.start_action(left_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)
			Profiler.stop("weapon_action")

			return
		end

		assert(right_hand_weapon_extension, "tried to start a right hand weapon action without a right hand wielded unit")

		if current_action_hand == "left" then
			left_hand_weapon_extension.stop_action(left_hand_weapon_extension, "new_interupting_action", interupting_action_data)
		end

		right_hand_weapon_extension.start_action(right_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)
	end

	Profiler.stop("weapon_action")

	return
end)

local empty_table = {}
Mods.hook.set(mod_name, "CharacterStateHelper._get_chain_action_data", function(func, item_template, current_action_extension, current_action_settings, input_extension, inventory_extension, unit, t, is_bot_player)
	if not get(MOD_SETTINGS.WEAPONSWITCHING.save) then
		return func(item_template, current_action_extension, current_action_settings, input_extension, inventory_extension, unit, t, is_bot_player)
	end

	local chain_actions = current_action_settings.allowed_chain_actions or empty_table
	local new_action, new_sub_action, wield_input, send_buffer, clear_buffer = nil

	for i = 1, #chain_actions, 1 do
		local action_data = chain_actions[i]
		local release_required = action_data.release_required
		local input_extra_requirement = true

		if release_required and not is_bot_player then
			input_extra_requirement = input_extension.released_input(input_extension, release_required)
		end

		local hold_required = action_data.hold_required

		if hold_required and not is_bot_player then
			for index, hold_require in pairs(hold_required) do
				if input_extension.released_input(input_extension, hold_require) then
					input_extra_requirement = false

					break
				end
			end
		end

		local input_id = action_data.input
		local softbutton_threshold = action_data.softbutton_threshold
		local input = nil
		local no_buffer = action_data.no_buffer
		local doubleclick_window = action_data.doubleclick_window
		local blocking_input = action_data.blocking_input
		local blocked = false

		local need_to_switch = CharacterStateHelper.get_buffered_input("wield_switch", input_extension)
		local slots_by_name = InventorySettings.slots_by_name
		local wieldable_slots = InventorySettings.slots_by_wield_input
		local equipment = inventory_extension.equipment(inventory_extension)
		local wielded_slot_name = equipment.wielded_slot
		local current_slot = slots_by_name[wielded_slot_name]
		for index, slot in ipairs(wieldable_slots) do
			if slot ~= current_slot then
				local wield_input = slot.wield_input
				local name = slot.name

				if equipment.slots[name] and CharacterStateHelper.get_buffered_input(wield_input, input_extension) then
					need_to_switch = true
					break
				end
			end
		end

		if not need_to_switch then
			if blocking_input then
				blocked = input_extension.get(input_extension, blocking_input)
			end

			if input_extra_requirement and not blocked then
				input = CharacterStateHelper.get_buffered_input(input_id, input_extension, no_buffer, doubleclick_window, softbutton_threshold)
			end
		end

		if not input then
			wield_input = CharacterStateHelper.wield_input(input_extension, inventory_extension, action_data.action)
			input = wield_input
		end

		local select_chance = action_data.select_chance or 1
		local is_selected = math.random() <= select_chance
		local chain_action_available = current_action_extension.is_chain_action_available(current_action_extension, action_data, t)

		if (input or action_data.auto_chain) and chain_action_available and is_selected then
			local sub_action = action_data.sub_action

			if not sub_action and action_data.first_possible_sub_action then
				local sub_actions = item_template.actions[action_data.action]

				for sub_action_name, data in pairs(sub_actions) do
					local condition_func = data.chain_condition_func

					if not condition_func or condition_func(unit) then
						sub_action = sub_action_name

						break
					end
				end
			end

			if sub_action then
				new_action = action_data.action
				new_sub_action = sub_action
				send_buffer = action_data.send_buffer
				clear_buffer = action_data.clear_buffer
			end

			break
		end
	end

	local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper._get_item_data_and_weapon_extensions(inventory_extension)
	if right_hand_weapon_extension
				and right_hand_weapon_extension.item_name
				and (string.find(right_hand_weapon_extension.item_name, "repeating_handgun") ~= nil
						or string.find(right_hand_weapon_extension.item_name, "rakegun") ~= nil
						or string.find(right_hand_weapon_extension.item_name, "blunderbuss") ~= nil)
			or
				left_hand_weapon_extension
				and left_hand_weapon_extension.item_name
				and (string.find(left_hand_weapon_extension.item_name, "hagbane") ~= nil
						or string.find(left_hand_weapon_extension.item_name, "trueflight") ~= nil)
			then
		for i = 1, #chain_actions, 1 do
			local action_data = chain_actions[i]
			local input_id = action_data.input

			if input_id == "action_wield" then
				wield_input = CharacterStateHelper.wield_input(input_extension, inventory_extension, action_data.action)
				if wield_input then
					local sub_action = action_data.sub_action

					if not sub_action and action_data.first_possible_sub_action then
						local sub_actions = item_template.actions[action_data.action]

						for sub_action_name, data in pairs(sub_actions) do
							local condition_func = data.chain_condition_func

							if not condition_func or condition_func(unit) then
								sub_action = sub_action_name

								break
							end
						end
					end

					if sub_action then
						new_action = action_data.action
						new_sub_action = sub_action
						send_buffer = action_data.send_buffer
						clear_buffer = action_data.clear_buffer
					end
				end
			end
		end
	end

	if new_action then
		local action_settings = item_template.actions[new_action] and item_template.actions[new_action][new_sub_action]
		local condition_func = action_settings and action_settings.chain_condition_func

		if not action_settings or (condition_func and not condition_func(unit, input_extension)) then
			new_action, new_sub_action = nil
		end

		if clear_buffer or new_sub_action == "push" then
			input_extension.clear_input_buffer(input_extension)
		elseif action_settings and not wield_input and not action_settings.keep_buffer then
			input_extension.reset_input_buffer(input_extension)
		end
	end

	return new_action, new_sub_action, wield_input
end)

local function create_options()
	Mods.option_menu:add_group("weapon_switching", "Weapon Switching Fix")

	Mods.option_menu:add_item("weapon_switching", MOD_SETTINGS.WEAPONSWITCHING, true)
end

local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end