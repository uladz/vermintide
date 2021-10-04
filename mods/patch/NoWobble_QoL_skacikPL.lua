--[[
	Name: No Wobble
	Author: SkacikPL, VernonKun
	Updated: uladz (since 1.1.0)
	Version: 1.1.0 (10/3/2021)

	Disables camera shake on weapon attacks. To enable go to "Options" -> "Mod Settings" ->
	"Gameplay Tweaks" and enable "Disable Wobble Effect" options.

	Version history:
		1.0.0 Ported from VMF to QoL by VernonKun (2/2/2021).
		1.1.0 Added mod options, added option to disable wobble for melee weapon only, cleaned up code.
			Melee only code was taken from VernonKun "NoWobble_QoL_skacikPL_melee_only.lua" mod.
]] --

local mod_name = "NoWobble"
NoWobble = {}
mod = NoWobble

--[[
  Variables
--]]

mod.widget_settings = {
	ENABLED = {
		["save"] = "cb_no_wobble_enabled",
		["widget_type"] = "stepper",
		["text"] = "Disable Wobble Effect",
		["tooltip"] = "Disable Wobble Effect\n" ..
			"Disables camera shake on weapon attacks.",
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
					"cb_no_wobble_melee_only",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_no_wobble_melee_only",
				}
			},
		},
	},
	MELEE_ONLY = {
		["save"] = "cb_no_wobble_melee_only",
		["widget_type"] = "stepper",
		["text"] = "For Melee Weapon Only",
		["tooltip"] = "For Melee Weapon Only\n" ..
			"Disables camera shake only for melee weapon attacks.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	}
}

--[[
  Options
--]]

mod.create_options = function()
	local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
	Mods.option_menu:add_item(group, mod.widget_settings.ENABLED, true)
	Mods.option_menu:add_item(group, mod.widget_settings.MELEE_ONLY)
end

--[[
  Functions
--]]

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

mod.get_equipped_slot = function(unit)
	local inventory_ext = ScriptUnit.has_extension(unit, "inventory_system")
	return (inventory_ext and inventory_ext:get_wielded_slot_name()) or ""
end

mod.is_melee_slot = function(unit)
	return mod.get_equipped_slot(unit) == "slot_melee"
end

--[[
  Hooks
--]]

Mods.hook.set(mod_name, "PlayerUnitFirstPerson.update", function (func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)

	if not Managers or not Managers.player or not mod.get(mod.widget_settings.ENABLED) then
		return
	end

	local unit_owner = Managers.player:unit_owner(unit)
	local player_unit	= unit_owner and unit_owner.player_unit

	if Unit.alive(player_unit) then
		local local_owner	= Managers.player:local_player()
		local local_unit = local_owner.player_unit

		if player_unit and player_unit == local_unit then
			if not mod.get(mod.widget_settings.MELEE_ONLY) or mod.is_melee_slot(player_unit) then
				local FPU = self.first_person_unit
				local camerabone = Unit.node(FPU, "camera_node")

				Unit.set_local_rotation(FPU, camerabone, Quaternion.identity())
				Unit.set_local_position(FPU, camerabone, Vector3.zero())
			end
		end
	end
end)

--[[
	Start
--]]

mod.create_options()
