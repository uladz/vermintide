local mod = GiveOtherItems
local player_unit = Managers.player:local_player().player_unit
local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
local slot_name = inventory_extension:get_wielded_slot_name()

if slot_name == "slot_healthkit" or slot_name == "slot_potion"  or slot_name == "slot_grenade" then
	local item_template = inventory_extension:get_wielded_slot_item_template()
	local item_name = ""

	if item_template.pickup_data and item_template.pickup_data.pickup_name then
		item_name = item_template.pickup_data.pickup_name
	elseif item_template.is_grimoire then
		item_name = "grimoire"
	end

	-- Remove item
	inventory_extension:destroy_slot(slot_name)

	-- Switch to melee weapon
	inventory_extension:wield("slot_melee")

	-- Spawn item
	Mods.spawnItem(item_name)

	-- Feedback
	if mod.get(mod.widget_settings.ECHO) then
		EchoConsole("Dropped " .. item_name)
	end
end
