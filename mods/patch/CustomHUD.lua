local mod_name = "CustomHUD"

local user_setting = Application.user_setting

local MOD_SETTINGS = {
	CUSTOM_HUD = {
		["save"] = "cb_custom_hud",
		["widget_type"] = "stepper",
		["text"] = "Choose HUD Preset",
		["tooltip"] = "Choose between different HUDs:\n" ..
			"Default HUD:\n" ..
			"Vanilla game HUD.\n" ..
			"\n" ..
			"Console HUD:\n" ..
			"A different HUD is used when you play the game with a gamepad, one which has a larger health " ..
			"bar but is more compact overall. Enabling this option will cause the gamepad HUD to be used " ..
			"even when you are not using a gamepad.\n" ..
			"\n" ..
			"Custom HUD:\n" ..
			"Minimalistic, screen real estate saving HUD.",
		["value_type"] = "number",
		["options"] = {
			{text = "Default HUD", value = 1},
			{text = "Console HUD", value = 2},
			{text = "Custom HUD", value = 3},
		},
		["default"] = 1, -- Default second option is enabled. In this case Off
	},
}

CustomHUD = CustomHUD or {}
CustomHUD.backups = CustomHUD.backups or {}

-- store things were initialized flags
CustomHUD.init = CustomHUD.init or {}

CustomHUD.OFF = 1
CustomHUD.GAMEPAD = 2
CustomHUD.CUSTOM = 3

-- we'll keep these updated
CustomHUD.current_hud = CustomHUD.current_hud or CustomHUD.OFF
CustomHUD.enabled = CustomHUD.enabled or user_setting(MOD_SETTINGS.CUSTOM_HUD.save) == CustomHUD.CUSTOM
CustomHUD.was_toggled = CustomHUD.was_toggled or false -- this will be true on manual switching in mod options, not on game start
CustomHUD.is_gamepad_active = CustomHUD.is_gamepad_active or false

