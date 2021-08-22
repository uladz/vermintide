local mod_name = "HudToggle"

local get = Application.user_setting
local set = Application.set_user_setting
local save = Application.save_user_settings

local oi = OptionsInjector

local function get_setting(key)
	if HUDControl.settings[key] then
		return get(HUDControl.settings[key].save)
	else
		return nil
	end
end

local function get_settings()
	local settings = {}
	for i,v in ipairs(HUDControl.setting_strings) do
		table.insert(settings, get(v))
	end
	return settings
end

local function set_setting(key, value)
	if HUDControl.settings[key] then
		set(HUDControl.settings[key].save, value)
		save()
	end
end

local function set_setting_i(i, value)
	if HUDControl.setting_strings[i] then
		set(HUDControl.setting_strings[i], value)
		save()
	end
end

local function set_all_settings(value)
	HUDControl.visible = value
	for i,v in ipairs(HUDControl.setting_strings) do
		set(HUDControl.setting_strings[i], not not value)
	end
	save()
end

local function apply_settings()

	--Saving settings locally
	for i,v in ipairs(HUDControl.settings_sorted) do
		HUDControl.saved_settings[v] = get_setting(v)
	end

	--Hiding beta overlay
	if(Managers.beta_overlay) then
		if(get_setting("ELEMENTS")) then
			Managers.beta_overlay.widget.offset[1] = 0
		else
			Managers.beta_overlay.widget.offset[1] = 10000
		end
	end

	--Setting flags for update hooks
	HUDControl.hud_set = false
	HUDControl.camera_set = false
	HUDControl.outlines_set = false
end

local function check_visibility()
	local visible = true
	for i,v in ipairs(HUDControl.setting_strings) do
		local value = get(v)
		if not value then
			visible = false
			break
		end
	end
	HUDControl.visible = visible
	return visible
end

local function create_options()
	Mods.option_menu:add_group("hud_group", "HUD Improvements")

	Mods.option_menu:add_item("hud_group", HUDControl.settings["SUB_GROUP"], true)
	Mods.option_menu:add_item("hud_group", HUDControl.settings["TOGGLE"])
	Mods.option_menu:add_item("hud_group", HUDControl.settings["MORE"])
	Mods.option_menu:add_item("hud_group", HUDControl.settings["LESS"])
	for i,v in ipairs(HUDControl.settings_sorted) do
		Mods.option_menu:add_item("hud_group", HUDControl.settings[v])
	end
end

