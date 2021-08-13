local mod_name = "PlayerListShowEquipment"
--[[
	Player List Show Equipment
	By: Walterr

	Mod which shows player equipment in the Player List screen.

	Installation: Place the file under mods/patch.
--]]

if not PlayerListEquipmentMod then
	PlayerListEquipmentMod = {}
end

local me = PlayerListEquipmentMod

local quest_view_definitions = local_require("scripts/ui/quest_view/quest_view_definitions")

local relevant_pass_ids = {
	tooltip_text = true,
	item_reward_texture = true,
	item_reward_frame_texture = true,
}

-- Creates a widget to show a single item of equipment (as an icon: we borrow some code from the
-- Quests & Contracts UI to create it).
local function create_equipment_widget(x_offset, y_offset)
	local widget = quest_view_definitions.create_quest_widget("player_list")

	-- The quest widget contains a bunch of elements we dont want - remove them and
	-- zero out the offsets of the ones we keep.
	local style = widget.style
	local passes = widget.element.passes
	for i = #passes, 1, -1 do
		local style_id = passes[i].style_id
		if not relevant_pass_ids[style_id] then
			table.remove(passes, i)
		elseif style_id == "tooltip_text" then
			style[style_id].cursor_offset = { 32, -120 }
		else
			local offset = style[style_id].offset
			offset[1] = x_offset
			offset[2] = y_offset
		end
	end
	widget.content.active = true
	return UIWidget.init(widget)
end

local y_padding = 50

local equipment_slots = {
	"slot_melee",
	"slot_ranged",
	"slot_trinket_1",
	"slot_trinket_2",
	"slot_trinket_3",
}

-- Borrow some more code from Quests & Contracts for generating item tooltips.
if not dummy_quest_view then
	dummy_quest_view = {
		_get_item_tooltip = QuestView._get_item_tooltip,
		_get_number_of_rows = QuestView._get_number_of_rows,
	}
end

-- Create all the equipment widgets and add them to the given IngamePlayerListUI instance.
local function create_equipment_widgets(player_list_ui)
	dummy_quest_view.ui_renderer = player_list_ui.ui_renderer

	local extra_y_offset = 0
	local equipment_widgets = {}
	player_list_ui.player_list_equipment_widgets = equipment_widgets

	for i, player_list_widget in ipairs(player_list_ui.player_list_widgets) do
		-- adjust the Y offsets of existing widgets to create room for the equipment icons
		local styles = player_list_widget.style
		local y_offset = styles.offset[2] - extra_y_offset
		styles.offset[2] = y_offset

		for style_id, style in pairs(styles) do
			if style.offset and style_id ~= "tooltip_text" then
				style.offset[2] = style.offset[2] - extra_y_offset
			end
		end

		-- create the new equipment icon widgets.
		local x_offset = 1024
		y_offset = y_offset - 56
		local slot_widgets = {}
		for _, equipment_slot in ipairs(equipment_slots) do
			slot_widgets[equipment_slot] = create_equipment_widget(x_offset, y_offset)
			x_offset = x_offset + 78
		end
		equipment_widgets[i] = slot_widgets
		extra_y_offset = extra_y_offset + y_padding
	end
end

Mods.hook.set(mod_name, "IngamePlayerListUI.create_ui_elements", function (orig_func, self)
	orig_func(self)
	create_equipment_widgets(self)
end)

