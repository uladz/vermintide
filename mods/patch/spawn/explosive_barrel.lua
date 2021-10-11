local mod = ItemSpawner

Mods.spawnItem("explosive_barrel")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned explosive barrel")
end