HUDControl = {
	setting_strings = {
		"cb_hud_elements",
		"cb_hud_objectives",
		"cb_hud_outlines",
		"cb_hud_crosshair",
		"cb_hud_ping",
		"cb_hud_feedback",
		"cb_hud_weapon"
	},
	settings_sorted = {
		"ELEMENTS",

		"OBJECTIVES",

		"OUTLINES",

		"CROSSHAIR",

		"PING",
		"FEEDBACK",

		"WEAPON",
	},
	visible = true,
	hud_set = false,
	camera_set = false,
	outlines_set = false
}
HUDControl.settings = {
	SUB_GROUP = {
		["save"] = "cb_hudtoggle_subgroup",
		["widget_type"] = "dropdown_checkbox",
		["text"] = "HUD Toggler",
		["default"] = false,
		["hide_options"] = {
			{
				true,
				mode = "show",
				options = {
					"cb_hud_elements",
					"cb_hud_objectives",
					"cb_hud_outlines",
					"cb_hud_crosshair",
					"cb_hud_ping",
					"cb_hud_feedback",
					"cb_hud_weapon",
					"cb_hud_toggle",
					"cb_hud_more",
					"cb_hud_less"
				},
			},
			{
				false,
				mode = "hide",
				options = {
					"cb_hud_elements",
					"cb_hud_objectives",
					"cb_hud_outlines",
					"cb_hud_crosshair",
					"cb_hud_ping",
					"cb_hud_feedback",
					"cb_hud_weapon",
					"cb_hud_toggle",
					"cb_hud_more",
					"cb_hud_less"
				},
			},
		},
	},
	ELEMENTS = {
		["save"] = HUDControl.setting_strings[1],
		["widget_type"] = "stepper",
		["text"] = "HUD Elements",
		["tooltip"] = "HUD Elements\n" ..
			"Whether to display HUD elements like equipment, health bars, stamina and overcharge.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	OBJECTIVES = {
		["save"] = HUDControl.setting_strings[2],
		["widget_type"] = "stepper",
		["text"] = "Objectives",
		["tooltip"] = "Objectives\n" ..
			"Whether to display objective banner, markers and button prompts.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	OUTLINES = {
		["save"] = HUDControl.setting_strings[3],
		["widget_type"] = "stepper",
		["text"] = "Outlines",
		["tooltip"] = "Outlines\n" ..
			"Whether to display player, object and item outlines.\n" ..
			"Overrides Player Outlines Always On setting.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	CROSSHAIR = {
		["save"] = HUDControl.setting_strings[4],
		["widget_type"] = "stepper",
		["text"] = "Crosshair",
		["tooltip"] = "Crosshair\n" ..
			"Whether to display crosshair.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	PING = {
		["save"] = HUDControl.setting_strings[5],
		["widget_type"] = "stepper",
		["text"] = "Ping",
		["tooltip"] = "Ping\n" ..
			"Whether enemies, players and items can be pinged.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	FEEDBACK = {
		["save"] = HUDControl.setting_strings[6],
		["widget_type"] = "stepper",
		["text"] = "Feedback",
		["tooltip"] = "Feedback\n" ..
			"Whether damage indicators, special kills and assists are shown.\n",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},
	WEAPON = {
		["save"] = HUDControl.setting_strings[7],
		["widget_type"] = "stepper",
		["text"] = "Weapon Model",
		["tooltip"] = "Weapon Model\n" ..
			"Whether to display weapon model and hands.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2,
	},

	TOGGLE = {
		["save"] = "cb_hud_toggle",
		["widget_type"] = "keybind",
		["text"] = "Toggle HUD",
		["default"] = {
			"h",
			oi.key_modifiers.CTRL
		},
		["exec"] = {"patch/action", "hud_toggle"},
	},
	MORE = {
		["save"] = "cb_hud_more",
		["widget_type"] = "keybind",
		["text"] = "HUD+",
		["default"] = {
			"0",
			oi.key_modifiers.NONE
		},
		["exec"] = {"patch/action", "hud_more"},
	},
	LESS = {
		["save"] = "cb_hud_less",
		["widget_type"] = "keybind",
		["text"] = "HUD-",
		["default"] = {
			"9",
			oi.key_modifiers.NONE
		},
		["exec"] = {"patch/action", "hud_less"},
	},
}
HUDControl.saved_settings = {}
for i,v in ipairs(HUDControl.settings_sorted) do
	HUDControl.saved_settings[v] = true
end
HUDControl.mode = 0

--Toggles hud
HUDControl.toggle = function()
	set_all_settings(not HUDControl.visible)
	HUDControl.mode = HUDControl.visible and 0 or #HUDControl.settings_sorted
	apply_settings()
end

--Hud +/-
HUDControl.more = function()
	local mode = HUDControl.mode
	local decrease = mode == 6 and 2 or 1
	if mode <= 0 then decrease = 0 end
	for i = mode - decrease + 1, #HUDControl.settings_sorted do
		set_setting_i(i, true)
	end
	HUDControl.mode = mode - decrease
	apply_settings()
end

HUDControl.less = function()
	local mode = HUDControl.mode
	local increase = mode == 4 and 2 or 1
	if mode >= #HUDControl.settings_sorted then increase = 0 end
	for i = 1, mode + increase do
		set_setting_i(i, false)
	end
	HUDControl.mode = mode + increase
	apply_settings()
end

