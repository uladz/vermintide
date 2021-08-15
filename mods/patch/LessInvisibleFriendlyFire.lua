--[[
	Name: Less Invisible Friendly Fire
	Author: VernonKun
	Revision 2020-08-02: Xq
	Updated: 8/7/2020

	Fix to apply camera offset to ranged weapons to reduce invisible friendly fire. Projectiles shot
	by the user will be spawned 0.5 meter in front of the head instead of at the head (camera
	position). Hopefully this will reduces the chance of shooting overlapping teammates. The script
	is modified from the Third Person mod from QOL. The mod might affect shield bashes too. (Please
	report oddity if you see any.)

	Note: One way to visualize the change is to shoot Trueflight Longbow and press X to compare where
	the trail starts.
--]]

-- local mod_name = RangedWeaponsModification
local mod_name = "LessInvisibleFriendlyFire"
local shift_active = false
local projectile_shift_active = false
local shift_distance_extended = 0.9	-- For certain projectiles with larger collision box.. Tested lower values too, <0.9 doesn't seem to reliably prevent friendly fire in situations where other player(s) are standing inside you but you still can't see them.
local shift_distance = 0.6	-- For bullets / arrows with tiny collision box.. Tested lower values too, <0.6 doesn't seem to reliably prevent friendly fire in the desired situations.

Mods.hook.set(mod_name, "ActionBulletSpray._select_targets", function(func, self, world, show_outline)
	-- Beam staff's / drakefre pistols' shotgun attack
	-- EchoConsole("fire shotgun")
	local ret = func(self, world, show_outline)

	local local_player_unit = Managers.player:local_player().player_unit
	local local_player_pos = local_player_unit and POSITION_LOOKUP[local_player_unit]
	local allies = {}
	local copied_targets = {}

	for _,owner in pairs(Managers.player:players()) do
		if owner.player_unit then
			local ally_pos = owner.player_unit and POSITION_LOOKUP[owner.player_unit]
			local ally_distance = local_player_pos and ally_pos and Vector3.length(local_player_pos - ally_pos)
			allies[owner.player_unit] = ally_distance
		end
	end

	for _,data in pairs(self.targets) do
		if allies[data] and allies[data] < shift_distance then
			-- this one won't get copied
		else
			copied_targets[#copied_targets +1] = data
		end
	end

	table.clear(self.targets)
	for _,data in pairs(copied_targets) do
		table.insert(self.targets, data)
	end

	return ret
end)


Mods.hook.set(mod_name, "ActionChargedProjectile.client_owner_post_update", function(func, ...)
	-- Drakefire pistols' / fireball staff's / conflag staff's light fireball attacks
	-- EchoConsole("charged_projectile")
	projectile_shift_active = true
	local ret = func(...)
	projectile_shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "ActionBeam.client_owner_post_update", function(func, ...)
	-- Beam staff's beam attack
	-- EchoConsole("beam")
	shift_active = true
	local ret = func(...)
	shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "ActionBow.fire", function(func, ...)
	-- Arrows frired from bows
	-- EchoConsole("bow")
	shift_active = true
	local ret = func(...)
	shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "ActionCrossbow.client_owner_post_update", function(func, ...)
	-- Bolts fired from crossbows / repeating crossbow
	-- EchoConsole("crossbow")
	shift_active = true
	local ret = func(...)
	shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "ActionHandgun.client_owner_post_update", function(func, ...)
	-- Shots from handguns, pistols, repeaters (gunpowder)
	-- EchoConsole("handgun")
	shift_active = true
	local ret = func(...)
	shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "ActionShotgun.client_owner_post_update", function(func, ...)
	-- Shots frired from grudge raker / blunderbuss
	-- EchoConsole("shotgun")
	shift_active = true
	local ret = func(...)
	shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "ActionTrueFlightBow.fire", function(func, ...)
	-- Trueflight arrosws / bolt staff bolts
	-- EchoConsole("trueflight")
	shift_active = true
	local ret = func(...)
	shift_active = false
	return ret
end)

Mods.hook.set(mod_name, "PlayerUnitFirstPerson.current_position", function(func, self)
	local ret = Vector3(0,0,0)
	if shift_active and self.unit == Managers.player:local_player().player_unit then
		-- only do the shift if the hooked fire function calls for it and the projectile is being shot by the local player
		local current_rot = Unit.local_rotation(self.first_person_unit, 0)
		local offset = shift_distance * Quaternion.forward(current_rot)
		ret = func(self) + offset
	else
		ret = func(self)
	end

	return ret
end)

Mods.hook.set(mod_name, "ActionUtils.spawn_player_projectile", function(func, owner_unit, position, rotation, scale, angle, target_vector, speed, item_name, item_template_name, action_name, sub_action_name, gaze_settings)
	local ret = Vector3(0,0,0)
	if projectile_shift_active and owner_unit == Managers.player:local_player().player_unit then
		-- only do the shift if the hooked fire function calls for it and the projectile is being shot by the local player
		local first_person_extension	= ScriptUnit.has_extension(owner_unit, "first_person_system")
		local current_rot				= first_person_extension:current_rotation() -- camera rotation
		local offset = shift_distance_extended * Quaternion.forward(current_rot)
		ret = func(owner_unit, position + offset, rotation, scale, angle, target_vector, speed, item_name, item_template_name, action_name, sub_action_name, gaze_settings)
	else
		ret = func(owner_unit, position, rotation, scale, angle, target_vector, speed, item_name, item_template_name, action_name, sub_action_name, gaze_settings)
	end

	return ret
end)
