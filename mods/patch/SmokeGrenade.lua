--[[
	Name: Smoke Grenade
	Author: uladz
	Version: 1.0.0 (10/10/2021)

	Restores throwable smoke grenades and allows the game to spawn them through a map along with
	other grenade types. Smoke grenade does not explode but emits a cloud of poisonous gas
	suffocating all rats in its area of effect. Affected area is a bit larger than fire grenade's
	are so use with caution. Smoke grenades can be found in chests, sackrat and supply drops. Also
	restores "improved" grenades naming.

	*** ATTENTION ***
	If enabled it will crash clients that don't have this mod installed when a smoke grenade is
	spowned. All playwer must have this mod installed if the host has enabled smoke grenades spawning
	though they don't need to enable it.

	This mod is intended to work with QoL modpack. To "install" copy the file to
	"<game>\binaries\mods\patch" folder. To enable go to "Options" -> "Mod Settings" ->
	"Gameplay Tweaks" and turn on "Enable Smoke Grenades" option.

	Version history:
	1.0.0 Initial release, inspired by grasmann's mod.
--]]

local mod_name = "SmokeGrenade"
SmokeGrenade = {}
local mod = SmokeGrenade

--[[
  Variables
--]]

mod.widget_settings = {
	ENABLE = {
		["save"] = "cb_smoke_grenade_enable",
		["widget_type"] = "stepper",
		["text"] = "Enable Smoke Grenades",
		["tooltip"] = "Enable Smoke Grenades\n" ..
			"Restores throwable Smoke Grenades and allows game to spawn them through a map alon with " ..
			"other grenade types. Smoke Grenades can be found in chests, sackrat and supply drops.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default second option is enabled. In this case On
	},
}

mod.was_active = false
mod.tables_patched = false

--[[
  Options
]]--

mod.create_options = function()
	local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
	Mods.option_menu:add_item(group, mod.widget_settings.ENABLE, true)
end

--[[
  Functions
]]--

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

-- Insert smoke grenades into game tables, must be called once.
mod.patch_pickup_tables = function()

	-- don't patch system files twice
	if not mod.tables_patched then
		mod.tables_patched = true
	else
		return
	end

	-- Patch AOE template
	ExplosionTemplates.smoke_grenade = {
		aoe = {
			radius = 7,
			nav_tag_volume_layer = "smoke_grenade",
			create_nav_tag_volume = true,
			attack_template = "poison_globe_ai_initial_damage",
			sound_event_name = "player_combat_weapon_smoke_grenade_explosion",
			damage_interval = 1,
			duration = 10,
			area_damage_template = "explosion_template_aoe",
			effect_name = "fx/wpnfx_smoke_grenade_impact",
		}
	}

	-- Add to Pickups
	Pickups.grenades.smoke_grenade_t1 = {
		only_once = true,
		type = "inventory_item",
		slot_name = "slot_grenade",
		item_description = "grenade_smoke",
		spawn_weighting = 0,
		pickup_sound_event = "pickup_grenade",
		dupable = true,
		bots_mule_pickup = true,
		item_name = "grenade_smoke_01",
		unit_name = "units/weapons/player/pup_grenades/pup_grenade_02_t1",
		local_pickup_sound = true,
		hud_description = "pickup_smoke_grenade_t1"
	}
	Pickups.improved_grenades.smoke_grenade_t2 = {
		only_once = true,
		type = "inventory_item",
		slot_name = "slot_grenade",
		item_description = "grenade_smoke",
		spawn_weighting = 0,
		pickup_sound_event = "pickup_grenade",
		dupable = true,
		bots_mule_pickup = true,
		item_name = "grenade_smoke_02",
		unit_name = "units/weapons/player/pup_grenades/pup_grenade_02_t2",
		local_pickup_sound = true,
		hud_description = "pickup_smoke_grenade_t2"
	}

	-- Add to AllPickups table
	AllPickups["smoke_grenade_t1"] = Pickups.grenades.smoke_grenade_t1
	AllPickups["smoke_grenade_t2"] = Pickups.improved_grenades.smoke_grenade_t2

	-- Add to NetworkLookup.pickup_names table
	local pickup_names = NetworkLookup.pickup_names
	if not table.find(pickup_names, "smoke_grenade_t1") then
		table.insert(pickup_names, "smoke_grenade_t1")
		pickup_names["smoke_grenade_t1"] = #pickup_names
	end
	if not table.find(pickup_names, "smoke_grenade_t2") then
		table.insert(pickup_names, "smoke_grenade_t2")
		pickup_names["smoke_grenade_t2"] = #pickup_names
	end

	-- Fix improved grenade names.
	Pickups.improved_grenades.frag_grenade_t2.hud_description = "pickup_frag_grenade_t2"
	Pickups.improved_grenades.fire_grenade_t2.hud_description = "pickup_fire_grenade_t2"
