local mod_name = "HUDTimers"
 
HUDTimers = {}
 
local user_setting = Application.user_setting
 
local MOD_SETTINGS = {
	SUB_GROUP = {
		["save"] = "cb_hud_potion_timer_subgroup",
		["widget_type"] = "dropdown_checkbox",
		["text"] = "Proc/Potion Timers",
		["default"] = false,
		["hide_options"] = {
			{
				true,
				mode = "show",
				options = {
					"cb_hud_potion_timer_indicator"
				},
			},
			{
				false,
				mode = "hide",
				options = {
					"cb_hud_potion_timer_indicator"
				},
			},
		},
	},
	POTION_TIMER_INDICATOR = {
		["save"] = "cb_hud_potion_timer_indicator",
		["widget_type"] = "stepper",
		["text"] = "Buff Timer Indicator",
		["tooltip"] = "Buff Timer Indicator\n" ..
			"Shows a timer when a potion or attack speed proc is active.",
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
					"cb_hud_potion_timer_indicator_position",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_hud_potion_timer_indicator_position",
				}
			},
		}
	},
	POTION_TIMER_INDICATOR_POSITION = {
		["save"] = "cb_hud_potion_timer_indicator_position",
		["widget_type"] = "stepper",
		["text"] = "Buff Timer Indicator Position",
		["tooltip"] = "Buff Timer Indicator Position\n" ..
			"Choose whether the timers appear at the top or bottom of your screen.",
		["value_type"] = "number",
		["options"] = {
			{text = "Top", value = 1},
			{text = "Bottom", value = 2},
		},
		["default"] = 1,
	},
}
 
-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
HUDTimers.create_options = function()
	Mods.option_menu:add_group("hud_group", "HUD Related Mods")
 
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.SUB_GROUP, true)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.POTION_TIMER_INDICATOR)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.POTION_TIMER_INDICATOR_POSITION)
end
 
-- ####################################################################################################################
-- ##### widget definitions ###########################################################################################
-- ####################################################################################################################
local function get_scenegraph_definition(owner)
	local indicator_position = user_setting(MOD_SETTINGS.POTION_TIMER_INDICATOR_POSITION.save)
	if owner._uitimers_indicator_position == indicator_position then
		return owner._uitimers_ui_scenegraph
	end
 
	-- There is no existing scenegraph, or its position has changed, so create a new
	-- scenegraph now.
	owner._uitimers_indicator_position = indicator_position
	local screen_w, screen_h = UIResolution()
	local is_top = indicator_position == 1
 
	local ui_scenegraph = {
		root = {
			is_root = true,
			position = {
				0,
				0,
				UILayer.hud
			},
			size = {
				screen_w,
				screen_h
			}
		},
		pivot = {
			parent = "root",
			vertical_alignment = is_top and "top" or "bottom",
			horizontal_alignment = "center",
			size = {
				screen_w,
				screen_h/2
			}
		},
		speed_pot_timer = {
			parent = "pivot",
			vertical_alignment = is_top and "top" or "bottom",
			horizontal_alignment = "center",
			position = {
				200,
				is_top and -screen_h/15 or 175,
				1
			},
			size = {
				80,
				80
			}
		},
		strength_pot_timer = {
			parent = "pivot",
			vertical_alignment = is_top and "top" or "bottom",
			horizontal_alignment = "center",
			position = {
				-200,
				is_top and -screen_h/15 or 175,
				1
			},
			size = {
				80,
				80
			}
		},
		proc_timer = {
			parent = "pivot",
			vertical_alignment = is_top and "top" or "bottom",
			horizontal_alignment = "center",
			position = {
				0,
				is_top and -screen_h/15 or 175,
				1
			},
			size = {
				80,
				80
			}
		},
	}
	owner._uitimers_ui_scenegraph = UISceneGraph.init_scenegraph(ui_scenegraph)
	return owner._uitimers_ui_scenegraph
end
 
-- Computes the vertices for a regular convex polygon with the given number of sides.
local function compute_polygon_vertices(side_count)
	local vertices = {}
	local angle_increment = 2*math.pi / side_count
	local angle = math.pi/2 - angle_increment/2
	for i = 1, side_count*2, 2 do
		vertices[i] = math.cos(angle)
		vertices[i + 1] = math.sin(angle)
		angle = angle + angle_increment
	end
	return vertices
end
 
local OCTAGON_VERTICES = compute_polygon_vertices(8)
local SQUARE_VERTICES = compute_polygon_vertices(4)
 
