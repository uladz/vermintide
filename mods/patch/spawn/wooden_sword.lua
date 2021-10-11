local mod = ItemSpawner

Mods.spawnItem("wooden_sword_01")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned wooden sword")
end