local temp_slot_texture_mapping = {
	slot_healthkit = "default_heal_icon",
	slot_potion = "default_potion_icon",
	slot_grenade = "default_grenade_icon",
}
local custom_player_widget_def =
{
	scenegraph_id = "pivot",
	offset = { -245, -30, 1 },
	element = {
		passes = {
			{
				pass_type = "texture",
				style_id = "bg_slot_1",
				texture_id = "bg_slot",
			},
			{
				pass_type = "texture_uv",
				style_id = "item_slot_1",
				content_id = "item_slot_1",
			},
			{
				pass_type = "texture",
				style_id = "bg_slot_2",
				texture_id = "bg_slot",
			},
			{
				pass_type = "texture_uv",
				style_id = "item_slot_2",
				content_id = "item_slot_2",
			},
			{
				pass_type = "texture",
				style_id = "bg_slot_3",
				texture_id = "bg_slot",
			},
			{
				pass_type = "texture_uv",
				style_id = "item_slot_3",
				content_id = "item_slot_3",
			},
			{
				text_id = "ammo_text_melee",
				pass_type = "text",
				style_id = "ammo_text_melee",
				content_check_function = function (content)
					return not content.stance_bar.active
				end,
			},
			{
				text_id = "ammo_text_1",
				pass_type = "text",
				style_id = "ammo_text_1",
				content_check_function = function (content)
					return not content.stance_bar.active
				end,
			},
			{
				text_id = "ammo_text_2",
				pass_type = "text",
				style_id = "ammo_text_2",
				content_check_function = function (content)
					return not content.stance_bar.active
				end,
			},
			{
				texture_id = "ammo_divider",
				pass_type = "texture",
				style_id = "ammo_divider",
				content_check_function = function (content)
					return not content.stance_bar.active and content.ammo_text_2 ~= ""
				end,
			},
			{
				pass_type = "texture_uv",
				style_id = "bg_ammo",
				content_id = "bg_ammo_c",
				content_check_function = function (content)
					return not content.stance_bar.active
				end,
			},
			{
				pass_type = "rect",
				style_id = "ammo_bar_warning",
				content_check_function = function(content)
					return not content.stance_bar.active and content.show_reload_reminder
				end,
			},
			{
				pass_type = "texture_uv",
				style_id = "bg_ammo_melee",
				content_id = "bg_ammo_c",
				content_check_function = function (content)
					return not content.stance_bar.active and content.ammo_text_melee ~= ""
				end,
			},
			{
				pass_type = "texture",
				style_id = "stance_bar_fg",
				texture_id = "stance_bar_fg",
				content_check_function = function (content)
					return content.stance_bar.active
				end
			},
			{
				pass_type = "texture",
				style_id = "stance_bar_lit",
				texture_id = "stance_bar_lit",
				content_check_function = function (content)
					return content.stance_bar.active
				end
			},
			{
				pass_type = "texture",
				style_id = "stance_bar_glow",
				texture_id = "stance_bar_glow",
				content_check_function = function (content)
					return content.stance_bar.active
				end
			},
			{
				style_id = "stance_bar",
				pass_type = "texture_uv_dynamic_color_uvs_size_offset",
				content_id = "stance_bar",
				content_check_function = function (content)
					return content.active
				end,
				dynamic_function = function (content, style, size, dt)
					local bar_value = content.bar_value
					local uv_start_pixels = style.uv_start_pixels
					local uv_scale_pixels = style.uv_scale_pixels
					local uv_pixels = uv_start_pixels + uv_scale_pixels*bar_value
					local uvs = style.uvs
					local uv_scale_axis = style.scale_axis
					local offset_scale = style.offset_scale
					local offset = style.offset
					uvs[1][uv_scale_axis] = 1 - uv_pixels/(uv_start_pixels + uv_scale_pixels)
					size[uv_scale_axis] = uv_pixels

					return content.color, uvs, size, offset
				end
			},
			{
				pass_type = "rect",
				style_id = "hp_bar_rect",
				content_check_function = function(content) return content.show end,
			},
			{
				pass_type = "rect",
				style_id = "hp_bar_rect2",
				content_check_function = function(content) return content.show end,
			},
			{
				pass_type = "texture",
				style_id = "host_icon",
				texture_id = "host_icon",
				content_check_function = function(content) return content.is_host end,
			},
		},
	},
	content = {
		stance_bar = {
			bar_value = 0,
			active = false,
			texture_id = "stance_bar_orange",
		},
		stance_bar_fg = "stance_bar_frame",
		stance_bar_glow = "stance_bar_glow_orange",
		stance_bar_lit = "stance_bar_frame_lit",
		item_slot_1 = {
			texture_id = "teammate_consumable_icon_medpack_empty",
			uvs = {
				{ 0.15, 0.15 },
				{ 0.85, 0.85 }
			},
		},
		item_slot_2 = {
			texture_id = "teammate_consumable_icon_potion_empty",
			uvs = {
				{ 0.15, 0.15 },
				{ 0.85, 0.85 }
			},
		},
		item_slot_3 = {
			texture_id = "teammate_consumable_icon_grenade_empty",
			uvs = {
				{ 0.15, 0.15 },
				{ 0.85, 0.85 }
			},
		},
		bg_slot = "consumables_frame_bg_lit",
		bg_ammo_c = {
			texture_id = "console_weapon_slot",
			uvs = {
				{ 0.002, 0.02 },
				{ 1 - 0.002, 1 }
			},
			stance_bar = {
				bar_value = 0,
				active = false,
				texture_id = "stance_bar_orange",
			},
			ammo_text_melee = "",
		},
		ammo_text_1 = "",
		ammo_text_2 = "",
		ammo_text_melee = "",
		ammo_divider = "weapon_generic_icons_ammodivider",
		show_reload_reminder = false,
		show = true,
		is_host = false,
		host_icon = "host_icon",
	},
	style = {
		stance_bar_fg = {
			size = {
				32,
				138
			},
			offset = {
				-31,
				-51,
				3
			},
			color = {
				255,
				255,
				255,
				255
			},
		},
		stance_bar_lit = {
			size = {
				32,
				138
			},
			offset = {
				-31,
				-51,
				4
			},
			color = {
				0,
				255,
				255,
				255
			},
		},
		stance_bar_glow = {
			size = {
				32,
				138
			},
			offset = {
				-24,
				-51,
				0
			},
			color = {
				0,
				255,
				255,
				255
			},
		},
		stance_bar = {
			uv_start_pixels = 0,
			uv_scale_pixels = 71,
			offset_scale = 1,
			scale_axis = 2,
			offset = {
				-7,
				-9,
				1
			},
			size = {
				9,
				0
			},
			color = {
				255,
				255,
				255,
				255
			},
			uvs = { { 0, 0 }, { 1, 1 } },
		},
		bg_slot_1 = {
			size = {
				64,
				64
			},
			offset = {
				4,
				0,
				1
			},
			color = {
				100,
				255,
				255,
				255
			},
		},
		item_slot_1 = {
			size = {
				48,
				48
			},
			offset = {
				8+4,
				8,
				2,
			},
			color = {
				50,
				255,
				255,
				255
			},
		},
		bg_slot_2 = {
			size = {
				64,
				64
			},
			offset = {
				64,
				0,
				1
			},
			color = {
				100,
				255,
				255,
				255
			},
		},
		item_slot_2 = {
			size = {
				48,
				48
			},
			offset = {
				64+8,
				8,
				2,
			},
			color = {
				50,
				255,
				255,
				255
			},
		},
		bg_slot_3 = {
			size = {
				64,
				64
			},
			offset = {
				64*2-4,
				0,
				1
			},
			color = {
				100,
				255,
				255,
				255
			},
		},
		item_slot_3 = {
			size = {
				48,
				48
			},
			offset = {
				64*2+4,
				8,
				2,
			},
			color = {
				50,
				255,
				255,
				255
			},
		},
		bg_ammo_melee = {
			size = {
				32*2,
				38
			},
			offset = {
				64,
				104,
				1
			},
			color = {
				150,
				255,
				255,
				255
			}
		},
		ammo_text_melee = {
			offset = {
				82,
				106,
				2,
			},
			size = {
				32,
				32
			},
			pixel_perfect = false,
			font_size = 32,
			dynamic_font = true,
			font_type = "hell_shark",
			text_color = {200,0,191,255},
			horizontal_alignment = "center",
			vertical_alignment = "center",
		},
		ammo_text_1 = {
			offset = {
				53, -- gets updated later
				66,
				2,
			},
			size = {
				32,
				32
			},
			pixel_perfect = false,
			font_size = 32,
			dynamic_font = true,
			font_type = "hell_shark",
			text_color = {200,0,191,255},
			horizontal_alignment = "right",
			vertical_alignment = "center",
		},
		ammo_text_2 = {
			offset = {
				101,
				66,
				2,
			},
			size = {
				32,
				32
			},
			pixel_perfect = false,
			font_size = 32,
			dynamic_font = true,
			font_type = "hell_shark",
			text_color = {200,0,191,255},
			horizontal_alignment = "left",
			vertical_alignment = "center",
		},
		ammo_divider = {
			offset = {
				25+64,
				64+2,
				2,
			},
			size = {
				8,
				32
			},
			color = {75,255,255,255},
		},
		bg_ammo = {
			size = {
				64*2,
				38
			},
			offset = {
				32,
				64,
				1
			},
			color = {
				150,
				255,
				255,
				255
			}
		},
		ammo_bar_warning = {
			size = {
				64*2-2,
				38-2
			},
			offset = {
				32+1,
				64+1,
				0
			},
			color = {
				100,
				255,
				0,
				0
			}
		},
		hp_bar_rect = {
			offset = {8, -20, -16},
			size = {182, 19},
			color = {255, 105,105,105},
		},
		hp_bar_rect2 = {
			offset = {9, -19, -15},
			size = {180, 17},
			color = {255, 0,0,0},
		},
		host_icon = {
			offset = {15+182, -18, -16},
			size = { 18, 14 },
		},
	},
}

