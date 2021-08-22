local mod_name = "Crosshair"

local oi = OptionsInjector

local preserved_default_sizes
if Crosshair and Crosshair.default_sizes then
	preserved_default_sizes = Crosshair.default_sizes
end

local enlarge_off = 1
local enlarge_slightly = 2
local enlarge_heavily = 3

Crosshair = {
	SETTINGS = {
		SUB_GROUP = {
			["save"] = "cb_crosshair_subgroup",
			["widget_type"] = "dropdown_checkbox",
			["text"] = "Crosshair",
			["default"] = false,
			["hide_options"] = {
				{
					true,
					mode = "show",
					options = {
						"cb_crosshair_color",
                        "cb_crosshair_color_main_red",
                        "cb_crosshair_color_main_green",
                        "cb_crosshair_color_main_blue",
						"cb_crosshair_enlarge",
						"cb_crosshair_dot",
                        "cb_crosshair_no_melee_dot",
						"cb_crosshair_headshot_marker"
					},
				},
				{
					false,
					mode = "hide",
					options = {
						"cb_crosshair_color",
                        "cb_crosshair_color_main_red",
                        "cb_crosshair_color_main_green",
                        "cb_crosshair_color_main_blue",
						"cb_crosshair_enlarge",
						"cb_crosshair_dot",
                        "cb_crosshair_no_melee_dot",
						"cb_crosshair_headshot_marker"
					},
				},
			},
		},
        COLOR_MAIN_RED = {
		["save"] = "cb_crosshair_color_main_red",
		["widget_type"] = "slider",
		["text"] = "Crosshair Red Value",
		["tooltip"] =  "Crosshair Red Value\n" ..
				"Changes the red color value of your crosshair.",
		["range"] = {0, 255},
		["default"] = 255,
	    },
        COLOR_MAIN_GREEN = {
		["save"] = "cb_crosshair_color_main_green",
		["widget_type"] = "slider",
		["text"] = "Crosshair Green Value",
		["tooltip"] =  "Crosshair Green Value\n" ..
				"Changes the green color value of your crosshair.",
		["range"] = {0, 255},
		["default"] = 255,
	    },
        COLOR_MAIN_BLUE = {
		["save"] = "cb_crosshair_color_main_blue",
		["widget_type"] = "slider",
		["text"] = "Crosshair Blue Value",
		["tooltip"] =  "Crosshair Blue Value\n" ..
				"Changes the blue color value of your crosshair.",
		["range"] = {0, 255},
		["default"] = 255,
	    },
        COLOR_HS_RED = {
		["save"] = "cb_crosshair_color_hs_red",
		["widget_type"] = "slider",
		["text"] = "Headshot Marker Red Value",
		["tooltip"] =  "Headshot Marker Red Value\n" ..
				"Changes the red color value of your crosshair headshot marker.",
		["range"] = {0, 255},
		["default"] = 255,
	    },
        COLOR_HS_GREEN = {
		["save"] = "cb_crosshair_color_hs_green",
		["widget_type"] = "slider",
		["text"] = "Headshot Marker Green Value",
		["tooltip"] =  "Headshot Marker Green Value\n" ..
				"Changes the green color value of your crosshair headshot marker.",
		["range"] = {0, 255},
		["default"] = 255,
	    },
        COLOR_HS_BLUE = {
		["save"] = "cb_crosshair_color_hs_blue",
		["widget_type"] = "slider",
		["text"] = "Headshot Marker Blue Value",
		["tooltip"] =  "Headshot Marker Blue Value\n" ..
				"Changes the blue color value of your crosshair headshot marker.",
		["range"] = {0, 255},
		["default"] = 255,
	    },
		ENLARGE = {
			["save"] = "cb_crosshair_enlarge",
			["widget_type"] = "stepper",
			["text"] = "Enlarge",
			["tooltip"] =  "Enlarge\n" ..
				"Increases the size of your crosshair.",
			["value_type"] = "number",
			["options"] = {
				{text = "Off", value = enlarge_off},
				{text = "Slightly", value = enlarge_slightly},
				{text = "Heavily", value = enlarge_heavily},
			},
			["default"] = enlarge_off,
		},
		DOT_ONLY = {
			["save"] = "cb_crosshair_dot",
			["widget_type"] = "stepper",
			text = "Dot Only",
			tooltip = "Dot Only\n" ..
					"Forces the crosshair to remain as only a dot, even with ranged weapons.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 1, -- Default second option is enabled. In this case Off
		},
		HEADSHOT_MARKER = {
			["save"] = "cb_crosshair_headshot_marker",
			["widget_type"] = "stepper",
			["text"] = "Headshot indicator",
			["tooltip"] = "Headshot marker\n" ..
					"Adds a marker to the crosshair on headshots.",
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
						"cb_crosshair_color_hs_red",
                        "cb_crosshair_color_hs_green",
                        "cb_crosshair_color_hs_blue",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_crosshair_color_hs_red",
                        "cb_crosshair_color_hs_green",
                        "cb_crosshair_color_hs_blue",
					}
				},
			},
		},
        NO_MELEE_DOT = {
			["save"] = "cb_crosshair_no_melee_dot",
			["widget_type"] = "stepper",
			text = "No Melee Dot",
			tooltip = "No Melee Dot\n" ..
					"Disables the dot when you have your melee equipped.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 1, -- Default second option is enabled. In this case Off
		},
	},
}

