--[[
	Name: Change Weapon Models.
	Author: /dev/null.
	Version: QoL v15

	This mod allows you to swap the model of your weapons with that of another quality of the same
	type, in a manner visible only to you.

	Update 5/11/2020: Added Ceremonial Dagger support (by VernonKun).
	The mod in QOL V15 wasn't updated after the Death on the Reik DLC came out, so it didn't support
	changing the models of Ceremonial Dagger. I have updated the mod to support that.
--]]

if not Application.user_setting("cb_weapon_model_warning") then
	return
end

local mod_name = "ChangeWeaponModels"

ChangeWeaponModels = {
    SETTINGS = {}
}

ChangeWeaponModels.hero_infos = {
    ["Witch Hunter"] = {
        menu   = "WITCH_HUNTER",
        config = "witch_hunter"
    },

    ["Bright Wizard"] = {
        menu   = "BRIGHT_WIZARD",
        config = "bright_wizard"
    },

    ["Dwarf Ranger"] = {
        menu   = "DWARF_RANGER",
        config = "dwarf_ranger"
    },

    ["Waywatcher"] = {
        menu   = "WAYWATCHER",
        config = "waywatcher"
    },

    ["Empire Soldier"] = {
        menu   = "EMPIRE_SOLDIER",
        config = "empire_soldier"
    }
}

ChangeWeaponModels.heroes_lookup = {
    "Witch Hunter",
    "Bright Wizard",
    "Dwarf Ranger",
    "Waywatcher",
    "Empire Soldier"
}

ChangeWeaponModels.weapon_rarities = {
    plentiful = "Plentiful",
    common    = "Common",
    rare      = "Rare",
    exotic    = "Exotic",
    unique    = "Unique"
}

ChangeWeaponModels.weapon_rarities_lookup = {
    "plentiful",
    "common",
    "rare",
    "exotic",
    "unique"
}

ChangeWeaponModels.melee_weapons_names = {
    ["Witch Hunter"] = {
        wh_fencing_sword = "Rapier",
        wh_1h_axes       = "One handed axe",
        wh_2h_sword      = "Two handed sword",
        wh_1h_falchions  = "Falchion"
    },

    ["Bright Wizard"] = {
        bw_1h_sword    = "One handed sword",
        bw_flame_sword = "Flaming Sword",
        bw_morningstar = "Mace",
	bw_dagger = "Ceremonial Dagger"
    },

    ["Dwarf Ranger"] = {
        dr_1h_axes          = "One handed axe",
        dr_1h_hammer        = "One handed hammer",
        dr_1h_axe_shield    = "Axe & Shield",
        dr_1h_hammer_shield = "Hammer & Shield",
        dr_2h_axes          = "Two handed axe",
        dr_2h_hammer        = "Two handed hammer",
        dr_2h_picks         = "Pick"
    },

    ["Waywatcher"] = {
        ww_1h_sword         = "One handed sword",
        ww_dual_daggers     = "Dual daggers",
        ww_dual_swords      = "Dual swords",
        ww_sword_and_dagger = "Sword & Dagger",
        ww_2h_axe           = "Glaive"
    },

    ["Empire Soldier"] = {
        es_1h_sword        = "One handed sword",
        es_1h_mace         = "Mace",
        es_1h_sword_shield = "Sword & Shield",
        es_1h_mace_shield  = "Mace & Shield",
        es_2h_sword        = "Two handed sword",
        es_2h_war_hammer   = "Two handed hammer",
        es_2h_sword_exec   = "Executioner sword"
    }
}

ChangeWeaponModels.ranged_weapons_names = {
    ["Witch Hunter"] = {
        wh_brace_of_pisols    = "Brace of pistols",
        wh_repeating_pistol   = "Repeater pistol",
        wh_crossbow           = "Crossbow",
        wh_repeating_crossbow = "Volley Crossbow"
    },

    ["Bright Wizard"] = {
        bw_staff_geiser  = "Conflagration staff",
        bw_staff_beam    = "Beam staff",
        bw_staff_spear   = "Bolt staff",
        bw_staff_firball = "Fireball staff"
    },

    ["Dwarf Ranger"] = {
        dr_handgun           = "Handgun",
        dr_grudgeraker       = "Grudge-Raker",
        dr_crossbow          = "Crossbow",
        dr_drakefire_pistols = "Drakefire pistols",
    },

    ["Waywatcher"] = {
        ww_shortbow   = "Swift bow",
        ww_hagbane    = "Hagbane swift bow",
        ww_longbow    = "Longbow",
        ww_trueflight = "Trueflight longbow"
    },

    ["Empire Soldier"] = {
        es_handgun           = "Handgun",
        es_blunderbuss       = "Blunderbuss",
        es_repeating_handgun = "Repeater Handgun"
    }
}

ChangeWeaponModels.melee_weapons_lookup = {
    ["Witch Hunter"] = {
        "wh_fencing_sword",
        "wh_1h_axes",
        "wh_2h_sword",
        "wh_1h_falchions"
    },

    ["Bright Wizard"] = {
        "bw_1h_sword",
        "bw_flame_sword",
        "bw_morningstar",
        "bw_dagger"
    },

    ["Dwarf Ranger"] = {
        "dr_1h_axes",
        "dr_1h_hammer",
        "dr_1h_axe_shield",
        "dr_1h_hammer_shield",
        "dr_2h_axes",
        "dr_2h_hammer",
        "dr_2h_picks"
    },

    ["Waywatcher"] = {
        "ww_1h_sword",
        "ww_dual_daggers",
        "ww_dual_swords",
        "ww_sword_and_dagger",
        "ww_2h_axe"
    },

    ["Empire Soldier"] = {
        "es_1h_sword",
        "es_1h_mace",
        "es_1h_sword_shield",
        "es_1h_mace_shield",
        "es_2h_sword",
        "es_2h_war_hammer",
        "es_2h_sword_exec"
    }
}

