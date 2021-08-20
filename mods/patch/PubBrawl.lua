--[[
	Pub Brawl
	Author: IamLupo and Aussiemon (ported from VMF by uladz)
	Version: 1.0.0
	Link: https://www.nexusmods.com/vermintide/mods/27

	In the past Pub Brawl was disabled, with this we can battle again in the inn.

	Had enough of Kruber questioning your family tree? That Elf's quick quips getting to you? Well,
	now's your chance to exact drunken justice on your friends and team mates! Just be careful, not
	everyone has it in them to slap an ogre to the chops! https://youtu.be/r2IBtsnkiq8
]]--

local mod_name = "PubBrawl"
local oi = OptionsInjector

local MOD_SETTINGS = {
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
}

local spawn_time = 0

-- Mod options
local create_options = function()
	Mods.option_menu:add_group("funny", "Totaly unnecessary funny stuff")
	Mods.option_menu:add_item("funny", MOD_SETTINGS.ACTIVE, true)
end

-- Spawn brawl items
local spawn_items = function()
	-- Wooden Sword
	Managers.state.network.network_transmit:send_rpc_server(
		"rpc_spawn_pickup_with_physics",
		NetworkLookup.pickup_names["wooden_sword_01"],
		Vector3(-3.4, -3.5, 1),
		Quaternion.axis_angle(Vector3(0, 0, 18), 0.1),
		NetworkLookup.pickup_spawn_types["dropped"]
	)

	-- Beer barrel
	Managers.state.network.network_transmit:send_rpc_server(
		"rpc_spawn_pickup_with_physics",
		NetworkLookup.pickup_names["brawl_unarmed"],
		Vector3(3.8, -2.7, 0.98),
		Quaternion.axis_angle(Vector3(0, 0, 0), 0),
		NetworkLookup.pickup_spawn_types["dropped"]
	)
end

-- Hook
Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, self)
	func(self)

	if Application.user_setting(MOD_SETTINGS.ACTIVE.save) then
		if Managers.player.is_server then
			if Managers.state.game_mode._game_mode_key == "inn" then
				-- initialize spawn time
				spawn_time = 0

				-- Make the hook
				Mods.hook.set(mod_name, "MatchmakingManager.update", function(func2, self2, dt, t)
					func2(self2, dt, t)

					-- initialize spawn time
					if spawn_time == 0 then
						spawn_time = t
					end

					-- Check time has paster 1 second
					if spawn_time + 1 > t then
						return
					end

					-- Spawn items
					spawn_items()

					-- Disable the hook
					Mods.hook.enable(false, mod_name, "MatchmakingManager.update")
				end)
			end
		end
	end
end)

-- Allows you to have the pvp back in the inn.
-- Mods.hook.set(mod_name, "GameModeManager.pvp_enabled", function (func, self)
	-- local is_inside_inn = false

	-- if Managers and Managers.state and Managers.state.game_mode then
		-- is_inside_inn = Managers.state.game_mode:level_key() == "inn_level"
	-- end

	-- if is_inside_inn then
		-- return true
	-- end

	-- return func(self)
-- end)

-- Start
create_options()
