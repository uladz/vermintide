local mod = ItemSpawner

Mods.spawnItem("tome")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned tome")
end
