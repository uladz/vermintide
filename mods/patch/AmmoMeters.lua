local mod_name = "AmmoMeters"
--[[
	authors: grimalackt, iamlupo, walterr

	Ammo meters for other team members, with network functionality to share status between modded users.

--]]

local user_setting = Application.user_setting
local set_user_setting = Application.set_user_setting
local RPC_HUDMOD_AMMO_UPDATE = "rpc_hudmod_ammo_update"
local RPC_HUDMOD_REQUEST_AMMO_UPDATE = "rpc_hudmod_request_ammo_update"

--[[
	Setting defs.
--]]
local MOD_SETTINGS = {
	SUB_GROUP = {
		["save"] = "cb_ammo_meter_subgroup",
		["widget_type"] = "dropdown_checkbox",
		["text"] = "Ammo Meters",
		["default"] = false,
		["hide_options"] = {
			{
				true,
				mode = "show",
				options = {
					"cb_hudmod_team_ammo_meters",
					"cb_hudmod_player_ammo_meter",
				},
			},
			{
				false,
				mode = "hide",
				options = {
					"cb_hudmod_team_ammo_meters",
					"cb_hudmod_player_ammo_meter",
				},
			},
		},
	},
	TEAM_AMMO_METERS = {
		["save"] = "cb_hudmod_team_ammo_meters",
		["widget_type"] = "stepper",
		["text"] = "Team Ammo Meters Enabled",
		["tooltip"] = "Team Ammo Meters\n" ..
				"Show an ammo meter on the HUD for each team member who has equipped a ranged " ..
				"weapon that uses ammo. Currently only works for human team-mates who also have " ..
				"this mod installed, and for bots.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 2, -- Default second option is enabled. In this case On
		["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_hudmod_team_ammo_meters_notch",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_hudmod_team_ammo_meters_notch",
					}
				},
			},
	},
	TEAM_AMMO_METERS_NOTCH = {
		["save"] = "cb_hudmod_team_ammo_meters_notch",
		["widget_type"] = "stepper",
		["text"] = "Add Player Ammo Notch to Ammo Bars",
		["tooltip"] = "Add Player Ammo Notch to Ammo Bars\n" ..
			"Adds a notch on ammo bars to compare your ammo count with the ammo bar's owner.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
	PLAYER_AMMO_METER = {
		["save"] = "cb_hudmod_player_ammo_meter",
		["widget_type"] = "stepper",
		["text"] = "Player Ammo Meter Enabled",
		["tooltip"] = "Add player ammo meter\n" ..
			"Add a meter that shows your ammo count.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true}
		},
		["default"] = 1, -- Default first option is enabled. In this case Off
	},
}

