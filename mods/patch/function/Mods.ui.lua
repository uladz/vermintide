local mod_name = "Mods.ui"

-- ################################################################################################################
-- ##### Input keymap #############################################################################################
-- ################################################################################################################
ModUIKeyMap = {
	win32 = {
		["backspace"] = {"keyboard", "backspace", "held"}, ["enter"] = {"keyboard", "enter", "pressed"}, ["esc"] = {"keyboard", "esc", "pressed"}, ["numpad enter"] = {"keyboard", "numpad enter", "pressed"},
	},
}
ModUIKeyMap.xb1 = ModUIKeyMap.win32
ModUISpecialKeys = {"space", "<", ">"}

-- ################################################################################################################
-- ##### Color helper #############################################################################################
-- ################################################################################################################
local ColorHelper = {
	--[[
		Transform color values to table
	]]--
	box = function(a, r, g, b)
		return {a, r, g, b}
	end,
	--[[
		Transform color table to color
	]]--
	unbox = function(box)
		return Color(box[1], box[2], box[3], box[4])
	end,
}

local function draw_image(texture_id, uvs, position, position_z, size, color)
	local pos_vector = Vector3(position[1], position[2], position_z)
	local size_vector = Vector2(size[1], size[2])
	if uvs then
		UIRenderer.script_draw_bitmap_uv(Mods.gui.gui, nil, texture_id, uvs, pos_vector, size_vector, color)
	else
		UIRenderer.script_draw_bitmap(Mods.gui.gui, nil, texture_id, pos_vector, size_vector, color)
	end
end

