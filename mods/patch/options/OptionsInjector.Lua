local mod_name = "OptionsInjector"
--[[
	Author: grasmann
	
	Injects custom options into menus
--]]

OptionsInjector = {
	
	initialized = false,
	
	CHECKBOX_SIZE = {36, 36},
	WIDGET_SIZE = {1315, 50},
	
	modifiers = {},
	widgets = {},
	keybind = {},
	dynamic = {},
	
	ModSettings = {
		view = {},
		offset = {
			base = {0, 0, 0},
			value = {0, 0, 0},
		},
		cache = {},
		hidden = {},
		list_start = "mod_settings_liststart",
		name = "Mod",
		is_open = false,
	},
	
	DynamicText = {
		{
			name = "dyn_local_player",
			default = "N/A",
			get_value = function()
				local local_player = Managers.player:local_player()
				local name = local_player._cached_name or local_player.character_name or "N/A"
				return name
			end
		},
	},
	
	key_modifiers = {
		NONE = 1,
		CTRL = 2,
		SHIFT = 3,
		ALT = 4,
		CTRL_SHIFT = 5,
		CTRL_ALT = 6,
		SHIFT_ALT = 7,
	},
	
}
local me = OptionsInjector
local get = Application.user_setting
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ####################################################################################################################
-- ##### Public functions ##############################################################################################
-- ####################################################################################################################
--[[
	Create stepper widget
--]]
OptionsInjector.stepper_widget = function(name, text, options, selected_option, tooltip_text, hide_options, dynamic)		
	local widget = me.widgets.stepper(text, options, selected_option, tooltip_text, name, hide_options, dynamic)
	
	me.add_to_cache(widget)
	
	return widget
end
OptionsInjector.CreateStepperWidget = OptionsInjector.stepper_widget
--[[
	Create checkbox widget
--]]
OptionsInjector.checkbox_widget = function(name, text, default_value, hide_options, dynamic, tooltip_text)
	local widget = me.widgets.checkbox(name, text, default_value, hide_options, dynamic, tooltip_text)
	
	me.add_to_cache(widget)
	
	return widget
end
OptionsInjector.CreateCheckBoxWidget = OptionsInjector.checkbox_widget
--[[
	Create dropdown checkbox widget
--]]
OptionsInjector.dropdown_checkbox_widget = function(name, text, default_value, hide_options, dynamic, tooltip_text)
	local widget = me.widgets.dropdown_checkbox(name, text, default_value, hide_options, dynamic, tooltip_text)
	
	me.add_to_cache(widget)
	
	return widget
end
OptionsInjector.CreateDropDownCheckBoxWidget = OptionsInjector.dropdown_checkbox_widget
--[[
	Create slider widget
--]]
OptionsInjector.slider_widget = function(name, text, tooltip_text, values, default_value, dynamic)
	local widget = me.widgets.slider(name, text, tooltip_text, values, default_value, dynamic)
	
	me.add_to_cache(widget)
	
	return widget
end
OptionsInjector.CreateSliderWidget = OptionsInjector.slider_widget
--[[
	Create dropdown widget
--]]
OptionsInjector.dropdown_widget = function(name, text, options, selected_option, tooltip_text, hide_options, dynamic)
	local widget = me.widgets.drop_down(text, options, selected_option, tooltip_text, name, hide_options, dynamic)
	
	me.add_to_cache(widget)
	
	return widget
end
OptionsInjector.CreateDropDownWidget = OptionsInjector.dropdown_widget
--[[
	Create keybind widget
--]]
OptionsInjector.keybind_widget = function(name, text, selected_key, default_value, modifiers, folder, script)
	local widget = me.widgets.keybind(name, text, selected_key, default_value)
	me.keybind.modifier(widget, modifiers)
	widget.content.folder = folder
	widget.content.script = script
	me.add_to_cache(widget)
	me.keybind.init(name, selected_key, nil, modifiers, folder, script)
	
	return widget
end
OptionsInjector.CreateKeybindWidget = OptionsInjector.keybind_widget
--[[
	Create empty line widget
--]]
OptionsInjector.empty_line = function()
	local widget = me.widgets.texture("popup_divider", {1315, 15})
	--local widget = me.widgets.texture("interaction_bar", {1315, 50})
	me.add_to_cache(widget)
end
OptionsInjector.CreateEmptyLine = OptionsInjector.empty_line

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################
--[[
	Hook to make sure the ingame ui is loaded because we need a reference
--]]
Mods.hook.set(mod_name, "IngameUI.update", function(func, self, dt, t, ...)

	if self.views.options_view.selected_settings_list == self.views.options_view.settings_lists.mod_settings then
		local oi = OptionsInjector
		oi.init(self.views.options_view)
		oi.dynamic.update()
		oi.widgets.set_offsets()
		oi.widgets.update(self.views.options_view)
	end
	func(self, dt, t, ...)
end)
--[[
	Hook to recreate options when ui is recreated
--]]
Mods.hook.set(mod_name, "StateInGameRunning.create_ingame_ui", function(func, self, ingame_ui_context)
	local oi = OptionsInjector
	func(self, ingame_ui_context)
	if oi.initialized then
		oi.initialized = false
	end
end)

