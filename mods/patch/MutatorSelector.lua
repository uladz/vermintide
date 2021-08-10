local mod_name = "MutatorSelectionGui"
 
local user_setting = Application.user_setting
 
local MOD_SETTINGS = {
	SHOW_MUTATOR_GUI = {
		["save"] = "cb_hudmod_show_mutator_gui",
		["widget_type"] = "stepper",
		["text"] = "Enabled",
		["tooltip"] = "Show Mutator Selection GUI\n" ..
				"On the mission selection screen, show options which allow mutators (such as " ..
				"Deathwish Difficulty and the Stormvermin Mutation) to be enabled and disabled.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2, -- By default second option is enabled, in this case On.
	},
}
 
MutatorMods = {}
MutatorMods.deathwish = {
	checkbox_label = "Deathwish",
	checkbox_position = {40, 41},
	tooltip_title = "Deathwish Difficulty",
	tooltip_text =	"A serious take on \"what if there was a difficulty after cataclysm?\"\n" ..
					"to give even the best of the best a serious challenge. If you thought\n" ..
					"the jump from nightmare to cataclysm was bad, then just you wait.",
	is_active = function()
		return not not rawget(_G, "deathwishtoken")
	end,
	toggle_active = function()
		if MutatorMods.stormvermin_mutation.is_active() then
			MutatorMods.stormvermin_mutation.toggle_active()
			Mods.chat.update("/deathwish")
			MutatorMods.stormvermin_mutation.toggle_active()
		else
			Mods.chat.update("/deathwish")
		end
	end,
	get_unavailable_reason = function(map_view)
		if map_view.selected_difficulty_stepper_index ~= 5 then
			return "Deathwish requires Cataclysm or Heroic difficulty to be selected."
		end
		return nil
	end,
}
MutatorMods.stormvermin_mutation = {
	checkbox_label = "Stormvermin Mutation",
	checkbox_position = {40, 13},
	tooltip_title = "The Stormvermin Mutation",
	tooltip_text =	"All slave rats are replaced by clan rats. All original clan rats are\n" ..
					"replaced with stormvermins. All specials are replaced with ogres.\n" ..
					"Chaos ensues. Playable on any difficulty, although the recommended\n" ..
					"difficulty is hard for full, serious group play, and easy or normal\n" ..
					"for play with bots or with an inexperienced team. Psychopaths may\n" ..
					"also attempt nightmare and cataclysm. Funeral costs are not covered.",
	is_active = function()
		return not not rawget(_G, "mutationtoken")
	end,
	toggle_active = function()
		Mods.chat.update("/mutation")
	end,
}
MutatorMods.onslaught = {
	checkbox_label = "Onslaught",
	checkbox_position = {580, 41},
	tooltip_title = "Adventure Mode - Onslaught",
	tooltip_text =	"\"The onslaught will not end, and your only way out is forward. Remember, they're numberless.\"\n" ..
				"Onslaught features massively increased spawn rates for ambient rats, hordes, specials and boss events,\n" ..
				"as well as a crazy redesign of all map specific events. Playable on all difficulties.",
	is_active = function()
		return not not rawget(_G, "onslaughttoken")
	end,
	toggle_active = function()
		Mods.chat.update("/onslaught")
	end,
	get_unavailable_reason = function(map_view)
		if map_view:active_game_mode() ~= "adventure" then
			return "Onslaught is only available on Adventure maps."
		end
		return nil
	end,
}
MutatorMods.slayers_oath = {
	checkbox_label = "Slayer's Oath",
	checkbox_position = {580, 13},
	tooltip_title = "Last Stand - Slayer's Oath waveset",
	tooltip_text =	"13 fully custom Last Stand waves compatible with Deathwish Difficulty,\n" ..
					"but also playable in other difficulties. Features insane combinations of skaven\n" ..
					"never seen anywhere before that will make short work of you should\n" ..
					"your discipline falter. Stand proud and tall, hero, for this is your\n" ..
					"last chance to do so.",
	is_active = function()
		return not not rawget(_G, "slayertoken")
	end,
	toggle_active = function()
		Mods.chat.update("/slayer")
	end,
	get_unavailable_reason = function(map_view)
		if map_view:active_game_mode() ~= "survival" then
			return "Slayer's Oath is only available on Last Stand maps."
		end
		return nil
	end,
}
 
local function on_checkbox_toggle(checkbox_control)
	if not checkbox_control.immutable then
		MutatorMods[checkbox_control.name].toggle_active()
	end
end
 
