--[[
	Name: Brace of Pistols & Rapier Firing Sound Fix
	Author: VernonKun (presumably)
	Updated: 5/24/2020

	This mod fixes the bug that the host can't hear firing sound of Brace of Pistols and Rapier when
	they are equipped on Saltzpyre bot.
--]]

local mod_name = "BraceOfPistolsSoundFix"

Mods.hook.set(mod_name, "PlayerBotUnitFirstPerson.play_hud_sound_event", function(func, self, event, wwise_source_id, play_on_husk)
	if (play_on_husk and not LEVEL_EDITOR_TEST) or event == "weapon_gun_fire_rare" then
		self:play_sound_event(event)
	end

	if play_on_husk and not LEVEL_EDITOR_TEST then
		--self:play_sound_event(event)

		local network_manager = Managers.state.network
		local network_transmit = network_manager.network_transmit
		local unit_id = network_manager:unit_game_object_id(self.unit)
		local event_id = NetworkLookup.sound_events[event]

		network_transmit:send_rpc_clients("rpc_play_husk_sound_event", unit_id, event_id)
	end
end)

Mods.hook.set(mod_name, "PlayerUnitFirstPerson.play_hud_sound_event", function(func, self, event, wwise_source_id, play_on_husk)
	if event ~= "weapon_gun_fire_rare" then
		func(self, event, wwise_source_id, play_on_husk)
	end
end)

--[[
--params.unit is the weapon unit?

Mods.hook.set(mod_name, "flow_callback_wwise_trigger_event_with_environment", function (func, params)
	if not (params.name == "weapon_gun_fire_rare" and params.unit == Managers.player:local_player().player_unit) then
	--if params.name ~= "weapon_gun_fire_rare" then
		func(params)
	end
end)
--]]

Weapons.brace_of_pistols_template_1.actions.action_one.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.brace_of_pistols_template_1.actions.action_one.fast_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.brace_of_pistols_template_1_co.actions.action_one.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.brace_of_pistols_template_1_co.actions.action_one.fast_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.brace_of_pistols_template_1_t2.actions.action_one.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.brace_of_pistols_template_1_t2.actions.action_one.fast_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.brace_of_pistols_template_1_t3.actions.action_one.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.brace_of_pistols_template_1_t3.actions.action_one.fast_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.fencing_sword_template_1.actions.action_three.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.fencing_sword_template_1.actions.action_three.block_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.fencing_sword_template_1_co.actions.action_three.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.fencing_sword_template_1_co.actions.action_three.block_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.fencing_sword_template_1_t2.actions.action_three.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.fencing_sword_template_1_t2.actions.action_three.block_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.fencing_sword_template_1_t3.actions.action_three.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.fencing_sword_template_1_t3.actions.action_three.block_shot.fire_sound_event = "weapon_gun_fire_rare"

Weapons.fencing_sword_template_1_t3_un.actions.action_three.default.fire_sound_event = "weapon_gun_fire_rare"
Weapons.fencing_sword_template_1_t3_un.actions.action_three.block_shot.fire_sound_event = "weapon_gun_fire_rare"

--EchoConsole("Brace of Pistols Sound Fix Loaded")
