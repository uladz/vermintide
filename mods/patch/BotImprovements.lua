local mod_name = "BotImprovements"
--[[
	authors: grimalackt, iamlupo, walterr

	Bot Improvements.
--]]

local MANUAL_HEAL_DISABLED = 1
local MANUAL_HEAL_OPTIONAL = 2
local MANUAL_HEAL_MANDATORY = 3

local oi = OptionsInjector

BotImprovements = {
	SETTINGS = {
		PREFER_SALTZBOT = {
			["save"] = "cb_bot_improvements_prefer_saltzbot",
			["widget_type"] = "stepper",
			["text"] = "Choose Saltzpyre as Bot",
			["tooltip"] = "Choose Saltzpyre as Bot\n" ..
				"Choose Saltzpyre as a bot in preference to Sienna.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		OVERRIDE_LEFT_PLAYER = {
			["save"] = "cb_override_left_player",
			["widget_type"] = "stepper",
			["text"] = "Override Leaving Player Bot",
			["tooltip"] =  "Override Leaving Player Bot\n" ..
				"Reverts back to default bot if a player leaves with the normally unused bot (Saltzpyre or Sienna, depending on above setting).",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default first option is enabled. In this case On
		},
		STAY_CLOSER = {
			["save"] = "cb_bot_improvements_stay_closer",
			["widget_type"] = "stepper",
			["text"] = "Bots Stay Closer During Hordes",
			["tooltip"] = "Bots Stay Closer During Hordes\n" ..
				"Bots will stay closer to humans when many rats are aggro'd.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		NO_CHASE_RATLING = {
			["save"] = "cb_bot_improvements_no_chase_ratling",
			["widget_type"] = "stepper",
			["text"] = "Bots Should Not Chase Ratlings",
			["tooltip"] = "Bots Should Not Chase Ratlings\n" ..
				"Prevents bots from running off to melee Ratling Gunners.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
		},
		NO_CHASE_GLOBADIER = {
			["save"] = "cb_bot_improvements_no_chase_globadier",
			["widget_type"] = "stepper",
			["text"] = "Bots Should Not Chase Globadiers",
			["tooltip"] = "Bots Should Not Chase Globadiers\n" ..
				"Prevents bots from running off to melee Globadiers.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
		},
		NO_SEEK_COVER = {
			["save"] = "cb_bot_improvements_no_seek_cover",
			["widget_type"] = "stepper",
			["text"] = "Bots Should Ignore Ratling Fire",
			["tooltip"] = "Bots Should Ignore Ratling Fire\n" ..
				"Prevents bots from running off to seek cover from Ratling " ..
				"Gunner fire, even if they are being shot (use with caution).",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
		},
		BETTER_MELEE = {
			["save"] = "cb_bot_improvements_better_melee",
			["widget_type"] = "stepper",
			["text"] = "Improved Bot Melee Choices",
			["tooltip"] = "Improved Bot Melee Choices\n" ..
				"Improves bots' decision-making about which melee attack to use.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		FASTER_AIM = {
			["save"] = "cb_bot_improvements_faster_aim",
			["widget_type"] = "stepper",
			["text"] = "Faster Bot Aiming",
			["tooltip"] = "Faster Bot Aiming\n" ..
				"Drastically improves bots' aiming speed and will to fire.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		MANUAL_HEAL = {
			["save"] = "cb_bot_improvements_manual_heal",
			["widget_type"] = "dropdown",
			["text"] = "Manual Control of Bot Healing",
			["tooltip"] = "Manual Control of Bot Healing\n" ..
				"Allows manual control of bot healing.\n\n" ..
				"Holding numpad 0 will make one of the bots heal you, if it has a medkit.\n" ..
				"Holding numpad 1, 2, or 3 will make a bot heal the hero at the 1st, 2nd, or 3rd " ..
				"position on the HUD (which may be itself).\n\n" ..
				"-- OFF --\nThe feature is disabled, bots heal automatically as usual.\n\n" ..
				"-- AS WELL AS AUTO --\nBots will still heal automatically, but you can also " ..
					"manually force them to heal.\n\n" ..
				"-- INSTEAD OF AUTO --\nBots will only heal if you manually force them to do so.",
			["value_type"] = "number",
			["options"] = {
				{text = "Off", value = MANUAL_HEAL_DISABLED},
				{text = "As Well as Auto", value = MANUAL_HEAL_OPTIONAL},
				{text = "Instead of Auto", value = MANUAL_HEAL_MANDATORY},
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
			["hide_options"] = {
				{
					1,
					mode = "hide",
					options = {
						"cb_bot_improvements_manual_heal_hotkey1",
						"cb_bot_improvements_manual_heal_hotkey2",
						"cb_bot_improvements_manual_heal_hotkey3",
						"cb_bot_improvements_manual_heal_hotkey4",
					}
				},
				{
					2,
					mode = "show",
					options = {
						"cb_bot_improvements_manual_heal_hotkey1",
						"cb_bot_improvements_manual_heal_hotkey2",
						"cb_bot_improvements_manual_heal_hotkey3",
						"cb_bot_improvements_manual_heal_hotkey4",
					}
				},
				{
					3,
					mode = "show",
					options = {
						"cb_bot_improvements_manual_heal_hotkey1",
						"cb_bot_improvements_manual_heal_hotkey2",
						"cb_bot_improvements_manual_heal_hotkey3",
						"cb_bot_improvements_manual_heal_hotkey4",
					}
				},
			},
		},
		MANUAL_HEAL_KEY1 = {
			["save"] = "cb_bot_improvements_manual_heal_hotkey1",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal First Hero",
			["default"] = {
				"numpad 0",
			},
		},
		MANUAL_HEAL_KEY2 = {
			["save"] = "cb_bot_improvements_manual_heal_hotkey2",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal Second Hero",
			["default"] = {
				"numpad 1",
			},
		},
		MANUAL_HEAL_KEY3 = {
			["save"] = "cb_bot_improvements_manual_heal_hotkey3",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal Third Hero",
			["default"] = {
				"numpad 2",
			},
		},
		MANUAL_HEAL_KEY4 = {
			["save"] = "cb_bot_improvements_manual_heal_hotkey4",
			["widget_type"] = "modless_keybind",
			["text"] = "Heal Fourth Hero",
			["default"] = {
				"numpad 3",
			},
		},
		FASTER_TRADING = {
			["save"] = "cb_bot_improvements_faster_trading",
			["widget_type"] = "stepper",
			["text"] = "Bots Trade Items Faster",
			["tooltip"] = "Bots Trade Items Faster\n" ..
				"Improves the efficiency and logic by which bots will trade items to you/each other.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		LOOT_GRIMOIRES = {
			["save"] = "cb_bot_improvements_loot_grimoires",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Grimoires",
			["tooltip"] = "Bots Pick Up Pinged Grimoires\n" ..
				"Allows bots to pick up a grimoire when a human player pings the grimoire.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		LOOT_TOMES = {
			["save"] = "cb_bot_improvements_loot_tomes",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Tomes",
			["tooltip"] = "Bots Pick Up Pinged Tomes\n" ..
				"Allows bots to pick up a tome when a human player pings the tome.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		LOOT_POTIONS = {
			["save"] = "cb_bot_improvements_loot_potions",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Potions",
			["tooltip"] = "Bots Pick Up Pinged Potions\n" ..
				"Allows bots to pick up a potion when a human player pings the potion. " ..
				"Bots will only pick up potions when no human has an empty potion slot.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		LOOT_GRENADES = {
			["save"] = "cb_bot_improvements_loot_grenades",
			["widget_type"] = "stepper",
			["text"] = "Bots Pick Up Pinged Grenades",
			["tooltip"] = "Bots Pick Up Pinged Grenades\n" ..
				"Allows bots to pick up a grenade when a human player pings the grenade. " ..
				"Bots will only pick up grenades when no human has an empty grenade slot.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		KEEP_TOMES = {
			["save"] = "cb_bot_improvements_keep_tomes",
			["widget_type"] = "stepper",
			["text"] = "Bots Keep Tomes",
			["tooltip"] = "Bots Keep Tomes\n" ..
				"Stop bots from exchanging tomes for healing items, \n"..
				"unless they are wounded enough to use them or the healing item is pinged.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		PING_STORMVERMINS = {
			["save"] = "cb_bot_improvements_ping_stormvermins",
			["widget_type"] = "stepper",
			["text"] = "Bots Ping Attacking Stormvermins",
			["tooltip"] = "Bots Ping Attacking Stormvermins\n" ..
				"Allows bots to ping stormvermins that are targeting them. " ..
				"Limited to one stormvermin at a time.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		FIX_REVIVE = {
			["save"] = "cb_bot_improvements_fix_revive",
			["widget_type"] = "stepper",
			["text"] = "Fix Revive",
			["tooltip"] = "Fix Revive\n" ..
				"Bots will no longer fail to revive when targeted by a stormvermin.\n",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		REDUCE_PICKUP_TRAVEL = {
			["save"] = "cb_bot_improvements_reduce_pickup_travel",
			["widget_type"] = "stepper",
			["text"] = "Reduce Pickup Travel Distance",
			["tooltip"] = "Reduce Pickup Travel Distance\n" ..
				"Reduces the distance bots will travel away from human players to " ..
				"pick up health items, potions, and grenades.  If this option is " ..
				"enabled, bots will only pick up such items if the human player they " ..
				"are following is standing close to the item.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default second option is enabled. In this case Off
		},
		FOLLOW = {
			["save"] = "cb_follow_host",
			["widget_type"] = "stepper",
			["text"] = "Follow the host",
			["tooltip"] =  "Follow Host\n" ..
				"Bots will prioritize following the host.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
		},
		BOTS_BLOCK_ON_PATH_SEARCH = {
			["save"] = "cb_bot_improvements_extra_block_pathing",
			["widget_type"] = "stepper",
			["text"] = "Block While Path-Searching",
			["tooltip"] = "Block While Path-Searching\n" ..
				"Bots block as they pause to search for a path to the player.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
		},
		AUTOEQUIP = {
			["save"] = "cb_autoequip",
			["widget_type"] = "stepper",
			["text"] = "Autoequip bots from a loadout slot",
			["tooltip"] =  "Autoequip bots from a loadout slot\n" ..
				"Autoequip bots from a dedicated loadout slot.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 1, -- Default first option is enabled. In this case Off
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_autoequip_slot",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_autoequip_slot",
					}
				},
			},
		},
		AUTOEQUIP_SLOT = {
			["save"] = "cb_autoequip_slot",
			["widget_type"] = "stepper",
			["text"] = "Loadout slot to use",
			["tooltip"] = "Loadout slot to use\n" ..
				"Autoequip bot from this loadout slot.\n" ..
				"ONLY CHANGEABLE IN INN!",
			["value_type"] = "number",
			["options"] = (function()
					local stepper = {}
					for i=1,9 do
						table.insert(stepper, {text = tostring(i), value = i})
					end
					return stepper
					end)(),
			["default"] = 1, -- Default to 1
			["disabled_outside_inn"] = true, -- disabled_outside_inn setting only implemented on stepper widgets!
		},
	},
}