--[[
	Speed-up trait proc indicator to show when Berserk, Swift Slaying, or Haste has
	procced. The indicator shows the icon for the trait as both foreground and
	background, with the foreground acting as a progress bar and the background being
	fainter than the foreground.
--]]
local speedup_indicator_widget =
{
	scenegraph_id = "proc_timer",
	element = {
		passes = {
			{
				pass_type = "texture",
				texture_id = "speedup_icon_bg",
				style_id = "speedup_icon_bg",
			},
			{
				pass_type = "convex_polygon",
				content_id = "progress_bg_content",
				style_id = "progress_bg_style",
			},
			{
				pass_type = "progress_convex_polygon",
				content_id = "progress_content",
				style_id = "progress_fg_style",
			},
			{
				pass_type = "progress_convex_polygon",
				content_id = "secondary_progress_content",
				style_id = "progress_fg_secondary_style",
			},
		},
	},
	content = {
		speedup_icon_bg = "trait_icon_swiftslaying",
		progress_bg_content = {
			radius = 45,
			vertices = OCTAGON_VERTICES,
		},
		progress_content = {
			progress_value = 0,
			radius = 42,
			vertices = OCTAGON_VERTICES,
		},
		secondary_progress_content = {
			progress_value = 0,
			radius = 42,
			vertices = OCTAGON_VERTICES,
		},
	},
	style = {
		progress_bg_style = {
			color = { 70, 0, 0, 0 },
			offset = { 40, 40, 0 },
		},
		progress_fg_style = {
			color = { 255, 230, 225, 225 },
			offset = { 40, 40, 1 },
		},
		progress_fg_secondary_style = {
			color = Colors.get_table("orange"),
			offset = { 40, 40, 1 },
		},
		speedup_icon_bg = {
			size = { 66, 66 },
			offset = { 7, 7, 2 },
			color = { 255, 255, 255, 255 },
		},
	},
}
 
local speed_potion_indicator_widget =
{
	scenegraph_id = "speed_pot_timer",
	element = {
		passes = {
			{
				pass_type = "texture",
				texture_id = "potion_icon_bg",
				style_id = "potion_icon_bg",
			},
			{
				pass_type = "convex_polygon",
				content_id = "progress_bg_content",
				style_id = "progress_bg_style",
			},
			{
				pass_type = "progress_convex_polygon",
				content_id = "progress_content",
				style_id = "progress_fg_style",
			},
		},
	},
	content = {
		potion_icon_bg = "teammate_consumable_icon_speed",
		progress_bg_content = {
			radius = 57,
			vertices = SQUARE_VERTICES,
		},
		progress_content = {
			progress_value = 0,
			radius = 54,
			vertices = SQUARE_VERTICES,
		},
	},
	style = {
		progress_bg_style = {
			color = { 70, 0, 0, 0 },
			offset = { 40, 40, 0 },
		},
		progress_fg_style = {
			color = { 255, 230, 225, 225 },
			offset = { 40, 40, 1 },
		},
		potion_icon_bg = {
			size = { 64, 64 },
			offset = { 8, 8, 2 },
			color = { 255, 255, 255, 255 },
		},
	},
}
 
local strength_potion_indicator_widget =
{
	scenegraph_id = "strength_pot_timer",
	element = {
		passes = {
			{
				pass_type = "texture",
				texture_id = "potion_icon_bg",
				style_id = "potion_icon_bg",
			},
			{
				pass_type = "convex_polygon",
				content_id = "progress_bg_content",
				style_id = "progress_bg_style",
			},
			{
				pass_type = "progress_convex_polygon",
				content_id = "progress_content",
				style_id = "progress_fg_style",
			},
		},
	},
	content = {
		potion_icon_bg = "teammate_consumable_icon_strength",
		progress_bg_content = {
			radius = 57,
			vertices = SQUARE_VERTICES,
		},
		progress_content = {
			progress_value = 0,
			radius = 54,
			vertices = SQUARE_VERTICES,
		},
	},
	style = {
		progress_bg_style = {
			color = { 70, 0, 0, 0 },
			offset = { 40, 40, 0 },
		},
		progress_fg_style = {
			color = { 255, 230, 225, 225 },
			offset = { 40, 40, 1 },
		},
		potion_icon_bg = {
			size = { 64, 64 },
			offset = { 8, 8, 2 },
			color = { 255, 255, 255, 255 },
		},
	},
}
 
