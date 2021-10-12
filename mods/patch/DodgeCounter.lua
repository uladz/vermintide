-- DodgeCounter
-- Xq 2021
-- The mod shows current / max dodges of equipped weapon as well as the dodge cooldown.
-- 
-- This mod has bee designed to work wth QoL modpack
-- To "install" copy the file to "steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch"

local mod_name = "DodgeCounter"
mod = {}

local MOD_SETTINGS =
{
	ENABLED =
	{
		["save"]		= "cb_hudmod_dodge_counter",
		["widget_type"]	= "stepper",
		text			= "Dodge Values Display",
		tooltip			=	"Dodge information\n" ..
							"Show current & max dodges and dodge reset timer.",
		["value_type"]	= "boolean",
		["options"]	=
		{
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"]		= 1, -- Default first option is enabled. In this case Off
	},
}

local create_options = function()
	Mods.option_menu:add_group("hud_group", "HUD Related Mods")
	Mods.option_menu:add_item("hud_group", MOD_SETTINGS.ENABLED, true)
end

local get = function(data)
	return Application.user_setting(data.save)
end

local global_exists = function(name)
	local ret = false
	for k,_ in pairs(_G) do
		if k == name then
			ret = true
			break
		end
	end
	return ret
end

local number_to_string = function(num, decimals)
	local ret = tostring(num)
	
	local int = math.floor(num)
	local fract = math.abs(num%1)
	if fract > 0 then
		ret = tostring(int) .. "." .. string.sub(tostring(fract),3, 2+decimals)
	end
	
	return ret
end

local update_dodge_values = function()
	local enabled			= get(MOD_SETTINGS.ENABLED)
	local owner				= Managers.player:local_player()
	local unit				= owner and owner.player_unit
	local status_extension	= unit and ScriptUnit.has_extension(unit, "status_system")
	
	if enabled and status_extension then
		status_extension:get_dodge_item_data()
	end
	
	return
end

Mods.hook.set(mod_name, "InventoryView.exit", function(func, ...)
	local ret = func(...)
	mod.update_needed = true
	return ret
end)

Mods.hook.set(mod_name, "GameModeManager.init", function(func, ...)
	local ret = func(...)
	mod.update_needed = true
	return ret
end)

Mods.hook.set(mod_name, "GameModeManager.hot_join_sync", function(func, ...)
	local ret = func(...)
	mod.update_needed = true
	return ret
end)

Mods.hook.set(mod_name, "SimpleInventoryExtension.wield", function(func, ...)
	local ret = func(...)
	mod.update_needed = true
	return ret
end)

mod.custom_hud_present = nil
mod.dodge_cooldown = 0
Mods.hook.set(mod_name, "UnitFrameUI.draw", function(func, self, dt)
	local enabled = get(MOD_SETTINGS.ENABLED)
	
	if enabled and Mods and Mods.gui and Mods.gui.text then
		repeat
			local owner = Managers.player:local_player()
			if not owner then break end
			
			local unit	= owner.player_unit
			if not unit then break end
			
			local status_extension = ScriptUnit.has_extension(unit, "status_system")
			if not status_extension or status_extension:is_disabled() then break end
			
			if mod.update_needed then
				mod.update_needed = false
				update_dodge_values()
			end
			
			
			if mod.custom_hud_present == nil then
				mod.custom_hud_present = global_exists("CustomHUD")
			end
			
			local current_ui_set	= "default"
			if mod.custom_hud_present then
				local current_hud	= CustomHUD and CustomHUD.current_hud
				if current_hud then
					current_ui_set	=	(current_hud == CustomHUD.GAMEPAD and "console") or
										(current_hud == CustomHUD.CUSTOM and "custom") or
										"default"
				end
			end
			
			local ammo_type = "ammo"
			if current_ui_set == "custom" then
				ammo_type = "heat"
				local inventory_extension	= ScriptUnit.has_extension(unit, "inventory_system")
				local slot_data				= inventory_extension and inventory_extension:equipment().slots["slot_ranged"]
				local right_unit			= slot_data and slot_data.right_unit_1p
				local left_unit				= slot_data and slot_data.left_unit_1p
				local ammo_extension		= ScriptUnit.has_extension(right_unit, "ammo_system") or ScriptUnit.has_extension(left_unit, "ammo_system")
				local uses_ammo				= (ammo_extension and ammo_extension:max_ammo_count() and true) or false
				if ammo_extension then
					ammo_type = "ammo"
				end
				current_ui_set = current_ui_set .. "_" .. ammo_type
			end
			
			local current_time		= Managers.time:time("game")
			local dodges_max		= status_extension.dodge_count
			local dodges_current	= math.clamp(dodges_max - status_extension.dodge_cooldown,0,1000)	-- status_extension.dodge_cooldown is really current dodge count, clamped at max_dodges +3
			local dodge_reset_time	= status_extension.dodge_cooldown_delay or current_time + 0.5
			local dodge_cooldown	= mod.dodge_cooldown or 0
			dodge_cooldown			= (dodge_reset_time and math.clamp(dodge_reset_time - current_time,0,100)) or dodge_cooldown
			
			local text_color = Color(255, 255, 255, 255)	-- a, r, g, b
			local ui_set =
			{
				default =
				{
					x = 1610,
					y = 80,
					font_size = 25,
				},
				console = 
				{
					x = 1363,
					y = 153,
					font_size = 30,
				},
				custom_ammo = 
				{
					x = 1650,
					y = 185,
					font_size = 25,
				},
				custom_heat = 
				{
					x = 1650,
					y = 140,
					font_size = 25,
				},
			}
			local scale_x = RESOLUTION_LOOKUP.res_w / 1920
			local scale_y = RESOLUTION_LOOKUP.res_h / 1080
			local x = math.floor(ui_set[current_ui_set].x * scale_x)
			local y = math.floor(ui_set[current_ui_set].y * scale_y)
			local font_size = math.floor(ui_set[current_ui_set].font_size * scale_y)
			local text = "(" .. tostring(dodges_current) .. "/" .. tostring(dodges_max) .. ") | " .. number_to_string(dodge_cooldown,2)
			Mods.gui.text(text, Vector3(x,y,1), font_size, text_color)
		until true
	end
	
	return func(self, dt)
end)

create_options()
