--[[
ItemSpawner v1.1.0
Author: IamLupo

Adds keyboard shortcuts for spawning pickup items (medkits, tomes etc.).
Requires SpawnItemFunc mod to function.
Go to Mod Settings -> Spawning -> Items to see and change shortcuts.

Changelog
	1.0.0 - Release
--]]

mod_name = "ItemSpawner"
ItemSpawner = {}
local mod = ItemSpawner
local oi = OptionsInjector

mod.widget_settings = {
	SPAWN_PICKUPS = {
		["save"] = "cb_spawning_spawn_pickups",
		["widget_type"] = "checkbox",
		["text"] = "Items",
		["default"] = false,
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_spawning_spawn_badges",
					"cb_spawning_spawn_badges_modifiers",
					"cb_spawning_spawn_package",
					"cb_spawning_spawn_package_modifiers",
					"cb_spawning_spawn_speed",
					"cb_spawning_spawn_speed_modifiers",
					"cb_spawning_spawn_kit",
					"cb_spawning_spawn_kit_modifiers",
					"cb_spawning_spawn_strength",
					"cb_spawning_spawn_strength_modifiers",
					"cb_spawning_spawn_frag",
					"cb_spawning_spawn_frag_modifiers",
					"cb_spawning_spawn_fire",
					"cb_spawning_spawn_fire_modifiers",
					"cb_spawning_spawn_lorebook_page",
					"cb_spawning_spawn_lorebook_page_modifiers",
					"cb_spawning_spawn_torch",
					"cb_spawning_spawn_torch_modifiers",
					"cb_spawning_spawn_grim",
					"cb_spawning_spawn_grim_modifiers",
					"cb_spawning_spawn_tome",
					"cb_spawning_spawn_tome_modifiers",
					"cb_spawning_spawn_brawl_unarmed",
					"cb_spawning_spawn_brawl_unarmed_modifiers",
					"cb_spawning_spawn_wooden_sword",
					"cb_spawning_spawn_wooden_sword_modifiers",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_spawning_spawn_badges",
					"cb_spawning_spawn_badges_modifiers",
					"cb_spawning_spawn_package",
					"cb_spawning_spawn_package_modifiers",
					"cb_spawning_spawn_speed",
					"cb_spawning_spawn_speed_modifiers",
					"cb_spawning_spawn_kit",
					"cb_spawning_spawn_kit_modifiers",
					"cb_spawning_spawn_strength",
					"cb_spawning_spawn_strength_modifiers",
					"cb_spawning_spawn_frag",
					"cb_spawning_spawn_frag_modifiers",
					"cb_spawning_spawn_fire",
					"cb_spawning_spawn_fire_modifiers",
					"cb_spawning_spawn_lorebook_page",
					"cb_spawning_spawn_lorebook_page_modifiers",
					"cb_spawning_spawn_torch",
					"cb_spawning_spawn_torch_modifiers",
					"cb_spawning_spawn_grim",
					"cb_spawning_spawn_grim_modifiers",
					"cb_spawning_spawn_tome",
					"cb_spawning_spawn_tome_modifiers",
					"cb_spawning_spawn_brawl_unarmed",
					"cb_spawning_spawn_brawl_unarmed_modifiers",
					"cb_spawning_spawn_wooden_sword",
					"cb_spawning_spawn_wooden_sword_modifiers",
				}
			},
		},
	},
	HK_SPAWN_BADGES = {
		["save"] = "cb_spawning_spawn_badges",
		["widget_type"] = "keybind",
		["text"] = "Badges",
		["default"] = {
			"b",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "badges"},
	},
	HK_SPAWN_PACKAGE = {
		["save"] = "cb_spawning_spawn_package",
		["widget_type"] = "keybind",
		["text"] = "Supply Drop",
		["default"] = {
			"f1",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "package"},
	},
	HK_SPAWN_KIT = {
		["save"] = "cb_spawning_spawn_kit",
		["widget_type"] = "keybind",
		["text"] = "First Aid Kit",
		["default"] = {
			"f2",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "first_aid_kit"},
	},
	HK_SPAWN_SPEED = {
		["save"] = "cb_spawning_spawn_speed",
		["widget_type"] = "keybind",
		["text"] = "Speed Potion",
		["default"] = {
			"f3",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "speed_boost_potion"},
	},
	HK_SPAWN_STRENGTH = {
		["save"] = "cb_spawning_spawn_strength",
		["widget_type"] = "keybind",
		["text"] = "Strength Potion",
		["default"] = {
			"f4",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "damage_boost_potion"},
	},
	HK_SPAWN_FRAG = {
		["save"] = "cb_spawning_spawn_frag",
		["widget_type"] = "keybind",
		["text"] = "Frag Grenade",
		["default"] = {
			"f5",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "frag_grenade_t2"},
	},
	HK_SPAWN_FIRE = {
		["save"] = "cb_spawning_spawn_fire",
		["widget_type"] = "keybind",
		["text"] = "Fire Grenade",
		["default"] = {
			"f6",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "fire_grenade_t2"},
	},
	HK_SPAWN_LOREBOOK_PAGE = {
		["save"] = "cb_spawning_spawn_lorebook_page",
		["widget_type"] = "keybind",
		["text"] = "Lorebook page",
		["default"] = {
			"f7",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "lorebook_page"},
	},
	HK_SPAWN_TORCH = {
		["save"] = "cb_spawning_spawn_torch",
		["widget_type"] = "keybind",
		["text"] = "Torch",
		["default"] = {
			"f8",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "torch"},
	},
	HK_SPAWN_GRIM = {
		["save"] = "cb_spawning_spawn_grim",
		["widget_type"] = "keybind",
		["text"] = "Grim",
		["default"] = {
			"f9",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "grimoire"},
	},
	HK_SPAWN_TOME = {
		["save"] = "cb_spawning_spawn_tome",
		["widget_type"] = "keybind",
		["text"] = "Tome",
		["default"] = {
			"f10",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "tome"},
	},
	-- HK_SPAWN_SMOKE = {
	-- 	["save"] = "cb_spawning_spawn_smoke",
	-- 	["widget_type"] = "keybind",
	-- 	["text"] = "Smoke Grenade",
	-- 	["default"] = {
	-- 		"f11",
	-- 		oi.key_modifiers.CTRL,
	-- 	},
	-- 	["exec"] = {"ItemSpawner", "spawn/smoke_grenade_t2"},
	-- },
	HK_SPAWN_BEER_BARREL = {
		["save"] = "cb_spawning_spawn_brawl_unarmed",
		["widget_type"] = "keybind",
		["text"] = "Beer barrel",
		["default"] = {
			"f11",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "brawl_unarmed"},
	},
	HK_SPAWN_WOODEN_SWORD = {
		["save"] = "cb_spawning_spawn_wooden_sword",
		["widget_type"] = "keybind",
		["text"] = "Wooden Sword",
		["default"] = {
			"f12",
			oi.key_modifiers.CTRL,
		},
		["exec"] = {"patch/spawn", "wooden_sword"},
	},
}

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

-- ####################################################################################################################
-- ##### Option #######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("spawning", "Spawning")

	Mods.option_menu:add_item("spawning", mod.widget_settings.SPAWN_PICKUPS, true)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_BADGES)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_PACKAGE)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_KIT)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_SPEED)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_STRENGTH)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_FRAG)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_FIRE)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_LOREBOOK_PAGE)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_TORCH)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_GRIM)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_TOME)
	--Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_SMOKE)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_BEER_BARREL)
	Mods.option_menu:add_item("spawning", mod.widget_settings.HK_SPAWN_WOODEN_SWORD)
end

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