Crosshair.headshot_animations = {}
Crosshair.headshot_widgets = {}

if preserved_default_sizes then
	Crosshair.default_sizes = preserved_default_sizes
end

local mod = Crosshair

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

local colors = {
	{255, 255, 255, 255},
	{255, 255, 0, 0},
	{255, 0, 255, 0},
}

--- Options
Crosshair.create_options = function()
	Mods.option_menu:add_group("hud_group", "HUD Improvements")

	Mods.option_menu:add_item("hud_group", mod.SETTINGS.SUB_GROUP, true)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.COLOR_MAIN_RED)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.COLOR_MAIN_GREEN)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.COLOR_MAIN_BLUE)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.ENLARGE)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.DOT_ONLY)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.NO_MELEE_DOT)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.HEADSHOT_MARKER)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.COLOR_HS_RED)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.COLOR_HS_GREEN)
    Mods.option_menu:add_item("hud_group", mod.SETTINGS.COLOR_HS_BLUE)
end

local widget_definitions = {
	crosshair_hit_1 = {
		scenegraph_id = "crosshair_hit_2",
		element = UIElements.RotatedTexture,
		content = {
			texture_id = "crosshair_01_hit"
		},
		style = {
			rotating_texture = {
				angle = math.pi*2,
				pivot = {
					0,
					0
				},
				offset = {
					-8,
					1,
					0
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		}
	},
	crosshair_hit_2 = {
		scenegraph_id = "crosshair_hit_1",
		element = UIElements.RotatedTexture,
		content = {
			texture_id = "crosshair_01_hit"
		},
		style = {
			rotating_texture = {
				angle = math.pi*1.5,
				pivot = {
					0,
					0
				},
				offset = {
					8,
					1,
					0
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		}
	},
	crosshair_hit_3 = {
		scenegraph_id = "crosshair_hit_4",
		element = UIElements.RotatedTexture,
		content = {
			texture_id = "crosshair_01_hit"
		},
		style = {
			rotating_texture = {
				angle = math.pi*1,
				pivot = {
					0,
					0
				},
				offset = {
					8,
					-1,
					0
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		}
	},
	crosshair_hit_4 = {
		scenegraph_id = "crosshair_hit_3",
		element = UIElements.RotatedTexture,
		content = {
			texture_id = "crosshair_01_hit"
		},
		style = {
			rotating_texture = {
				angle = math.pi*0.5,
				pivot = {
					0,
					0
				},
				offset = {
					-8,
					-1,
					0
				},
				color = {
					0,
					255,
					255,
					255
				}
			}
		}
	},
}

local function populate_defaults(crosshair_ui)
	if not Crosshair.default_sizes then
		Crosshair.default_sizes = {
			crosshair_dot = table.clone(crosshair_ui.ui_scenegraph.crosshair_dot.size),
			crosshair_up = table.clone(crosshair_ui.ui_scenegraph.crosshair_up.size),
			crosshair_down = table.clone(crosshair_ui.ui_scenegraph.crosshair_down.size),
			crosshair_left = table.clone(crosshair_ui.ui_scenegraph.crosshair_left.size),
			crosshair_right = table.clone(crosshair_ui.ui_scenegraph.crosshair_right.size),
		}
	end
end

Mods.hook.set(mod_name, "CrosshairUI.draw", function (func, self, dt)
	func(self, dt)

	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_service = self.input_manager:get_service("ingame_menu")

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt)
	for i = 1, 4 do
		UIRenderer.draw_widget(ui_renderer, Crosshair.headshot_widgets[i])
	end
	UIRenderer.end_pass(ui_renderer)
end)

Mods.hook.set(mod_name, "CrosshairUI.update_hit_markers", function (func, self, dt)
	func(self, dt)

	if not Crosshair.headshot_widgets[1] then
		for i=1,4 do
			Crosshair.headshot_widgets[i] = UIWidget.init(widget_definitions["crosshair_hit_"..i])
		end
	end

	local hud_extension = ScriptUnit.extension(self.local_player.player_unit, "hud_system")
	if hud_extension.headshot_hit_enemy then
		hud_extension.headshot_hit_enemy = nil

		for i = 1, 4 do
			local hit_marker = Crosshair.headshot_widgets[i]
			Crosshair.headshot_animations[i] = UIAnimation.init(UIAnimation.function_by_time, hit_marker.style.rotating_texture.color, 1, 255, 0, UISettings.crosshair.hit_marker_fade, math.easeInCubic)
		end
	end

	if Crosshair.headshot_animations[1] then
		for i = 1, 4 do
			UIAnimation.update(Crosshair.headshot_animations[i], dt)
		end

		if UIAnimation.completed(Crosshair.headshot_animations[1]) then
			for i = 1, 4 do
				Crosshair.headshot_animations[i] = nil
			end
		end
	end
end)

local change_crosshair_color = function(crosshair_ui)
    local main_color = {255, get(mod.SETTINGS.COLOR_MAIN_RED), get(mod.SETTINGS.COLOR_MAIN_GREEN), get(mod.SETTINGS.COLOR_MAIN_BLUE)}

    crosshair_ui.crosshair_dot.style.color = table.clone(main_color)
    crosshair_ui.crosshair_up.style.color = table.clone(main_color)
	crosshair_ui.crosshair_down.style.color = table.clone(main_color)
	crosshair_ui.crosshair_left.style.color = table.clone(main_color)
	crosshair_ui.crosshair_right.style.color = table.clone(main_color)

	if not crosshair_ui.hit_marker_animations[1] then
		for i,v in ipairs(crosshair_ui.hit_markers) do
		  v.style.rotating_texture.color = table.clone(main_color)
		  v.style.rotating_texture.color[1] = 0
		end
	end

	if Crosshair.headshot_widgets[1] and not Crosshair.headshot_animations[1] then
        local hs_color = {255, get(mod.SETTINGS.COLOR_HS_RED), get(mod.SETTINGS.COLOR_HS_GREEN), get(mod.SETTINGS.COLOR_HS_BLUE)}
		for i = 1, 4 do
			Crosshair.headshot_widgets[i].style.rotating_texture.color = table.clone(hs_color)
			Crosshair.headshot_widgets[i].style.rotating_texture.color[1] = 0
		end
	end
end

local change_crosshair_scale = function(crosshair_ui)
	local crosshair_dot_scale = 1
	local crosshair_lines_scale = 1

	if get(mod.SETTINGS.ENLARGE) == enlarge_slightly then
		crosshair_dot_scale = 1.5
		crosshair_lines_scale = 1.2
	elseif get(mod.SETTINGS.ENLARGE) == enlarge_heavily then
		crosshair_dot_scale = 2
		crosshair_lines_scale = 1.5
	end

	for k,v in pairs(Crosshair.default_sizes) do
		for i,v in ipairs(Crosshair.default_sizes[k]) do
		  crosshair_ui.ui_scenegraph[k].size[i] = v * crosshair_lines_scale
		end
	end

	for i,v in ipairs(Crosshair.default_sizes.crosshair_dot) do
		crosshair_ui.ui_scenegraph.crosshair_dot.size[i] = v * crosshair_dot_scale
	end
end

Mods.hook.set(mod_name, "CrosshairUI.draw_dot_style_crosshair", function(func, self, ...)
	populate_defaults(self)
	change_crosshair_scale(self)
	change_crosshair_color(self)

    if get(mod.SETTINGS.NO_MELEE_DOT) then
        self.crosshair_dot.style.color[1] = 0;
	end

    return func(self, ...)
end)

Mods.hook.set(mod_name, "CrosshairUI.draw_default_style_crosshair", function(func, self, ...)
	populate_defaults(self)
	change_crosshair_scale(self)
	change_crosshair_color(self)

    if get(mod.SETTINGS.DOT_ONLY) then
        crosshair_ui.crosshair_up.style.color[1] = 0
        crosshair_ui.crosshair_down.style.color[1] = 0
        crosshair_ui.crosshair_left.style.color[1] = 0
        crosshair_ui.crosshair_right.style.color[1] = 0
	end

    return func(self, ...)
end)

Mods.hook.set(mod_name, "DamageSystem.rpc_add_damage", function (func, self, sender, victim_unit_go_id, attacker_unit_go_id, attacker_is_level_unit, damage_amount, hit_zone_id, damage_type_id, damage_direction, damage_source_id, hit_ragdoll_actor_id)
	func(self, sender, victim_unit_go_id, attacker_unit_go_id, attacker_is_level_unit, damage_amount, hit_zone_id, damage_type_id, damage_direction, damage_source_id, hit_ragdoll_actor_id)

	if not get(mod.SETTINGS.HEADSHOT_MARKER) then
		return
	end

	local victim_unit = self.unit_storage:unit(victim_unit_go_id)

	local attacker_unit = nil
	if attacker_is_level_unit then
		attacker_unit = LevelHelper:unit_by_index(self.world, attacker_unit_go_id)
	else
		attacker_unit = self.unit_storage:unit(attacker_unit_go_id)
	end

	if not Unit.alive(victim_unit) then
		return
	end

	if Unit.alive(attacker_unit) then
		if ScriptUnit.has_extension(attacker_unit, "hud_system") then
			local health_extension = ScriptUnit.extension(victim_unit, "health_system")
			local damage_source = NetworkLookup.damage_sources[damage_source_id]
			local should_indicate_hit = health_extension.is_alive(health_extension) and attacker_unit ~= victim_unit and damage_source ~= "wounded_degen"

			local hit_zone_name = NetworkLookup.hit_zones[hit_zone_id]

			if should_indicate_hit and (hit_zone_name == "head" or hit_zone_name == "neck") then
				local hud_extension = ScriptUnit.extension(attacker_unit, "hud_system")
				hud_extension.headshot_hit_enemy = true
			end
		end
	end
end)

Mods.hook.set(mod_name, "GenericUnitDamageExtension.add_damage", function (func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)
	func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)

	if not get(mod.SETTINGS.HEADSHOT_MARKER) then
		return
	end

	local victim_unit = self.unit
	if ScriptUnit.has_extension(attacker_unit, "hud_system") then
		local health_extension = ScriptUnit.extension(victim_unit, "health_system")
		local should_indicate_hit = health_extension.is_alive(health_extension) and attacker_unit ~= victim_unit and damage_source_name ~= "wounded_degen"

		if should_indicate_hit and (hit_zone_name == "head" or hit_zone_name == "neck") then
			local hud_extension = ScriptUnit.extension(attacker_unit, "hud_system")
			hud_extension.headshot_hit_enemy = true
		end
	end
end)

Crosshair.create_options()
