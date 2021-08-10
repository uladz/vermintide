local mod_name = "LuckAndDupeIndicators"

local oi = OptionsInjector

local get = Application.user_setting
local set = Application.set_user_setting
local save = Application.save_user_settings

LuckAndDupeIndicators = {
	SETTINGS = {
		SUB_GROUP = {
			["save"] = "cb_luck_and_dupe_indicators_subgroup",
			["widget_type"] = "dropdown_checkbox",
			["text"] = "Luck And Dupe Indicators",
			["default"] = false,
			["hide_options"] = {
				{
					true,
					mode = "show",
					options = {
						"cb_luck_and_dupe_indicators_luck_enabled",
						"cb_luck_and_dupe_indicators_dupe_enabled"
					},
				},
				{
					false,
					mode = "hide",
					options = {
						"cb_luck_and_dupe_indicators_luck_enabled",
						"cb_luck_and_dupe_indicators_dupe_enabled"
					},
				},
			},
		},
		ENABLED_LUCK = {
			["save"] = "cb_luck_and_dupe_indicators_luck_enabled",
			["widget_type"] = "checkbox",
			["text"] = "Enabled for luck",
			["tooltip"] = "Enabled for luck\n" ..
				"Show a reminder icon above chests when someone is carrying a luck trinket. " ..
				"The reminder is removed if the luck carrier is dead or you looted both dice.",
			["default"] = false,
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_luck_and_dupe_indicators_luck_enabled_self",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_luck_and_dupe_indicators_luck_enabled_self",
					}
				},
			},
		},
		ENABLED_LUCK_SELF = {
			["save"] = "cb_luck_and_dupe_indicators_luck_enabled_self",
			["widget_type"] = "checkbox",
			["text"] = "Enabled For Self (Luck)",
			["tooltip"] = "Enabled For Self\n" ..
				"Enable if you want the reminder shown when you're the one carrying a luck trinket.",
			["default"] = false,
		},
		ENABLED_DUPE = {
			["save"] = "cb_luck_and_dupe_indicators_dupe_enabled",
			["widget_type"] = "checkbox",
			["text"] = "Enabled for dupe",
			["tooltip"] = "Enabled for dupe\n" ..
				"Show a reminder icon above dupable items when someone is carrying a dupe trinket.",
			["default"] = false,
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_luck_and_dupe_indicators_dupe_enabled_self",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_luck_and_dupe_indicators_dupe_enabled_self",
					}
				},
			},
		},
		ENABLED_DUPE_SELF = {
			["save"] = "cb_luck_and_dupe_indicators_dupe_enabled_self",
			["widget_type"] = "checkbox",
			["text"] = "Enabled For Self (Dupe)",
			["tooltip"] = "Enabled For Self\n" ..
				"Enable if you want the reminder shown when you're the one carrying a dupe trinket.",
			["default"] = false,
		},
	},
}
local mod = LuckAndDupeIndicators

local luck_trinket_keys = {
	"trinket_increase_luck_tier1",
	"trinket_increase_luck_tier2",
	"trinket_increase_luck_tier3",
	"trinket_increase_luck_halloween",
}

local pickup_dupe_trinket_keys = {
	"trinket_not_consume_pickup_tier1",
	"trinket_not_consume_pickup_tier2",
	"trinket_not_consume_pickup_tier3",
}

local function create_chest_icon(unit, pickup_name)
	local player = Managers.player:local_player()
	local world = Managers.world:world("level_world")
	local viewport = ScriptWorld.viewport(world, player.viewport_name)
	local camera = ScriptViewport.camera(viewport)

	if POSITION_LOOKUP[player.player_unit] then
		local distance = Vector3.distance(Unit.local_position(unit, 0), POSITION_LOOKUP[player.player_unit])
		local world_pos = Unit.world_position(unit, 0)
		world_pos.z = world_pos.z + 0.85
		local position2d, depth = Camera.world_to_screen(camera, world_pos)

		if distance > 0.5 and distance < 6.5 and depth < 1 then
			local scale = math.clamp((6.5-distance)/6.5, 0, 1)
			local size = Vector2(96 * scale*1.25, 96 * scale*1.25)
			local pos = Vector3(position2d[1]-size[1]/2, position2d[2]-size[2]/2, 200)

			safe_pcall(function()
				Mods.gui.draw_icon("icon_trophy_luckstone_01_01", pos, Color(125, 255, 255, 255), size, "gui_item_icons_atlas")
			end)
		end
	end
end

local function create_dupe_icon(unit, pickup_name)
	local player = Managers.player:local_player()
	local world = Managers.world:world("level_world")
	local viewport = ScriptWorld.viewport(world, player.viewport_name)
	local camera = ScriptViewport.camera(viewport)

	if POSITION_LOOKUP[unit] and POSITION_LOOKUP[player.player_unit] then
		local distance = Vector3.distance(POSITION_LOOKUP[unit], POSITION_LOOKUP[player.player_unit])
		local world_pos = POSITION_LOOKUP[unit]
		world_pos.z = world_pos.z + 0.4
		local position2d, depth = Camera.world_to_screen(camera, world_pos)
		world_pos.z = world_pos.z - 0.4

		if distance > 0.5 and distance < 6.5 and depth < 1 then
			local scale = math.clamp((6.5-distance)/6.5, 0, 1)
			local size = Vector2(64 * scale*1, 64 * scale*1)
			local pos = Vector3(position2d[1]-size[1]/2, position2d[2]-size[2]/2, 200)

			safe_pcall(function()
				Mods.gui.draw_icon("icon_trophy_ornamented_scroll_case_01_01", pos, Color(100, 255, 255, 255), size, "gui_item_icons_atlas")
			end)
		end
	end
