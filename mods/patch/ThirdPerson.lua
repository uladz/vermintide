--[[ 
	Third person mode
		- Does the necessary positioning of the camera
		- Applies different fixes to certain situations
	
	Author: grasmann
--]]
local mod_name = "ThirdPerson"

local oi = OptionsInjector

Mods.ThirdPerson = {

	reset = true,

	firstperson = {
		unit = false,
		value = false,
	},
	
	offset = { x = 0.6, y = -0.8, z = 0.1 },
	
	zoom = {
		default = { default = 30, medium = 40, low = 50, off = 65, },
		increased = { default = 16, medium = 30, low = 45, off = 65, },
	},

	reload = {
		reloading = {},
		extended = {},
		is_reloading = function(self, unit)
			if self.reloading[unit] and self.t then
				if self.reloading[unit].start_time + self.reloading[unit].reload_time > self.t then
					return true
				end
			end
			return false
		end
	},
	
	SETTINGS = {
		ACTIVE = {
			["save"] = "cb_third_person_active",
			["widget_type"] = "stepper",
			["text"] = "Active",
			["tooltip"] =  "Third Person\n" ..
				"Toggle third person on / off.\n\n" ..
				"Play the game in first or third person.",
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
						"cb_third_person_side",
						"cb_third_person_offset",
						"cb_third_person_reload_animation_fix",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_third_person_side",
						"cb_third_person_offset",
						"cb_third_person_reload_animation_fix",
					}
				},
			},
		},
		SIDE = {
			["save"] = "cb_third_person_side",
			["widget_type"] = "stepper",
			["text"] = "Side",
			["tooltip"] = "Third Person Side\n" ..
				"Toggle side for third person left and right.\n\n" ..
				"Choose if the camera is to left or right of your character.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Left", value = false},
				{text = "Right", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Left
		},
		OFFSET = {
			["save"] = "cb_third_person_offset",
			["widget_type"] = "slider",
			["text"] = "Offset",
			["tooltip"] = "Third Person Offset\n" ..
				"Set camera offset for third person.\n\n" ..
				"Change the distance between the camera and the character.",
			["range"] = {50, 400},
			["default"] = 100,
		},
		RELOAD_ANIMATION_FIX = {
			["save"] = "cb_third_person_reload_animation_fix",
			["widget_type"] = "stepper",
			["text"] = "3rd Person Reload Animation",
			["tooltip"] = "3rd Person Reload Animation\n" ..
				"Toggle 3rd person reload animation off or on.\n\n" ..
				"Plays your 3rd person reload animation if you're a client.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1,
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_third_person_reload_stop_when_finished",
						"cb_third_person_extend_too_short",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_third_person_reload_stop_when_finished",
						"cb_third_person_extend_too_short",
					}
				},
			},
		},
		RELOAD_STOP_WHEN_FINISHED = {
			["save"] = "cb_third_person_reload_stop_when_finished",
			["widget_type"] = "stepper",
			["text"] = "Stop Reload When Finished",
			["tooltip"] = "Stop Reload When Finished\n" ..
				"Toggle stop reload when finished off or on.\n\n" ..
				"The first- and third person animations can differ a lot.\n" ..
				"Especially the reload animation for ranged weapons.\n" ..
				"Stops third person reload animation after the correct time.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1,
		},
		RELOAD_EXTEND_TOO_SHORT = {
			["save"] = "cb_third_person_extend_too_short",
			["widget_type"] = "stepper",
			["text"] = "Extend Short Animations",
			["tooltip"] = "Extend short Animations\n" ..
				"Toggle extend short animations off or on.\n\n" ..
				"The first- and third person animations can differ a lot.\n" ..
				"Especially the reload animation for ranged weapons.\n" ..
				"Repeats third person reload animation if too short.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1,
		},
		HK_TOGGLE = {
			["save"] = "cb_third_person_hotkey_toggle",
			["widget_type"] = "keybind",
			["text"] = "Toggle On / Off",
			["default"] = {
				"mouse_middle",
				oi.key_modifiers.CTRL,
			},
			["exec"] = {"patch/action", "third_person"},
		},
		HK_SIDE = {
			["save"] = "cb_third_person_hotkey_side",
			["widget_type"] = "keybind",
			["text"] = "Toggle Left / Right",
			["default"] = {
				"mouse_middle",
				oi.key_modifiers.ALT,
			},
			["exec"] = {"patch/action", "third_person_side"},
		},
		HK_OFFSET = {
			["save"] = "cb_third_person_hotkey_offset",
			["widget_type"] = "keybind",
			["text"] = "Change Offset",
			["default"] = {
				"mouse_middle",
				oi.key_modifiers.SHIFT,
			},
			["exec"] = {"patch/action", "third_person_offset"},
		},
		HK_ZOOM = {
			["save"] = "cb_third_person_hotkey_zoom",
			["widget_type"] = "keybind",
			["text"] = "Change Zoom",
			["default"] = {
				"mouse_middle",
				oi.key_modifiers.CTRL_SHIFT,
			},
			["exec"] = {"patch/action", "third_person_zoom"},
		},
		ZOOM = {
			["save"] = "cb_third_person_zoom",
			["widget_type"] = "dropdown",
			["text"] = "Aim Down Sight Zoom",
			["tooltip"] = "Aim Down Sight Zoom\n" ..
				"Set camera zoom for aiming down the sights.\n\n" ..
				"This option is active in first person as well.",
			["value_type"] = "number",
			["options"] = {
				{text = "Default", value = 1},
				{text = "Medium", value = 2},
				{text = "Low", value = 3},
				{text = "Off", value = 4},
			},
			["default"] = 1, -- Default first option is enabled. In this case Default
		},
		HK_ZOOM_B = {
			["save"] = "cb_third_person_hotkey_zoom_behaviour",
			["widget_type"] = "stepper",
			["text"] = "Zoom Hotkey Behaviour",
			["tooltip"] = "Zoom Hotkey Behaviour\n" ..
				"Set the behaviour of the \"Change Zoom\" hotkey.\n\n" ..
				"4 Settings will have the hotkey going through all possible zoom settings.\n\n" ..
				"2 Settings will have the hotkey only switch between default and no zoom.",
			["value_type"] = "number",
			["options"] = {
				{text = "4 Settings", value = 4},
				{text = "2 Settings", value = 2},
			},
			["default"] = 1,
		},
	},
}
local me = Mods.ThirdPerson

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ####################################################################################################################
-- ##### Option #######################################################################################################
-- ####################################################################################################################
Mods.ThirdPerson.create_options = function()
	Mods.option_menu:add_group("third_person", "Third Person")
	
	Mods.option_menu:add_item("third_person", me.SETTINGS.ACTIVE, true)
	Mods.option_menu:add_item("third_person", me.SETTINGS.SIDE)
	Mods.option_menu:add_item("third_person", me.SETTINGS.OFFSET)
	Mods.option_menu:add_item("third_person", me.SETTINGS.RELOAD_ANIMATION_FIX)
	Mods.option_menu:add_item("third_person", me.SETTINGS.RELOAD_STOP_WHEN_FINISHED)
	Mods.option_menu:add_item("third_person", me.SETTINGS.RELOAD_EXTEND_TOO_SHORT)
	Mods.option_menu:add_item("third_person", me.SETTINGS.HK_TOGGLE, true)
	Mods.option_menu:add_item("third_person", me.SETTINGS.HK_SIDE, true)
	Mods.option_menu:add_item("third_person", me.SETTINGS.HK_OFFSET, true)
	Mods.option_menu:add_item("third_person", me.SETTINGS.HK_ZOOM, true)
	Mods.option_menu:add_item("third_person", me.SETTINGS.ZOOM, true)
	Mods.option_menu:add_item("third_person", me.SETTINGS.HK_ZOOM_B, true)
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################
--[[
	Fix to make mission objectives visible in third person
--]]
Mods.hook.set(mod_name, "TutorialUI.update", function(func, self, ...)
	if get(me.SETTINGS.ACTIVE) then
		if self._first_person_extension then self._first_person_extension.first_person_mode = true end
		func(self, ...)
		if self._first_person_extension then self._first_person_extension.first_person_mode = me.firstperson.value end
	else
		func(self, ...)
	end
end)
--[[
	MAIN FUNCTION - Camera positioning
--]]
Mods.hook.set(mod_name, "CameraManager.post_update", function(func, self, dt, t, viewport_name)
	
	-- ##### Original function ########################################################################################
	func(self, dt, t, viewport_name)			
	
	-- ##### Get data #############################################################################################
		local viewport = ScriptWorld.viewport(self._world, viewport_name)
		local camera = ScriptViewport.camera(viewport)
		local shadow_cull_camera = ScriptViewport.shadow_cull_camera(viewport)
		local camera_nodes = self._camera_nodes[viewport_name]
		local current_node = self._current_node(self, camera_nodes)
		local camera_data = self._update_transition(self, viewport_name, camera_nodes, dt)	
		
		-- ##### Change zoom #####
		me.set_zoom_values(current_node)
	
	if get(me.SETTINGS.ACTIVE) then
		-- ##### Check side ###########################################################################################
		local offset = nil
		local mult = get(me.SETTINGS.OFFSET) / 100
		if mult == nil then mult = 1 end		
		if not get(me.SETTINGS.SIDE) then
			offset = Vector3(me.offset.x, me.offset.y * mult, me.offset.z)
		else
			offset = Vector3(-me.offset.x, me.offset.y * mult, me.offset.z)
		end

		camera_data.position = self._calculate_sequence_event_position(self, camera_data, offset)
	end

		-- ##### Update camera ########################################################################################		
		self._update_camera_properties(self, camera, shadow_cull_camera, current_node, camera_data, viewport_name)
		self._update_sound_listener(self, viewport_name)		
		ScriptCamera.force_update(self._world, camera)	
	
end)
--[[
	Fix to apply camera offset to ranged weapons
--]]
Mods.hook.set(mod_name, "PlayerUnitFirstPerson.current_position", function(func, self)
	if get(me.SETTINGS.ACTIVE) then
		-- ##### Get data #############################################################################################
		local position = Unit.world_position(self.first_person_unit, 0) --+ Vector3(0, 0, 1.5)
		local current_rot = Unit.local_rotation(self.first_person_unit, 0)

		-- ##### Counter offset #######################################################################################
		local offset = {}
		if not get(me.SETTINGS.SIDE) then
			offset = Vector3(me.offset.x, 0, me.offset.z)
		else
			offset = Vector3(-me.offset.x, 0, me.offset.z)
		end
		
		-- ##### Change position ######################################################################################
		local x = offset.x * Quaternion.right(current_rot)
		local y = offset.y * Quaternion.forward(current_rot)
		local z = Vector3(0, 0, offset.z)
		position = position + x + y + z	
		return position
	end
	
	-- ##### Original function ########################################################################################
	return func(self)
end)
--[[
	MAIN FUNCTION - Set first / third person mode - Hide first person ammo
--]]
Mods.hook.set(mod_name, "PlayerUnitFirstPerson.update", function(func, self, unit, input, dt, context, t)
	me.firstperson.unit = self

	if me.reset then
		self.set_first_person_mode(self, not get(me.SETTINGS.ACTIVE))
		me.reset = false
	end
	
	-- ##### Original function ########################################################################################
	func(self, unit, input, dt, context, t)
	
	if not me.is_first_person_blocked(self.unit) then
		if get(me.SETTINGS.ACTIVE) then
			-- ##### Disable first person #############################################################################
			if me.firstperson.value then
				self.set_first_person_mode(self, false)
				me.firstperson.value = false
			end
			
			-- ##### Hide first person ammo ###########################################################################
			local inventory_extension = ScriptUnit.extension(self.unit, "inventory_system")
			local slot_data = inventory_extension.get_slot_data(inventory_extension, "slot_ranged")
			if slot_data then
				if slot_data.right_ammo_unit_1p then Unit.set_unit_visibility(slot_data.right_ammo_unit_1p, false) end
				if slot_data.left_ammo_unit_1p then Unit.set_unit_visibility(slot_data.left_ammo_unit_1p, false) end	
			end
		else
			-- ##### Enable first person ##############################################################################
			if not me.firstperson.value then
				self.set_first_person_mode(self, true)
				me.firstperson.value = true
			end
		end
	end
	
end)

