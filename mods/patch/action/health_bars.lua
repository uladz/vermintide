pcall(function()
	if Application.user_setting(EnemyHealthBars.SETTINGS.HK_TOGGLE_B.save) == 2 then
		if Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save) == 1 then
			Application.set_user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save, 5)
			EchoConsole("Enemy Health Bars: Enabled")
		else
			Application.set_user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save, 1)
			EchoConsole("Enemy Health Bars: Disabled")
		end
	else
		local value	= Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save)
		value = value + 1
		if value > 5 then value = 1 end
		Application.set_user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save, value)
		Application.save_user_settings()
		
		if Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save) == 1 then
			EchoConsole("Enemy Health Bars: Off")
		elseif Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save) == 2 then
			EchoConsole("Enemy Health Bars: All")
		elseif Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save) == 3 then
			EchoConsole("Enemy Health Bars: Specials")
		elseif Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save) == 4 then
			EchoConsole("Enemy Health Bars: Ogre")
		elseif Application.user_setting(EnemyHealthBars.SETTINGS.ACTIVE.save) == 5 then
			EchoConsole("Enemy Health Bars: Custom")
		end
	end
end)