ChangeWeaponModels.ranged_weapons_lookup = {
    ["Witch Hunter"] = {
        "wh_brace_of_pisols",
        "wh_repeating_pistol",
        "wh_crossbow",
        "wh_repeating_crossbow"
    },

    ["Bright Wizard"] = {
        "bw_staff_geiser",
        "bw_staff_beam",
        "bw_staff_spear",
        "bw_staff_firball"
    },

    ["Dwarf Ranger"] = {
        "dr_handgun",
        "dr_grudgeraker",
        "dr_crossbow",
        "dr_drakefire_pistols"
    },

    ["Waywatcher"] = {
        "ww_shortbow",
        "ww_hagbane",
        "ww_longbow",
        "ww_trueflight"
    },

    ["Empire Soldier"] = {
        "es_handgun",
        "es_blunderbuss",
        "es_repeating_handgun"
    }
}

ChangeWeaponModels.weapons_use_types = {
    ["Witch Hunter"] = {
        wh_fencing_sword = "MELEE",
        wh_1h_axes       = "MELEE",
        wh_2h_sword      = "MELEE",
        wh_1h_falchions  = "MELEE",

        wh_brace_of_pisols    = "RANGED",
        wh_repeating_pistol   = "RANGED",
        wh_crossbow           = "RANGED",
        wh_repeating_crossbow = "RANGED"
    },

    ["Bright Wizard"] = {
        bw_1h_sword    = "MELEE",
        bw_flame_sword = "MELEE",
        bw_morningstar = "MELEE",
        bw_dagger      = "MELEE",

        bw_staff_geiser  = "RANGED",
        bw_staff_beam    = "RANGED",
        bw_staff_spear   = "RANGED",
        bw_staff_firball = "RANGED"
    },

    ["Dwarf Ranger"] = {
        dr_1h_axes          = "MELEE",
        dr_1h_hammer        = "MELEE",
        dr_1h_axe_shield    = "MELEE",
        dr_1h_hammer_shield = "MELEE",
        dr_2h_axes          = "MELEE",
        dr_2h_hammer        = "MELEE",
        dr_2h_picks         = "MELEE",

        dr_handgun           = "RANGED",
        dr_grudgeraker       = "RANGED",
        dr_crossbow          = "RANGED",
        dr_drakefire_pistols = "RANGED",
    },

    ["Waywatcher"] = {
        ww_1h_sword         = "MELEE",
        ww_dual_daggers     = "MELEE",
        ww_dual_swords      = "MELEE",
        ww_sword_and_dagger = "MELEE",
        ww_2h_axe           = "MELEE",

        ww_shortbow   = "RANGED",
        ww_hagbane    = "RANGED",
        ww_longbow    = "RANGED",
        ww_trueflight = "RANGED"
    },

    ["Empire Soldier"] = {
        es_1h_sword        = "MELEE",
        es_1h_mace         = "MELEE",
        es_1h_sword_shield = "MELEE",
        es_1h_mace_shield  = "MELEE",
        es_2h_sword        = "MELEE",
        es_2h_war_hammer   = "MELEE",
        es_2h_sword_exec   = "MELEE",

        es_handgun           = "RANGED",
        es_blunderbuss       = "RANGED",
        es_repeating_handgun = "RANGED"
    }
}