-- ################################################################################################################
-- ##### Main Object ##############################################################################################
-- ################################################################################################################
Mods.ui = {

	theme = "default",

	-- ################################################################################################################
	-- ##### Create containers ########################################################################################
	-- ################################################################################################################
	--[[
		Create window
	]]--
	create_window = function(name, position, size, controls, on_hover_enter)
		-- Create window
		local window = table.clone(Mods.ui.controls.window)
		window:set("name", name or "name")
		window:set("position", position or {0, 0})
		window:set("size", size or {0, 0})
		window:set("controls", controls or {})
		window:set("on_hover_enter", on_hover_enter)

		-- Add window to list
		Mods.ui.windows:add_window(window)

		return window
	end,

	-- ################################################################################################################
	-- ##### Cycle ####################################################################################################
	-- ################################################################################################################
	--[[
		Update
	]]--
	update = function()
		Mods.ui.input:check()

		-- Click
		local position = Mods.ui.mouse:cursor()
		if stingray.Mouse.pressed(stingray.Mouse.button_id("left")) then
			Mods.ui.mouse:click(position, Mods.ui.windows.list)
		elseif stingray.Mouse.released(stingray.Mouse.button_id("left")) then
			Mods.ui.mouse:release(position, Mods.ui.windows.list)
		end

		-- Hover
		Mods.ui.mouse:hover(position, Mods.ui.windows.list)

		-- Update windows
		Mods.ui.windows:update()

	end,

	-- ################################################################################################################
	-- ##### Common functions #########################################################################################
	-- ################################################################################################################
	--[[
		Transform position and size to bounds
	]]--
	to_bounds = function(position, size)
		return {position[1], position[1] + size[1], position[2], position[2] + size[2]}
	end,
	--[[
		Check if position is in bounds
	]]--
	point_in_bounds = function(position, bounds)
		if position[1] >= bounds[1] and position[1] <= bounds[2] and position[2] >= bounds[3] and position[2] <= bounds[4] then
			return true, {position[1] - bounds[1], position[2] - bounds[3]}
		end
		return false, {0, 0}
	end,

	-- ################################################################################################################
	-- ##### Window system ############################################################################################
	-- ################################################################################################################
	windows = {
		list = {},
		--[[
			Add window to list
		]]--
		add_window = function(self, window)
			self:inc_z_orders(#self.list)
			window.z_order = 1
			self.list[#self.list+1] = window
		end,
		--[[
			Shift z orders of windows
		]]--
		inc_z_orders = function(self, changed_z)
			for z=changed_z, 1, -1 do
				for _, window in pairs(self.list) do
					if window.z_order == z then
						window.z_order = window.z_order + 1
					end
				end
			end
		end,
		--[[
			Shift z orders of windows
		]]--
		dec_z_orders = function(self, changed_z)
			--for z=changed_z, 1, -1 do
			for z=changed_z+1, #self.list do
				for _, window in pairs(self.list) do
					if window.z_order == z then
						window.z_order = window.z_order - 1
					end
				end
			end
		end,
		--[[
			Shift z orders of windows
		]]--
		unfocus = function(self)
			for _, window in pairs(self.list) do
				if window.z_order == 1 then
					window:unfocus()
				end
			end
		end,
		--[[
			Update windows
		]]--
		update = function(self)
			if #self.list > 0 then
				for z=#self.list, 1, -1 do
					for _, window in pairs(self.list) do
						if window.visible then
							if window.z_order == z then
								window:update()
								window:render()
							end
						end
					end
				end
			end
		end,
	},

	-- ################################################################################################################
	-- ##### Mouse system #############################################################################################
	-- ################################################################################################################
	mouse = {
		--[[
			Process click
		]]--
		click = function(self, position, windows)
			for z=1, #windows do
				for _, window in pairs(windows) do
					if window.z_order == z then
						if Mods.ui.point_in_bounds(position, window:extended_bounds()) then
							window:click(position)
						else
							window:unfocus()
						end
					end
				end
			end
		end,
		--[[
			Process release
		]]--
		release = function(self, position, windows)
			for z=1, #windows do
				for _, window in pairs(windows) do
					if window.z_order == z then
						if Mods.ui.point_in_bounds(position, window:extended_bounds()) then
							window:release(position)
						else
							window:unfocus()
						end
					end
				end
			end
		end,
		--[[
			Process hover
		]]--
		hover = function(self, position, windows)
			self:un_hover_all(windows)
			for z=1, #windows do
				for _, window in pairs(windows) do
					if window.z_order == z then
						local hovered, cursor = Mods.ui.point_in_bounds(position, window:extended_bounds())
						if hovered then
							window:hover(cursor)
							return
						end
					end
				end
			end
		end,
		--[[
			Unhover all
		]]--
		un_hover_all = function(self, windows)
			for _, window in pairs(windows) do
				if window.hovered then
					window:hover_exit()
				end
			end
		end,
		--[[
			Get mouse position
		]]--
		cursor = function(self)
			local cursor_axis_id = stingray.Mouse.axis_id("cursor")	-- retrieve the axis ID
			local value = stingray.Mouse.axis(cursor_axis_id)		-- use the ID to access to value
			return {value[1], value[2]}
		end,
	},

	-- ################################################################################################################
	-- ##### Timer system #############################################################################################
	-- ################################################################################################################
	timers = {
		-- Timer list
		items = {},
		-- Timer template
		template = {
			name = nil,
			rate = 100,
			enabled = false,
			timestamp = nil,
			params = nil,
			reset_pending = false,

			-- ##### Methods ##############################################################################
			--[[
				Enable timer
			]]--
			enable = function(self)
				self.enabled = true
			end,
			--[[
				Disable timer
			]]--
			disable = function(self)
				self.enabled = false
			end,

			-- ##### Cycle ################################################################################
			--[[
				Process tick
			]]--
			tick = function(self)
				--if self.on_tick and type(self.on_tick) == "function" then
				self:on_tick(self.params)
				--end
			end,
			--[[
				Update
			]]--
			update = function(self, t)
				if self.timestamp and self.enabled and not self.reset_pending then
					if t - self.timestamp >= self.rate / 1000 then
						self:tick()
						self.timestamp = t
					end
				else
					self.timestamp = t
					self.reset_pending = false
				end
			end,
			reset = function(self)
				self.enabled = true
				self.reset_pending = true
			end,

			-- ##### Events ################################################################################
			--[[
				On click event
			]]--
			on_tick = function(self, ...)
			end,
		},
		--[[
			Create timer
		]]--
		create_timer = function(self, name, rate, enabled, on_tick, ...) --, wait)
			if not table.has_item(self.items, name) then
				local new_timer = table.clone(self.template)
				new_timer.name = name or "timer_" .. tostring(#self.items+1)
				new_timer.rate = rate or new_timer.rate
				new_timer.enabled = enabled or new_timer.enabled
				new_timer.on_tick = on_tick or new_timer.on_tick
				new_timer.params = ...
				--new_timer.wait = wait or new_timer.wait
				self.items[name] = new_timer
				return new_timer
			end
			return nil
		end,
		--[[
			Update timers
		]]--
		update = function(self, t)
			for name, timer in pairs(self.items) do
				timer:update(t)
			end
		end,
	},

	-- ################################################################################################################
	-- ##### Input system #############################################################################################
	-- ################################################################################################################
	input = {
		blocked_services = nil,
		--[[
			Check and create input system
		]]--
		check = function(self)
			if not Managers.input:get_input_service("ModsUI") then
				Managers.input:create_input_service("ModsUI", "ModUIKeyMap")
				Managers.input:map_device_to_service("ModsUI", "keyboard")
				Managers.input:map_device_to_service("ModsUI", "mouse")
				Managers.input:map_device_to_service("ModsUI", "gamepad")
			end
		end,
		--[[
			Get list of unblocked input services and block them
		]]--
		block = function(self, dont_block_mouse)
			if not self.blocked_services then
				self.blocked_services = {}
				Managers.input:get_unblocked_services("keyboard", 1, self.blocked_services)
				for _, s in pairs(self.blocked_services) do
					Managers.input:device_block_service("keyboard", 1, s)
					if not dont_block_mouse then Managers.input:device_block_service("mouse", 1, s) end
					Managers.input:device_block_service("gamepad", 1, s)
				end
			end
		end,
		--[[
			Unblock previously blocked services
		]]--
		unblock = function(self)
			if self.blocked_services then
				for _, s in pairs(self.blocked_services) do
					Managers.input:device_unblock_service("keyboard", 1, s)
					Managers.input:device_unblock_service("mouse", 1, s)
					Managers.input:device_unblock_service("gamepad", 1, s)
				end
				self.blocked_services = nil
			end
		end,
	},

	-- ################################################################################################################
	-- ##### Font system ##############################################################################################
	-- ################################################################################################################
	fonts = {
		fonts = {},
		--[[
			Font template
		]]--
		template = {
			font = "hell_shark",
			material = "materials/fonts/gw_body_32",
			size = 22,
			font_size = function(self)
				if not self.dynamic_size then
					return self.size
				else
					local screen_w, screen_h = UIResolution()
					local size = screen_w / 100
					return size
				end
			end,
			dynamic_size = false,
		},
		--[[
			Create font
		]]--
		create = function(self, name, font, size, material, dynamic_size)
			if not table.has_item(self.fonts, name) then
				local new_font = table.clone(self.template)
				new_font.font = font or new_font.font
				new_font.material = material or new_font.material
				new_font.size = size or new_font.size
				new_font.dynamic_size = dynamic_size or new_font.dynamic_size
				self.fonts[name] = new_font
			end
		end,
		--[[
			Get font by name
		]]--
		get = function(self, name)
			for k, font in pairs(self.fonts) do
				if k == name then
					return font
				end
			end
			return Mods.ui.fonts.default or nil
		end,
	},

	-- ################################################################################################################
	-- ##### Anchor system ############################################################################################
	-- ################################################################################################################
	anchor = {
		styles = {
			"bottom_left",
			"center_left",
			"top_left",
			"middle_top",
			"top_right",
			"center_right",
			"bottom_right",
			"middle_bottom",
			"fill",
		},
		bottom_left = {
			position = function(window, control)
				local x = window.position[1] + control.offset[1]
				local y = window.position[2] + control.offset[2]
				return {x, y}, control.size
			end,
		},
		center_left = {
			position = function(window, control)
				local x = window.position[1] + control.offset[1]
				local y = window.position[2] + window.size[2]/2 - control.size[2]/2
				return {x, y}, control.size
			end,
		},
		top_left = {
			position = function(window, control)
				local x = window.position[1] + control.offset[1]
				local y = window.position[2] + window.size[2] - control.offset[2] - control.size[2]
				return {x, y}, control.size
			end,
		},
		middle_top = {
			position = function(window, control)
				local x = window.position[1] + window.size[1]/2 - control.size[1]/2
				local y = window.position[2] + window.size[2] - control.offset[2] - control.size[2]
				return {x, y}, control.size
			end,
		},
		top_right = {
			position = function(window, control)
				local x = window.position[1] + window.size[1] - control.offset[1] - control.size[1]
				local y = window.position[2] + window.size[2] - control.offset[2] - control.size[2]
				return {x, y}, control.size
			end,
		},
		center_right = {
			position = function(window, control)
				local x = window.position[1] + window.size[1] - control.offset[1] - control.size[1]
				local y = window.position[2] + window.size[2]/2 - control.size[2]/2
				return {x, y}, control.size
			end,
		},
		bottom_right = {
			position = function(window, control)
				local x = window.position[1] + window.size[1] - control.offset[1] - control.size[1]
				local y = window.position[2] + control.offset[2]
				return {x, y}, control.size
			end,
		},
		middle_bottom = {
			position = function(window, control)
				local x = window.position[1] + window.size[1]/2 - control.size[1]/2
				local y = window.position[2] + control.offset[2]
				return {x, y}, control.size
			end,
		},
		fill = {
			position = function(window, control)
				return {window.position[1], window.position[2]}, {window.size[1], window.size[2]}
			end,
		},
	},

	-- ################################################################################################################
	-- ##### Textalignment system #####################################################################################
	-- ################################################################################################################
	text_alignment = {
		bottom_left = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[3] - bounds[4]
				local left = bounds[1]
				local bottom = bounds[3]
				local fix = 2*scale
				return {left + fix, bottom + fix}
			end,
		},
		bottom_center = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[3] - bounds[4]
				local left = bounds[1]
				local bottom = bounds[3]
				local fix = 2*scale
				return {left + frame_width/2 - text_width/2, bottom + fix}
			end,
		},
		bottom_right = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[3] - bounds[4]
				local right = bounds[2]
				local bottom = bounds[3]
				local fix = 2*scale
				return {right - text_width, bottom + fix}
			end,
		},
		middle_left = {
			position = function(text, font, bounds, padding)
				local scale = UIResolutionScale()
				local text_height = font:font_size()
				local frame_height = bounds[4] - bounds[3]
				local left = bounds[1]
				local bottom = bounds[3]
				--local border = 5*scale
				local fix = 2*scale
				return {left + fix, bottom + fix + (frame_height/2) - (text_height/2)}
			end,
		},
		middle_center = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[4] - bounds[3]
				local left = bounds[1]
				local bottom = bounds[3]
				local fix = 2*scale
				return {left + fix + frame_width/2 - text_width/2, bottom + fix + (frame_height/2) - (text_height/2)}
			end,
		},
		middle_right = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[4] - bounds[3]
				local right = bounds[2]
				local bottom = bounds[3]
				local fix = 2*scale
				return {right - text_width - fix, bottom + fix + (frame_height/2) - (text_height/2)}
			end,
		},
		top_left = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[4] - bounds[3]
				local left = bounds[1]
				local top = bounds[4]
				local fix = 2*scale
				return {left + fix, top - fix - text_height/2}
			end,
		},
		top_center = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[4] - bounds[3]
				local left = bounds[1]
				local top = bounds[4]
				local fix = 2*scale
				return {left + frame_width/2 - text_width/2, top - fix - text_height/2}
			end,
		},
		top_right = {
			position = function(text, font, bounds)
				local scale = UIResolutionScale()
				local text_width = Mods.gui.text_width(text, font.material, font:font_size())
				local text_height = font:font_size() --Mods.gui.text_height(text, font.material, font:font_size())
				local frame_width = bounds[2] - bounds[1]
				local frame_height = bounds[4] - bounds[3]
				local right = bounds[2]
				local bottom = bounds[3]
				local fix = 2*scale
				return {right - fix - text_width, bottom - fix + frame_height - (text_height/2)}
			end,
		},
	},

	-- ################################################################################################################
	-- ##### Controls #################################################################################################
	-- ################################################################################################################
	controls = {

		window = {
			name = "",
			position = {0, 0},
			size = {0, 0},
			initialized = false,
			hovered = false,
			cursor = {0, 0},
			dragging = false,
			drag_offset = {0, 0},
			resizing = false,
			resize_offset = {0, 0},
			resize_origin = {0, 0},
			z_order = 0,
			controls = {},
			visible = true,
			transparent = false,

			-- ################################################################################################################
			-- ##### Init #####################################################################################################
			-- ################################################################################################################
			--[[
				Set value
			--]]
			set = function(self, attribute, value)
				self[attribute] = value
			end,
			--[[
				Refresh theme
			--]]
			refresh_theme = function(self)
				self.theme = {}
				-- Default
				local theme_element = Mods.ui.themes[Mods.ui.theme].default
				if theme_element then self:copy_theme_element(theme_element) end
				-- Specific
				local theme_element = Mods.ui.themes[Mods.ui.theme]["window"]
				if theme_element then self:copy_theme_element(theme_element) end
			end,
			--[[
				Copy theme element
			--]]
			copy_theme_element = function(self, theme_element)
				-- Go through elements
				for key, element in pairs(theme_element) do
					-- Set element
					self.theme[key] = element
				end
			end,

			-- ################################################################################################################
			-- ##### Create controls ##########################################################################################
			-- ################################################################################################################
			--[[
				Create title bar
			--]]
			create_title = function(self, name, text, height)
				-- Base control
				local control = self:create_control(name, nil, nil, "title")
				-- Set attributes
				control:set("text", text or "")
				control:set("height", height or Mods.ui.themes[Mods.ui.theme].title.height)
				-- Add control
				self:add_control(control)
				return control
			end,
			--[[
				Create button
			--]]
			create_button = function(self, name, position, size, text, on_click, anchor, param)
				-- Base control
				local control = self:create_control(name, position, size, "button", anchor)
				-- Set attributes
				control:set("text", text or "")
				control:set("on_click", on_click)
				control:set("param", param)
				-- Add control
				self:add_control(control)
				return control
			end,
			--[[
				Create resizer
			--]]
			create_resizer = function(self, name, size)
				-- Base control
				local control = self:create_control(name, nil, size, "resizer")
				-- Set attributes
				control:set("size", size or Mods.ui.themes[Mods.ui.theme].resizer.size)
				-- Add control
				self:add_control(control)
				return control
			end,
			--[[
				Create close button
			--]]
			create_close_button = function(self, name)
				local control = self:create_control(name, {5, 0}, {25, 25}, "close_button", Mods.ui.anchor.styles.top_right)
				control:set("text", "X")
				self:add_control(control)
				return control
			end,
			--[[
				Create textbox
			--]]
			create_textbox = function(self, name, position, size, text, watermark, on_text_changed, on_done_typing)
				local control = self:create_control(name, position, size, "textbox")
				control:set("text", text or "")
				control:set("watermark", watermark or "")
				control:set("on_text_changed", on_text_changed)
				control:set("on_done_typing", on_done_typing)
				self:add_control(control)
				return control
			end,
			--[[
				Create checkbox
			--]]
			create_checkbox = function(self, name, position, size, text, value, on_value_changed)
				local control = self:create_control(name, position, size, "checkbox")
				control:set("text", text or "")
				control:set("value", value or false)
				control:set("on_value_changed", on_value_changed)
				self:add_control(control)
				return control
			end,
			--[[
				Create label
			--]]
			create_label = function(self, name, position, size, text)
				local control = self:create_control(name, position, size, "label")
				control:set("text", text or "")
				self:add_control(control)
				return control
			end,
			--[[
				Create image
			--]]
			create_image = function(self, name, texture_id, position, size, color, uvs)
				-- Base control
				local control = self:create_control(name, position, size, "image")
				-- Set attributes
				control:set("texture_id", texture_id)
				control:set("color", color or { 255, 255, 255, 255 })
				control:set("uvs", uvs)
				-- Add control
				self:add_control(control)
				return control
			end,
			--[[
				Create checkbox_square
			--]]
			create_checkbox_square = function(self, name, position, text, value, on_value_changed)
				local control = self:create_control(name, position, nil, "checkbox_square")
				control:set("text", text or "")
				control:set("value", value or false)
				control:set("on_value_changed", on_value_changed)
				self:add_control(control)
				return control
			end,
			--[[
				Create control
			--]]
			create_dropdown = function(self, name, position, size, options, selected_index, on_index_changed, show_items_num)
				local control = self:create_control(name, position, size, "dropdown")
				--local control.controls = {}
				control:set("text", "")
				control:set("options", {})
				control:set("index", selected_index)
				--table.sort(options)
				safe_pcall(function()
				for text, index in pairs(options) do
					local sub_control = self:create_dropdown_item(name, index, control, text)
					EchoConsole("--")
					EchoConsole(tostring(index))
					control.options[#control.options+1] = sub_control
				end
				end)
				control:set("show_items_num", show_items_num or 2)
				control:set("on_index_changed", on_index_changed)
				self:add_control(control)
				return control
			end,
			create_dropdown_item = function(self, name, index, parent, text)
				local control = self:create_control(name.."_option_"..text, {0, 0}, {0, 0}, "dropdown_item")
				control:set("text", text or "")
				control:set("index", index)
				control:set("parent", parent)
				control:set("anchor", nil)
				control:set("z_order", 1)
				return control
			end,
			--[[
				Create control
			--]]
			create_control = function(self, name, position, size, _type, anchor)

				-- Create control
				local control = table.clone(Mods.ui.controls.control)
				control.name = name or "name"
				control.position = position or {0, 0}
				control.offset = control.position
				control.size = size or {0, 0}
				control._type = _type or "button"
				control.window = self
				-- Anchor
				control.anchor = anchor or "bottom_left"
				-- Setup functions and theme
				control:setup()

				return control
			end,
			--[[
				Add control to list
			--]]
			add_control = function(self, control)
				self:inc_z_orders(#self.controls)
				control.z_order = 1
				self.controls[#self.controls+1] = control
			end,

			-- ################################################################################################################
			-- ##### Methods ##################################################################################################
			-- ################################################################################################################
			--[[
				Initialize window
			--]]
			init = function(self)
				-- Event
				self:on_init()

				-- Theme
				self:refresh_theme()

				-- Init controls
				if #self.controls > 0 then
					for _, control in pairs(self.controls) do
						control:init()
					end
				end

				self:update()

				self.initialized = true
			end,
			--[[
				Bring window to front
			--]]
			bring_to_front = function(self)
				if not self:has_focus() then
					Mods.ui.windows:unfocus()
					Mods.ui.windows:inc_z_orders(self.z_order)
					self.z_order = 1
				end
			end,
			--[[
				Destroy window
			--]]
			destroy = function(self)
				Mods.ui.windows:dec_z_orders(self.z_order)
				table.remove(Mods.ui.windows.list, self:window_index())
			end,
			--[[
				Increase z orders
			--]]
			inc_z_orders = function(self, changed_z)
				for z=changed_z, 1, -1 do
					for _, control in pairs(self.controls) do
						if control.z_order == z then
							control.z_order = control.z_order + 1
						end
					end
				end
			end,
			--[[
				Decrease z orders
			--]]
			dec_z_orders = function(self, changed_z)
				--for z=changed_z, #self.controls do
				for z=changed_z+1, #self.controls do
					for _, control in pairs(self.controls) do
						if control.z_order == z then
							control.z_order = control.z_order - 1
						end
					end
				end
			end,
			--[[
				Focus window
			--]]
			focus = function(self)
				self:bring_to_front()
				self:on_focus()
			end,
			--[[
				Unfocus window
			--]]
			unfocus = function(self)
				for _, control in pairs(self.controls) do
					control:unfocus()
				end
				self:on_unfocus()
			end,
			--[[
				Hover window
			--]]
			hover = function(self, cursor)
				if not self.hovered then self:hover_enter() end
				self.cursor = cursor
				self:on_hover(cursor)
			end,
			--[[
				Start hover window
			--]]
			hover_enter = function(self)
				--Mods.ui.mouse:un_hover_all(Mods.ui.windows.list)
				self.hovered = true
				self:on_hover_enter()
			end,
			--[[
				End hover window
			--]]
			hover_exit = function(self)
				self.hovered = false
				self:on_hover_exit()
			end,
			--[[
				Click window
			--]]
			click = function(self, position)
				--self:focus()
				local clicked = false
				for z=1, #self.controls do
					for _, control in pairs(self.controls) do
						if control.z_order == z then
							if not Mods.ui.point_in_bounds(position, control:extended_bounds()) then
								control:unfocus()
							end
							if not clicked and Mods.ui.point_in_bounds(position, control:extended_bounds()) then
								control:click()
								clicked = true
							end
						end
					end
				end
				self:on_click(position)
			end,
			--[[
				Release click window
			--]]
			release = function(self, position)
				self:focus()
				local released = false
				for z=1, #self.controls do
					for _, control in pairs(self.controls) do
						if control.z_order == z then
							if not Mods.ui.point_in_bounds(position, control:extended_bounds()) then
								control:unfocus()
							end
							if not released and Mods.ui.point_in_bounds(position, control:extended_bounds()) then
								control:release()
								released = true
							end
						end
					end
				end
				self:on_release(position)
			end,

			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				Window is initialized
			--]]
			on_init = function(self)
			end,
			--[[
				Window gets focus
			--]]
			on_focus = function(self)
			end,
			--[[
				Window loses focus
			--]]
			on_unfocus = function(self)
			end,
			--[[
				Window is hovered
			--]]
			on_hover = function(self, cursor)
			end,
			--[[
				Window starts being hovered
			--]]
			on_hover_enter = function(self)
			end,
			--[[
				Window ends being hovered
			--]]
			on_hover_exit = function(self)
			end,
			--[[
				Window is clicked
			--]]
			on_click = function(self, position)
			end,
			--[[
				Window click released
			--]]
			on_release = function(self, position)
			end,
			--[[
				Before window is updated
			--]]
			before_update = function(self)
			end,
			--[[
				Window was updated
			--]]
			after_update = function(self)
			end,
			--[[
				Window is dragged
			--]]
			on_dragged = function(self)
			end,
			--[[
				Window is resized
			--]]
			on_resize = function(self)
			end,

			-- ################################################################################################################
			-- ##### Attributes ###############################################################################################
			-- ################################################################################################################
			--[[
				Check if window has focus
			--]]
			has_focus = function(self)
				return self.z_order == 1
			end,
			--[[
				Get window index
			--]]
			window_index = function(self)
				for i=1, #Mods.ui.windows.list do
					if Mods.ui.windows.list[i] == self then return i end
				end
				return 0
			end,
			--[[
				Window bounds
			--]]
			bounds = function(self)
				return Mods.ui.to_bounds(self.position, self.size)
			end,
			extended_bounds = function(self)
				local bounds = self:bounds()
				for _, control in pairs(self.controls) do
					local cbounds = control:extended_bounds()
					if cbounds[1] < bounds[1] then bounds[1] = cbounds[1] end
					if cbounds[2] > bounds[2] then bounds[2] = cbounds[2] end
					if cbounds[3] < bounds[3] then bounds[3] = cbounds[3] end
					if cbounds[4] > bounds[4] then bounds[4] = cbounds[4] end
				end
				return bounds
			end,
			control_bounds = function(self)
				local bounds = {}
				for _, control in pairs(self.controls) do
					local cbounds = control:extended_bounds()
					if not bounds[1] or cbounds[1] < bounds[1] then bounds[1] = cbounds[1] end
					if not bounds[2] or cbounds[2] > bounds[2] then bounds[2] = cbounds[2] end
					if not bounds[3] or cbounds[3] < bounds[3] then bounds[3] = cbounds[3] end
					if not bounds[4] or cbounds[4] > bounds[4] then bounds[4] = cbounds[4] end
				end
				return bounds
			end,
			--[[
				Z position
			--]]
			position_z = function(self)
				return 800 + (#Mods.ui.windows.list - self.z_order)
			end,
			--[[
				Get control by name
			--]]
			get_control = function(self, name)
				for _, control in pairs(self.controls) do
					if control.name == name then
						return control
					end
				end
				return nil
			end,

			-- ################################################################################################################
			-- ##### Cycle ####################################################################################################
			-- ################################################################################################################
			--[[
				Update window
			--]]
			update = function(self)
				if self.initialized then
					self:before_update()
					if self:has_focus() then
						-- Get cursor position
						local cursor = Mods.ui.mouse.cursor()
						-- Drag
						self:drag(cursor)
						-- Resize
						self:resize(cursor)
						-- Update controls
						self:update_controls()
					end
					self:after_update()
				end
			end,
			--[[
				Resize window
			--]]
			drag = function(self, cursor)
				if self.dragging then
					self.position = {cursor[1] - self.drag_offset[1], cursor[2] - self.drag_offset[2]}
					self:on_dragged()
				end
			end,
			--[[
				Resize window
			--]]
			resize = function(self, cursor)
				if self.resizing then
					local new_size = {
						cursor[1] - self.resize_origin[1] + self.resize_offset[1],
						self.resize_origin[2] - cursor[2] + self.resize_offset[2],
					}
					if new_size[1] < 100 then new_size[1] = 100 end
					if new_size[2] < 100 then new_size[2] = 100 end
					self.size = new_size
					local control_bounds = self:control_bounds()
					if self.size[1] < control_bounds[2] - control_bounds[1] then
						self.size[1] = control_bounds[2] - control_bounds[1]
					end
					if self.size[2] < control_bounds[4] - control_bounds[3] then
						self.size[2] = control_bounds[4] - control_bounds[3]
					end
					self.position = {self.position[1], self.resize_origin[2] - new_size[2]}
					self:on_resize()
				end
			end,
			--[[
				Update controls
			--]]
			update_controls = function(self)
				if #self.controls > 0 then
					local catched = false
					for z=1, #self.controls do
						for _, control in pairs(self.controls) do
							if control.z_order == z and not catched then
								catched = control:update()
							end
						end
					end
				end
			end,

			-- ################################################################################################################
			-- ##### Render ###################################################################################################
			-- ################################################################################################################
			render = function(self)
				if not self.visible then return end
				self:render_shadow()
				self:render_background()
				self:render_controls()
			end,
			--[[
				Render window
			--]]
			render_background = function(self)
				if not self.visible or self.transparent then return end
				local color = ColorHelper.unbox(self.theme.color)
				if self.hovered then
					color = ColorHelper.unbox(self.theme.color_hover)
				end
				Mods.gui.rect(self.position[1], self.position[2], self:position_z(), self.size[1], self.size[2], color)
			end,
			--[[
				Render shadow
			--]]
			render_shadow = function(self)
				if not self.visible then return end
				-- Theme
				local layers = self.theme.shadow.layers
				local border = self.theme.shadow.border
				local cv = self.theme.shadow.color
				-- Render
				for i=1, layers do
					local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
					local mod = layers-i
					Mods.gui.rect(self.position[1]+mod-border, self.position[2]-mod-border, self:position_z(),
						self.size[1]-mod*2+border*2, self.size[2]+mod*2+border*2, color)
				end
				for i=1, layers do
					local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
					local mod = layers-i
					Mods.gui.rect(self.position[1]-mod-border, self.position[2]+mod-border, self:position_z(),
						self.size[1]+mod*2+border*2, self.size[2]-mod*2+border*2, color)
				end
			end,
			--[[
				Render controls
			--]]
			render_controls = function(self)
				if not self.visible then return end
				if #self.controls > 0 then
					for z=#self.controls, 1, -1 do
						for _, control in pairs(self.controls) do
							if control.z_order == z and control.visible then
								control:render()
							end
						end
					end
				end
			end,

		},

		control = {
			name = "",
			position = {0, 0},
			size = {0, 0},
			_type = "",
			anchor = "",
			hovered = false,
			cursor = {0, 0},
			--colors = {},
			z_order = 0,
			visible = true,
			theme = {},

			-- ################################################################################################################
			-- ##### Control Methods ##########################################################################################
			-- ################################################################################################################
			--[[
				Initialize
			--]]
			init = function(self)
				-- Trigger update
				self:update()
				-- Trigger event
				self:on_init()
			end,
			--[[
				Click
			--]]
			click = function(self)
				-- Disabled
				if self.disabled then return end
				-- Click
				self.clicked = true
			end,
			--[[
				Release
			--]]
			release = function(self)
				-- Disabled
				if self.disabled then return end
				-- Clicked
				if not self.clicked then return end
				-- Release
				self.clicked = false
				-- Trigger event
				self:on_click()
			end,
			--[[
				Focus
			--]]
			focus = function(self)
				-- Disabled
				if self.disabled then return end
				-- Focus
				self.has_focus = true
			end,
			--[[
				Unfocus
			--]]
			unfocus = function(self)
				-- Unfocus
				self.hovered = false
				self.clicked = false
				self.has_focus = false
			end,
			-- ################################################################################################################
			-- ##### Init #####################################################################################################
			-- ################################################################################################################
			--[[
				Set value
			--]]
			set = function(self, attribute, value)
				self[attribute] = value
			end,
			--[[
				Refresh theme
			--]]
			refresh_theme = function(self)
				self.theme = {}
				-- Default
				local theme_element = Mods.ui.themes[Mods.ui.theme].default
				if theme_element then self:copy_theme_element(theme_element) end
				-- Specific
				local theme_element = Mods.ui.themes[Mods.ui.theme][self._type]
				if theme_element then self:copy_theme_element(theme_element) end
			end,
			--[[
				Copy theme element
			--]]
			copy_theme_element = function(self, theme_element)
				-- Go through elements
				for key, element in pairs(theme_element) do
					-- Set element
					self.theme[key] = element
				end
			end,
			--[[
				Setup control
			--]]
			setup = function(self)
				-- Copy control specific functions
				local control_element = Mods.ui.controls[self._type]
				if control_element then self:copy_control_element(control_element) end
				-- Refresh theme
				self:refresh_theme()
			end,
			--[[
				Copy control element
			--]]
			copy_control_element = function(self, control_element)
				-- Go through elements
				for key, element in pairs(control_element) do
					if type(element) == "function" then
						-- If function save callback to original function
						if self[key] then self[key.."_base"] = self[key] end
						self[key] = element
					else
						-- Set element
						self[key] = element
					end
				end
			end,
			-- ################################################################################################################
			-- ##### Cycle ####################################################################################################
			-- ################################################################################################################
			--[[
				Update
			--]]
			update = function(self)
				-- Trigger event
				self:before_update()
				-- Disabled
				if self.disabled or not self.visible then return end
				-- Mouse position
				local cursor = Mods.ui.mouse.cursor()
				-- Set control position via anchor
				if self.anchor then
					self.position, self.size = Mods.ui.anchor[self.anchor].position(self.window, self)
				end
				-- Check hovered
				self.hovered, self.cursor = Mods.ui.point_in_bounds(cursor, self:extended_bounds())
				if self.hovered then
					if self.tooltip then Mods.gui.tooltip(self.tooltip) end
					self:on_hover()
				end
				-- Clicked
				if self.clicked then
					self.clicked = self.hovered
				end
				-- Trigger event
				self:after_update()
				-- Return
				return self.clicked
			end,
			-- ################################################################################################################
			-- ##### Render ###################################################################################################
			-- ################################################################################################################
			--[[
				Main Render
			--]]
			render = function(self)
				-- Visible
				if not self.visible then return end
				-- Render shadow
				self:render_shadow()
				-- Render background
				self:render_background()
				-- Render text
				self:render_text()
			end,
			--[[
				Render shadow
			--]]
			render_shadow = function(self)
				-- Visible
				if not self.visible then return end
				-- Shadow set
				if self.theme.shadow then
					-- Get theme value
					local layers = self.theme.shadow.layers
					local border = self.theme.shadow.border
					local cv = self.theme.shadow.color
					-- Render
					for i=1, layers do
						local mod = layers-i
						local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
						Mods.gui.rect(self.position[1]+mod-border, self.position[2]-mod-border, self:position_z(),
							self.size[1]-mod*2+border*2, self.size[2]+mod*2+border*2, color)
					end
					for i=1, layers do
						local mod = layers-i
						local color = Color((cv[1]/layers)*i, cv[2], cv[3], cv[4])
						Mods.gui.rect(self.position[1]-mod-border, self.position[2]+mod-border, self:position_z(),
							self.size[1]+mod*2+border*2, self.size[2]-mod*2+border*2, color)
					end
				end
			end,
			--[[
				Render background
			--]]
			render_background = function(self)
				-- Visible
				if not self.visible then return end
				-- Get current theme color
				local color = ColorHelper.unbox(self.theme.color)
				if self.clicked then
					color = ColorHelper.unbox(self.theme.color_clicked)
				elseif self.hovered then
					color = ColorHelper.unbox(self.theme.color_hover)
				end
				-- Get bounds
				local bounds = self:extended_bounds()
				-- Render background rectangle
				Mods.gui.rect(bounds[1], bounds[4], self:position_z(), bounds[2]-bounds[1], bounds[3]-bounds[4], color)
			end,
			--[[
				Render text
			--]]
			render_text = function(self)
				-- Visible
				if not self.visible then return end
				-- Get current theme color
				local color = ColorHelper.unbox(self.theme.color_text)
				if self.clicked then
					color = ColorHelper.unbox(self.theme.color_text_clicked)
				elseif self.hovered then
					color = ColorHelper.unbox(self.theme.color_text_hover)
				end
				-- Get text info
				local text = self.text or ""
				--local font = self.theme.font
				local font = Mods.ui.fonts:get(self.theme.font)
				-- Get text alignment
				local position = {self.position[1] + self.size[2]*0.2, self.position[2] + self.size[2]*0.2}
				--local align = self.theme.text_alignment
				local align = Mods.ui.text_alignment[self.theme.text_alignment]
				if align then
					position = align.position(text, font, self:bounds())
				end
				-- Render text
				Mods.gui.text(text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
			end,
			-- ################################################################################################################
			-- ##### Attributes ###############################################################################################
			-- ################################################################################################################
			--[[
				Bounds
			--]]
			bounds = function(self)
				return Mods.ui.to_bounds(self.position, self.size)
			end,
			extended_bounds = function(self)
				return self:bounds()
			end,
			--[[
				Position Z
			--]]
			position_z = function(self)
				return self.window:position_z() + (#self.window.controls - self.z_order)
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				On init
			--]]
			on_init = function(self)
			end,
			--[[
				On click
			--]]
			on_click = function(self)
			end,
			--[[
				On hover
			--]]
			on_hover = function(self)
			end,
			--[[
				Before update
			--]]
			before_update = function(self)
			end,
			--[[
				After update
			--]]
			after_update = function(self)
			end,
		},

		title = {
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Init override
			--]]
			init = function(self)
				-- Original function
				self:init_base()
				-- Change
				self.height = self.height or Mods.ui.themes[Mods.ui.theme].title.height
			end,
			--[[
				Click override
			--]]
			click = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:click_base()
				-- Drag
				self:drag()
			end,
			-- ################################################################################################################
			-- ##### Cycle overrides ##########################################################################################
			-- ################################################################################################################
			--[[
				Update override
			--]]
			update = function(self)
				-- Set bounds
				self.size = {self.window.size[1], self.height or Mods.ui.themes[Mods.ui.theme].title.height}
				self.position = {self.window.position[1], self.window.position[2] + self.window.size[2] - self.size[2]}
				-- Disabled
				if self.disabled then return end
				-- Hover
				local cursor = Mods.ui.mouse.cursor()
				self.hovered, self.cursor = Mods.ui.point_in_bounds(cursor, self:bounds())
				-- Drag
				if self.window.dragging then self:drag() end
				-- Return
				return self.clicked or self.window.dragging
			end,
			-- ################################################################################################################
			-- ##### Drag #####################################################################################################
			-- ################################################################################################################
			--[[
				Drag start
			--]]
			drag_start = function(self)
				-- Set offset
				self.window.drag_offset = self.window.cursor
				-- Dragging
				self.window.dragging = true
				-- Block input
				Mods.ui.input:block()
				-- Trigger event
				self:before_drag()
			end,
			--[[
				Drag
			--]]
			drag = function(self)
				-- Catch start event
				if not self.window.dragging then self:drag_start() end
				-- Check mouse button
				self.window.dragging = not stingray.Mouse.released(stingray.Mouse.button_id("left"))
				-- Drag
				self:on_drag()
				-- Catch end event
				if not self.window.dragging then self:drag_end() end
			end,
			--[[
				Drag end
			--]]
			drag_end = function(self)
				-- Unblock input
				Mods.ui.input:unblock()
				-- Trigger event
				self:after_drag()
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				On drag start
			--]]
			before_drag = function(self)
			end,
			--[[
				On drag
			--]]
			on_drag = function(self)
			end,
			--[[
				On drag end
			--]]
			after_drag = function(self)
			end,
		},

		button = {},

		resizer = {
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Init override
			--]]
			init = function(self)
				-- Original function
				self:init_base()
				-- Change
				self.size = self.theme.size
			end,
			--[[
				Click override
			--]]
			click = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:click_base()
				-- Resize
				self:resize()
			end,
			-- ################################################################################################################
			-- ##### Resize ###################################################################################################
			-- ################################################################################################################
			--[[
				Start resize
			--]]
			resize_start = function(self)
				-- Save offset
				self.window.resize_offset = {self.window.size[1] - self.window.cursor[1], self.window.cursor[2]}
				self.window.resize_origin = {self.window.position[1], self.window.position[2] + self.window.size[2]}
				-- Set resizing
				self.window.resizing = true
				Mods.ui.input:block()
				-- Trigger event
				self:before_resize()
			end,
			--[[
				Resize
			--]]
			resize = function(self)
				-- Catch start event
				if not self.window.resizing then self:resize_start() end
				-- Check mouse button
				self.window.resizing = not stingray.Mouse.released(stingray.Mouse.button_id("left"))
				-- Trigger event
				self:on_resize()
				-- Catch end event
				if not self.window.resizing then self:resize_end() end
			end,
			--[[
				Resize end
			--]]
			resize_end = function(self)
				-- Block input
				Mods.ui.input:unblock()
				-- Trigger event
				self:after_resize()
			end,
			-- ################################################################################################################
			-- ##### Cycle overrides ##########################################################################################
			-- ################################################################################################################
			--[[
				Update override
			--]]
			update = function(self)
				-- Update position
				self.position = {self.window.position[1] + self.window.size[1] - self.size[1] - 5, self.window.position[2] + 5}
				-- Disabled
				if self.disabled then return end
				-- Hover
				local cursor = Mods.ui.mouse.cursor()
				--local bounds = Mods.ui.to_bounds({self.position[1], self.position[2]}, self.size)
				self.hovered, self.cursor = Mods.ui.point_in_bounds(cursor, self:bounds())
				-- Resize
				if self.window.resizing then self:resize() end
				-- Return
				return self.clicked or self.window.resizing
			end,
			-- ################################################################################################################
			-- ##### Render overrides #########################################################################################
			-- ################################################################################################################
			--[[
				render_background override
			--]]
			render_background_bak = function(self)
				-- if self.window.resizing then
					-- local color = ColorHelper.unbox(self.theme.color_clicked)
					-- local bounds = self:bounds()
					-- Mods.gui.rect(bounds[1], bounds[4], self:position_z(), bounds[2]-bounds[1], bounds[3]-bounds[4], color)
				-- else
					-- self:render_background_base()
				-- end
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				Before resize
			--]]
			before_resize = function(self)
			end,
			--[[
				On resize
			--]]
			on_resize = function(self)
			end,
			--[[
				After resize
			--]]
			after_resize = function(self)
			end,
		},

		close_button = {
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Init override
			--]]
			init = function(self)
				-- Original function
				self:init_base()
				-- Change
				self.size = self.theme.size
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				OnClick override
			--]]
			on_click = function(self)
				-- Destroy window
				self.window:destroy()
			end,
		},

		textbox = {
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Init override
			--]]
			init = function(self)
				-- Original function
				self:init_base()
				-- Input cursor timer
				self.input_cursor = {
					timer = Mods.ui.timers:create_timer(self.name .. "_input_cursor_timer", 500, true, self.on_input_cursor_timer, self),
					state = true,
					position = 0,
				}
				-- Input timer
				self.input = {
					timer = Mods.ui.timers:create_timer(self.name .. "_input_timer", 100, true, self.on_input_timer, self),
					ready = true,
				}
				self.typing = {
					timer = Mods.ui.timers:create_timer(self.name .. "_typing_timer", 100, false, self.on_typing_timer, self),
				}
			end,
			--[[
				Release override
			--]]
			release = function(self)
				-- Disabled
				if self.disabled then return end
				-- Clicked
				if self.clicked then self:focus() end
				-- Original function
				self:release_base()
			end,
			--[[
				Text changed
			--]]
			text_changed = function(self)
				-- Disable input
				self.input.ready = false
				-- Enable input timer
				self.input.timer.enabled = true
				-- Trigger event
				if self.on_text_changed then self:on_text_changed() end
			end,
			--[[
				Focus override
			--]]
			focus = function(self)
				-- Disabled
				if self.disabled then return end
				-- Block input
				if not self.has_focus then
					Mods.ui.input:block(true)
				end
				-- Original function
				self:focus_base()
			end,
			--[[
				Unfocus override
			--]]
			unfocus = function(self)
				-- Disabled
				if self.disabled then return end
				-- Unblock input
				if self.has_focus then
					Mods.ui.input:unblock()
				end
				-- Original function
				self:unfocus_base()
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				Cursor timer
			--]]
			on_input_cursor_timer = function(self, textbox)
				-- Toggle cursor state
				textbox.input_cursor.state = not textbox.input_cursor.state
			end,
			--[[
				Input timer
			--]]
			on_input_timer = function(self, textbox)
				-- Disable timer
				self.enabled = false
				-- Accept input
				textbox.input.ready = true
			end,
			on_typing_timer = function(self, textbox)
				self.enabled = false
				if textbox.on_done_typing then textbox:on_done_typing() end
			end,
			-- ################################################################################################################
			-- ##### Cycle overrides ##########################################################################################
			-- ################################################################################################################
			--[[
				Update override
			--]]
			update = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:update_base()
				-- Input
				if self.has_focus then
					local chat_input_service = Managers.input:get_service("chat_input")
					if chat_input_service then
						chat_input_service:get("activate_chat_input", true)
					end

					-- Get input service
					Managers.input:device_unblock_service("keyboard", 1, "ModsUI")
					local input_service = Managers.input:get_service("ModsUI")

					local keystrokes = stingray.Keyboard.keystrokes()
					if #keystrokes > 0 then
						self.typing.timer:reset()
					end
					-- Check input and timer
					if input_service then
						-- Check keystrokes
						for _, key in pairs(keystrokes) do
							if type(key) == "string" then
								local new_text = self.text
								if not table.has_item(ModUISpecialKeys, key) then
									if input_service:get("left shift") then
										new_text = new_text .. string.upper(key)
									else
										new_text= new_text .. key
									end
								elseif key == "space" then
									new_text = new_text .. " "
								end

								if new_text ~= self.text then
									local width = Mods.gui.text_width(new_text, "materials/fonts/gw_body_32", self.size[2])
									if width < self.size[1] then
										self.text = new_text
										self:text_changed()
									end
								end
							else
								-- If not string it's control key
								if input_service:get("backspace") then
									-- Handle backspace - remove last character
									if string.len(self.text) >= 1 then
										local _, count = string.gsub(self.text, "[^\128-\193]", "")
										self.text = UTF8:utf8sub(self.text, 1, count-1)
										-- Trigger changed
										self:text_changed()
									end
								elseif input_service:get("esc", true) or input_service:get("enter", true) or input_service:get("numpad enter", true) then
									-- Unfocus
									self:unfocus()
								end
							end
						end
					end
				end
				-- Return
				return self.clicked or self.has_focus
			end,
			-- ################################################################################################################
			-- ##### Render overrides #########################################################################################
			-- ################################################################################################################
			--[[
				Render main override
			--]]
			render = function(self)
				-- Visible
				if not self.visible then return end
				-- Original function
				self:render_base()
				-- Cursor
				self:render_cursor()
			end,
			--[[
				Render text override
			--]]
			render_text = function(self)
				-- Visible
				if not self.visible then return end
				-- Get current theme color
				local color = ColorHelper.unbox(self.theme.color_watermark)
				if self.clicked then
					color = ColorHelper.unbox(self.theme.color_text_clicked)
				elseif self.hovered and #self.text > 0 then
					color = ColorHelper.unbox(self.theme.color_text_hover)
				elseif #self.text > 0 then
					color = ColorHelper.unbox(self.theme.color_text)
				end
				-- Get text
				local text = self.text or ""
				if not self.has_focus then
					text = #self.text > 0 and self.text or self.watermark or ""
				end
				-- Get font
				--local font = self.theme.font
				local font = Mods.ui.fonts:get(self.theme.font)
				-- Get text alignment
				local position = {self.position[1] + self.size[2]*0.2, self.position[2] + self.size[2]*0.2}
				--local align = self.theme.text_alignment
				local align = Mods.ui.text_alignment[self.theme.text_alignment]
				if align then
					position = align.position(text, font, self:bounds())
				end
				-- Render text
				Mods.gui.text(text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
			end,
			--[[
				Render cursor
			--]]
			render_cursor = function(self)
				-- Visible
				if not self.visible then return end
				-- Render
				if self.has_focus and self.input_cursor.state then
					-- Get current theme color
					local color = ColorHelper.unbox(self.theme.color_input_cursor)
					-- Get data
					local width = 0
					--local font = self.theme.font
					local font = Mods.ui.fonts:get(self.theme.font)
					if self.text and #self.text > 0 then
						width = Mods.gui.text_width(self.text, font.material, font:font_size())
					end
					-- Render cursor
					Mods.gui.rect(self.position[1]+2+width, self.position[2]+2, self:position_z(), 2, self.size[2]-4, color)
				end
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				On text changed
			--]]
			on_text_changed = function(self)
			end,
			on_done_typing = function(self)
			end,
		},

		checkbox = {
			-- ################################################################################################################
			-- ##### Methods ##################################################################################################
			-- ################################################################################################################
			--[[
				Toggle state
			--]]
			toggle = function(self)
				-- Change
				self.value = not self.value
				-- Trigger event
				self:on_value_changed()
			end,
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Release override
			--]]
			release = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:release_base()
				-- Toggle
				self:toggle()
			end,
			-- ################################################################################################################
			-- ##### Render overrides #########################################################################################
			-- ################################################################################################################
			--[[
				Render override
			--]]
			render = function(self)
				-- Visible
				if not self.visible then return end
				-- Original function
				self:render_base()
				-- Render box
				self:render_box()
			end,
			--[[
				Render text override
			--]]
			render_text = function(self)
				-- Visible
				if not self.visible then return end
				-- Get current theme color
				local color = ColorHelper.unbox(self.theme.color_text)
				if self.clicked then
					color = ColorHelper.unbox(self.theme.color_text_clicked)
				elseif self.hovered then
					color = ColorHelper.unbox(self.theme.color_text_hover)
				end
				-- Get font
				--local font = self.theme.font
				local font = Mods.ui.fonts:get(self.theme.font)
				-- Get text alignment
				local position = {self.position[1] + self.size[2] + 5, self.position[2] + self.size[2]*0.2}
				-- local align = self.theme.text_alignment
				-- if align then
					-- position = align.position(self.text, font, self:bounds())
				-- end
				-- Render text
				Mods.gui.text(self.text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
			end,
			--[[
				Render box
			--]]
			render_box = function(self)
				-- Visible
				if not self.visible then return end
				-- Check value
				if self.value then
					-- Get current theme color
					local color = ColorHelper.unbox(self.theme.color_text)
					if self.clicked then
						color = ColorHelper.unbox(self.theme.color_text_clicked)
					elseif self.hovered then
						color = ColorHelper.unbox(self.theme.color_text_hover)
					end
					local text = "X"
					-- Get font
					--local font = self.theme.font
					local font = Mods.ui.fonts:get(self.theme.font)
					-- Get text alignment
					local position = {self.position[1] + 5, self.position[2] + self.size[2]*0.2}
					--local align = self.theme.text_alignment
					local align = Mods.ui.text_alignment[self.theme.text_alignment]
					if align then
						position = align.position(text, font, self:bounds())
					end
					-- Render text
					Mods.gui.text(text, position[1], position[2], self:position_z()+1, font:font_size(), color, font.font)
				end
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				Text changed
			--]]
			on_value_changed = function(self)
			end,
		},

		label = {},

		dropdown = {
			-- ################################################################################################################
			-- ##### Methods ##################################################################################################
			-- ################################################################################################################
			--[[
				Select index
			--]]
			select_index = function(self, index)
				-- Check options  ( options are dropdown_item controls )
				if self.options and #self.options >= index then
					-- Set index
					self.index = index
					-- Set text
					self:update_text()
					-- Trigger event
					self:on_index_changed()
				end
			end,
			update_text = function(self)
				for _, option in pairs(self.options) do
					if option.index == self.index then
						self.text = option.text
						return
					end
				end
			end,
			--[[
				Wrap function calls to options
			--]]
			wrap_options = function(self, function_name)
				local results = {}
				-- Go through options
				for key, option in pairs(self.options) do
					-- Check for function and execute it
					if option[function_name] and type(option[function_name]) == "function" then
						local result = option[function_name](option)
						results[#results+1] = result
					end
				end
				-- Return
				return results
			end,
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Init override
			--]]
			init = function(self)
				-- Original function
				self:init_base()
				-- Wrap init
				self:wrap_options("init")
				-- If options select first
				if #self.options > 0 and not self.index then self.index = 1 end
				self:select_index(self.index)
			end,
			--[[
				Click override
			--]]
			click = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:click_base()
				-- Go through options
				for key, option in pairs(self.options) do
					-- If option hovered
					if Mods.ui.point_in_bounds(Mods.ui.mouse.cursor(), option:extended_bounds()) then
						-- Click option
						option:click()
					end
				end
			end,
			--[[
				Release override
			--]]
			release = function(self)
				-- Disabled
				if self.disabled then return end
				-- Drop
				if self.clicked then self.dropped = not self.dropped end
				-- Original function
				self:release_base()
				-- Go through options
				for key, option in pairs(self.options) do
					-- If option hovered
					if Mods.ui.point_in_bounds(Mods.ui.mouse.cursor(), option:extended_bounds()) then
						-- Release
						option:release()
					end
				end
			end,
			--[[
				Unfocus override
			--]]
			unfocus = function(self)
				-- Original function
				self:unfocus_base()
				-- Drop off
				self.dropped = false
				-- Wrap
				self:wrap_options("unfocus")
			end,
			-- ################################################################################################################
			-- ##### Cycle overrides ##########################################################################################
			-- ################################################################################################################
			--[[
				Update override
			--]]
			update = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:update_base()
				-- If dropped
				if self.dropped then
					-- Get some shit
					local scale = UIResolutionScale()
					local border = 2*scale
					local x = self.position[1] --+ border
					local y = self.position[2] - border -- self.size[2] - border
					-- Go through options
					--table.sort(self.options)
					--for i = 1, #self.options do
					--for i = #self.options, 1, -1 do
						-- EchoConsole("--")
						for _, option in pairs(self.options) do
							--if option.param == i then
								-- Update position
								-- EchoConsole(tostring(option.param))
								option:set("position", {x, y - (self.size[2] * option.index)})
								option:set("size", self.size)
								option:set("visible", true)
								--y = y - self.size[2] --- border
								--break
							--end
						end
					--end
					-- Wrap
					self:wrap_options("update")
				end
				-- Return
				return self.clicked or self.dropped
			end,
			-- ################################################################################################################
			-- ##### Render overrides #########################################################################################
			-- ################################################################################################################
			--[[
				Render main override
			--]]
			render = function(self)
				-- Visible
				if not self.visible then return end
				-- Original function
				self:render_base()
				-- If dropped
				if self.dropped then
					-- Wrap
					self:wrap_options("render")
				end
			end,
			-- ################################################################################################################
			-- ##### Attribute overrides ######################################################################################
			-- ################################################################################################################
			--[[
				Bounds override
			--]]
			extended_bounds = function(self)
				local bounds = self:bounds()
				-- If dropped
				if self.dropped then
					-- Change bounds to reflect dropped size
					bounds[3] = bounds[3] - (self.size[2]*#self.options)
					--bounds[4] = bounds[4] --+ self.size[2] + (self.size[2]*#self.options)
				end
				-- Return
				return bounds
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				Index changed
			--]]
			on_index_changed = function(self)
			end,
		},

		dropdown_item = {
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Release override
			--]]
			release = function(self)
				-- Disabled
				if self.disabled then return end
				-- Original function
				self:release_base()
				-- Change
				if self.parent and self.index then
					self.parent:select_index(self.index)
				end
			end,
			-- ################################################################################################################
			-- ##### Attribute overrides ######################################################################################
			-- ################################################################################################################
			--[[
				Position Z override
			--]]
			position_z = function(self)
				-- Return parent position z + 1
				return self.parent:position_z()+1
			end,
		},

		image = {
			render = function(self)
				if self.visible then
					draw_image(self.texture_id, self.uvs, self.position, self:position_z(), self.size, self.color)
				end
			end,
		},

		checkbox_square = {
			-- ################################################################################################################
			-- ##### Methods ##################################################################################################
			-- ################################################################################################################
			--[[
				Toggle state
			--]]
			toggle = function(self)
				-- Change
				self.value = not self.value
				-- Trigger event
				self:on_value_changed()
			end,
			-- ################################################################################################################
			-- ##### Control overrides ########################################################################################
			-- ################################################################################################################
			--[[
				Release override
			--]]
			release = function(self)
				-- Disabled
				if self.disabled or self.immutable then return end
				-- Original function
				self:release_base()
				-- Toggle
				self:toggle()
			end,
			bounds = function(self)
				local font = Mods.ui.fonts:get(self.theme.font)
				local text_width = Mods.gui.text_width(self.text, font.material, font:font_size())
				local text_height = font:font_size()
				return Mods.ui.to_bounds(self.position, { (16 + 3 + text_width), math.max(16, text_height) })
			end,
			-- ################################################################################################################
			-- ##### Render overrides #########################################################################################
			-- ################################################################################################################
			--[[
				Render override
			--]]
			render = function(self)
				-- Visible
				if self.visible then
					-- Render label
					self:render_text()
					-- Render box
					self:render_box()
				end
			end,
			--[[
				Render text override
			--]]
			render_text = function(self)
				-- Visible
				if not self.visible then return end
				-- Get current theme color
				local color
				if self.disabled or self.immutable then
					color = ColorHelper.unbox(self.theme.color_text_disabled)
				elseif self.hovered then
					color = ColorHelper.unbox(self.theme.color_text_hover)
				else
					color = ColorHelper.unbox(self.theme.color_text)
				end
				-- Get font
				local font = Mods.ui.fonts:get(self.theme.font)
				-- Render text
				local position = self.position
				Mods.gui.text(self.text, position[1] + 16 + 3, position[2] + 2, self:position_z(), font:font_size(), color, font.font)
			end,
			--[[
				Render box
			--]]
			render_box = function(self)
				-- Visible
				if not self.visible then return end
				-- Check value
				local texture_id = (self.value and "checkbox_checked") or "checkbox_unchecked"
				draw_image(texture_id, nil, self.position, self:position_z(), { 16, 16 }, { 255, 255, 255, 255 })
			end,
			-- ################################################################################################################
			-- ##### Events ###################################################################################################
			-- ################################################################################################################
			--[[
				Text changed
			--]]
			on_value_changed = function(self)
			end,
		}
	},

	-- ################################################################################################################
	-- ##### Themes ###################################################################################################
	-- ################################################################################################################
	themes = {
		-- Define a "default" theme element with common values for every control
		-- Define specific elements with a control name to overwrite default settings
		-- Default theme
		default = {
			-- default theme element
			default = {
				color = ColorHelper.box(200, 50, 50, 50),
				color_hover = ColorHelper.box(200, 60, 60, 60),
				color_clicked = ColorHelper.box(200, 90, 90, 90),
				color_text = ColorHelper.box(100, 255, 255, 255),
				color_text_hover = ColorHelper.box(200, 255, 168, 0),
				color_text_clicked = ColorHelper.box(255, 255, 180, 0),
				text_alignment = "middle_center",
				shadow = {
					layers = 5,
					border = 0,
					color = {20, 10, 10, 10},
				},
				font = "hell_shark",
			},
			-- Overwrites and additions
			window = {
				color = ColorHelper.box(200, 30, 30, 30), --
				color_hover = ColorHelper.box(255, 35, 35, 35), --
				shadow = {
					layers = 0,
					border = 0,
					color = {0, 255, 255, 255},
				},
			},
			title = {
				height = 20,
				color = ColorHelper.box(255, 40, 40, 40),
				color_hover = ColorHelper.box(255, 50, 50, 50),
				color_clicked = ColorHelper.box(255, 60, 60, 60),
				color_text = ColorHelper.box(200, 255, 255, 255),
				color_text_hover = ColorHelper.box(200, 255, 168, 0),
				color_text_clicked = ColorHelper.box(255, 255, 180, 0),
				shadow = {
					layers = 5,
					border = 0,
					color = {20, 10, 10, 10},
				},
			},
			button = {},
			resizer = {
				size = {20, 20},
			},
			close_button = {
				size = {25, 25},
			},
			textbox = {
				color_watermark = ColorHelper.box(50, 255, 255, 255),
				color_input_cursor = ColorHelper.box(100, 255, 255, 255),
				text_alignment = "middle_left",
			},
			checkbox = {},
			dropdown = {
				draw_items_num = 5,
			},
			dropdown_item = {
				color_hover = ColorHelper.box(255, 60, 60, 60),
				color_clicked = ColorHelper.box(255, 90, 90, 90),
			},
			label = {
				color = ColorHelper.box(0, 0, 0, 0),
				color_hover = ColorHelper.box(0, 0, 0, 0),
				color_clicked = ColorHelper.box(0, 0, 0, 0),
				color_text = ColorHelper.box(200, 255, 255, 255),
				color_text_hover = ColorHelper.box(200, 255, 255, 255),
				color_text_clicked = ColorHelper.box(200, 255, 255, 255),
				shadow = {
					layers = 0,
					border = 0,
					color = {20, 10, 10, 10},
				},
			},
			image = {},
			checkbox_square = {}
		},
	}

}

