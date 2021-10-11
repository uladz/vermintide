local mod = ItemSpawner

Mods.spawnItem("first_aid_kit")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned med pack")
end
