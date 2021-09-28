--[[
	Pub Brawl
	Author: IamLupo, Aussiemon (ported from VMF)
	Updated: uladz (since 1.1.0)
	Version: 1.2.0 (9/25/2021)
	Link: https://www.nexusmods.com/vermintide/mods/27
	Link: https://github.com/Aussiemon/Vermintide-JHF-Mods/blob/original_release/mods/patch/PubBrawl.lua

	In the past Pub Brawl was disabled, with this we can battle again in the inn.
	Had enough of Kruber questioning your family tree? That Elf's quick quips getting to you? Well,
	now's your chance to exact drunken justice on your friends and team mates! Just be careful, not
	everyone has it in them to slap an ogre to the chops! https://youtu.be/r2IBtsnkiq8

	Version history:
		1.0.0 Release.
		1.1.0 Merged with Aussiemon's GIT version of this mod.
		1.2.0 Added fire granade, options to enable barrel and extra items, spawn logic fixes, some
			code refactoring to unify with QoL code style.
--]]

local mod_name = "PubBrawl"
PubBrawl = {}
mod = PubBrawl

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_pub_brawl_active",
		["widget_type"] = "stepper",
		["text"] = "Pub Brawl",
		["tooltip"] =  "Pub Brawl\n" ..
			"Enables you to fight each other in the inn.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	BARREL_AND_SWORD = {
		["save"] = "cb_pub_brawl_barrel_and_sword",
		["widget_type"] = "stepper",
		["text"] = "Barrel and Swords",
		["tooltip"] = "Barrel and Swords\n" ..
			"Enables beer barrel and wooden swords spawning. Picking up these items start brawl as well.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	ADDITIONAL_ITEMS = {
		["save"] = "cb_pub_brawl_additional_items",
		["widget_type"] = "stepper",
		["text"] = "Additional Items",
		["tooltip"] = "Additional Items\n" ..
			"Enables additional item spawning. Adds bombs and potions to the inn.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

mod.spawn_time = 0

--[[
  Options
--]]

mod.create_options = function()
	local group = "funny"
	Mods.option_menu:add_group(group, "Totaly unnecessary funny stuff")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVE, true)
	Mods.option_menu:add_item(group, mod.widget_settings.BARREL_AND_SWORD, true)
	Mods.option_menu:add_item(group, mod.widget_settings.ADDITIONAL_ITEMS, true)
end

--[[
  Functions
--]]

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

mod.update_title_properties = function()
	if Managers.backend and Managers.backend._interfaces and Managers.backend._interfaces.title_properties then
		local title_properties = Managers.backend._interfaces.title_properties
		if not title_properties._data then
			title_properties._data = {
				brawl_enabled = true,
			}
		else
			title_properties._data.brawl_enabled = true
		end
	end
end

-- Spawn brawl items
mod.spawn_items = function()
	-- Wooden Sword #1
	Managers.state.network.network_transmit:send_rpc_server(
		"rpc_spawn_pickup_with_physics",
		NetworkLookup.pickup_names["wooden_sword_01"],
		Vector3(-3.4, -3.5, 1),
		Quaternion.axis_angle(Vector3(0, 0, 18), 0.1),
		NetworkLookup.pickup_spawn_types["dropped"]
	)

	-- Wooden Sword #2
	Managers.state.network.network_transmit:send_rpc_server(
		'rpc_spawn_pickup',
		NetworkLookup.pickup_names["wooden_sword_02"],
		Vector3(0.0, 0.4, 2),
		Quaternion.axis_angle(Vector3(5, 3, -8), .5),
		NetworkLookup.pickup_spawn_types['dropped']
	)

	-- Beer Barrel
	Managers.state.network.network_transmit:send_rpc_server(
		"rpc_spawn_pickup_with_physics",
		NetworkLookup.pickup_names["brawl_unarmed"],
		Vector3(3.8, -2.7, 0.98),
		Quaternion.axis_angle(Vector3(0, 0, 0), 0),
		NetworkLookup.pickup_spawn_types["dropped"]
	)
end

-- Spawn additional items
mod.spawn_extra_items = function()
	-- Frag Grenade
	Managers.state.network.network_transmit:send_rpc_server(
		'rpc_spawn_pickup',
		NetworkLookup.pickup_names["frag_grenade_t2"],
		Vector3(2.9, 3.9, 1.95),
		Quaternion.axis_angle(Vector3(0, 0, 0), 0),
		NetworkLookup.pickup_spawn_types['dropped']
	)

	-- Fire Grenade
	Managers.state.network.network_transmit:send_rpc_server(
		'rpc_spawn_pickup',
		NetworkLookup.pickup_names["fire_grenade_t2"],
		Vector3(0.1, 4.4, 1.90),
		Quaternion.axis_angle(Vector3(0, 0, 0), 0),
		NetworkLookup.pickup_spawn_types['dropped']
	)

	-- Strength Potion
	Managers.state.network.network_transmit:send_rpc_server(
		'rpc_spawn_pickup',
		NetworkLookup.pickup_names["damage_boost_potion"],
		Vector3(6.41, -3.15, 1.3),
		Quaternion.axis_angle(Vector3(0, 0, 0), 0),
		NetworkLookup.pickup_spawn_types['dropped']
	)

	-- Speed Potion
	Managers.state.network.network_transmit:send_rpc_server(
		'rpc_spawn_pickup',
		NetworkLookup.pickup_names["speed_boost_potion"],
		Vector3(-7.8, -4.7, 1.7),
		Quaternion.axis_angle(Vector3(0, 0, 0), 0),
		NetworkLookup.pickup_spawn_types['dropped']
	)
end

--[[
  Hooks
--]]

-- Handles initial spawning of pub items
Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, self)
	func(self)

	if mod.get(mod.widget_settings.ACTIVE) and Managers.player.is_server then
		if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then

			local barrel_sword = mod.get(mod.widget_settings.BARREL_AND_SWORD)
			local extra_items = mod.get(mod.widget_settings.ADDITIONAL_ITEMS)

			local total_items = 0
			if barrel_sword then
				total_items = total_items + 3
			end
			if extra_items then
				total_items = total_items + 3
			end

			-- Spawn items
			local pickup_system = Managers.state.entity:system("pickup_system")
			if mod.get(mod.widget_settings.BARREL_AND_SWORD) then
				if #pickup_system._spawned_pickups < total_items then
					mod.spawn_items()
				end
			end
			if mod.get(mod.widget_settings.ADDITIONAL_ITEMS) then
				if #pickup_system._spawned_pickups < total_items then
					mod.spawn_extra_items()
				end
			end
		end
	end
end)

-- Re-enables the flow event that causes Lohner to pour a drink when approached
Mods.hook.set(mod_name, "GameModeManager.pvp_enabled", function (func, self)

	if mod.get(mod.widget_settings.ACTIVE) then
		if Managers.state.game_mode and Managers.state.game_mode._game_mode_key == "inn" then
			return true
		end
	end

	return func(self)
end)

--[[
  Start
--]]

mod.create_options()