-- ################################################################################################################
-- ##### Default stuff ############################################################################################
-- ################################################################################################################
Mods.ui.fonts:create("default", "hell_shark", 22)
Mods.ui.fonts:create("hell_shark", "hell_shark", 22, nil, true)

-- ################################################################################################################
-- ##### UTF8 #####################################################################################################
-- ################################################################################################################
UTF8 = {
	-- UTF-8 Reference:
	-- 0xxxxxxx - 1 byte UTF-8 codepoint (ASCII character)
	-- 110yyyxx - First byte of a 2 byte UTF-8 codepoint
	-- 1110yyyy - First byte of a 3 byte UTF-8 codepoint
	-- 11110zzz - First byte of a 4 byte UTF-8 codepoint
	-- 10xxxxxx - Inner byte of a multi-byte UTF-8 codepoint

	chsize = function(self, char)
		if not char then
			return 0
		elseif char > 240 then
			return 4
		elseif char > 225 then
			return 3
		elseif char > 192 then
			return 2
		else
			return 1
		end
	end,

	-- This function can return a substring of a UTF-8 string, properly handling
	-- UTF-8 codepoints.  Rather than taking a start index and optionally an end
	-- index, it takes the string, the starting character, and the number of
	-- characters to select from the string.

	utf8sub = function(self, str, startChar, numChars)
		local startIndex = 1
		while startChar > 1 do
			local char = string.byte(str, startIndex)
			startIndex = startIndex + self:chsize(char)
			startChar = startChar - 1
		end

		local currentIndex = startIndex

		while numChars > 0 and currentIndex <= #str do
			local char = string.byte(str, currentIndex)
			currentIndex = currentIndex + self:chsize(char)
			numChars = numChars -1
		end
		return str:sub(startIndex, currentIndex - 1)
	end,
}

-- ################################################################################################################
-- ##### Entry point ##############################################################################################
-- ################################################################################################################
--[[
	Update cycle
--]]
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	-- Original function
	func(self, dt, t)
	-- Wrap pcall
	safe_pcall(function()
		if Mods.ui then
			Mods.ui.update()
			Mods.ui.timers:update(t)
		end
	end)
end)