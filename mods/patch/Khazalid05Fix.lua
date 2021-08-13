--[[
  Khazalid 05 Fix Mod
  By: VernonKun

  This mod changes the loading screen text <loading_screen_khazalid_05> to "Introduction to
	Khazalid, lesson #5 | Dawr = 'As good as something can get without it being proven over time and
	hard use'. Also dwarfen slang for "comrade"." (It is probably the double quotation marks causing
	the bug.)

  Text is copied from Sir Duckyweather's guide: "A Guide for Warhammer: End Times - Vermintide" by
	Sir Duckyweather. Here you can find all text from the bottom of loading screens in one convenient
	location.

  Installation: Place the file under mods/patch.
--]]

local mod_name = "Khazalid05Fix"

Mods.hook.set(mod_name, "Localize", function(func, text_id)
	if (text_id == "loading_screen_khazalid_05") then
		return "Introduction to Khazalid, lesson #5 | Dawr = 'As good as something can get without " ..
		  "it being proven over time and hard use'. Also dwarfen slang for \"comrade\"."
	end

	return func(text_id)
end)

--EchoConsole(Localize("loading_screen_khazalid_05"))