local me = BotImprovements

local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings

-- ############################################################################################################
-- ##### Options ##############################################################################################
-- ############################################################################################################
--[[
	Create options
--]]
BotImprovements.create_options = function()
	Mods.option_menu:add_group("bot_improvements", "Bot Improvements")

	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.PREFER_SALTZBOT, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.OVERRIDE_LEFT_PLAYER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.STAY_CLOSER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_CHASE_RATLING, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_CHASE_GLOBADIER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.NO_SEEK_COVER, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BETTER_MELEE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FASTER_AIM, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY1)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY2)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY3)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.MANUAL_HEAL_KEY4)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FASTER_TRADING, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_GRIMOIRES, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_TOMES, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_POTIONS, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.LOOT_GRENADES, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.KEEP_TOMES, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.PING_STORMVERMINS, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FIX_REVIVE, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.REDUCE_PICKUP_TRAVEL, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.FOLLOW, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.AUTOEQUIP, true)
	Mods.option_menu:add_item("bot_improvements", me.SETTINGS.AUTOEQUIP_SLOT)
end

-- ####################################################################################################################
-- ##### Implementation ###############################################################################################
-- ####################################################################################################################
--[[
	Prioritize Saltzpyre bot over Sienna when choosing which bots will be spawned. By Walterr.

	Only one line of this function is modified, but I have to replace the whole thing ...
--]]
SpawnManager._update_available_profiles = function (self, profile_synchronizer, available_profile_order, available_profiles)
	local delta = 0
	local bots = 0
	local humans = 0

	-- This is the modified line (1=WH, 2=BW, 3=DR, 4=WE, 5=ES).
	local profile_indexes = (get(me.SETTINGS.PREFER_SALTZBOT) and {2,1,3,4,5}) or {1,2,3,4,5}
	for _,profile_index in ipairs(profile_indexes) do
		local owner_type = profile_synchronizer.owner_type(profile_synchronizer, profile_index)

		if owner_type == "human" then
			humans = humans + 1
			local index = table.find(available_profile_order, profile_index)

			if index then
				table.remove(available_profile_order, index)

				available_profiles[profile_index] = false
				delta = delta - 1
			end
		elseif (owner_type == "available" or owner_type == "bot") and not table.contains(available_profile_order, profile_index) then
			table.insert(available_profile_order, 1, profile_index)

			available_profiles[profile_index] = true
			delta = delta + 1
		end

		if owner_type == "bot" then
			bots = bots + 1
		end
	end

	if self._forced_bot_profile_index then
		local forced_bot_profile_index = self._forced_bot_profile_index
		local index = table.find(available_profile_order, forced_bot_profile_index)
		local available = (index and profile_synchronizer.owner_type(profile_synchronizer, forced_bot_profile_index) == "available") or false

		fassert(available, "Bot profile (%s) is not available!", SPProfilesAbbreviation[forced_bot_profile_index])

		if index ~= 1 then
			available_profile_order[index] = available_profile_order[1]
			available_profile_order[1] = available_profile_order[index]
		end
	end

	return delta, humans, bots
end

--[[
	Will make the bots stick closer to players, especially during swarms. By Walterr.
--]]
Mods.hook.set(mod_name, "AISystem.update_brains", function (func, self, ...)
	local result = func(self, ...)

	if get(me.SETTINGS.STAY_CLOSER) then
		local fight_melee = BotActions.default.fight_melee
		local aggro_level = (self.number_ordinary_aggroed_enemies * 2 / 3)
		fight_melee.engage_range_near_follow_pos = math.max(3, 15 - aggro_level)
		fight_melee.engage_range = math.max(2, 6 - aggro_level)
		fight_melee.engage_range_near_follow_pos_horde = math.max(3, 9 - aggro_level)
	end

	return result
end)

Mods.hook.set(mod_name, "PlayerBotBase._enemy_path_allowed", function (func, self, enemy_unit)
	local breed = Unit.get_data(enemy_unit, "breed")

	if (breed == Breeds.skaven_ratling_gunner and get(me.SETTINGS.NO_CHASE_RATLING)) or
			(breed == Breeds.skaven_poison_wind_globadier and get(me.SETTINGS.NO_CHASE_GLOBADIER)) then
		return false
	end

	return func(self, enemy_unit)
end)

