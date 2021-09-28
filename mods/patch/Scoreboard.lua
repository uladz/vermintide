--[[
	Name: Scoreboard
	Author: /u/Grundlid
	Updated: uladz (since 1.0.1)
	Version: 1.0.1 (9/25/2021)

	Version history:
	1.0.0 Release with Qol v15
	1.0.1 Options moved from "HUD Improvements" to "Scoreboard Improvements".
--]]

local mod_name = "Scoreboard"

local user_setting = Application.user_setting

local MOD_SETTINGS = {
	SCOREBOARD_FIXED_ORDER = {
		["save"] = "cb_scoreboard_fixed_order",
		["widget_type"] = "stepper",
		["text"] = "Consistent Topic Order",
		["tooltip"] = "Consistent Topic Order\n" ..
			"Make scoreboard topics always be presented in the same order.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off by default
	},
	DAMAGE_TAKEN = {
		["save"] = "cb_damage_taken_enabled",
		["widget_type"] = "stepper",
		["text"] = "Damage Taken Scoreboard Fix",
		["tooltip"] = "Damage Taken Scoreboard Fix\n" ..
			"Ignore damage taken while already downed for the purpose of the end match scoreboard.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off by default
	},
	SCOREBOARD_FF = {
		["save"] = "cb_scoreboard_ff",
		["widget_type"] = "stepper",
		text = "Friendly Fire On Scoreboard",
		tooltip = "Friendly fire on scoreboard\n" ..
			"Display friendly fire tab on the scoreboard.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off by default
	},
	SCOREBOARD_FF_SELF = {
		["save"] = "cb_scoreboard_ff_self",
		["widget_type"] = "stepper",
		text = "Self-inflicted Damage On Scoreboard",
		tooltip = "Self-inflicted friendly fire on scoreboard\n" ..
			"Display self-inficted friendly fire tab on the scoreboard.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off by default
	},
	SCOREBOARD_PLAYER_PROCS = {
		["save"] = "cb_scoreboard_player_procs",
		["widget_type"] = "stepper",
		text = "Heal And Scavenger Procs On Scoreboard",
		tooltip = "Heal And Scavenger Procs Tally On Scoreboard\n" ..
			"Displays the amount of health and ammo gained from procs.\n" ..
			"Columns: From Melee Slot, From Ranged Slot, Total Score.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off by default
	},
}

--- new scoreboard categories
if not StatisticsDefinitions.player.ff then
	StatisticsDefinitions.player.ff = {
		value = 0,
		name = "ff"
	}
end
if not StatisticsDefinitions.player.ff_self then
	StatisticsDefinitions.player.ff_self = {
		value = 0,
		name = "ff_self"
	}
end
--- not tracked, just so we don't crash on the ui category
if not StatisticsDefinitions.player.local_data then
	StatisticsDefinitions.player.local_data = {
		value = "",
		name = "local_data"
	}
end
if not StatisticsDefinitions.player.heal_procs then
	StatisticsDefinitions.player.heal_procs = {
		value = "0 / 0 / 0",
		name = "heal_procs"
	}
end
if not StatisticsDefinitions.player.scavenger_procs then
	StatisticsDefinitions.player.scavenger_procs = {
		value = "0 / 0 / 0",
		name = "scavenger_procs"
	}
end

--- create lookup for iterating
--- data_stat_name used for "More Player Data" tab
local new_categories_lookup = {
	{
		setting = MOD_SETTINGS.SCOREBOARD_FF.save,
		global_var_name = "_init_scoreboard_ff",
		stat_name = "ff",
	},
	{
		setting = MOD_SETTINGS.SCOREBOARD_FF_SELF.save,
		global_var_name = "_init_scoreboard_ff_self",
		stat_name = "ff_self",
	},
	{
		setting = MOD_SETTINGS.SCOREBOARD_PLAYER_PROCS.save,
		global_var_name = "_init_scoreboard_local_data",
		stat_name = "local_data",
		data_stat_name = "heal_procs",
	},
	{
		setting = MOD_SETTINGS.SCOREBOARD_PLAYER_PROCS.save,
		global_var_name = "_init_scoreboard_local_data",
		stat_name = "local_data",
		data_stat_name = "scavenger_procs",
	},
}

