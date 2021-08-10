local mod_name = "TrueflightTweaks"
--[[
	authors: walterr

	Tweaks for the Trueflight Bow.
--]]

local user_setting = Application.user_setting

local MOD_SETTINGS = {
	FORCE_LOCK_OUTLINE = {
		save = "cb_tf_tweaks_force_lock_outline",
		widget_type = "stepper",
		text = "Prioritize Red Outline Over Blue Outline",
		tooltip = "Prioritize Red Outline Over Blue Outline\n" ..
			"If the Trueflight Bow has a target-lock on an enemy that is also pinged, give the enemy " ..
			"a red outline not a blue one. Also works for the Bolt Staff.",
		value_type = "boolean",
		options = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		default = 1, -- Default second option is enabled. In this case Off
	},
	STICKY_ZOOM = {
		save = "cb_tf_tweaks_sticky_zoom",
		widget_type = "stepper",
		text = "Remember Zoom Setting",
		tooltip = "Remember Zoom Setting\n" ..
			"Makes the Trueflight Bow remember its current zoom setting: instead of needing to " ..
			"manually zoom in each time, after zooming in once the bow will keep zooming in on every " ..
			"charged attack until you manually zoom out again. Also works for the Hawk Eye trait.",
		value_type = "boolean",
		options = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		default = 1, -- Default second option is enabled. In this case Off
	},
	BOLT_STAFF_HIDE_HANDS = {
		save = "cb_tf_tweaks_bolt_staff_hide_hands",
		widget_type = "stepper",
		text = "Hide Hands When Charging Bolt Staff",
		tooltip = "Hide Hands When Charging Bolt Staff\n" ..
			"In the Bolt Staff charging animation, make the Bright Wizard's hands disappear briefly " ..
			"when they would otherwise block line of sight.",
		value_type = "boolean",
		options = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		default = 1, -- Default second option is enabled. In this case Off
	},
}

-- Enables or disables the red outline. We don't actually need to do this, OutlineSystem.update would
-- do it eventually, but there is a brief random delay before it does, and this avoids that.
local function set_outline_immediately(unit, outline_extn, enable)
	local outline_system = Managers.state.entity:system("outline_system")
	local c = outline_extn.outline_color.channel
	local channel = Color(c[1], c[2], c[3], c[4])
	outline_system:outline_unit(unit, outline_extn.flag, channel, enable, outline_extn.apply_method, false)
	outline_extn[(enable and "outlined") or "reapply"] = true
end

-- Stores the current zoom of the given action, if it has changed, so it can be reapplied
-- automatically later.
local function remember_zoom(action)
	if user_setting(MOD_SETTINGS.STICKY_ZOOM.save) then
		local zoom_condition_function = action.zoom_condition_function
		if not zoom_condition_function or zoom_condition_function() then
			local owner_unit = action.owner_unit
			if ScriptUnit.extension(owner_unit, "input_system"):get("action_three") then
				local status_extn = ScriptUnit.extension(owner_unit, "status_system")
				if status_extn:is_zooming() then
					if not action.current_action.orig_default_zoom then
						action.current_action.orig_default_zoom = action.current_action.default_zoom
					end
					action.current_action.default_zoom = status_extn.zoom_mode
				end
			end
		end
	else
		if action.current_action.orig_default_zoom then
			action.current_action.default_zoom = action.current_action.orig_default_zoom
		end
	end
end

-- Wraps the given extension's set_pinged function in a function that checks the
-- _tftweak_override_ping variable and only calls the real set_pinged if it's false.
local function wrap_set_pinged(outline_extn)
	local real_set_pinged = outline_extn.set_pinged

	outline_extn.set_pinged = function (pinged)
		if outline_extn._tftweak_override_ping then
			if pinged then
				if not outline_extn.pinged then
					outline_extn.previous_flag = outline_extn.flag
				end
				outline_extn.flag = "outline_unit"
			else
				outline_extn.flag = outline_extn.previous_flag
			end
			outline_extn.pinged = pinged
		else
			real_set_pinged(pinged)
		end
	end
end

local function set_hand_hidden(player_unit, hidden)
	local first_person_extn = ScriptUnit.extension(player_unit, "first_person_system")
	Unit.set_unit_visibility(first_person_extn.first_person_attachment_unit, not hidden)
end