-- ####################################################################################################################
-- ##### locals #######################################################################################################
-- ####################################################################################################################
local speedup_info = {
	icon = "trait_icon_swiftslaying",
	start_time = -math.huge,
	end_time = -math.huge,
	-- End time for the "infinite ammo" secondary buff on Haste and Berserking for ranged weapons, which
	-- has shorter duration than the primary buff.
	secondary_end_time = -math.huge,
}
 
local speedpot_info = {
	start_time = -math.huge,
	end_time = -math.huge,
}
 
local strengthpot_info = {
	start_time = -math.huge,
	end_time = -math.huge,
}
 
-- Map from stat buff index to trait icon.
local speedup_icons = { }
 
-- Called when a speed-up buff is applied
local function notify_speedup_proc(unit, buff, params)
	if user_setting(MOD_SETTINGS.POTION_TIMER_INDICATOR.save) and unit == Managers.player:local_player().player_unit then
		local buff_extn = ScriptUnit.has_extension(unit, "buff_system")
		if buff_extn and buff.parent_id then
			-- The 'end_time + 10' check is just a safety net in case we somehow miss a buff-removed
			-- notification, otherwise we would stop showing speedup buffs forever if we missed one.
			if speedup_info.end_time == -math.huge or (speedup_info.end_time + 10) < params.t then
				local stat_buff_list = buff_extn._stat_buffs
				for stat_buff_index, icon in pairs(speedup_icons) do
					for _, stat_buff in pairs(stat_buff_list[stat_buff_index]) do
						if stat_buff.parent_id == buff.parent_id then
							speedup_info.icon = icon
							speedup_info.start_time = params.t
							speedup_info.end_time = params.end_time
							speedup_info.duration = params.end_time - params.t
							buff._hudmod_is_indicated = true
							return
						end
					end
				end
			end
		end
	end
end
 
-- Called when a speed-up buff is removed
local function notify_speedup_remove(unit, buff, params)
	if buff._hudmod_is_indicated then
		speedup_info.end_time = -math.huge
	end
end
 
-- Called when the "infinite ammo" secondary buff is applied for a Haste or Berserking proc
local function notify_infinite_ammo_proc(unit, buff, params)
	if user_setting(MOD_SETTINGS.POTION_TIMER_INDICATOR.save) and unit == Managers.player:local_player().player_unit then
		speedup_info.secondary_end_time = params.end_time
		buff._hudmod_is_indicated = true
	end
end
 
-- Called when the "infinite ammo" secondary buff is removed
local function notify_infinite_ammo_remove(unit, buff, params)
	if buff._hudmod_is_indicated then
		speedup_info.secondary_end_time = -math.huge
	end
end
 
-- Called when a str pot buff is applied
local function hudmod_notify_strength_pot_proc(unit, buff, params)
	if user_setting(MOD_SETTINGS.POTION_TIMER_INDICATOR.save) and unit == Managers.player:local_player().player_unit then
		local buff_extn = ScriptUnit.has_extension(unit, "buff_system")
		if buff_extn and buff.parent_id then
			strengthpot_info.start_time = params.t
			strengthpot_info.end_time = params.end_time
			buff._hudmod_is_indicated = true
			return
		end
	end
end
 
-- Called when the str pot buff is removed
local function hudmod_notify_strength_pot_remove(unit, buff, params)
	if buff._hudmod_is_indicated and strengthpot_info.start_time == params.start_time then
		strengthpot_info.end_time = -math.huge
	end
end
 
local function hudmod_notify_speed_pot_movement_buff_applied(unit, buff, params)
	if user_setting(MOD_SETTINGS.POTION_TIMER_INDICATOR.save) and unit == Managers.player:local_player().player_unit then
		local buff_extn = ScriptUnit.has_extension(unit, "buff_system")
		if buff_extn and buff.parent_id then
			speedpot_info.start_time = params.t
			speedpot_info.end_time = params.end_time
			buff._hudmod_is_indicated = true
		end
	end
end
 
local function hudmod_notify_speed_pot_movement_buff_removed(unit, buff, params)
	if buff._hudmod_is_indicated and speedpot_info.start_time == params.start_time then
		speedpot_info.end_time = -math.huge
	end
end
 
