local mod_name = "Fire Grenade"
--[[
	Game Version: All
	
	Error:
		<<Lua Error>> scripts/entity_system/systems/volumes/volume_system.lua:181: attempt to index local 'nav_tag_volume_handler' (a nil value)<</Lua Error>>
		<<Lua Stack>>   [1] scripts/entity_system/systems/volumes/volume_system.lua:181: in function create_nav_tag_volume_from_data
		  [2] scripts/unit_extensions/weapons/area_damage/area_damage_extension.lua:235: in function start
		  [3] scripts/entity_system/systems/damage/damage_system.lua:249:in function <scripts/entity_system/systems/damage/damage_system.lua:245>
		<</Lua Stack>>
		<<Lua Locals>>   [1] self = table: 2B031620; pos = Vector3(3.21132, -1.25919, 0.8979); size = 6; layer_name = "fire_grenade"; nav_tag_volume_handler = nil
		  [2] self = table: 2B25FCC0; area_damage = table: 2B19D5C0; particle_var_table = table: 2F393288; nav_mesh_effect = table: 2B488240; volume_system = table: 2B031620; pos = Vector3(3.21132, -1.25919, 0.8979)
		  [3] self = table: 2B0BBA40; sender = "1100001067b5a03"; go_id = 113; position = Vector3(3.21132, -1.25919, 0.8979); unit = [Unit \'#ID[d754cba8f2fefbf8]\']; area_damage_system = table: 2B25FCC0
		<</Lua Locals>>
	
	Detail:
		When you throw a fire grenade in the inn it is missing a "nav_tag_volume_handler".
		I check it exist before executing the function.
--]]

Mods.hook.set(mod_name, "VolumeSystem.create_nav_tag_volume_from_data", function(func, self, ...)
	if self.nav_tag_volume_handler then
		-- Call orginal function
		return func(self, ...)
	end
	
	return ""
end)

Mods.hook.set(mod_name, "VolumeSystem.destroy_nav_tag_volume", function(func, self, ...)
	if self.nav_tag_volume_handler then
		-- Call orginal function
		func(self, ...)
	end
	
	return
end)
