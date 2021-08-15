--[[
	Name: Volley Crossbow Charged Fix
	Author: VernonKun
	Updated: 1/20/2021

	This mod fixes the issue of Volley Crossbow that another 3-bolt shot cannot be fired between
	0.5-0.8 second after one 3-bolt shot is fired, and shorten the transition time from charged mode to normal mode.

	The issue is also described in doom_hamster's video (4:20 - 8:40):
	https://www.youtube.com/watch?v=umKIgEUDXaY&t=5s

	Codes are copied from Vermintide 2 source code.
--]]

Weapons.repeating_crossbow_template_1.actions.action_one.zoomed_shot.total_time = math.huge
Weapons.repeating_crossbow_template_1_co.actions.action_one.zoomed_shot.total_time = math.huge
Weapons.repeating_crossbow_template_1_t2.actions.action_one.zoomed_shot.total_time = math.huge
Weapons.repeating_crossbow_template_1_t3.actions.action_one.zoomed_shot.total_time = math.huge

if not volleychargedfixtoken then
	volleychargedfixtoken = true

	table.remove(Weapons.repeating_crossbow_template_1.actions.action_one.zoomed_shot.allowed_chain_actions, 2)
	table.remove(Weapons.repeating_crossbow_template_1_co.actions.action_one.zoomed_shot.allowed_chain_actions, 2)
	table.remove(Weapons.repeating_crossbow_template_1_t2.actions.action_one.zoomed_shot.allowed_chain_actions, 2)
	table.remove(Weapons.repeating_crossbow_template_1_t3.actions.action_one.zoomed_shot.allowed_chain_actions, 2)
end
