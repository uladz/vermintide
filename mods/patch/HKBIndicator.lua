--[[
	Name: Heroic Killing Blow Indicator
	Author: VernonKun
	Updated: 5/13/2020

	Display a local chat message when Heroic Killing Blow procs on Rat Ogre.
--]]
Mods.hook.set("HKBIndicator", "DamageUtils.buff_on_attack", function (func, unit, hit_unit, attack_type, ...)
	local original_BuffExtension_apply_buffs_to_value = BuffExtension.apply_buffs_to_value
	BuffExtension.apply_buffs_to_value = function (self, value, stat_buff)
		local amount, procced, parent_id = original_BuffExtension_apply_buffs_to_value(self, value, stat_buff)
		local breed = Unit.get_data(hit_unit, "breed")

		if procced
			and stat_buff == StatBuffIndex.HEAVY_KILLING_BLOW_PROC
			and unit == Managers.player:local_player().player_unit
			and breed
			and breed.name == "skaven_rat_ogre"
			then
				EchoConsole("<Heroic Killing Blow on Rat Ogre!>")
		end
		return amount, procced, parent_id
	end

	local return_val = func(unit, hit_unit, attack_type, ...)

	BuffExtension.apply_buffs_to_value = original_BuffExtension_apply_buffs_to_value

	return return_val
end)