--Settings watch
local last_update = 0
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, dt, t)
	func(self, dt, t)
	if t - last_update > 1 then
		last_update = t
		for i,v in ipairs(HUDControl.settings_sorted) do
			if get_setting(v) ~= HUDControl.saved_settings[v] then
				apply_settings()
				break
			end
		end
	end
end)

--Altering hud toggle function
Mods.hook.set(mod_name, "IngameHud.set_visible", function(func, self, orig_visible)

	if get_setting("ELEMENTS") then
		return func(self, orig_visible)
	end

	local visible = false
	if self.player_inventory_ui then
		self.player_inventory_ui:set_visible(visible)
	end

	if self.unit_frames_handler then
		self.unit_frames_handler:set_visible(visible)
	end

	if self.game_timer_ui then
		self.game_timer_ui:set_visible(visible)
	end

	if self.endurance_badge_ui then
		self.endurance_badge_ui:set_visible(visible)
	end

	local difficulty_unlock_ui = self.difficulty_unlock_ui

	if difficulty_unlock_ui then
		difficulty_unlock_ui.set_visible(difficulty_unlock_ui, visible)
	end

	local difficulty_notification_ui = self.difficulty_notification_ui

	if difficulty_notification_ui then
		difficulty_notification_ui.set_visible(difficulty_notification_ui, visible)
	end

	if self.boon_ui then
		self.boon_ui:set_visible(visible)
	end

	if self.contract_log_ui then
		self.contract_log_ui:set_visible(visible)
	end

	if self.tutorial_ui then
		self.tutorial_ui:set_visible(visible)
	end

	local observer_ui = self.observer_ui

	if observer_ui then
		local observer_ui_visibility = self.is_own_player_dead(self) and not self.ingame_player_list_ui.active and orig_visible

		if observer_ui and observer_ui.is_visible(observer_ui) ~= observer_ui_visibility then
			observer_ui.set_visible(observer_ui, observer_ui_visibility)
		end
	end

end)

--Hiding things that might show up later
Mods.hook.set(mod_name, "IngameUI.update", function(func, self, ...)
	func(self, ...)
	if not HUDControl.hud_set then
		if self.ingame_hud and self.ingame_hud.set_visible then
			self.ingame_hud:set_visible(self, get_setting("ELEMENTS"))
			HUDControl.hud_set = true
		end
	end
	if not get_setting("OBJECTIVES") and self.hud_visible then
		self.hud_visible = false
	end
end)

--Hiding Last Stand timer
Mods.hook.set(mod_name, "GameTimerUI.update", function (func, ...)
	if get_setting("ELEMENTS") then
		return func(...)
	end
end)

--Hiding contracts log
Mods.hook.set(mod_name, "ContractLogUI.update", function (func, ...)
	if get_setting("ELEMENTS") then
		return func(...)
	end
end)

--Hiding stamina
Mods.hook.set(mod_name, "FatigueUI.update", function (func, ...)
	if get_setting("ELEMENTS") then
		return func(...)
	end
end)

--Hiding overcharge bar
Mods.hook.set(mod_name, "OverchargeBarUI.update", function (func, ...)
	if get_setting("ELEMENTS") then
		return func(...)
	end
end)

--Area indicators (?)
Mods.hook.set(mod_name, "AreaIndicatorUI.update", function (func, ...)
	if get_setting("OBJECTIVES") then
		return func(...)
	end
end)

--Hiding interaction prompts
Mods.hook.set(mod_name, "InteractionUI.update", function (func, ...)
	if get_setting("OBJECTIVES") then
		return func(...)
	end
end)

--Mission objectives
Mods.hook.set(mod_name, "MissionObjectiveUI.update", function (func, ...)
	if get_setting("OBJECTIVES") then
		return func(...)
	end
end)

--Tutorial UI (?)
Mods.hook.set(mod_name, "TutorialUI.update", function (func, ...)
	if get_setting("OBJECTIVES") then
		return func(...)
	end
end)