--[[
	Ammo meter widget definition, based on code from scripts/ui/views/player_inventory_ui_definitions.lua
	(it's a very simplified version of the overcharge meter shown to the right of combustion-based
	weapons' icons on the HUD).
--]]
local ammo_meter_widget =
{
	scenegraph_id = "pivot",
	offset = { 225, -79, -2 },
	element = {
		passes = {
			{
				pass_type = "texture",
				style_id = "ammo_bar_fg",
				texture_id = "ammo_bar_fg",
			},
			{
				style_id = "ammo_bar",
				pass_type = "texture_uv_dynamic_color_uvs_size_offset",
				content_id = "ammo_bar",
				dynamic_function = function (content, style, size, dt)
					local bar_value = content.bar_value
					local uv_start_pixels = style.uv_start_pixels
					local uv_scale_pixels = style.uv_scale_pixels
					local uv_pixels = uv_start_pixels + uv_scale_pixels*bar_value
					local uvs = style.uvs
					local uv_scale_axis = style.scale_axis
					local offset = style.offset
					uvs[1][uv_scale_axis] = 1 - uv_pixels/(uv_start_pixels + uv_scale_pixels)
					size[uv_scale_axis] = uv_pixels
					return nil, uvs, size, offset
				end
			},
			{
				pass_type = "rect",
				style_id = "player_ammo_notch",
				content_check_function = function (content, style)
					return style.offset[2] ~= 0
				end,
			},
		},
	},
	content = {
		ammo_bar_fg = "stance_bar_frame",
		ammo_bar = {
			bar_value = 0,
			texture_id = "stance_bar_blue",
		},
	},
	style = {
		player_ammo_notch = {
			size = { 9, 2 },
			offset = { 18, 0, 0 },
			color = {
				255,
				255,
				255,
				0
			}
		},
		ammo_bar_fg = {
			color = { 255, 255, 255, 255 },
			offset = { 0, 0, 1 },
			size = { 32, 128 },
		},
		ammo_bar = {
			uv_start_pixels = 0,
			uv_scale_pixels = 67,
			offset_scale = 1,
			scale_axis = 2,
			offset = { 9, 15, 0 },
			size = { 9, 0 },
			uvs = {
				{ 0, 0 },
				{ 1, 1 }
			},
		},
	},
}

--[[
	Checks whether an ammo meter is permitted for the player attached to the given unit frame.
	Currently only bot players are permitted.
--]]
local function check_ammo_meter_allowed(unit_frame)
	local data = unit_frame.data
	if data._hudmod_ammo_meter_allowed == nil then
		data._hudmod_ammo_meter_allowed = not not unit_frame.player_data.player.bot_player
	end
	return data._hudmod_ammo_meter_allowed
end

--[[
	Helper function to retrieve the ammo extension from the given slot data.
--]]
local function get_ammo_extension(slot_data)
	if slot_data then
		local right_unit = slot_data.right_unit_1p
		local left_unit = slot_data.left_unit_1p
		return (right_unit and ScriptUnit.has_extension(right_unit, "ammo_system")) or
			(left_unit and ScriptUnit.has_extension(left_unit, "ammo_system"))
	end
	return nil
end

--[[
	Returns the current ammo and the maximum ammo from the given ammo.  Based on
	SimpleInventoryExtension.current_ammo_status, which we can't use because it doesn't give the max
	ammo we want (it gives the 'raw' max ammo for the weapon type without the Ammo Holder trait).
--]]
local function current_ammo_status(inventory_extn, is_bot)
	local slot_data = inventory_extn:equipment().slots["slot_ranged"]
	if slot_data then
		local item_data = slot_data.item_data
		local item_template = BackendUtils.get_item_template(item_data)
		local ammo_data = item_template.ammo_data

		if ammo_data then
			local ammo_extn = get_ammo_extension(slot_data)
			if ammo_extn then
				return ammo_extn:total_remaining_ammo(), ammo_extn.max_ammo
			end

			if slot_data.ammo_extn then
				local max_ammo = ammo_data.max_ammo
				for _, trait_name in pairs(slot_data.item_data.traits) do
					if trait_name == "ranged_weapon_total_ammo_tier1" and not is_bot then
						max_ammo = math.ceil(max_ammo * 1.3)
					end
				end
				return slot_data.ammo_extn.available_ammo, max_ammo
			end
		end
	end
	return nil, nil
end

local RPC_UPDATE_QUEUE = {}
local function on_rpc_ammo_update(sender_id, unit_id, ammo_count)
	local ingame_ui = Managers.matchmaking.ingame_ui
	local unit_frames_handler = ingame_ui and ingame_ui.ingame_hud.unit_frames_handler

	if unit_frames_handler then
		local unit_frames = unit_frames_handler:_get_unit_frames()
		local unit_frame = nil
		local network_manager = Managers.state.network

		if Managers.player.is_server then
			for index, uframe in ipairs(unit_frames) do
				if uframe.player_data.peer_id == sender_id and uframe.player_data.player._player_controlled then
					unit_frame = uframe
				end
			end
		else
			for index, uframe in ipairs(unit_frames) do
				local frame_unit_id = network_manager.unit_game_object_id(network_manager, uframe.player_data.player_unit)
				if frame_unit_id == unit_id then
					unit_frame = uframe
				end
			end
		end

		local extensions = unit_frame and unit_frame.player_data.extensions
		local inventory_extn = extensions and extensions.inventory
		local slot_data = inventory_extn and inventory_extn:equipment().slots["slot_ranged"]

		if slot_data then
			slot_data.ammo_extn = {}

			slot_data.ammo_extn.available_ammo = ammo_count

			-- Also update _hudmod_ammo_meter_allowed in case this is the first time we have
			-- received ammo info from this player.
			unit_frame.data._hudmod_ammo_meter_allowed = true
			if Managers.player.is_server then
				--Mods.network.send_rpc_clients_except(RPC_HUDMOD_AMMO_UPDATE, sender_id, unit_id, ammo_count)
			else
				local bots_have_info = false
				for _, player in pairs(Managers.player:bots()) do
					local bot_unit_id = network_manager.unit_game_object_id(network_manager, player.player_unit)

					if frame_unit_id == bot_unit_id and unit_frame.data._hudmod_ammo_meter_allowed == true then
						bots_have_info = true
					end
				end
				if #Managers.player:bots() > 0 and bots_have_info == false then
					Mods.network.send_rpc_server(RPC_HUDMOD_REQUEST_AMMO_UPDATE, "")
				end
			end
		else
			RPC_UPDATE_QUEUE[unit_id] = {
				ammo = ammo_count,
				sender_id = sender_id
			}
		end
	end
end

Mods.hook.set(mod_name, "UnitFramesHandler.update", function(orig_func, self, dt, t, my_player)
	local player_unit = self.my_player.player_unit
	if player_unit then
		-- Update value for ammo meter.
		if user_setting(MOD_SETTINGS.TEAM_AMMO_METERS.save) then
			local unit_frame = self._unit_frames[self._current_frame_index]
			if unit_frame and unit_frame.sync and check_ammo_meter_allowed(unit_frame) then
				local extensions = unit_frame.player_data.extensions
				local inventory_extn = extensions and extensions.inventory
				local ammo_value = nil
				if inventory_extn then
					local is_bot = not unit_frame.player_data.player._player_controlled
					local current_ammo, max_ammo = current_ammo_status(inventory_extn, is_bot)
					if current_ammo then
						ammo_value = math.max(0, math.min(current_ammo / max_ammo, 1))
					end
				end
				if unit_frame.data._hudmod_ammo_value ~= ammo_value then
					unit_frame.data._hudmod_ammo_value = ammo_value
					self._dirty = true
				end
			end
		end

		local network_manager = Managers.state.network
		for _, unit_frame in pairs(self._unit_frames) do
			local frame_unit_id = network_manager.unit_game_object_id(network_manager, unit_frame.player_data.player_unit)
			for unit_id, request in pairs(RPC_UPDATE_QUEUE) do
				if frame_unit_id == unit_id then
					RPC_UPDATE_QUEUE[unit_id] = nil
					on_rpc_ammo_update(request.sender_id, unit_id, request.ammo)
				end
			end
		end
	end
	return orig_func(self, dt, t, my_player)
end)

Mods.hook.set(mod_name, "UnitFrameUI.draw", function(orig_func, self, dt)
	local data = self.data

	if self._ammo_widget and rawget(_G, "_customhud_defined") and CustomHUD.was_toggled then
		self._ammo_widget = nil
	end

	local player_ammo_meter_enabled = user_setting(MOD_SETTINGS.PLAYER_AMMO_METER.save)
	if self._is_visible and (user_setting(MOD_SETTINGS.TEAM_AMMO_METERS.save) or player_ammo_meter_enabled) and (data._hudmod_ammo_value ~= nil or self._hudmod_is_own_player and player_ammo_meter_enabled) then
		local ui_renderer = self.ui_renderer
		local input_service = self.input_manager:get_service("ingame_menu")
		UIRenderer.begin_pass(ui_renderer, self.ui_scenegraph, input_service, dt, nil, self.render_settings)

		if data._hudmod_ammo_value ~= nil or self._hudmod_is_own_player and player_ammo_meter_enabled then
			local widget = self._ammo_widget
			if not widget then
				widget = UIWidget.init(ammo_meter_widget)
				self._ammo_widget = widget
			end
			local ammo_bar = widget.content.ammo_bar
			ammo_bar.bar_value = data._hudmod_ammo_value
			if self._hudmod_is_own_player then
				widget.offset[1] = rawget(_G, "_customhud_defined") and CustomHUD.enabled and -273 or 25
				widget.offset[2] = rawget(_G, "_customhud_defined") and CustomHUD.enabled and -80 or -82
				widget.offset[3] = 10
				local local_player_unit = Managers.player:local_player().player_unit
				if local_player_unit and ScriptUnit.has_extension(local_player_unit, "inventory_system") then
					local inventory_extension = ScriptUnit.extension(local_player_unit, "inventory_system")
					if inventory_extension then
						local current_ammo, max_ammo = current_ammo_status(inventory_extension, false)
						if current_ammo ~= nil and max_ammo then
							ammo_bar.bar_value = math.max(0, math.min(current_ammo / max_ammo, 1))
						end
					end
				end
			else
				widget.offset[1] = rawget(_G, "_customhud_defined") and CustomHUD.enabled and 18 or 225
				widget.offset[2] = rawget(_G, "_customhud_defined") and CustomHUD.enabled and -75 or -79
				widget.style.player_ammo_notch.offset[2] = 0
				if user_setting(MOD_SETTINGS.TEAM_AMMO_METERS_NOTCH.save) then
					local local_player_unit = Managers.player:local_player().player_unit
					if local_player_unit and ScriptUnit.has_extension(local_player_unit, "inventory_system") then
						local inventory_extension = ScriptUnit.extension(local_player_unit, "inventory_system")
						if inventory_extension then
							local current_ammo, max_ammo = current_ammo_status(inventory_extension, false)
							if current_ammo ~= nil and max_ammo then
								widget.style.player_ammo_notch.offset[2] = 29 + math.max(0, math.min(current_ammo / max_ammo, 1))*67
							end
						end
					end
				end
			end

			if not self._customhud_is_dead and not self._customhud_player_unit_missing and not self._customhud_has_respawned and ammo_bar.bar_value then -- not showing if player inactive
				UIRenderer.draw_widget(ui_renderer, widget)
			end
		end

		UIRenderer.end_pass(ui_renderer)
	end

	return orig_func(self, dt)
end)

--[[
	Send/receive ammo updates over the network.
--]]

Mods.hook.set(mod_name, "GenericAmmoUserExtension.update", function(orig_func, self, unit, input, dt, context, t)
	orig_func(self, unit, input, dt, context, t)

	-- If this is the ammo extension for our ranged weapon, send our current ammo count to the
	-- other players if their view of it is out of date. We send updates once per second at most,
	-- so that fast-firing weapons dont cause rpc spam.
	if self.slot_name == "slot_ranged" then
		local current_ammo = self:total_remaining_ammo()
		local last_ammo_time = self._hudmod_last_ammo_time

		if self._hudmod_last_ammo_count ~= current_ammo and (not last_ammo_time or last_ammo_time + 1 < t) then
			self._hudmod_last_ammo_count = current_ammo
			self._hudmod_last_ammo_time = t
			local network_manager = Managers.state.network
			local unit_id = network_manager.unit_game_object_id(network_manager, self.owner_unit)

			if Managers.player.is_server then
				Mods.network.send_rpc_clients(RPC_HUDMOD_AMMO_UPDATE, unit_id, current_ammo)
			else
				for _, player in pairs(Managers.player:human_players()) do
					if player.peer_id ~= Managers.player:local_player().peer_id then
						Mods.network.send_rpc(RPC_HUDMOD_AMMO_UPDATE, player.peer_id, unit_id, current_ammo)
					end
				end
			end
		end
	end
end)

-- Required RPC update when equipment is added that GenericAmmoUserExtension.update does not cover.
Mods.hook.set(mod_name, "SimpleInventoryExtension.add_equipment",
function(func, self, slot_name, item_data, unit_template, extra_extension_data, ammo_percent)
	func(self, slot_name, item_data, unit_template, extra_extension_data, ammo_percent)
	if slot_name == "slot_ranged" then
		local network_manager = Managers.state.network
		local unit_id = network_manager.unit_game_object_id(network_manager, self._unit)
		local slot_data = self.get_slot_data(self, slot_name)
		local item_template = BackendUtils.get_item_template(item_data)
		local ammo_data = item_template.ammo_data

		if ammo_data and unit_id then
			local ammo_extn = get_ammo_extension(slot_data)
			if ammo_extn then
				local current_ammo = ammo_extn.max_ammo
				if ammo_percent ~= nil then
					current_ammo = math.ceil(ammo_extn.max_ammo * ammo_percent)
				end

				if Managers.player.is_server then
					Mods.network.send_rpc_clients(RPC_HUDMOD_AMMO_UPDATE, unit_id, current_ammo)
				else
					for _, player in pairs(Managers.player:human_players()) do
						if player.peer_id ~= Managers.player:local_player().peer_id then
							Mods.network.send_rpc(RPC_HUDMOD_AMMO_UPDATE, player.peer_id, unit_id, current_ammo)
						end
					end
				end
			end
		end
	end
end)

Mods.hook.set(mod_name, "PlayerManager.assign_unit_ownership",
function(func, self, unit, player, is_player_unit)
	func(self, unit, player, is_player_unit)
	local local_unit = Managers.player:local_player().player_unit
	if local_unit == unit then
		local network_manager = Managers.state.network
		local unit_id = network_manager.unit_game_object_id(network_manager, unit)
		local inventory_ext = ScriptUnit.has_extension(player.player_unit, "inventory_system") and ScriptUnit.extension(player.player_unit, "inventory_system")
		local slot_data = inventory_ext.get_slot_data(inventory_ext, "slot_ranged")
		local item_data = slot_data.item_data
		local item_template = BackendUtils.get_item_template(item_data)
		local ammo_data = item_template.ammo_data

		if ammo_data then
			local ammo_extn = get_ammo_extension(slot_data)
			if ammo_extn then
				local current_ammo = ammo_extn.available_ammo
				if Managers.player.is_server then
					Mods.network.send_rpc_clients(RPC_HUDMOD_AMMO_UPDATE, unit_id, current_ammo)
				else
					for _, player in pairs(Managers.player:human_players()) do
						if player.peer_id ~= Managers.player:local_player().peer_id then
							Mods.network.send_rpc(RPC_HUDMOD_AMMO_UPDATE, player.peer_id, unit_id, current_ammo)
						end
					end
				end
			end
		end
	end
end)

-- Allows easy access to a table of all unit frames.
UnitFramesHandler._get_unit_frames = function (self)
	return self._unit_frames
end

-- Request all ammo status when joining game in progress
Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, ...)
	func(...)
	if not Managers.player.is_server then
		for _, player in pairs(Managers.player:human_players()) do
			if player.peer_id ~= Managers.player:local_player().peer_id then
				Mods.network.send_rpc(RPC_HUDMOD_REQUEST_AMMO_UPDATE, player.peer_id, "")
			end
		end
	end
