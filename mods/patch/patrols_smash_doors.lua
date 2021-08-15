--[[
 	Name: Patrols Smash Doors
 	Author: Xq
	Updated: 2/27/2020

	This hook causes stormvermin patrols to break all doors while patrolling instead of opening them.
--]]

local mod_name = "patrols_smash_doors"

Mods.hook.set(mod_name, "ConflictDirector.update", function(func, self, dt, t)
	func(self, dt, t)
	local patrol_rats = Managers.state.conflict._spawned_units_by_breed["skaven_storm_vermin"]
	for _,unit in pairs(patrol_rats) do
		local blackboard = Unit.get_data(unit, "blackboard")
		if blackboard then
			blackboard.preferred_door_action = "smash"	-- originally "open"
		end
	end
end)
