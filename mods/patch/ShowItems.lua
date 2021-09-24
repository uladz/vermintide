--[[
ShowItems v1.0.2
Adds the ability to display icons above items, including items inside chests.
Go to Mod Settings -> Items -> Show Item Icons to tweak settings to your liking.

Changelog
	1.0.2 - Added german language
	1.0.1 - Fixed grim title in options
	1.0.0 - Release
]]--

mod_name = "ShowItems"
ShowItems = {}
local mod = ShowItems

mod.get = function(data)
	return Application.user_setting(data.save)
end

mod.widget_settings = {
	SHOW = {
		["save"] = "cb_show_items_show",
		["widget_type"] = "checkbox",
		["text"] = "Show Item Icons",
		["default"] = false,
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_show_items_mode"
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_show_items_mode"
				}
			}
		},
	},
	MODE = {
		["save"] = "cb_show_items_mode",
		["widget_type"] = "dropdown",
		["text"] = "Mode",
		["tooltip"] = "Mode\n" ..
			"Shows icons above items.\n" ..
			"\n" ..
			"Off: No Item icons will be visable.\n" ..
			"All: All items icons will be visable\n" ..
			"Custom: Selected items will be only be visable.",
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
					"cb_show_items_range",
					"cb_show_items_size",
					"cb_show_items_custom_health",
					"cb_show_items_custom_potion",
					"cb_show_items_custom_bomb",
					"cb_show_items_custom_grim",
					"cb_show_items_custom_tome",
					"cb_show_items_custom_lorebook_page",
				}
			},
			{
				2,
				mode = "hide",
				options = {
					"cb_show_items_custom_health",
					"cb_show_items_custom_potion",
					"cb_show_items_custom_bomb",
					"cb_show_items_custom_grim",
					"cb_show_items_custom_tome",
					"cb_show_items_custom_lorebook_page",
				}
			},
			{
				2,
				mode = "show",
				options = {
					"cb_show_items_range",
					"cb_show_items_size",
				}
			},
			{
				3,
				mode = "show",
				options = {
					"cb_show_items_range",
					"cb_show_items_size",
					"cb_show_items_custom_health",
					"cb_show_items_custom_potion",
					"cb_show_items_custom_bomb",
					"cb_show_items_custom_grim",
					"cb_show_items_custom_tome",
					"cb_show_items_custom_lorebook_page",
				}
			},
		},
	},
	RANGE = {
		["save"] = "cb_show_items_range",
		["widget_type"] = "slider",
		["text"] = "Distance",
		["tooltip"] = "Distance\n" ..
			"Set the maximum distance to show items.",
		["range"] = {2, 1000},
		["default"] = 100,
	},
	SIZE = {
		["save"] = "cb_show_items_size",
		["widget_type"] = "slider",
		["text"] = "Icon Size",
		["tooltip"] = "Icon Size\n" ..
			"Set the size of the icons.",
		["range"] = {16, 128},
		["default"] = 64,
	},
	CUSTOM = {
		HEALTH = {
			["save"] = "cb_show_items_custom_health",
			["widget_type"] = "checkbox",
			["text"] = "Health",
			["default"] = false,
		},
		POTION = {
			["save"] = "cb_show_items_custom_potion",
			["widget_type"] = "checkbox",
			["text"] = "Potion",
			["default"] = false,
		},
		BOMB = {
			["save"] = "cb_show_items_custom_bomb",
			["widget_type"] = "checkbox",
			["text"] = "Bomb",
			["default"] = false,
		},
		GRIM = {
			["save"] = "cb_show_items_custom_grim",
			["widget_type"] = "checkbox",
			["text"] = "Grimoire",
			["default"] = false,
		},
		TOME = {
			["save"] = "cb_show_items_custom_tome",
			["widget_type"] = "checkbox",
			["text"] = "Tome",
			["default"] = false,
		},
		LOREBOOK_PAGE = {
			["save"] = "cb_show_items_custom_lorebook_page",
			["widget_type"] = "checkbox",
			["text"] = "Lorebook Page",
			["default"] = false,
		},
	}
}

