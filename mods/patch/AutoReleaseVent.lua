--[[
AutoReleaseVent v1.0.0
Author : Walterr ; Optimization by IamLupo

Automatically Release Vent Button

How to use :
When you're venting with overcharge high enough to cause you damage, this mod will automatically stop venting just before a second chunk of damage would be incurred. If you want to keep venting, you have to press the vent button again.
This mod is automaticelly loaded when you start the Framework, there's no need to toggle it On/Off in Mod Settings.

Changelog
1.0.0 - Release
--]]

local mod_name = "AutoReleaseVent"
AutoReleaseVent = {}
local mod = AutoReleaseVent

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "ActionCharge.client_owner_post_update", function(func, self, dt, t, world, can_damage)
	local overcharge_extn = self.overcharge_extension
	if overcharge_extn and overcharge_extn.venting_overcharge and not overcharge_extn.venting_anim then

		-- This code duplicates the tests in the real ActionCharge.client_owner_post_update that
		-- determine whether to inflict damage due to venting.
		local overcharge_value = overcharge_extn.overcharge_value
		if 0 <= overcharge_value and overcharge_extn.unit == overcharge_extn.right_unit and not overcharge_extn.is_exploding then
			local vent_amount = overcharge_value * overcharge_extn.max_value / 80 * dt
			local vent_damage_pool = overcharge_extn.vent_damage_pool + vent_amount * 2
			local overcharge_value = overcharge_value - vent_amount

			if 20 <= vent_damage_pool and not overcharge_extn.no_damage and overcharge_extn.overcharge_threshold < overcharge_value then
				-- We would incur another chunk of damage now if we kept on venting, so finish the
				-- venting action (and remember the result of finish() so we can return it later).
				self._arvmod_finish_data = self:finish("hold_input_released")
			end
		end
	end

	if not self._arvmod_finish_data then
		return func(self, dt, t, world, can_damage)
	end
end)

Mods.hook.set(mod_name, "ActionCharge.finish", function(func, self, reason)
	local finish_data = self._arvmod_finish_data
	if finish_data then
		self._arvmod_finish_data = nil
		return finish_data
	else
		return func(self, reason)
	end
end)