Mods.hook.set(mod_name, "ActionTrueFlightBowAim.client_owner_post_update", function(orig_func, self, ...)
	local old_target = self.target
	orig_func(self, ...)
	local new_target = self.target

	-- If the target has changed, set _tftweak_override_ping on the new target (if any) to cause the
	-- red outline to be prioritized over the blue, also remove _tftweak_override_ping from the old
	-- target (if any).
	if new_target ~= old_target and user_setting(MOD_SETTINGS.FORCE_LOCK_OUTLINE.save) then
		local outline_extn = new_target and ScriptUnit.has_extension(new_target, "outline_system")
		if outline_extn and outline_extn.method == "always" then
			if outline_extn._tftweak_override_ping == nil then
				wrap_set_pinged(outline_extn)
			end
			outline_extn._tftweak_override_ping = true
			set_outline_immediately(new_target, outline_extn, true)
		end
		outline_extn = old_target and ScriptUnit.has_extension(old_target, "outline_system")
		if outline_extn then
			outline_extn._tftweak_override_ping = false
			set_outline_immediately(old_target, outline_extn, false)
		end
	end

	-- Check whether the zoom level has changed and if so record its new value.
	remember_zoom(self)

	-- If this is the Bolt Staff, hide the BW's hands for part of the charging animation so the
	-- left hand doesn't block line of sight.
	if self.current_action.anim_event == "attack_charge_spear" and user_setting(MOD_SETTINGS.BOLT_STAFF_HIDE_HANDS.save) then
		local charge_value = self.charge_value
		local should_hide_hand = (0.25 < charge_value) and (charge_value < 0.95)
		local is_third_person_mod = Mods.ThirdPerson and Mods.ThirdPerson.SETTINGS and Mods.ThirdPerson.SETTINGS.ACTIVE and Mods.ThirdPerson.SETTINGS.ACTIVE.save and user_setting(Mods.ThirdPerson.SETTINGS.ACTIVE.save)

		if should_hide_hand and not self._tftweak_hidden and not is_third_person_mod then
			set_hand_hidden(self.owner_unit, true)
			self._tftweak_hidden = true

		elseif not should_hide_hand and self._tftweak_hidden and not is_third_person_mod then
			set_hand_hidden(self.owner_unit, false)
			self._tftweak_hidden = false
		end
	end
end)

Mods.hook.set(mod_name, "ActionTrueFlightBowAim.finish", function(orig_func, self, ...)
	if user_setting(MOD_SETTINGS.FORCE_LOCK_OUTLINE.save) then
		local outline_extn = self.target and ScriptUnit.has_extension(self.target, "outline_system")
		if outline_extn then
			-- Tidy up.
			outline_extn._tftweak_override_ping = false
			outline_extn.reapply = true
		end
	end
	if self._tftweak_hidden then
		local is_third_person_mod = Mods.ThirdPerson and Mods.ThirdPerson.SETTINGS and Mods.ThirdPerson.SETTINGS.ACTIVE and Mods.ThirdPerson.SETTINGS.ACTIVE.save and user_setting(Mods.ThirdPerson.SETTINGS.ACTIVE.save)
		if not is_third_person_mod then
			set_hand_hidden(self.owner_unit, false)
			self._tftweak_hidden = false
		end
	end

	return orig_func(self, ...)
end)

Mods.hook.set(mod_name, "ActionAim.client_owner_post_update", function(orig_func, self, ...)
	orig_func(self, ...)
	remember_zoom(self)
end)

Mods.hook.set(mod_name, "ActionBeam.client_owner_start_action", function(orig_func, self, new_action, ...)
	orig_func(self, new_action, ...)

	-- ActionBeam doesn't use 'default_zoom' so do it ourselves.
	local default_zoom = new_action.default_zoom
	if default_zoom then
		local status_extn = ScriptUnit.extension(self.owner_unit, "status_system")
		if default_zoom ~= status_extn.zoom_mode then
			status_extn:set_zooming(true, default_zoom)
		end
	end
end)

Mods.hook.set(mod_name, "ActionBeam.client_owner_post_update", function(orig_func, self, ...)
	orig_func(self, ...)
	remember_zoom(self)
end)

-- Replace OutlineSystem.update with a modified version of the original code which prioritizes the
-- target-lock outline over the pinged outline (unfortunately I can't see any good way to do this by
-- just hooking the function.
OutlineSystem.update = function (self, context, t)
	if #self.units == 0 then
		return
	end

	if script_data.disable_outlines then
		return
	end

	local checks_per_frame = 4
	local current_index = self.current_index
	local units = self.units

	for i = 1, checks_per_frame, 1 do
		current_index = current_index + 1

		if not units[current_index] then
			current_index = 1
		end

		local unit = self.units[current_index]
		local extension = self.unit_extension_data[unit]

		if extension or false then
			local is_pinged = extension.pinged
			-- This is the modified code (the next three lines were added).
			if is_pinged and extension._tftweak_override_ping and self[extension.method](self, unit, extension) then
				is_pinged = false
			end
			local method = (is_pinged and extension.pinged_method) or extension.method

			if self[method](self, unit, extension) then
				if not extension.outlined or extension.new_color or extension.reapply then
					local c = (is_pinged and OutlineSettings.colors.player_attention.channel) or extension.outline_color.channel
					local channel = Color(c[1], c[2], c[3], c[4])

					self.outline_unit(self, unit, extension.flag, channel, true, extension.apply_method, extension.reapply)

					extension.outlined = true
				end
			elseif extension.outlined or extension.new_color or extension.reapply then
				local c = extension.outline_color.channel
				local channel = Color(c[1], c[2], c[3], c[4])

				self.outline_unit(self, unit, extension.flag, channel, false, extension.apply_method, extension.reapply)

				extension.outlined = false
			end

			extension.new_color = false
			extension.reapply = false
		end
	end

	self.current_index = current_index
end

local function create_options()
	local setting_group = "trueflight_tweaks"
	Mods.option_menu:add_group(setting_group, "Trueflight Tweaks")
	Mods.option_menu:add_item(setting_group, MOD_SETTINGS.FORCE_LOCK_OUTLINE, true)
	Mods.option_menu:add_item(setting_group, MOD_SETTINGS.STICKY_ZOOM, true)
	Mods.option_menu:add_item(setting_group, MOD_SETTINGS.BOLT_STAFF_HIDE_HANDS, true)
end

create_options()
