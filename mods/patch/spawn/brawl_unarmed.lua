local mod = ItemSpawner

Mods.spawnItem("brawl_unarmed")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned beer barrel")
end