end)

Mods.network.register(RPC_HUDMOD_REQUEST_AMMO_UPDATE, function(sender_id, string)
	local network_manager = Managers.state.network

	local local_player = Managers.player:local_player()
	local unit_id = network_manager.unit_game_object_id(network_manager, local_player.player_unit)
	local inventory_extn = ScriptUnit.has_extension(local_player.player_unit, 'inventory_system') and ScriptUnit.extension(local_player.player_unit, 'inventory_system')
	if inventory_extn then
		local current_ammo = current_ammo_status(inventory_extn, false)
		if unit_id and current_ammo then
			Mods.network.send_rpc(RPC_HUDMOD_AMMO_UPDATE, sender_id, unit_id, current_ammo)
		end
	end

	if Managers.player.is_server then
		for _, player in pairs(Managers.player:bots()) do
			local unit_id = network_manager.unit_game_object_id(network_manager, player.player_unit)
			local inventory_extn = ScriptUnit.has_extension(player.player_unit, 'inventory_system') and ScriptUnit.extension(player.player_unit, 'inventory_system')
			if inventory_extn then
				local current_ammo = current_ammo_status(inventory_extn, false)
				if unit_id and current_ammo then
					Mods.network.send_rpc(RPC_HUDMOD_AMMO_UPDATE, sender_id, unit_id, current_ammo)
				end
			end
		end
	end
end)

Mods.network.register(RPC_HUDMOD_AMMO_UPDATE, function(sender_id, unit_id, ammo_count)
	local status, err = pcall(on_rpc_ammo_update, sender_id, unit_id, ammo_count)
	if err ~= nil then
		EchoConsole(err)
	end
end)

--[[
	Add options for this module to the Options UI.
--]]
local function create_options()
	Mods.option_menu:add_group("hud_group", "HUD Improvements")

	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.SUB_GROUP, true)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.TEAM_AMMO_METERS)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.TEAM_AMMO_METERS_NOTCH)
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.PLAYER_AMMO_METER)
end

local status, err = pcall(create_options)
if err ~= nil then
	EchoConsole(err)
end
