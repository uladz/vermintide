--[[
	Name: Crosshair Spread Fix
	Author: VernonKun
	Updated: 6/2/2020

	Scale crosshair size according to field of view and zoom so that it represents the spread.

	Also Drakefire Pistols charged, Beam Staff normal, and Volley Crossbow charged attack crosshairs
	have been modified to represent the correct spread. Targeteer has no effect on these attacks so
	now the trait does not change the crosshair size anymore.

	Note that Drakefire Pistols blast and Beam Staff blast can only hit the neck of the rats and
	teammates, and only the inner circle of about 2/3 the radius can deal friendly fire damage. (More
	precisely, the inner 21.8 degrees out of the whole radius 34.9 degrees.)

	Update 1: Fixed the increased spread when switching from Drakefire Pistols charged to normal, or
	from switching from Beam Staff normal to charged. Ranged weapons with Skirmisher will not get
	increased spread when being switched from the melee weapon or other items.

	Update 2: Maximum spread is set back to default to prevent excessive spread when player takes
	damage. Skirmisher change is reverted.

	Update 2: Fixed Volley Crossbow charged shots resetting crosshair to the normal shot crosshair.

	(Codes borrowed from the V2 Crosshairs Fix mod by Skwuruhl:
	https://github.com/Skwuruhl/vermintide-2-crosshair-fix)
--]]

local mod_name = "CrosshairSpreadFix"

Mods.hook.set(mod_name, "CrosshairUI.update_spread", function (func, self, dt, equipment)
	Profiler.start("update_spread")

	local wielded_item_data = equipment.wielded
	local item_template = BackendUtils.get_item_template(wielded_item_data)
	local pitch = 0
	local yaw = 0

	if item_template.default_spread_template then
		local weapon_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit

		if weapon_unit and ScriptUnit.has_extension(weapon_unit, "spread_system") then
			local spread_extension = ScriptUnit.extension(weapon_unit, "spread_system")
			pitch, yaw = spread_extension:get_current_pitch_and_yaw()
		end
	end

	local camera_manager = Managers.state.camera
	local viewport_name = Managers.player:local_player().viewport_name
	local fieldOfView = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1

	local pitch_offset = 1080.0 * math.tan(math.rad(pitch)/2)/math.tan(fieldOfView/2)
	local yaw_offset = 1080.0 * math.tan(math.rad(yaw)/2)/math.tan(fieldOfView/2)

	self.crosshair_up.style.offset[2] = pitch_offset
	self.crosshair_down.style.offset[2] = -pitch_offset
	self.crosshair_left.style.offset[1] = -yaw_offset
	self.crosshair_right.style.offset[1] = yaw_offset

	Profiler.stop("update_spread")
end)

SpreadTemplates.drake_pistol_charged = {
	continuous = {
		still = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		moving = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		crouch_still = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		crouch_moving = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		zoomed_still = {
			max_yaw = 0,
			max_pitch = 0
		},
		zoomed_moving = {
			max_yaw = 0.4,
			max_pitch = 0.4
		}
	},
	immediate = {
		being_hit = {
			immediate_pitch = 1.4,
			immediate_yaw = 1.4
		},
		shooting = {
			immediate_pitch = 35,	--10
			immediate_yaw = 35	--10
		}
	}
}

SpreadTemplates._antitargeteer_drake_pistol_charged = {
	continuous = {
		still = {
			max_yaw = 70,	--15
			max_pitch = 70	--6
		},
		moving = {
			max_yaw = 70,	--15
			max_pitch = 70	--6
		},
		crouch_still = {
			max_yaw = 70,	--15
			max_pitch = 70	--6
		},
		crouch_moving = {
			max_yaw = 70,	--15
			max_pitch = 70	--6
		},
		zoomed_still = {
			max_yaw = 0,
			max_pitch = 0
		},
		zoomed_moving = {
			max_yaw = 0.8,	--0.4
			max_pitch = 0.8	--0.4
		}
	},
	immediate = {
		being_hit = {
			immediate_pitch = 2.8,	--1.4
			immediate_yaw = 2.8	--1.4
		},
		shooting = {
			immediate_pitch = 70,	--10
			immediate_yaw = 70	--10
		}
	}
}

SpreadTemplates.beam_blast = {
	continuous = {
		still = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		moving = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		crouch_still = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		crouch_moving = {
			max_yaw = 35,	--15
			max_pitch = 35	--6
		},
		zoomed_still = {
			max_yaw = 0,
			max_pitch = 0
		},
		zoomed_moving = {
			max_yaw = 0.4,
			max_pitch = 0.4
		}
	},
	immediate = {
		being_hit = {
			immediate_pitch = 1.4,
			immediate_yaw = 1.4
		},
		shooting = {
			immediate_pitch = 35,	--10
			immediate_yaw = 35	--10
		}
	}
}

Weapons.staff_blast_beam_template_1.default_spread_template = "beam_blast"
Weapons.staff_blast_beam_template_1_co.default_spread_template = "beam_blast"
Weapons.staff_blast_beam_template_1_t2.default_spread_template = "beam_blast"
Weapons.staff_blast_beam_template_1_t3.default_spread_template = "beam_blast"

SpreadTemplates.repeating_crossbow_3bolt = {
	continuous = {
		still = {
			max_yaw = 3,	--3.5
			max_pitch = 0.5
		},
		moving = {
			max_yaw = 3,	--3.5
			max_pitch = 0.5
		},
		crouch_still = {
			max_yaw = 3,	--3.5
			max_pitch = 0.5
		},
		crouch_moving = {
			max_yaw = 3,	--3.5
			max_pitch = 0.5
		},
		zoomed_still = {
			max_yaw = 3,	--3.5
			max_pitch = 0.5
		},
		zoomed_moving = {
			max_yaw = 3,	--3.5
			max_pitch = 0.5
		}
	},
	immediate = {
		being_hit = {
			immediate_pitch = 100.4,	--15	--100.4
			immediate_yaw = 100.4	--15	--100.4
		},
		shooting = {
			immediate_pitch = 6,
			immediate_yaw = 6
		}
	}
}

-- SpreadTemplates.maximum_pitch = 35
-- SpreadTemplates.maximum_yaw = 35

-- SpreadTemplates.crossbow.immediate.being_hit.immediate_pitch = 15	--100.4
-- SpreadTemplates.crossbow.immediate.being_hit.immediate_yaw = 15	--100.4

Mods.hook.set(mod_name, "WeaponSpreadExtension.init", function (func, self, extension_init_context, unit, extension_init_data)
	self.unit = unit
	self.owner_unit = extension_init_data.owner_unit
	local item_name = extension_init_data.item_name
	self.item_name = item_name
	local item_data = ItemMasterList[item_name]
	local item_template = BackendUtils.get_item_template(item_data)
	self.default_spread_template_name = item_template.default_spread_template
	self.spread_lerp_speed = item_template.spread_lerp_speed or 4
	self.spread_settings = SpreadTemplates[self.default_spread_template_name]

	self.crosshair_fix_no_targeteer = false

	self.drakefire_pistols = false
	self.beam_staff = false

	if self.default_spread_template_name == "brace_of_drake_pistols" then
		self.drakefire_pistols = true
	end

	if self.default_spread_template_name == "beam_blast" then
		self.beam_staff = true
	end

	self.current_state = "still"
	self.current_yaw = 0
	self.current_pitch = 0
	self.shooting = false
	self.hit_aftermath = false
	self.hit_timer = 0
end)

local ignored_damage_types = {
	globadier_gas_dot = true,
	buff_shared_medpack = true,
	wounded_dot = true,
	buff = true,
	heal = true
}

Mods.hook.set(mod_name, "WeaponSpreadExtension.update", function (func, self, unit, input, dt, context, t)
	local current_pitch = self.current_pitch
	local current_yaw = self.current_yaw
	local current_state = self.current_state
	local continuous_spread_settings = self.spread_settings.continuous
	local state_settings = continuous_spread_settings[current_state]
	local owner_buff_extension = self.owner_buff_extension
	local new_pitch = owner_buff_extension:apply_buffs_to_value(state_settings.max_pitch, StatBuffIndex.ACCURACY)
	local new_yaw = owner_buff_extension:apply_buffs_to_value(state_settings.max_yaw, StatBuffIndex.ACCURACY)

	if self.crosshair_fix_no_targeteer then
		new_pitch = state_settings.max_pitch
		new_yaw = state_settings.max_yaw
	end

	local input_extension = self.owner_input_extension
	local status_extension = self.owner_status_extension
	local moving = CharacterStateHelper.is_moving(input_extension)
	local crouching = CharacterStateHelper.is_crouching(status_extension)
	local zooming = CharacterStateHelper.is_zooming(status_extension)
	local new_state = nil
	local lerp_speed = 4
	--local lerp_speed = self.spread_lerp_speed or 4

	if self.hit_aftermath then
		self.hit_timer = self.hit_timer - dt
		lerp_speed = math.random(0.5, 1)

		if self.hit_timer <= 0 then
			self.hit_aftermath = false
		end
	end

	if owner_buff_extension:has_buff_type("increased_move_speed_while_aiming") then
		moving = false
	end

	if moving then
		if crouching then
			new_state = "crouch_moving"
		elseif zooming then
			new_state = "zoomed_moving"
		else
			new_state = "moving"
		end
	elseif crouching then
		new_state = "crouch_still"
	elseif zooming then
		new_state = "zoomed_still"
	else
		new_state = "still"
	end

	if current_state ~= new_state then
		self.current_state = new_state
	end

	current_pitch = math.lerp(current_pitch, new_pitch, math.min(1, dt * lerp_speed))
	current_yaw = math.lerp(current_yaw, new_yaw, math.min(1, dt * lerp_speed))

	--Fix Drakefire Pistols switching firing mode spread
	if self.drakefire_pistols then
		if new_pitch ~= 35 and current_pitch < 35 and current_pitch > 6 then
			current_pitch = 6
			current_pitch = math.lerp(current_pitch, new_pitch, math.min(1, dt * lerp_speed))
		end

		if new_yaw ~= 35 and current_yaw < 35 and current_yaw > 15 then
			current_yaw = 15
			current_yaw = math.lerp(current_yaw, new_yaw, math.min(1, dt * lerp_speed))
		end
	end

	--Fix Beam Staff switching firing mode spread
	if self.beam_staff then
		if new_pitch ~= 35 and current_pitch < 35 and current_pitch > 8 then
			current_pitch = 8
			current_pitch = math.lerp(current_pitch, new_pitch, math.min(1, dt * lerp_speed))
		end

		if new_yaw ~= 35 and current_yaw < 35 and current_yaw > 12 then
			current_yaw = 12
			current_yaw = math.lerp(current_yaw, new_yaw, math.min(1, dt * lerp_speed))
		end
	end

	--Ranged weapon with Skrimisher won't get initial spread when being switched into
	-- if owner_buff_extension:has_buff_type("increased_move_speed_while_aiming") then
		-- if (current_state == "moving" and new_state == "still") or (current_state == "crouch_moving" and new_state == "crouch_still") or (current_state == "zoomed_moving" and new_state == "zoomed_still") then
			-- state_settings = continuous_spread_settings[new_state]
			-- current_pitch = owner_buff_extension:apply_buffs_to_value(state_settings.max_pitch, StatBuffIndex.ACCURACY)
			-- current_yaw = owner_buff_extension:apply_buffs_to_value(state_settings.max_yaw, StatBuffIndex.ACCURACY)
		-- end
	-- end

	local immediate_spread_settings = self.spread_settings.immediate
	local immediate_pitch = 0
	local immediate_yaw = 0
	local damage_extension = self.owner_damage_extension
	local recent_damage_type = damage_extension:recently_damaged()
	local hit = recent_damage_type and not ignored_damage_types[recent_damage_type]

	if hit then
		local spread_settings = immediate_spread_settings.being_hit
		immediate_pitch = spread_settings.immediate_pitch
		immediate_yaw = spread_settings.immediate_yaw
		self.hit_aftermath = true
		self.hit_timer = 1.5
	end

	if self.shooting then
		local spread_settings = immediate_spread_settings.shooting
		immediate_pitch = owner_buff_extension:apply_buffs_to_value(spread_settings.immediate_pitch, StatBuffIndex.ACCURACY)
		immediate_yaw = owner_buff_extension:apply_buffs_to_value(spread_settings.immediate_yaw, StatBuffIndex.ACCURACY)

		if self.crosshair_fix_no_targeteer then
			immediate_pitch = spread_settings.immediate_pitch
			immediate_yaw = spread_settings.immediate_yaw
		end

		self.shooting = false
	end

	if not self.crosshair_fix_no_targeteer then
		current_pitch = current_pitch + immediate_pitch
		current_yaw = current_yaw + immediate_yaw
	end

	if not self.drakefire_pistols and not self.beam_staff then
		self.current_pitch = math.min(current_pitch, SpreadTemplates.maximum_pitch)
		self.current_yaw = math.min(current_yaw, SpreadTemplates.maximum_yaw)
	else
		self.current_pitch = math.min(current_pitch, 35)
		self.current_yaw = math.min(current_yaw, 35)
	end
end)

Mods.hook.set(mod_name, "WeaponSpreadExtension.override_spread_template", function (func, self, spread_template_name)
	self.spread_settings = SpreadTemplates[spread_template_name]

	if spread_template_name == "drake_pistol_charged" or spread_template_name == "repeating_crossbow_3bolt" or spread_template_name == "beam_blast" then --or spread_template_name == "_antitargeteer_drake_pistol_charged" then
		self.crosshair_fix_no_targeteer = true
	else
		self.crosshair_fix_no_targeteer = false
	end

	local current_state = self.current_state
	local continuous_spread_settings = self.spread_settings.continuous
	local state_settings = continuous_spread_settings[current_state]
	self.current_pitch = state_settings.max_pitch
	self.current_yaw = state_settings.max_yaw
end)

Mods.hook.set(mod_name, "WeaponSpreadExtension.reset_spread_template", function (func, self)
	self.spread_settings = SpreadTemplates[self.default_spread_template_name]

	self.crosshair_fix_no_targeteer = false
end)

Mods.hook.set(mod_name, "ActionCrossbow.client_owner_start_action", function(func, self, new_action, t)
	func(self, new_action, t)

	local spread_template_override = new_action.spread_template_override

	if spread_template_override then
		self.spread_extension:override_spread_template(spread_template_override)
	end
end)

Mods.hook.set(mod_name, "ActionCrossbow.finish", function(func, self, reason)
	func(self, reason)

	if self.spread_extension then
		self.spread_extension:reset_spread_template()
	end
end)
