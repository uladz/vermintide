--[[
	Name: Pages Forever
	Author: Aussiemon
	Updated: uladz (since 1.1.0)
	Version: 1.1.0
	Link: https://github.com/Aussiemon/Vermintide-JHF-Mods/blob/original_release/mods/patch/PagesForever.lua

	Allows the pickup of lorebook pages (that don't do anything) after they've all been unlocked.
	Also allows restriction of lorebook sackrat drops after they've all been unlocked.

	Version history:
		1.0.0 Uptaken from GIT, last update 1/25/2018.
		1.1.0 Refactored code and changed options to better fit QoL mod options.
--]]

local mod_name = "PagesForever"
PagesForever = {}
local mod = PagesForever

mod.widget_settings = {
	ACTIVE = {
		["save"] = "cb_lorebook_pages_forever",
		["widget_type"] = "stepper",
		["text"] = "Lorebook Pages Forever",
		["tooltip"] = "Lorebook Pages Forever\n" ..
			"Toggle lorebook pages appearing post-unlock on / off. Allows you to see and interact " ..
			"with lorebook pages after they've been unlocked, if only for the joy of picking them up.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	SACKRAT = {
		["save"] = "cb_lorebook_pages_forever_sackrat_drops",
		["widget_type"] = "stepper",
		["text"] = "Sackrats Drop Pages",
		["tooltip"] = "Sackrats Drop Pages\n" ..
			"Toggle the drop of sackrat lorebook pages on / off. Sackrat lorebook page drops will " ..
			"be disabled when all pages are unlocked, this option enables the drops. Note that " ..
			"lorebook pages drops will lower probability of loot die drops.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 2, -- Default first option is enabled. In this case On
	},
}

--[[
  Options
--]]

mod.create_options = function()
	local group = "tweaks"
	Mods.option_menu:add_group(group, "Gameplay Tweaks")
	Mods.option_menu:add_item(group, mod.widget_settings.ACTIVE, true)
	Mods.option_menu:add_item(group, mod.widget_settings.SACKRAT, true)
end

--[[
  Functions
--]]

mod.get = function(data)
	return Application.user_setting(data.save)
end

mod.redo_sackrat_weights = function()
	local total_loot_rat_spawn_weighting = 0
	for pickup_name, spawn_weighting in pairs(LootRatPickups) do
		total_loot_rat_spawn_weighting = total_loot_rat_spawn_weighting + spawn_weighting
	end

	for pickup_name, spawn_weighting in pairs(LootRatPickups) do
		LootRatPickups[pickup_name] = spawn_weighting/total_loot_rat_spawn_weighting
	end
end

mod.set_sackrat_pages = function(enabled)
	-- Enable sackrat pages
	if enabled then
		LootRatPickups = {
			first_aid_kit = 3,
			healing_draught = 2,
			damage_boost_potion = 1,
			speed_boost_potion = 1,
			frag_grenade_t2 = 1,
			fire_grenade_t2 = 1,
			loot_die = 4,
			lorebook_page = 4
		}
		mod.redo_sackrat_weights()

	-- Disable sackrat pages
	else
		LootRatPickups = {
			first_aid_kit = 3,
			healing_draught = 2,
			damage_boost_potion = 1,
			speed_boost_potion = 1,
			frag_grenade_t2 = 1,
			fire_grenade_t2 = 1,
			loot_die = 4,
		}
		mod.redo_sackrat_weights()
	end
end

--[[
  Hooks
--]]

Mods.hook.set(mod_name, "Pickups.lorebook_pages.lorebook_page.hide_func", function (func, ...)
	local result = func(...)

	-- Change sackrat drops if necessary
	if not mod.get(mod.widget_settings.SACKRAT) and LootRatPickups["lorebook_page"] then
		mod.set_sackrat_pages(false)
	-- Restore sackrat drops to default if necessary
	elseif mod.get(mod.widget_settings.SACKRAT) and not LootRatPickups["lorebook_page"] then
		mod.set_sackrat_pages(true)
	end

	if mod.get(mod.widget_settings.ACTIVE) then
		-- Force show lorebook pages
		return false
	end

	-- Return original result
	return result
end)

--[[
  Start
--]]

mod.create_options()
