--[[
  Compass
	Author: woobilicious, uladz
	Version: 1.0.3
	Original link: https://www.nexusmods.com/vermintide/mods/52

	Simple Compass HUD addition.

  Version history:
  1.0.1 - ported from VMF to QoL
  1.0.2 - added ON/OFF switch in mod option under "HUD Improvements" group.
	1.0.3 - added options to change vertical position and font size of the compass.
--]]

local mod_name = "Compass"
local oi = OptionsInjector

local MOD_SETTINGS = {
	SHOW = {
		["save"] = "cb_compass_show",
		["widget_type"] = "stepper",
		["text"] = "Show Compass",
		["tooltip"] = "Show Compass\n" ..
			"Shows simple compass in HUD.",
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
					"cb_compass_position",
					"cb_compass_font_size",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_compass_position",
					"cb_compass_font_size",
				}
			},
		},
  },
	POSITION = {
    ["save"] = "cb_compass_position",
    ["widget_type"] = "slider",
    ["text"] = "Vertical Position",
    ["tooltip"] = "Vertical Position\n" ..
      "Changes compass vertical position from the top of the screen.",
    ["range"] = {0, 200},
    ["default"] = 60,
  },
	FONT_SIZE = {
    ["save"] = "cb_compass_font_size",
    ["widget_type"] = "slider",
    ["text"] = "Font Size",
    ["tooltip"] = "Font Size\n" ..
      "Changes font size of the compass.",
    ["range"] = {1, 100},
    ["default"] = 32,
  },
}

local create_options = function()
	Mods.option_menu:add_group("hud_group", "HUD Improvements")
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.SHOW, true)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.POSITION)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.FONT_SIZE)
end

local get = function(data)
	return Application.user_setting(data.save)
end

local scenegraph_def = {
  root = {
    scale = "fit",
    size = {
      1920,
      1080
    },
    position = {
      0,
      0,
      UILayer.hud
    }
  }
}

local compass_ui_def = {
  scenegraph_id = "root",
  element = {
    passes = {
      {
        style_id = "compass_text",
        pass_type = "text",
        text_id = "compass_text",
      }
    }
  },
  content = {
    compass_text = "NW",
  },
  style = {
    compass_text = {
      font_type = "hell_shark",
      font_size = 32,
      vertical_alignment = "top",
      horizontal_alignment = "center",
      offset = {
        0,
        -60,
        0
      }
    }
  },
  offset = {
    0,
    0,
    0
  }
}

local fake_input_service = {
  get = function ()
    return
  end,
  has = function ()
    return
  end
}

Compass = {
  ui_widget = nil,
  ui_renderer = nil,
  ui_scenegraph = nil
}

local init_ui_widget = function()
  if Compass.ui_widget then
		return
	end
  local world = Managers.world:world("top_ingame_view")
  Compass.ui_renderer = UIRenderer.create(world, "material", "materials/fonts/gw_fonts")
  Compass.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_def)
  Compass.ui_widget = UIWidget.init(compass_ui_def)
end

local get_rotation = function()
  local player = Managers.player:local_player()
  local unit = player.player_unit
  local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
  local rot = Quaternion.yaw(first_person_extension:current_rotation()) * (-180/math.pi)
  if rot < 0.0 then
    rot = 360.0 + rot
  end
  return rot
end

local rot_to_cardinal = function(d)
  local a = 360/16
  if d <= a or d >= a*15 then
    return "N"
  elseif d <= a*3 then
    return "NE"
  elseif d <= a*5 then
    return "E"
  elseif d <= a*7 then
    return "SE"
  elseif d <= a*9 then
    return "S"
  elseif d <= a*11 then
    return "SW"
  elseif d <= a*13 then
    return "W"
  elseif d <= a*15 then
    return "NW"
  else
    return "?"
  end
end

local draw_hook = function(func, self, dt, t, my_player)
  if get(MOD_SETTINGS.SHOW) then
    if not Compass.ui_widget then
      init_ui_widget()
    end

    local rot = 999999
    if pcall(function () rot = get_rotation() end) then
      local widget = Compass.ui_widget
      local renderer = Compass.ui_renderer
      local scenegraph = Compass.ui_scenegraph

      widget.content.compass_text = rot_to_cardinal(rot)
			widget.style.compass_text.offset[2] = -get(MOD_SETTINGS.POSITION)
			widget.style.compass_text.font_size = get(MOD_SETTINGS.FONT_SIZE)
      UIRenderer.begin_pass(renderer, scenegraph, fake_input_service, dt)
      UIRenderer.draw_widget(renderer, widget)
      UIRenderer.end_pass(renderer)
    end
  end

  return func(self, dt, t, my_player)
end

Mods.hook.set(mod_name, "IngameHud.update", draw_hook)
create_options()