Mods.hook.set(mod_name, "PlayerBotBase._in_line_of_fire", function(func, ...)
	if get(me.SETTINGS.NO_SEEK_COVER) then
		return false, false
	end

	return func(...)
end)

--[[
	Improve bot melee behaviour. By Grimalackt.
--]]
Mods.hook.set(mod_name, "BTBotMeleeAction._attack", function(func, self, unit, blackboard, input_ext, target_unit)
	if not get(me.SETTINGS.BETTER_MELEE) then
		return func(self, unit, blackboard, input_ext, target_unit)
	end

	local num_enemies = #blackboard.proximite_enemies
	local outnumbered = 1 < num_enemies
	local massively_outnumbered = 3 < num_enemies
	local target_breed = Unit.get_data(target_unit, "breed")
	local target_armor = (target_breed and target_breed.armor_category) or 1
	local inventory_ext = blackboard.inventory_extension
	local wielded_slot_name = inventory_ext.get_wielded_slot_name(inventory_ext)
	local slot_data = inventory_ext.get_slot_data(inventory_ext, wielded_slot_name)
	local item_data = slot_data.item_data
	local item_template = BackendUtils.get_item_template(item_data)
	local DEFAULT_ATTACK_META_DATA = {
		tap_attack = {
			penetrating = false,
			arc = 0
		},
		hold_attack = {
			penetrating = true,
			arc = 2
		}
	}
	local weapon_meta_data = item_template.attack_meta_data or DEFAULT_ATTACK_META_DATA

	if item_data.item_type == "bw_1h_sword" or item_data.item_type == "es_1h_sword" or item_data.item_type == "bw_flame_sword" then
		weapon_meta_data.tap_attack = {
			penetrating = false,
			arc = 2
		}
	end

	if item_data.item_type == "ww_2h_axe" then
		weapon_meta_data.tap_attack = {
			penetrating = true,
			arc = 2
		}
	end

	local best_utility = -1
	local best_attack_input = nil

	for attack_input, attack_meta_data in pairs(weapon_meta_data) do
		local utility = 0

		if (not outnumbered) and attack_meta_data.arc ~= 1 then
			utility = utility + 1
		end

		if target_armor ~= 2 or attack_meta_data.penetrating then
			utility = utility + 8
		end

		if best_utility < utility then
			best_utility = utility
			best_attack_input = attack_input
		end
	end

	input_ext[best_attack_input](input_ext)
	return
end)

Mods.hook.set(mod_name, "BTBotMeleeAction._defend", function(func, self, unit, blackboard, target_unit, input_ext, t, in_melee_range)
	if not get(me.SETTINGS.BETTER_MELEE) then
		return func(self, unit, blackboard, target_unit, input_ext, t, in_melee_range)
	end

	if self._is_attacking_me(self, unit, target_unit) then
		if not in_melee_range then
			input_ext.defend(input_ext)
		elseif Unit.get_data(target_unit, "breed") and Unit.get_data(target_unit, "breed").name == "skaven_rat_ogre" then
			input_ext.defend(input_ext)
			input_ext.dodge(input_ext)
		elseif Unit.get_data(target_unit, "breed") and Unit.get_data(target_unit, "breed").name == "skaven_storm_vermin_champion" then
			input_ext.defend(input_ext)
		else
			input_ext.melee_push(input_ext)
		end

		return true
	else
		return false
	end

	return
end)

--[[
	Drastically improves bots' aiming speed and will to fire. By Grimalackt.
--]]
Mods.hook.set(mod_name, "BTBotShootAction._calculate_aim_speed",
function(func, self, self_unit, dt, current_yaw, current_pitch, wanted_yaw, wanted_pitch, current_yaw_speed, current_pitch_speed)
	if not get(me.SETTINGS.FASTER_AIM) then
		return func(self, self_unit, dt, current_yaw, current_pitch, wanted_yaw, wanted_pitch, current_yaw_speed, current_pitch_speed)
	end

	local pi = math.pi
	local yaw_offset = (wanted_yaw - current_yaw + pi)%(pi*2) - pi
	local pitch_offset = wanted_pitch - current_pitch
	local yaw_offset_sign = math.sign(yaw_offset)
	local yaw_speed_sign = math.sign(current_yaw_speed)
	local has_overshot = yaw_speed_sign ~= 0 and yaw_offset_sign ~= yaw_speed_sign
	local wanted_yaw_speed = yaw_offset*math.pi*10
	local new_yaw_speed = nil
	local acceleration = 30
	local deceleration = 40

	if has_overshot and 0 < yaw_offset_sign then
		new_yaw_speed = math.min(current_yaw_speed + deceleration*dt, 0)
	elseif has_overshot then
		new_yaw_speed = math.max(current_yaw_speed - deceleration*dt, 0)
	elseif 0 < yaw_offset_sign then
		if current_yaw_speed <= wanted_yaw_speed then
			new_yaw_speed = math.min(current_yaw_speed + acceleration*dt, wanted_yaw_speed)
		else
			new_yaw_speed = math.max(current_yaw_speed - deceleration*dt, wanted_yaw_speed)
		end
	elseif wanted_yaw_speed <= current_yaw_speed then
		new_yaw_speed = math.max(current_yaw_speed - acceleration*dt, wanted_yaw_speed)
	else
		new_yaw_speed = math.min(current_yaw_speed + deceleration*dt, wanted_yaw_speed)
	end

	local lerped_pitch_speed = pitch_offset/dt

	return new_yaw_speed, lerped_pitch_speed
end)

Mods.hook.set(mod_name, "BTBotShootAction._aim_good_enough", function(func, self, dt, t, shoot_blackboard, yaw_offset, pitch_offset)
	if not get(me.SETTINGS.FASTER_AIM) then
		return func(self, dt, t, shoot_blackboard, yaw_offset, pitch_offset)
	end

	local bb = shoot_blackboard

	if not bb.reevaluate_aim_time then
		bb.reevaluate_aim_time = 0
	end

	local aim_data = bb.aim_data

	if bb.reevaluate_aim_time < t then
		local offset = math.sqrt(pitch_offset*pitch_offset + yaw_offset*yaw_offset)

		if (aim_data.max_radius / 50) < offset then
			bb.aim_good_enough = false

			dprint("bad aim - offset:", offset)
		else
			local success = nil
			local num_rolls = bb.num_aim_rolls + 1

			if offset < aim_data.min_radius then
				success = Math.random() < aim_data.min_radius_pseudo_random_c*num_rolls
			else
				local prob = math.auto_lerp(aim_data.min_radius, aim_data.max_radius, aim_data.min_radius_pseudo_random_c, aim_data.max_radius_pseudo_random_c, offset)*num_rolls
				success = Math.random() < prob
			end

			success = true

			if success then
				bb.aim_good_enough = true
				bb.num_aim_rolls = 0

				dprint("fire! - offset:", offset, " num_rolls:", num_rolls)
			else
				bb.aim_good_enough = false
				bb.num_aim_rolls = num_rolls

				dprint("not yet - offset:", offset, " num_rolls:", num_rolls)
			end
		end

		bb.reevaluate_aim_time = t + 0.1
	end

	return bb.aim_good_enough
end)

