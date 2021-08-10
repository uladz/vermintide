pcall(function()
	if Application.user_setting(Mods.ThirdPerson.SETTINGS.HK_ZOOM_B.save) == 2 then
		if Application.user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save) == 4 then
			Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save, 1)
		else
			Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save, 4)
		end
		Application.save_user_settings()
	else
		if Application.user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save) == 4 then
			Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save, 3)
		elseif Application.user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save) == 3 then
			Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save, 2)
		elseif Application.user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save) == 2 then
			Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save, 1)
		else
			Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ZOOM.save, 4)
		end
		Application.save_user_settings()
	end
end)