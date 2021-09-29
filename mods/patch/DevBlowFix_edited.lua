--[[
	Name: Devastating Blow Fix (ported from VMF)
	Author: Zeropathic
	Version: 1.2.1

	Devastating Blow doesn't only increase your push strength; it also increases the stagger strength
	of your weapon's attacks. Normally, this secondary effect only works if you're the host. This mod
	aims to fix this bug for clients connected to you.

	NOTE: Only the host needs to have this mod installed. It does (or at least should do) nothing if
	installed on clients.

	Update 5/24/2020: Ported from VMF (by VernonKun).
	Devastating blow has the effect of nullifying "ignore_stagger" of some enemy actions, e.g.
	stormvermin overheads, but it only works for the host. This fix runs on the host side and gives
	every client in the lobby the same effect if they have devastating blow.
--]]


--local mod = get_mod("DevBlowFix")
local mod_name = "DevBlowFix"

--
-- This function checks the unit's currently held item and sees if devastating blow is on it.
-- A current side-effect is that dev blow will work on weapon attacks even if it isn't unlocked.
local function hasDevBlow(attacker_unit)
	local inventory_extension = ScriptUnit.has_extension(attacker_unit, "inventory_system")
	local wielded_slot = inventory_extension and inventory_extension:get_wielded_slot_name()
	local slot_data = inventory_extension and inventory_extension:get_slot_data(wielded_slot)

	local item_key = slot_data and slot_data.item_data.key
	local item = item_key and ItemMasterList[item_key]

	if item and item.traits then -- Ogres can trigger this function. This check keeps them out. It would crash because they don't have item data.
		for _, trait_name in ipairs(item.traits) do
			if trait_name == "melee_weapon_push_increase" then
				-- Currently returns 'true' even if the trait hasn't been unlocked. Would be nice to fix it, but it's not very high priority.
				return true
			end
		end
	end
	return false
end
--


--
-- I hook the function responsible for calculating stagger, then run a modified version of it instead.
-- This function runs host-side when an attack connects with an enemy. Stagger is then calculated based on various factors.
--Mods.hook.set(DamageUtils, "calculate_stagger", function(damage_table, duration_table, target_unit, attacker_unit, attack_template)
Mods.hook.set(mod_name, "DamageUtils.calculate_stagger", function(func, damage_table, duration_table, target_unit, attacker_unit, attack_template)
	local breed = Unit.get_data(target_unit, "breed")
	local target_unit_armor = breed.armor_category
	local stagger = 0
	local duration = 0.5

	if damage_table then
		stagger = damage_table[target_unit_armor]
	end

	if breed.boss_staggers and stagger < 6 then
		stagger = 0
	end

	local blackboard = Unit.get_data(target_unit, "blackboard")
	local action = blackboard.action
	local ignore_staggers = action and action.ignore_staggers

	-- ignore_staggers seems to be active during stormvermin attacks
	if ignore_staggers then
		--[[
		-- Default stuff. Doesn't work when off-host is attacker
		local owner_buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

		-- This check always returns false if a client is the attacker. It's as if buff data isn't properly communicated to the host or something.
		if owner_buff_extension and owner_buff_extension:has_buff_type("push_increase") then
			ignore_staggers = false
		end
		--]]

		-- My own check. See the function above.
		if hasDevBlow(attacker_unit) then
			ignore_staggers = false
		end
	end

	if ignore_staggers and ignore_staggers[stagger] and (not ignore_staggers.allow_push or not attack_template or not attack_template.is_push) then
		return 0, 0
	end

	if duration_table then
		duration = duration_table[target_unit_armor]
	end

	if breed.no_stagger_duration then
		duration = 0
	end

	duration = math.max((duration + math.random()) - 0.5, 0)

	if DamageUtils.is_player_unit(attacker_unit) then
		local player = Managers.player:owner(attacker_unit)
		local boon_handler = player.boon_handler

		if boon_handler then
			local boon_name = "increased_stagger_type"
			local has_increased_stagger_type_boon = boon_handler:has_boon(boon_name)

			if has_increased_stagger_type_boon then
				local num_increased_damage_boons = boon_handler:get_num_boons(boon_name)
				local boon_template = BoonTemplates[boon_name]
				local duration_multiplier = 1 + boon_template.duration_multiplier
				duration = duration * duration_multiplier
			end
		end
	end

	return stagger, duration
end)
--