-- Performs initial setup for the speed-up trait proc indicator
local function setup_speedup_indicator()
	-- Find icons for speedup traits.
	for _, buff_template in pairs(BuffTemplates) do
		for _, buff in ipairs(buff_template.buffs) do
			if buff.proc == "attack_speed_from_proc" then
				assert(buff.stat_buff and buff_template.icon)
				speedup_icons[buff.stat_buff] = buff_template.icon
			end
		end
	end
 
	-- Set notification functions for trait proc. Currently we can just set our own
	-- because there are no functions set for this already. If they are added in the
	-- future we can change to hooking them instead.
	local attack_speed_buff = BuffTemplates.attack_speed_from_proc.buffs[1]
	local infinite_ammo_buff = BuffTemplates.infinite_ammo_from_proc.buffs[1]
	assert((not attack_speed_buff.apply_buff_func) or attack_speed_buff.apply_buff_func == "hudmod_notify_speedup_proc")
	assert((not attack_speed_buff.remove_buff_func) or attack_speed_buff.remove_buff_func == "hudmod_notify_speedup_remove")
	assert((not infinite_ammo_buff.apply_buff_func) or infinite_ammo_buff.apply_buff_func == "hudmod_notify_infinite_ammo_proc")
	assert((not infinite_ammo_buff.remove_buff_func) or infinite_ammo_buff.remove_buff_func == "hudmod_notify_infinite_ammo_remove")
	assert((not infinite_ammo_buff.reapply_buff_func) or infinite_ammo_buff.reapply_buff_func == "hudmod_notify_infinite_ammo_proc")
 
	attack_speed_buff.apply_buff_func = "hudmod_notify_speedup_proc"
	attack_speed_buff.remove_buff_func = "hudmod_notify_speedup_remove"
	infinite_ammo_buff.apply_buff_func = "hudmod_notify_infinite_ammo_proc"
	infinite_ammo_buff.remove_buff_func = "hudmod_notify_infinite_ammo_remove"
	infinite_ammo_buff.reapply_buff_func = "hudmod_notify_infinite_ammo_proc"
	BuffFunctionTemplates.functions.hudmod_notify_speedup_proc = notify_speedup_proc
	BuffFunctionTemplates.functions.hudmod_notify_speedup_remove = notify_speedup_remove
	BuffFunctionTemplates.functions.hudmod_notify_infinite_ammo_proc = notify_infinite_ammo_proc
	BuffFunctionTemplates.functions.hudmod_notify_infinite_ammo_remove = notify_infinite_ammo_remove
 
	--- speed pot
	for _, v in ipairs({"speed_boost_potion_weak", "speed_boost_potion_medium", "speed_boost_potion"}) do
		local speed_buff = BuffTemplates[v].buffs[2]
 
		assert((not speed_buff.apply_buff_func) or speed_buff.apply_buff_func == "hudmod_notify_speed_pot_movement_buff_applied")
		assert((not speed_buff.remove_buff_func) or speed_buff.remove_buff_func == "hudmod_notify_speed_pot_movement_buff_removed")
 
		speed_buff.apply_buff_func = "hudmod_notify_speed_pot_movement_buff_applied"
		speed_buff.remove_buff_func = "hudmod_notify_speed_pot_movement_buff_removed"
	end
	BuffFunctionTemplates.functions.hudmod_notify_speed_pot_movement_buff_applied = hudmod_notify_speed_pot_movement_buff_applied
	BuffFunctionTemplates.functions.hudmod_notify_speed_pot_movement_buff_removed = hudmod_notify_speed_pot_movement_buff_removed
 
	--- str pot
	for _, v in ipairs({"damage_boost_potion_weak", "damage_boost_potion_medium", "damage_boost_potion"}) do
		local str_buff = BuffTemplates[v].buffs[1]
 
		assert((not str_buff.apply_buff_func) or str_buff.apply_buff_func == "hudmod_notify_strength_pot_proc")
		assert((not str_buff.remove_buff_func) or str_buff.remove_buff_func == "hudmod_notify_strength_pot_remove")
 
		str_buff.apply_buff_func = "hudmod_notify_strength_pot_proc"
		str_buff.remove_buff_func = "hudmod_notify_strength_pot_remove"
	end
 
	BuffFunctionTemplates.functions.hudmod_notify_strength_pot_proc = hudmod_notify_strength_pot_proc
	BuffFunctionTemplates.functions.hudmod_notify_strength_pot_remove = hudmod_notify_strength_pot_remove
end
 
