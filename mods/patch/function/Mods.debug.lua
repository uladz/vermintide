Mods.debug = {
	-- Draw parameter of function call if you only know the function name
	parameter = function(func_name)	
		Mods.hook.set("debug", func_name, function(func, ...)
			local args = table.pack(...)
			local str = func_name .. "("
			
			for i, v in ipairs(args) do
				str = str .. type(v)
				
				if #args ~= i then
					str = str .. ", "
				end
			end
			
			EchoConsole(str .. ")")
			
			-- Disable the hook
			Mods.hook.enable(false, "debug", func_name)
			
			return func(...)
		end)
		
		return
	end,
	
	parameters = function(o)
		for key, obj in pairs(o) do
			if type(obj) == "function" then
				Mods.debug.parameter(key)
			end
		end
		
		return
	end,
	
	-- Draw all propeties inside object
	object = {
		
		draw = function(obj, obj_name, level_max)
			local draw
			local found_adress = {}
			
			if type(obj) ~= "table" then
				return
			end
			
			table.insert(found_adress, table.adress(obj))
			
			draw = function(out, o, space, level)
				if level >= level_max then
					return
				end
				
				for key, obj in pairs(o) do
					if type(obj) == "table" then
						local adress = table.adress(obj)
						
						if not table.has_item(found_adress, adress) then
							table.insert(found_adress, table.adress(obj))
							
							out:write(space .. tostring(key) .. "(" .. table.adress(obj) .. ") = {\n")
							draw(out, obj, space .. "	", level + 1)
							out:write(space .. "},\n")
						else
							out:write(space .. tostring(key) .. " = table: " .. table.adress(obj) .. "\n")
						end
					else
						out:write(space .. tostring(key) .. " = " .. tostring(obj) .. ",\n")
					end
				end
				
				return
			end

			local out = assert(io.open(obj_name .. ".json", "w+"))

			out:write(obj_name .. "(" .. table.adress(obj) .. ") = {\n")
			draw(out, obj, "	", 1)
			out:write("}\n")
			out:close()
		end,
		
		draw_safe = function(obj, obj_name, level_max)
			local draw
			local draw_obj

			draw = function(out, o, space, level)
				if level >= level_max then
					return
				end
				
				for key, obj in pairs(o) do
					safe_pcall(function()
						draw_obj(out, obj, key, level, space)
					end)
				end		
				
				return
			end
			
			draw_obj = function(out, obj, key, level, space)
				if type(obj) == "table" then
					out:write(space .. tostring(key) .. " = {\n")
					draw(out, obj, space .. "	", level + 1)
					out:write(space .. "},\n")
				else
					out:write(space .. tostring(key) .. " = " .. tostring(obj) .. ",\n")
				end
			end

			local out = assert(io.open(obj_name .. ".json", "w+"))

			out:write(obj_name .. " = {\n")
			draw(out, obj, "	", 1)
			out:write("}\n")
			out:close()
		end
	}
}

-- Lazyness mode xD
mdp = Mods.debug.parameter
mdps = Mods.debug.parameters
mdod = Mods.debug.object.draw
mdods = Mods.debug.object.draw_safe