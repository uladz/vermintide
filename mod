EchoConsole = function(message)
	Managers.chat:add_local_system_message(1, message, true)
end

Mods = { }

Mods.exec = function(group, file_name, args)
	local file_path = "mods"
		
	if group ~= "" then
		file_path = file_path .. "/" .. group
	end
		
	file_path = file_path .. "/" .. file_name .. ".lua"
		
	if file_exists(file_path) then
		local status, err = pcall(function ()
			local f = io.open(file_path, "r")
			local data = f:read("*all")
			local func = loadstring(data)

			if args == nil then
				func()
			else
				func(args)
			end
		
			f:close()
		end)

		if err == "mod:23: attempt to call local 'func' (a nil value)" then
			err = "Attempt to call local 'func' (a nil value) - Syntax error"
		end

		if err ~= nil then
			EchoConsole("Error on file '" .. file_path .. "'")
			EchoConsole(err)
			return false
		end
		
		return true
	else
		return false
	end
end

file_exists = function(name)
	local f = io.open(name,"r")
	
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

safe_pcall = function(func, echo)
	local status, err = pcall(func)
	
	if err ~= nil then
		EchoConsole(err)
	end
end

Mods.exec("", "Initialize")