--- custom widget for other players
local other_players_widget_def =
{
	scenegraph_id = "pivot",
	offset = { 0, 0, 10 },
	element = {
			passes = {
			{
				pass_type = "texture",
				style_id = "custom_character_portrait",
				texture_id = "custom_character_portrait",
				content_check_function = function(content) return CustomHUD.enabled end,
			},
			{
				style_id = "custom_player_level",
				pass_type = "text",
				text_id = "player_level",
				content_check_function = function(content) return CustomHUD.enabled and content.player_level end,
			},
			{
				text_id = "player_name",
				pass_type = "text",
				style_id = "custom_player_name",
				content_check_function = function(content) return CustomHUD.enabled and content.player_name and not content._customhud_is_bot end,
			},
			{
				pass_type = "texture",
				style_id = "custom_portrait_overlay",
				texture_id = "custom_portrait_overlay",
				content_check_function = function(content) return content.display_portrait_overlay and content.display_custom_portrait_overlay end,
			},
			{
				pass_type = "rect",
				style_id = "hp_bar_rect",
				content_check_function = function(content) return content.show end,
			},
			{
				pass_type = "rect",
				style_id = "hp_bar_rect2",
				content_check_function = function(content) return content.show end,
			},
			{
				pass_type = "rect",
				style_id = "hp_bar_rect3",
				content_check_function = function(content) return content.show end,
			},
			{
				text_id = "current_hp",
				pass_type = "text",
				style_id = "current_hp",
				content_check_function = function(content) return content.show and content.current_hp ~= nil end,
			},
			{
				pass_type = "texture",
				style_id = "host_icon",
				texture_id = "host_icon",
				content_check_function = function(content) return content.is_host end,
			},
		}
	},
	content = {
		player_level = "456",
		current_hp = "100",
		player_name = "Brobrobro",
		_customhud_is_bot = false,
		custom_character_portrait = "hero_icon_medium_witch_hunter_yellow",
		custom_portrait_overlay = "unit_frame_red_overlay",
		display_portrait_overlay = false,
		display_custom_portrait_overlay = false,
		is_host = false,
		host_icon = "host_icon",
	},
	style = {
		custom_player_level = {
			vertical_alignment = "center",
			horizontal_alignment = "center",
			font_type = "hell_shark",
			font_size = 18,
			offset = {67, -42.5, 3},
			text_color = Colors.color_definitions.cheeseburger,
		},
		current_hp = {
			vertical_alignment = "center",
			horizontal_alignment = "left",
			font_type = "arial",
			font_size = 14,
			offset = {59, -26, 0},
			size = {182, 14},
			text_color = Colors.color_definitions.white,
		},
		custom_character_portrait = {
			offset = {50, -14, 0},
			size = {45, 45},
			color = {255,255,255,255},
		},
		custom_player_name = {
			vertical_alignment = "center",
			horizontal_alignment = "left",
			font_type = "hell_shark",
			font_size = 18,
			text_color = Colors.color_definitions.white,
			offset = {95, -37.5, 3},
		},
		custom_portrait_overlay = {
			offset = {20,-55, 20},
			size = {245, 95},
			color = {255, 255, 255, 255},
		},
		hp_bar_rect = {
			offset = {53, -27, -17},
			size = {184, 16},
			color = {255, 105,105,105},
		},
		hp_bar_rect2 = {
			offset = {55, -25, -15},
			size = {180, 12},
			color = {255, 0,0,0},
		},
		hp_bar_rect3 = {
			offset = {54, -26, -16},
			size = {182, 14},
			color = {255, 0,0,0},
		},
		host_icon = {
			offset = {76, -8, 0},
			size = { 16, 12 },
		},
	},
}

--- create style and pass for custom_item_slot_x elements
for i=1,3 do
	other_players_widget_def.element.passes[#other_players_widget_def.element.passes+1] = {
		pass_type = "texture_uv",
		style_id = "custom_item_slot_"..i,
		content_id = "custom_item_slot_"..i,
		content_check_function = function(content, style)
			if not CustomHUD.enabled then
				return false
			else
				return content.show
			end
		end,
	}

	other_players_widget_def.style["custom_item_slot_"..i] = {
		offset = {100+45*(i-1), -9, 7},
		size = {38, 38},
		color = {255, 255, 255, 255},
	}
end

--- white and yellow variants of hero icons
local hero_icons = {
	white = {
		witch_hunter = "hero_icon_medium_witch_hunter_white",
		empire_soldier = "hero_icon_medium_empire_soldier_white",
		dwarf_ranger = "hero_icon_medium_dwarf_ranger_white",
		test_profile = "hero_icon_medium_empire_soldier_white",
		wood_elf = "hero_icon_medium_way_watcher_white",
		bright_wizard = "hero_icon_medium_bright_wizard_white"
	},
	yellow = {
		witch_hunter = "hero_icon_medium_witch_hunter_yellow",
		empire_soldier = "hero_icon_medium_empire_soldier_yellow",
		dwarf_ranger = "hero_icon_medium_dwarf_ranger_yellow",
		test_profile = "hero_icon_medium_empire_soldier_yellow",
		wood_elf = "hero_icon_medium_way_watcher_yellow",
		bright_wizard = "hero_icon_medium_bright_wizard_yellow"
	}
}

local custom_player_widget = nil