Mods.hook.set(mod_name, "BTBotShootAction._is_shot_obstructed", function(func, self, physics_world, from, direction, self_unit, target_unit, actual_aim_position, collision_filter)
	if not get(me.SETTINGS.FASTER_AIM) then
		return func(self, physics_world, from, direction, self_unit, target_unit, actual_aim_position, collision_filter)
	end

	local INDEX_POSITION = 1
	local INDEX_DISTANCE = 2
	local INDEX_NORMAL = 3
	local INDEX_ACTOR = 4

	local max_distance = Vector3.length(actual_aim_position - from)

	PhysicsWorld.prepare_actors_for_raycast(physics_world, from, direction, 0.01, 0.5, max_distance*max_distance)

	local raycast_hits = PhysicsWorld.immediate_raycast(physics_world, from, direction, max_distance, "all", "collision_filter", collision_filter)

	if not raycast_hits then
		return false
	end

	local num_hits = #raycast_hits

	for i = 1, num_hits, 1 do
		local hit = raycast_hits[i]
		local hit_actor = hit[INDEX_ACTOR]
		local hit_unit = Actor.unit(hit_actor)

		if hit_unit == target_unit then
			return false
		elseif hit_unit ~= self_unit then
			local obstructed_by_static = Actor.is_static(hit_actor)

			if script_data.debug_unit == self_unit and script_data.debug_bot_obstruction then
				QuickDrawerStay:line(from, hit[INDEX_POSITION])
				QuickDrawerStay:sphere(hit[INDEX_POSITION], 0.05, Color(255, 0, 0))
			end

			if obstructed_by_static then
				return obstructed_by_static, max_distance - hit[INDEX_DISTANCE], obstructed_by_static
			end
		end
	end

	return false
end)

--[[
	Allow bots to loot pinged items. By Walterr, IamLupo and Grimalackt.
--]]
local pinged_grim = nil
local pinged_tome = nil
local pinged_potion = nil
local pinged_grenade = nil
local pinged_heal = nil
local pinged_storm = nil

Mods.hook.set(mod_name, "PingTargetExtension.set_pinged", function (func, self, pinged)
	if pinged then
		local pickup_extension = ScriptUnit.has_extension(self._unit, "pickup_system")
		local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()
		local is_inventory_item = pickup_settings and (pickup_settings.type == "inventory_item")
		local health_extension = ScriptUnit.has_extension(self._unit, "health_system") and
			Unit.get_data(self._unit, "breed") and
			(Unit.get_data(self._unit, "breed").name == "skaven_storm_vermin_commander"
			or Unit.get_data(self._unit, "breed").name == "skaven_storm_vermin") and
			ScriptUnit.extension(self._unit, "health_system")

		if is_inventory_item and (pickup_settings.item_name == "wpn_grimoire_01") and
				get(me.SETTINGS.LOOT_GRIMOIRES) then
			pinged_grim = self._unit
		else
			pinged_grim = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "wpn_side_objective_tome_01") and
				get(me.SETTINGS.LOOT_TOMES) then
			pinged_tome = self._unit
		else
			pinged_tome = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "potion_speed_boost_01" or
				pickup_settings.item_name == "potion_damage_boost_01") and
				get(me.SETTINGS.LOOT_POTIONS) then
			pinged_potion = self._unit
		else
			pinged_potion = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "grenade_frag_01" or
				pickup_settings.item_name == "grenade_frag_02" or
				pickup_settings.item_name == "grenade_fire_01" or
				pickup_settings.item_name == "grenade_fire_02") and
				get(me.SETTINGS.LOOT_GRENADES) then
			pinged_grenade = self._unit
		else
			pinged_grenade = nil
		end

		if is_inventory_item and (pickup_settings.item_name == "potion_healing_draught_01" or
				pickup_settings.item_name == "healthkit_first_aid_kit_01") and
				get(me.SETTINGS.KEEP_TOMES) then
			pinged_heal = self._unit
		else
			pinged_heal = nil
		end

		if health_extension then
			pinged_storm = self._unit
		end

	elseif self._unit == pinged_grim then
		pinged_grim = nil
	elseif self._unit == pinged_tome then
		pinged_tome = nil
	elseif self._unit == pinged_potion then
		pinged_potion = nil
	elseif self._unit == pinged_grenade then
		pinged_grenade = nil
	elseif self._unit == pinged_heal then
		pinged_heal = nil
	elseif self._unit == pinged_storm then
		pinged_storm = nil
	end

	return func(self, pinged)
end)

--[[
	Add BTConditions.can_loot_pinged_item:
		This checks the logic on whether or not bots can loot a specific item.
--]]
BTConditions.can_loot_pinged_item = function (blackboard)
	-- Avoids possible crash
	if blackboard.unit == nil then
		return false
	end

	local self_unit = blackboard.unit

	-- If bot is been attacked
	for _, enemy_unit in pairs(blackboard.proximite_enemies) do
		if Unit.alive(enemy_unit) and Unit.get_data(enemy_unit, "blackboard").target_unit == self_unit then
			return false
		end
	end

	if pinged_grim then
		local grim_posn = POSITION_LOOKUP[pinged_grim]

		-- Check if a player is near the grimoire
		local player_near_grimoire = false
		for i, player in pairs(Managers.player:human_players()) do
			if grim_posn and player.player_unit and (3.5 > Vector3.distance(POSITION_LOOKUP[player.player_unit], grim_posn)) then
				player_near_grimoire = true
			end
		end

		if not player_near_grimoire then
			return false
		end

		-- Check distance to grim
		if grim_posn and (14.0 < Vector3.distance(POSITION_LOOKUP[self_unit], grim_posn)) then
			return false
		end

		blackboard.interaction_unit = pinged_grim
		return true
	end

	if pinged_tome then
		local tome_posn = POSITION_LOOKUP[pinged_tome]
		local inventory_ext = ScriptUnit.extension(self_unit, "inventory_system")
		local health_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")

		-- Check if bot already has a tome
		if health_slot_data ~= nil then
			local item = inventory_ext.get_item_template(inventory_ext, health_slot_data)
  			if item.name == "wpn_side_objective_tome_01" then
				return false
			end
		end

		-- Case : Courier - 2nd tome - grabbing through barrel mini-game
		if tome_posn and tome_posn.x == -73.59222412109375 and tome_posn.y == 250.91647338867187 and tome_posn.z == 9.4020509719848633 and (3.5 < Vector3.distance(POSITION_LOOKUP[self_unit], tome_posn)) then
			return false
		end
		-- Case : Wizard's tower - 3rd tome - grabbing from below
		if tome_posn and tome_posn.x == 144.01631164550781 and tome_posn.y == 85.939056396484375 and tome_posn.z == 60.007415771484375 and (POSITION_LOOKUP[self_unit].z < tome_posn.z - 0.5) then
			return false
		end
		-- Check distance to tome
		if tome_posn and (7 < Vector3.distance(POSITION_LOOKUP[self_unit], tome_posn)) then
			return false
		end

		blackboard.interaction_unit = pinged_tome
		return true
	end

	if pinged_potion then
		local potion_posn = POSITION_LOOKUP[pinged_potion]
		local inventory_ext = ScriptUnit.extension(self_unit, "inventory_system")
		local potion_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_potion")
		-- Check if close-by players have free potion slot
		for i, player in pairs(Managers.player:human_players()) do
			if player.player_unit == nil then
				return false
			end
			local player_inventory_ext = ScriptUnit.extension(player.player_unit, "inventory_system")
			local player_potion_slot_data = player_inventory_ext.get_slot_data(player_inventory_ext, "slot_potion")

			if player_potion_slot_data == nil and potion_posn and (20.0 > Vector3.distance(POSITION_LOOKUP[player.player_unit], potion_posn)) then
				return false
			end
		end


		-- Check if bot already has a potion
		if potion_slot_data ~= nil then
			return false
		end

		-- Check distance to potion
		if potion_posn and (5.5 < Vector3.distance(POSITION_LOOKUP[self_unit], potion_posn)) then
			return false
		end

		blackboard.interaction_unit = pinged_potion
		return true
	end

	if pinged_grenade then
		local grenade_posn = POSITION_LOOKUP[pinged_grenade]
		local inventory_ext = ScriptUnit.extension(self_unit, "inventory_system")
		local grenade_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_grenade")

		-- Check if players have free grenade slot
		for i, player in pairs(Managers.player:human_players()) do
			if player.player_unit == nil then
				return false
			end
			local player_inventory_ext = ScriptUnit.extension(player.player_unit, "inventory_system")
			local player_grenade_slot_data = player_inventory_ext.get_slot_data(player_inventory_ext, "slot_grenade")

			if player_grenade_slot_data == nil and grenade_posn and (20.0 > Vector3.distance(POSITION_LOOKUP[player.player_unit], grenade_posn)) then
				return false
			end
		end


		-- Check if bot already has a grenade
		if grenade_slot_data ~= nil then
			return false
		end

		-- Check distance to grenade
		if grenade_posn and (5.5 < Vector3.distance(POSITION_LOOKUP[self_unit], grenade_posn)) then
			return false
		end

		blackboard.interaction_unit = pinged_grenade
		return true
	end

	return false
