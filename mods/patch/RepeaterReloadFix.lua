--[[
	Name: Repeater Reload Fix (for Repeater Handgun & Repeater Pistol)
	Author: VernonKun
	Updated: 6/2/2020

	Without the fix, if you right click to start spin and press reload swiftly, bugged audio and
	animation will be played. It will be reloading without reload animation, or spinning without
	spinning animation. (This can be viewed as a feature because it allows you to reload and spin at
	the same time, at the cost of bugged animation.) This mod intends to fix the bug. Currently I
	made reload uninterruptible by spinning.

	The bug is shown in my video:
	https://www.youtube.com/watch?v=4VwnVIJ2O60

	To do:
	* Allow spinning to interrupt reload when right mouse button is held down after reload begins,
		but not when right mouse button is held down before reload begins.
--]]

local mod_name = "RepeaterReloadFix"

local function ranged_condition_func_hook(func, unit, input_extension, ammo_extension)
	if ammo_extension and (ammo_extension:total_remaining_ammo() <= 0 or ammo_extension:is_reloading()) then
		return false
	end

	return true
end

Mods.hook.set(mod_name, "Weapons.repeating_pistol_template_1.actions.action_two.default.condition_func", ranged_condition_func_hook)
Mods.hook.set(mod_name, "Weapons.repeating_pistol_template_1_co.actions.action_two.default.condition_func", ranged_condition_func_hook)
Mods.hook.set(mod_name, "Weapons.repeating_pistol_template_1_t2.actions.action_two.default.condition_func", ranged_condition_func_hook)
Mods.hook.set(mod_name, "Weapons.repeating_pistol_template_1_t3.actions.action_two.default.condition_func", ranged_condition_func_hook)

Mods.hook.set(mod_name, "Weapons.repeating_handgun_template_1.actions.action_two.default.condition_func", ranged_condition_func_hook)
Mods.hook.set(mod_name, "Weapons.repeating_handgun_template_1_co.actions.action_two.default.condition_func", ranged_condition_func_hook)
Mods.hook.set(mod_name, "Weapons.repeating_handgun_template_1_t2.actions.action_two.default.condition_func", ranged_condition_func_hook)
Mods.hook.set(mod_name, "Weapons.repeating_handgun_template_1_t3.actions.action_two.default.condition_func", ranged_condition_func_hook)

Mods.hook.set(mod_name, "ActionAim.client_owner_post_update", function (func, self, dt, t, world, can_damage)
	func(self, dt, t, world, can_damage)

	local item_data = ItemMasterList[self.item_name]
	local item_type = item_data.item_type

	if item_type == "wh_repeating_pistol" or item_type == "es_repeating_handgun" then
		local input_extension = ScriptUnit.extension(self.owner_unit, "input_system")
		local ammo_extension = self.ammo_extension

		--if (input_extension:get("weapon_reload") or input_extension:get_buffer("weapon_reload")) and ammo_extension:can_reload() then
		if input_extension:get("weapon_reload") and ammo_extension:can_reload() then
			local weapon_extension = ScriptUnit.extension(self.weapon_unit, "weapon_system")

			weapon_extension:stop_action("reload")

			local play_reload_animation = true

			ammo_extension:start_reload(play_reload_animation)

			input_extension:reset_release_input()
			input_extension:clear_input_buffer()
		end
	end
end)

--This stops the default reload mechanics
Weapons.repeating_handgun_template_1.actions.action_two.default.active_reload_time = 0
Weapons.repeating_handgun_template_1_co.actions.action_two.default.active_reload_time = 0
Weapons.repeating_handgun_template_1_t2.actions.action_two.default.active_reload_time = 0
Weapons.repeating_handgun_template_1_t3.actions.action_two.default.active_reload_time = 0

Weapons.repeating_pistol_template_1.actions.action_two.default.active_reload_time = 0
Weapons.repeating_pistol_template_1_co.actions.action_two.default.active_reload_time = 0
Weapons.repeating_pistol_template_1_t2.actions.action_two.default.active_reload_time = 0
Weapons.repeating_pistol_template_1_t3.actions.action_two.default.active_reload_time = 0

local ranged_enter_function = function(attacker_unit, input_extension)
	input_extension:clear_input_buffer()

	return input_extension:reset_release_input()
end

--Affect Repeater Reload Fix?
Weapons.repeating_pistol_template_1.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_pistol_template_1_co.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_pistol_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_pistol_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function

Weapons.repeating_handgun_template_1.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_handgun_template_1_co.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_handgun_template_1_t2.actions.action_two.default.enter_function = ranged_enter_function
Weapons.repeating_handgun_template_1_t3.actions.action_two.default.enter_function = ranged_enter_function
