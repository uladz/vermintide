local mod_name = "InventoryFiltering"

local oi = OptionsInjector

Mods.InventoryFiltering = {}
Mods.InventoryFiltering.filters = {}
Mods.InventoryFiltering.favs = {}
Mods.InventoryFiltering.filename = "Favorite_items"
Mods.InventoryFiltering.hotkey = "r"

local me = Mods.InventoryFiltering

Mods.InventoryFiltering.save = function()
	local file_path = "mods/patch/storage/" .. Mods.InventoryFiltering.filename .. ".lua"

	local file = io.open(file_path, "w+")
	if file ~= nil then
		file:write("Mods.InventoryFiltering.favs = {\n")

		for _, item_id in ipairs(Mods.InventoryFiltering.favs) do
			file:write(item_id..",\n")
		end

		file:write("}\n")
		file:close()
	end
end

Mods.InventoryFiltering.load = function()
	Mods.exec("patch/storage", Mods.InventoryFiltering.filename)
end

local filter_operators = {
	["find"] = {
		5,
		2,
		function (op1, op2)
			return (string.find(string.lower(op1), string.lower(string.gsub(tostring(op2), "_", " "))) ~= nil)
		end
	},
	["not"] = {
		4,
		1,
		function (op1)
			return not op1
		end
	},
	["<"] = {
		3,
		2,
		function (op1, op2)
			return op1 < op2
		end
	},
	[">"] = {
		3,
		2,
		function (op1, op2)
			return op2 < op1
		end
	},
	["<="] = {
		3,
		2,
		function (op1, op2)
			return op1 <= op2
		end
	},
	[">="] = {
		3,
		2,
		function (op1, op2)
			return op2 <= op1
		end
	},
	["~="] = {
		3,
		2,
		function (op1, op2)
			return op1 ~= op2
		end
	},
	["=="] = {
		3,
		2,
		function (op1, op2)
			return op1 == op2
		end
	},
	["and"] = {
		2,
		2,
		function (op1, op2)
			return op1 and op2
		end
	},
	["or"] = {
		1,
		2,
		function (op1, op2)
			return op1 or op2
		end
	}
}

local is_favorite = function (backend_id)
	return table.contains(Mods.InventoryFiltering.favs, backend_id)
end

local filter_macros = {
	trait_names =  function (item_data, backend_id)
		local trait_names = ""
		if item_data.traits then
			for _, trait_name in ipairs(item_data.traits) do
				trait_names = trait_names.." "..Localize(BuffTemplates[trait_name].display_name)
			end
		end
		return trait_names
	end,
	item_name = function (item_data, backend_id)
		return Localize(item_data.display_name).." "..Localize(item_data.item_type)
	end,
	trait_names_and_item_name =  function (item_data, backend_id)
		local trait_names = ""
		if item_data.traits then
			for _, trait_name in ipairs(item_data.traits) do
				trait_names = trait_names.." "..Localize(BuffTemplates[trait_name].display_name)
			end
		end
		return Localize(item_data.display_name).." "..Localize(item_data.item_type).." "..trait_names
	end,
	is_fav = function (item_data, backend_id)
		return is_favorite(backend_id)
	end,
	are_traits_locked = function (item_data, backend_id)
		local slot_type = item_data.slot_type
		local is_trinket = slot_type == "trinket"
		if is_trinket or slot_type == "hat" then
			return false
		end
		local traits = item_data.traits
		local any_trait_unlocked = false
		if traits then
			for i = #traits, 1, -1 do
				local trait_name = traits[i]
				local trait_template = BuffTemplates[trait_name]

				if trait_template then
					any_trait_unlocked = any_trait_unlocked or (BackendUtils.item_has_trait(backend_id, trait_name) and true)
				end
			end
		end
		return not any_trait_unlocked
	end,
	item_key = function (item_data, backend_id)
		return item_data.key
	end,
	item_rarity = function (item_data, backend_id)
		return item_data.rarity
	end,
	slot_type = function (item_data, backend_id)
		return item_data.slot_type
	end,
	item_type = function (item_data, backend_id)
		return item_data.item_type
	end,
	trinket_as_hero = function (item_data, backend_id)
		if item_data.traits then
			for _, trait_name in ipairs(item_data.traits) do
				local trait_config = BuffTemplates[trait_name]
				local roll_dice_as_hero = trait_config.roll_dice_as_hero

				if roll_dice_as_hero then
					return true
				end
			end
		end

		return
	end,
	equipped_by = function (item_data, backend_id)
		local hero = ScriptBackendItem.equipped_by(backend_id)

		return hero
	end,
	current_hero = function (item_data, backend_id)
		local profile_synchronizer = Managers.state.network.profile_synchronizer
		local player = Managers.player:local_player()
		local profile_index = profile_synchronizer.profile_by_peer(profile_synchronizer, player.network_id(player), player.local_player_id(player))
		local hero_data = SPProfiles[profile_index]
		local hero_name = hero_data.display_name

		return hero_name
	end,
	can_wield_bright_wizard = function (item_data, backend_id)
		local hero_name = "bright_wizard"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_dwarf_ranger = function (item_data, backend_id)
		local hero_name = "dwarf_ranger"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_empire_soldier = function (item_data, backend_id)
		local hero_name = "empire_soldier"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_witch_hunter = function (item_data, backend_id)
		local hero_name = "witch_hunter"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	can_wield_wood_elf = function (item_data, backend_id)
		local hero_name = "wood_elf"
		local can_wield = item_data.can_wield

		return table.contains(can_wield, hero_name)
	end,
	player_owns_item_key = function (item_data, backend_id)
		local all_items = ScriptBackendItem.get_all_backend_items()

		for backend_id, config in pairs(all_items) do
			if item_data.key == config.key then
				return true
			end
		end

		return false
	end
}

