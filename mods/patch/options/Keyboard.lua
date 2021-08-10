--[[
	Patch Keyboard:
		Every time you host/join a new map the key binding needs to be reloaded.
--]]
local mod_name = "Keyboard"

Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, ...)
	func(...)
	
	-- Check settings
	for _, item in ipairs(Mods.keyboard.update) do
		if Mods.keyboard.pressed(item[1]) then			
			Mods.exec(item[2], item[3], item[4])
		end
	end
	
	return
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_started", function(func, ...)
	func(...)
	
	Mods.keyboard.init()
end)

Mods.hook.set(mod_name, "StateInGameRunning.event_game_actually_starts", function(func, ...)
	func(...)
	
	Mods.keyboard.init()
end)