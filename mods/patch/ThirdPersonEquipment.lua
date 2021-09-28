ThirdPersonEquipment = {}
local mod = ThirdPersonEquipment

local mod_name = "ThirdPersonEquipment"

local oi = OptionsInjector

mod.get = Application.user_setting
mod.set = Application.set_user_setting
mod.save = Application.save_user_settings

-- Global to keep track of spawned units
equipment_3p_spawned_items = equipment_3p_spawned_items or {}

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_visible_3p_equipment_active",
		["widget_type"] = "stepper",
		["text"] = "Third Person Equipment",
		["tooltip"] =  "Third Person Equipment\n" ..
			"Toggle third person equipment on / off.\n\n" ..
			"Shows your equipment on your character.\n" ..
			"Works for yourself, other players and bots.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1,
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
                    "cb_visible_3p_equipment_performance_mode",
					"cb_visible_3p_equipment_dwarf_weapons",
					"cb_visible_3p_equipment_1h_weapons",
					"cb_visible_3p_equipment_waywatcher_dual_weapons",
					"cb_visible_3p_equipment_dwarf_one_handed_weapons",
					"cb_visible_3p_equipment_downscale_big_weapons",
				},
			},
			{
				true,
				mode = "show",
				options = {
                    "cb_visible_3p_equipment_performance_mode",
					"cb_visible_3p_equipment_dwarf_weapons",
					"cb_visible_3p_equipment_1h_weapons",
					"cb_visible_3p_equipment_waywatcher_dual_weapons",
					"cb_visible_3p_equipment_dwarf_one_handed_weapons",
					"cb_visible_3p_equipment_downscale_big_weapons",
				},
			},
		},
	},
	PERFORMANCE_MODE = {
		["save"] = "cb_visible_3p_equipment_performance_mode",
		["widget_type"] = "checkbox",
		["text"] = "Performance Mode",
		["tooltip"] =  "Hide Consumables\n" ..
                       "Only render melee and ranged weapons for third person equipment.\n" ..
                       "Books and consumables will not be rendered.",
		["default"] = false,
	},
	DWARF_WEAPONS_POSITION = {
		["save"] = "cb_visible_3p_equipment_dwarf_weapons",
		["widget_type"] = "dropdown",
		["text"] = "Dwarf Weapon Position",
		["tooltip"] =  "Dwarf Weapon Position\n" ..
			"Choose the position of the dwarf weapons.\n\n" ..
			"-- Backpack --\n" ..
			"Weapons will be placed on the backpack.\n\n" ..
			"-- Back --\n" ..
			"Weapons will be placed on the back.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Backpack", value = 1},
			{text = "Back", value = 2},
		},
		["default"] = 1,
	},
	DWARF_ONE_HANDED_WEAPONS_POSITION = {
		["save"] = "cb_visible_3p_equipment_dwarf_one_handed_weapons",
		["widget_type"] = "dropdown",
		["text"] = "Dwarf One-Handed Weapon Position",
		["tooltip"] =  "Dwarf One-Handed Weapon Position\n" ..
			"Choose the position of the one-handed dwarf weapons.\n\n" ..
			"-- Default --\n" ..
			"Uses dwarf weapon position.\n\n" ..
			"-- Belt --\n" ..
			"Weapons will be placed on the belt.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Dwarf Weapon Position", value = 1},
			{text = "Belt", value = 2},
			{text = "Back", value = 3},
		},
		["default"] = 1,
	},
	WAYWATCHER_DUAL_WEAPONS_POSITION = {
		["save"] = "cb_visible_3p_equipment_waywatcher_dual_weapons",
		["widget_type"] = "dropdown",
		["text"] = "Waywatcher Dual Weapon Position",
		["tooltip"] =  "Waywatcher Dual Weapon Position\n" ..
			"Choose the position of the waywatcher dual weapons.\n\n" ..
			"-- Belt --\n" ..
			"Weapons will be placed on the belt.\n\n" ..
			"-- Back --\n" ..
			"Weapons will be placed on the back.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Belt", value = 1},
			{text = "Back", value = 2},
		},
		["default"] = 1,
	},
	ONE_HANDED_WEAPONS_POSITION = {
		["save"] = "cb_visible_3p_equipment_1h_weapons",
		["widget_type"] = "dropdown",
		["text"] = "One-Handed Weapon Position",
		["tooltip"] =  "One-Handed Weapon Position\n" ..
			"Choose the position of the one-handed weapons.\n\n" ..
			"-- Belt --\n" ..
			"Weapons will be placed on the belt.\n\n" ..
			"-- Back --\n" ..
			"Weapons will be placed on the back.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Belt", value = 1},
			{text = "Back", value = 2},
		},
		["default"] = 1,
	},
	DOWNSCALE_BIG_WEAPONS = {
		["save"] = "cb_visible_3p_equipment_downscale_big_weapons",
		["widget_type"] = "slider",
		["text"] = "Downscale Big Weapons",
		["tooltip"] =  "Downscale Big Weapons\n" ..
			"Downscale the biggest weapons in the game.\n\n" ..
			"Affects: Red staffs, volley crossbow, wh crossbow",
		["range"] = {50, 100},
		["default"] = 75,
	},
}