--- related to register_damage hook
local register_damage_categories = {
	new_categories_lookup[1],
	new_categories_lookup[2],
}

local heal_procs_category = new_categories_lookup[3]
local scavenger_procs_category = new_categories_lookup[4]

local function remove_scoreboard_stat(init_var_name, stat_name)
	if rawget(_G, init_var_name) then
		for i,v in ipairs(ScoreboardHelper.scoreboard_topic_stats) do
			if v.stat_type == stat_name then
				table.remove(ScoreboardHelper.scoreboard_topic_stats, i)
				break
			end
		end
		rawset(_G, init_var_name, false)
	end
end

local function add_scoreboard_stat(init_var_name, stat_name)
	if not rawget(_G, init_var_name) then
		rawset(_G, init_var_name, true)
		table.insert(ScoreboardHelper.scoreboard_topic_stats, {
			stat_type = stat_name,
			display_text = "scoreboard_topic_"..stat_name,
			sort_function = function (a, b)
				return b.score < a.score
			end
		})
	end
end

-- check if we're tracking any new stats at all
local function any_category_enabled()
	local any_new_category = false
	for _, new_category in ipairs(new_categories_lookup) do
		any_new_category = any_new_category or user_setting(new_category.setting)
	end
	return any_new_category
end

--- hook some ScoreboardUI functions that crash on math.floor call if we use string scores in scoreboard
local function math_floor_hook(func, ...)
	if not any_category_enabled() then
		func(...)
		return
	end

	local original_math_floor = math.floor
	math.floor = function(num) return type(num) == "string" and num or original_math_floor(num) end
	func(...)
	math.floor = original_math_floor
end
Mods.hook.set(mod_name, "ScoreboardUI.update_topic_data", math_floor_hook)

Mods.hook.set(mod_name, "ScoreboardUI.set_player_list_data_by_index", function (func, self, topic_index)
	if not any_category_enabled() then
		func(self, topic_index)
		return
	end

	local topic_score_data = self.topic_score_data[topic_index]
	local topic_title_text = topic_score_data.display_text

	local original_ScoreboardUI_set_player_widget_name_by_index = ScoreboardUI.set_player_widget_name_by_index
	ScoreboardUI.set_player_widget_name_by_index = function (scoreboard_ui, player_index, name)
		if topic_title_text ~= "scoreboard_topic_local_data" then
			return original_ScoreboardUI_set_player_widget_name_by_index(scoreboard_ui, player_index, name)
		end
		local player_entry_widgets = scoreboard_ui.player_entry_widgets
		local widget = player_entry_widgets[player_index]
		local player_name = ""
		if player_index == 1 then
			player_name = "Health gained from regrowth and bloodlust procs, melee/ranged/total"
		end
		if player_index == 2 then
			player_name = "Ammo gained from scavenger procs, melee/ranged/total"
		end

		widget.content.title_text = player_name
	end

	local original_ScoreboardUI_sset_player_widget_score_by_index = ScoreboardUI.set_player_widget_score_by_index
	ScoreboardUI.set_player_widget_score_by_index = function (scoreboard_ui, player_index, score)
		if topic_title_text ~= "scoreboard_topic_local_data" then
			return original_ScoreboardUI_sset_player_widget_score_by_index(scoreboard_ui, player_index, score)
		end

		local player_entry_widgets = self.player_entry_widgets

		local statistics_db = Managers.player:statistics_db()
		local local_player = Managers.player:local_player()
		local stats_id = local_player:stats_id()

		score = ""
		if player_index == 1 then
			score = statistics_db.get_stat(statistics_db, stats_id, heal_procs_category.data_stat_name)
		end
		if player_index == 2 then
			score = statistics_db.get_stat(statistics_db, stats_id, scavenger_procs_category.data_stat_name)
		end

		player_entry_widgets[player_index].content.score_text = score
	end

	local original_ScoreboardUI_set_player_widget_icon_by_index = ScoreboardUI.set_player_widget_icon_by_index
	ScoreboardUI.set_player_widget_icon_by_index = function (scoreboard_ui, player_index, icon_texture)
		local player_entry_widgets = scoreboard_ui.player_entry_widgets
		player_entry_widgets[player_index].style.icon.color[1] = 255

		if topic_title_text ~= "scoreboard_topic_local_data" then
			return original_ScoreboardUI_set_player_widget_icon_by_index(scoreboard_ui, player_index, icon_texture)
		end

		player_entry_widgets[player_index].style.icon.color[1] = 0
	end

	math_floor_hook(func, self, topic_index)

	ScoreboardUI.set_player_widget_name_by_index = original_ScoreboardUI_set_player_widget_name_by_index
	ScoreboardUI.set_player_widget_icon_by_index = original_ScoreboardUI_set_player_widget_icon_by_index
	ScoreboardUI.set_player_widget_score_by_index = original_ScoreboardUI_sset_player_widget_score_by_index
end)

