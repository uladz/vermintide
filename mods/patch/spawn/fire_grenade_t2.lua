local mod = ItemSpawner

Mods.spawnItem("fire_grenade_t2")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned fire grenade")
end
