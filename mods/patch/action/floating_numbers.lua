pcall(function()
	if Application.user_setting(ShowPlayerDamage.SETTINGS.FLTNRS.save) then
		Application.set_user_setting(ShowPlayerDamage.SETTINGS.FLTNRS.save, false)
		EchoConsole("Floating Numbers Off")
	else
		Application.set_user_setting(ShowPlayerDamage.SETTINGS.FLTNRS.save, true)
		EchoConsole("Floating Numbers On")
	end
	Application.save_user_settings()
end)