--- update custom widgets based on current player status
UnitFrameUI._customhud_update = function (self, has_respawned, is_dead, is_wounded, player_unit_missing, out_of_wounds, is_bot, current_hp)
	local widget_loadout_static = self._widget_by_name(self, "loadout_static")
	if self._other_players_widget then
		local color_dead = {255,128,128,128}
		local color_respawned = {170,50,205,50}

		local function set_level_and_name_text_color(color)
			self._other_players_widget.style.custom_player_name.text_color = color
			self._other_players_widget.style.custom_player_level.text_color = color
		end

		if is_dead or player_unit_missing then
			set_level_and_name_text_color(color_dead)
			self._other_players_widget.style.custom_character_portrait.color = {40,255,255,255}
		elseif has_respawned then
			set_level_and_name_text_color(color_respawned)
			self._other_players_widget.style.custom_character_portrait.color = {215,0,225,0}
		elseif is_wounded or out_of_wounds then
			set_level_and_name_text_color(Colors.color_definitions.white)
			self._other_players_widget.style.custom_character_portrait.color = {175,255,255,255}
		else
			set_level_and_name_text_color(Colors.color_definitions.cheeseburger)
			self._other_players_widget.style.custom_character_portrait.color = {255,255,225,255}
		end

		self._other_players_widget.style.custom_player_name.offset[2] = (is_dead or player_unit_missing or has_respawned) and -19.5 or -39.5
		self._other_players_widget.style.custom_player_level.offset[2] = (is_dead or player_unit_missing or has_respawned) and -19.5 or -39.5

		self._other_players_widget.content._customhud_is_bot = is_bot
		self._other_players_widget.content._customhud_is_dead = is_dead
		self._other_players_widget.content._customhud_player_unit_missing = player_unit_missing
		self._other_players_widget.content._customhud_has_respawned = has_respawned
		self._other_players_widget.content.current_hp = current_hp
		-- if current_hp == "100%" then
			self._other_players_widget.content.current_hp = nil
		-- end

		self._set_widget_dirty(self, self._other_players_widget)
	end

	self._customhud_is_bot = is_bot
	self._customhud_is_dead = is_dead
	self._customhud_player_unit_missing = player_unit_missing
	self._customhud_has_respawned = has_respawned

	widget_loadout_static.content._customhud_is_bot = is_bot
	widget_loadout_static.content._customhud_is_dead = is_dead
	widget_loadout_static.content._customhud_player_unit_missing = player_unit_missing
	widget_loadout_static.content._customhud_has_respawned = has_respawned

	local widget_loadout_dynamic = self._widget_by_name(self, "loadout_dynamic")
	widget_loadout_dynamic.content._customhud_is_dead = is_dead
	widget_loadout_dynamic.content._customhud_player_unit_missing = player_unit_missing
	widget_loadout_dynamic.content._customhud_has_respawned = has_respawned

	for _,content_name in ipairs({"hp_bar_max_health_divider", "hp_bar_grimoire_icon", "grimoire_debuff", "hp_bar", "hp_bar_shield"}) do
		widget_loadout_dynamic.content[content_name]._customhud_is_dead = is_dead
		widget_loadout_dynamic.content[content_name]._customhud_player_unit_missing = player_unit_missing
		widget_loadout_dynamic.content[content_name]._customhud_has_respawned = has_respawned
	end
end

--- change player portrait
UnitFrameUI._customhud_set_profile = function (self, portrait_texture)
	if self._other_players_widget then
		self._other_players_widget.content.custom_character_portrait = portrait_texture
		self._set_widget_dirty(self, self._other_players_widget)
	end
end

Mods.hook.set(mod_name, "UnitFramesHandler._sync_player_stats", function (func, self, unit_frame)
	local player_data = unit_frame.player_data
	local has_respawned = false
	local is_dead = false
	local is_wounded = false
	local player_unit_missing = false
	local out_of_wounds = false
	local is_bot = false
	local current_hp = nil

	-- hook GenericStatusExtension.is_ready_for_assisted_respawn to find if player is in respawn state
	local original_GenericStatusExtension_is_ready_for_assisted_respawn = GenericStatusExtension.is_ready_for_assisted_respawn
	GenericStatusExtension.is_ready_for_assisted_respawn = function(generic_status_extension)
		has_respawned = original_GenericStatusExtension_is_ready_for_assisted_respawn(generic_status_extension)
		return has_respawned
	end

	-- hook UnitFrameUI.set_portrait_status to find out if we should display custom portrait overlay
	local original_UnitFrameUI_set_portrait_status = UnitFrameUI.set_portrait_status
	UnitFrameUI.set_portrait_status = function (unit_frame_ui, is_knocked_down, needs_help)
		if unit_frame_ui._other_players_widget then
			if not is_dead and (is_knocked_down or (needs_help and not has_respawned)) then
				unit_frame_ui._other_players_widget.content.display_custom_portrait_overlay = true
			else
				unit_frame_ui._other_players_widget.content.display_custom_portrait_overlay = false
			end

			unit_frame_ui:_set_widget_dirty(unit_frame_ui._other_players_widget)
		end

		original_UnitFrameUI_set_portrait_status(unit_frame_ui, is_knocked_down, needs_help)
	end

	func(self, unit_frame)

	if player_data and player_data.player then
		is_bot = not player_data.player._player_controlled
		player_unit_missing = not (player_data.player and player_data.player.player_unit)

		if player_data.extensions then
			is_dead = player_data.extensions.status:is_dead()
			is_wounded = player_data.extensions.status:is_wounded()
			out_of_wounds = not player_data.extensions.status:has_wounds_remaining()

			local function round(num, numDecimalPlaces)
			  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
			end
			current_hp = round(player_data.extensions.health:current_health_percent()*100).."%"
		end
	end

	unit_frame.widget:_customhud_update(has_respawned, is_dead, is_wounded, player_unit_missing, out_of_wounds, is_bot, current_hp)

	-- restore original functions
	UnitFrameUI.set_portrait_status = original_UnitFrameUI_set_portrait_status
	GenericStatusExtension.is_ready_for_assisted_respawn = original_GenericStatusExtension_is_ready_for_assisted_respawn

	-- use different profile icon texture for easier icon color changes on certain player statuses
	local profile_index = self.profile_synchronizer:profile_by_peer(player_data.peer_id, player_data.local_player_id)
	if profile_index then
		local profile_data = SPProfiles[profile_index]
		local display_name = profile_data.display_name
		if is_wounded or out_of_wounds or is_dead or player_unit_missing then
			unit_frame.widget:_customhud_set_profile(hero_icons.white[display_name])
		else
			unit_frame.widget:_customhud_set_profile(hero_icons.yellow[display_name])
		end
	end
end)

-- return a content_check_function that checks CustomHUD.enabled and the original content_check_function
local function create_backup_function(storage_name)
	storage_name = "CustomHUD.backups['"..storage_name.."']"

	local exe_this = [[
		return
			function(fun_to_backup)
				if not fun_to_backup or fun_to_backup ~= ]]..storage_name..[[ then
					]]..storage_name..[[ = fun_to_backup or (function(content, style) return true end)
				end
				return
					function(content, style)
						return not CustomHUD.enabled and not not ]]..storage_name..[[(content, style)
					end
			end
	]]

	return loadstring(exe_this)()
end

-- more robust create_backup_function that hides hp bar elements in custom_hud if player is dead or respawned
local function create_backup_function_hp_element(storage_name)
	storage_name = "CustomHUD.backups['"..storage_name.."']"

	local exe_this = [[
		return
			function(fun_to_backup)
				if not fun_to_backup or fun_to_backup ~= ]]..storage_name..[[ then
					]]..storage_name..[[ = fun_to_backup or (function(content, style) return true end)
				end
				return
					function(content, style)
						local original_return = not not ]]..storage_name..[[(content, style)
						if not CustomHUD.enabled then
							return original_return
						else
							return not content._customhud_is_dead and not content._customhud_player_unit_missing and not content._customhud_has_respawned and original_return
						end
					end
			end
	]]

	return loadstring(exe_this)()
