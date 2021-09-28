--[[
	Name: Player Name (ported from VMF)
	Author: IamLupo
	Updated: uladz
	Version: 1.3.1
	Original link: https://www.nexusmods.com/vermintide/mods/26

	Displays player names above their character.
	Option for health color coding.

  Version history:
	1.0.0 Release.
	1.0.1 Removed missing material.
	1.1.0 Characters in insta kill state will have white names.
	1.1.1 Options moved to hud group.
	1.2.0 Transelated to English and Dutch.
	1.3.0 Ported from VMF to QoL, sorry no dutch.
	1.3.1 Added option to change the font size, menu reorg to better fit to QoL.
--]]

local mod_name = "PlayerName"
PlayerName = {}
local mod = PlayerName

mod.widget_settings = {
	ACTIVATE = {
		["save"] = "cb_player_name_activate",
		["widget_type"] = "stepper",
		["text"] = "Show Player Name",
		["tooltip"] = "Show Player Name\n" ..
			"Shows the player name floating above player character.",
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
					"cb_player_name_font_size",
					"cb_player_name_color",
					"cb_player_name_alpha",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_player_name_font_size",
					"cb_player_name_color",
					"cb_player_name_alpha",
				}
			},
		},
	},
-- edit --
	FONT_SIZE = {
    ["save"] = "cb_player_name_font_size",
    ["widget_type"] = "slider",
    ["text"] = "Font Size",
    ["tooltip"] = "Font Size\n" ..
      "Changes font size of the floating player name.",
    ["range"] = {1, 200},
    ["default"] = 100,
  },
-- edit --
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
			"Changes transparanty of the floating player name in procentages.",
		["range"] = {1, 100},
		["default"] = 70,
	},
}

mod.gui = nil

--[[
  Options
--]]

mod.create_options = function()
	local group = "hud_group"
	Mods.option_menu:add_group(group, "HUD Improvements")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVATE, true)
	Mods.option_menu:add_item(group, mod.widget_settings.FONT_SIZE)
	Mods.option_menu:add_item(group, mod.widget_settings.COLOR)
	Mods.option_menu:add_item(group, mod.widget_settings.ALPHA)
end

--[[
  Functions
--]]

mod.get = function(data)
	return Application.user_setting(data.save)
end

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

--[[
  Hooks
--]]

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

	if mod.get(mod.widget_settings.ACTIVATE) then
		pcall(function()
			local human_players = Managers.player:human_players()

			local font_size = mod.get(mod.widget_settings.FONT_SIZE) / 1000
			local font = "gw_body_32"
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
					local alpha = 2.55 * mod.get(mod.widget_settings.ALPHA)

					-- Generate player name color
					local color = Color(0, 0, 0, 0)
					if mod.get(mod.widget_settings.COLOR) == "by_health" then
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
						color = Colors.get_color_with_alpha(mod.get(mod.widget_settings.COLOR), alpha)
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

--[[
	Start
--]]

mod.create_options()
mod.init()
