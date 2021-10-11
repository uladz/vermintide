local mod = ItemSpawner

Mods.spawnItem("speed_boost_potion")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned speed potion")
end