mod.current = {
	slot = {},
	equipment = {},
	profile = {},
}
mod.options = {}

-- ####################################################################################################################
-- ##### Option #######################################################################################################
-- ####################################################################################################################
mod.create_options = function(self)
	Mods.option_menu:add_group("visible_3p_equipment", "Third Person Equipment")
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.ACTIVE, true)
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.PERFORMANCE_MODE)
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.ONE_HANDED_WEAPONS_POSITION)
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.DWARF_WEAPONS_POSITION)
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION)
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION)
	Mods.option_menu:add_item("visible_3p_equipment", self.widget_settings.DOWNSCALE_BIG_WEAPONS)
	
	self.options[self.widget_settings.DWARF_WEAPONS_POSITION.save] = self.get(self.widget_settings.DWARF_WEAPONS_POSITION.save)
	self.options[self.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save] = self.get(self.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save)
	self.options[self.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save] = self.get(self.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save)
	self.options[self.widget_settings.ONE_HANDED_WEAPONS_POSITION.save] = self.get(self.widget_settings.ONE_HANDED_WEAPONS_POSITION.save)
	self.options[self.widget_settings.DOWNSCALE_BIG_WEAPONS.save] = self.get(self.widget_settings.DOWNSCALE_BIG_WEAPONS.save)
end

-- ####################################################################################################################
-- ##### Functionality ################################################################################################
-- ####################################################################################################################
--[[
	Delete all spawned units
--]]
mod.delete_all_units = function(self)
	if equipment_3p_spawned_items then
		for _, unit in pairs(equipment_3p_spawned_items) do
			if unit ~= nil and Unit.alive(unit) then
				local world = Managers.world:world("level_world")
				World.destroy_unit(world, unit)
			end
		end
		equipment_3p_spawned_items = {}
		self.current.equipment = {}
	end
end
--[[
	Delete specific i_unit
--]]
mod.delete_i_unit = function(self, i_unit)
	if i_unit.right ~= nil then
		equipment_3p_spawned_items[i_unit.right] = nil
		if Unit.alive(i_unit.right) then
			local world = Managers.world:world("level_world")
			World.destroy_unit(world, i_unit.right)
		end
	end
	if i_unit.left ~= nil then
		equipment_3p_spawned_items[i_unit.left] = nil
		if Unit.alive(i_unit.left) then
			local world = Managers.world:world("level_world")
			World.destroy_unit(world, i_unit.left)
		end
	end
end
--[[
	Delete spawned units for specific character
--]]
mod.delete_units = function(self, unit)
	if self.current.equipment[unit] then
		for _, i_unit in pairs(self.current.equipment[unit]) do
			mod:delete_i_unit(i_unit)
		end
		self.current.equipment[unit] = nil
	end
