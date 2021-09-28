--[[
	Name: Fashion Patrol
	Author: Aussiemon
	Updated: uladz (since 1.1.0)
	Version: 1.1.0 (9/25/2021)
	Link: https://github.com/Aussiemon/Vermintide-JHF-Mods/blob/original_release/mods/patch/FashionPatrol.lua

	Stormvermin patrol fashion week up in here.

	Version history:
		1.0.0 Uptaken from GIT, last update 1/25/2018.
		1.1.0 Refactored code and changed options to better fit QoL mod options.
--]]

local mod_name = "FashionPatrol"
FashionPatrol = {}
local mod = FashionPatrol

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_fashion_patrol_enabled",
		["widget_type"] = "stepper",
		["text"] = "Fashion Patrol",
		["tooltip"] = "Fashion Patrol\n" ..
			"Patrol stormvermin have white armor in hosted games.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
}

mod.white_storm_variation = {
	material_variations = {
		cloth_tint = {
			min = 31,
			max = 31,
			variable = "gradient_variation",
			materials = {
				"mtr_outfit"
			},
			meshes = {
				"g_stormvermin_armor_lod0",
				"g_stormvermin_armor_lod1",
				"g_stormvermin_armor_lod2"
			}
		}
	}
}

--[[
  Options
--]]

mod.create_options = function()
	local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
	Mods.option_menu:add_group(group, "Fashion Patrol")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVE, true)
end

--[[
  Functions
--]]

mod.trigger_stormvermin_variation = function(unit)
	local variation_settings = mod.white_storm_variation
	local variation = variation_settings.material_variations["cloth_tint"]

	local variable_value = math.random(variation.min, variation.max)
	local variable_name = variation.variable
	local materials = variation.materials
	local meshes = variation.meshes
	local num_materials = #materials

	local Mesh_material = Mesh.material
	local Material_set_scalar = Material.set_scalar

	if not meshes then
		local Unit_set_scalar_for_material_table = Unit.set_scalar_for_material_table
		Unit_set_scalar_for_material_table(unit, materials, variable_name, variable_value)
	else
		for i=1, #meshes do
			local mesh = meshes[i]
			local Unit_mesh = Unit.mesh
			local current_mesh = Unit_mesh(unit, mesh)

			for material_i=1, num_materials do
				local material = materials[material_i]
				local current_material = Mesh_material(current_mesh, material)
				Material_set_scalar(current_material,variable_name,variable_value)
			end
		end
	end

	local Unit_set_visibility = Unit.set_visibility
	Unit_set_visibility(unit, "all", false)

	return
end

local get = function(data)
	return Application.user_setting(data.save)
end

--[[
  Hooks
--]]

Mods.hook.set(mod_name, "UnitSpawner.spawn_local_unit_with_extensions", function (func, self, unit_name, unit_template_name, extension_init_data, ...)
	local unit, unit_template_name = func(self, unit_name, unit_template_name, extension_init_data, ...)

	-- Changes here: --------------------------------
	if get(mod.widget_settings.ACTIVE) then

		if unit_template_name == "ai_unit_storm_vermin" and extension_init_data and extension_init_data.ai_group_system and extension_init_data.ai_group_system.template == "storm_vermin_formation_patrol" then
			mod.trigger_stormvermin_variation(unit)
		end
	end
	-- Changes end. ---------------------------------

	return unit, unit_template_name
end)

--[[
  Start
--]]

mod.create_options()

-- ##########################################################
