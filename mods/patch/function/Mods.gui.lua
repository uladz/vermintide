local mod_name = "Mods.gui"
--[[
	author: grasmann
	
	Mods.gui
		- Provides a screen gui and functionality to draw to it
--]]

Mods.gui = {
	gui = nil,
	default_world = "top_ingame_view",
	default_font = "hell_shark",
	default_font_size = 22,
	default_font_material = "materials/fonts/gw_body_32",
}
local me = Mods.gui

-- ####################################################################################################################
-- ##### Init #########################################################################################################
-- ####################################################################################################################
--[[
	Init draw
--]]
local init_error = false
Mods.gui.init = function()	
	if not pcall(me.create_screen_ui) then
		init_error = true
		me.create_screen_ui()
		init_error = false
	end
end
--[[
	Create screen gui
--]]
Mods.gui.create_screen_ui = function()
	local world = Managers.world:world(Mods.gui.default_world)
	if (Managers.state.game_mode == nil or Managers.state.game_mode._game_mode_key == "inn") and not init_error then
		me.gui = World.create_screen_gui(world, "immediate",
			"material", "materials/fonts/gw_fonts",
			--"material", "materials/ui/ui_1080p_ingame",
			"material", "materials/ui/ui_1080p_ingame_inn",
			"material", "materials/ui/ui_1080p_ingame_common")
			-- "material", "materials/ui/ui_1080p_popup"
	else
		me.gui = World.create_screen_gui(world, "immediate",
			"material", "materials/fonts/gw_fonts",
			--"material", "materials/ui/ui_1080p_ingame",
			--"material", "materials/ui/ui_1080p_ingame_inn",
			"material", "materials/ui/ui_1080p_ingame_common")
			-- "material", "materials/ui/ui_1080p_popup"	
	end
end

-- ####################################################################################################################
-- ##### Overloaded draw functions ####################################################################################
-- ####################################################################################################################
--[[
	Draw rect with vectors
--]]
Mods.gui.rect_vectors = function(position, size, color)
	Gui.rect(me.gui, position, size, color)
end
--[[
	Draw text with vectors
--]]
Mods.gui.text_vectors = function(text, position, font_size, color, font)
	local font_type = font or "hell_shark"
	local font_by_resolution = UIFontByResolution({
		dynamic_font = true,
		font_type = font_type,
		font_size = font_size
	})
	local font, result_size, material = unpack(font_by_resolution)
	Gui.text(me.gui, text, font, font_size, material, position, color)
end
--[[
	Draw bitmap with vectors
--]]
Mods.gui.bitmap_uv = function(atlas, uv00, uv11, position, size, color)
	local atlas = atlas or "gui_hud_atlas"
	local uv00 = uv00 or Vector2(0.222656, 0.584961)
	local uv11 = uv11 or Vector2(0.25293, 0.615234)
	local position = position or Vector3(1, 1, 1)
	local size = size or Vector2(62, 62)
	local color = color or Color(255, 255, 255, 255)
	return Gui.bitmap_uv(me.gui, atlas, uv00, uv11, position, size, color)
end


-- ####################################################################################################################
-- ##### Draw functions ###############################################################################################
-- ####################################################################################################################
--[[
	Draw rect
	Parameters:
		1) int:X, int:Y, int:Z, int:Width, int:Height, Color:color
		2) vector3:Position, vector2:size, Color:color
--]]
Mods.gui.rect = function(arg1, arg2, arg3, arg4, arg5, arg6)
	local color = Color(255, 255, 255, 255)
	if type(arg1) == "number" then
		me.rect_vectors(Vector3(arg1, arg2, arg3 or 1), Vector2(arg4, arg5), arg6 or color)
	else
		me.rect_vectors(arg1, arg2, arg3 or color)
	end
end
--[[
	Draw text
	Parameters:
		1) string:Text, int:X, int:Y, int:Z, int:font_size, Color:color, string:font
		2) string:Text, vector3:position, int:font_size, Color:color, string:font