end

--[[
	Insert InteractAction into BotBehaviors for looting items.
--]]
local insert_bt_node = function(lua_node)
	local lua_tree = BotBehaviors.default
	for i = 1, math.huge, 1 do
		if not lua_tree[i] then
			EchoConsole("ERROR: insertion point not found")
			return
		elseif lua_tree[i].name == lua_node.name then
			--EchoConsole("ERROR: bt node " .. lua_node.name .. " already inserted")
			return
		elseif lua_tree[i].name == "in_combat" then
			table.insert(lua_tree, i, lua_node)
			return
		end
	end
end
insert_bt_node({
	"BTBotInteractAction",
	condition = "can_loot_pinged_item",
	name = "loot_pinged_item"
})

--[[
	Improve the efficiency with which bots trade items. Patch 1.8.3+. By Grimalackt.
--]]
local wasjusttraded = {}
Mods.hook.set(mod_name, "InventorySystem.rpc_give_equipment", function(func, self, sender, game_object_id, slot_id, item_name_id, position)
	func(self, sender, game_object_id, slot_id, item_name_id, position)
	local unit = self.unit_storage:unit(game_object_id)

	if Unit.alive(unit) and not ScriptUnit.extension(unit, "status_system"):is_dead() then
		local owner = Managers.player:owner(unit)
		if not owner.remote and owner.bot_player then
			local network_manager = Managers.state.network
			wasjusttraded[network_manager.unit_game_object_id(network_manager, unit)] = true
		end
	end
end)

local function can_interact_with_ally(self_unit, target_ally_unit)
	local interactable_extension = ScriptUnit.extension(target_ally_unit, "interactable_system")
	local interactor_unit = interactable_extension.is_being_interacted_with(interactable_extension)
	local can_interact_with_ally = interactor_unit == nil or interactor_unit == self_unit

	return can_interact_with_ally
end
Mods.hook.set(mod_name, "BTConditions.can_help_in_need_player", function (func, blackboard, args)
	if not get(me.SETTINGS.FASTER_TRADING) then
		return func(blackboard, args)
	end

	local need_type = args[1]

	if blackboard.target_ally_need_type == need_type then
		if need_type == "can_accept_heal_item" or need_type == "can_accept_potion" or need_type == "can_accept_grenade" then
			local ally_distance = blackboard.ally_distance
			local self_unit = blackboard.unit
			local network_manager = Managers.state.network
			local self_unit_id = network_manager.unit_game_object_id(network_manager, self_unit)

			if 5 < ally_distance then
				wasjusttraded[self_unit_id] = nil
			end

			if 3.75 < ally_distance then
				return false
			end

			local target_ally_unit = blackboard.target_ally_unit
			local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)

			if can_interact_with_ally and not wasjusttraded[self_unit_id] then
				return true
			end
		else
			local ally_distance = blackboard.ally_distance

			if 2.5 < ally_distance then
				return false
			end

			local self_unit = blackboard.unit
			local target_ally_unit = blackboard.target_ally_unit
			local destination_reached = blackboard.navigation_extension:destination_reached()
			local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)

			if can_interact_with_ally and destination_reached then
				return true
			end
		end
	end

	return
end)

Mods.hook.set(mod_name, "PlayerBotBase._alter_target_position", function (func, self, nav_world, self_position, unit, target_position, reason)
	local network_manager = Managers.state.network
	local unit_id = network_manager.unit_game_object_id(network_manager, self._unit)
	if get(me.SETTINGS.FASTER_TRADING) and (reason == "can_accept_grenade" or reason == "can_accept_potion" or reason == "can_accept_heal_item") and wasjusttraded[unit_id] then
		return
	else
		return func(self, nav_world, self_position, unit, target_position, reason)
	end
end)

--[[
	Allow bots to ping stormvermins attacking them. By Grimalackt.
--]]
BTConditions.can_ping_storm = function (blackboard)
	if not get(me.SETTINGS.PING_STORMVERMINS) then
		return false
	end

	-- Avoids possible crash
	if blackboard.unit == nil then
		return false
	end

	local self_unit = blackboard.unit

	if pinged_storm then
		local health_extension = ScriptUnit.has_extension(pinged_storm, "health_system") and ScriptUnit.extension(pinged_storm, "health_system")

		if health_extension and health_extension.current_health_percent(health_extension) <= 0 then
			pinged_storm = nil
		end
	end

	for _, enemy_unit in pairs(blackboard.proximite_enemies) do
		if Unit.alive(enemy_unit) and Unit.get_data(enemy_unit, "blackboard").target_unit == self_unit and
			(Unit.get_data(enemy_unit, "breed").name == "skaven_storm_vermin_commander" or Unit.get_data(enemy_unit, "breed").name == "skaven_storm_vermin") and
			ScriptUnit.extension(enemy_unit, "health_system").current_health_percent(ScriptUnit.extension(enemy_unit, "health_system")) > 0 and not pinged_storm then
			blackboard.interaction_unit = enemy_unit
			local network_manager = Managers.state.network
			local self_unit_id = network_manager.unit_game_object_id(network_manager, self_unit)
			local enemy_unit_id = network_manager.unit_game_object_id(network_manager, enemy_unit)
			network_manager.network_transmit:send_rpc_server("rpc_ping_unit", self_unit_id, enemy_unit_id)
			return true
		end
	end

	return false
end

local ping_stormvermin_action = {
	"BTBotInteractAction",
	condition = "can_ping_storm",
	name = "ping_stormvermin"
}

insert_bt_node(ping_stormvermin_action)

--[[
	This is literally a bugfix of Fatshark's code. Bots will no longer refuse to revive you if targeted by a stormvermin. By Grimalackt.
--]]
Mods.hook.set(mod_name, "BTConditions.can_revive", function (func, blackboard)
	if not get(me.SETTINGS.FIX_REVIVE) then
		return func(blackboard)
	end

	if blackboard.target_ally_need_type == "knocked_down" then
		local ally_distance = blackboard.ally_distance

		if 2.25 < ally_distance then
			return false
		end

		local self_unit = blackboard.unit
		local target_ally_unit = blackboard.target_ally_unit

		local destination_reached = blackboard.navigation_extension:destination_reached()
		local can_interact_with_ally = can_interact_with_ally(self_unit, target_ally_unit)
		local bot_stuck_threshold = 1

		if can_interact_with_ally and (destination_reached or ally_distance < 1.75 or Vector3.length_squared(blackboard.locomotion_extension:current_velocity()) < bot_stuck_threshold*bot_stuck_threshold) then
			return true
		end
	end

	return
end)

--[[
	Allow manual control of bot use of healing items. By Walterr.
--]]

