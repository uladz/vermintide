--[[
	Ported from VMF 0.17.4 to QoL, version as of 7/3/2017.
	Author: grasmann

	Patch GiveOtherItems:
		Allows all items except for the grim to be given to other players.
		The grim is missing an attribute which crashes the game for players who are not using the mod.

		Set ACTIVATE_GRIM to true to enable grims anyways.
			You can give grims to bots on your own server and players using the mod.
			Players without the mod will crash if you give them a grim and the grim will be lost in spaaaaace.
--]]

local mod_name = "GiveOtherItems"
GiveOtherItems = {}
local mod = GiveOtherItems
local oi = OptionsInjector

mod.widget_settings = {
	MODE = {
		["save"] = "cb_give_other_items_mode",
		["widget_type"] = "dropdown",
		["text"] = "Give Other Items",
		["tooltip"] = "Give other items\n" ..
			"Allows you to give more items to other players.\n\n" ..
			"-- ALL --\nYou can give bombs, med kits and tomes to other players.\n\n" ..
			"-- CUSTOM --\nChoose which items are affected.\n\n",
		["value_type"] = "number",
		["options"] = {
			{text = "Off", value = 1},
			{text = "All", value = 2},
			{text = "Custom", value = 3},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
		["hide_options"] = {
			{
				1,
				mode = "hide",
				options = {
					"cb_give_other_items_bomb",
					"cb_give_other_items_medkit",
					"cb_give_other_items_tome",
				}
			},
			{
				2,
				mode = "hide",
				options = {
					"cb_give_other_items_bomb",
					"cb_give_other_items_medkit",
					"cb_give_other_items_tome",
				}
			},
			{
				3,
				mode = "show",
				options = {
					"cb_give_other_items_bomb",
					"cb_give_other_items_medkit",
					"cb_give_other_items_tome",
				}
			},
		},
	},
	BOMB = {
		["save"] = "cb_give_other_items_bomb",
		["widget_type"] = "checkbox",
		["text"] = "Bomb",
		["default"] = false,
	},
	MEDKIT = {
		["save"] = "cb_give_other_items_medkit",
		["widget_type"] = "checkbox",
		["text"] = "Med Kit",
		["default"] = false,
	},
	TOME = {
		["save"] = "cb_give_other_items_tome",
		["widget_type"] = "checkbox",
		["text"] = "Tome",
		["default"] = false,
	},
	DROP = {
		["save"] = "cb_give_other_items_drop",
		["widget_type"] = "keybind",
		["text"] = "Drop Item",
		["default"] = {
			"mouse_right",
			oi.key_modifiers.ALT,
		},
		["exec"] = {"patch/action", "drop"},
	},
}

mod.activate_grim = false

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("items", "Items")

	Mods.option_menu:add_item("items", mod.widget_settings.MODE, true)
	Mods.option_menu:add_item("items", mod.widget_settings.BOMB)
	Mods.option_menu:add_item("items", mod.widget_settings.MEDKIT)
	Mods.option_menu:add_item("items", mod.widget_settings.TOME)
	Mods.option_menu:add_item("items", mod.widget_settings.DROP, true)
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "InteractionDefinitions.give_item.client.can_interact",
function(func, interactor_unit, interactable_unit, data, config)
	if mod.get(mod.widget_settings.MODE) > 1 then
		-- Check unit
		if not ScriptUnit.has_extension(interactable_unit, "damage_system") or
		   not ScriptUnit.has_extension(interactable_unit, "status_system") then
		   return false
		end

		-- Get unit info
		local health_extension = ScriptUnit.extension(interactable_unit, "health_system")
		local status_extension = ScriptUnit.extension(interactable_unit, "status_system")
		local is_alive = health_extension:is_alive() and not status_extension:is_knocked_down()
		local interactor_inventory_extension = ScriptUnit.extension(interactor_unit, "inventory_system")
		local item_template = interactor_inventory_extension:get_wielded_slot_item_template()

		-- Check item
		if not item_template then
			return false
		end

		--if item_template.is_grimoire then
		--	return false
		--end

		-- Get item info
		local slot_name = interactor_inventory_extension:get_wielded_slot_name()
		if item_template.pickup_data or (slot_name == "slot_potion" and mod.activate_grim) then
			local pickup_name
			if slot_name == "slot_potion" and mod.activate_grim then
				pickup_name = "tome"
			else
				pickup_name = item_template.pickup_data.pickup_name
			end

			local mode = mod.get(mod.widget_settings.MODE)
			local bomb = mod.get(mod.widget_settings.BOMB)
			local kit = mod.get(mod.widget_settings.MEDKIT)
			local tome = mod.get(mod.widget_settings.TOME)
			if (string.find(pickup_name, "grenade") and (mode == 2 or (mode == 3 and bomb)))
			or (pickup_name == "first_aid_kit" and (mode == 2 or (mode == 3 and kit)))
			or (pickup_name == "tome" and (mode == 2 or (mode == 3 and tome))) then
				-- Get inventory info
				local target_inventory_extension = ScriptUnit.extension(interactable_unit, "inventory_system")
				--local slot_name = interactor_inventory_extension.get_wielded_slot_name(interactor_inventory_extension)
				local slot_occupied = target_inventory_extension:get_slot_data(slot_name)
				--return is_alive and not slot_occupied <- Alternative return
				return is_alive and not slot_occupied
			end
		end
	end

	return func(interactor_unit, interactable_unit, data, config)
end)

