local mod = ItemSpawner

Mods.spawnItem("torch")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned torch")
end