local get_selected_player = function ()
	local selected_player_id = (((Keyboard.button(Keyboard.button_index(get(me.SETTINGS.MANUAL_HEAL_KEY1) or "numpad 0")) > 0.5) and 0) or
		((Keyboard.button(Keyboard.button_index(get(me.SETTINGS.MANUAL_HEAL_KEY2) or "numpad 1")) > 0.5) and 1) or
		((Keyboard.button(Keyboard.button_index(get(me.SETTINGS.MANUAL_HEAL_KEY3) or "numpad 2")) > 0.5) and 2) or
		((Keyboard.button(Keyboard.button_index(get(me.SETTINGS.MANUAL_HEAL_KEY4) or "numpad 3")) > 0.5) and 3))
	if not selected_player_id then
		return nil
	end

	local ingame_ui = Managers.matchmaking.ingame_ui
	local unit_frames_handler = ingame_ui and ingame_ui.ingame_hud.unit_frames_handler
	if unit_frames_handler then
		-- The unit frames and player_data are never nil, although player might be.
		return unit_frames_handler._unit_frames[selected_player_id + 1].player_data.player
	end
	return nil
end

local can_perform_heal = function (unit, heal_self)
		local inventory_ext = ScriptUnit.extension(unit, "inventory_system")
		local health_slot_data = inventory_ext:get_slot_data("slot_healthkit")
		if health_slot_data then
			local item_template = inventory_ext:get_item_template(health_slot_data)
			return (heal_self and item_template.can_heal_self) or ((not heal_self) and item_template.can_heal_other)
		end
		return false
end

local bot_heal_info = { player_unit = nil, healing_self = false }

Mods.hook.set(mod_name, "BTConditions.bot_should_heal", function (func, blackboard)
	local heal_option = get(me.SETTINGS.MANUAL_HEAL)

	if MANUAL_HEAL_MANDATORY ~= heal_option then
		local result = func(blackboard)
		if MANUAL_HEAL_DISABLED == heal_option or (result and not bot_heal_info.player_unit) then
			return result
		end
	end

	return bot_heal_info.healing_self and (bot_heal_info.player_unit == blackboard.unit)
end)

Mods.hook.set(mod_name, "PlayerBotBase._select_ally_by_utility", function(func, self, unit, blackboard, breed, t)
	local heal_option = get(me.SETTINGS.MANUAL_HEAL)
	if MANUAL_HEAL_DISABLED == heal_option then
		return func(self, unit, blackboard, breed, t)
	end

	local selected_player = get_selected_player()
	local selected_unit = selected_player and selected_player.player_unit
	if (selected_unit == unit) and selected_player.bot_player and can_perform_heal(unit, true) then
		bot_heal_info.player_unit = unit
		bot_heal_info.healing_self = true
		return nil, math.huge, nil

	elseif selected_unit and ((bot_heal_info.player_unit == nil and selected_unit ~= unit) or bot_heal_info.player_unit == unit) and
			can_perform_heal(unit, false) and not (selected_player.bot_player and can_perform_heal(selected_unit, true)) then
		bot_heal_info.player_unit = unit
		bot_heal_info.healing_self = false
		return selected_unit, Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[selected_unit]), "in_need_of_heal"

	elseif bot_heal_info.player_unit == unit then
		bot_heal_info.player_unit = nil
		bot_heal_info.healing_self = false
	end

	local ally_unit, real_dist, in_need_type = func(self, unit, blackboard, breed, t)

	-- Stop the bot from auto-healing someone if only manual healing is allowed.
	local manual_heal_only = (MANUAL_HEAL_MANDATORY == heal_option)
	local override_ally_need = ally_unit and ("in_need_of_heal" == in_need_type) and (manual_heal_only or bot_heal_info.player_unit)

	-- We also need to stop this bot from giving a healing draught to another bot if this bot itself
	-- needs healing and healing is set to manual, otherwise they will keep passing the draught back
	-- and forth to each other.
	if not override_ally_need and ally_unit and ("can_accept_heal_item" == in_need_type) and manual_heal_only and
			Managers.player:unit_owner(ally_unit).bot_player then

		local our_health_percent = ScriptUnit.extension(unit, "health_system"):current_health_percent()
		local ally_health_percent = ScriptUnit.extension(ally_unit, "health_system"):current_health_percent()
		override_ally_need = (our_health_percent <= ally_health_percent)
	end

	-- To override the choice of ally, we have to reproduce a chunk of the real _select_ally_by_utility
	if override_ally_need then
		in_need_type = nil
		ally_unit = nil
		real_dist = math.huge
		local dist = math.huge

		local inventory_extn = blackboard.inventory_extension
		local grenade_slot_data = inventory_extn:get_slot_data("slot_grenade")
		local can_give_grenade_to_other = grenade_slot_data and inventory_extn:get_item_template(grenade_slot_data).can_give_other

		local potion_slot_data = inventory_extn:get_slot_data("slot_potion")
		local can_give_potion_to_other = potion_slot_data and inventory_extn:get_item_template(potion_slot_data).can_give_other

		local human_players = Managers.player:human_players()
		for _, human_player in pairs(human_players) do
			local human_player_unit = human_player.player_unit

			if AiUtils.unit_alive(human_player_unit) then
				local allowed_follow_path, allowed_aid_path = self:_ally_path_allowed(human_player_unit, t)
				if allowed_follow_path then
					local human_need_type = nil
					local human_dist = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[human_player_unit])
					local utility_dist = human_dist

					if allowed_aid_path then
						local human_inventory_extn = ScriptUnit.extension(human_player_unit, "inventory_system")
						if can_give_grenade_to_other and not human_inventory_extn:get_slot_data("slot_grenade") then
							human_need_type = "can_accept_grenade"
							utility_dist = utility_dist - 10
						elseif can_give_potion_to_other and not human_inventory_extn:get_slot_data("slot_potion") then
							human_need_type = "can_accept_potion"
							utility_dist = utility_dist - 10
						end
					end

					if utility_dist < dist then
						dist = utility_dist
						ally_unit = human_player_unit
						real_dist = human_dist
						in_need_type = human_need_type
					end
				end
			end
		end
	end

	return ally_unit, real_dist, in_need_type
end)