-- ####################################################################################################################
-- ##### Reset ########################################################################################################
-- ####################################################################################################################
--[[
	A game was started
--]]
Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, self)
	func(self)
	me.reset = true
end)
--[[
	A game was actually started ... lol
--]]
Mods.hook.set(mod_name, "StateInGameRunning.event_game_actually_starts", function(func, self)
	func(self)
	me.reset = true
end)
--[[
	Set first person mode for cutscenes
--]]
Mods.hook.set(mod_name, "CutsceneSystem.set_first_person_mode", function(func, self, enabled)
	func(self, enabled)
	
	if enabled then
		me.reset = true
	end
end)

Mods.hook.set(mod_name, "ProfileView.on_exit", function(func, ...)
	func(...)
	
	if get(me.SETTINGS.ACTIVE) then
		me.reset = true
	end
end)

-- ####################################################################################################################
-- ##### Projectiles ##################################################################################################
-- ####################################################################################################################
--[[
	Set zoom values
--]]
Mods.ThirdPerson.set_zoom_values = function(current_node)
	local degrees_to_radians = math.pi/180
	local zoom_fov = 65
	local zoom_setting = get(me.SETTINGS.ZOOM)
	if current_node._name == "zoom_in" then
		if zoom_setting == 2 then
			zoom_fov = me.zoom.default.medium
		elseif zoom_setting == 3 then
			zoom_fov = me.zoom.default.low
		elseif zoom_setting == 4 then
			zoom_fov = me.zoom.default.off
		else
			zoom_fov = me.zoom.default.default
		end
		current_node._vertical_fov = zoom_fov*degrees_to_radians				
	elseif current_node._name == "increased_zoom_in" then
		if zoom_setting == 2 then
			zoom_fov = me.zoom.increased.medium
		elseif zoom_setting == 3 then
			zoom_fov = me.zoom.increased.low
		elseif zoom_setting == 4 then
			zoom_fov = me.zoom.increased.off
		else
			zoom_fov = me.zoom.increased.default
		end
		current_node._vertical_fov = zoom_fov*degrees_to_radians
	end	
