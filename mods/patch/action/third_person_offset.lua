pcall(function()
	if Application.user_setting(Mods.ThirdPerson.SETTINGS.OFFSET.save) == 100 then
		Application.set_user_setting(Mods.ThirdPerson.SETTINGS.OFFSET.save, 200)
	elseif Application.user_setting(Mods.ThirdPerson.SETTINGS.OFFSET.save) == 200 then
		Application.set_user_setting(Mods.ThirdPerson.SETTINGS.OFFSET.save, 400)
	else
		Application.set_user_setting(Mods.ThirdPerson.SETTINGS.OFFSET.save, 100)
	end
	Application.save_user_settings()
end)