Mods.InventoryFiltering.filters_to_string = function(self)
	local current_filter = "Current filter: "
	for i,v in ipairs(self.filters) do
		if i ~= 1 then
			current_filter = current_filter..", "
		end
		current_filter = current_filter..v
	end
	return current_filter
end

Mods.InventoryFiltering.get_filter = function(self)

	if not self.filters or #self.filters == 0 then
		return nil
	end

	local filter = ""
	for i,v in ipairs(self.filters) do
		if i > 1 then
			filter = filter.." and "
		end
		if v == "locked" then
			filter = filter.."true are_traits_locked =="
		elseif v == "favs" then
			filter = filter.."true is_fav =="
		else
			filter = filter..string.gsub(v, " ", "_").." trait_names_and_item_name find"
		end
	end
	return filter
end

local force_refresh = false
local function refresh_ui(menu)
	if Mods.InventoryFiltering.filters_last_update ~= Mods.InventoryFiltering:filters_to_string() or force_refresh then
		force_refresh = false
		Mods.InventoryFiltering.filters_last_update = Mods.InventoryFiltering:filters_to_string()
		menu:refresh()
	end
end

local function UI_update_hook(func, self, ...)
	refresh_ui(self)
	return func(self, ...)
end

Mods.hook.set(mod_name, "InventoryItemsUI.update", UI_update_hook)
Mods.hook.set(mod_name, "AltarItemsUI.update", UI_update_hook)
Mods.hook.set(mod_name, "ForgeItemsUI.update", UI_update_hook)