--Hiding crosshair
Mods.hook.set(mod_name, "CrosshairUI.update", function(func, self, ...)
	if get_setting("CROSSHAIR") then
		return func(self, ...)
	end
end)


--Hiding hands and weapon
Mods.hook.set(mod_name, "PlayerUnitFirstPerson.update", function (func, self, unit, input, dt, context, t)
	func(self, unit, input, dt, context, t)

	if not get_setting("WEAPON") then
		self.inventory_extension:show_first_person_inventory(false)
		self.inventory_extension:show_first_person_inventory_lights(false)
		Unit.set_unit_visibility(self.first_person_attachment_unit, false)

	elseif not HUDControl.camera_set then

		local player_unit = Managers.player:player_from_peer_id(Network.peer_id()).player_unit
		local first_person_system = player_unit and ScriptUnit.extension(player_unit, "first_person_system")
		if not first_person_system or not first_person_system.first_person_mode then return end

		local is_third_person_mod = Mods.ThirdPerson and Mods.ThirdPerson.SETTINGS and Mods.ThirdPerson.SETTINGS.ACTIVE and Mods.ThirdPerson.SETTINGS.ACTIVE.save and get(Mods.ThirdPerson.SETTINGS.ACTIVE.save)
		local is_first_person = first_person_system.first_person_mode and not is_third_person_mod


		self.inventory_extension:show_first_person_inventory(is_first_person)
		self.inventory_extension:show_first_person_inventory_lights(is_first_person)
		Unit.set_unit_visibility(self.first_person_attachment_unit, is_first_person)

		HUDControl.camera_set = true
	end
end)

--Hiding outlines
Mods.hook.set(mod_name, "OutlineSystem.update", function(func, self, ...)

	if get_setting("OUTLINES") then
		return func(self, ...)
	end

	if #self.units == 0 then
		return
	end

	if script_data.disable_outlines then
		return
	end

	local checks_per_frame = 4
	local current_index = self.current_index
	local units = self.units

	for i = 1, checks_per_frame, 1 do
		current_index = current_index + 1

		if not units[current_index] then
			current_index = 1
		end

		local unit = self.units[current_index]
		local extension = self.unit_extension_data[unit]

		if extension or false then
			local is_pinged = extension.pinged
			local method = "never"

			if self[method](self, unit, extension) then
				if not extension.outlined or extension.new_color or extension.reapply then
					local c = (is_pinged and OutlineSettings.colors.player_attention.channel) or extension.outline_color.channel
					local channel = Color(c[1], c[2], c[3], c[4])

					self.outline_unit(self, unit, extension.flag, channel, true, extension.apply_method, extension.reapply)

					extension.outlined = true
				end
			elseif extension.outlined or extension.new_color or extension.reapply then
				local c = extension.outline_color.channel
				local channel = Color(c[1], c[2], c[3], c[4])

				self.outline_unit(self, unit, extension.flag, channel, false, extension.apply_method, extension.reapply)

				extension.outlined = false
			end

			extension.new_color = false
			extension.reapply = false
		end
	end

	self.current_index = current_index
end)

--Disabling ping
Mods.hook.set(mod_name, "ContextAwarePingExtension.update", function (func, ...)
	if get_setting("PING") then
		return func(...)
	end
end)

--Disabling positive reinforcement
Mods.hook.set(mod_name, "PositiveReinforcementUI.update", function (func, ...)
	if get_setting("FEEDBACK") then
		return func(...)
	end
end)

--Hiding subtitles
Mods.hook.set(mod_name, "SubtitleGui.update", function(func, self, ...)
	if get_setting("FEEDBACK") then
		return func(self, ...)
	end
end)

--Hide damage indicators
Mods.hook.set(mod_name, "DamageIndicatorGui.update", function(func, self, ...)
	if get_setting("FEEDBACK") then
		return func(self, ...)
	end
end)

--Init
create_options()
check_visibility()
apply_settings()
