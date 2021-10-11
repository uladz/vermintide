local mod = ItemSpawner

Mods.spawnItem("lorebook_page")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned lorebook page")
end