Mods.hook.set(mod_name, "InteractionDefinitions.give_item.client.stop",
function(func, world, interactor_unit, interactable_unit, data, config, t, result)
	if mod.get(mod.widget_settings.MODE) > 1 then
		local pickup_name = ""
		local interactor_inventory_extension = ScriptUnit.extension(interactor_unit, "inventory_system")
		local item_template = interactor_inventory_extension:get_wielded_slot_item_template()

		if item_template.pickup_data then
			pickup_name = item_template.pickup_data.pickup_name
		else
			local slot_name = interactor_inventory_extension:get_wielded_slot_name()
			if slot_name == "slot_potion" then
				pickup_name = "tome"
			end
		end

		local mode = mod.get(mod.widget_settings.MODE)
		local bomb = mod.get(mod.widget_settings.BOMB)
		local kit = mod.get(mod.widget_settings.MEDKIT)
		local tome = mod.get(mod.widget_settings.TOME)

		if (string.find(pickup_name, "grenade") and (mode == 2 or (mode == 3 and bomb)))
		or (pickup_name == "first_aid_kit" and (mode == 2 or (mode == 3 and kit)))
		or (pickup_name == "tome" and (mode == 2 or (mode == 3 and tome))) then
			-- Execute
			data.start_time = nil
			Unit.animation_event(interactor_unit, "interaction_end")
			if result == InteractionResult.SUCCESS then
				local interactor_player = Managers.player:owner(interactor_unit)

				if interactor_player and not interactor_player.remote then
					local inventory_extension = ScriptUnit.extension(interactor_unit, "inventory_system")
					local equipment = inventory_extension:equipment()
					local wielded_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit
					local ammo_extension = ScriptUnit.extension(wielded_unit, "ammo_system")
					ammo_extension.use_ammo(ammo_extension, 1)
					if not LEVEL_EDITOR_TEST then
						local game_object_id = Managers.state.unit_storage:go_id(interactable_unit)
						local slot_name = inventory_extension:get_wielded_slot_name()
						local slot_data = inventory_extension:get_slot_data(slot_name)
						local slot_id = NetworkLookup.equipment_slots[slot_name]
						local item_name_id = NetworkLookup.item_names[slot_data.item_data.name]
						local position = POSITION_LOOKUP[interactable_unit] + Vector3(0, 0, 1.5)
						Managers.state.network.network_transmit:send_rpc_server("rpc_give_equipment",
							game_object_id, slot_id, item_name_id, position)
					end
				end
			end
			return
		end
	end

	func(world, interactor_unit, interactable_unit, data, config, t, result)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
if mod.activate_grim then
	Weapons.wpn_grimoire_01.pickup_data = {pickup_name = "tome"}
	Weapons.wpn_grimoire_01.can_give_other = true
end

mod.create_options()
