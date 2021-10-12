--[[
DodgeJump v1.0.0
Author: IamLupo

Allows you to dodge-jump up walls, like you could before v1.6.
Go to Mod Settings -> Movement -> Dodge Jump to toggle.
Off by default.

Changelog
	1.0.0 - Release

	In game version 1.5 and lower there was a funny glitch thats called dodge jump.
	This allowed you to dodge and jump on wall and this gave you possebility to come on handy places.
	This became pretty populair and people missed it.

	Fatshark Patch:
		File:
			scripts/unit_extensions/default_player_unit/states/player_character_state_dodging.lua

		Before:
			if input_extension.get(input_extension, "jump") and
				status_extension.can_override_dodge_with_jump(status_extension, t) then

		After:
			if input_extension.get(input_extension, "jump") and
				self.locomotion_extension:jump_allowed() and
				status_extension.can_override_dodge_with_jump(status_extension, t) then
]]--

local mod_name = "DodgeJump"
DodgeJump = {}
local mod = DodgeJump

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_dodge_jump",
		["widget_type"] = "stepper",
		["text"] = "Dodge Jump",
		["tooltip"] = "Enable Dodge Jump\n" ..
			"Dodge jump was a mechanic before v1.6 where it was patched out.\n\n" ..
			"This allows you to dodge-jump up walls again.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1 -- Default first option is enabled. In this case Off
	}
}

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("movement", "Movement")

	Mods.option_menu:add_item("movement", mod.widget_settings.ACTIVE, true)
end

-- ####################################################################################################################
-- ##### Hook ######################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "PlayerCharacterStateDodging.update", function(func, ...)
	if mod.get(mod.widget_settings.ACTIVE) then
		local jump_allowed = PlayerUnitLocomotionExtension.jump_allowed

		PlayerUnitLocomotionExtension.jump_allowed = function (self)
			return true
		end

		func(...)

		PlayerUnitLocomotionExtension.jump_allowed = jump_allowed
	else
		func(...)
	end
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