end
--[[
	Check if first person is blocked
--]]
Mods.ThirdPerson.is_first_person_blocked = function(unit)
	local blocked = false
	local state_system = ScriptUnit.extension(unit, "character_state_machine_system")
	if state_system ~= nil then
		blocked = blocked or state_system.state_machine.state_current.name == "dead"
		blocked = blocked or state_system.state_machine.state_current.name == "grabbed_by_pack_master"
		blocked = blocked or state_system.state_machine.state_current.name == "inspecting"
		blocked = blocked or state_system.state_machine.state_current.name == "interacting"
		blocked = blocked or state_system.state_machine.state_current.name == "knocked_down"
		--blocked = blocked or state_system.state_machine.state_current.name == "leave_ledge_hanging_falling"
		--blocked = blocked or state_system.state_machine.state_current.name == "leave_ledge_hanging_pull_up"
		blocked = blocked or state_system.state_machine.state_current.name == "ledge_hanging"
		blocked = blocked or state_system.state_machine.state_current.name == "pounced_down"
		blocked = blocked or state_system.state_machine.state_current.name == "waiting_for_assisted_respawn"
	end
	return blocked
end

-- ####################################################################################################################
-- ##### Reload #######################################################################################################
-- ####################################################################################################################
--[[
	Play third person animation for yourself
--]]
Mods.hook.set(mod_name, "GenericAmmoUserExtension.start_reload_animation", function(func, self, reload_time)
	func(self, reload_time)
	if get(me.SETTINGS.RELOAD_ANIMATION_FIX) and self.reload_event then
		-- Play 3rd person animation
		Unit.animation_event(self.owner_unit, self.reload_event)
		-- Set reloading
		me.reload.reloading[self.owner_unit] = {
			reload_time = reload_time,
			start_time = me.reload.t,
			event = self.reload_event,
		}
	end
end)
--[[
	Check to disable animation when reloading is done
--]]
Mods.hook.set(mod_name, "GenericAmmoUserExtension.update", function(func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)
	me.reload.t = t
	if get(me.SETTINGS.RELOAD_ANIMATION_FIX) and me.reload.reloading[self.owner_unit] then
		if not me.reload:is_reloading(self.owner_unit) then
			if get(me.SETTINGS.RELOAD_STOP_WHEN_FINISHED) then
				local inventory_extension = ScriptUnit.extension(self.owner_unit, "inventory_system")
				local slot_data = inventory_extension.get_slot_data(inventory_extension, "slot_ranged")
				local item_template = BackendUtils.get_item_template(slot_data.item_data)
				local wield_anim = item_template.wield_anim
				if self.available_ammo <= 0 then
					wield_anim = item_template.wield_anim_no_ammo
				end
				CharacterStateHelper.play_animation_event(self.owner_unit, item_template.wield_anim)
			end
			me.reload.reloading[self.owner_unit] = nil
			me.reload.extended[self.owner_unit] = nil
		elseif not me.reload.extended[self.owner_unit] and get(me.SETTINGS.RELOAD_EXTEND_TOO_SHORT) then
			local t, length = Unit.animation_layer_info(self.owner_unit, 2)
			if length > me.reload.reloading[self.owner_unit].reload_time then
				-- Reload animation is too short
				CharacterStateHelper.play_animation_event(self.owner_unit, me.reload.reloading[self.owner_unit].event)
				me.reload.extended[self.owner_unit] = true
			end
		end
	end
end)
--[[
	Cancel reload
--]]
Mods.hook.set(mod_name, "GenericAmmoUserExtension.abort_reload", function(func, self)
	func(self)
	if get(me.SETTINGS.RELOAD_ANIMATION_FIX) then
		me.reload.reloading[self.owner_unit] = nil
		me.reload.extended[self.owner_unit] = nil
	end
end)

-- ##### Start ########################################################################################################
me.create_options()