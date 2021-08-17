--[[
	Name: Full Ammo Fix
	Author: VernonKun (presumably)
	Updated: 5/26/2020

	With this mod, the game will consider the user has full ammo when total ammo exceeds max ammo
	(because of Haste / Berserking + Scavenger etc.). This prevents user from getting less ammo from
	ammo crates and consumable ammo and wasting it.

	Update 1: Now the mod also prevents Scavenger procs resetting total ammo to max ammo.
--]]

local mod_name = "FullAmmoFix"

Mods.hook.set(mod_name, "GenericAmmoUserExtension.full_ammo", function(func, self)
	return self:remaining_ammo() + self:ammo_count() >= self.max_ammo
end)

Mods.hook.set(mod_name, "GenericAmmoUserExtension.add_ammo", function(func, self)
	if self.available_ammo == 0 and self.current_ammo == 0 then
		self.reloaded_from_zero_ammo = true
		local player = Managers.player:unit_owner(self.owner_unit)
		local item_name = self.item_name
		local position = POSITION_LOOKUP[self.owner_unit]

		Managers.telemetry.events:player_ammo_refilled(player, item_name, position)
	end

	if self.ammo_immediately_available then
		self.current_ammo = math.max(self.current_ammo, self.max_ammo)
	else
		self.available_ammo = math.max(self.available_ammo, self.max_ammo - (self.current_ammo - self.shots_fired))
	end
end)

--no need compatibility with QoL mods
Mods.hook.set(mod_name, "GenericAmmoUserExtension.add_ammo_to_reserve", function(func, self, amount)
	if self.ammo_immediately_available then
		self.current_ammo = math.max(self.current_ammo, math.min(self.max_ammo, self.current_ammo + amount))
	else
		self.available_ammo = math.max(self.available_ammo, math.min(self.max_ammo - self.current_ammo, self.available_ammo + amount))
	end

	--EchoConsole("add_ammo_to_reserve hooked")
end)

Mods.hook.set(mod_name, "ActiveReloadAmmoUserExtension.add_ammo", function(func, self, ammo_amount)
	--self.available_ammo = math.min(self.available_ammo + ammo_amount, self.max_ammo - (self.current_ammo - self.shots_fired))
	self.available_ammo = math.max(self.available_ammo, math.min(self.available_ammo + ammo_amount, self.max_ammo - (self.current_ammo - self.shots_fired)))
end)

--SimpleInventoryExtension.add_ammo_from_pickup