-- ####################################################################################################################
-- ##### OptionsInjector ##############################################################################################
-- ####################################################################################################################
--[[
	Init OptionsInjector
--]]
OptionsInjector.init = function(options_view)
	
	if not OptionsInjector.initialized and options_view ~= nil then
		me.create_mod_settings_button(options_view)

		-- ##### Reset mod settings ###################################################################################
		me.ModSettings.view = options_view.settings_lists.mod_settings
		me.ModSettings.offset.value = table.clone(me.ModSettings.offset.base)
		options_view.settings_lists.mod_settings.max_offset_y = -762

		me.initialized = true
		
		-- ##### Load cached options ##################################################################################
		for __, widget in pairs(me.ModSettings.cache) do
			me.add_to_menu(widget)
		end	
		
		return true
	end
	return false
end
--[[
	Check for option
--]]
OptionsInjector.has_option = function(name)
	return table.has_item(me.ModSettings.cache, name)
end
--[[
	Add widget to cache
--]]
OptionsInjector.add_to_cache = function(widget)
	if not me.has_option(widget.name) or widget.name == "seperator" then
		me.ModSettings.cache[#me.ModSettings.cache+1] = widget
		me.add_to_menu(me.ModSettings.cache[#me.ModSettings.cache])
	end
end
--[[
	Add widget to menu
--]]
OptionsInjector.add_to_menu = function(widget)
	if me.initialized then
		me.ModSettings.view.widgets[#me.ModSettings.view.widgets+1] = widget
		me.ModSettings.view.widgets_n = #me.ModSettings.view.widgets
		--me.widgets.update()
	end
end

-- ####################################################################################################################
-- ##### Dynamic Text #################################################################################################
-- ####################################################################################################################
--[[
	Replace the text of a dynamic widget
--]]
OptionsInjector.dynamic.replace = function(content)
	for _, dynamic in pairs(me.DynamicText) do
		if dynamic.name == content.name then
			local name = dynamic.get_value()
			name = name or dynamic.default or "N/A"
			--name = "𝕷𝖔𝖛𝖊 𝕮𝖆𝖙"
			--name = "� � � � � 𐀀� � � � � � �"
			if not Utf8.valid(name) then
				name = "Non-UTF8 Error"
			end
			content.text = name
		end
	end
end
--[[
	Update dynamic widgets
--]]
OptionsInjector.dynamic.update = function()
	if me.initialized then
		for _, widget in pairs(me.ModSettings.cache) do
			if widget.content.dynamic then
				me.dynamic.replace(widget.content)
			end
		end
	end
end
--[[
	Add dynamic text
--]]
OptionsInjector.dynamic.add = function(name, default, get_value)
	if not table.has_item(me.DynamicText, name) then
		local new_text = {
			name = name,
			default = default,
			get_value = get_value,
		}
		me.DynamicText[#me.DynamicText+1] = new_text
	end
end
OptionsInjector.add_dynamic_text = OptionsInjector.dynamic.add

-- ####################################################################################################################
-- ##### Widgets ######################################################################################################
-- ####################################################################################################################
--[[
	Get the count of visible widgets
--]]
OptionsInjector.widgets.visible_widgets = function()
	local count = 0
	for _, widget in pairs(me.ModSettings.cache) do
		if me.widgets.visible(widget) and not widget.skip_visible then
			count = count + 1
		end
	end
	return count
end
--[[
	Indent child widgets
--]]
OptionsInjector.widgets.indent_childs = function(widget)	
	if widget.content.hide_options ~= nil then
		
		for _, hide_option in pairs(widget.content.hide_options) do
		
			for _, name in pairs(hide_option.options) do
				local w = me.widgets.by_name(name)
				if w ~= nil and w.style.text ~= nil and not w.skip_visible then
					w.style.text.offset[1] = widget.style.text.offset[1] + 50
				end
			end
		
		end
		
	end	
end
--[[
	Set widget offsets
--]]
OptionsInjector.widgets.set_offsets = function()
	-- Set default offset
	for _, widget in pairs(me.ModSettings.cache) do
		me.widgets.set_offset(widget)
	end
	-- Change for child widgets
	for _, widget in pairs(me.ModSettings.cache) do
		me.widgets.indent_childs(widget)
	end
end
--[[
	Update menu settings table
--]]
OptionsInjector.widgets.update = function(options_view)
	local settings = me.ModSettings
	local visible_n = me.widgets.visible_widgets()
	settings.view.visible_widgets_n = visible_n
	settings.view.max_offset_y = (visible_n * 50) - 750 --762 + 25
	
	-- If current menu is mod settings
	--if options_view.selected_settings_list ~= nil and settings.view == options_view.selected_settings_list then
		-- if not settings.is_open then
			-- safe_pcall(function()
				-- --me.dynamic.update()
				-- --me.widgets.set_offsets()
			-- end)
		-- end
		local widgets_sizes = settings.view.visible_widgets_n * 50
		--local bar_size = options_view.ui_scenegraph.list_mask.children[4].size[2] / widgets_sizes
		local bar_size = options_view.ui_scenegraph.list_mask.size[2] / widgets_sizes
		options_view.scrollbar.content.scroll_bar_info.bar_height_percentage = bar_size
		-- settings.is_open = true
	-- else
		-- settings.is_open = false
	-- end
	
	-- Handle scrollbar
	if settings.view.visible_widgets_n >= 16 then
		settings.view.scrollbar = true
		settings.view.visible_widgets_n = 16		
	else		
		options_view.set_scrollbar_value(options_view, 0)
		if settings.view.scrollbar then
			options_view.set_scrollbar_value(options_view, 0)
			options_view.update_scrollbar(options_view, settings.view, options_view.ui_scenegraph)
			settings.view.scrollbar = false
		end
	end
	
end
--[[
	Check widget visibility
--]]
OptionsInjector.widgets.visible = function(widget)
	return widget.style.offset[1] < 2000
end
--[[
	Set widget visibility
--]]
OptionsInjector.widgets.set_visible = function(widget, visible)
	if not visible then
		widget.offx = widget.offx or widget.style.offset[1]
		widget.style.offset[1] = 2000		
		
		local modifier = widget.content.modifier
		if modifier then
			modifier.offx = modifier.offx or modifier.style.offset[1]
			modifier.style.offset[1] = 2000
		end
		--if widget.content.hide_options ~= nil then
			--widget.content.callback(widget.content)
		--end
		if widget.content.hide_options ~= nil then
			
			for _, hide_option in pairs(widget.content.hide_options) do
			
				for _, name in pairs(hide_option.options) do
					local hide_widget = me.widgets.by_name(name)
					if hide_widget ~= nil then
						-- --widget.content.callback(hide_widget.content)
						me.widgets.set_visible(hide_widget, false)
					end
				end
			
			end
			
			me.widgets.set_offsets()
		end
	else		
		widget.style.offset[1] = widget.offx
		widget.offx = nil
		
		local modifier = widget.content.modifier
		if modifier then
			modifier.style.offset[1] = modifier.offx
			modifier.offx = nil
		end
		
		if widget.content.hide_options ~= nil then
			widget.content.callback(widget.content)
		end
	end	
end
--[[
	Get widget by name
--]]
OptionsInjector.widgets.by_name = function(name)
	for _, widget in pairs(me.ModSettings.cache) do
		if widget.name == name then
			return widget
		end
	end
	return nil
end
--[[
	Get visible index by widget
--]]
OptionsInjector.widgets.visible_index = function(widget)
	local index = 1
	if me.widgets.visible(widget) then
		for _, w in pairs(me.ModSettings.cache) do
			if me.widgets.visible(w) then
				if widget == w then
					-- if w.skip_visible then
						-- return index-1
					-- end
					return index
				end
				if not w.skip_visible then
					index = index + 1
				end
			end
		end
	end
	return nil
end
--[[
	Triggered when widget settings change
--]]
OptionsInjector.widgets.on_change = function(content, setting_value)
	if content.hide_options ~= nil then
		if me.widgets.visible(me.widgets.by_name(content.name)) then
			local settings = me.ModSettings
			local hide_options = content.hide_options
			
			for _, hide_option in pairs(hide_options) do
				local value = hide_option[1]
				local show = hide_option.mode == "show"
				if value == setting_value then
					for _, name in pairs(hide_option.options) do
						local hide_widget = me.widgets.by_name(name)
						if hide_widget ~= nil then
							if me.widgets.visible(hide_widget) ~= show then
								me.widgets.set_visible(hide_widget, show)
							end
						end
					end
				end
			end
			
		end
	end
	me.widgets.set_offsets()
end
--[[
	Set widget offset
--]]
OptionsInjector.widgets.set_offset = function(widget)
	if widget.skip_visible then
		local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
		local value = widget.parent_widget.style.offset[2]
		for _, style in pairs(widget.style) do
			if style.offset ~= nil then
				style.offy = style.offy or style.offset[2] - widget.style.offset[2]
				style.offset[2] = value + style.offy
			end
		end
		--widget.style.offset[1] = widget.parent_widget.style.offset[1]
		widget.style.offset[2] = value
		--widget.content.is_highlighted = true
	else
		local index = me.widgets.visible_index(widget)
		local size = -50
		if index ~= nil and index > 1 then	
			local value = index * size
			for _, style in pairs(widget.style) do
				if style.offset ~= nil then
					style.offy = style.offy or style.offset[2] - widget.style.offset[2]
					style.offset[2] = value + style.offy
				end
			end
			widget.style.offset[2] = value
		end	
	end
end
-- ##### Create Widgets ###############################################################################################
--[[
	Create stepper
--]]
OptionsInjector.widgets.stepper = function(text, options, selected_option, tooltip_text, name, hide_options, dynamic)
	
	local options_view_definitions = package.loaded["scripts/ui/views/options_view_definitions"]
	local definition = options_view_definitions.create_stepper_widget(text, options, selected_option, tooltip_text, 
		me.ModSettings.list_start, me.ModSettings.offset.value)
	
	-- ##### widget ###################################################################################################
	definition.name = name
	definition.type = "stepper"
	definition.ui_animations = {}	
	
	-- ##### content ##################################################################################################
	definition.content.name = name
	definition.content.hide_options = hide_options
	definition.content.dynamic = dynamic or false
	definition.content.saved_value_cb = function(widget)
		for i=1, #widget.content.options_values do
			if widget.content.options_values[i] == get(widget.content.name) then
				widget.content.current_selection = i
				break
			end
		end
		me.widgets.on_change(widget.content, widget.content.options_values[widget.content.current_selection])
	end
	definition.content.on_pressed_callback = function()
	end
	definition.content.on_hover_enter_callback = function()
	end
	definition.content.on_hover_exit_callback = function()
	end
	definition.content.visible = true
	definition.content.default_value = selected_option
	definition.content.callback = function(content)
		local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
		options_view.changed_user_settings[content.name] = content.options_values[content.current_selection]
		me.widgets.on_change(content, content.options_values[content.current_selection])
	end
	-- ##### Set references ###########################################################################################
	definition.content.highlight_hotspot.parent = definition.content
	definition.content.highlight_hotspot.disable_button = false
	definition.content.right_hotspot.parent = definition.content
	definition.content.right_hotspot.disable_button = false
	definition.content.left_hotspot.parent = definition.content
	definition.content.left_hotspot.disable_button = false

	for _,id in ipairs({"left_arrow", "right_arrow", "left_arrow_hover", "right_arrow_hover"}) do
		for pass_index, pass in ipairs(definition.element.passes) do
			if pass.texture_id and pass.texture_id == id then
				definition.element.passes[pass_index].content_check_function = function(content)
					local game_mode = Managers.state.game_mode
					if content.disabled_outside_inn and game_mode and game_mode:game_mode_key() ~= "inn" then
						content.disabled = true
						return false
					end
					content.disabled = false
					return true
				end
			end
		end
	end
	
	-- ##### Style #####
	definition.style.text.localize = false
	definition.style.tooltip_text.localize = false
	
	return definition
end
--[[
	Create checkbox
--]]
OptionsInjector.widgets.checkbox = function(name, text, default_value, hide_options, dynamic, tooltip_text)
	local settings = me.ModSettings
	local options_view_definitions = package.loaded["scripts/ui/views/options_view_definitions"]
	local definition = options_view_definitions.create_checkbox_widget(text, settings.list_start, 
		settings.offset.value)
	
	-- ##### widget ###################################################################################################
	definition.name = name
	definition.type = "checkbox"
	definition.ui_animations = {}
	
	-- -- ##### content ##################################################################################################
	--definition.content.visible = true
	definition.content.name = name
	definition.content.hide_options = hide_options
	definition.content.default_value = default_value
	definition.content.dynamic = dynamic or false
	definition.content.saved_value_cb = function(widget)
		widget.content.flag = get(widget.content.name)
		me.widgets.on_change(widget.content, widget.content.flag)
	end	
	definition.content.on_pressed_callback = function()
	end
	definition.content.on_hover_enter_callback = function()
	end
	definition.content.on_hover_exit_callback = function()
	end
	definition.content.callback = function(content)
		local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
		options_view.changed_user_settings[content.name] = content.flag
		me.widgets.on_change(content, content.flag)
	end
	-- ##### Set references ########################################################################################
	definition.content.hotspot.parent = definition.content
	definition.content.hotspot.disable_button = false
	definition.content.highlight_hotspot.parent = definition.content
	definition.content.highlight_hotspot.disable_button = false
	
	-- ##### Style #####
	definition.style.text.localize = false
	definition.style.size = table.clone(me.WIDGET_SIZE)
	definition.style.highlight_texture.size = table.clone(me.WIDGET_SIZE)
	local old_size = definition.style.checkbox.size[2]
	local diff = me.CHECKBOX_SIZE[2] - old_size
	definition.style.checkbox.size = me.CHECKBOX_SIZE
	definition.style.checkbox.offset = {516 + definition.style.checkbox.offset[1] - diff / 2, definition.style.checkbox.offset[2] - diff / 2, definition.style.checkbox.offset[3]}

	local tooltip_pass = {
		style_id = "tooltip_text",
		pass_type = "tooltip_text",
		text_id = "tooltip_text",
		content_check_function = function (ui_content)
			return ui_content.tooltip_text and ui_content.highlight_hotspot.is_hover
		end
	}
	table.insert(definition.element.passes, tooltip_pass)

	local tooltip_style = {
		font_type = "hell_shark",
		localize = false,
		font_size = 24,
		horizontal_alignment = "left",
		vertical_alignment = "top",
		cursor_side = "left",
		max_width = 600,
		cursor_offset = {
			-10,
			-27
		},
		text_color = Colors.get_color_table_with_alpha("white", 255),
		line_colors = {
			Colors.get_color_table_with_alpha("cheeseburger", 255)
		},
		offset = {
			0,
			0,
			me.ModSettings.offset.value[3] + 20
		}
	}
	definition.style.tooltip_text = tooltip_style
	definition.content.tooltip_text = tooltip_text

	definition.element.pass_data[#definition.element.passes] = UIPasses["tooltip_text"].init(definition.element.passes[#definition.element.passes], definition.content, definition.style, definition.style_global)

	return definition
end
--[[
	Create dropdown checkbox
--]]
OptionsInjector.widgets.dropdown_checkbox = function(name, text, default_value, hide_options, dynamic, tooltip_text)
	local widget = me.widgets.checkbox(name, text, default_value, hide_options, dynamic, tooltip_text)

	widget.element.passes[5].content_check_function = function() return false end -- hide the checkbox

	local dropdown_pass = 
		{
			pass_type = "rotated_texture",
			style_id = "arrow",
			texture_id = "arrow",
			content_check_function = function(content, style)
				if content.flag then
					style.angle = -0.5*math.pi
				else
					style.angle = 0.5*math.pi
				end
				return true
			end
		}

	local dropdown_arrow_style =
		{
			masked = true,
			size = {
				25,
				25
			},
			offset = {
				widget.style.checkbox.offset[1] + 5,
				widget.style.checkbox.offset[2] + 4,
				widget.style.checkbox.offset[3],
			},
			color = {
				255,
				255,
				255,
				255
			},
			angle = 1.5*math.pi,
			pivot = {
				12.5,
				12.5
			}
		}

	table.insert(widget.element.passes, dropdown_pass)
	widget.content.arrow = "settings_arrow_normal"
	widget.style.arrow = dropdown_arrow_style

	return widget
end
--[[
	Create slider
--]]
OptionsInjector.widgets.slider = function(name, text, tooltip_text, values, default_value, dynamic)
	local options_view_definitions = package.loaded["scripts/ui/views/options_view_definitions"]
	local slider_image = {size = {0, 0}, masked = true, offset = {0, 0, 0}}
	local definition = options_view_definitions.create_slider_widget(text, tooltip_text, 
		me.ModSettings.list_start, me.ModSettings.offset.value, slider_image)
	me.ModSettings.offset.value[2] = me.ModSettings.offset.value[2] + me.WIDGET_SIZE[2]
	
	-- ##### widget ###################################################################################################
	definition.name = name
	definition.type = "slider"
	definition.ui_animations = {}
	
	-- ##### content ##################################################################################################
	--definition.content.visible = true
	definition.content.name = name
	definition.content.min = values[1]
	definition.content.max = values[2]
	definition.content.default_value = default_value
	definition.content.dynamic = dynamic or false
	definition.content.saved_value_cb = function(widget)
		widget.content.value = get(widget.content.name) or definition.content.default_value or 1
		widget.content.internal_value = (widget.content.value - widget.content.min) / (widget.content.max - widget.content.min)
	end
	definition.content.on_pressed_callback = function()
	end
	definition.content.on_hover_enter_callback = function()
	end
	definition.content.on_hover_exit_callback = function()
	end
	definition.content.callback = function(content)
		local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
		options_view.changed_user_settings[content.name] = content.value
	end
	
	-- ##### Set references ########################################################################################
	definition.content.hotspot.parent = definition.content
	definition.content.hotspot.disable_button = false
	definition.content.highlight_hotspot.parent = definition.content
	definition.content.highlight_hotspot.disable_button = false
	
	-- ##### Style #####
	definition.style.text.localize = false
	definition.style.tooltip_text.localize = false
	
	return definition

end
--[[
	Create dropdown
--]]
OptionsInjector.widgets.drop_down = function(text, options, selected_option, tooltip_text, name, hide_options, dynamic)	
	local options_view_definitions = package.loaded["scripts/ui/views/options_view_definitions"]
	local definition = options_view_definitions.create_drop_down_widget(text, options, selected_option, tooltip_text, 
		me.ModSettings.list_start, me.ModSettings.offset.value)
	
	-- ##### widget ###################################################################################################
	definition.name = name
	definition.type = "drop_down"
	definition.ui_animations = {}
	
	-- ##### content ##################################################################################################
	definition.content.name = name
	definition.content.hide_options = hide_options
	definition.content.dynamic = dynamic or false
	definition.content.saved_value_cb = function(widget)
		for i=1, #widget.content.options_texts do
			if widget.content.options_values[i] == get(widget.content.name) then
				widget.content.current_selection = i
			end
		end
		me.widgets.on_change(widget.content, widget.content.options_values[widget.content.current_selection])
	end
	definition.content.on_pressed_callback = function()
	end
	definition.content.on_hover_enter_callback = function()
	end
	definition.content.on_hover_exit_callback = function()
	end
	definition.content.visible = true
	definition.content.default_value = selected_option
	definition.content.callback = function(content)
		local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
		options_view.changed_user_settings[content.name] = content.options_values[content.current_selection]
		me.widgets.on_change(content, content.options_values[content.current_selection])
	end
	
	-- ##### Set references ###########################################################################################
	definition.content.hotspot.parent = definition.content
	definition.content.hotspot.disable_button = false
	definition.content.highlight_hotspot.parent = definition.content
	definition.content.highlight_hotspot.disable_button = false
	
	-- ##### Style #####
	definition.style.text.localize = false
	definition.style.tooltip_text.localize = false
	
	return definition
end
--[[
	Create texture
--]]
OptionsInjector.widgets.texture = function(texture, texture_size)
	local options_view_definitions = package.loaded["scripts/ui/views/options_view_definitions"]
	local definition = options_view_definitions.create_simple_texture_widget(texture, texture_size, 
		me.ModSettings.list_start, me.ModSettings.offset.value)
	
	-- ##### widget ###################################################################################################
	definition.type = "image"
	definition.ui_animations = {}
	definition.name = "seperator"
	
	-- ##### content ##################################################################################################
	definition.content.name = "seperator"
	definition.content.saved_value_cb = function()
	end
	definition.content.on_pressed_callback = function()
	end
	definition.content.on_hover_enter_callback = function()
	end
	definition.content.on_hover_exit_callback = function()	
	end
	definition.content.callback = function()
	end
	
	-- ##### Style ####################################################################################################
	definition.style.texture_id.color = Colors.get_color_table_with_alpha("cheeseburger", 255)

	return definition
end
--[[
	Create keybind
--]]
OptionsInjector.widgets.keybind = function(name, text, selected_key, default_value)

	local keys = {"input"}
	local actions_info = {
		{action = "input", keybind = {"keyboard", selected_key or "A", "pressed"}},
	}

	local options_view_definitions = package.loaded["scripts/ui/views/options_view_definitions"]
	local definition = options_view_definitions.create_keybind_widget(selected_key, keys, actions_info, 
		me.ModSettings.list_start, me.ModSettings.offset.value)
	
	-- ##### widget ###################################################################################################
	definition.name = name
	definition.type = "keybind"
	definition.ui_animations = {}

	-- ##### content ##################################################################################################
	definition.content.name = name
	definition.content.keymappings_key = "ModsKeyMap"
	definition.content.keymappings_table_key = "win32"
	definition.content.default_value = {
		controller = "keyboard",
		key = default_value,
	}
	definition.content.text = text
	definition.content.selected_key = selected_key
	definition.content.saved_value_cb = function(widget)
		me.keybind.link_keymap()
		widget.content.selected_key = get(widget.content.name) or default_value
		if widget.content.modifier then
			local child = widget.content.modifier.content
			me.keybind.init(widget.content.name, widget.content.selected_key, nil, child.options_values[child.current_selection], 
				widget.content.folder, widget.content.script)
		end
	end
	definition.content.callback = function(new_key, device, content)
		me.keybind.link_keymap()
		-- Don't allow certain keys as input
		local blocked = {"left ctrl", "left alt", "left shift", "right ctrl", "right alt", "right shift", "esc",
			"escape", "tab", "caps lock", "enter", "print screen", "pause", "num lock"}
		if not table.has_item(blocked, new_key) then
			local actions_info = content.actions_info
			local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
			
			local button_locale_name = string.lower(me.keybind.key_name(device, new_key))
			-- if device == "keyboard" then
				-- local button_index = Keyboard.button_index(new_key)
				-- button_locale_name = Keyboard.button_locale_name(button_index)
			-- elseif device == "mouse" then
				-- button_locale_name = string.format("%s %s", "mouse", new_key)
			-- elseif device == "gamepad" then
				-- local button_index = Pad1.button_index(new_key)
				-- button_locale_name = Pad1.button_locale_name(button_index) ~= "" or new_key
			-- end
			--EchoConsole(button_locale_name)
			content.device = device
			if device ~= "mouse" then button_locale_name = new_key end
			content.selected_key = button_locale_name
			options_view.changed_user_settings[content.name] = button_locale_name
			me.widgets.on_change(content, button_locale_name)
			--me.keybind.init(content.name, content.selected_key)
			if content.modifier then
				local child = content.modifier.content
				me.keybind.init(content.name, button_locale_name, device, child.options_values[child.current_selection], 
					content.folder, content.script)
			end
		end
	end
	
	-- ##### Set references ###########################################################################################
	definition.content.hotspot.parent = definition.content
	definition.content.hotspot.disable_button = false
	definition.content.highlight_hotspot.parent = definition.content
	definition.content.highlight_hotspot.disable_button = false
	
	-- ##### Style #####
	definition.style.text.localize = false

	return definition
end

-- ####################################################################################################################
-- ##### Keybind Widget ###############################################################################################
-- ####################################################################################################################
--[[
	Create modifier sub widget
--]]
OptionsInjector.keybind.modifier = function(widget, modifiers)
	local EXPERIMENTAL = true

	if EXPERIMENTAL then
		-- Options
		local options = {
			{text = "None", value = 1},
			{text = "Ctrl", value = 2},
			{text = "Shift", value = 3},
			{text = "Alt", value = 4},
			{text = "Ctrl+Shift", value = 5},
			{text = "Ctrl+Alt", value = 6},
			{text = "Shift+Alt", value = 7},
		}
		-- Change widget
		local base_offset_x = 1007
		local base_size_x = 1107
		widget.style.size[1] = base_size_x
		widget.style.highlight_texture.size[1] = base_size_x
		if widget.style.selected_key then widget.style.selected_key.offset[1] = base_offset_x + 15 end
		if widget.style.selected_rect then widget.style.selected_rect.offset[1] = base_offset_x end
		-- Create dropdown modifier widget
		local drop_down = me.widgets.drop_down("+", options, modifiers, nil, widget.content.name .. "_modifiers")
		drop_down.skip_visible = true
		drop_down.parent_widget = widget
		drop_down.content.parent_widget = widget
		local base_offset_x = 1107
		drop_down.style.offset[1] = base_offset_x
		drop_down.style.offset[3] = 999
		drop_down.style.text.offset[1] = base_offset_x
		drop_down.style.frame.offset[1] = base_offset_x + 40
		drop_down.style.frame.size[1] = 150
		drop_down.style.selected_option.offset[1] = base_offset_x + 45
		drop_down.style.arrow.offset[1] = base_offset_x + 165
		drop_down.style.size[1] = 200
		drop_down.style.list_style.offset[1] = base_offset_x + 42
		for _, style in pairs(drop_down.style.list_style.item_styles) do
			style.size[1] = 148
		end
		drop_down.style.highlight_texture.offset[1] = base_offset_x
		drop_down.style.highlight_texture.size[1] = 200
		drop_down.style.selected_bg.offset[1] = base_offset_x + 44
		drop_down.style.selected_bg.size[1] = 120
		drop_down.style.disabled_texture.offset[1] = base_offset_x + 120
		drop_down.style.disabled_texture.size[1] = 150
		
		drop_down.content.callback = function(content)
			local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
			options_view.changed_user_settings[content.name] = content.options_values[content.current_selection]
			me.widgets.on_change(content, content.options_values[content.current_selection])
			
			local parent = content.parent_widget.content
			me.keybind.init(parent.name, parent.selected_key, parent.device, content.options_values[content.current_selection],
				parent.folder, parent.script)
		end
		
		drop_down.content.saved_value_cb = function(widget)
			for i=1, #widget.content.options_texts do
				if widget.content.options_values[i] == get(widget.content.name) then
					widget.content.current_selection = i
				end
			end
			me.widgets.on_change(widget.content, widget.content.options_values[widget.content.current_selection])
			
			local parent = widget.content.parent_widget.content
			me.keybind.init(parent.name, parent.selected_key, parent.device, widget.content.options_values[widget.content.current_selection],
				parent.folder, parent.script)
		end
		
		widget.content.modifier = drop_down
		
		me.add_to_cache(drop_down)
	else
		-- Options
		-- local options = {
			-- {text = "None", value = 1},
			-- {text = "Ctrl", value = 1},
			-- {text = "Shift", value = 2},
			-- {text = "Ctrl+Shift", value = 3},
			-- {text = "Alt", value = 4},
			-- {text = "Ctrl+Alt", value = 5},
			-- {text = "Shift+Alt", value = 6},
		-- }
		--local drop_down = me.widgets.drop_down("Modifiers", table.clone(modifier_list), 1, "lol", widget.content.name .. "_modifiers")
		--me.add_to_cache(drop_down)
	end
	
end
--[[
	Convert modifiers to a string list
--]]
OptionsInjector.keybind.convert_modifiers = function(value)
	local list = {}
	if value == 2 then
		list[#list+1] = "left ctrl"
	elseif value == 3 then
		list[#list+1] = "left shift"
	elseif value == 4 then
		list[#list+1] = "left alt"
	elseif value == 5 then
		list[#list+1] = "left ctrl"
		list[#list+1] = "left shift"
	elseif value == 6 then
		list[#list+1] = "left ctrl"
		list[#list+1] = "left alt"
	elseif value == 7 then
		list[#list+1] = "left shift"
		list[#list+1] = "left alt"
	end
	return list
end
--[[
	Get readable key name
--]]
OptionsInjector.keybind.key_name = function(device, new_key)
	if device == "keyboard" then
		local button_index = Keyboard.button_index(new_key)
		return Keyboard.button_locale_name(button_index)
	elseif device == "mouse" then
		return string.format("%s %s", "mouse", new_key)
	elseif device == "gamepad" then
		local button_index = Pad1.button_index(new_key)
		return Pad1.button_locale_name(button_index) ~= "" or new_key
	end
	return ""
end
--[[
	Link mod key map to options_view
--]]
OptionsInjector.keybind.link_keymap = function()
	local options_view = Managers.player.network_manager.matchmaking_manager.matchmaking_ui.ingame_ui.views.options_view
	options_view.session_keymaps.ModsKeyMap = ModsKeyMap
end
--[[
	Create input
--]]
OptionsInjector.keybind.init = function(name, key, device, modifiers, folder, script)
	local key = string.lower(key)
	
	-- Add to keymap
	if string.find(key, "mouse") then
		local mouse_key = string.sub(key, 7)
		ModsKeyMap.win32[name] = {"mouse", mouse_key, "pressed"}
	elseif device == "mouse" then
		ModsKeyMap.win32[name] = {"mouse", key, "pressed"}
	else
		ModsKeyMap.win32[name] = {"keyboard", key, "pressed"}
	end
	Managers.input.stored_keymaps_data["ModsKeyMap"] = nil
	Managers.input.add_keymaps_data(Managers.input, ModsKeyMap, "ModsKeyMap")

	-- Add to settings
	local keys = me.keybind.convert_modifiers(modifiers)
	keys[#keys+1] = name
	
	Mods.keyboard.add(keys, folder, script)
end

-- ####################################################################################################################
-- ##### Mod Settings Button ##########################################################################################
-- ####################################################################################################################
OptionsInjector.create_mod_settings_button = function(options_view)

	-- We use a global for this because it needs to stay the same even if the mods are reloaded.
	local orig_title_buttons_n = rawget(_G, "_oi_orig_title_buttons_n")
	if not orig_title_buttons_n then
	    orig_title_buttons_n = options_view.title_buttons_n
	    rawset(_G, "_oi_orig_title_buttons_n", orig_title_buttons_n)
	end
	
	local title_buttons_n = orig_title_buttons_n + 1
	options_view.title_buttons_n = title_buttons_n

	options_view.settings_lists.mod_settings = {
		widgets = {},
		visible_widgets_n = 0,
		widgets_n = 0,
		scenegraph_id_start = "mod_settings_liststart",
		scrollbar = false,
		scenegraph_id = "mod_settings_list",
		max_offset_y = -762,
	}

	-- Currently there is always an unused scenegraph id we can use for the "Mod Settings" button,
	-- but if that ever changes we will need to rethink this.
	local button_scenegraph_id = "settings_button_" .. title_buttons_n
	assert(options_view.ui_scenegraph[button_scenegraph_id], "No spare scenegraph node for mod settings button")

	if #options_view.title_buttons == title_buttons_n then table.remove(options_view.title_buttons, title_buttons_n) end
	local definition = UIWidget.init(UIWidgets.create_menu_button("settings_view_mod", button_scenegraph_id, 25, true))
	definition.content.button_hotspot = {
		disable_button = false,
		parent = {},
	}
	definition.content.button_hotspot.parent = definition.content
	definition.style.text_disabled.localize = false
	definition.style.text_click.localize = false
	definition.style.text_hover.localize = false
	definition.style.text_selected.localize = false
	definition.style.text.localize = false
	definition.animations = table.clone(options_view.title_buttons[6].animations)
	definition.content.text_field = "Mod Settings"
	options_view.title_buttons[title_buttons_n] = definition

	rawset(options_view.ui_scenegraph, "mod_settings_list", "")
	options_view.ui_scenegraph.mod_settings_list = {
		position = {0, 0, -1},
		children = {},
		parent = "list_mask",
		vertical_alignment = "top",
		num_children = 1,
		offset = {0, 0, 0},
		world_position = {1199, 80, 515},
		size = {840, 1150},
		horizontal_alignment = "center",
		local_position = {0, 0, -1},
		name = "mod_settings_list",
	}

	rawset(options_view.ui_scenegraph, "mod_settings_liststart", "")
	options_view.ui_scenegraph.mod_settings_liststart = {
		world_position = {1229, 80, 525},
		horizontal_alignment = "left",
		position = {-220, 0, 10},
		local_position = {-220, 0, 10},
		name = "mod_settings_liststart",
		size = {1, 1},
		parent = "mod_settings_list",
		vertical_alignment = "top",
	}

	options_view.ui_scenegraph.mod_settings_list.children[1] = options_view.ui_scenegraph.mod_settings_liststart
	options_view.ui_scenegraph.list_mask.children[10] = options_view.ui_scenegraph.mod_settings_list
	options_view.ui_scenegraph.list_mask.num_children = 10

	if not table.has_item(SettingsMenuNavigation, "mod_settings") then
		SettingsMenuNavigation[#SettingsMenuNavigation+1] = "mod_settings"
	end
end

-- ####################################################################################################################
-- ##### Create widget based on settings ##############################################################################
-- ####################################################################################################################
OptionsInjector.CreateWidget = function(setting)
	if setting and setting.widget_type then
		local value = get(setting.save)
		
		if setting.widget_type == "stepper" then -- Stepper
			-- Check save data
			if type(value) ~= setting.value_type then
				set(setting.save, setting.options[setting.default].value)
				save()
			end
			
			-- Create widget
			local new_stepper_widget = me.CreateStepperWidget(setting.save, setting.text, setting.options, setting.default, setting.tooltip, setting.hide_options)
			if setting.disabled_outside_inn ~= nil then new_stepper_widget.content.disabled_outside_inn = setting.disabled_outside_inn end
			return new_stepper_widget
		elseif setting.widget_type == "slider" then -- Slider
			-- Check save data
			if type(value) ~= "number" or value < setting.range[1] or value > setting.range[2] then
				set(setting.save, setting.default)	
				save()
			end
			
			-- Create widget
			return me.CreateSliderWidget(setting.save, setting.text, setting.tooltip, setting.range, setting.default)
		elseif setting.widget_type == "checkbox" then -- CheckBox
			-- Check user setting
			if type(value) ~= "boolean" then
				set(setting.save, setting.default)
				save()
			end
			
			-- Create widget
			return me.CreateCheckBoxWidget(setting.save, setting.text, setting.default,
				setting.hide_options, setting.dynamic, setting.tooltip)
		elseif setting.widget_type == "dropdown_checkbox" then -- Dropdown checkBox
			-- Check user setting
			if type(value) ~= "boolean" then
				set(setting.save, setting.default)
				save()
			end
			
			-- Create widget
			return me.CreateDropDownCheckBoxWidget(setting.save, setting.text, setting.default,
				setting.hide_options, setting.dynamic, setting.tooltip)
		elseif setting.widget_type == "dropdown" then -- DropDown
			-- Check user setting
			if type(value) ~= setting.value_type then
				set(setting.save, setting.options[setting.default].value)
				save()
			end
			
			-- Create widget
			return me.CreateDropDownWidget(setting.save, setting.text, setting.options, setting.default, setting.tooltip, setting.hide_options)
		elseif setting.widget_type == "keybind" then -- Keybind
			
			return me.CreateKeybindWidget(setting.save, setting.text,
				get(setting.save) or setting.default[1], setting.default[1],
				get(setting.save .. "_modifiers") or setting.default[2],
				setting.exec[1], setting.exec[2])
		elseif setting.widget_type == "modless_keybind" then -- Keybind without modifier/executed file
			
			return me.add_to_cache(me.widgets.keybind(setting.save, setting.text, get(setting.save) or setting.default[1], setting.default[1]))
		end
	else
		EchoConsole("setting or setting.widget_type missing")
	end
end