end
--[[
	Spawn equipment unit
--]]
mod.spawn = function(self, package_name, unit, item_setting)
	local s_unit = nil
	local world = Managers.world:world("level_world")
	local unit_spawner = Managers.state.unit_spawner
	local node = Unit.node(unit, item_setting.node)
	
	s_unit = World.spawn_unit(world, package_name)
	World.link_unit(world, s_unit, unit, node)
	equipment_3p_spawned_items[s_unit] = s_unit
	
	local i_pos = item_setting.position
	local pos_offset = i_pos ~= nil and Vector3(i_pos[1], i_pos[2], i_pos[3]) or Vector3(0,0,0)
	Unit.teleport_local_position(s_unit, 0, pos_offset)
	
	local i_rot = item_setting.rotation
	local rot_offset = i_rot ~= nil and Vector3(i_rot[1], i_rot[2], i_rot[3]) or Vector3(0,0,0)
	local rotation = Quaternion.from_euler_angles_xyz(rot_offset[1], rot_offset[2], rot_offset[3])
	Unit.teleport_local_rotation(s_unit, 0, rotation) 
	
	-- Hardcoded scaling
	local grim = "units/weapons/player/wpn_grimoire_01/wpn_grimoire_01_3p"
	local tome = "units/weapons/player/wpn_side_objective_tome/wpn_side_objective_tome_01_3p"
	if package_name == grim or package_name == tome then
		Unit.teleport_local_scale(s_unit, 0, Vector3(0.75, 0.75, 0.75))
	end
	-- Option scaling
	local scaling = self.get(self.widget_settings.DOWNSCALE_BIG_WEAPONS.save) / 100
	local staff = "units/weapons/player/wpn_brw_staff_06/wpn_brw_staff_06_3p"
	local volley1 = "units/weapons/player/wpn_wh_repeater_crossbow_t1/wpn_wh_repeater_crossbow_t1_3p"
	local volley2 = "units/weapons/player/wpn_wh_repeater_crossbow_t2/wpn_wh_repeater_crossbow_t2_3p"
	local volley3 = "units/weapons/player/wpn_wh_repeater_crossbow_t3/wpn_wh_repeater_crossbow_t3_3p"
	local xbow1 = "units/weapons/player/wpn_empire_crossbow_t1/wpn_empire_crossbow_tier1_3p"
	local xbow2 = "units/weapons/player/wpn_empire_crossbow_t2/wpn_empire_crossbow_tier2_3p"
	local xbow3 = "units/weapons/player/wpn_empire_crossbow_t3/wpn_empire_crossbow_tier3_3p"
	local repeat1 = "units/weapons/player/wpn_empire_pistol_repeater/wpn_empire_pistol_repeater_t1_3p"
	local repeat2 = "units/weapons/player/wpn_empire_pistol_repeater/wpn_empire_pistol_repeater_t2_3p"
	local repeat3 = "units/weapons/player/wpn_empire_pistol_repeater/wpn_empire_pistol_repeater_t3_3p"
	if package_name == volley1 or package_name == volley2 or package_name == volley3 or
			package_name == xbow1 or package_name == xbow2 or package_name == xbow3 or 
			package_name == repeat1 or package_name == repeat2 or package_name == repeat3 then
		local z_scale = scaling >= 0.75 and scaling - 0.25 or scaling
		local scale = Vector3(scaling, scaling, z_scale)
		Unit.teleport_local_scale(s_unit, 0, scale)
	end
	if package_name == staff then
		local scale = Vector3(scaling, scaling, scaling)
		Unit.teleport_local_scale(s_unit, 0, scale)
	end
	
	return s_unit
