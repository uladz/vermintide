--[[
	Name: ShowItems (ported from VMF)
	Link: https://www.moddb.com/downloads/show-items
	Author: unknown
	Updated by: uladz
	Version: 1.1.1 (9/24/2021)

	Adds the ability to display icons above items, including items inside chests.
	Go to Mod Settings -> Items -> Show Item Icons to tweak settings to your liking.

Changelog
	1.0.0 release
	1.0.1 fixed grim title in options
	1.1.0 ported from VMF to QoL, fixed menus, no german lang
	1.1.1 added support for small ammo as well, fixed icon position
--]]

mod_name = "ShowItems"
ShowItems = {}
local mod = ShowItems

mod.widget_settings = {
	SHOW = {
		["save"] = "cb_show_items_show",
		["widget_type"] = "stepper",
		["text"] = "Show Item Icons",
		["tooltip"] = "Show Item Icons\n" ..
			"Adds the ability to display icons above items, including items inside chests.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_show_items_mode",
					"cb_show_items_range",
					"cb_show_items_size",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_show_items_mode",
					"cb_show_items_range",
					"cb_show_items_size",
				}
			}
		},
	},
	MODE = {
		["save"] = "cb_show_items_mode",
		["widget_type"] = "dropdown",
		["text"] = "Mode",
		["tooltip"] = "Mode\n" ..
			"Show icons above items.\n" ..
			"\n" ..
			"All: All items icons will be visable\n" ..
			"Custom: Selected items will be only be visable.",
		["value_type"] = "number",
		["options"] = {
			{text = "All", value = 1},
			{text = "Custom", value = 2},
		},
		["default"] = 1, -- Default first option is enabled. In this case All
		["hide_options"] = {
			{
				1,
				mode = "hide",
				options = {
					"cb_show_items_custom_health",
					"cb_show_items_custom_potion",
					"cb_show_items_custom_bomb",
					"cb_show_items_custom_grim",
					"cb_show_items_custom_tome",
					"cb_show_items_custom_lorebook_page",
					"cb_show_items_custom_small_ammo",
				}
			},
			{
				2,
				mode = "show",
				options = {
					"cb_show_items_custom_health",
					"cb_show_items_custom_potion",
					"cb_show_items_custom_bomb",
					"cb_show_items_custom_grim",
					"cb_show_items_custom_tome",
					"cb_show_items_custom_lorebook_page",
					"cb_show_items_custom_small_ammo",
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
		["range"] = {1, 500},
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
		SMALL_AMMO = {
			["save"] = "cb_show_items_custom_small_ammo",
			["widget_type"] = "checkbox",
			["text"] = "Small Ammo",
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
	all_ammo_small = {
		icon = "weapon_generic_icon_crossbow_lit",
		setting = "SMALL_AMMO",
		width = 3
	},
}

--[[
  Options
--]]

mod.create_options = function()
	local group = "cheats"
	Mods.option_menu:add_group(group, "Gameplay Cheats")
	Mods.option_menu:add_item(group, mod.widget_settings.SHOW, true)
	Mods.option_menu:add_item(group, mod.widget_settings.MODE)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.HEALTH)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.POTION)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.BOMB)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.TOME)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.GRIM)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.LOREBOOK_PAGE)
	Mods.option_menu:add_item(group, mod.widget_settings.CUSTOM.SMALL_AMMO)
	Mods.option_menu:add_item(group, mod.widget_settings.RANGE)
	Mods.option_menu:add_item(group, mod.widget_settings.SIZE)
end

--[[
  Functions
--]]

mod.get = function(data)
	return Application.user_setting(data.save)
end

mod.create_icon = function(unit, pickup_name)
	local player = Managers.player:local_player()
	local world = Managers.world:world("level_world")
	local viewport = ScriptWorld.viewport(world, player.viewport_name)
	local camera = ScriptViewport.camera(viewport)

	if not mod.get(mod.widget_settings.SHOW) then
		return
	end

	--EchoConsole(pickup_name)
	local item_settings = mod.items[pickup_name]
	if item_settings == nil then
		return
	end

	local setting = mod.widget_settings.CUSTOM[item_settings.setting]
	if mod.get(mod.widget_settings.MODE) == 2 and not mod.get(setting) then
		return
	end

	if POSITION_LOOKUP[unit] and POSITION_LOOKUP[player.player_unit] then
		local distance = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[player.player_unit])
		local position2d, depth = Camera.world_to_screen(camera, POSITION_LOOKUP[unit])

		if distance > 2 and distance < mod.get(mod.widget_settings.RANGE) and depth < 1 then
			local x = item_settings.height or 1
			local y = item_settings.width or 1
			local size = mod.get(mod.widget_settings.SIZE)

			local pos = Vector3(position2d[1]-y/2*size, position2d[2], 200)
			local size2 = Vector2(size*y, size*x)

			safe_pcall(function()
				Mods.gui.draw_icon(item_settings.icon, pos, nil, size2)
			end)
		end
	end
end

--[[
	Hooks
--]]

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

--[[
	Start
--]]

mod.create_options()