local MAX_PICKUP_RANGE_SQ = 4 * 4
--[[
	Stops bots from exchanging tomes for medical supplies, unless they are wounded enough to use them on the spot, or the item is pinged. By Grimalackt.
--]]
Mods.hook.set(mod_name, "AIBotGroupSystem._update_health_pickups", function(func, self, dt, t)
	func(self, dt, t)

	if get(me.SETTINGS.REDUCE_PICKUP_TRAVEL) then
		-- Check whether any bots are trying to travel too far in order to pick up
		-- a healing item. If they are, tell them not to.
		for unit, data in pairs(self._bot_ai_data) do
			local blackboard = Unit.get_data(unit, "blackboard")
			if blackboard.allowed_to_take_health_pickup then
				local pickup_pos = POSITION_LOOKUP[blackboard.health_pickup]
				local follow_unit = data.follow_unit
				local out_of_range = follow_unit and (Vector3.distance_squared(POSITION_LOOKUP[follow_unit], pickup_pos) > MAX_PICKUP_RANGE_SQ)
				if out_of_range then
					blackboard.allowed_to_take_health_pickup = false
				end
			end
		end
	end

	if not get(me.SETTINGS.KEEP_TOMES) then
		return
	end
	local need_next_bot = nil
	local need_next_bot_pickup = nil
	local valid_bots = 0
	for unit, _ in pairs(self._bot_ai_data) do
		local blackboard = Unit.get_data(unit, "blackboard")
		local health_extension = ScriptUnit.extension(unit, "health_system")
		local inventory_ext = ScriptUnit.extension(unit, "inventory_system")
		local health_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")
 		local status_extension = ScriptUnit.extension(unit, "status_system")
		local current_health = 1
		local healthy = true

		-- Check if bot already has a tome
		if health_slot_data ~= nil then
			local item = inventory_ext.get_item_template(inventory_ext, health_slot_data)
			if item.name == "wpn_side_objective_tome_01" and blackboard.allowed_to_take_health_pickup and not (blackboard.health_pickup == pinged_heal) then
				if not status_extension.is_knocked_down(status_extension) then
					current_health = health_extension.current_health_percent(health_extension)
				end
				local pickup_extension = ScriptUnit.extension(blackboard.health_pickup, "pickup_system")
				local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()
				if (current_health <= 0.5 or status_extension.wounded) and (pickup_settings.item_name == "potion_healing_draught_01") then
					healthy = false
				elseif (current_health <= 0.2 or status_extension.wounded) and (pickup_settings.item_name == "healthkit_first_aid_kit_01") then
					healthy = false
				end
				if healthy then
					blackboard.allowed_to_take_health_pickup = false
					need_next_bot = unit
					need_next_bot_pickup = blackboard.health_pickup
					valid_bots = valid_bots + 1
				end
			end
		end
	end
	if need_next_bot and valid_bots < 3 then
		for unit, _ in pairs(self._bot_ai_data) do
			if unit ~= need_next_bot then
				local blackboard = Unit.get_data(unit, "blackboard")
				local health_extension = ScriptUnit.extension(unit, "health_system")
				local inventory_ext = ScriptUnit.extension(unit, "inventory_system")
				local health_slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_healthkit")
 				local status_extension = ScriptUnit.extension(unit, "status_system")
				local current_health = 1
				local healthy = true

				-- Check if bot already has a tome
				if health_slot_data == nil and Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup]) < 15 then
					blackboard.allowed_to_take_health_pickup = true
					blackboard.health_pickup = need_next_bot_pickup
					blackboard.health_dist = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup])
					blackboard.health_pickup_valid_until = math.huge
					return
				end
				if health_slot_data ~= nil then
					local item = inventory_ext.get_item_template(inventory_ext, health_slot_data)
					if item.name == "wpn_side_objective_tome_01" and Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup]) < 15 then
						if not status_extension.is_knocked_down(status_extension) then
							current_health = health_extension.current_health_percent(health_extension)
						end

						local pickup_extension = ScriptUnit.extension(need_next_bot_pickup, "pickup_system")
						local pickup_settings = pickup_extension and pickup_extension:get_pickup_settings()

						if (current_health <= 0.5 or status_extension.wounded) and (pickup_settings.item_name == "potion_healing_draught_01") then
							healthy = false
						elseif (current_health <= 0.2 or status_extension.wounded) and (pickup_settings.item_name == "healthkit_first_aid_kit_01") then
							healthy = false
						end
						if not healthy then
							blackboard.allowed_to_take_health_pickup = true
							blackboard.health_pickup = need_next_bot_pickup
							blackboard.health_dist = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[need_next_bot_pickup])
							blackboard.health_pickup_valid_until = math.huge
							return
						end
					end
				end
			end
		end
	end
end)

--[[
	Checks whether any bots are trying to travel too far in order to pick up
	a potion or grenade. If they are, tell them not to.
--]]
Mods.hook.set(mod_name, "AIBotGroupSystem._update_mule_pickups", function (orig_func, self, ...)
	orig_func(self, ...)
	if get(me.SETTINGS.REDUCE_PICKUP_TRAVEL) then
		for unit, data in pairs(self._bot_ai_data) do
			local blackboard = Unit.get_data(unit, "blackboard")
			if blackboard.mule_pickup then
				local pickup_pos = POSITION_LOOKUP[blackboard.mule_pickup]
				local follow_unit = data.follow_unit
				local out_of_range = follow_unit and (Vector3.distance_squared(POSITION_LOOKUP[follow_unit], pickup_pos) > MAX_PICKUP_RANGE_SQ)
				if out_of_range then
					blackboard.mule_pickup = nil
				end
			end
		end
	end
end)

-- ####################################################################################################################
-- ##### follow host ##################################################################################################
-- ####################################################################################################################
--
-- Check if player is active
--
me.player_is_enabled = function(player)
	if player and player.player_unit then
		local status_ext = ScriptUnit.extension(player.player_unit, "status_system")

		if status_ext then
			return not ScriptUnit.extension(player.player_unit, "status_system"):is_disabled()
		end
	end

	return false
end

--
-- With player data we want to generate new bot position where they need to stand
--
me.generate_points = function(ai_bot_group_system, player)
	local points = nil

	-- Collect data
	local player_unit = player.player_unit
	local player_pos = POSITION_LOOKUP[player_unit]
	local num_bots = ai_bot_group_system._num_bots
	local nav_world = Managers.state.entity:system("ai_system"):nav_world()
	local disallowed_at_pos, current_mapping = ai_bot_group_system:_selected_unit_is_in_disallowed_nav_tag_volume(nav_world, player_pos)

	if disallowed_at_pos then
		local origin_point = ai_bot_group_system:_find_origin(nav_world, player_unit)

		points = ai_bot_group_system:_find_destination_points_outside_volume(nav_world, player_pos, current_mapping, origin_point, num_bots)
	else
		local cluster_position, rotation = ai_bot_group_system:_find_cluster_position(nav_world, player_unit)

		points = ai_bot_group_system:_find_destination_points(nav_world, cluster_position, rotation, num_bots)
	end

	return points
end

Mods.hook.set(mod_name, "AIBotGroupSystem._assign_destination_points",
function (func, self, bot_ai_data, points, follow_unit, follow_unit_table)
	func(self, bot_ai_data, points, follow_unit, follow_unit_table)

	if not get(me.SETTINGS.FOLLOW) then
		return
	end

	local player = Managers.player:local_player()

	if follow_unit and me.player_is_enabled(player) or follow_unit_table and table.has_item(follow_unit_table, player.player_unit) then
		local destination_points = me.generate_points(self, player)

		if destination_points then
			local i = 1
			-- Update bots with new positions
			for unit, data in pairs(bot_ai_data) do
				data.follow_unit = player.player_unit
				data.follow_position = destination_points[i]
				i = i + 1
			end
		end
	end
end)

-- ####################################################################################################################
-- ##### don't use wizard bot when wizard player laeves ###############################################################
-- ####################################################################################################################
local NUM_PLAYERS = 4
local CONSUMABLE_SLOTS = {
	"slot_healthkit",
	"slot_potion",
	"slot_grenade"
}