ChangeWeaponModels.melee_weapons_ids = {
    wh_fencing_sword = {
        plentiful = "wh_fencing_sword_0001",
        common    = "wh_fencing_sword_0002",
        rare      = "wh_fencing_sword_0016",
        exotic    = "wh_fencing_sword_0082",
        unique    = "wh_fencing_sword_1001"
    },
    wh_1h_axes = {
        plentiful = "wh_1h_axe_0001",
        common    = "wh_1h_axe_0002",
        rare      = "wh_1h_axe_0016",
        exotic    = "wh_1h_axe_0082",
        unique    = "wh_1h_axe_1001"
    },
    wh_2h_sword = {
        plentiful = "wh_2h_sword_0001",
        common    = "wh_2h_sword_0002",
        rare      = "wh_2h_sword_0016",
        exotic    = "wh_2h_sword_0082",
        unique    = "wh_2h_sword_1001"
    },
    wh_1h_falchions = {
        plentiful = "wh_1h_falchion_0001",
        common    = "wh_1h_falchion_1001",
        rare      = "wh_1h_falchion_2001",
        exotic    = "wh_1h_falchion_3001",
        unique    = "wh_1h_falchion_4001"
    },

    bw_1h_sword = {
        plentiful = "bw_sword_0001",
        common    = "bw_sword_0002",
        rare      = "bw_sword_0017",
        exotic    = "bw_sword_0091",
        unique    = "bw_sword_1001"
    },
    bw_flame_sword = {
        plentiful = "bw_flame_sword_0001",
        common    = "bw_flame_sword_0002",
        rare      = "bw_flame_sword_0017",
        exotic    = "bw_flame_sword_0091",
        unique    = "bw_flame_sword_1001"
    },
    bw_morningstar = {
        plentiful = "bw_1h_mace_0001",
        common    = "bw_1h_mace_0002",
        rare      = "bw_1h_mace_0017",
        exotic    = "bw_1h_mace_0091",
        unique    = "bw_1h_mace_1001"
    },
    bw_dagger = {
        plentiful = "bw_dagger_0001",
        common    = "bw_dagger_1001",
        rare      = "bw_dagger_2001",
        exotic    = "bw_dagger_3001",
        unique    = "bw_dagger_4001"
    },

    dr_1h_axes = {
        plentiful = "dr_1h_axe_0001",
        common    = "dr_1h_axe_0002",
        rare      = "dr_1h_axe_0016",
        exotic    = "dr_1h_axe_0082",
        unique    = "dr_1h_axe_1001"
    },
    dr_1h_hammer = {
        plentiful = "dr_1h_hammer_0001",
        common    = "dr_1h_hammer_0002",
        rare      = "dr_1h_hammer_0016",
        exotic    = "dr_1h_hammer_0082",
        unique    = "dr_1h_hammer_1001"
    },
    dr_1h_axe_shield = {
        plentiful = "dr_shield_axe_0001",
        common    = "dr_shield_axe_0002",
        rare      = "dr_shield_axe_0016",
        exotic    = "dr_shield_axe_0082",
        unique    = "dr_shield_axe_1001"
    },
    dr_1h_hammer_shield = {
        plentiful = "dr_shield_hammer_0001",
        common    = "dr_shield_hammer_0002",
        rare      = "dr_shield_hammer_0016",
        exotic    = "dr_shield_hammer_0082",
        unique    = "dr_shield_hammer_1001"
    },
    dr_2h_axes = {
        plentiful = "dr_2h_axe_0001",
        common    = "dr_2h_axe_0002",
        rare      = "dr_2h_axe_0016",
        exotic    = "dr_2h_axe_0082",
        unique    = "dr_2h_axe_1001"
    },
    dr_2h_hammer = {
        plentiful = "dr_2h_hammer_0001",
        common    = "dr_2h_hammer_0002",
        rare      = "dr_2h_hammer_0016",
        exotic    = "dr_2h_hammer_0082",
        unique    = "dr_2h_hammer_1001"
    },
    dr_2h_picks = {
        plentiful = "dr_2h_pick_0001",
        common    = "dr_2h_pick_1001",
        rare      = "dr_2h_pick_2001",
        exotic    = "dr_2h_pick_3001",
        unique    = "dr_2h_pick_4001"
    },

    ww_1h_sword = {
        plentiful = "we_1h_sword_0001",
        common    = "we_1h_sword_0002",
        rare      = "we_1h_sword_0016",
        exotic    = "we_1h_sword_0082",
        unique    = "we_1h_sword_1001"
    },
    ww_dual_daggers = {
        plentiful = "we_dual_wield_daggers_0001",
        common    = "we_dual_wield_daggers_0002",
        rare      = "we_dual_wield_daggers_0016",
        exotic    = "we_dual_wield_daggers_0082",
        unique    = "we_dual_wield_daggers_1001"
    },
    ww_dual_swords = {
        plentiful = "we_dual_wield_swords_0001",
        common    = "we_dual_wield_swords_0002",
        rare      = "we_dual_wield_swords_0016",
        exotic    = "we_dual_wield_swords_0082",
        unique    = "we_dual_wield_swords_1001"
    },
    ww_sword_and_dagger = {
        plentiful = "we_dual_wield_sword_dagger_0001",
        common    = "we_dual_wield_sword_dagger_0002",
        rare      = "we_dual_wield_sword_dagger_0016",
        exotic    = "we_dual_wield_sword_dagger_0082",
        unique    = "we_dual_wield_sword_dagger_1001"
    },
    ww_2h_axe = {
        plentiful = "we_2h_axe_0001",
        common    = "we_2h_axe_1001",
        rare      = "we_2h_axe_2001",
        exotic    = "we_2h_axe_3001",
        unique    = "we_2h_axe_4001"
    },

    es_1h_sword = {
        plentiful = "es_1h_sword_0001",
        common    = "es_1h_sword_0002",
        rare      = "es_1h_sword_0016",
        exotic    = "es_1h_sword_0082",
        unique    = "es_1h_sword_1001"
    },
    es_1h_mace = {
        plentiful = "es_1h_mace_0001",
        common    = "es_1h_mace_0002",
        rare      = "es_1h_mace_0016",
        exotic    = "es_1h_mace_0082",
        unique    = "es_1h_mace_1001"
    },
    es_1h_sword_shield = {
        plentiful = "es_sword_shield_0001",
        common    = "es_sword_shield_0002",
        rare      = "es_sword_shield_0016",
        exotic    = "es_sword_shield_0082",
        unique    = "es_sword_shield_1001"
    },
    es_1h_mace_shield = {
        plentiful = "es_mace_shield_0001",
        common    = "es_mace_shield_0002",
        rare      = "es_mace_shield_0016",
        exotic    = "es_mace_shield_0082",
        unique    = "es_mace_shield_1001"
    },
    es_2h_sword = {
        plentiful = "es_2h_sword_0001",
        common    = "es_2h_sword_0002",
        rare      = "es_2h_sword_0016",
        exotic    = "es_2h_sword_0082",
        unique    = "es_2h_sword_1001"
    },
    es_2h_war_hammer = {
        plentiful = "es_2h_hammer_0001",
        common    = "es_2h_hammer_0002",
        rare      = "es_2h_hammer_0016",
        exotic    = "es_2h_hammer_0082",
        unique    = "es_2h_hammer_1001"
    },
    es_2h_sword_exec = {
        plentiful = "es_2h_sword_exe_0001",
        common    = "es_2h_sword_exe_1001",
        rare      = "es_2h_sword_exe_2001",
        exotic    = "es_2h_sword_exe_3036",
        unique    = "es_2h_sword_exe_4001"
    }
}