end

-- this one for grim ui elements hiding
local function create_backup_function_grim_element(storage_name)
	storage_name = "CustomHUD.backups['"..storage_name.."']"

	local exe_this = [[
		return function(fun_to_backup)
				if not fun_to_backup or fun_to_backup ~= ]]..storage_name..[[ then
					]]..storage_name..[[ = fun_to_backup or (function(content, style) return true end)
				end
				return function(content, style)
						local original_return = not not ]]..storage_name..[[(content, style)
						if not CustomHUD.enabled then
							return original_return
						else
							return content.grim_equipped and content.show
						end
					end
			end
	]]

	return loadstring(exe_this)()
end

local inventory_consumable_icons = local_require("scripts/ui/hud_ui/player_unit_frame_ui_definitions").inventory_consumable_icons

Mods.hook.set(mod_name, "PlayerInventoryUI.update", function (func, self, dt, t, my_player)
	if my_player and custom_player_widget then
		local player_unit = my_player.player_unit

		if player_unit and ScriptUnit.has_extension(player_unit, "inventory_system") then
			local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
			local equipment = inventory_extension.equipment(inventory_extension)

			if not CustomHUD.backups["player_inventory_slots_widget_1.passes[1].content_check_function"] then
				for widget_i,inv_widget in ipairs(self.inventory_slots_widgets) do
					for pass_i,pass in ipairs(inv_widget.element.passes) do
						pass.content_check_function = create_backup_function("player_inventory_slots_widget_"..tostring(widget_i)..".passes["..tostring(pass_i).."].content_check_function")(pass.content_check_function)
					end
				end
			end

			-- update player consumables slots
			for i,slot_name in ipairs({"slot_healthkit", "slot_potion", "slot_grenade"}) do
				local widget_slot_name = "item_slot_"..i
				local slot_bg_name = "bg_slot_"..i
				local slot_data = equipment.slots[slot_name]
				if slot_data then
					local item_data = slot_data.item_data
					-- custom_player_widget.content[widget_slot_name].texture_id = (item_data and item_data.hud_icon) or temp_slot_texture_mapping[slot_name]
					custom_player_widget.content[widget_slot_name].texture_id = (item_data and inventory_consumable_icons[item_data.name]) or temp_slot_texture_mapping[slot_name]

					custom_player_widget.style[widget_slot_name].color[1] = (item_data and item_data.hud_icon) and 255 or 100
					custom_player_widget.style[slot_bg_name].color[1] = (item_data and item_data.hud_icon) and 255 or 100
				else
					custom_player_widget.content[widget_slot_name].texture_id = temp_slot_texture_mapping[slot_name]
					custom_player_widget.style[widget_slot_name].color[1] = 75
					custom_player_widget.style[slot_bg_name].color[1] = 75
				end
			end

			-- update ammo count
			custom_player_widget.content.ammo_text_melee = self.inventory_slots_widgets[1].content.ammo_text_1
			custom_player_widget.content.ammo_text_1 = self.inventory_slots_widgets[2].content.ammo_text_1
			custom_player_widget.content.ammo_text_2 = self.inventory_slots_widgets[2].content.ammo_text_2

			-- weapon without a clip size
			custom_player_widget.style.ammo_text_1.offset[1] = self.inventory_slots_widgets[2].content.ammo_text_2 ==  "" and 87 or 53

			-- change color when at 0 ammo
			custom_player_widget.style.ammo_text_melee.text_color = self.inventory_slots_widgets[1].content.ammo_text_1 == "0" and {200,255,0,0} or {200,0,191,255}
			custom_player_widget.style.ammo_text_1.text_color = self.inventory_slots_widgets[2].content.ammo_text_1 == "0" and {200,255,0,0} or {200,0,191,255}
			custom_player_widget.style.ammo_text_2.text_color = self.inventory_slots_widgets[2].content.ammo_text_2 == "0" and {200,255,0,0} or {200,0,191,255}

			-- update heat
			custom_player_widget.content.stance_bar.active = self.inventory_slots_widgets[2].content.stance_bar.active
			custom_player_widget.content.stance_bar.bar_value = tonumber(self.inventory_slots_widgets[2].content.stance_bar.bar_value)

			-- update bg_ammo_c
			custom_player_widget.content.bg_ammo_c.stance_bar = custom_player_widget.content.stance_bar
			custom_player_widget.content.bg_ammo_c.ammo_text_melee = custom_player_widget.content.ammo_text_melee

			-- "can reload weapon" reminder
			custom_player_widget.content.show_reload_reminder = self.inventory_slots_widgets[2].content.show_reload_reminder
		end
	end

	CustomHUD.current_hud = user_setting(MOD_SETTINGS.CUSTOM_HUD.save)
	local custom_hud_enabled = CustomHUD.current_hud == CustomHUD.CUSTOM and not CustomHUD.is_gamepad_active
	CustomHUD.was_toggled = CustomHUD.enabled ~= custom_hud_enabled
	CustomHUD.enabled = custom_hud_enabled

	return func(self, dt, t, my_player)
end)

local function backup_loadout_dynamic(loadout_dynamic)
	if CustomHUD.backups.hp_bar_divider_size_2 == nil then
		CustomHUD.backups.hp_bar_divider_size_2 = loadout_dynamic.style.hp_bar_divider.size[2]
		CustomHUD.backups.hp_bar_divider_texture_size_2 = loadout_dynamic.style.hp_bar_divider.texture_size[2]
		CustomHUD.backups.hp_bar_divider_offset_2 = loadout_dynamic.style.hp_bar_divider.offset[2]
	end
end