UIRenderer.draw_progress_convex_polygon = function(self, position, vertices, radius, color, progress)
	progress = math.clamp(progress, 0, 1)
 
	local gui = self.gui
	local Gui_triangle = Gui.triangle
	color = Color(unpack(color))
	radius = UIScaleScalarToResolution(radius)
 
	local layer = position[3]
	local p1 = UIScaleVectorToResolution(position)
	local x = p1.x
	local y = p1.y
	p1.z = y
	p1.y = 0
 
	local p2 = Vector3(x + vertices[1]*radius, 0, y + vertices[2]*radius)
 
	local side_count = (#vertices) / 2
	local progress_per_side = 1 / side_count
	local i = 2
 
	-- Draw completely filled sides.
	while progress > progress_per_side do
		local p3 = Vector3(x + vertices[i*2 - 1]*radius, 0, y + vertices[i*2]*radius)
		Gui_triangle(gui, p1, p2, p3, layer, color)
		p2 = p3
		i = i + 1
		progress = progress - progress_per_side
	end
 
	-- Draw the remaining side which may be only partially filled.
	if i > side_count then
		i = 1
	end
	local p3 = Vector3(x + vertices[i*2 - 1]*radius, 0, y + vertices[i*2]*radius)
	p3 = Vector3.lerp(p2, p3, progress * side_count)
	Gui_triangle(gui, p1, p2, p3, layer, color)
end
 
UIPasses.progress_convex_polygon = {
	init = function (pass_definition)
		return nil
	end,
	draw = function (ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt)
		return UIRenderer.draw_progress_convex_polygon(ui_renderer, {position.x, position.y, position.z}, ui_content.vertices, ui_content.radius, ui_style.color, ui_content.progress_value)
	end
}
 
UIPasses.convex_polygon = {
	init = function (pass_definition)
		return nil
	end,
	draw = function (ui_renderer, pass_data, ui_scenegraph, pass_definition, ui_style, ui_content, position, size, input_service, dt)
		return UIRenderer.draw_progress_convex_polygon(ui_renderer, {position.x, position.y, position.z}, ui_content.vertices, ui_content.radius, ui_style.color, 1)
	end
}
 
-- ####################################################################################################################
-- ##### Hooks #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "UnitFrameUI._create_ui_elements", function(orig_func, self, frame_index)
	orig_func(self, frame_index)
	self._hudmod_is_own_player = not frame_index
 
	strengthpot_info.end_time = -math.huge
	speedpot_info.end_time = -math.huge
	speedup_info.end_time = -math.huge
	speedup_info.secondary_end_time = -math.huge
end)
 
Mods.hook.set(mod_name, "UnitFrameUI.draw", function(orig_func, self, dt)
	local data = self.data
	local t = Managers.time:time("game")
 
	if self._is_visible and self._hudmod_is_own_player then
		local ui_renderer = self.ui_renderer
		local ui_scenegraph = get_scenegraph_definition(self)
 
 		UIRenderer.begin_pass(ui_renderer, ui_scenegraph, self.input_manager:get_service("ingame_menu"), dt)
 
 		local function update_widget(widget_name, info, widget_definition)
			-- See note at end of function
			local later_end_time = (info.secondary_end_time and math.max(info.secondary_end_time, info.end_time)) or info.end_time
			if t >= later_end_time then
				return
			end
 
			local widget = self[widget_name]
			if not widget then
				widget = UIWidget.init(widget_definition)
				self[widget_name] = widget
			end
 
			if info.icon then
				if widget.content.speedup_icon_bg then widget.content.speedup_icon_bg = info.icon end
				if widget.content.speedup_icon_fg then widget.content.speedup_icon_fg.texture_id = info.icon end
			end
			local duration = info.duration or (later_end_time - info.start_time)
			widget.content.progress_content.progress_value = (info.end_time - t) / duration
			if info.secondary_end_time then
				widget.content.secondary_progress_content.progress_value = (info.secondary_end_time - t) / duration
			end
			UIRenderer.draw_widget(ui_renderer, widget)
		end
 
		if self._hudmod_is_own_player then
			update_widget("_uitimers_speedup_widget", speedup_info, speedup_indicator_widget)
			update_widget("_uitimers_speed_pot_widget", speedpot_info, speed_potion_indicator_widget)
			update_widget("_uitimers_strength_pot_widget", strengthpot_info, strength_potion_indicator_widget)
		end
 
		UIRenderer.end_pass(self.ui_renderer)
	end
 
	return orig_func(self, dt)
end)
-- Note: for speedup proc indicator we can't assume that secondary_end_time < end_time
-- because the infinite ammo can proc again after it expires the first time while the speedup
-- buff is still active, even though the speedup buff itself is not refreshed.  I suspect
-- this is unintended, but until it's fixed we should just show what we see.
 
-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
local function init()
    HUDTimers.create_options()
    setup_speedup_indicator()
end
 
local status, err = pcall(init)
if err ~= nil then
    EchoConsole(err)
end