Mods.hook.set(mod_name, "BackendUtils.get_inventory_items", function(func, profile, slot, rarity)
	local item_id_list = ScriptBackendItem.get_items(profile, slot, rarity)
	local items = {}
	local unfiltered_items = {}

	local to_filter = {}

	for key, backend_id in pairs(item_id_list) do
		local item = BackendUtils.get_item_from_masterlist(backend_id)
		unfiltered_items[#unfiltered_items + 1] = item
		to_filter[backend_id] = item
	end

	if not Mods.InventoryFiltering:get_filter() then
		return unfiltered_items
	end

	local filtered_items = ScriptBackendCommon.filter_items(to_filter, nil)
	for _,v in ipairs(filtered_items) do
		items[#items + 1] = v
	end

	return items
end)

Mods.hook.set(mod_name, "ScriptBackendCommon.filter_items", function(func, items, filter_infix)

	local input_filter_present = not not filter_infix

	if not input_filter_present and Mods.InventoryFiltering:get_filter() then
		filter_infix = Mods.InventoryFiltering:get_filter()
	end

	local filter_postfix = ScriptBackendCommon.filter_postfix_cache[filter_infix]

	if not filter_postfix then
		filter_postfix = ScriptBackendCommon.infix_to_postfix_item_filter(filter_infix)
		ScriptBackendCommon.filter_postfix_cache[filter_infix] = filter_postfix
	end

	local item_master_list = ItemMasterList
	local stack = {}
	local passed = {}

	for backend_id, item in pairs(items) do
		local key = item.key
		local item_data = item_master_list[key]

		table.clear(stack)

		for i = 1, #filter_postfix, 1 do
			local token = filter_postfix[i]

			if filter_operators[token] then
				local num_params = filter_operators[token][2]
				local op_func = filter_operators[token][3]
				local op1 = table.remove(stack)

				if num_params == 1 then
					stack[#stack + 1] = op_func(op1)
				else
					local op2 = table.remove(stack)
					stack[#stack + 1] = op_func(op1, op2)
				end
			else
				local macro_func = filter_macros[token]

				if macro_func then
					stack[#stack + 1] = macro_func(item_data, backend_id)
				else
					stack[#stack + 1] = token
				end
			end
		end

		if stack[1] == true then
			local clone_item_data = table.clone(item_data)
			clone_item_data.backend_id = backend_id
			passed[#passed + 1] = clone_item_data
		end
	end

	if input_filter_present and Mods.InventoryFiltering:get_filter() and string.match(filter_infix, "^item_key == [%w_]+$") == nil then
		local repass_these_items = {}
		for _, item in ipairs(passed) do
			repass_these_items[item.backend_id] = item
		end
		return ScriptBackendCommon.filter_items(repass_these_items)
	end

	return passed
end)

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function remove_from_favorites(backend_id)
	if table.contains(Mods.InventoryFiltering.favs, backend_id) then
		local new_my_favs = {}
		for i,v in ipairs(Mods.InventoryFiltering.favs) do
			if v ~= backend_id then
				new_my_favs[#new_my_favs + 1] = v
			end
		end

		Mods.InventoryFiltering.favs = new_my_favs
	end
end

function toggle_favorite(backend_id)
	if table.contains(Mods.InventoryFiltering.favs, backend_id) then
		remove_from_favorites(backend_id)
		Mods.InventoryFiltering.save()
		return
	end

	Mods.InventoryFiltering.favs[#Mods.InventoryFiltering.favs + 1] = backend_id
	Mods.InventoryFiltering.save()
end

Mods.InventoryFiltering.is_favorites_filter_active = function(self)
	return table.contains(self.filters, "favs")
end

Mods.InventoryFiltering.toggle_favorites_filter = function(self)
	if not self:is_favorites_filter_active() then
		self.filters[#self.filters+1] = "favs"
		return
	end

	local new_filter = {}
	for i,v in ipairs(self.filters) do
		if v ~= "favs" then
			new_filter[#new_filter+1] = v
		end
	end
	self.filters = new_filter
end

local element_settings = {
	height_spacing = 4.5,
	height = 115,
	width = 535
}

favorite_keymaps = {
			win32 = {
				fav = {
					"keyboard",
					Mods.InventoryFiltering.hotkey,
					"pressed"
				},
			}
		}
favorite_keymaps.xb1 = favorite_keymaps.win32

local view_tab_changed = false

Mods.hook.set(mod_name, "InventoryItemsList.draw", function(func, self, ...)
	for _,v in ipairs(self.item_widget_elements) do
		if not v.style.text_favorite then
			v.style.text_favorite = {
				font_size = 30,
				word_wrap = false,
				pixel_perfect = true,
				horizontal_alignment = "left",
				vertical_alignment = "center",
				dynamic_font = true,
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("dark_red", 255),
				size = {
					30,
					38
				},
				offset = {
					element_settings.width - 225,
					12,
					6
				}
			}
		end
	end

	for _,v in ipairs(self.empty_widget_elements) do
		if not v.style.text_favorite then
			v.style.text_favorite = {
				font_size = 30,
				word_wrap = false,
				pixel_perfect = true,
				horizontal_alignment = "left",
				vertical_alignment = "center",
				dynamic_font = true,
				font_type = "hell_shark",
				text_color = Colors.get_color_table_with_alpha("dark_red", 255),
				size = {
					30,
					38
				},
				offset = {
					element_settings.width - 225,
					12,
					6
				}
			}
		end
	end

	local text_favorite_pass_exists = false
	for _,pass in ipairs(self.widget_definitions.inventory_list_widget.element.passes[1].passes) do
		if pass.text_id == "text_favorite" then
			text_favorite_pass_exists = true
			break
		end
	end
	if not text_favorite_pass_exists then
		local passes = self.widget_definitions.inventory_list_widget.element.passes[1].passes
		passes[#passes + 1] = {
						text_id = "text_favorite",
						pass_type = "text",
						style_id = "text_favorite",
						content_check_function = function(ui_content)
							if not ui_content.item then
								return false
							end
							return table.contains(Mods.InventoryFiltering.favs, ui_content.item.backend_id)
						end,
					}

		self.create_ui_elements(self)
		self.populate_widget_list(self)
	end

	return func(self, ...)
end)

local open_chat = nil
Mods.hook.set(mod_name, "InventoryItemsList.update", function(func, self, ...)

	func(self, ...)

	if open_chat and Managers.state.network:network_time() > open_chat then
		local tab_widget = Managers.chat.chat_gui.tab_widget
		local tab_hotspot = tab_widget.content.button_hotspot
		tab_hotspot.on_pressed = true
		open_chat = nil
	end

	if not Managers.input:get_input_service("favorite_input_service") then
		Managers.input:create_input_service("favorite_input_service", "favorite_keymaps")
		Managers.input:map_device_to_service("favorite_input_service", "keyboard")
		Managers.input:map_device_to_service("favorite_input_service", "mouse")
		Managers.input:map_device_to_service("favorite_input_service", "gamepad")
	end

	if view_tab_changed then
		view_tab_changed = false
		self.create_ui_elements(self)
		self.populate_widget_list(self)
		force_refresh = true
		return
	end

	if force_refresh then
		return
	end

	if Mods.InventoryFiltering.search_textbox and Mods.InventoryFiltering.search_textbox.has_focus then
		return
	end

	Managers.input:device_unblock_service("keyboard", 1, "favorite_input_service")
	local input_service = Managers.input:get_input_service("favorite_input_service")
	if input_service:get("fav") then
		local hover_index = self.hover_list_index
		if hover_index then
			local item_list_widget = self.item_list_widget
			local list_content = item_list_widget.content.list_content
			if list_content and list_content[hover_index] then
				local item = list_content[hover_index].item
				if item then
					toggle_favorite(item.backend_id)
					self.refresh_items_status(self)
				end
			end
		end
	end

	return
end)

local rarity_order = {
	common = 4,
	promo = 6,
	plentiful = 5,
	exotic = 2,
	rare = 3,
	unique = 1
}

local function sort_by_loadout_rarity_name(a, b)

	if a.equipped and not b.equipped then
		return true
	elseif b.equipped and not a.equipped then
		return false
	else
		if is_favorite(a.backend_id) and not is_favorite(b.backend_id) then
			return true
		elseif not is_favorite(a.backend_id) and is_favorite(b.backend_id) then
			return false
		else
			local a_rarity_order = rarity_order[a.rarity]
			local b_rarity_order = rarity_order[b.rarity]

			if a_rarity_order == b_rarity_order then
				local a_name = a.localized_name
				local b_name = b.localized_name

				if a_name == b_name then
					return a.backend_id < b.backend_id
				end

				return a_name < b_name
			else
				return a_rarity_order < b_rarity_order
			end
		end
	end

	return
end

local function sort_by_rarity_name(a, b)
	local a_rarity_order = rarity_order[a.rarity]
	local b_rarity_order = rarity_order[b.rarity]

	if is_favorite(a.backend_id) and not is_favorite(b.backend_id) then
		return false
	elseif not is_favorite(a.backend_id) and is_favorite(b.backend_id) then
		return true
	else
		if a_rarity_order == b_rarity_order then
			local a_name = a.localized_name
			local b_name = b.localized_name

			if a_name == b_name then
				return a.backend_id < b.backend_id
			end

			return a_name < b_name
		else
			return a_rarity_order < b_rarity_order
		end
	end

	return
end

local temp_trait_textures = {}
local temp_traits_unlocked = {}
local temp_traits_tooltip = {}

local function set_item_element_info(item_element, is_room_item, item, item_color, equipped_item, is_new, is_active, is_locked, allow_equipped_drag, ui_renderer)
	local content = item_element.content
	local style = item_element.style
	local traits = item.traits

	table.clear(temp_trait_textures)
	table.clear(temp_traits_tooltip)
	table.clear(temp_traits_unlocked)

	local tooltip_trait_locked_text = Localize("tooltip_trait_locked")
	local tooltip_trait_unique_text = Localize("unique_trait_description")
	local slot_type = item.slot_type
	local is_trinket = slot_type == "trinket"
	local never_locked = is_trinket or slot_type == "hat"

	if traits then
		for i = #traits, 1, -1 do
			local trait_name = traits[i]
			local trait_template = BuffTemplates[trait_name]

			if trait_template then
				local backend_id = item.backend_id
				local trait_unlocked = ((never_locked or BackendUtils.item_has_trait(backend_id, trait_name)) and true) or false
				local title_text = (trait_template.display_name and Localize(trait_template.display_name)) or "Unknown"
				local description_text = BackendUtils.get_item_trait_description(backend_id, i)
				local trait_icon = trait_template.icon or "icons_placeholder"
				temp_trait_textures[#temp_trait_textures + 1] = trait_icon
				temp_traits_unlocked[#temp_traits_unlocked + 1] = trait_unlocked
				local tooltip_text = title_text .. "\n" .. description_text

				if is_trinket then
					tooltip_text = tooltip_text .. "\n" .. tooltip_trait_unique_text
				elseif not trait_unlocked then
					tooltip_text = tooltip_text .. "\n" .. tooltip_trait_locked_text
				end

				temp_traits_tooltip[#temp_traits_tooltip + 1] = tooltip_text
			end
		end
	end

	table.clear(content.button_hotspot)
	table.clear(content.trait_slot_1_hotspot)
	table.clear(content.trait_slot_2_hotspot)
	table.clear(content.trait_slot_3_hotspot)
	table.clear(content.trait_slot_4_hotspot)

	content.item = item
	content.new = is_new
	content.visible = true
	content.active = is_active
	content.locked = is_locked
	content.hover_disabled = false
	content.equipped = equipped_item
	content.room_item = is_room_item
	content.trait_slot_1 = temp_trait_textures[1]
	content.trait_slot_2 = temp_trait_textures[2]
	content.trait_slot_3 = temp_trait_textures[3]
	content.trait_slot_4 = temp_trait_textures[4]
	content.locked_text = ""
	content.trait_slot_1_locked = not temp_traits_unlocked[1]
	content.trait_slot_2_locked = not temp_traits_unlocked[2]
	content.trait_slot_3_locked = not temp_traits_unlocked[3]
	content.trait_slot_4_locked = not temp_traits_unlocked[4]
	content.trait_slot_1_tooltip = temp_traits_tooltip[1] or ""
	content.trait_slot_2_tooltip = temp_traits_tooltip[2] or ""
	content.trait_slot_3_tooltip = temp_traits_tooltip[3] or ""
	content.trait_slot_4_tooltip = temp_traits_tooltip[4] or ""
	content.allow_equipped_drag = allow_equipped_drag or false
	local item_name = (item.name and item.localized_name) or "Unknown"

	if style.text_title and 25 < UTF8Utils.string_length(item_name) then
		item_name = UIRenderer.crop_text_width(ui_renderer, item_name, 400, style.text_title) or item_name
	end

	content.title = item_name
	content.item_texture_id = item.inventory_icon or "icons_placeholder"
	content.sub_title = (item.item_type and Localize(item.item_type)) or "Unknown"
	content.description = (item.description and Localize(item.description)) or "Unknown"
	style.item_frame_texture_id.color = table.clone(item_color)
	style.text_title.text_color = table.clone(item_color)
	local red_color = Colors.get_table("red")
	style.trait_slot_1_tooltip.last_line_color = ((is_trinket or not temp_traits_unlocked[1]) and table.clone(red_color)) or nil
	style.trait_slot_2_tooltip.last_line_color = ((is_trinket or not temp_traits_unlocked[2]) and table.clone(red_color)) or nil
	style.trait_slot_3_tooltip.last_line_color = ((is_trinket or not temp_traits_unlocked[3]) and table.clone(red_color)) or nil
	style.trait_slot_4_tooltip.last_line_color = ((is_trinket or not temp_traits_unlocked[4]) and table.clone(red_color)) or nil

	return
end

Mods.hook.set(mod_name, "InventoryItemsList.populate_widget_list", function(func, self, list_start_index, sort_list)

	self.hover_list_index = nil -- ADDITION

	local items = self.stored_items

	if items then
		local item_list_widget = self.item_list_widget
		list_start_index = list_start_index or item_list_widget.style.list_style.list_start_index or 1
		local num_items_in_list = #items

		if num_items_in_list < list_start_index then
			return
		end

		self._sync_item_list_equipped_status(self, items)

		if sort_list then
			if self.sort_by_equipment then
				table.sort(items, sort_by_loadout_rarity_name)
			else
				table.sort(items, sort_by_rarity_name)
			end
		end

		local settings = self.settings
		local new_backend_ids = ItemHelper.get_new_backend_ids()
		local disable_equipped_items = self.disable_equipped_items
		local accepted_rarity_list = self.accepted_rarity_list
		local disabled_backend_ids = self.disabled_backend_ids
		local tag_equipped_items = self.tag_equipped_items
		local selected_rarity = self.selected_rarity
		local num_item_slots = settings.num_list_items
		local num_draws = num_item_slots
		local list_content = {}
		local list_style = {
			vertical_alignment = "top",
			scenegraph_id = "item_list",
			size = settings.list_size,
			list_member_offset = {
				0,
				-(element_settings.height + element_settings.height_spacing),
				0
			},
			item_styles = {},
			columns = settings.columns,
			column_offset = settings.columns and element_settings.width + settings.column_offset
		}
		local item_active_list = (self.item_active_list and table.clear(self.item_active_list)) or {}
		local index = 1

		for i = list_start_index, (list_start_index + num_draws) - 1, 1 do
			local item = items[i]

			if item then
				local is_equipped = item.equipped
				local is_locked = false
				local is_active = true
				local is_new = false
				local item_rarity = item.rarity
				local item_color = self.get_rarity_color(self, item_rarity)
				local item_backend_id = item.backend_id

				if new_backend_ids and new_backend_ids[item_backend_id] then
					is_new = true
				end

				if (selected_rarity and item_rarity ~= selected_rarity) or (disable_equipped_items and is_equipped) then
					is_active = false
				end

				if is_active and self.disable_non_trait_items then
					local item_traits = item.traits

					if not item_traits or #item_traits < 1 then
						is_active = false
					end
				end

				if accepted_rarity_list and not accepted_rarity_list[item_rarity] then
					is_active = false
				end

				if disabled_backend_ids[item_backend_id] then
					is_active = is_active and false
				end

				local item_element = self.item_widget_elements[index]

				set_item_element_info(item_element, true, item, item_color, is_equipped, is_new, is_active, is_locked, not disable_equipped_items, self.ui_renderer)

				local content = item_element.content

				content.text_favorite = "FAV" -- ADDITION

				local style = item_element.style
				list_content[index] = content
				list_style.item_styles[index] = style
				item_active_list[item_backend_id] = is_active
				index = index + 1
			end
		end

		self.item_active_list = item_active_list
		list_style.start_index = 1
		list_style.list_start_index = list_start_index
		list_style.num_draws = num_draws
		item_list_widget.style.list_style = list_style
		item_list_widget.content.list_content = list_content
		item_list_widget.element.pass_data[1].num_list_elements = nil
		local list_content_n = #list_content
		self.number_of_real_items = num_items_in_list

		if list_content_n < num_draws then
			local padding_n = num_draws - #list_content%num_draws

			if padding_n < num_draws then
				for i = 1, padding_n, 1 do
					local empty_element = self.empty_widget_elements[i]
					local index = #list_content + 1
					empty_element.content.text_favorite = "FAV" -- ADDITION
					list_content[index] = empty_element.content
					list_style.item_styles[index] = empty_element.style
				end

				self.used_empty_elements = padding_n
			end
		end

		local selected_absolute_list_index = self.selected_absolute_list_index

		if selected_absolute_list_index then
			self.on_inventory_item_selected(self, selected_absolute_list_index)
		end
	end

	return
end)

Mods.hook.set(mod_name, "ForgeView._apply_item_filter", function(func, self, item_filter, update_list)
	local ui_pages = self.ui_pages
	local items_page = ui_pages.items
	self.item_filter = item_filter
	local current_profile_name = items_page.current_profile_name(items_page)

	if item_filter and current_profile_name and current_profile_name ~= "all" then
		local can_wield_name = "can_wield_" .. current_profile_name
		item_filter = item_filter .. " and " .. can_wield_name .. " == true"
	end

	if ui_pages.melt.active then
		item_filter = item_filter.." and is_fav == false"
	end

	items_page.set_item_filter(items_page, item_filter)

	if update_list then
		local play_sound = false

		items_page.refresh(items_page)
		items_page.on_inventory_item_selected(items_page, 1, play_sound)
	end

	return
end)

Mods.hook.set(mod_name, "ForgeLogic.poll_select_rerolled_traits", function (func, self)
	local data = self._reroll_trait_data

	fassert(data, "Polling for select reroll traits when there is nothing to ask about")

	local new_item_key = data.new_item_key

	if data and data.state == 3 then
		if data.accept_new then
			local commit_returned = Managers.backend:commit_status(data.commit_id) == Backend.COMMIT_SUCCESS

			if commit_returned then
				ScriptBackendItem.__dirtify()

				local items = ScriptBackendItem.get_filtered_items("item_key == " .. new_item_key)

				for _, item_data in ipairs(items) do
					local traits = ScriptBackendItem.get_traits(item_data.backend_id)

					if table.is_empty(traits) then
						if data.hero and data.slot then
							ScriptBackendItem.set_loadout_item(item_data.backend_id, data.hero, data.slot)
						end

						self._reroll_trait_data = nil

						if is_favorite(data.old_backend_id) then
							toggle_favorite(item_data.backend_id)
						end

						return {
							backend_id = item_data.backend_id,
							hero = data.hero,
							slot = data.slot
						}
					end
				end

				table.dump(items, "rerolled items", 2)
				ferror("Found %d items with the name %q, all of which had traits unlocked", #items, new_item_key)
			end
		else
			self._reroll_trait_data = nil

			return {}
		end
	end

	return
end)

local function forge_and_altar_selection_bar_index_changed_hook(func, ...)
	view_tab_changed = true
	return func(...)
end

Mods.hook.set(mod_name, "ForgeView.on_forge_selection_bar_index_changed", forge_and_altar_selection_bar_index_changed_hook)
Mods.hook.set(mod_name, "AltarView.on_forge_selection_bar_index_changed", forge_and_altar_selection_bar_index_changed_hook)

local any_screen_open = false

local function forge_and_altar_on_enter_hook(func, ...)
	any_screen_open = true
	view_tab_changed = true
	Mods.InventoryFiltering:reload_window()

	return func(...)
end

Mods.hook.set(mod_name, "ForgeView.on_enter", forge_and_altar_on_enter_hook)
Mods.hook.set(mod_name, "AltarView.on_enter", forge_and_altar_on_enter_hook)

local function forge_and_altar_on_exit_hook(func, ...)
	func(...)
	any_screen_open = false
	Mods.InventoryFiltering:destroy_window()
end

Mods.hook.set(mod_name, "ForgeView.on_exit", forge_and_altar_on_exit_hook)
Mods.hook.set(mod_name, "AltarView.on_exit", forge_and_altar_on_exit_hook)

Mods.hook.set(mod_name, "InventoryItemsUI.on_enter", function (func, ...)
	any_screen_open = true
	view_tab_changed = true

	return func(...)
end)

Mods.hook.set(mod_name, "InventoryItemsUI.on_exit", function(func, ...)
	func(...)
	any_screen_open = false
end)

local function focus_window (window)
	window:focus()
end

local function trim(s)
  return s:match'^%s*(.*%S)' or ''
end

local function execute_filter(textbox)
	if any_screen_open then
		local button = textbox.window:get_control("btn_clear_search")
		if textbox.text and #textbox.text > 0 then
			Mods.InventoryFiltering.filters = {}
			for term in string.gmatch(textbox.text, "[^,]+") do
				local trimmed_term = trim(term)
				if #trimmed_term > 0 then Mods.InventoryFiltering.filters[#Mods.InventoryFiltering.filters+1] = trimmed_term end
			end
			if button then
				button.text = "X"
			end
		else
			Mods.InventoryFiltering.filters = {}
			if button then
				button.text = "?"
			end
		end
		local favorites = textbox.window:get_control("chk_favorites")
		if favorites and favorites.value then
			Mods.InventoryFiltering.filters[#Mods.InventoryFiltering.filters+1] = "favs"
		end
	end
end

local function clear_filter_button_onclick(button)
	local textbox = button.window:get_control("txt_search")
	if not textbox then
		return
	end

	if textbox.text and #textbox.text > 0 then
		textbox.text = ""
		textbox:text_changed()
	else
		EchoConsole("----------FILTERING AND FAVORITES----------")
		EchoConsole("Hover over an inventory item and press \"r\" to set the item as your favorite! Repeat to undo. Favorites won't show on the scavenge tab of the forge!")
		EchoConsole("Filter by item name, item type or by trait names. Narrow the search with multiple search terms separated with a comma.")
		EchoConsole("----------------------------------------------------------------------")

		open_chat = Managers.state.network:network_time() + 0.1
	end

	execute_filter(textbox)
end

local function toggle_favorites_checkbox_toggle (checkbox)
	Mods.InventoryFiltering:toggle_favorites_filter()
end

Mods.InventoryFiltering.destroy_window = function(self)
	if self.filter_window ~= nil then
		self.filter_window:destroy()
	end
end

Mods.InventoryFiltering.create_window = function(self)
	local screen_w, screen_h = UIResolution()
	local scale = UIResolutionScale()
	local size = {40*scale, 36*scale}
	local border = 2*scale

	local window_width = 600

	self.filter_window = Mods.ui.create_window("inventory_filtering_window", {screen_w/2-window_width/2*scale, 30*scale}, {window_width*scale, 80*scale})
	self.filter_window.on_hover_enter = focus_window

	self.filter_window.color = {0, 0, 0, 0}
	self.filter_window.color_hover = {0, 0, 0, 0}

	local text = ""
	if Mods.InventoryFiltering.filters then
		for _, s in pairs(Mods.InventoryFiltering.filters) do
			if s ~= "favs" then	text = text..(#text > 0 and ", " or "")..s end
		end
	end

	self.search_textbox = self.filter_window:create_textbox("txt_search", {0*scale, 0*scale}, {(window_width-40)*scale, size[2]}, text, "Search ...", nil, execute_filter)

	local btn_clear_search = self.filter_window:create_button("btn_clear_search", {(window_width-40)*scale, 0*scale}, {size[1], size[2]}, "?", clear_filter_button_onclick)
	if text and #text > 0 then
		btn_clear_search.text = "X"
	end

	local favorites = Mods.InventoryFiltering.filters and table.contains(Mods.InventoryFiltering.filters, "favs")

	self.filter_window:create_checkbox("chk_favorites", {0*scale, 40*scale}, {size[1], size[2]}, "Show Favorites", favorites, toggle_favorites_checkbox_toggle)

	self.filter_window:init()
end

Mods.InventoryFiltering.reload_window = function(self)
	self:destroy_window()
	self:create_window()
end

local create_filter_window = function(func, self, ...)
	func(self, ...)
	Mods.InventoryFiltering:reload_window()
end

Mods.hook.set(mod_name, "InventoryView.on_enter", create_filter_window)
Mods.hook.set(mod_name, "InventoryView.unsuspend", create_filter_window)

Mods.hook.set(mod_name, "ForgeView.unsuspend", create_filter_window)
Mods.hook.set(mod_name, "AltarView.unsuspend", create_filter_window)

Mods.hook.set(mod_name, "InventoryView.on_exit", function(func, ...)
	func(...)
	Mods.InventoryFiltering:destroy_window()
end)

Mods.InventoryFiltering.load()