local function reposition_loadout_dynamic_elements(widget)
	local custom_hud_enabled = CustomHUD.enabled
	local relative_offset_y = custom_hud_enabled and 45 or -45
	widget.style.hp_bar_max_health_divider.offset[2] = widget.style.hp_bar_max_health_divider.offset[2] - relative_offset_y
	widget.style.hp_bar_highlight.offset[2] = widget.style.hp_bar_highlight.offset[2] - relative_offset_y
	widget.style.hp_bar.offset[2] = widget.style.hp_bar.offset[2] - relative_offset_y
	widget.style.hp_bar_grimoire_icon.offset[2] = widget.style.hp_bar_grimoire_icon.offset[2] - relative_offset_y
	widget.style.shield_bar_highlight.offset[2] = widget.style.shield_bar_highlight.offset[2] - relative_offset_y
	widget.style.hp_bar_shield.offset[2] = widget.style.hp_bar_shield.offset[2] - relative_offset_y
	widget.style.hp_bar_divider.offset[2] = widget.style.hp_bar_divider.offset[2] - relative_offset_y
	widget.style.grimoire_debuff.offset[2] = widget.style.grimoire_debuff.offset[2] - relative_offset_y

	if user_setting(MOD_SETTINGS.CUSTOM_HUD.save) ~= CustomHUD.GAMEPAD then
		widget.style.hp_bar_divider.size[2] = custom_hud_enabled and 12 or CustomHUD.backups.hp_bar_divider_size_2
		widget.style.hp_bar_divider.texture_size[2] = custom_hud_enabled and 12 or CustomHUD.backups.hp_bar_divider_texture_size_2
		widget.style.hp_bar_divider.offset[2] = custom_hud_enabled and 30 or CustomHUD.backups.hp_bar_divider_offset_2
	end
end

local function backup_player_loadout_dynamic(player_loadout_dynamic)
	if CustomHUD.backups.player_hp_bar_divider_size_2 == nil then
		CustomHUD.backups.player_hp_bar_divider_size_2 = player_loadout_dynamic.style.hp_bar_divider.size[2]
		CustomHUD.backups.player_hp_bar_divider_texture_size_2 = player_loadout_dynamic.style.hp_bar_divider.texture_size[2]
		CustomHUD.backups.player_hp_bar_divider_offset_2 = player_loadout_dynamic.style.hp_bar_divider.offset[2]
	end
end

local function reposition_player_loadout_dynamic_elements(widget)
	local custom_hud_enabled = CustomHUD.enabled
	if user_setting(MOD_SETTINGS.CUSTOM_HUD.save) ~= CustomHUD.GAMEPAD then
		widget.style.hp_bar_divider.size[2] = custom_hud_enabled and 15 or CustomHUD.backups.player_hp_bar_divider_size_2
		widget.style.hp_bar_divider.texture_size[2] = custom_hud_enabled and 15 or CustomHUD.backups.player_hp_bar_divider_texture_size_2
		widget.style.hp_bar_divider.offset[2] = custom_hud_enabled and 4 or CustomHUD.backups.player_hp_bar_divider_offset_2
	end
end

local function reposition_loadout_static_elements(widget)
	local relative_offset_y = user_setting(MOD_SETTINGS.CUSTOM_HUD.save) == CustomHUD.CUSTOM and 45 or -45
	widget.style.hp_bar_bg.offset[2] = widget.style.hp_bar_bg.offset[2] - relative_offset_y
	widget.style.hp_bar_fg.offset[2] = widget.style.hp_bar_fg.offset[2] - relative_offset_y
end

Mods.hook.set(mod_name, "UnitFrameUI._create_ui_elements", function (func, self, frame_index)
	func(self, frame_index)

	self._customhud_frame_index = frame_index

	local loadout_dynamic = self._widget_by_name(self, "loadout_dynamic")
	local loadout_static = self._widget_by_name(self, "loadout_static")

	-- frame_index is only false for the player widget
	if not frame_index then
		backup_player_loadout_dynamic(loadout_dynamic)
	else
		backup_loadout_dynamic(loadout_dynamic)
	end

	if user_setting(MOD_SETTINGS.CUSTOM_HUD.save) == CustomHUD.CUSTOM then
		if not frame_index then
			reposition_player_loadout_dynamic_elements(loadout_dynamic)
		else
			reposition_loadout_dynamic_elements(loadout_dynamic)
			reposition_loadout_static_elements(loadout_static)
		end
	end
end)

--- variables to help debugging
local made_custom_widget = false
local reload_n = 0

