pcall(function()
	Application.set_user_setting(Mods.ThirdPerson.SETTINGS.SIDE.save, not Application.user_setting(Mods.ThirdPerson.SETTINGS.SIDE.save))
	Application.save_user_settings()
end)