end
--[[
	Spawn single equipment unit
--]]
mod.get_item_setting = function(self, unit, slot_name, item_data, left)
	local def = Visible3PEquipment_Definitions
	local item_setting = nil

	-- ####### Fixes and options #######
	safe_pcall(function()
	if slot_name == "slot_melee" or slot_name == "slot_ranged" then
		
		-- Dwarf
		if table.contains(def.dwarf_weapons, item_data.item_type) then
			local dwarf_weapon_position = self.get(self.widget_settings.DWARF_WEAPONS_POSITION.save)
			local option_backpack = 1
			local option_back = 2
			if dwarf_weapon_position == option_backpack then
				if not left then
					item_setting = def[item_data.item_type].right.backpack
				else
					item_setting = def[item_data.item_type].left.backpack
				end
			elseif dwarf_weapon_position == option_back then
				if not left then
					item_setting = def[item_data.item_type].right.back
				else
					item_setting = def[item_data.item_type].left.back
				end
			end
		end
		
		-- One-Handed
		if table.contains(def.one_handed, item_data.item_type) then
			local dwarf_one_handed_weapon_position = self.get(self.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save)
			local option_d_belt = 2
			local option_d_back = 3
			local dwarf_weapon = table.contains(def.dwarf_weapons, item_data.item_type)
			local _1h_weapon_position = self.get(self.widget_settings.ONE_HANDED_WEAPONS_POSITION.save)
			local option_belt = 1
			local option_back = 2
			if _1h_weapon_position == option_belt and not dwarf_weapon or dwarf_weapon and dwarf_one_handed_weapon_position == option_d_belt then
				if not left then
					item_setting = def[item_data.item_type].right.belt
				else
					item_setting = def[item_data.item_type].left.belt
				end
			elseif _1h_weapon_position == option_back and not dwarf_weapon or dwarf_weapon and dwarf_one_handed_weapon_position == option_d_back then
				if not left then
					item_setting = def[item_data.item_type].right.back
				else
					item_setting = def[item_data.item_type].left.back
				end
			end
		end
		
		-- Waywatcher
		if table.contains(def.waywatcher_dual, item_data.item_type) then
			local dwarf_weapon_position = self.get(self.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save)
			local option_belt = 1
			local option_back = 2
			if dwarf_weapon_position == option_belt then
				if not left then
					item_setting = def[item_data.item_type].right.belt
				else
					item_setting = def[item_data.item_type].left.belt
				end
			elseif dwarf_weapon_position == option_back then
				if not left then
					item_setting = def[item_data.item_type].right.back
				else
					item_setting = def[item_data.item_type].left.back
				end
			end
		end
		
		-- Default
		if not left then
			item_setting = item_setting or def[item_data.item_type].right
		else
			item_setting = item_setting or def[item_data.item_type].left
		end
		
	else
		local profile_name = self.current.profile[unit] or nil
		if profile_name then
			if not left then
				item_setting = profile_name and def[item_data.item_type][profile_name] and def[item_data.item_type][profile_name].right
				item_setting = item_setting or def[item_data.item_type] and def[item_data.item_type].right
			else
				item_setting = profile_name and def[item_data.item_type][profile_name] and def[item_data.item_type][profile_name].left
				item_setting = item_setting or def[item_data.item_type] and def[item_data.item_type].left
			end
		end
	end
	end)
	
	-- Default values
	if not left then
		item_setting = item_setting or def.default.right
	else
		item_setting = item_setting or def.default.left
	end
	
	return item_setting
end
mod.add_item = function(self, unit, slot_name, item_data)
	local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
	local equipment = inventory_extension.equipment(inventory_extension)
	if Visible3PEquipment_Definitions[item_data.item_type] ~= nil then
		local right, left, right_pack, left_pack = nil
		local item_units = BackendUtils.get_item_units(item_data)
		if item_units.right_hand_unit ~= nil then
			local item_setting = self:get_item_setting(unit, slot_name, item_data)
			right_pack = item_units.right_hand_unit.."_3p"
			right = self:spawn(right_pack, unit, item_setting)
		end
		if item_units.left_hand_unit ~= nil then
			local item_setting = self:get_item_setting(unit, slot_name, item_data, true)
			left_pack = item_units.left_hand_unit.."_3p"
			left = self:spawn(left_pack, unit, item_setting)
		end
		
		self.current.equipment[unit] = self.current.equipment[unit] or {}
		self.current.equipment[unit][#self.current.equipment[unit]+1] = {
			right = right,
			left = left,
			slot = slot_name,
			right_pack = right_pack,
			left_pack = left_pack,
		}
	end
end
--[[
	Spawn all equipment units for a character
--]]
mod.add_all_items = function(self, unit)
	if not self.current.equipment[unit] then
		local slots_by_name = InventorySettings.slots_by_name
		local wieldable_slots = InventorySettings.slots_by_wield_input
		if ScriptUnit.has_extension(unit, "inventory_system") then
			local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
			local equipment = inventory_extension.equipment(inventory_extension)
			for name, slot in pairs(equipment.slots) do
                if (not self.get(self.widget_settings.PERFORMANCE_MODE.save) or 
                    (name == "slot_melee" or name == "slot_ranged")) then
                    mod:add_item(unit, name, slot.item_data)
                end
			end
			self.current.slot[unit] = self.current.slot[unit] or equipment.wielded_slot or "slot_melee"
			self:set_equipment_visibility(unit)
		end
	end