Mods.hook.set(mod_name, "UnitFrameUI.draw", function(orig_func, self, dt)
	if not self._hudmod_is_own_player then
		-- if reload_n < 5 or not self._other_players_widget then
		if not self._other_players_widget then
			self._other_players_widget = UIWidget.init(other_players_widget_def)
			reload_n = reload_n + 1
		end

		-- update the player warning overlay
		if self._other_players_widget.content.display_custom_portrait_overlay then
			-- start warning animation
			if not UIWidget.has_animation(self._other_players_widget) then
				UIWidget.animate(self._other_players_widget, UIAnimation.init(
						UIAnimation.function_by_time, self._other_players_widget.style.custom_portrait_overlay.color, 1, 255, 100, 0.5, math.easeCubic,
						UIAnimation.function_by_time, self._other_players_widget.style.custom_portrait_overlay.color, 1, 100, 255, 0.5, math.easeCubic
					)
				)
			end
		else
			-- stop warning animation
			if UIWidget.has_animation(self._other_players_widget) then
				UIWidget.stop_animations(self._other_players_widget)
			end
		end

		for widget_id, widget in pairs(self._widgets) do
			if tostring(widget_id) == "portait_static" then
				if not CustomHUD.init.portait_static then
					CustomHUD.init.portait_static = true
					-- 1 portrait_frame
					-- 2 character_portrait
					-- 3 player_level_bg
					-- 4 player_level
					-- 5 host icon
					for i=1,5 do
						widget.element.passes[i].content_check_function = create_backup_function(widget_id..".element.passes["..i.."].content_check_function")(widget.element.passes[i].content_check_function)
					end
				end

				self._other_players_widget.style.custom_player_level.offset[1] = self._customhud_is_bot and 73 or 67
				self._other_players_widget.content.player_level = widget.content.player_level
				self._other_players_widget.content.is_host = widget.content.is_host
			end

			if tostring(widget_id) == "portait_dynamic" then
				if not CustomHUD.init.portait_dynamic then
					CustomHUD.init.portait_dynamic = true
					-- 1 portrait overlay
					-- 2 portrait(warning) icon
					-- 3 speaking indicator hlight
					for i=1,3 do
						widget.element.passes[i].content_check_function = create_backup_function(widget_id..".element.passes["..i.."].content_check_function")(widget.element.passes[i].content_check_function)
					end
				end

				self._other_players_widget.content.display_portrait_overlay = widget.content.display_portrait_overlay
			end

			if tostring(widget_id) == "loadout_dynamic" then
				if CustomHUD.was_toggled then
					reposition_loadout_dynamic_elements(widget)
					self._set_widget_dirty(self, widget)
				end

				if not CustomHUD.init.loadout_dynamic then
					CustomHUD.init.loadout_dynamic = true
					-- hp overrides
					for _,pass_index in ipairs({1,2,4,6,7,8}) do
						widget.element.passes[pass_index].content_check_function = create_backup_function_hp_element(widget_id..".element.passes["..tostring(pass_index).."].content_check_function")(widget.element.passes[pass_index].content_check_function)
					end

					widget.element.passes[10].content_check_function = create_backup_function(widget_id..".element.passes[10].content_check_function")(widget.element.passes[10].content_check_function) -- item slot 1 highlight
					widget.element.passes[12].content_check_function = create_backup_function(widget_id..".element.passes[12].content_check_function")(widget.element.passes[12].content_check_function) -- item slot 2 highlight
					widget.element.passes[14].content_check_function = create_backup_function(widget_id..".element.passes[14].content_check_function")(widget.element.passes[14].content_check_function) -- item slot 3 highlight

					for _,pass_index in ipairs({9,11,13}) do
						widget.element.passes[pass_index].content_check_function = create_backup_function(widget_id..".element.passes["..pass_index.."].content_check_function")(widget.element.passes[pass_index].content_check_function)
					end

					widget.element.passes[3].content_check_function = create_backup_function_grim_element(widget_id..".element.passes[3].content_check_function")(widget.element.passes[3].content_check_function)
					widget.element.passes[5].content_check_function = create_backup_function_grim_element(widget_id..".element.passes[5].content_check_function")(widget.element.passes[5].content_check_function)
				end

				local grim_equipped = widget.content.hp_bar_grimoire_icon.active
				local show = not self._customhud_is_dead and not self._customhud_player_unit_missing and not self._customhud_has_respawned

				widget.content.hp_bar_max_health_divider.grim_equipped = grim_equipped
				widget.content.hp_bar_max_health_divider.show = show
				widget.content.grimoire_debuff.grim_equipped = grim_equipped
				widget.content.grimoire_debuff.show = show

				self._other_players_widget.content.custom_item_slot_1 = {
					texture_id = widget.content.item_slot_1 == "teammate_consumable_icon_medpack_empty" and "default_heal_icon" or widget.content.item_slot_1,
					uvs = widget.content.item_slot_1 == "teammate_consumable_icon_medpack_empty" and {{0,0},{1,1}} or { { 0.15, 0.15 }, { 0.85, 0.85 } },
					show = show,
				}
				self._other_players_widget.content.custom_item_slot_2 = {
					texture_id = widget.content.item_slot_2 == "teammate_consumable_icon_potion_empty" and "default_potion_icon" or widget.content.item_slot_2,
					uvs = widget.content.item_slot_2 == "teammate_consumable_icon_potion_empty" and {{0,0},{1,1}} or { { 0.15, 0.15 }, { 0.85, 0.85 } },
					show = show,
				}
				self._other_players_widget.content.custom_item_slot_3 = {
					texture_id = widget.content.item_slot_3 == "teammate_consumable_icon_grenade_empty" and "default_grenade_icon" or widget.content.item_slot_3,
					uvs = widget.content.item_slot_3 == "teammate_consumable_icon_grenade_empty" and {{0,0},{1,1}} or { { 0.15, 0.15 }, { 0.85, 0.85 } },
					show = show,
				}
				self._other_players_widget.content.show = show

				self._other_players_widget.style.custom_item_slot_1.color[1] = widget.content.item_slot_1 == "teammate_consumable_icon_medpack_empty" and 75 or 255
				self._other_players_widget.style.custom_item_slot_2.color[1] = widget.content.item_slot_2 == "teammate_consumable_icon_potion_empty" and 75 or 255
				self._other_players_widget.style.custom_item_slot_3.color[1] = widget.content.item_slot_3 == "teammate_consumable_icon_grenade_empty" and 75 or 255
			end

			if tostring(widget_id) == "loadout_static" then
				if CustomHUD.was_toggled then
					reposition_loadout_static_elements(widget)
					self._set_widget_dirty(self, widget)
				end

				if not CustomHUD.init.loadout_static then
					CustomHUD.init.loadout_static = true

					-- 2 - hp_bar_bg, 3 - hp_bar_fg
					widget.element.passes[2].content_check_function = create_backup_function(widget_id..".element.passes[2].content_check_function")(widget.element.passes[2].content_check_function)
					widget.element.passes[3].content_check_function = create_backup_function(widget_id..".element.passes[3].content_check_function")(widget.element.passes[3].content_check_function) -- hp_bar_fg

					-- 1 inventory_bg
					-- 4 player_name
					widget.element.passes[1].content_check_function = create_backup_function(widget_id..".element.passes[1].content_check_function")(widget.element.passes[1].content_check_function)
					widget.element.passes[4].content_check_function = create_backup_function(widget_id..".element.passes[4].content_check_function")(widget.element.passes[4].content_check_function)
				end

				self._other_players_widget.content.player_name = widget.content.player_name
			end
		end
	else
		-- if not made_custom_widget or not custom_player_widget then -- for debugging
		if not custom_player_widget then
			made_custom_widget = true
			custom_player_widget = UIWidget.init(custom_player_widget_def)
		end

		for widget_id, widget in pairs(self._widgets) do
			if tostring(widget_id) == "portait_static" then
				-- 1 portrait_frame
				-- 2 character_portrait
				-- 3 player_level_bg
				-- 4 player_level
				if not CustomHUD.init.player_portait_static then
					CustomHUD.init.player_portait_static = true
					for i=1,5 do
						widget.element.passes[i].content_check_function = create_backup_function("player_"..widget_id..".element.passes["..tostring(i).."].content_check_function")(widget.element.passes[i].content_check_function)
					end
				end

				custom_player_widget.content.is_host = widget.content.is_host
			end

			if tostring(widget_id) == "loadout_dynamic" then
				if not CustomHUD.init.player_loadout_dynamic then
					CustomHUD.init.player_loadout_dynamic = true

					widget.element.passes[3].content_check_function = create_backup_function_grim_element("player_loadout_dynamic.element.passes["..tostring(3).."].content_check_function")(widget.element.passes[3].content_check_function)
					widget.element.passes[5].content_check_function = create_backup_function_grim_element("player_loadout_dynamic.element.passes["..tostring(5).."].content_check_function")(widget.element.passes[5].content_check_function)
				end

				if CustomHUD.was_toggled then
					reposition_player_loadout_dynamic_elements(widget)
					self._set_widget_dirty(self, widget)
				end

				local grim_equipped = widget.content.hp_bar_grimoire_icon.active
				local show = not self._customhud_is_dead and not self._customhud_player_unit_missing and not self._customhud_has_respawned

				widget.content.hp_bar_max_health_divider.grim_equipped = grim_equipped
				widget.content.hp_bar_max_health_divider.show = show
				widget.content.grimoire_debuff.grim_equipped = grim_equipped
				widget.content.grimoire_debuff.show = show
			end

			if tostring(widget_id) == "portait_dynamic" then
				if not CustomHUD.init.player_portait_dynamic then
					CustomHUD.init.player_portait_dynamic = true
					-- portrait_overlay, portrait_icon, talk_indicator_highlight, connecting_icon
					for i=1,4 do
						widget.element.passes[i].content_check_function = create_backup_function("player_"..widget_id..".element.passes["..tostring(i).."].content_check_function")(widget.element.passes[i].content_check_function)
					end
				end
			end

			if tostring(widget_id) == "loadout_static" then
				if not CustomHUD.init.player_loadout_static then
					CustomHUD.init.player_loadout_static = true

					widget.element.passes[1].content_check_function = create_backup_function("player_"..widget_id..".element.passes[1].content_check_function")(widget.element.passes[1].content_check_function)
					widget.element.passes[2].content_check_function = create_backup_function("player_"..widget_id..".element.passes[2].content_check_function")(widget.element.passes[2].content_check_function) -- hp_bar_fg
				end
			end
		end
	end

	if CustomHUD.was_toggled then
		self._dirty = true
	end

	if self._is_visible and CustomHUD.enabled then
		local ui_renderer = self.ui_renderer
		local input_service = self.input_manager:get_service("ingame_menu")
		UIRenderer.begin_pass(ui_renderer, self.ui_scenegraph, input_service, dt, nil, self.render_settings)
			if self._hudmod_is_own_player then
				UIRenderer.draw_widget(ui_renderer, custom_player_widget)
			else
				if UIWidget.has_animation(self._other_players_widget) then
					self._dirty = true
				end
				UIRenderer.draw_widget(ui_renderer, self._other_players_widget)
			end
		UIRenderer.end_pass(ui_renderer)
	end

	orig_func(self, dt)
end)