local map_gui_mod_panel = {
	update = function(self, map_view)
		if not self._window then
			self:_create_window(map_view)
			-- Adjust positions of a couple of tooltips in the map view so they wont
			-- be placed underneath the mutator panel.
			map_view.private_checkbox_widget.style.tooltip_text.cursor_offset = { 50, -55 }
			map_view.player_list_conuter_text_widget.style.tooltip_text.cursor_offset = { 10, -35 }
		end
 
		-- Update the state of each mutator checkbox.
		local window = self._window
		for mutator_name, mutator in pairs(MutatorMods) do
			local control = window:get_control(mutator_name)
			control.value = mutator.is_active()
 
			local unavailable_reason = mutator.get_unavailable_reason and mutator.get_unavailable_reason(map_view)
			if unavailable_reason then
				--if mutator.is_active() then
				--	mutator.toggle_active()
				--end
				control.immutable = true
				control.tooltip = mutator.tooltip_title .. " (Not Available)\n\n" .. unavailable_reason
			else
				control.immutable = false
				control.tooltip = mutator.tooltip_title .. "\n\n" .. mutator.tooltip_text
			end
		end
	end,
 
	hide = function(self)
		if self._window then
			self._window:destroy()
			self._window = nil
		end
	end,
 
	_create_window = function(self, map_view)
		-- The following is a workaround for weird errors I get in the map view after
		-- returning from a mission.
		World.destroy_gui(Managers.world:world(Mods.gui.default_world), Mods.gui.gui)
		Mods.gui.create_screen_ui()
 
 		-- Calculate the offset of the map UI from the bottom left of the screen.
		local res_scale = RESOLUTION_LOOKUP.scale
 		local root_size = map_view.ui_scenegraph.root.size
		local root_x = (RESOLUTION_LOOKUP.res_w - (root_size[1] * res_scale)) / 2
		local root_y = (RESOLUTION_LOOKUP.res_h - (root_size[2] * res_scale)) / 2
 
		-- Create a window for the mutators panel.
		local scale = UIResolutionScale()
		local window_pos = { math.round(root_x + (245 * scale)), math.round(root_y + (46 * scale)) }
		local window_size = { math.round(1087 * scale), math.round(70 * scale) }
		local window = Mods.ui.create_window("mutator_selection_window", window_pos, window_size)
		window:set("transparent", true)
		window:set("on_hover_enter", function() end)
 
		-- Create a background image for the panel, by cut-and-pasting a section of the
		-- map view background image.
		local bg_uvs = { { (505/1920), (845/1080) }, { (1482/1920), (941/1080) } }
		window:create_image("mutator_bg", "map_screen_bg", {0, 0}, window_size, nil, bg_uvs)
 
		-- Add a checkbox for each mutator.
		for mutator_name, mutator in pairs(MutatorMods) do
			local position = { mutator.checkbox_position[1] * scale, mutator.checkbox_position[2] * scale }
			local checkbox = window:create_checkbox_square(mutator_name, position, mutator.checkbox_label, false, on_checkbox_toggle)
			checkbox.theme.color_text = Colors.get_color_table_with_alpha("cheeseburger", 255)
			checkbox.theme.color_text_hover = Colors.get_color_table_with_alpha("white", 255)
			checkbox.theme.color_text_disabled = Colors.get_color_table_with_alpha("gray", 255)
			checkbox.theme.font = "scaled_hell_shark"
		end
 
		window:init()
		self._window = window
	end,
}
 
Mods.hook.set(mod_name, "MapView.draw", function(func, self, ...)
	func(self, ...)
	if user_setting(MOD_SETTINGS.SHOW_MUTATOR_GUI.save) then
		map_gui_mod_panel:update(self)
	end
end)
 
Mods.hook.set(mod_name, "MapView.on_exit", function(func, self, ...)
	func(self, ...)
	map_gui_mod_panel:hide()
end)
 
local function scaled_font_size(font)
	return font.size * UIResolutionScale()
end
 
-- _________________________________________________________________________ --
-- Mod initialization.
local function init_mod()
 
	-- Add options for this module to the Options UI.
	Mods.option_menu:add_group("mutator_gui", "Mutator Selection GUI")
	Mods.option_menu:add_item("mutator_gui", MOD_SETTINGS.SHOW_MUTATOR_GUI, true)
 
	Mods.ui.fonts:create("scaled_hell_shark", "hell_shark", 19)
	Mods.ui.fonts:get("scaled_hell_shark").font_size = scaled_font_size
 
	rawset(_G, "_mutator_gui_mod_previously_loaded", true)
end
 
local status, err = pcall(init_mod)
if err ~= nil then
	EchoConsole(err)
end