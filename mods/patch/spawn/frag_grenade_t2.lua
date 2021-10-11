local mod = ItemSpawner

Mods.spawnItem("frag_grenade_t2")

-- Feedback
if mod.get(mod.widget_settings.HK_FEEDBACK) then
	EchoConsole("Spawned frag grenade")
end
