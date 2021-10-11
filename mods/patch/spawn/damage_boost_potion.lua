local mod = ItemSpawner

Mods.spawnItem("damage_boost_potion")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned damage potion")
end