local PROC_TYPE_HP = 1
local PROC_TYPE_SCAVENGER = 2

--- update database on heal proc
local function on_proc(proc_type, amount)
	local proc_category = proc_type == PROC_TYPE_HP and heal_procs_category
							or proc_type == PROC_TYPE_SCAVENGER and scavenger_procs_category

	if not proc_category then
		return
	end

	--- OR all local data settings to get enabled
	local enabled = user_setting(heal_procs_category.setting) or user_setting(scavenger_procs_category.setting)
	if enabled then
		add_scoreboard_stat(proc_category.global_var_name, proc_category.stat_name)
	else
		remove_scoreboard_stat(proc_category.global_var_name, proc_category.stat_name)
	end

	if not enabled then
		return
	end

	local statistics_db = Managers.player:statistics_db()
	local local_player = Managers.player:local_player()
	local stats_id = local_player:stats_id()

	local db_value = statistics_db.get_stat(statistics_db, stats_id, proc_category.data_stat_name)
	local melee, ranged, total = string.match(db_value, "(%d+) / (%d+) / (%d+)")

	local local_player_unit = local_player.player_unit
	if local_player_unit and ScriptUnit.has_extension(local_player_unit, "inventory_system") then
		local inventory_extension = ScriptUnit.extension(local_player_unit, "inventory_system")
		if inventory_extension then
			local wielded_slot_name = inventory_extension.get_wielded_slot_name(inventory_extension)
			if wielded_slot_name == "slot_melee" then
				melee = melee + amount
			elseif wielded_slot_name == "slot_ranged" then
				ranged = ranged + amount
			end
			total = total + amount
		end
	end

	statistics_db.set_stat(statistics_db, stats_id, proc_category.data_stat_name, melee.." / "..ranged.." / "..total)
end

--- regrowth tracking
Mods.hook.set(mod_name, "DamageUtils.buff_on_attack", function (func, unit, hit_unit, attack_type, ...)
	if not user_setting(MOD_SETTINGS.SCOREBOARD_PLAYER_PROCS.save) then
		return func(unit, hit_unit, attack_type, ...)
	end

	local original_BuffExtension_apply_buffs_to_value = BuffExtension.apply_buffs_to_value
	BuffExtension.apply_buffs_to_value = function (self, value, stat_buff)
		local amount, procced, parent_id = original_BuffExtension_apply_buffs_to_value(self, value, stat_buff)
		if procced
			and (stat_buff == StatBuffIndex.HEAL_PROC or stat_buff == StatBuffIndex.LIGHT_HEAL_PROC or stat_buff == StatBuffIndex.HEAVY_HEAL_PROC)
			and unit == Managers.player:local_player().player_unit
			then
				on_proc(PROC_TYPE_HP, amount)
		end
		return amount, procced, parent_id
	end

	local return_val = func(unit, hit_unit, attack_type, ...)

	BuffExtension.apply_buffs_to_value = original_BuffExtension_apply_buffs_to_value

	return return_val
end)