ChangeWeaponModels.ranged_weapons_ids = {
    wh_brace_of_pisols = {
        plentiful = "wh_brace_of_pistols_0001",
        common    = "wh_brace_of_pistols_0002",
        rare      = "wh_brace_of_pistols_0013",
        exotic    = "wh_brace_of_pistols_0066",
        unique    = "wh_brace_of_pistols_1001"
    },
    wh_repeating_pistol = {
        plentiful = "wh_repeating_pistols_0001",
        common    = "wh_repeating_pistols_0002",
        rare      = "wh_repeating_pistols_0013",
        exotic    = "wh_repeating_pistols_0067",
        unique    = "wh_repeating_pistols_1001"
    },
    wh_crossbow = {
        plentiful = "wh_crossbow_0001",
        common    = "wh_crossbow_0002",
        rare      = "wh_crossbow_0011",
        exotic    = "wh_crossbow_0046",
        unique    = "wh_crossbow_1001"
    },
    wh_repeating_crossbow = {
        plentiful = nil,
        common    = nil,
        rare      = "wh_crossbow_repeater_2001",
        exotic    = "wh_crossbow_repeater_3001",
        unique    = "wh_crossbow_repeater_4001"
    },

    bw_staff_geiser = {
        plentiful = "bw_skullstaff_geiser_0001",
        common    = "bw_skullstaff_geiser_0002",
        rare      = "bw_skullstaff_geiser_0011",
        exotic    = "bw_skullstaff_geiser_0043",
        unique    = "bw_skullstaff_geiser_1001"
    },
    bw_staff_beam = {
        plentiful = "bw_skullstaff_beam_0001",
        common    = "bw_skullstaff_beam_0002",
        rare      = "bw_skullstaff_beam_0011",
        exotic    = "bw_skullstaff_beam_0046",
        unique    = "bw_skullstaff_beam_1001"
    },
    bw_staff_spear = {
        plentiful = "bw_skullstaff_spear_0001",
        common    = "bw_skullstaff_spear_0002",
        rare      = "bw_skullstaff_spear_0009",
        exotic    = "bw_skullstaff_spear_0029",
        unique    = "bw_skullstaff_spear_1001"
    },
    bw_staff_firball = {
        plentiful = "bw_skullstaff_fireball_0001",
        common    = "bw_skullstaff_fireball_0002",
        rare      = "bw_skullstaff_fireball_0011",
        exotic    = "bw_skullstaff_fireball_0043",
        unique    = "bw_skullstaff_fireball_1001"
    },

    dr_handgun = {
        plentiful = "dr_handgun_0001",
        common    = "dr_handgun_0002",
        rare      = "dr_handgun_0015",
        exotic    = "dr_handgun_0089",
        unique    = "dr_handgun_1001"
    },
    dr_grudgeraker = {
        plentiful = "dr_rakegun_0001",
        common    = "dr_rakegun_0002",
        rare      = "dr_rakegun_0012",
        exotic    = "dr_rakegun_0056",
        unique    = "dr_rakegun_1001"
    },
    dr_crossbow = {
        plentiful = "dr_crossbow_0001",
        common    = "dr_crossbow_0002",
        rare      = "dr_crossbow_0011",
        exotic    = "dr_crossbow_0046",
        unique    = "dr_crossbow_1001"
    },
    dr_drakefire_pistols = {
        plentiful = nil,
        common    = nil,
        _rare     = "dr_drake_pistol_0001",
        rare      = "dr_drake_pistol_0016",
        exotic    = "dr_drake_pistol_0042",
        unique    = "dr_drake_pistol_1001"
    },

    ww_shortbow = {
        plentiful = "we_shortbow_0001",
        common    = "we_shortbow_0002",
        rare      = "we_shortbow_0014",
        exotic    = "we_shortbow_0076",
        unique    = "we_shortbow_1001"
    },
    ww_hagbane = {
        plentiful = "we_shortbow_hagbane_0001",
        common    = "we_shortbow_hagbane_0002",
        rare      = "we_shortbow_hagbane_0014",
        exotic    = "we_shortbow_hagbane_0076",
        unique    = "we_shortbow_hagbane_1001"
    },
    ww_longbow = {
        plentiful = "we_longbow_0001",
        common    = "we_longbow_0002",
        rare      = "we_longbow_0014",
        exotic    = "we_longbow_0076",
        unique    = "we_longbow_1001"
    },
    ww_trueflight = {
        plentiful = "we_longbow_trueflight_0001",
        common    = "we_longbow_trueflight_0002",
        rare      = "we_longbow_trueflight_0014",
        exotic    = "we_longbow_trueflight_0076",
        unique    = "we_longbow_trueflight_1001"
    },

    es_handgun = {
        plentiful = "es_handgun_0001",
        common    = "es_handgun_0002",
        rare      = "es_handgun_0015",
        exotic    = "es_handgun_0089",
        unique    = "es_handgun_1001"
    },
    es_blunderbuss = {
        plentiful = "es_blunderbuss_0001",
        common    = "es_blunderbuss_0002",
        rare      = "es_blunderbuss_0011",
        exotic    = "es_blunderbuss_0046",
        unique    = "es_blunderbuss_1001"
    },
    es_repeating_handgun = {
        plentiful = "es_repeating_handgun_0001",
        common    = "es_repeating_handgun_0002",
        rare      = "es_repeating_handgun_0016",
        exotic    = "es_repeating_handgun_0100",
        unique    = "es_repeating_handgun_1001"
    }
}

