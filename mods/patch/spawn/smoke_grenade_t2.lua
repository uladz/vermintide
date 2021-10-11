local mod = ItemSpawner

Mods.spawnItem("smoke_grenade_t2")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned smoke grenade")
end