Mods.hook.set(mod_name, "SpawnManager._update_bot_spawns", function (func, self, dt, t)
	if not get(me.SETTINGS.OVERRIDE_LEFT_PLAYER) then
		return func(self, dt, t)
	end

	local player_manager = Managers.player
	local profile_synchronizer = self._profile_synchronizer
	local available_profile_order = self._available_profile_order
	local available_profiles = self._available_profiles
	local profile_release_list = self._bot_profile_release_list
	local delta, humans, bots = self._update_available_profiles(self, profile_synchronizer, available_profile_order, available_profiles)

	for local_player_id, bot_player in pairs(self._bot_players) do
		local profile_index = bot_player.profile_index

		if not available_profiles[profile_index] then
			local peer_id = bot_player.network_id(bot_player)
			local local_player_id = bot_player.local_player_id(bot_player)
			profile_release_list[profile_index] = true
			local bot_unit = bot_player.player_unit

			if bot_unit then
				bot_player.despawn(bot_player)
			end

			local status_slot_index = bot_player.status_slot_index

			self._free_status_slot(self, status_slot_index)
			player_manager.remove_player(player_manager, peer_id, local_player_id)

			self._bot_players[local_player_id] = nil
		end
	end

	local allowed_bots = math.min(NUM_PLAYERS - humans, (not script_data.ai_bots_disabled or 0) and (script_data.cap_num_bots or NUM_PLAYERS))
	local bot_delta = allowed_bots - bots
	local local_peer_id = Network.peer_id()

	if 0 < bot_delta then
		local i = 1
		local bots_spawned = 0

		available_profile_order = {}
		for _,profile_index in ipairs((get(me.SETTINGS.PREFER_SALTZBOT) and {5,4,3,1,2}) or {5,4,3,2,1}) do
			if available_profiles[profile_index] then
				table.insert(available_profile_order, profile_index)
			end
		end

		while bots_spawned < bot_delta do
			local profile_index = available_profile_order[i]

			fassert(profile_index, "Tried to add more bots than there are profiles available")

			local owner_type = profile_synchronizer.owner_type(profile_synchronizer, profile_index)

			if owner_type == "available" then
				local local_player_id = player_manager.next_available_local_player_id(player_manager, local_peer_id)
				local bot_player = player_manager.add_bot_player(player_manager, SPProfiles[profile_index].display_name, local_peer_id, "default", profile_index, local_player_id)
				local is_initial_spawn, status_slot_index = self._assign_status_slot(self, local_peer_id, local_player_id, profile_index)
				bot_player.status_slot_index = status_slot_index

				profile_synchronizer.set_profile_peer_id(profile_synchronizer, profile_index, local_peer_id, local_player_id)
				bot_player.create_game_object(bot_player)

				self._bot_players[local_player_id] = bot_player
				self._spawn_list[#self._spawn_list + 1] = bot_player
				bots_spawned = bots_spawned + 1
				self._forced_bot_profile_index = nil
			end

			i = i + 1
		end
	elseif bot_delta < 0 then
		local bots_despawned = 0
		local i = 1

		while bots_despawned < -bot_delta do
			local profile_index = available_profile_order[i]

			fassert(profile_index, "Tried to remove more bots than there are profiles belonging to bots")

			local owner_type = profile_synchronizer.owner_type(profile_synchronizer, profile_index)

			if owner_type == "bot" then
				local bot_player, bot_local_player_id = nil

				for local_player_id, player in pairs(self._bot_players) do
					if player.profile_index == profile_index then
						bot_player = player
						bot_local_player_id = local_player_id

						break
					end
				end

				fassert(bot_player, "Did not find bot player with profile_index profile_index %i", profile_index)

				profile_release_list[profile_index] = true
				local bot_unit = bot_player.player_unit

				if bot_unit then
					bot_player.despawn(bot_player)
				end

				local status_slot_index = bot_player.status_slot_index

				self._free_status_slot(self, status_slot_index)
				player_manager.remove_player(player_manager, local_peer_id, bot_local_player_id)

				self._bot_players[bot_local_player_id] = nil
				bots_despawned = bots_despawned + 1
			end

			i = i + 1
		end
	end

	local statuses = self._player_statuses

	if self._network_server:has_all_peers_loaded_packages() then
		for _, bot_player in ipairs(self._spawn_list) do
			local bot_local_player_id = bot_player.local_player_id(bot_player)
			local bot_peer_id = bot_player.network_id(bot_player)

			if player_manager.player(player_manager, bot_peer_id, bot_local_player_id) == bot_player then
				local status_slot_index = bot_player.status_slot_index
				local status = statuses[status_slot_index]
				local position = status.position:unbox()
				local rotation = status.rotation:unbox()
				local is_initial_spawn = false

				if status.health_state ~= "dead" and status.health_state ~= "respawn" and status.health_state ~= "respawning" then
					local consumables = status.consumables
					local ammo = status.ammo

					bot_player.spawn(bot_player, position, rotation, is_initial_spawn, ammo.slot_melee, ammo.slot_ranged, consumables[CONSUMABLE_SLOTS[1]], consumables[CONSUMABLE_SLOTS[2]], consumables[CONSUMABLE_SLOTS[3]])
				end

				status.spawn_state = "spawned"
			end
		end

		table.clear(self._spawn_list)
	end

	return
end)
Mods.hook.front(mod_name, "SpawnManager._update_bot_spawns")

-- ####################################################################################################################
-- ##### autoequip bots from a dedicated loadout slot #################################################################
-- ####################################################################################################################
local LOADOUT_SETTING = "cb_saved_loadouts"
Mods.hook.set(mod_name, "BackendUtils.get_loadout_item", function (func, profile, slot)
	if not get(me.SETTINGS.AUTOEQUIP) then
		return func(profile, slot)
	end

	if profile == "all" then
		return
	end

	local profile_index = 0
	for _,profile_data in ipairs(SPProfiles) do
		profile_index = profile_index + 1
		if profile_data.display_name == profile then
			break
		end
	end

	local item_data = nil

	if SPProfiles[profile_index] and Managers.state.network then
		if Managers.state.network.profile_synchronizer:owner_type(profile_index) == "bot" then
			local loadout = Application.user_setting(LOADOUT_SETTING, profile, get(me.SETTINGS.AUTOEQUIP_SLOT))
			local backend_id = loadout and loadout[slot] or nil
			if backend_id and ScriptBackendItem.get_key(backend_id) then
				item_data = BackendUtils.get_item_from_masterlist(backend_id) or nil
			end
			if item_data then
				return item_data
			end
		end
	end

	local backend_id = ScriptBackendItem.get_loadout_item_id(profile, slot)
	item_data = (backend_id and BackendUtils.get_item_from_masterlist(backend_id)) or nil

	return item_data
end)
Mods.hook.front(mod_name, "BackendUtils.get_loadout_item")

-- ####################################################################################################################
-- ##### Block on Path Search by Aussiemon ############################################################################
-- ####################################################################################################################

-- ##########################################################
-- ################## Functions #############################

me.manual_block = function(unit, blackboard, should_block, t)
	if unit and Unit.alive(unit) and blackboard and blackboard.input_extension then
		local input_extension = blackboard.input_extension
		
		if should_block then
			input_extension:wield("slot_melee")
			input_extension._defend = true
			blackboard._block_start_time_BIE = t
			
		elseif t > (blackboard._block_start_time_BIE + 1) then
			input_extension._defend = false
			blackboard._block_start_time_BIE = nil
		end
	end
end

me.auto_block = function(unit, status)
	if unit and Unit.alive(unit) and ScriptUnit.has_extension(unit, "status_system") then
		local status_extension = ScriptUnit.extension(unit, "status_system")
		local go_id = Managers.state.unit_storage:go_id(unit)

		Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, status)
	   
		status_extension.set_blocking(status_extension, status)
	end
end

-- ##########################################################
-- #################### Hooks ###############################

-- ## Bots Block on Path Search - Teleport to Ally Action ##
-- Start blocking as the teleport action begins
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.enter", function (func, self, unit, blackboard, t)
	
	if get(me.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		me.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

-- Continue blocking as the teleport action runs
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.run", function (func, self, unit, blackboard, t)
	
	if get(me.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		me.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

-- Cancel blocking when the teleport action ends
Mods.hook.set(mod_name, "BTBotTeleportToAllyAction.leave", function (func, self, unit, blackboard, t)
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	
	if get(me.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		me.manual_block(unit, blackboard, false, t)
	end
	
	return result
end)


-- ## Bots Block on Path Search - Nil Action ##
-- Start blocking when the nil action ends, and hold the block until the game decides to release it
Mods.hook.set(mod_name, "BTNilAction.leave", function (func, self, unit, blackboard, t)
	
	if get(me.SETTINGS.BOTS_BLOCK_ON_PATH_SEARCH) then 
		me.manual_block(unit, blackboard, true, t)
	end
	
	-- Original Function
	local result = func(self, unit, blackboard, t)
	return result
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
me.create_options()