--]]
Mods.gui.text = function(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	local color = Color(255, 255, 255, 255)
	local font_size = me.default_font_size
	local font = me.default_font
	if type(arg2) == "number" then
		me.text_vectors(arg1, Vector3(arg2, arg3, arg4 or 1), arg5 or font_size, arg6 or color, arg7 or font)
	else
		me.text_vectors(arg1, arg2, arg3 or font_size, arg4 or color, arg5 or font)
	end
end
--[[
	Create lines from string with \n
--]]
Mods.gui.to_lines = function(text, font_size, font_material, colors)
	local get_color = function(index)
		if #colors >= index then
			if colors[index] then
				return colors[index]
			end
		else
			return colors[#colors]
		end
		return {255, 255, 255, 255}
	end
	local _lines = {}
	local width = 0
	local height = 0
	font_size = font_size or me.default_font_size
	local index = 1
	font_material = font_material or me.default_font_material
	for line in string.gmatch(text.."\n", "([^\n]*)\n") do
		local w = Mods.gui.text_width(line, font_material, font_size)
		if line == "" then line = "#" end
		if w > width then width = w end
		--local h = Mods.gui.text_height(line, font_material, font_size)
		height = height + font_size --h
		_lines[#_lines+1] = {
			text = line,
			width = w,
			height = font_size, --h,
			color = get_color(index),
		}
		index = index + 1
	end
	if #_lines == 0 and #text > 0 then
		_lines[#_lines+1] = text
	end
	local result = {
		size = {width, height},
		["lines"] = _lines,
	}
	return result
end
--[[
	Draw tooltip
	Parameters:
		1) string:Text [, table:colors, int:font_size, int:line_padding, table:offset, table:padding, string:font_material]
--]]
Mods.gui.tooltip = function(str, colors, font_size, line_padding, offset, padding, font_material, size)
	safe_pcall(function()
		-- Create default colors if nil
		colors = colors or 
			{Colors.get_color_table_with_alpha("cheeseburger", 255),
			Colors.get_color_table_with_alpha("white", 255),}
		-- Get mouse position
		local cursor_axis_id = stingray.Mouse.axis_id("cursor")
		local mouse = stingray.Mouse.axis(cursor_axis_id)
		-- UI
		local scale = UIResolutionScale()
		local screen_w, screen_h = UIResolution()
		-- Font
		font_size = font_size or screen_w / 100
		font_material = font_material or me.default_font_material --"materials/fonts/gw_body_32"
		-- Offset / Padding
		offset = offset or {20*scale, -20*scale}
		padding = padding or {5*scale, 5*scale, 5*scale, 5*scale}
		line_padding = line_padding or 0*scale
		-- Transform string
		local text = Mods.gui.to_lines(str, font_size, font_material, colors)
		-- Transform simple text size
		if #text.lines > 0 then
			text.size[2] = text.size[2] + (#text.lines-1 * line_padding) + padding[4] + padding[1]
			text.size[1] = text.size[1] + padding[1] + padding[3]
		end
		-- Render background
		local x = mouse[1] + offset[1]
		local y = mouse[2] + offset[2]
		size = size or Vector2(text.size[1], text.size[2])
		Mods.gui.rect(Vector3(x, y, 999), size, Color(200, 0, 0, 0))
		-- Render lines
		--EchoConsole("rofl")
		local text_x = x + padding[1]
		local text_y = y + text.size[2] - padding[2] - font_size
		--local index = 1
		local icon_size = Vector2(50*scale, 50*scale)
		local icon_x = text_x
		local icon_y = text_y - icon_size[2]
		for _, line in pairs(text.lines) do
			if line.text ~= "#" then
				local color = Color(line.color[1], line.color[2], line.color[3], line.color[4])
				Mods.gui.text(line.text, Vector3(text_x, text_y, 999), font_size, color)
			end
			text_y = text_y - line.height - line_padding
		end
	end)
end
--[[
	Draw mission icon
	Parameters:
		1) vector3:position, string:text, vector2:text_offset, color:color, [vector2:size, int:font_size, string:font]
		
		text_offset:
		By default the text will be placed to the right of the icon up half its size
		The offset if set will be calculated from the middle of the icon
--]]
Mods.gui.side_mission_icon = function(position, text, text_offset, color, size, font_size, font, text_color)
	local atlas = "gui_hud_atlas"
	local uv00 = Vector2(0.222656, 0.584961)
	local uv11 = Vector2(0.25293, 0.615234)
	local position = position or Vector3(1, 1, 1)
	local size = size or Vector2(62, 62)
	local color = color or Color(255, 255, 255, 255)
	local id = me.bitmap_uv(atlas, uv00, uv11, position, size, color)
	if text ~= nil then
		if text_offset ~= nil then
			position = position + Vector3(text_offset[1], text_offset[2], 0)
		else
			position = position + Vector3(size[1], size[2] / 2, 0)
		end
		local font_size = font_size or me.default_font_size
		local font = me.default_font
		local text_color = text_color or color
		me.text_vectors(text, position, font_size, text_color, font)
	end
	return id, size, color
end

Mods.gui.tome_icon = function(position, color, size)
	local icon_texture = "consumables_book_lit"
	local icon_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(icon_texture)
	
	local atlas = "gui_generic_icons_atlas"
	local size = size or Vector2(icon_settings.size[1], icon_settings.size[2])
	local color = color or Color(255, 255, 255, 255)
	local uv00 = Vector2(icon_settings.uv00[1], icon_settings.uv00[2])
	local uv11 = Vector2(icon_settings.uv11[1], icon_settings.uv11[2])
	local position = position or Vector3(1, 1, 1)
	return me.bitmap_uv(atlas, uv00, uv11, position, size, color)
end

Mods.gui.grim_icon = function(position, color, size)
	local icon_texture = "consumables_grimoire_lit"
	local icon_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(icon_texture)

	local atlas = "gui_generic_icons_atlas"
	local size = size or Vector2(icon_settings.size[1], icon_settings.size[2])
	local color = color or Color(255, 255, 255, 255)
	local uv00 = Vector2(icon_settings.uv00[1], icon_settings.uv00[2])
	local uv11 = Vector2(icon_settings.uv11[1], icon_settings.uv11[2])
	local position = position or Vector3(1, 1, 1)
	return me.bitmap_uv(atlas, uv00, uv11, position, size, color)
end

Mods.gui.draw_icon = function(icon_texture, position, color, size, atlas, uv00, uv11)
	local icon_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(icon_texture)

	local atlas = atlas or "gui_generic_icons_atlas"
	local size = size or Vector2(icon_settings.size[1], icon_settings.size[2])
	local color = color or Color(255, 255, 255, 255)
	local uv00 = uv00 or Vector2(icon_settings.uv00[1], icon_settings.uv00[2])
	local uv11 = uv11 or Vector2(icon_settings.uv11[1], icon_settings.uv11[2])
	local position = position or Vector3(1, 1, 1)
	return me.bitmap_uv(atlas, uv00, uv11, position, size, color)
end

-- ####################################################################################################################
-- ##### Get information ##############################################################################################
-- ####################################################################################################################
--[[
	Get width of a text with the given font and font size
--]]
Mods.gui.text_width = function(text, font, font_size)
	local text_extent_min, text_extent_max = Gui.text_extents(me.gui, text, font or me.default_font, font_size or me.default_font_size)
	local text_width = text_extent_max[1] - text_extent_min[1]
	return text_width
end
--[[
	Get height of a text with the given font and font size
--]]
Mods.gui.text_height = function(text, font, font_size)
	local text_extent_min, text_extent_max = Gui.text_extents(me.gui, text, font or me.default_font, font_size or me.default_font_size)
	local text_height = text_extent_max[2] - text_extent_min[2]
	return text_height
end

-- Initialize
me.init()