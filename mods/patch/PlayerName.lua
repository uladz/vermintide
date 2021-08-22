--[[
	Player Name
	Author: IamLupo (ported from VMF by uladz)
	Version: 1.2.0
	Link: https://www.nexusmods.com/vermintide/mods/26

	Displays player names above their character.
	Option for health color coding.
--]]

local mod_name = "PlayerName"
local oi = OptionsInjector

PlayerName = {}
local mod = PlayerName

mod.get = Application.user_setting
mod.set = Application.set_user_setting
mod.save = Application.save_user_settings

mod.widget_settings = {
	SHOW = {
		["save"] = "cb_player_name_show",
		["widget_type"] = "checkbox",
		["text"] = "Player Name",
		["default"] = false,
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_player_name_activate",
					"cb_player_name_color",
					"cb_player_name_alpha",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_player_name_activate",
					"cb_player_name_color",
					"cb_player_name_alpha",
				}
			},
		},
	},
	ACTIVATE = {
		["save"] = "cb_player_name_activate",
		["widget_type"] = "stepper",
		["text"] = "Active",
		["tooltip"] = "Active\n" ..
			"Shows the player name above player in the 3D world.",
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
					"cb_player_name_color",
					"cb_player_name_alpha",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_player_name_color",
					"cb_player_name_alpha",
				}
			},
		},
	},
	COLOR = {
		["save"] = "cb_player_name_color",
		["widget_type"] = "dropdown",
		["text"] = "Color",
		["tooltip"] = "Color\n" ..
			"Color of player name.\n" ..
			"\n" ..
			"By health - Show the player name color by health state of the player.\n" ..
			"White - Show the player name in white.\n" ..
			"Red - Show the player name in red.\n" ..
			"Green - Show the player name in green.\n" ..
			"Blue - Show the player name in  blue.",
		["value_type"] = "string",
		["options"] = {
			{text = "By Health", value = "by_health"},
			{text = "White", value = "white"},
			{text = "Red", value = "red"},
			{text = "Green", value = "green"},
			{text = "Blue", value = "blue"},
		},
		["default"] = 1, -- Default first option is enabled. In this case "By Health"
	},
	ALPHA = {
		["save"] = "cb_player_name_alpha",
		["widget_type"] = "slider",
		["text"] = "Transparanty",
		["tooltip"] = "Transparanty\n" ..
			"Set the Transparanty of the name in procentages.",
		["range"] = {1, 100},
		["default"] = 70,
	},
}

mod.gui = nil

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("hud", "HUD")

	Mods.option_menu:add_item("hud", mod.widget_settings.SHOW, true)
	Mods.option_menu:add_item("hud", mod.widget_settings.ACTIVATE)
	Mods.option_menu:add_item("hud", mod.widget_settings.COLOR)
	Mods.option_menu:add_item("hud", mod.widget_settings.ALPHA)
end

-- ####################################################################################################################
-- ##### Function #####################################################################################################
-- ####################################################################################################################
mod.init = function()
	mod.gui = World.create_world_gui(
		Application.main_world(),
		Matrix4x4.identity(), 1, 1,
		"immediate",
		"material", "materials/ui/ui_1080p_title_screen",
		"material", "materials/fonts/gw_fonts",
		"material", "materials/ui/ui_1080p_ingame_common"
	)
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, ...)
	func(...)

	mod.init()
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_actually_starts", function(func, ...)
	func(...)

	mod.init()
end)

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, ...)
	func(...)

	if mod.get(mod.widget_settings.ACTIVATE.save) then
		pcall(function()
			local human_players = Managers.player:human_players()

			local font_size = 0.2
			local font = "gw_arial_32"
			local font_material = "materials/fonts/" .. font

			for _, player in pairs(human_players) do
				if player.remote then
					local player_name = tostring(player._cached_name)
					local player_unit = player.player_unit
					local player_head_index = Unit.node(player_unit, "j_head")
					local player_head_pos = Unit.world_position(player_unit, player_head_index)

					local camera_rotation = Managers.state.camera:camera_rotation("player_1")
					local tm = Matrix4x4.from_quaternion_position(camera_rotation, player_head_pos)

					-- Generate position based on the middle of the player name on screen
					local text_extent_min, text_extent_max = Gui.text_extents(mod.gui, player_name, font_material, font_size)
					local text_width = text_extent_max[1] - text_extent_min[1]
					local text_offset = Vector3(-text_width/2, 0.3, 0)

					-- Generate player name transparancy
					local alpha = 2.55 * mod.get(mod.widget_settings.ALPHA.save)

					-- Generate player name color
					local color = Color(0, 0, 0, 0)
					if mod.get(mod.widget_settings.COLOR.save) == "by_health" then
						-- Get health
						local health_extension = ScriptUnit.extension(player_unit, "health_system")
						local health_percent = health_extension:current_health_percent()
						local status_extension = health_extension.status_extension

						if not status_extension:has_wounds_remaining() then
							color = Colors.get_color_with_alpha("white", alpha)
						else
							if health_percent > 0.8 then
								color = Colors.get_color_with_alpha("green", alpha)
							elseif health_percent > 0.3 then
								color = Colors.get_color_with_alpha("yellow", alpha)
							else
								color = Colors.get_color_with_alpha("red", alpha)
							end
						end
					else
						color = Colors.get_color_with_alpha(mod.get(mod.widget_settings.COLOR.save), alpha)
					end

					-- Draw
					Gui.text_3d(
						mod.gui, player_name, font_material, font_size, font,
						tm, text_offset, 0, color
					)
				end
			end
		end)
	end
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
mod.init()
