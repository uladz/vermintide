 
local oi = OptionsInjector
 
local mod_name = "SaverGrimDiscard"
 
SaverGrimDiscard = {
    MOD_SETTINGS = {
        ACTIVE = {
        ["save"] = "cb_save_saver_grim_discard",
        ["widget_type"] = "stepper",
        ["text"] = "Grimoire Discard Saver",
        ["tooltip"] =  "Grimoire Discard Saver\n" ..
            "Toggle grimoire discarding saver on / off.\n\n" ..
            "Only let's you discard the grim with [Block] + [Push]",
        ["value_type"] = "boolean",
        ["options"] = {
            {text = "Off", value = false},
            {text = "On", value = true}
        },
        ["default"] = 1, -- Default first option is enabled. In this case Off
        },
    }
}
 
local me = SaverGrimDiscard
 
local get = function(data)
    return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings
 
me.skip_next_fade = false
 
me.orig_template = table.clone(Weapons.wpn_grimoire_01)
 
me.update = function()
    if get(me.MOD_SETTINGS.ACTIVE) then
        Weapons.wpn_grimoire_01.actions["action_one"]["default"] = {
            kind = "dummy",
            weapon_action_hand = "left",
            total_time = 0,
            allowed_chain_actions = {}
        }
        Weapons.wpn_grimoire_01.actions["action_one"]["throw"] = {
            kind = "throw_grimoire",
            ammo_usage = 1,
            anim_end_event = "attack_finished",
            anim_event = "attack_throw",
            weapon_action_hand = "left",
            total_time = 0.7,
            anim_end_event_condition_func = function (unit, end_reason)
                return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
            end,
            allowed_chain_actions = {}
        }
        Weapons.wpn_grimoire_01.actions["action_two"] = {
            default = {
                cooldown = 0.15,
                minimum_hold_time = 0.3,
                anim_end_event = "parry_finished",
                kind = "dummy",
                weapon_action_hand = "left",
                hold_input = "action_two_hold",
                anim_event = "parry_pose",
                anim_end_event_condition_func = function (unit, end_reason)
                    return end_reason ~= "new_interupting_action"
                end,
                total_time = math.huge,
                enter_function = function (attacker_unit, input_extension)
                    return input_extension.reset_release_input(input_extension)
                end,
                allowed_chain_actions = {
                    {
                        sub_action = "throw",
                        start_time = 0.1,
                        action = "action_one",
                        doubleclick_window = 0,
                        input = "action_one",
                        hold_required = {
                            "action_two_hold"
                        }
                    },
                    {
                        sub_action = "default",
                        start_time = 0.4,
                        action = "action_wield",
                        input = "action_wield"
                    }
                }
            }
        }
    else
        Weapons.wpn_grimoire_01 = table.clone(me.orig_template)
    end
end
 
-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
 
SaverGrimDiscard.create_options = function()
    Mods.option_menu:add_group("saver_grim_discard", "Grimoire Discard Saver")
 
    Mods.option_menu:add_item("saver_grim_discard", me.MOD_SETTINGS.ACTIVE, true)
end
 
-- ####################################################################################################################
-- ##### Hook #########################################################################################################
-- ####################################################################################################################
 
Mods.hook.set(mod_name, "OptionsView.exit", function(orig_func, self)
    orig_func(self)
   
    me.update()
end)
 
Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(orig_func, self)
    orig_func(self)
 
    me.update()
end)
 
-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
me.create_options()