local generate_item_tooltip = function(item, item_key, style, player, slot_name)
	local text = ""
	local color = {}

	pcall(function()
		local trait_template = BuffTemplates[item_key]

		if trait_template then -- Tinkets
			local display_name = trait_template.display_name or "Unknown"
			local description_text = BackendUtils.get_trait_description(
				item_key,
				item.rarity)

			-- Draw Information
			text = text .. Localize(item.display_name) .. "\n"
			color[#color + 1] = Colors.get_table(item.rarity)

			text = text .. "\n"
			color[#color + 1] = Colors.get_color_table_with_alpha("white", 255)

			text = text .. Localize(display_name) .. "\n"
			color[#color + 1] = Colors.get_color_table_with_alpha("cheeseburger", 255)

			text = text .. description_text .. "\n"
			local description_rows = dummy_quest_view:_get_number_of_rows(style, description_text)
			for k = 1, description_rows, 1 do
				color[#color + 1] = Colors.get_color_table_with_alpha("white", 255)
			end

		else -- Melee and Range weapons
			trait_template = BuffTemplates[item.traits[1]]
			local display_name = trait_template.display_name or "Unknown"

			text = text .. Localize(item.display_name) .. "\n"
			color[#color + 1] = Colors.get_table(item.rarity)

			for _, trait_name in ipairs(item.traits) do
				trait_template = BuffTemplates[trait_name]

				local backup_proc = {}

				-- Edit Proc data
				if player.local_player and trait_template.buffs[1].proc_chance then
					local player_name = SPProfiles[player.profile_index].display_name
					local player_traits = ScriptBackendItem.get_traits(backend_items._loadout[player_name][slot_name])

					-- Save proc
					backup_proc = table.clone(trait_template.buffs[1].proc_chance)

					if #trait_template.buffs[1].proc_chance > 1 then
						for x, player_trait in ipairs(player_traits) do
							if player_trait.trait_name == trait_name then
								trait_template.buffs[1].proc_chance[1] = player_trait.proc_chance
							end
						end
					end
				end

				if (not player.local_player) and trait_template.buffs[1].proc_chance then
					-- Save proc
					backup_proc = table.clone(trait_template.buffs[1].proc_chance)

					if me[player.peer_id] and me[player.peer_id][trait_name] then
						if #trait_template.buffs[1].proc_chance > 1 then
							trait_template.buffs[1].proc_chance[1] = me[player.peer_id][trait_name]
						end
					end
				end

				local description_text = BackendUtils.get_trait_description(
					trait_name,
					item.rarity)

				-- Draw Information
				text = text .. "\n"
				color[#color + 1] = Colors.get_color_table_with_alpha("white", 255)
				text = text .. Localize(trait_template.display_name) .. "\n"
				color[#color + 1] = Colors.get_color_table_with_alpha("cheeseburger", 255)
				text = text .. description_text .. "\n"

				local description_rows = dummy_quest_view:_get_number_of_rows(style, description_text)
				for k = 1, description_rows, 1 do
					color[#color + 1] = Colors.get_color_table_with_alpha("white", 255)
				end

				--Restore proc data
				if trait_template.buffs[1].proc_chance then
					trait_template.buffs[1].proc_chance = backup_proc
				end
			end
		end

		if (not player.local_player) and me[player.peer_id] == nil then
			text = text .. "No percentage data available\n"
			color[#color + 1] = Colors.get_color_table_with_alpha("red", 255)
		end
	end)

	return text, color
end

Mods.hook.set(mod_name, "IngamePlayerListUI.update_widgets", function (orig_func, self)
	orig_func(self)

	local players = self.players
	local player_list_equipment_widgets = self.player_list_equipment_widgets
	local num_players = self.num_players

	for i = 1, num_players, 1 do
		-- update this player''s equipment icons.
		local player_unit = players[i].player.player_unit
		local inventory_extn = ScriptUnit.has_extension(player_unit, "inventory_system")
		local attachment_extn = ScriptUnit.has_extension(player_unit, "attachment_system")
		local widgets = player_list_equipment_widgets[i]

		for slot_name, widget in pairs(widgets) do
			local content = widget.content

			local slot_data = inventory_extn and inventory_extn:get_slot_data(slot_name)
			if not slot_data then
				slot_data = attachment_extn and attachment_extn._attachments.slots[slot_name]
			end
			local item_key = slot_data and slot_data.item_data.key
			local item = item_key and ItemMasterList[item_key]
			if item then
				--This code taken from _assign_widget_data in scripts/ui/quest_view/quest_view.lua
				local style = widget.style

				-- Color
				local item_color = Colors.get_table(item.rarity)
				style.item_reward_frame_texture.color = item_color
				style.tooltip_text.line_colors[1] = item_color

				-- Basic tooltip information
				--local item_name = Localize(item.display_name)
				--local item_type_name = Localize(item.item_type)
				--content.tooltip_text = item_name .. "\n" .. item_type_name

				-- Advanced tooltip information
				--local tooltip_text, tooltip_colors = dummy_quest_view:_get_item_tooltip(item_key, style.tooltip_text)
				--content.tooltip_text = tooltip_text
				--style.tooltip_text.line_colors = tooltip_colors

				-- Development tooltip information
				local tooltip_text, tooltip_colors = generate_item_tooltip(
							item, item_key, style.tooltip_text, players[i].player, slot_name)
				content.tooltip_text = tooltip_text
				style.tooltip_text.line_colors = tooltip_colors

				if item.item_type ~= "bw_staff_firefly_flamewave" and (slot_name == "slot_ranged" or slot_name == "slot_melee") then
					content.item_reward_texture = "forge_icon_" .. item.item_type
				else
					content.item_reward_texture = item.inventory_icon
				end
			end
			content.has_item = not not item
		end
	end
end)

Mods.hook.set(mod_name, "IngamePlayerListUI.draw", function (orig_func, self, dt)
	orig_func(self, dt)

	local ui_renderer = self.ui_renderer
	local input_service = self.input_manager:get_service("player_list_input")
	UIRenderer.begin_pass(ui_renderer, self.ui_scenegraph, input_service, dt, nil, self.render_settings)

	-- draw the equipment icons.
	local player_list_equipment_widgets = self.player_list_equipment_widgets
	local num_players = self.num_players
	for i = 1, num_players, 1 do
		local widgets = player_list_equipment_widgets[i]
		for _, widget in pairs(widgets) do
			UIRenderer.draw_widget(ui_renderer, widget)
		end
	end

	UIRenderer.end_pass(ui_renderer)
end)

Mods.hook.set(mod_name, "IngamePlayerListUI.set_active", function (orig_func, self, active)
	orig_func(self, active)
	if active then
		-- update the equipment icons in case the player has changed his equipment.
		self:update_widgets()
	end
end)

-- Info sharing
local TraitUsingSlotTypes = {
	melee = true,
	ranged = true
}
Mods.hook.set(mod_name, "SimpleInventoryExtension.add_equipment",
function(func, self, slot_name, item_data, unit_template, extra_extension_data, ammo_percent)
	func(self, slot_name, item_data, unit_template, extra_extension_data, ammo_percent)

	local is_bot = self.is_bot
	local uses_traits = TraitUsingSlotTypes[item_data.slot_type]
	if uses_traits and not is_bot then
		local traits = self._get_traits(self, item_data)

		me[Network.peer_id()] = {}

		local other_slot_name = ""

		if slot_name == "slot_melee" then
			other_slot_name = "slot_ranged"
		else
			other_slot_name = "slot_melee"
		end

		local other_slot_data = self.get_slot_data(self, other_slot_name)
		local other_item_data = other_slot_data and other_slot_data.item_data
		local other_traits = other_item_data and self._get_traits(self, other_item_data)

		local player = self.player
		local player_name = SPProfiles[player.profile_index].display_name

		for _, trait in ipairs(traits) do
			local trait_template = BuffTemplates[trait.trait_name]
			if trait_template.buffs[1].proc_chance then
				local player_traits = ScriptBackendItem.get_traits(backend_items._loadout[player_name][slot_name])

				if #trait_template.buffs[1].proc_chance > 1 then
					for x, player_trait in ipairs(player_traits) do
						if player_trait.trait_name == trait.trait_name then
							me[Network.peer_id()][trait.trait_name] = player_trait.proc_chance
						end
					end
				end
			end
		end

		if other_traits then
			for _, trait in ipairs(other_traits) do
				local trait_template = BuffTemplates[trait.trait_name]
				if trait_template.buffs[1].proc_chance then
					local player_traits = ScriptBackendItem.get_traits(backend_items._loadout[player_name][other_slot_name])

					if #trait_template.buffs[1].proc_chance > 1 then
						for x, player_trait in ipairs(player_traits) do
							if player_trait.trait_name == trait.trait_name then
								me[Network.peer_id()][trait.trait_name] = player_trait.proc_chance
							end
						end
					end
				end
			end
		end

		if Managers.player.is_server then
			Mods.network.send_rpc_clients("rpc_playerlist_set_proc_chances", Network.peer_id(), me[Network.peer_id()])
		else
			for _, player in pairs(Managers.player:human_players()) do
				if player.peer_id ~= Managers.player:local_player().peer_id then
					Mods.network.send_rpc("rpc_playerlist_set_proc_chances", player.peer_id, Network.peer_id(), me[Network.peer_id()])
				end
			end
		end
	end
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, ...)
	func(...)
	if not Managers.player.is_server then
		for _, player in pairs(Managers.player:human_players()) do
			if player.peer_id ~= Managers.player:local_player().peer_id then
				Mods.network.send_rpc("rpc_playerlist_request_proc_chances_full_list", player.peer_id, "")
			end
		end
	end
end)

-- Network
Mods.network.register("rpc_playerlist_request_proc_chances_full_list", function(sender, string)
	if me[Network.peer_id()] ~= nil then
		Mods.network.send_rpc("rpc_playerlist_set_proc_chances", sender, Network.peer_id(), me[Network.peer_id()])
	end
end)

Mods.network.register("rpc_playerlist_set_proc_chances", function(sender, peer, proc_list)
	me[peer] = proc_list

	for peer_id, list in pairs(me) do
		if Managers.player:players_at_peer(peer_id) == nil then
			me[peer_id] = nil
		end
	end
end)