Mods.hook.set(mod_name, "PlayerInventoryUI.set_visible", function (orig_func, self, visible)
	-- In the gamepad HUD the inventory UI is part of the unit frame.
	if CustomHUD.current_hud == CustomHUD.GAMEPAD then
		visible = false
	end
	return orig_func(self, visible)
end)

Mods.hook.set(mod_name, "UnitFramesHandler._create_unit_frame_by_type", function(orig_func, self, ...)
	if CustomHUD.current_hud == CustomHUD.GAMEPAD then
		-- The gamepad HUD will be used if the platform is not "win32"
		local real_platform = self.platform
		self.platform = "definitely-not-win32"
		local result = orig_func(self, ...)
		self.platform = real_platform
		return result
	else
		return orig_func(self, ...)
	end
end)

Mods.hook.set(mod_name, "UnitFramesHandler.update", function(orig_func, self, dt, t, my_player)
	-- Check whether the FORCE_GAMEPAD_HUD setting has changed.
	local force_gamepad_hud = CustomHUD.current_hud == CustomHUD.GAMEPAD
	if not force_gamepad_hud ~= not self._unit_frames[1].gamepad_version then
		if force_gamepad_hud then
			self:on_gamepad_activated()
		else
			self:on_gamepad_deactivated()
		end
		self.ingame_ui.ingame_hud.player_inventory_ui:set_visible(self._is_visible)
	end

	return orig_func(self, dt, t, my_player)
end)

Mods.hook.set(mod_name, "BoonUI.draw", function (func, self, dt)
	if CustomHUD.was_toggled then
		self._align_widgets(self)
	end

	func(self, dt)
end)

Mods.hook.set(mod_name, "BoonUI._align_widgets", function (func, self)
	func(self)

	local boon_width = 38
	local boon_spacing = 15

	-- -250 X widget offset on boons for gamepad needs to be manually reapplied
	if CustomHUD.current_hud == CustomHUD.GAMEPAD then
		local widget_total_width = 0
		for _, data in ipairs(self._active_boons) do
			local widget = data.widget
			local widget_offset = widget.offset
			widget_offset[1] = -250 + widget_total_width
			widget_total_width = widget_total_width - (boon_width + boon_spacing)
		end
	end

	if CustomHUD.current_hud == CustomHUD.CUSTOM then
		local widget_total_width = 0
		for _, data in ipairs(self._active_boons) do
			local widget = data.widget
			local widget_offset = widget.offset
			widget_offset[1] = -20 + widget_total_width
			widget_total_width = widget_total_width - (boon_width + boon_spacing)
		end
	end
end)

Mods.hook.set(mod_name, "BoonUI.update", function (func, self, dt, t)
	func(self, dt, t)
	-- Force update boon positions when mod turned on/off
	if CustomHUD.current_hud == CustomHUD.GAMEPAD then
		if not self.force_gamepad_active_last_frame then
			self.force_gamepad_active_last_frame = true

			self.on_gamepad_activated(self)
		end
	elseif self.force_gamepad_active_last_frame then
		self.force_gamepad_active_last_frame = false

		self.on_gamepad_deactivated(self)
	end

	CustomHUD.is_gamepad_active = self.input_manager:is_device_active("gamepad")
end)

local function create_options()
	Mods.option_menu:add_group("custom_hud_group", "Custom HUDs")
	Mods.option_menu:add_item("custom_hud_group", MOD_SETTINGS.CUSTOM_HUD, true)

	rawset(_G, "_customhud_defined", true)
end

safe_pcall(create_options)