ChangeWeaponModels.weapon_units_lookup = {}

for _,weapons in ipairs({ChangeWeaponModels.melee_weapons_ids, ChangeWeaponModels.ranged_weapons_ids}) do
    for weapon_type,weapon_rarities in pairs(weapons) do
        for weapon_rarity,weapon_name in pairs(weapon_rarities) do
            if weapon_name then
                local weapon_table = ItemMasterList[weapon_name]
                local hand_unit = weapon_table.right_hand_unit

                if not hand_unit then
                    hand_unit = weapon_table.left_hand_unit
                end

                if hand_unit then
                    if ChangeWeaponModels.weapon_units_lookup[hand_unit] == nil then
                        ChangeWeaponModels.weapon_units_lookup[hand_unit] = {}
                    end

                    local weapon_units_lookup = ChangeWeaponModels.weapon_units_lookup[hand_unit]

                    weapon_units_lookup[weapon_name] = true
                end
            end
        end
    end
end

for hero_name,hero_weapons in pairs(ChangeWeaponModels.melee_weapons_names) do
    local hero_info = ChangeWeaponModels.hero_infos[hero_name]
    local hero_weapons_config = {}

    for weapon_id,weapon_name in pairs(hero_weapons) do
        hero_weapons_config[#hero_weapons_config + 1] = "cb_melee_weapons_"..weapon_id
    end

    ChangeWeaponModels.SETTINGS[hero_info.menu.."_MELEE"] = {
        ["save"] = "cb_melee_weapons_"..hero_info.config,
        ["widget_type"] = "checkbox",
        ["text"] = hero_name,
        ["tooltip"] =  hero_name.."\n",
        ["default"] = false,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = hero_weapons_config
            },
            {
                true,
                mode = "show",
                options = hero_weapons_config
            },
        }
    }

    for weapon_id,weapon_name in pairs(hero_weapons) do
        local rarities = {}

        for rarity_id,rarity_name in pairs(ChangeWeaponModels.weapon_rarities) do
            if ChangeWeaponModels.melee_weapons_ids[weapon_id][rarity_id] ~= nil then
                rarities[#rarities + 1] = "cb_melee_weapons_"..weapon_id.."_"..rarity_id
            end
        end

        ChangeWeaponModels.SETTINGS[hero_info.menu.."_MELEE_"..weapon_id] = {
            ["save"] = "cb_melee_weapons_"..weapon_id,
            ["widget_type"] = "checkbox",
            ["text"] = weapon_name,
            ["tooltip"] = weapon_name.."\n",
            ["default"] = false,
            ["hide_options"] = {
                {
                    false,
                    mode = "hide",
                    options = rarities
                },
                {
                    true,
                    mode = "show",
                    options = rarities
                },
            }
        }

        for rarity_id,rarity_name in pairs(ChangeWeaponModels.weapon_rarities) do
            if ChangeWeaponModels.melee_weapons_ids[weapon_id][rarity_id] ~= nil then
                local rarities = {}
                local default_idx = 1

                for i,rarity_lookup_name in ipairs(ChangeWeaponModels.weapon_rarities_lookup) do
                    if ChangeWeaponModels.melee_weapons_ids[weapon_id][rarity_lookup_name] ~= nil then
                        local rarity_index = #rarities + 1

                        if rarity_lookup_name == rarity_id then
                            default_idx = rarity_index
                        end

                        rarities[rarity_index] = {text = ChangeWeaponModels.weapon_rarities[rarity_lookup_name], value = i}
                    end
                end

                ChangeWeaponModels.SETTINGS[hero_info.menu.."_MELEE_"..weapon_id.."_"..rarity_id] = {
                    ["save"] = "cb_melee_weapons_"..weapon_id.."_"..rarity_id,
                    ["widget_type"] = "dropdown",
                    ["text"] = rarity_name,
                    ["tooltip"] = rarity_name.."\n",
                    ["value_type"] = "number",
                    ["options"] = rarities,
                    ["default"] = default_idx
                }
            end
        end
    end
end

for hero_name,hero_weapons in pairs(ChangeWeaponModels.ranged_weapons_names) do
    local hero_info = ChangeWeaponModels.hero_infos[hero_name]
    local hero_weapons_config = {}

    for weapon_id,weapon_name in pairs(hero_weapons) do
        hero_weapons_config[#hero_weapons_config + 1] = "cb_ranged_weapons_"..weapon_id
    end

    ChangeWeaponModels.SETTINGS[hero_info.menu.."_RANGED"] = {
        ["save"] = "cb_ranged_weapons_"..hero_info.config,
        ["widget_type"] = "checkbox",
        ["text"] = hero_name,
        ["tooltip"] =  hero_name.."\n",
        ["default"] = false,
        ["hide_options"] = {
            {
                false,
                mode = "hide",
                options = hero_weapons_config
            },
            {
                true,
                mode = "show",
                options = hero_weapons_config
            },
        }
    }

    for weapon_id,weapon_name in pairs(hero_weapons) do
        local rarities = {}

        for rarity_id,rarity_name in pairs(ChangeWeaponModels.weapon_rarities) do
            if ChangeWeaponModels.ranged_weapons_ids[weapon_id][rarity_id] ~= nil then
                rarities[#rarities + 1] = "cb_ranged_weapons_"..weapon_id.."_"..rarity_id
            end
        end

        ChangeWeaponModels.SETTINGS[hero_info.menu.."_RANGED_"..weapon_id] = {
            ["save"] = "cb_ranged_weapons_"..weapon_id,
            ["widget_type"] = "checkbox",
            ["text"] = weapon_name,
            ["tooltip"] = weapon_name.."\n",
            ["default"] = false,
            ["hide_options"] = {
                {
                    false,
                    mode = "hide",
                    options = rarities
                },
                {
                    true,
                    mode = "show",
                    options = rarities
                },
            }
        }

        for rarity_id,rarity_name in pairs(ChangeWeaponModels.weapon_rarities) do
            if ChangeWeaponModels.ranged_weapons_ids[weapon_id][rarity_id] ~= nil then
                local rarities = {}
                local default_idx = 1

                for i,rarity_lookup_name in ipairs(ChangeWeaponModels.weapon_rarities_lookup) do
                    if ChangeWeaponModels.ranged_weapons_ids[weapon_id][rarity_lookup_name] ~= nil then
                        local rarity_index = #rarities + 1

                        if rarity_lookup_name == rarity_id then
                            default_idx = rarity_index
                        end

                        rarities[rarity_index] = {text = ChangeWeaponModels.weapon_rarities[rarity_lookup_name], value = i}
                    end
                end

                ChangeWeaponModels.SETTINGS[hero_info.menu.."_RANGED_"..weapon_id.."_"..rarity_id] = {
                    ["save"] = "cb_ranged_weapons_"..weapon_id.."_"..rarity_id,
                    ["widget_type"] = "dropdown",
                    ["text"] = rarity_name,
                    ["tooltip"] = rarity_name.."\n",
                    ["value_type"] = "number",
                    ["options"] = rarities,
                    ["default"] = default_idx
                }
            end
        end
    end
end

ChangeWeaponModels.get = function(data)
    return Application.user_setting(data.save)
end

ChangeWeaponModels.get_item_original_units = function(item_data)
    local left_hand_unit = item_data.left_hand_unit
    local right_hand_unit = item_data.right_hand_unit
    local unit = item_data.unit

    if left_hand_unit or right_hand_unit or unit then
        local units = {
            left_hand_unit = left_hand_unit,
            right_hand_unit = right_hand_unit,
            unit = unit
        }

        return units
    end

    fassert(false, "no left hand or right hand unit defined for : " .. item.key)

    return
end

ChangeWeaponModels.get_hero_name_from_weapon_type = function(weapon_type)
    for hero_name,hero_weapons in pairs(ChangeWeaponModels.melee_weapons_names) do
        for weapon_id,weapon_name in pairs(hero_weapons) do
            if weapon_type == weapon_id then
                return hero_name
            end
        end
    end

    for hero_name,hero_weapons in pairs(ChangeWeaponModels.ranged_weapons_names) do
        for weapon_id,weapon_name in pairs(hero_weapons) do
            if weapon_type == weapon_id then
                return hero_name
            end
        end
    end

    return nil
end

ChangeWeaponModels.profile_packages = function(profile_index, packages_list, is_first_person)
    assert(packages_list)

    local first_person_value = nil

    if is_first_person then
        first_person_value = false
    end

    local profile = SPProfiles[profile_index]
    local profile_name = profile.display_name
    local slots = InventorySettings.slots
    local slots_n = #InventorySettings.slots

    for i = 1, slots_n, 1 do
        local slot = InventorySettings.slots[i]
        local slot_name = slot.name
        local slot_category = slot.category
        local item_data = ItemHelper.get_loadout_item(slot_name, profile)

        if item_data or false then
            local item_template = BackendUtils.get_item_template(item_data)
            local item_units = ChangeWeaponModels.get_item_original_units(item_data)

            if slot_category == "weapon" then
                local left_hand_unit_name = item_units.left_hand_unit

                if left_hand_unit_name then
                    packages_list[left_hand_unit_name] = first_person_value
                    packages_list[left_hand_unit_name .. "_3p"] = false
                end

                local right_hand_unit_name = item_units.right_hand_unit

                if right_hand_unit_name then
                    packages_list[right_hand_unit_name] = first_person_value
                    packages_list[right_hand_unit_name .. "_3p"] = false
                end

                local actions = item_template.actions

                for action_name, sub_actions in pairs(actions) do
                    for sub_action_name, sub_action_data in pairs(sub_actions) do
                        local projectile_info = sub_action_data.projectile_info

                        if projectile_info then
                            if projectile_info.projectile_unit_name then
                                packages_list[projectile_info.projectile_unit_name] = false
                            end

                            if projectile_info.dummy_linker_unit_name then
                                packages_list[projectile_info.dummy_linker_unit_name] = false
                            end

                            if projectile_info.dummy_linker_broken_units then
                                for unit_name, unit in pairs(projectile_info.dummy_linker_broken_units) do
                                    packages_list[unit] = false
                                end
                            end
                        end
                    end
                end

                local ammo_data = item_template.ammo_data

                if ammo_data then
                    if ammo_data.ammo_unit then
                        packages_list[ammo_data.ammo_unit] = first_person_value
                    end

                    if ammo_data.ammo_unit_3p then
                        packages_list[ammo_data.ammo_unit_3p] = false
                    end
                end
            elseif slot_category == "attachment" then
                packages_list[item_units.unit] = false
            else
                error("InventoryPackageSynchronizerClient unknown template_type: " .. template_type)
            end
        end
    end

    local profile_name = profile.display_name
    local skin_settings = Managers.unlock:get_skin_settings(profile_name)
    local units = skin_settings.units
    local third_person_units = units.third_person

    if is_first_person then
        local first_person_units = units.first_person
        packages_list[first_person_units.first_person] = false
        packages_list[first_person_units.first_person_bot] = false
        packages_list[third_person_units.third_person] = false
        packages_list[third_person_units.third_person_bot] = false
    else
        packages_list[third_person_units.third_person_husk] = false
    end

    local first_person_attachment = skin_settings.first_person_attachment

    if is_first_person then
        packages_list[first_person_attachment.unit] = false
    end

    return packages_list
end

ChangeWeaponModels.rebuild_unit_list = function(package_list, add_units)
    for unit_name,_ in pairs(add_units) do
        package_list[unit_name] = true
    end

    local new_list = {}
    local added = 0

    for unit_name,_ in pairs(package_list) do
        added = added + 1
        new_list[added] = NetworkLookup.inventory_packages[unit_name]
    end

    return new_list
end

ChangeWeaponModels.remove_items_units = function(package_list, remove_items)
    for _,item_data in ipairs(remove_items) do
        local item_units = ChangeWeaponModels.get_item_original_units(item_data)

        local left_hand_unit_name = item_units.left_hand_unit

        if left_hand_unit_name then
            package_list[left_hand_unit_name] = nil
            package_list[left_hand_unit_name .. "_3p"] = nil
        end

        local right_hand_unit_name = item_units.right_hand_unit

        if right_hand_unit_name then
            package_list[right_hand_unit_name] = nil
            package_list[right_hand_unit_name .. "_3p"] = nil
        end
    end

    return
end

ChangeWeaponModels.get_items_units = function(items)
    local units_count = 0
    local units = {}

    for _,item in pairs(items) do
        local item_data = item.item_data
        local hero_name = ChangeWeaponModels.get_hero_name_from_weapon_type(item_data.item_type)

        if hero_name then
            local hero_info = ChangeWeaponModels.hero_infos[hero_name]
            local weapon_use_type = ChangeWeaponModels.weapons_use_types[hero_name][item_data.item_type]
            local option_name = hero_info.menu.."_"..weapon_use_type.."_"..item_data.item_type.."_"..item_data.rarity
            local option_value = ChangeWeaponModels.get(ChangeWeaponModels.SETTINGS[option_name])
            local target_rarity = ChangeWeaponModels.weapon_rarities_lookup[option_value]
            local target_weapon = nil

            if weapon_use_type == "MELEE" then
                target_weapon = ChangeWeaponModels.melee_weapons_ids[item_data.item_type][target_rarity]
            else
                target_weapon = ChangeWeaponModels.ranged_weapons_ids[item_data.item_type][target_rarity]
            end

            if target_weapon then
                local target_weapon_table = nil

                if target_rarity == item_data.rarity then
                    target_weapon_table = item_data
                else
                    target_weapon_table = ItemMasterList[target_weapon]
                end

                local item_units = ChangeWeaponModels.get_item_original_units(target_weapon_table)

                local left_hand_unit_name = item_units.left_hand_unit

                if left_hand_unit_name then
                    if item.has_first_person then
                        units_count = units_count + 1
                        units[left_hand_unit_name] = true
                    end
                    if item.has_third_person then
                        units_count = units_count + 1
                        units[left_hand_unit_name .. "_3p"] = true
                    end
                end

                local right_hand_unit_name = item_units.right_hand_unit

                if right_hand_unit_name then
                    if item.has_first_person then
                        units_count = units_count + 1
                        units[right_hand_unit_name] = true
                    end
                    if item.has_third_person then
                        units_count = units_count + 1
                        units[right_hand_unit_name .. "_3p"] = true
                    end
                end
            end
        end
    end

    return units_count, units
end

ChangeWeaponModels.find_items_from_unit_names = function(unit_names)
    local items = {}
    local original_items = {}

    for unit_name,_ in pairs(unit_names) do
        local item_names = ChangeWeaponModels.weapon_units_lookup[unit_name]
        local has_first_person = false
        local has_third_person = false

        if not item_names and string.sub(unit_name, -3) == "_3p" then
            local third_person_unit_name = string.sub(unit_name, 1, -4)
            item_names = ChangeWeaponModels.weapon_units_lookup[third_person_unit_name]
            has_third_person = true
        else
            has_first_person = true
        end

        if item_names then
            for item_name,_ in pairs(item_names) do
                local item_data = ItemMasterList[item_name]
                local existing_item = items[item_name]

                if existing_item then
                    if existing_item.has_first_person then
                        has_first_person = true
                    end
                    if existing_item.has_third_person then
                        has_third_person = true
                    end
                end

                items[item_name] = {
                    item_data = item_data,
                    has_first_person = has_first_person,
                    has_third_person = has_third_person
                }
                original_items[#original_items + 1] = item_data
            end
        end
    end

    return items, original_items
end

ChangeWeaponModels.build_new_package_list = function(package_list)
    local package_list_names = {}

    for _,value in ipairs(package_list) do
        local package_name = NetworkLookup.inventory_packages[value]
        package_list_names[package_name] = true
    end

    local items, old_items = ChangeWeaponModels.find_items_from_unit_names(package_list_names)
    local new_units_count, new_units = ChangeWeaponModels.get_items_units(items)

    if not new_units or new_units_count < 1 then
        return package_list
    end

    ChangeWeaponModels.remove_items_units(package_list_names, old_items)

    local new_package_list = ChangeWeaponModels.rebuild_unit_list(package_list_names, new_units)

    return new_package_list
end

ChangeWeaponModels.get_swapped_weapon_units = function(item_data)
    if item_data.item_type and item_data.rarity then
        local hero_name = ChangeWeaponModels.get_hero_name_from_weapon_type(item_data.item_type)

        if hero_name then
            local hero_info = ChangeWeaponModels.hero_infos[hero_name]
            local weapon_use_type = ChangeWeaponModels.weapons_use_types[hero_name][item_data.item_type]
            local option_name = hero_info.menu.."_"..weapon_use_type.."_"..item_data.item_type.."_"..item_data.rarity
            local option_value = ChangeWeaponModels.get(ChangeWeaponModels.SETTINGS[option_name])

            if option_value ~= nil then
                local target_rarity = ChangeWeaponModels.weapon_rarities_lookup[option_value]

                if item_data.rarity ~= target_rarity then
                    local target_weapon = nil

                    if weapon_use_type == "MELEE" then
                        target_weapon = ChangeWeaponModels.melee_weapons_ids[item_data.item_type][target_rarity]
                    else
                        target_weapon = ChangeWeaponModels.ranged_weapons_ids[item_data.item_type][target_rarity]
                    end

                    if target_weapon then
                        local target_weapon_table = ItemMasterList[target_weapon]

                        return item_data.right_hand_unit, item_data.left_hand_unit, target_weapon_table.right_hand_unit, target_weapon_table.left_hand_unit
                    end
                end
            end
        end
    end

    return item_data.right_hand_unit, item_data.left_hand_unit, nil, nil
end

-- ####################################################################################################################
-- ##### Option #######################################################################################################
-- ####################################################################################################################
ChangeWeaponModels.create_options = function()
    Mods.option_menu:add_group("change_melee_weapons", "Change Melee Weapons")
    Mods.option_menu:add_group("change_ranged_weapons", "Change Ranged Weapons")

    for i,hero_name in ipairs(ChangeWeaponModels.heroes_lookup) do
        local hero_info = ChangeWeaponModels.hero_infos[hero_name]

        Mods.option_menu:add_item("change_melee_weapons", ChangeWeaponModels.SETTINGS[hero_info.menu.."_MELEE"], true)

        for j,weapon_id in pairs(ChangeWeaponModels.melee_weapons_lookup[hero_name]) do
            Mods.option_menu:add_item("change_melee_weapons", ChangeWeaponModels.SETTINGS[hero_info.menu.."_MELEE_"..weapon_id])

            for k,rarity_id in ipairs(ChangeWeaponModels.weapon_rarities_lookup) do
                if ChangeWeaponModels.melee_weapons_ids[weapon_id][rarity_id] ~= nil then
                    Mods.option_menu:add_item("change_melee_weapons", ChangeWeaponModels.SETTINGS[hero_info.menu.."_MELEE_"..weapon_id.."_"..rarity_id])
                end
            end
        end

        Mods.option_menu:add_item("change_ranged_weapons", ChangeWeaponModels.SETTINGS[hero_info.menu.."_RANGED"], true)

        for j,weapon_id in pairs(ChangeWeaponModels.ranged_weapons_lookup[hero_name]) do
            Mods.option_menu:add_item("change_ranged_weapons", ChangeWeaponModels.SETTINGS[hero_info.menu.."_RANGED_"..weapon_id])

            for k,rarity_id in ipairs(ChangeWeaponModels.weapon_rarities_lookup) do
                if ChangeWeaponModels.ranged_weapons_ids[weapon_id][rarity_id] ~= nil then
                    Mods.option_menu:add_item("change_ranged_weapons", ChangeWeaponModels.SETTINGS[hero_info.menu.."_RANGED_"..weapon_id.."_"..rarity_id])
                end
            end
        end
    end
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

Mods.hook.set(mod_name, "BackendUtils.get_item_units", function(func, item_data)
    local unit = item_data.unit

    local original_right_hand_unit, original_left_hand_unit, custom_right_hand_unit, custom_left_hand_unit = ChangeWeaponModels.get_swapped_weapon_units(item_data)

    local units = {
        right_hand_unit = original_right_hand_unit,
        left_hand_unit = original_left_hand_unit,
        unit = unit
    }

    if custom_right_hand_unit or custom_left_hand_unit then
        units.right_hand_unit = custom_right_hand_unit
        units.left_hand_unit = custom_left_hand_unit
    end

    if original_right_hand_unit or original_left_hand_unit or units.unit then
        return units
    end

    fassert(false, "no left hand or right hand unit defined for : " .. item.key)

    return
end)

Mods.hook.set(mod_name, "InventoryPackageSynchronizerClient.build_inventory_lists", function(func, self, profile_index)
    if not profile_index or profile_index == 0 then
        return empty_table, empty_table
    end

    local inventory_list = ChangeWeaponModels.profile_packages(profile_index, FrameTable.alloc_table(), false)
    local inventory_list_first_player = ChangeWeaponModels.profile_packages(profile_index, FrameTable.alloc_table(), true)

    return inventory_list, inventory_list_first_player
end)

Mods.hook.set(mod_name, "InventoryPackageSynchronizerClient.rpc_server_set_inventory_packages", function(func, self, sender, inventory_sync_id, inventory_package_list)
    inventory_package_list = ChangeWeaponModels.build_new_package_list(inventory_package_list)

    return func(self, sender, inventory_sync_id, inventory_package_list)
end)

-- ##### Start ########################################################################################################
ChangeWeaponModels.create_options()
