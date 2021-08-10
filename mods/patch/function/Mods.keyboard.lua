ModsKeyMap = {
	win32 = {
		f1				= {"keyboard", "f1", "pressed"},
		f2				= {"keyboard", "f2", "pressed"},
		f3				= {"keyboard", "f3", "pressed"},
		f4				= {"keyboard", "f4", "pressed"},
		f5				= {"keyboard", "f5", "pressed"},
		f6				= {"keyboard", "f6", "pressed"},
		f7				= {"keyboard", "f7", "pressed"},
		f8				= {"keyboard", "f8", "pressed"},
		f9				= {"keyboard", "f9", "pressed"},
		f10				= {"keyboard", "f10", "pressed"},
		f11				= {"keyboard", "f11", "pressed"},
		f12				= {"keyboard", "f12", "pressed"},
		
		["up"]			= {"keyboard", "up", "held"},
		["down"]		= {"keyboard", "down", "held"},
		["left"]		= {"keyboard", "left", "held"},
		["right"]		= {"keyboard", "right", "held"},
		
		["page up"]		= {"keyboard", "page up", "pressed"},
		["page down"]	= {"keyboard", "page down", "pressed"},
		["end"]         = {"keyboard", "end", "pressed"},
		
		["left ctrl"]	= {"keyboard", "left ctrl", "held"},
		["left shift"]	= {"keyboard", "left shift", "held"},
		["left alt"]	= {"keyboard", "left alt", "held"},
		
		["home"]   		= {"keyboard", "home", "pressed"},
		
		a				= {"keyboard", "a", "pressed"},
		b				= {"keyboard", "b", "pressed"},
		d				= {"keyboard", "d", "pressed"},
		f				= {"keyboard", "f", "pressed"},
		g				= {"keyboard", "g", "pressed"},
		h				= {"keyboard", "h", "pressed"},
		i				= {"keyboard", "i", "pressed"},
		k				= {"keyboard", "k", "pressed"},
		o				= {"keyboard", "o", "pressed"},
		p				= {"keyboard", "p", "pressed"},
		r				= {"keyboard", "r", "pressed"},
		u				= {"keyboard", "u", "pressed"},
		
		mouse_left		= {"mouse", "left", "pressed"},
		mouse_middle    = {"mouse", "middle", "pressed"},
		mouse_right		= {"mouse", "right", "pressed"},
		
		input			= {"keyboard", "a", "pressed"},
		
		["6"]			= {"keyboard", "6", "pressed"},
		["7"]			= {"keyboard", "7", "pressed"},
		["8"]			= {"keyboard", "8", "pressed"},
		["9"]			= {"keyboard", "9", "pressed"},
	},
}
ModsKeyMap.xb1 = ModsKeyMap.win32

Mods.keyboard = {
	update = {},
	
	init = function()
		Managers.input.create_input_service(Managers.input, "Mods", "ModsKeyMap")
		Managers.input.map_device_to_service(Managers.input, "Mods", "keyboard")
		Managers.input.map_device_to_service(Managers.input, "Mods", "mouse")
		Managers.input.map_device_to_service(Managers.input, "Mods", "gamepad")
	end,
	
	pressed = function(keys)
		local blocks = { "left ctrl", "left shift", "left alt" }
		local input_service = Managers.input:get_service("Mods")
		
		if input_service then
			-- Check first if all keys are pressed
			for _, key in ipairs(keys) do
				if input_service.get(input_service, key) == false then --or not table.has_item(ModsKeyMap.win32, key) then
					return false
				end
			end
			
			-- Check Blocks
			for _, block_key in ipairs(blocks) do
				if table.has_item(keys, block_key) == false and input_service.get(input_service, block_key) then
					return false
				end
			end
			
			return true
		else
			return false
		end
	end,
	
	get = function(folder, script)
		for _, command in pairs(Mods.keyboard.update) do
			if command[2] == folder and command[3] == script then
				return command
			end
		end
		return nil
	end,
	
	add = function(keys, folder, script)
		local action = Mods.keyboard.get(folder, script)
		
		if action then
			action[1] = keys
			action[2] = folder
			action[3] = script
		else
			local command = {table.clone(keys), folder, script}
			Mods.keyboard.update[#Mods.keyboard.update+1] = command
		end
		return true
	end,
}

Mods.keyboard.init()