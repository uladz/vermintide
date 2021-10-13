local mod = ChestInfo

mod.set(mod.widget_settings.PING, not mod.get(mod.widget_settings.PING))
mod.save()

--Feedback
if mod.get(mod.widget_settings.PING) then
	EchoConsole("Enabled")
else
	EchoConsole("Disabled")
end