--- bloodlust tracking
local function DeathReactions_start_hook(func, unit, dt, context, t, killing_blow, is_server, cached_wall_nail_data)
	if killing_blow[DamageDataIndex.ATTACKER] ~= Managers.player:local_player().player_unit then
		return func(unit, dt, context, t, killing_blow, is_server, cached_wall_nail_data)
	end

	local original_BuffExtension_apply_buffs_to_value = BuffExtension.apply_buffs_to_value
	BuffExtension.apply_buffs_to_value = function (self, value, stat_buff)
		local amount, procced, parent_id = original_BuffExtension_apply_buffs_to_value(self, value, stat_buff)
		if procced and stat_buff == StatBuffIndex.HEAL_ON_KILL and user_setting(MOD_SETTINGS.SCOREBOARD_PLAYER_PROCS.save) then
			on_proc(PROC_TYPE_HP, amount)
		end
		return amount, procced, parent_id
	end

	local ammo_proc_amount = nil
	local original_GenericAmmoUserExtension_add_ammo_to_reserve = GenericAmmoUserExtension.add_ammo_to_reserve
	GenericAmmoUserExtension.add_ammo_to_reserve = function (self, amount)
		ammo_proc_amount = amount
		return original_GenericAmmoUserExtension_add_ammo_to_reserve(self, amount)
	end

	local return_val_1, return_val_2 = func(unit, dt, context, t, killing_blow, is_server, cached_wall_nail_data)

	if ammo_proc_amount then
		on_proc(PROC_TYPE_SCAVENGER, ammo_proc_amount)
	end

	GenericAmmoUserExtension.add_ammo_to_reserve = original_GenericAmmoUserExtension_add_ammo_to_reserve
	BuffExtension.apply_buffs_to_value = original_BuffExtension_apply_buffs_to_value

	return return_val_1, return_val_2
end

for breed_name,template in pairs(DeathReactions.templates) do
	if template.unit and template.husk and template.unit.start and template.husk.start then
		Mods.hook.set(mod_name, "DeathReactions.templates."..breed_name..".unit.start", DeathReactions_start_hook)
		Mods.hook.set(mod_name, "DeathReactions.templates."..breed_name..".husk.start", DeathReactions_start_hook)
	end
end

--- localize scoreboard category title
Mods.hook.set(mod_name, "Localize", function (func, id, ...)
	if id == "scoreboard_topic_ff" then
		return "Friendly Fire"
	end

	if id == "scoreboard_topic_ff_self" then
		return "Damage To Self"
	end

	if id == "scoreboard_topic_local_data" then
		return "More Player Data"
	end

	return func(id, ...)
end)

--- Fixed topic order
local topics = {
	"scoreboard_topic_damage_taken",
	"scoreboard_topic_damage_dealt",
	"scoreboard_topic_damage_bosses",

	"scoreboard_topic_kills_total",
	"scoreboard_topic_kills_melee",
	"scoreboard_topic_kills_ranged",

	"scoreboard_topic_kills_skaven_core_rats",
	"scoreboard_topic_kills_specials",
	"scoreboard_topic_kills_skaven_storm_vermin",

	"scoreboard_topic_headshots",
	"scoreboard_topic_saved_companion",
	"scoreboard_topic_aided_companion",

	"scoreboard_topic_ff",
	"scoreboard_topic_ff_self",
	"scoreboard_topic_local_data",
}

Mods.hook.set(mod_name, "ScoreboardUI.init", function (func, self, end_of_level_ui_context)
	if not user_setting(MOD_SETTINGS.SCOREBOARD_FIXED_ORDER.save) then
		func(self, end_of_level_ui_context)
		return
	end

	local scoreboard_session_data = end_of_level_ui_context.scoreboard_session_data

	-- create lookup table: topic_name as key, topic weight as value
	local topics_lookup = {}
	for i=1, #topics do
		topics_lookup[topics[i]] = i
	end

	-- sort using the lookup
	table.sort(scoreboard_session_data[1],
	        function(topic1, topic2)
	            return topics_lookup[topic1.display_text] < topics_lookup[topic2.display_text]
	        end
	    )

	func(self, end_of_level_ui_context)
end)

