local mod_name = "BowDoubleShotFix"

local ranged_enter_function_hook = function(func, attacker_unit, input_extension)
	input_extension:clear_input_buffer()

	return input_extension:reset_release_input()
end

Mods.hook.set(mod_name, "Weapons.longbow_template_1.actions.action_one.shoot_charged.enter_function", ranged_enter_function_hook)
Mods.hook.set(mod_name, "Weapons.longbow_template_1_co.actions.action_one.shoot_charged.enter_function", ranged_enter_function_hook)
Mods.hook.set(mod_name, "Weapons.longbow_template_1_t2.actions.action_one.shoot_charged.enter_function", ranged_enter_function_hook)
Mods.hook.set(mod_name, "Weapons.longbow_template_1_t3.actions.action_one.shoot_charged.enter_function", ranged_enter_function_hook)

local ranged_enter_function = function(attacker_unit, input_extension)
	input_extension:clear_input_buffer()

	return input_extension:reset_release_input()
end

Weapons.shortbow_hagbane_template_1.actions.action_one.shoot_charged.enter_function = ranged_enter_function
Weapons.shortbow_hagbane_template_1_co.actions.action_one.shoot_charged.enter_function = ranged_enter_function
Weapons.shortbow_hagbane_template_1_t2.actions.action_one.shoot_charged.enter_function = ranged_enter_function
Weapons.shortbow_hagbane_template_1_t3.actions.action_one.shoot_charged.enter_function = ranged_enter_function
