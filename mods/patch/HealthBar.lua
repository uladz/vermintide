local mod_name = "HealthBars"
--[[ 
	Enemy health bars
		- Show health bars for enemies
	
	Author: grasmann
--]]

-- Backup units list
local units_bak = {}
if EnemyHealthBars then
	units_bak = EnemyHealthBars.units or {}
end

local oi = OptionsInjector

EnemyHealthBars = {
	initialized = false,

	SETTINGS = {
		SUB_GROUP = {
			["save"] = "cb_enemy_health_bars_subgroup",
			["widget_type"] = "dropdown_checkbox",
			["text"] = "Enemy Health Bars",
			["default"] = false,
			["hide_options"] = {
				{
					true,
					mode = "show",
					options = {
						"cb_enemy_health_bars_active",
						"cb_enemy_health_bars_hotkey_toggle",
						"cb_enemy_health_bars_hotkey_toggle_behaviour"
					},
				},
				{
					false,
					mode = "hide",
					options = {
						"cb_enemy_health_bars_active",
						"cb_enemy_health_bars_hotkey_toggle",
						"cb_enemy_health_bars_hotkey_toggle_behaviour"
					},
				},
			},
		},
		ACTIVE = {
			["save"] = "cb_enemy_health_bars_active",
			["widget_type"] = "dropdown",
			["text"] = "Mode",
			["tooltip"] = "Enemy Health Bars Mode\n" ..
				"Switch mode for the enemy health bars.\n\n" ..
				"-- OFF --\nNo health bars will be created.\n\n" ..
				"-- All --\nCreate health bars for all wounded enemies.\n\n" ..
				"-- SPECIALS ONLY --\nCreate health bars for specials only.\n\n" ..
				"-- OGRE ONLY --\nCreate health bars only for the ogre unit.\n\n" ..
				"-- CUSTOM --\nChoose which enemies should have a health bar.\n\n",
			["value_type"] = "number",
			["options"] = {
				{text = "Off", value = 1},
				{text = "All", value = 2},
				{text = "Specials Only", value = 3}, 
				{text = "Ogre Only", value = 4},
				{text = "Custom", value = 5},
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
			["hide_options"] = {
				{
					1,
					mode = "hide",
					options = {
						"cb_enemy_health_bars_slave_rat",
						"cb_enemy_health_bars_clan_rat",
						"cb_enemy_health_bars_stormvermin",
						"cb_enemy_health_bars_runner",
						"cb_enemy_health_bars_gunner",
						"cb_enemy_health_bars_packmaster",
						"cb_enemy_health_bars_gas_rat",
						"cb_enemy_health_bars_ogre",
						"cb_enemy_health_bars_sack_rat",
						"cb_enemy_health_bars_position",
						"cb_enemy_health_bars_champion",
					}
				},
				{
					2,
					mode = "hide",
					options = {
						"cb_enemy_health_bars_slave_rat",
						"cb_enemy_health_bars_clan_rat",
						"cb_enemy_health_bars_stormvermin",
						"cb_enemy_health_bars_runner",
						"cb_enemy_health_bars_gunner",
						"cb_enemy_health_bars_packmaster",
						"cb_enemy_health_bars_gas_rat",
						"cb_enemy_health_bars_ogre",
						"cb_enemy_health_bars_sack_rat",
						"cb_enemy_health_bars_champion",
					}
				},
				{
					2,
					mode = "show",
					options = {
						"cb_enemy_health_bars_position",
					}
				},
				{
					3,
					mode = "hide",
					options = {
						"cb_enemy_health_bars_slave_rat",
						"cb_enemy_health_bars_clan_rat",
						"cb_enemy_health_bars_stormvermin",
						"cb_enemy_health_bars_runner",
						"cb_enemy_health_bars_gunner",
						"cb_enemy_health_bars_packmaster",
						"cb_enemy_health_bars_gas_rat",
						"cb_enemy_health_bars_ogre",
						"cb_enemy_health_bars_sack_rat",
						"cb_enemy_health_bars_champion",
					}
				},
				{
					3,
					mode = "show",
					options = {
						"cb_enemy_health_bars_position",
					}
				},
				{
					4,
					mode = "hide",
					options = {
						"cb_enemy_health_bars_slave_rat",
						"cb_enemy_health_bars_clan_rat",
						"cb_enemy_health_bars_stormvermin",
						"cb_enemy_health_bars_runner",
						"cb_enemy_health_bars_gunner",
						"cb_enemy_health_bars_packmaster",
						"cb_enemy_health_bars_gas_rat",
						"cb_enemy_health_bars_ogre",
						"cb_enemy_health_bars_sack_rat",
						"cb_enemy_health_bars_champion",
					}
				},
				{
					4,
					mode = "show",
					options = {
						"cb_enemy_health_bars_position",
					}
				},
				{
					5,
					mode = "show",
					options = {
						"cb_enemy_health_bars_slave_rat",
						"cb_enemy_health_bars_clan_rat",
						"cb_enemy_health_bars_stormvermin",
						"cb_enemy_health_bars_runner",
						"cb_enemy_health_bars_gunner",
						"cb_enemy_health_bars_packmaster",
						"cb_enemy_health_bars_gas_rat",
						"cb_enemy_health_bars_ogre",
						"cb_enemy_health_bars_sack_rat",
						"cb_enemy_health_bars_champion",
						"cb_enemy_health_bars_position",
					}
				},
			},
		},
		POSITION = {
			["save"] = "cb_enemy_health_bars_position",
			["widget_type"] = "stepper",
			["text"] = "Position",
			["tooltip"] = "Enemy Health Bars Position\n" ..
				"Switch position of the enemy health bars.",
			["value_type"] = "number",
			["options"] = {
				{text = "Below", value = 1},
				{text = "Above", value = 2}
			},
			["default"] = 1, -- Default first option is enabled. In this case Below
		},
		SLAVE_RAT = {
			["save"] = "cb_enemy_health_bars_slave_rat",
			["widget_type"] = "checkbox",
			["text"] = "Slave Rats",
			["default"] = false,
		},
		CLAN_RAT = {
			["save"] = "cb_enemy_health_bars_clan_rat",
			["widget_type"] = "checkbox",
			["text"] = "Clan Rats",
			["default"] = false,
		},
		STORMVERMIN = {
			["save"] = "cb_enemy_health_bars_stormvermin",
			["widget_type"] = "checkbox",
			["text"] = "Stormvermin",
			["default"] = false,
		},
		RUNNER = {
			["save"] = "cb_enemy_health_bars_runner",
			["widget_type"] = "checkbox",
			["text"] = "Gutter Runner",
			["default"] = false,
		},
		GUNNER = {
			["save"] = "cb_enemy_health_bars_gunner",
			["widget_type"] = "checkbox",
			["text"] = "Ratling Gunner",
			["default"] = false,
		},
		PACKMASTER = {
			["save"] = "cb_enemy_health_bars_packmaster",
			["widget_type"] = "checkbox",
			["text"] = "Packmaster",
			["default"] = false,
		},
		GAS_RAT = {
			["save"] = "cb_enemy_health_bars_gas_rat",
			["widget_type"] = "checkbox",
			["text"] = "Globadier",
			["default"] = false,
		},
		SACK_RAT = {
			["save"] = "cb_enemy_health_bars_sack_rat",
			["widget_type"] = "checkbox",
			["text"] = "Sack Rat",
			["default"] = false,
		},
		OGRE = {
			["save"] = "cb_enemy_health_bars_ogre",
			["widget_type"] = "checkbox",
			["text"] = "Rat Ogre",
			["default"] = false,
		},
		CHAMPION = {
			["save"] = "cb_enemy_health_bars_champion",
			["widget_type"] = "checkbox",
			["text"] = "Stormvermin Champion",
			["default"] = false,
		},
		HK_TOGGLE = {
			["save"] = "cb_enemy_health_bars_hotkey_toggle",
			["widget_type"] = "keybind",
			["text"] = "Change Mode",
			["default"] = {
				"h",
				oi.key_modifiers.ALT,
			},
			["exec"] = {"patch/action", "health_bars"},
		},
		HK_TOGGLE_B = {
			["save"] = "cb_enemy_health_bars_hotkey_toggle_behaviour",
			["widget_type"] = "stepper",
			["text"] = "Hotkey Behaviour",
			["tooltip"] = "Hotkey Behaviour\n" ..
				"Set the behaviour of the \"Change Mode\" hotkey.\n\n" ..
				"'Presets' will have the hotkey going through all possible modes.\n\n" ..
				"'On and off' will only alter between Off and Custom modes.",
			["value_type"] = "number",
			["options"] = {
				{text = "Presets", value = 1},
				{text = "On and off", value = 2}
			},
			["default"] = 1, -- Default first option is enabled. In this case Presets
		},
	},

	
	VERY_FAR = 50,
	
	units = units_bak,
	
	specials = {
		"skaven_gutter_runner",
		"skaven_ratling_gunner",
		"skaven_pack_master",
		"skaven_poison_wind_globadier",
		"skaven_storm_vermin_champion",
		"skaven_rat_ogre",
		"skaven_loot_rat",
	},
	
	offsets = {
		default = 1.5,
		skaven_slave = 3,
		skaven_clan_rat = 3,
		skaven_storm_vermin = 4,
		skaven_storm_vermin_commander = 4,
		skaven_storm_vermin_champion = 5.5,
		skaven_gutter_runner = 3,
		skaven_ratling_gunner = 4,
		skaven_pack_master = 4,
		skaven_poison_wind_globadier = 3.5,
		skaven_rat_ogre = 5.5,
		skaven_loot_rat = 4,
		critter_pig = 2.5,
		critter_rat = 0.5,
	},
	
	sizes = {
		default = {17*0.9, 7*0.9},
		special = {17*1.4, 7*1.4},
		ogre = {17*1.8, 7*1.8},		
	},
}
local me = EnemyHealthBars

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################
--[[
	GenericHealthExtension Add damage hook
--]]
Mods.hook.set(mod_name, "GenericHealthExtension.add_damage", function(func, self, ...)
	func(self, ...)
	me.on_enemy_damage(self)
end)
--[[
	GenericHealthExtension Set damage hook
--]]
Mods.hook.set(mod_name, "GenericHealthExtension.set_current_damage", function(func, self, ...)
	func(self, ...)
	me.on_enemy_damage(self)
end)
--[[
	RatOgreHealthExtension Add ogre damage hook
--]]
Mods.hook.set(mod_name, "RatOgreHealthExtension.add_damage", function(func, self, ...)
	func(self, ...)
	me.on_enemy_damage(self)
end)
--[[
	RatOgreHealthExtension Set ogre damage hook
--]]
Mods.hook.set(mod_name, "RatOgreHealthExtension.set_current_damage", function(func, self, ...)
	func(self, ...)
	me.on_enemy_damage(self)
end)
--[[
	Check units before updating health bars
	Necessary fix to avoid rare crashes
--]]
Mods.hook.set(mod_name, "TutorialUI.update_health_bars", function(func, tutorial_ui, ...)
	if get(me.SETTINGS.ACTIVE) then
		me.clean_units()
		me.set_sizes(tutorial_ui)
		me.set_offsets(tutorial_ui)
		local status, err = pcall(func, tutorial_ui, ...)
		if err ~= nil then
			EchoConsole(err)
		end
	else
		func(tutorial_ui, ...)
	end
end)
--[[
	Remove health bar from gutter runner when he's vanishing
--]]
Mods.hook.set(mod_name, "BTSelector_gutter_runner.run", function(func, self, unit, blackboard, ...)
	local result, evaluate = func(self, unit, blackboard, ...)
	local child_running = self.current_running_child(self, blackboard)
	local node_ninja_vanish = self._children[5]
	if node_ninja_vanish == child_running then
		me.remove_health_bar(unit)
	end
	return result, evaluate
end)

-- ####################################################################################################################
-- ##### Offset #######################################################################################################
-- ####################################################################################################################
--[[
	Set sizes for all health bars
--]]
EnemyHealthBars.set_sizes = function(tutorial_ui)
	for _, unit in pairs(me.units) do
		me.set_size(unit, tutorial_ui)
	end
end
--[[
	Set size of units health bar
--]]
EnemyHealthBars.set_size = function(unit, tutorial_ui)
	local breed = Unit.get_data(unit, "breed")
	local sizes = me.sizes[breed.name] or me.sizes.default
	for _, health_bar in pairs(tutorial_ui.health_bars) do
		if health_bar.unit == unit then
			local texture_bg = health_bar.widget.style.texture_bg
			texture_bg.size[2] = sizes[1]
			local texture_fg = health_bar.widget.style.texture_fg
			texture_fg.size[2] = sizes[2]
			return true
		end
	end
	return false
end
--[[
	Set offset for all health bars
--]]
EnemyHealthBars.set_offsets = function(tutorial_ui)
	if get(me.SETTINGS.POSITION) ~= nil
	and get(me.SETTINGS.POSITION) == 2 then
		for _, unit in pairs(me.units) do
			me.set_offset(unit, tutorial_ui)
		end
	end
end
--[[
	Set offset for units health bar
--]]
EnemyHealthBars.set_offset = function(unit, tutorial_ui)
	local breed = Unit.get_data(unit, "breed")
	local offset = me.offsets[breed.name] or me.offsets.default
	local player = Managers.player:local_player()
	local world = tutorial_ui.world_manager:world("level_world")
	local viewport = ScriptWorld.viewport(world, player.viewport_name)
	local camera = ScriptViewport.camera(viewport)	
	
	for _, health_bar in pairs(tutorial_ui.health_bars) do
		if health_bar.unit == unit then
			-- Enemy position
			local enemy_pos = Unit.world_position(unit, 0)
			--local x1, y1 = tutorial_ui:convert_world_to_screen_position(camera, enemy_pos)
			local enemy_pos_2d = Camera.world_to_screen(camera, enemy_pos)
			-- Health bar position
			local hp_bar_pos = Vector3(enemy_pos[1], enemy_pos[2], enemy_pos[3] + offset)
			--local x2, y2 = tutorial_ui:convert_world_to_screen_position(camera, hp_bar_pos)
			local hp_bar_pos_2d = Camera.world_to_screen(camera, hp_bar_pos)
			-- Difference
			--local diff = y2 - y1
			local diff = hp_bar_pos_2d[2] - enemy_pos_2d[2]
			-- Change offsets
			local scale = UIResolutionScale()
			diff = (diff / 2) * (2 - scale)
			--EchoConsole(scale)
			local texture_bg = health_bar.widget.style.texture_bg
			texture_bg.offset[2] = diff - texture_bg.size[2]/2
			local texture_fg = health_bar.widget.style.texture_fg
			texture_fg.offset[2] = diff - texture_fg.size[2]/2
			
			return true
		end
	end
	return false
end

-- ####################################################################################################################
-- ##### Healthbar ####################################################################################################
-- ####################################################################################################################
--[[
	Add a health bar to all units
--]]
EnemyHealthBars.add_health_bar_all = function(unit)
	local breed = Unit.get_data(unit, "breed")
	if not table.has_item2(me.units, unit) and breed ~= nil then
		local tutorial_system = Managers.state.entity:system("tutorial_system")
		local tutorial_ui = tutorial_system.tutorial_ui			
		tutorial_ui:add_health_bar(unit)
		me.units[unit] = unit		
	end
end
--[[
	Add a health bar only to special units
--]]
EnemyHealthBars.add_health_bar_specials = function(unit)
	local breed = Unit.get_data(unit, "breed")
	if not table.has_item2(me.units, unit) and breed ~= nil then
		if table.has_item(me.specials, breed.name) then
			local tutorial_system = Managers.state.entity:system("tutorial_system")
			local tutorial_ui = tutorial_system.tutorial_ui
			tutorial_ui:add_health_bar(unit)
			me.units[unit] = unit
		end
	end
end
--[[
	Add a health bar only to custom units
--]]
EnemyHealthBars.add_health_bar_custom = function(unit)
	local breed = Unit.get_data(unit, "breed")
	if not table.has_item2(me.units, unit) and breed ~= nil then
		local add = false
		
		if breed.name == "skaven_slave"
			and get(me.SETTINGS.SLAVE_RAT) then add = true end
		if breed.name == "skaven_clan_rat"
			and get(me.SETTINGS.CLAN_RAT) then add = true end
		if (breed.name == "skaven_storm_vermin" 
			or breed.name == "skaven_storm_vermin_commander")
			and get(me.SETTINGS.STORMVERMIN) then add = true end
		if breed.name == "skaven_gutter_runner"
			and get(me.SETTINGS.RUNNER) then add = true end
		if breed.name == "skaven_ratling_gunner"
			and get(me.SETTINGS.GUNNER) then add = true end
		if breed.name == "skaven_pack_master"
			and get(me.SETTINGS.PACKMASTER) then add = true end
		if breed.name == "skaven_poison_wind_globadier"
			and get(me.SETTINGS.GAS_RAT) then add = true end
		if breed.name == "skaven_rat_ogre"
			and get(me.SETTINGS.OGRE) then add = true end
		if breed.name == "skaven_loot_rat"
			and get(me.SETTINGS.SACK_RAT) then add = true end
		if breed.name == "skaven_storm_vermin_champion"
			and get(me.SETTINGS.CHAMPION) then add = true end
		
		if add then
			local tutorial_system = Managers.state.entity:system("tutorial_system")
			local tutorial_ui = tutorial_system.tutorial_ui
			tutorial_ui:add_health_bar(unit)
			me.units[unit] = unit
		end
	end
end
--[[
	Add a health bar only to ogres
--]]
EnemyHealthBars.add_health_bar_ogre = function(unit)
	local breed = Unit.get_data(unit, "breed")
	if not table.has_item2(me.units, unit) and breed ~= nil then
		local search = {"skaven_rat_ogre"}
		if table.has_item(search, breed.name) then
			local tutorial_system = Managers.state.entity:system("tutorial_system")
			local tutorial_ui = tutorial_system.tutorial_ui
			tutorial_ui:add_health_bar(unit)
			me.units[unit] = unit
		end
	end
end
--[[
	Add a health bar to the specified unit
--]]
EnemyHealthBars.add_health_bar = function(unit)		
	if get(me.SETTINGS.ACTIVE) == 2 then
		me.add_health_bar_all(unit)
	elseif get(me.SETTINGS.ACTIVE) == 3 then
		me.add_health_bar_specials(unit)
	elseif get(me.SETTINGS.ACTIVE) == 4 then
		me.add_health_bar_ogre(unit)
	elseif get(me.SETTINGS.ACTIVE) == 5 then
		me.add_health_bar_custom(unit)
	end
end
--[[
	Remove a health bar from a unit
--]]
EnemyHealthBars.remove_health_bar = function(unit)
	if table.has_item2(me.units, unit) then
		local tutorial_system = Managers.state.entity:system("tutorial_system")
		local tutorial_ui = tutorial_system.tutorial_ui
		tutorial_ui:remove_health_bar(unit)		
		me.units[unit] = nil
	end
end
--[[
	Remove a health bar from a unit
--]]
EnemyHealthBars.on_enemy_damage = function(health_extension)
	if get(me.SETTINGS.ACTIVE) > 1 then
		if GenericHealthExtension.current_health(health_extension) > 0 then
			me.add_health_bar(health_extension.unit)
		else			
			me.remove_health_bar(health_extension.unit)
		end		
	else
		me.remove_health_bar(health_extension.unit)
	end
end
--[[
	Clean units in the health bar system
--]]

local obstructed_line_of_sight = function(player_unit, target_unit)
	local INDEX_POSITION = 1
	local INDEX_DISTANCE = 2
	local INDEX_NORMAL = 3
	local INDEX_ACTOR = 4

	local pinged = ScriptUnit.has_extension(target_unit, "ping_system") and ScriptUnit.extension(target_unit, "ping_system"):pinged()
	if pinged then
		return false
	end

	local player_unit_pos = Unit.world_position(player_unit, 0)
	player_unit_pos.z = player_unit_pos.z + 1.5
	local target_unit_pos = Unit.world_position(target_unit, 0)
	target_unit_pos.z = target_unit_pos.z + 1.4

	local tutorial_system = Managers.state.entity:system("tutorial_system")
	local tutorial_ui = tutorial_system.tutorial_ui
	local world = tutorial_ui.world_manager:world("level_world")
	local physics_world = World.get_data(world, "physics_world")
	local max_distance = Vector3.length(target_unit_pos - player_unit_pos)
	
	if max_distance < 5 then
		return false
	end

	local direction = target_unit_pos - player_unit_pos
	local length = Vector3.length(direction)
	direction = Vector3.normalize(direction)
	local collision_filter = "filter_player_ray_projectile"

	PhysicsWorld.prepare_actors_for_raycast(physics_world, player_unit_pos, direction, 0.01, 10, max_distance*max_distance)

	local raycast_hits = PhysicsWorld.immediate_raycast(physics_world, player_unit_pos, direction, max_distance, "all", "collision_filter", collision_filter)

	if raycast_hits then
		local num_hits = #raycast_hits

		for i = 1, num_hits, 1 do
			local hit = raycast_hits[i]
			local hit_actor = hit[INDEX_ACTOR]
			local hit_unit = Actor.unit(hit_actor)

			if hit_unit == target_unit then
				return false
			elseif hit_unit ~= player_unit then
				local obstructed_by_static = Actor.is_static(hit_actor)

				if obstructed_by_static then
					return obstructed_by_static
				end
			end
		end
	end

	return false
end

EnemyHealthBars.clean_units = function()
	for _, unit in pairs(me.units) do
		if not Unit.alive(unit) then
			me.remove_health_bar(unit)
		else
			local unit_pos = Unit.world_position(unit, 0)
			local player_manager = Managers.player
			local local_player = player_manager.local_player(player_manager)
			local player_unit = local_player.player_unit
			local player_pos = Unit.world_position(player_unit, 0)
			local dir = unit_pos - player_pos
			local distance = Vector3.length(dir)
			if distance > me.VERY_FAR or obstructed_line_of_sight(player_unit, unit) then
				me.remove_health_bar(unit)
			end
		end
	end
end

-- ####################################################################################################################
-- ##### Init functions ###############################################################################################
-- ####################################################################################################################
--[[
	Create options
--]]
EnemyHealthBars.create_options = function()
	Mods.option_menu:add_group("hud_group", "HUD Related Mods")

	Mods.option_menu:add_item("hud_group", me.SETTINGS.SUB_GROUP, true)
	
	Mods.option_menu:add_item("hud_group", me.SETTINGS.ACTIVE)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.POSITION)
	
	Mods.option_menu:add_item("hud_group", me.SETTINGS.SLAVE_RAT)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.CLAN_RAT)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.STORMVERMIN)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.RUNNER)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.GUNNER)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.PACKMASTER)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.GAS_RAT)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.SACK_RAT)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.OGRE)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.CHAMPION)
	
	Mods.option_menu:add_item("hud_group", me.SETTINGS.HK_TOGGLE)
	Mods.option_menu:add_item("hud_group", me.SETTINGS.HK_TOGGLE_B)
