Mods.init = function()
	-- Load LuaFileSystem package
	local f = assert(package.loadlib("./mods/patch/function/lfs.dll", "luaopen_lfs"))
	lfs = f()

	-- Load settings
	Mods.exec("", "CommandList")
	
	-- Load Functions
	Mods.exec("patch/function", "Table")
	Mods.exec("patch/function", "Mods.hook")
	Mods.exec("patch/function", "Mods.chat")
	Mods.exec("patch/function", "Mods.keyboard")
	Mods.exec("patch/function", "Mods.whisper")
	Mods.exec("patch/function", "Mods.ban")
	Mods.exec("patch/function", "Mods.network")

	Mods.exec("patch/function", "Mods.gui")
	Mods.exec("patch/function", "Mods.debug")
	Mods.exec("patch/function", "Mods.ui")

	Mods.exec("patch/options", "Mods.option_menu")

	Mods.exec("patch/options", "Keyboard")
	Mods.exec("patch/options", "OptionsInjector")


	-- Make a list of all mods in 'mods/patch'
	local loadable_mod_list = {}

	for file in lfs.dir("./mods/patch") do
		if string.find(file, "%.lua$") then
			local modname = file:match("(.+)%..+")
			loadable_mod_list[modname] = true
		end
	end

	-- Suggested load order of mods
	local load_order = {
		"AnimationFix",
		"CheatProtect",
		"DisconnectResilience",
		"PlayerListPing",
		"PlayerListKickBan",
		"PlayerListShowEquipment",
		"LoadoutSaver",
		"InventoryFiltering",
		"BotImprovements",
		"ThirdPerson",
		"CustomHUD",
		"HealthBar",
		"ShowDamage",
		"SoundSettings",
		"ChatBlock",
		"Crosshair",
		"AmmoMeters",
		"HUDMods",
		"HUDToggle",
		"Scoreboard",
		"TrueflightTweaks",
		"LuckAndDupeIndicators",
		"UITimers",
		"SaveGrimoire",
		"WeaponSwitching",
		"ThirdPersonEquipment_Definitions",
		"ThirdPersonEquipment",
		"LobbyImprovements",
		"SalvageOnLoottable",
		"SkinDisabler",
		"MutatorSelector",
		"ChangeWeaponModelsWarning",
		"ChangeWeaponModels",
	}

	-- Load all mods in order
	for i, mod in pairs(load_order) do
		Mods.exec("patch", mod)
		loadable_mod_list[mod] = false
	end

	-- Load all other mods not specified in the load order
	for modname, loadable in pairs(loadable_mod_list) do
		if loadable then
			Mods.exec("patch", modname)
		end
	end
	
	-- Draw options menu
	Mods.option_menu:draw()
end
Mods.init()