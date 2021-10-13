--[[
	ChestInfo:
		Shows loot dice chances in the chat

		ChestInfo v1.1.1
		Author: IamLupo

		Displays the percentage of getting a loot die when opening chests.
		Go to Mod Settings -> Items -> Show Loot Die Chance to toggle.
		Off by default.

		Changelog
		1.1.1
		- Added language support en, de
		1.1.0
		- Made fix for outline crash
		1.0.0
		- Release
--]]

local mod_name = "ChestInfo"
ChestInfo = {}
local mod = ChestInfo

mod.widget_settings = {
	INFO = {
		["save"] = "cb_chest_info",
		["widget_type"] = "stepper",
		["text"] = "Show Loot Die Chance",
		["tooltip"] = "Show Loot Die Chance\n" ..
			"Shows loot dice chance of all the chests.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	PING = {
		["save"] = "cb_chest_ping",
		["widget_type"] = "stepper",
		["text"] = "Ping all Chests",
		["tooltip"] =  "Ping all Chests\n" ..
			"Enables to see all chest through walls.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

mod.was_enabled = false

mod.refresh = 0

mod.get = function(data)
	if data then
		return Application.user_setting(data.save)
	end
end

mod.set = function(data, value)
	if data then
		Application.set_user_setting(data.save, value)
	end
end

mod.save = function()
	Application.save_user_settings()
end

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
mod.create_options = function()
	Mods.option_menu:add_group("chest", "Chest")

	Mods.option_menu:add_item("chest", mod.widget_settings.INFO, true)
	Mods.option_menu:add_item("chest", mod.widget_settings.PING, true)
end

-- ####################################################################################################################
-- ##### Functions ####################################################################################################
-- ####################################################################################################################
mod.is_chest = function(unit)
	local interaction_type = Unit.get_data(unit, "interaction_data", "interaction_type")

	return interaction_type == "chest"
end

mod.can_interact = function(unit)
	local interaction_type = Unit.get_data(unit, "interaction_data", "interaction_type")
	local interaction_data = InteractionDefinitions[interaction_type]

	local player_unit = Managers.player:local_player().player_unit

	if player_unit then
		return interaction_data.client.can_interact(player_unit, unit)
	end

	return false
end

mod.update = function()
	-- Ping all chests
	if mod.get(mod.widget_settings.PING.save) then
		for _, world in pairs(Application.worlds()) do
			for _, unit in pairs(World.units(world)) do
				if mod.is_chest(unit) then
					local outline_extension = ScriptUnit.extension(unit, "outline_system")

					if mod.can_interact(unit) then
						outline_extension.set_pinged(true)
					else
						outline_extension.set_pinged(false)
					end
				end
			end
		end

		mod.was_enabled = true
	elseif mod.was_enabled then -- Disable all pinged chests
		for _, world in pairs(Application.worlds()) do
			for _, unit in pairs(World.units(world)) do
				if mod.is_chest(unit) then
					local outline_extension = ScriptUnit.extension(unit, "outline_system")

					outline_extension.set_pinged(false)
				end
			end
		end

		mod.was_enabled = false
	end
end

-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
local pickup_params = {}
Mods.hook.set(mod_name, "InteractionDefinitions.chest.server.stop",
function (func, world, interactor_unit, interactable_unit, data, config, t, result)
	if mod.get(mod.widget_settings.INFO.save) == true then
		data.start_time = nil
		local can_spawn_dice = Unit.get_data(interactable_unit, "can_spawn_dice")

		if not can_spawn_dice then
			return
		end

		table.clear(pickup_params)

		local pickup_name = "loot_die"
		local dice_keeper = data.dice_keeper
		local pickup_settings = AllPickups[pickup_name]
		pickup_params.dice_keeper = dice_keeper

		if result == InteractionResult.SUCCESS and pickup_settings.can_spawn_func(pickup_params) then
			local buff_extension = ScriptUnit.extension(interactor_unit, "buff_system")
			local rand = math.random()
			local chance = dice_keeper.chest_loot_dice_chance(dice_keeper)
			chance = buff_extension.apply_buffs_to_value(buff_extension, chance, StatBuffIndex.INCREASE_LUCK)

			local chance_str = tostring(tonumber(string.format("%.0f", chance * 1000)) / 10)
			local rand_str = string.format("%.0f", rand * 100)
			local message = string.format("Loot dice is %s%% chance and the random number is %s", chance_str, rand_str)

			EchoConsole(message)

			if rand < chance then
				local extension_init_data = {
					pickup_system = {
						has_physics = true,
						spawn_type = "rare",
						pickup_name = pickup_name
					}
				}
				local unit_name = pickup_settings.unit_name
				local unit_template_name = pickup_settings.unit_template_name or "pickup_unit"
				local position = Unit.local_position(interactable_unit, 0) + Vector3(0, 0, 0.3)
				local rotation = Unit.local_rotation(interactable_unit, 0)

				Managers.state.unit_spawner:spawn_network_unit(unit_name, unit_template_name, extension_init_data, position, rotation)
				dice_keeper.bonus_dice_spawned(dice_keeper)
			end
		end

		Unit.set_data(interactable_unit, "interaction_data", "being_used", false)
	else
		func(world, interactor_unit, interactable_unit, data, config, t, result)
	end
end)

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	func(self, dt, t)

	if mod.refresh + 1 < t then
		mod.update()

		mod.refresh = t
	end
end)

--[[
	Fix: Issue #24
]]--
Mods.hook.set(mod_name, "OutlineSystem.outline_unit", function(func, ...)
	pcall(func, ...)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
mod.create_options()