end
--[[
	Create health bar sizes
--]]
EnemyHealthBars.create_sizes = function()
	me.sizes.skaven_slave 				= me.sizes.default
	me.sizes.skaven_clan_rat 			= me.sizes.default
	me.sizes.skaven_storm_vermin 			= me.sizes.special
	me.sizes.skaven_storm_vermin_commander		= me.sizes.special
	me.sizes.skaven_storm_vermin_champion		= me.sizes.ogre
	me.sizes.skaven_gutter_runner 			= me.sizes.special
	me.sizes.skaven_ratling_gunner 			= me.sizes.special
	me.sizes.skaven_pack_master 			= me.sizes.special
	me.sizes.skaven_poison_wind_globadier 		= me.sizes.special
	me.sizes.skaven_rat_ogre 			= me.sizes.ogre
	me.sizes.skaven_loot_rat 			= me.sizes.ogre
end

-- ####################################################################################################################
-- ##### Healthbar Limit ##############################################################################################
-- ####################################################################################################################
--[[
	UI definitions
--]]
EnemyHealthBars.ui = {
	item_definitions = {
		scenegraph_id = "health_bar_",
		content = {
			texture_fg = "objective_hp_bar_fg_2",
			texture_bg = "objective_hp_bar_bg_2",
		},
		style = {
			texture_bg = {
				scenegraph_id = "health_bar_",
				offset = {-73.5, 0, 1},
				size = {147, 17},
				color= {255, 255, 255, 255},
			},
			texture_fg = {
				scenegraph_id = "health_bar_",
				offset = {-68.5, 5, 1},
				size = {137, 7},
				color = {255, 255, 255, 255},
			},
		},
		element = {
			passes = {
				{
					texture_id = "texture_bg",
					style_id = "texture_bg",
					pass_type = "texture",
				},
				{
					texture_id = "texture_fg",
					style_id = "texture_fg",
					pass_type = "texture",
				},
			},
		},
	},

	item_scene_graph = {
		size = {137, 7},
		parent = "screen_fit",
		position = {0, 0, 1},
	}
}
--[[
	Create healthbar widgets
--]]
EnemyHealthBars.create_extra_health_bars = function(total)
	local script = package.loaded["scripts/ui/views/tutorial_ui_definitions"]
	local scenegraph = nil
	
	-- 1.4.3 and beta check
	if script.floating_icons_scene_graph then
		scenegraph = script.floating_icons_scene_graph
	else
		scenegraph = script.scenegraph
	end
	
	script.health_bar_definitions = {}
	
	
	for x = 1, total do
		local name = "health_bar_" .. tostring(x)
		
		-- definitions
		me.ui.item_definitions.scenegraph_id = name
		me.ui.item_definitions.style.texture_bg.scenegraph_id = name
		me.ui.item_definitions.style.texture_fg.scenegraph_id = name
		
		script.health_bar_definitions[x] = table.clone(me.ui.item_definitions)
		
		scenegraph[name] = table.clone(me.ui.item_scene_graph)
	end

	script.NUMBER_OF_HEALTH_BARS = total
end

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
me.create_sizes()
me.create_extra_health_bars(30)
me.create_options()