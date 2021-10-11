local mod = ItemSpawner

Mods.spawnItem("grimoire")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned grimoire")
end
