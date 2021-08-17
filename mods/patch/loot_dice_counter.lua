--[[
  Name: Loot Dice Counter (ported from VMF by VernonKun)
  Author: Ithiridiel
  Version: 1.0.1
  Updated: 3/12/2021
  Link: https://www.nexusmods.com/vermintide/mods/51

  Tired of not being able to tell how many loot dice you found in a level so far? Want to know when
  to stop going out of your way to open chests? Then this mod is for you!

  This mod shows the number of cursed loot dice picked up so far in the player list menu. Using a
  "Stone of Pure Luck" as a placeholder, every icon in the bottom right of the player menu stands
  for one loot die found.

  Installation: Place the file under mods/patch.
  Creates no options, enabled permanently.
--]]

local LootDiceCounter = {}
local mod_name = "LootDiceCounter"

-- Here I borrow a lot of the UI code from code from PlayerListEquipment mod / Quests & Contracts
LootDiceCounter.definitions = local_require("scripts/ui/quest_view/quest_view_definitions")

LootDiceCounter.relevant_style_ids = {
    item_reward_texture = true,
    item_reward_frame_texture = true,
}

LootDiceCounter.create_dice_widget = function(x_offset, y_offset)
    local widget = LootDiceCounter.definitions.create_quest_widget("player_list")
    widget.scenegraph_id = "player_list"
    local passes = widget.element.passes

    widget.content.active = true

    -- The quest widget contains a bunch of elements we dont want - remove them and
    -- zero out the offsets of the ones we keep.
    for i = #passes, 1, -1 do
        local style_id = passes[i].style_id

        if not LootDiceCounter.relevant_style_ids[style_id] then
            table.remove(passes, i)
        elseif style_id == "tooltip_text" then
            widget.style[style_id].cursor_offset = { 32, -32 }
        else
            local offset = widget.style[style_id].offset

            offset[1] = x_offset
            offset[2] = y_offset
        end
    end

    local created_widget = UIWidget.init(widget)
    return created_widget
end

LootDiceCounter.create_dice_widgets = function(player_list_ui)
    local loot_dice_widgets = {}

    local x_offset = 1258
    local y_offset = -430

    local mission_system = Managers.state.entity:system("mission_system")
    local active_mission = mission_system.active_missions
    local cursed_loot_dice_amount = 0

    if active_mission.bonus_dice_hidden_mission then
        cursed_loot_dice_amount = active_mission.bonus_dice_hidden_mission.current_amount
    end

    for i = 1, cursed_loot_dice_amount, 1 do
        loot_dice_widgets[i] = LootDiceCounter.create_dice_widget(x_offset, y_offset)
        x_offset = x_offset + 78
    end

    player_list_ui.player_list_loot_dice_widgets = loot_dice_widgets
end

-- HOOKS:

Mods.hook.set(mod_name, "IngamePlayerListUI.draw", function (func, self, dt)
    func(self, dt)

    safe_pcall(function()
        local ui_renderer = self.ui_renderer
        local input_service = self.input_manager:get_service("player_list_input")

        UIRenderer.begin_pass(ui_renderer, self.ui_scenegraph, input_service, dt, nil, self.render_settings)

        local mission_system = Managers.state.entity:system("mission_system")
        local active_mission = mission_system.active_missions
        local cursed_loot_dice_amount = 0

        if active_mission.bonus_dice_hidden_mission then
            cursed_loot_dice_amount = active_mission.bonus_dice_hidden_mission.current_amount
        end

        -- draw the equipment icons.
        local widgets = self.player_list_loot_dice_widgets

        for _, widget in pairs(widgets) do
            UIRenderer.draw_widget(ui_renderer, widget)
        end

        UIRenderer.end_pass(ui_renderer)
    end)

end)

Mods.hook.set(mod_name, "IngamePlayerListUI.update_widgets", function (func, self)
    func(self)

    LootDiceCounter.create_dice_widgets(self)

    safe_pcall(function()
        local mission_system = Managers.state.entity:system("mission_system")
        local active_mission = mission_system.active_missions
        local cursed_loot_dice_amount = 0

        if active_mission.bonus_dice_hidden_mission then
            cursed_loot_dice_amount = active_mission.bonus_dice_hidden_mission.current_amount
        end

        for i = 1, cursed_loot_dice_amount, 1 do
           local widgets = self.player_list_loot_dice_widgets

            for _, widget in pairs(widgets) do
                local content = widget.content

                local item_key = "trinket_increase_luck_tier3"
                local item = ItemMasterList[item_key]
                --item.inventory_icon = "loot_screen_dice_2"
                if item then
                    --This code taken from _assign_widget_data in scripts/ui/quest_view/quest_view.lua
                    local style = widget.style

                    -- Color
                    local item_color = Colors.get_table("unique")
                    style.item_reward_frame_texture.color = item_color
                    style.tooltip_text.line_colors[1] = item_color

                    content.item_reward_texture = item.inventory_icon
                end
                content.has_item = not not item
            end
        end
    end)
end)
