local mod_name = "ChatBlock"
--[[
    Add Defend while in chat:
        When you are typing in the chat the charter will automaticly
        block every attack.
--]]
 
local oi = OptionsInjector
 
ChatBlock = {
	SETTINGS = {
		ACTIVE = "cb_chat_block",
		PUSH = "cb_chat_block_push",
	},

	SETTINGS = {
		ENABLED = {
			["save"] = "cb_chat_block_enabled",
			["widget_type"] = "stepper",
			["text"] = "Enabled",
			["tooltip"] = "Chat Block\n" ..
				"Toggle chat block on / off.\n\n" ..
				"Automatically block when you're chatting.\n" ..
				"Your block will still break if your stamina runs out.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 2, -- Default second option is enabled. In this case On
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_chat_block_push",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_chat_block_push",
					}
				},
			},
		},
		PUSH = {
			["save"] = "cb_chat_block_push",
			["widget_type"] = "stepper",
			["text"] = "Push on exit",
			["tooltip"] = "Push on exit\n" ..
				"Toggle push on exit on / off.\n\n" ..
				"When on, you will automatically push when exiting the chat.\n" ..
				"Will not happen if your stamina does not allow it.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true}
			},
			["default"] = 1, -- Default second option is enabled. In this case Off
		},
	},
}
local me = ChatBlock
local states = {
    NOT_BLOCKING = 0,
    SHOULD_BLOCK = 1,
    BLOCKING = 2,
    SHOULD_PUSH = 3
}
me.state = states.NOT_BLOCKING
 
local get = function(data)
	return Application.user_setting(data.save)
end
local set = Application.set_user_setting
local save = Application.save_user_settings
 
-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
ChatBlock.create_options = function()
	Mods.option_menu:add_group("chat_block", "Chat Block")

	Mods.option_menu:add_item("chat_block", me.SETTINGS.ENABLED, true)
	Mods.option_menu:add_item("chat_block", me.SETTINGS.PUSH)
end
 
-- ####################################################################################################################
-- ##### Chat manager hook ############################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "ChatManager.update", function(func, self, dt, t, ...)
    if get(me.SETTINGS.ENABLED) then
        local player = Managers.player:player_from_peer_id(Network.peer_id())
       
        if player and player.player_unit then
            local player_unit = player.player_unit
	    if player_unit and ScriptUnit.has_extension(player_unit, "status_system") then
            	local status_extension = ScriptUnit.extension(player_unit, "status_system")
       
            	if self.chat_gui.chat_focused and me.state == states.NOT_BLOCKING then             
             	   me.state = states.SHOULD_BLOCK
             	   --EchoConsole(tostring(me.state))
            	elseif not self.chat_gui.chat_focused and me.state == states.BLOCKING then
			if get(me.SETTINGS.PUSH) then
				me.state = states.SHOULD_PUSH
			else
				me.state = states.NOT_BLOCKING
			end
            	    --EchoConsole(tostring(me.state))
            	elseif not self.chat_gui.chat_focused and me.state ~= states.NOT_BLOCKING then
            	    me.state = states.NOT_BLOCKING
            	    --EchoConsole(tostring(me.state))
           	 end
	    end
        end
    end
    return func(self, dt, t, ...)
end)
 
-- Weapon action update hook
-- And I'm not doing this fancy over the top unnessesary commenting thing, no way
 
Mods.hook.set(mod_name, "CharacterStateHelper.update_weapon_actions", function(func, t, unit, input_extension, inventory_extension, damage_extension)
 
    local player_unit = Managers.player:local_player().player_unit
    local status_extension = player_unit and ScriptUnit.has_extension(player_unit, "status_system") and ScriptUnit.extension(player_unit, "status_system")

    --Check if local player and not in inn
    if(player_unit ~= unit or LevelHelper:current_level_settings().level_id == "inn_level" or (not status_extension) or (status_extension and status_extension.is_ready_for_assisted_respawn(status_extension))) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
 
    --Get data about weapon
    local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper._get_item_data_and_weapon_extensions(inventory_extension)
    local new_action, new_sub_action, current_action_settings, current_action_extension, current_action_hand = nil
    current_action_settings, current_action_extension, current_action_hand = CharacterStateHelper._get_current_action_data(left_hand_weapon_extension, right_hand_weapon_extension)
    if not(item_data) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
    local item_template = BackendUtils.get_item_template(item_data)
    if not(item_template) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
 
    --Check if weapon can block
    new_action = "action_two"
    new_sub_action = "default"
    local new_action_template = item_template.actions[new_action]
    local template = new_action_template and item_template.actions[new_action][new_sub_action]
    if not(template) or (not right_hand_weapon_extension and not left_hand_weapon_extension) or (template.kind ~= "block") then
        func(t, unit, input_extension, inventory_extension, damage_extension)
        return
    end
 
    --Block
    if (me.state == states.SHOULD_BLOCK) then
        me.state = states.BLOCKING
        if(left_hand_weapon_extension) then
            left_hand_weapon_extension.start_action(left_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)              
        end
        if(right_hand_weapon_extension) then
            right_hand_weapon_extension.start_action(right_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)
        end
        return
 
    --Push
    elseif(me.state == states.SHOULD_PUSH and not status_extension.fatigued(status_extension)) then
        new_action = "action_one"
        new_sub_action = "push"
        if(item_template.actions[new_action][new_sub_action]) then
            if(left_hand_weapon_extension) then
                left_hand_weapon_extension.start_action(left_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)              
            end
            if(right_hand_weapon_extension) then
                right_hand_weapon_extension.start_action(right_hand_weapon_extension, new_action, new_sub_action, item_template.actions, t)
            end
        end
 
        --Reset block state
        me.state = states.NOT_BLOCKING
    end
 
    --Continue blocking
    if not(me.state == states.BLOCKING) then
        func(t, unit, input_extension, inventory_extension, damage_extension)
    end
end)
 
-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
me.create_options()