mod.items = {
	healing_draught = {
		icon = "consumables_potion_01_lit",
		setting = "HEALTH"
	},
	first_aid_kit = {
		icon = "consumables_medpack_lit",
		setting = "HEALTH"
	},
	damage_boost_potion = {
		icon = "consumables_strength_lit",
		setting = "POTION"
	},
	speed_boost_potion = {
		icon = "consumables_speed_lit",
		setting = "POTION"
	},
	fire_grenade_t1 = {
		icon = "consumables_fire_lit",
		setting = "BOMB"
	},
	fire_grenade_t2 = {
		icon = "consumables_fire_lit",
		setting = "BOMB"
	},
	frag_grenade_t1 = {
		icon = "consumables_frag_lit",
		setting = "BOMB"
	},
	frag_grenade_t2 = {
		icon = "consumables_frag_lit",
		setting = "BOMB"
	},
	smoke_grenade_t1 = {
		icon = "consumables_smoke_lit",
		setting = "BOMB"
	},
	smoke_grenade_t2 = {
		icon = "consumables_smoke_lit",
		setting = "BOMB"
	},
	tome = {
		icon = "consumables_book_lit",
		setting = "TOME"
	},
	grimoire = {
		icon = "consumables_grimoire_lit",
		setting = "GRIM"
	},
	lorebook_page = {
		icon = "consumables_book_lit",
		setting = "LOREBOOK_PAGE"
	},
}

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	local group = "items"
	Mods.option_menu:add_group(group, "Show Items")
	Mods.option_menu:add_item(group, mod.widget_settings.SHOW, true)
	Mods.option_menu:add_item(group, mod.widget_settings.MODE)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.HEALTH)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.POTION)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.BOMB)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.TOME)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.GRIM)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.LOREBOOK_PAGE)
	Mods.option_menu:add_item(group, mod.widget_settings.RANGE)
	Mods.option_menu:add_item(group, mod.widget_settings.SIZE)
end

-- ####################################################################################################################
-- ##### Functions ####################################################################################################
-- ####################################################################################################################
mod.create_icon = function(unit, pickup_name)
	local player = Managers.player:local_player()
	local world = Managers.world:world("level_world")
	local viewport = ScriptWorld.viewport(world, player.viewport_name)
	local camera = ScriptViewport.camera(viewport)

	local item_settings = mod.items[pickup_name]

	if mod.get(mod.widget_settings.MODE) == 1 or item_settings == nil then
		return
	end

	local setting = mod.widget_settings.CUSTOM[item_settings.setting]
	if mod.get(mod.widget_settings.MODE) == 3 and mod.get(setting) == false then
		return
	end

	if POSITION_LOOKUP[unit] and POSITION_LOOKUP[player.player_unit] then
		local distance = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[player.player_unit])
		local position2d, depth = Camera.world_to_screen(camera, POSITION_LOOKUP[unit])

		if distance > 2 and distance < mod.get(mod.widget_settings.RANGE) and depth < 1 then
			local pos = Vector3(position2d[1], position2d[2], 200)

			safe_pcall(function()
				local size = Vector2(mod.get(mod.widget_settings.SIZE), mod.get(mod.widget_settings.SIZE))
				Mods.gui.draw_icon(item_settings.icon, pos, nil, size)
			end)
		end
	end
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "OutlineSystem.update", function(func, self, ...)
	if Managers.matchmaking.ingame_ui.hud_visible then
		for _, unit in pairs(self.units) do
			if ScriptUnit.has_extension(unit, "pickup_system") then
				local pickup_system = ScriptUnit.extension(unit, "pickup_system")

				mod.create_icon(unit, pickup_system.pickup_name)
			end
		end
	end

	func(self, ...)

	return
end)

Mods.hook.set(mod_name, "OutlineSystem.outline_unit", function(func, ...)
	pcall(func, ...)

	return
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