--[[
	Damage Taken Scoreboard Fix, by Grundlid.
--]]
Mods.hook.set(mod_name, "GenericUnitDamageExtension.add_damage", function (func, self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)
	local any_new_category = false -- just return later if we're not tracking any new category
	for _, new_category in ipairs(register_damage_categories) do
		local enabled = user_setting(new_category.setting)
		any_new_category = any_new_category or enabled
		if enabled then
			add_scoreboard_stat(new_category.global_var_name, new_category.stat_name)
		else
			remove_scoreboard_stat(new_category.global_var_name, new_category.stat_name)
		end
	end

	-- self dmg and ff handling
	if any_new_category then
		local player_manager = Managers.player
		local player = player_manager.owner(player_manager, self.unit)

		local statistics_db = Managers.player:statistics_db()

		if player and ScriptUnit.has_extension(self.unit, "health_system") and ScriptUnit.has_extension(self.unit, "buff_system") then
			local health_extension = ScriptUnit.extension(self.unit, "health_system")
			local buff_extension = ScriptUnit.extension(self.unit, "buff_system")
			local overflow = health_extension.damage + damage_amount - health_extension.health
			local self_ff_damage = damage_amount
			if buff_extension:has_buff_type("knockdown bleed") then
				self_ff_damage = 0
			elseif overflow > 0 then
				self_ff_damage = damage_amount - overflow
			end

			local actual_attacker_unit = AiUtils.get_actual_attacker_unit(attacker_unit)
			local player_attacker = player_manager.owner(player_manager, actual_attacker_unit)

			-- wounded_dot is white hp bleedout, kinetic is falling dmg
			if player_attacker and self_ff_damage > 0 and damage_type ~= "wounded_dot" and damage_type ~= "knockdown_bleed" and damage_type ~= "kinetic" then
				local stats_id = player_attacker.stats_id(player_attacker)
				if actual_attacker_unit == self.unit then
					statistics_db.modify_stat_by_amount(statistics_db, stats_id, "ff_self", self_ff_damage)
				else
					statistics_db.modify_stat_by_amount(statistics_db, stats_id, "ff", self_ff_damage)
				end
			end
		end
	end

	if not user_setting(MOD_SETTINGS.DAMAGE_TAKEN.save) then
		return func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)
	end

	local original_register_damage = StatisticsUtil.register_damage

	if Managers.player:owner(self.unit) and ScriptUnit.has_extension(self.unit, "health_system") and ScriptUnit.has_extension(self.unit, "buff_system") then
		local health_extension = ScriptUnit.extension(self.unit, "health_system")
		local buff_extension = ScriptUnit.extension(self.unit, "buff_system")

		StatisticsUtil.register_damage = function(victim_unit, damage_data, statistics_db)
			local overflow = health_extension.damage + damage_amount - health_extension.health -- overflow is the overkill dmg on player killing blow
			if buff_extension:has_buff_type("knockdown bleed") then
				damage_data[DamageDataIndex.DAMAGE_AMOUNT] = 0
			elseif overflow > 0 then
				damage_data[DamageDataIndex.DAMAGE_AMOUNT] = math.max(0, damage_data[DamageDataIndex.DAMAGE_AMOUNT] - overflow)
			end
			original_register_damage(victim_unit, damage_data, statistics_db)
		end
	end

	func(self, attacker_unit, damage_amount, hit_zone_name, damage_type, damage_direction, damage_source_name, hit_ragdoll_actor, damaging_unit)

	StatisticsUtil.register_damage = original_register_damage
end)

--- options
safe_pcall(function()
	local group = "scoreboard"
	Mods.option_menu:add_group(group, "Scoreboard Improvements")
	Mods.option_menu:add_item(group, MOD_SETTINGS.SCOREBOARD_FIXED_ORDER, true)
	Mods.option_menu:add_item(group, MOD_SETTINGS.DAMAGE_TAKEN, true)
	Mods.option_menu:add_item(group, MOD_SETTINGS.SCOREBOARD_FF, true)
	Mods.option_menu:add_item(group, MOD_SETTINGS.SCOREBOARD_FF_SELF, true)
	Mods.option_menu:add_item(group, MOD_SETTINGS.SCOREBOARD_PLAYER_PROCS, true)
end)