end

local function player_has_trinket_from_array(player, trinket_keys)
	local inventory_extn = ScriptUnit.has_extension(player.player_unit, "inventory_system")
	local attachment_extn = ScriptUnit.has_extension(player.player_unit, "attachment_system")

	for _, slot_name in ipairs({"slot_trinket_1", "slot_trinket_2", "slot_trinket_3"}) do
		local slot_data = inventory_extn and inventory_extn:get_slot_data(slot_name)
		if not slot_data then
			slot_data = attachment_extn and attachment_extn._attachments.slots[slot_name]
		end
		local item_key = slot_data and slot_data.item_data.key
		local item = item_key and ItemMasterList[item_key]
		if item_key and table.has_item(trinket_keys, item_key) then
			return true
		end
	end

	return false
end

local function player_not_disabled(player)
	local status_ext = player.player_unit and ScriptUnit.extension(player.player_unit, "status_system")
	return status_ext and not status_ext.is_disabled(status_ext) or false
end

Mods.hook.set(mod_name, "OutlineSystem.update", function(func, self, ...)
	local local_player = Managers.player:local_player()
	local enabled_luck = get(mod.SETTINGS.ENABLED_LUCK.save)
	local enabled_dupe = get(mod.SETTINGS.ENABLED_DUPE.save)

	if Managers.matchmaking.ingame_ui.hud_visible and (enabled_luck or enabled_dupe) and player_not_disabled(local_player) then
		local anyone_with_luck = false
		local anyone_with_dupe = false
		for _, player in pairs(Managers.player:human_players()) do

			if player_not_disabled(player) then
				if player_has_trinket_from_array(player, luck_trinket_keys) then
					anyone_with_luck = true
				end
				if player_has_trinket_from_array(player, pickup_dupe_trinket_keys) then
					anyone_with_dupe = true
				end
			end
		end

		if player_has_trinket_from_array(local_player, luck_trinket_keys) and not get(mod.SETTINGS.ENABLED_LUCK_SELF.save) then
			anyone_with_luck = false
		end
		if player_has_trinket_from_array(local_player, pickup_dupe_trinket_keys) and not get(mod.SETTINGS.ENABLED_DUPE_SELF.save) then
			anyone_with_dupe = false
		end

		local mission_system = Managers.state.entity:system("mission_system")
		local active_mission = mission_system.active_missions
		local have_all_dice = not (active_mission["bonus_dice_hidden_mission"] == nil or active_mission["bonus_dice_hidden_mission"].current_amount < 2)

		local first_person_extension
		local camera_position
		if ScriptUnit.has_extension(local_player.player_unit, "first_person_system") then
			first_person_extension = ScriptUnit.extension(local_player.player_unit, "first_person_system")
			camera_position = first_person_extension.current_position(first_person_extension)
		end

		local interactor_extension
		if ScriptUnit.has_extension(local_player.player_unit, "interactor_system") then
			interactor_extension = ScriptUnit.extension(local_player.player_unit, "interactor_system")
		end

		local Unit_alive = Unit.alive
		local Unit_has_data = Unit.has_data
		local Unit_get_data = Unit.get_data
		for _, unit in pairs(self.units) do
			if Unit_alive(unit) then
				if enabled_luck and anyone_with_luck and Unit_has_data(unit, "interaction_data") then
					local interaction_type = Unit_get_data(unit, "interaction_data", "interaction_type")

					if interaction_type == "chest"
						and Unit_get_data(unit, "interaction_data", "being_used") ~= false
						and not have_all_dice
						then
							create_chest_icon(unit)
					end
				end

				if enabled_dupe and anyone_with_dupe and ScriptUnit.has_extension(unit, "pickup_system") then
					local pickup_extension = ScriptUnit.extension(unit, "pickup_system")
					local pickup_settings = pickup_extension.get_pickup_settings(pickup_extension)

					if pickup_extension.spawn_type ~= "dropped"
						and pickup_settings
						and pickup_settings.dupable
						and camera_position
						and interactor_extension
						and not interactor_extension:_check_if_interactable_in_chest(unit, camera_position)
						then
							create_dupe_icon(unit)
					end
				end
			end
		end
	end

	return func(self, ...)
end)

mod.create_options = function()
	Mods.option_menu:add_group("hud_group", "HUD Related Mods")

	Mods.option_menu:add_item("hud_group", mod.SETTINGS.SUB_GROUP, true)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.ENABLED_LUCK)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.ENABLED_LUCK_SELF)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.ENABLED_DUPE)
	Mods.option_menu:add_item("hud_group", mod.SETTINGS.ENABLED_DUPE_SELF)
end

mod.create_options()