end

-- Allows frag and fire grenade spawners to spawn smoke grenades too.
mod.patch_spawners = function(spawners)
	for i = 1, #spawners, 1 do
		local unit = spawners[i]
		if Unit.get_data(unit, "frag_grenade_t1") or Unit.get_data(unit, "fire_grenade_t1") then
			Unit.set_data(unit, "smoke_grenade_t1", true)
		end
		if Unit.get_data(unit, "frag_grenade_t2") or Unit.get_data(unit, "fire_grenade_t2") then
			Unit.set_data(unit, "smoke_grenade_t2", true)
		end
	end
end

--[[
  Hooks
]]--

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	func(self, dt, t)

	local active = mod.get(mod.widget_settings.ENABLE)
	if active ~= mod.was_active then
		if active then
			-- rebalance spawn rates for 3 grenades
			Pickups.grenades.smoke_grenade_t1.spawn_weighting = 1/3
			Pickups.grenades.frag_grenade_t1.spawn_weighting = 1/3
			Pickups.grenades.fire_grenade_t1.spawn_weighting = 1/3
			Pickups.improved_grenades.smoke_grenade_t2.spawn_weighting = 1/3
			Pickups.improved_grenades.frag_grenade_t2.spawn_weighting = 1/3
			Pickups.improved_grenades.fire_grenade_t2.spawn_weighting = 1/3

			-- rebalance sackrat drop rates for 3 grenades
			LootRatPickups["smoke_grenade_t2"] = 0.039215686274509803
			LootRatPickups["frag_grenade_t2"] = 0.039215686274509803
			LootRatPickups["fire_grenade_t2"] = 0.039215686274509803
		else
			-- restore spawn rates for 2 grenades
			Pickups.grenades.smoke_grenade_t1.spawn_weighting = 0
			Pickups.grenades.frag_grenade_t1.spawn_weighting = 1/2
			Pickups.grenades.fire_grenade_t1.spawn_weighting = 1/2
			Pickups.improved_grenades.smoke_grenade_t2.spawn_weighting = 0
			Pickups.improved_grenades.frag_grenade_t2.spawn_weighting = 1/2
			Pickups.improved_grenades.fire_grenade_t2.spawn_weighting = 1/2

			-- restore sackrat drop rates for 2 grenades
			LootRatPickups["smoke_grenade_t2"] = nil
			LootRatPickups["frag_grenade_t2"] = 0.058823529411764705
			LootRatPickups["fire_grenade_t2"] = 0.058823529411764705
		end
		mod.was_active = active
	end
end)

Mods.hook.set(mod_name, "PickupSystem.spawn_spread_pickups", function(func, self, spawners, pickup_settings, comparator, seed)
	mod.patch_spawners(spawners)
	return func(self, spawners, pickup_settings, comparator, seed)
end)

Mods.hook.set(mod_name, "PickupSystem.spawn_guarenteed_pickups", function (func, self)
	mod.patch_spawners(self.guaranteed_pickup_spawners)
	return func(self)
end)

Mods.hook.set(mod_name, "PickupSystem.activate_triggered_pickup_spawners", function (func, self, triggered_spawn_id)
	mod.patch_spawners(self.triggered_pickup_spawners[triggered_spawn_id])
	return func(self, triggered_spawn_id)
end)

--[[
	Start
--]]

mod.patch_pickup_tables()
mod.create_options()
