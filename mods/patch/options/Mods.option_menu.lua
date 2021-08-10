local template_group_widget = {
	["save"] = "cb_unknown",
	["widget_type"] = "dropdown_checkbox",
	["text"] = "<Unknown>",
	["default"] = false,
	["hide_options"] = {
		{
			true,
			mode = "show",
			options = {},
		},
		{
			false,
			mode = "hide",
			options = {},
		},
	},
}

Mods.option_menu = {
	_groups = {},
	_conf = {},
	
	--[[
		Create Group
		
		This allows you to create group and item options.
		The group option is always a check box that show/hide all items.
	]]--
	add_group = function(self, id, text)
		if self:_get_group(id) == nil then
			table.insert(self._groups, {id = id, text = text, hide_options = {}})
		end
	end,
	
	add_item = function(self, group_id, setting, hide_option)
		-- Check settings exist
		if not self._conf[group_id] then
			self._conf[group_id] = {}
		end
		
		-- Insert new settings in group
		table.insert(self._conf[group_id], setting)
		
		-- Show and hide influence
		if hide_option then
			local group = self:_get_group(group_id)
			if not group then
				self:add_group(group_id, group_id)
				group = self:_get_group(group_id)
			end
			table.insert(group.hide_options, setting.save)
		end
	end,
	
	_get_group = function(self, id)
		for _, group in ipairs(self._groups) do
			if group.id == id then
				return group
			end
		end
	end,
	
	--[[
		Draw the option menu
	]]--
	draw = function(self)
		local oi = OptionsInjector
		
		for _, group in ipairs(self._groups) do
			group.setting = table.clone(template_group_widget)
			group.setting.save = "cb_" .. group.id
			group.setting.text = group.text
			
			if self._conf[group.id] then
				-- Create widget
				oi.CreateWidget(group.setting)
				for _, setting in ipairs(self._conf[group.id]) do
					if setting.save ~= group.setting.save then
						-- Create widget
						local widget = oi.CreateWidget(setting)
						
						if setting.cursor_offset then
							widget.style.tooltip_text.cursor_offset = table.clone(setting.cursor_offset)
						end
					else
						EchoConsole("menu_option error: group save name is same as item save name.")
						EchoConsole("Change \'" .. setting.save .. "\' to a different name.")
					end
				end
				-- Draw Seperator
				Mods.exec("patch/options", "insert_option_seperator")
			end
			
			-- set show/hide settings
			group.setting.hide_options[1].options = group.hide_options
			group.setting.hide_options[2].options = group.hide_options
			

		end
	end,
}