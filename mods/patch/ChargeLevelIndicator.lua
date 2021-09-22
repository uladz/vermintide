--[[
	authors: walterr

	Charge Level Indicator.
	*	When charging the Bolt staff or Fireball staff, a colored marker will be shown on the HUD
		indicating the current 'charge level'.
		The Bolt staff has discrete charge levels, which are shown as: green=1, orange=2, red=3.
		The Fireball staff doesn't have discrete levels and charging just continuously increases
		damage and area, so the levels I've chosen are kind of arbitrary:
		green=(3 <= damage < 5, 0.75 <= area < 2.25), orange=(5 <= damage < 6, 2.25 <= area < 3),
		red=(damage = 6, area = 3). (Where 'damage' means AoE instantaneous damage to normal
		targets, not including impact damage or DoT.)
--]]

local mod_name = "ChargeLevelIndicator"
ChargeLevelIndicator = {}
local mod = ChargeLevelIndicator

mod.anim_state = {
	STARTING = 1,
	ONGOING = 2,
}

mod.widget_settings = {
	-- The charge level indicator is just a rounded rect. The color is set dynamically.
	CHARGE_LEVEL = {
		scenegraph_id = "charge_bar",
		element = {
			passes = {
				{
					pass_type = "rounded_background",
					style_id = "indicator"
				},
			},
		},
		content = {},
		style = {
			indicator = {
				offset = { 230, -45 },
				size = { 48, 48 },
				corner_radius = 3,
			},
		},
	}
}

mod.current_charge_level = {
	color = nil,
	fade_out = nil,
}

-- Defines the charge levels for the staffs.
mod.display_info = {
	-- Fireball staff uses this, ActionCharge is defined in
	-- scripts/unit_extensions/weapons/actions/action_charge.lua
	ActionCharge = {
		levels = {
			{
				min_value = 1,
				color = Colors.get_table("red"),
			},
			{
				min_value = (2/3),
				color = Colors.get_table("orange"),
			},
			{
				min_value = 0,
				color = Colors.get_table("green_yellow"),
			},
		},
	},
	-- Bolt staff uses this, ActionTrueFlightBowAim is defined in
	-- scripts/unit_extensions/weapons/actions/action_true_flight_bow_aim.lua
	ActionTrueFlightBowAim = {
		levels = {
			{
				min_value = 1,
				color = Colors.get_table("red"),
			},
			{
				min_value = (0.8 / 1.25),
				color = Colors.get_table("orange"),
			},
			{
				min_value = 0,
				color = Colors.get_table("yellow_green"),
			},
		},
	},
}

-- ####################################################################################################################
-- ##### Functions ####################################################################################################
-- ####################################################################################################################
mod.display_info.ActionCharge.compute_level_value = function(action)
	if action.overcharge_extension and not action.current_action.vent_overcharge then
		return action.charge_level
	end
	return nil
end
mod.display_info.ActionTrueFlightBowAim.compute_level_value = function(action)
	return (action.overcharge_extension and action.charge_value) or nil
end

local compute_level_color = function(self, charge_value)
	for _, level in ipairs(self.levels) do
		if charge_value >= level.min_value then
			return level.color
		end
	end
	return nil
end
mod.display_info.ActionCharge.compute_level_color = compute_level_color
mod.display_info.ActionTrueFlightBowAim.compute_level_color = compute_level_color

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "ActionCharge.client_owner_post_update", function (func, self, dt, t, ...)
	func(self, dt, t, ...)

	local display_info = mod.display_info["ActionCharge"]
	local charge_value = display_info.compute_level_value(self)
	if charge_value then
		mod.current_charge_level.color = display_info:compute_level_color(charge_value)
		mod.current_charge_level.fade_out = nil
	end
end)

Mods.hook.set(mod_name, "ActionCharge.finish", function (func, self, reason)
	local result = func(self, reason)

	local display_info = mod.display_info["ActionCharge"]
	if reason == "new_interupting_action" then
		local charge_value = display_info.compute_level_value(self)
		if charge_value then
			mod.current_charge_level.color = display_info:compute_level_color(charge_value)
			mod.current_charge_level.fade_out = mod.anim_state.STARTING
		end
	else
		mod.current_charge_level.color = nil
	end

	return result
end)

Mods.hook.set(mod_name, "ActionTrueFlightBowAim.client_owner_post_update", function (func, self, dt, t, ...)
	func(self, dt, t, ...)

	local display_info = mod.display_info["ActionTrueFlightBowAim"]
	local charge_value = display_info.compute_level_value(self)
	if charge_value then
		mod.current_charge_level.color = display_info:compute_level_color(charge_value)
		mod.current_charge_level.fade_out = nil
	end
end)

Mods.hook.set(mod_name, "ActionTrueFlightBowAim.finish", function (func, self, reason)
	local result = func(self, reason)

	local display_info = mod.display_info["ActionTrueFlightBowAim"]
	if reason == "new_interupting_action" then
		local charge_value = display_info.compute_level_value(self)
		if charge_value then
			mod.current_charge_level.color = display_info:compute_level_color(charge_value)
			mod.current_charge_level.fade_out = mod.anim_state.STARTING
		end
	else
		mod.current_charge_level.color = nil
	end

	return result
end)

Mods.hook.set(mod_name, "OverchargeBarUI.update", function(func, self, dt, ...)
	-- We use drawn_test to tell whether the overcharge bar was actually drawn (this avoids
	-- having to duplicate all the tests in OverchargeBarUI._update_overcharge).  If it was
	-- drawn, drawn_test.angle will be set after calling func.
	local drawn_test = self.charge_bar.style.white_divider_left
	drawn_test.angle = nil
	func(self, dt, ...)
	if not drawn_test.angle then
		return
	end

	if mod.current_charge_level.color then
		local widget = self._hudmod_charge_level_indicator
		if not widget then
			-- First use of the charge level indicator, create it now.
			widget = UIWidget.init(mod.widget_settings.CHARGE_LEVEL)
			self._hudmod_charge_level_indicator = widget
		end

		if mod.current_charge_level.fade_out == mod.anim_state.ONGOING and not UIWidget.has_animation(widget) then
			-- Fade-out animation just finished.
			mod.current_charge_level.color = nil
			mod.current_charge_level.fade_out = nil
		else
			if mod.current_charge_level.fade_out == mod.anim_state.STARTING then
				-- Start the fade-out animation.
				local color = table.clone(mod.current_charge_level.color)
				widget.style.indicator.color = color
				UIWidget.animate(widget, UIAnimation.init(UIAnimation.function_by_time, color, 1, 255, 0, 1, math.easeInCubic))
				mod.current_charge_level.fade_out = mod.anim_state.ONGOING

			elseif not mod.current_charge_level.fade_out then
				if UIWidget.has_animation(widget) then
					-- A new charge has begun while we're still fading out the last one, cancel animation.
					UIWidget.stop_animations(widget)
				end
				widget.style.indicator.color = mod.current_charge_level.color
			end

			-- Draw the charge level indicator.
			local input_service = self.input_manager:get_service("ingame_menu")
			local ui_renderer = self.ui_renderer
			UIRenderer.begin_pass(ui_renderer, self.ui_scenegraph, input_service, dt, nil, self.render_settings)
 			UIRenderer.draw_widget(ui_renderer, widget)
			UIRenderer.end_pass(ui_renderer)
		end
	end
end)
