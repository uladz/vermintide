pcall(function()
	Application.set_user_setting(Mods.ThirdPerson.SETTINGS.ACTIVE.save, not Application.user_setting(Mods.ThirdPerson.SETTINGS.ACTIVE.save))
	Application.save_user_settings()
end)