end
--[[
	Check if packages are loaded
--]]
mod.is_not_loading = function()
	return (#Managers.package._queued_async_packages == 0 and #Managers.package._queue_order == 0)
end
--[[
	Set unit visibility
--]]
mod.set_equipment_visibility = function(self, unit, hide)
	if self.current.equipment[unit] then
		for _, equip in pairs(self.current.equipment[unit]) do
			if equip.slot == self.current.slot[unit] or hide then
				if equip.right ~= nil then
					Unit.set_unit_visibility(equip.right, false)
				end
				if equip.left ~= nil then
					Unit.set_unit_visibility(equip.left, false)
				end
			else
				if equip.right ~= nil then
					Unit.set_unit_visibility(equip.right, true)
					Unit.flow_event(equip.right, "lua_wield")
					Unit.flow_event(equip.right, "lua_unwield")
				end
				if equip.left ~= nil then
					Unit.set_unit_visibility(equip.left, true)
					Unit.flow_event(equip.left, "lua_wield")
					Unit.flow_event(equip.left, "lua_unwield")
				end
			end
		end
	end
end
--[[
	Execute wield
--]]
mod.wield_equipment = function(self, unit, slot_name)
	self.current.slot[unit] = slot_name
	self:set_equipment_visibility(unit)
end
--[[
	Function from third person to check if forced third person is active
--]]
mod.is_first_person_blocked = function(self, unit)
	local blocked = false
	if ScriptUnit.has_extension(unit, "character_state_machine_system") then
		local state_system = ScriptUnit.extension(unit, "character_state_machine_system")
		if state_system ~= nil then
			blocked = blocked or state_system.state_machine.state_current.name == "dead"
			blocked = blocked or state_system.state_machine.state_current.name == "grabbed_by_pack_master"
			blocked = blocked or state_system.state_machine.state_current.name == "inspecting"
			blocked = blocked or state_system.state_machine.state_current.name == "interacting"
			blocked = blocked or state_system.state_machine.state_current.name == "knocked_down"
			--blocked = blocked or state_system.state_machine.state_current.name == "leave_ledge_hanging_falling"
			--blocked = blocked or state_system.state_machine.state_current.name == "leave_ledge_hanging_pull_up"
			blocked = blocked or state_system.state_machine.state_current.name == "ledge_hanging"
			blocked = blocked or state_system.state_machine.state_current.name == "pounced_down"
			blocked = blocked or state_system.state_machine.state_current.name == "waiting_for_assisted_respawn"
		end
	end
	return blocked
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################
--[[
	Wield equipment hooks
--]]
Mods.hook.set(mod_name, "InventorySystem.rpc_wield_equipment", function(func, self, sender, go_id, slot_id)
	func(self, sender, go_id, slot_id)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		local unit = self.unit_storage:unit(go_id)
		local slot_name = NetworkLookup.equipment_slots[slot_id]
		mod:wield_equipment(unit, slot_name)
	end
end)
Mods.hook.set(mod_name, "SimpleInventoryExtension.wield", function(func, self, slot_name)
	func(self, slot_name)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		mod:wield_equipment(self._unit, slot_name)
	end
end)
Mods.hook.set(mod_name, "SimpleHuskInventoryExtension.wield", function(func, self, slot_name)
	func(self, slot_name)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		mod:wield_equipment(self._unit, slot_name)
	end
end)
--[[
	Despawn equipment
--]]
Mods.hook.set(mod_name, "SimpleInventoryExtension.destroy_slot", function(func, self, slot_name, allow_destroy_weapon)
	func(self, slot_name, allow_destroy_weapon)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		mod:delete_units(self._unit)
	end
end)
Mods.hook.set(mod_name, "SimpleHuskInventoryExtension.destroy_slot", function(func, self, slot_name)
	func(self, slot_name)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		mod:delete_units(self._unit)
	end
end)
Mods.hook.set(mod_name, "PlayerUnitHealthExtension.die", function(func, self, damage_type)
	func(self, damage_type)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		mod:delete_units(self.unit)
	end
end)
--[[
	Unloading packages
--]]
Mods.hook.set(mod_name, "PackageManager.unload", function(func, self, package_name, ...)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		for unit, equip in pairs(mod.current.equipment) do
			for _, i_unit in pairs(equip) do
				if i_unit.right_pack and i_unit.right_pack == package_name then
					mod:delete_units(unit)
				end
				if i_unit.left_pack and i_unit.left_pack == package_name then
					mod:delete_units(unit)
				end
			end
		end
	end
	return func(self, package_name, ...)
end)
--[[
	Manage option toggle
	Create equipment
--]]
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	func(self, dt, t)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		local players = Managers.player:human_and_bot_players()
		for k, player in pairs(players) do
			if player then
				local player_unit = player.player_unit
				if player_unit ~= nil then
				
					local profile_synchronizer = Managers.state.network.profile_synchronizer
					local profile_index = profile_synchronizer:profile_by_peer(player:network_id(), player:local_player_id())
					mod.current.profile[player_unit] = SPProfiles[profile_index].unit_name

					if ScriptUnit.has_extension(player_unit, "health_system") and ScriptUnit.has_extension(player_unit, "status_system") then
						local health_extension = ScriptUnit.extension(player_unit, "health_system")
						local status_extension = ScriptUnit.extension(player_unit, "status_system")
						local is_alive = health_extension.is_alive(health_extension) and not status_extension.is_disabled(status_extension)
						if is_alive and mod.is_not_loading() and mod.current.profile[player_unit] and not mod.current.equipment[player_unit] then
							mod:add_all_items(player_unit)
						end
					end
				end
			end
		end
		-- Options
		-- Dwarf weapons
		if mod.options[mod.widget_settings.DWARF_WEAPONS_POSITION.save] ~= mod.get(mod.widget_settings.DWARF_WEAPONS_POSITION.save) then
			for unit, name in pairs(mod.current.profile) do
				if name == "dwarf_ranger" then
					mod:delete_units(unit)
				end
			end
			mod.options[mod.widget_settings.DWARF_WEAPONS_POSITION.save] = mod.get(mod.widget_settings.DWARF_WEAPONS_POSITION.save)
		end
		-- Dwarf one-handed weapons
		if mod.options[mod.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save] ~= mod.get(mod.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save) then
			for unit, name in pairs(mod.current.profile) do
				if name == "dwarf_ranger" then
					mod:delete_units(unit)
				end
			end
			mod.options[mod.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save] = mod.get(mod.widget_settings.DWARF_ONE_HANDED_WEAPONS_POSITION.save)
		end
		-- Waywatcher dual weapons
		if mod.options[mod.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save] ~= mod.get(mod.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save) then
			for unit, name in pairs(mod.current.profile) do
				if name == "wood_elf" then
					mod:delete_units(unit)
				end
			end
			mod.options[mod.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save] = mod.get(mod.widget_settings.WAYWATCHER_DUAL_WEAPONS_POSITION.save)
		end
		-- One-handed weapons
		if mod.options[mod.widget_settings.ONE_HANDED_WEAPONS_POSITION.save] ~= mod.get(mod.widget_settings.ONE_HANDED_WEAPONS_POSITION.save) then
			for unit, name in pairs(mod.current.profile) do
				mod:delete_units(unit)
			end
			mod.options[mod.widget_settings.ONE_HANDED_WEAPONS_POSITION.save] = mod.get(mod.widget_settings.ONE_HANDED_WEAPONS_POSITION.save)
		end
		-- Downscale big weapons
		if mod.options[mod.widget_settings.DOWNSCALE_BIG_WEAPONS.save] ~= mod.get(mod.widget_settings.DOWNSCALE_BIG_WEAPONS.save) then
			for unit, name in pairs(mod.current.profile) do
				mod:delete_units(unit)
			end
			mod.options[mod.widget_settings.DOWNSCALE_BIG_WEAPONS.save] = mod.get(mod.widget_settings.DOWNSCALE_BIG_WEAPONS.save)
		end
		-- First person
		local player = Managers.player:local_player()
		if player then
			local third_person_mod = Mods.ThirdPerson
			local third_person = third_person_mod and not third_person_mod.firstperson.value or mod:is_first_person_blocked(player.player_unit) or false
			mod:set_equipment_visibility(player.player_unit, not third_person)
		end
	else
		mod:delete_all_units()
	end
end)

Mods.hook.set(mod_name, "InventoryPackageSynchronizer.set_inventory_list", function(func, self, profile_index, inventory_list, inventory_list_first_person)
	if mod.get(mod.widget_settings.ACTIVE.save) then
		local players = Managers.player:human_and_bot_players()
		for k, player in pairs(players) do
			local profile_synchronizer = Managers.state.network.profile_synchronizer
			local profile_index_ = profile_synchronizer:profile_by_peer(player:network_id(), player:local_player_id())
			if profile_index == profile_index_ then
				mod:delete_units(player.player_unit)
			end
		end
	end
	func(self, profile_index, inventory_list, inventory_list_first_person)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod:delete_all_units()
mod:create_options()