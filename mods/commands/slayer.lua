local local_player = Managers.player

if not local_player.is_server then
	EchoConsole("You must be the host to activate mods.")
	return
end

if Managers.state.game_mode == nil or (Managers.state.game_mode._game_mode_key ~= "inn" and local_player.is_server) then
	EchoConsole("You must be in the inn to change the difficulty!")
	return
end

local function count_event_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
end

local function count_breed(breed_name)
	return Managers.state.conflict:count_units_by_breed(breed_name)
end

TerrorEventBlueprints.survival_magnus_deathwish_wave3_1 = {
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-45,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				85,
				-12,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 25
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				14,
				24,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-45,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		},
		{
			"control_specials",
			enable = false
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_wave3_2 = {
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				14,
				24,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_main"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				85,
				-12,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_main"
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				70,
				30,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_slaves_large"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		},
		{
			"control_specials",
			enable = false
		}
}

TerrorEventBlueprints.survival_fall_deathwish_wave3_1 = {
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-55,
				25
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				90,
				0,
				18
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 25
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				-20,
				-5,
				20
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-55,
				25
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		},
		{
			"control_specials",
			enable = false
		}
}

TerrorEventBlueprints.survival_fall_deathwish_wave3_2 = {
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				-20,
				-5,
				20
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_main"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				90,
				0,
				18
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_main"
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				20,
				50,
				25
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_slaves_large"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		},
		{
			"control_specials",
			enable = false
		}
}

TerrorEventBlueprints.survival_deathwish_wave4 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_slaves_large"
		},
		{
			"delay",
			duration = {
				12,
				18
			}
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = {
				20,
				25
			}
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_gutter_runner") < 1 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1 and count_event_breed("skaven_ratling_gunner") < 1 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_sub13filler_1 = {
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_flush"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_slaves_large"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 20
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_flush"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		},
		{
			"control_specials",
			enable = false
		}
}

TerrorEventBlueprints.survival_deathwish_sub13filler_2 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 40
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 40
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_gutter_runner") < 1 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_sub13filler_3 = {
		{
			"control_specials",
			enable = true
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 0.5
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 30
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") == 0 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_clan_rat") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}

}

TerrorEventBlueprints.survival_deathwish_sub13filler_4 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 5
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 65,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") == 0 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_slaves_large"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") == 0 and count_event_breed("skaven_gutter_runner") == 0 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_clan_rat") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_sub13filler_5 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_slaves_large"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"delay",
			duration = {
				12,
				18
			}
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 3
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_poison_wind_globadier") < 1 and count_event_breed("skaven_ratling_gunner") < 1 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_sub13filler_6 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_slaves_large"
		},
		{
			"delay",
			duration = {
				12,
				18
			}
		},
		{
			"spawn",
			1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_pack_master"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_pack_master"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = {
				20,
				25
			}
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_flank"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_gutter_runner"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_gutter_runner") < 1 and count_event_breed("skaven_storm_vermin_commander") == 0
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_wave7 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_gutter_runner"
		},
				{
			"delay",
			duration = 10
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_in",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_stormvermin"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") == 0 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_gutter_runner") == 0 and count_event_breed("skaven_pack_master") == 0
			end
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "spawner_flush_out",
			composition_type = "event_survival_main"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") == 0 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_clan_rat") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}

}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_north = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				70,
				30,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_north"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_south = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-45,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_south"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_east = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				85,
				-12,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_east"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_west = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				14,
				24,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_west"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_north = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-55,
				25
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_north"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_south = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				20,
				50,
				25
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_south"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_east = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				-20,
				-5,
				20
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_east"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_west = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				90,
				0,
				18
			}
		},
		{
			"flow_event",
			flow_event_name = "survival_direction_west"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_north_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				70,
				30,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_south_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-45,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_east_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				85,
				-12,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_magnus_deathwish_from_the_west_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				14,
				24,
				15
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_north_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				25,
				-55,
				25
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_b",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_b",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_south_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				20,
				50,
				25
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_d",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_d",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_east_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				-20,
				-5,
				20
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_c",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_fall_deathwish_from_the_west_silent = {
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"control_specials",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger",
			optional_pos = {
				90,
				0,
				18
			}
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_pack"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_pack_master"
		},
		{
			"delay",
			duration = 1
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "spawner_a",
			composition_type = "event_survival_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 25
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn_a",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") == 0 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_wave13 = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 150,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") == 0 and count_event_breed("skaven_ratling_gunner") == 0 and count_event_breed("skaven_gutter_runner") == 0 and count_event_breed("skaven_pack_master") == 0 and count_event_breed("skaven_rat_ogre") == 0
			end
		},
		{
			"delay",
			duration = 30
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_pack_master"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_ratling_gunner"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_gutter_runner") < 1 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

TerrorEventBlueprints.survival_deathwish_bonus_wave = {
		{
			"control_specials",
			enable = false
		},
		{
			"set_master_event_running",
			name = "survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_special"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},	
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},	
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},	
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},	
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn_at_raw",
			spawner_id = "boss_spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_gutter_runner") < 1 and count_event_breed("skaven_pack_master") < 1 and count_event_breed("skaven_poison_wind_globadier") < 1 and count_event_breed("skaven_ratling_gunner") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "survival_wave_complete"
		}
}

if OriginalTerrorEventBlueprints then
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_wave3_1 = TerrorEventBlueprints.survival_magnus_deathwish_wave3_1
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_wave3_2 = TerrorEventBlueprints.survival_magnus_deathwish_wave3_2
	OriginalTerrorEventBlueprints.survival_fall_deathwish_wave3_1 = TerrorEventBlueprints.survival_fall_deathwish_wave3_1
	OriginalTerrorEventBlueprints.survival_fall_deathwish_wave3_2 = TerrorEventBlueprints.survival_fall_deathwish_wave3_2
	OriginalTerrorEventBlueprints.survival_deathwish_wave4 = TerrorEventBlueprints.survival_deathwish_wave4
	OriginalTerrorEventBlueprints.survival_deathwish_sub13filler_1 = TerrorEventBlueprints.survival_deathwish_sub13filler_1
	OriginalTerrorEventBlueprints.survival_deathwish_sub13filler_2 = TerrorEventBlueprints.survival_deathwish_sub13filler_2
	OriginalTerrorEventBlueprints.survival_deathwish_sub13filler_3 = TerrorEventBlueprints.survival_deathwish_sub13filler_3
	OriginalTerrorEventBlueprints.survival_deathwish_sub13filler_4 = TerrorEventBlueprints.survival_deathwish_sub13filler_4
	OriginalTerrorEventBlueprints.survival_deathwish_sub13filler_5 = TerrorEventBlueprints.survival_deathwish_sub13filler_5
	OriginalTerrorEventBlueprints.survival_deathwish_sub13filler_6 = TerrorEventBlueprints.survival_deathwish_sub13filler_6
	OriginalTerrorEventBlueprints.survival_deathwish_wave7 = TerrorEventBlueprints.survival_deathwish_wave7
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_north = TerrorEventBlueprints.survival_magnus_deathwish_from_the_north
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_south = TerrorEventBlueprints.survival_magnus_deathwish_from_the_south
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_east = TerrorEventBlueprints.survival_magnus_deathwish_from_the_east
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_west = TerrorEventBlueprints.survival_magnus_deathwish_from_the_west
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_north = TerrorEventBlueprints.survival_fall_deathwish_from_the_north
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_south = TerrorEventBlueprints.survival_fall_deathwish_from_the_south
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_east = TerrorEventBlueprints.survival_fall_deathwish_from_the_east
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_west = TerrorEventBlueprints.survival_fall_deathwish_from_the_west
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_north_silent = TerrorEventBlueprints.survival_magnus_deathwish_from_the_north_silent
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_south_silent = TerrorEventBlueprints.survival_magnus_deathwish_from_the_south_silent
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_east_silent = TerrorEventBlueprints.survival_magnus_deathwish_from_the_east_silent
	OriginalTerrorEventBlueprints.survival_magnus_deathwish_from_the_west_silent = TerrorEventBlueprints.survival_magnus_deathwish_from_the_west_silent
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_north_silent = TerrorEventBlueprints.survival_fall_deathwish_from_the_north_silent
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_south_silent = TerrorEventBlueprints.survival_fall_deathwish_from_the_south_silent
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_east_silent = TerrorEventBlueprints.survival_fall_deathwish_from_the_east_silent
	OriginalTerrorEventBlueprints.survival_fall_deathwish_from_the_west_silent = TerrorEventBlueprints.survival_fall_deathwish_from_the_west_silent
	OriginalTerrorEventBlueprints.survival_deathwish_wave13 = TerrorEventBlueprints.survival_deathwish_wave13
	OriginalTerrorEventBlueprints.survival_deathwish_bonus_wave = TerrorEventBlueprints.survival_deathwish_bonus_wave
end

if not slayertoken then
	slayertoken = true

	OriginalMagnusWaveset = table.clone(SurvivalSettings.survival_magnus_01.waves)
	OriginalFallWaveset = table.clone(SurvivalSettings.dlc_01.waves)

	--Wave 1
	SurvivalSettings.survival_magnus_01.waves[27] = {
		"deathwish_wave1",
		reset = {
			"deathwish_wave1"
		}
	}

	SurvivalSettings.dlc_01.waves[27] = {
		"deathwish_wave1",
		reset = {
			"deathwish_wave1"
		}
	}

	SurvivalSettings.templates.deathwish_wave1 = {
		"survival_deathwish_wave_1"
	}

	WeightedRandomTerrorEvents.survival_deathwish_wave_1 = {
		"survival_specials_a",
		1,
		"survival_specials_b",
		1
	}

	--Wave 2
	SurvivalSettings.survival_magnus_01.waves[28] = {
		"deathwish_wave2",
		reset = {
			"deathwish_wave2"
		}
	}

	SurvivalSettings.dlc_01.waves[28] = {
		"deathwish_wave2",
		reset = {
			"deathwish_wave2"
		}
	}

	SurvivalSettings.templates.deathwish_wave2 = {
		"survival_deathwish_wave_2"
	}

	WeightedRandomTerrorEvents.survival_deathwish_wave_2 = {
		"survival_cataclysm_specials_e",
		1
	}

	--Wave 3
	SurvivalSettings.survival_magnus_01.waves[29] = {
		"magnus_deathwish_wave3"
	}

	SurvivalSettings.dlc_01.waves[29] = {
		"fall_deathwish_wave3"
	}

	SurvivalSettings.templates.magnus_deathwish_wave3 = {
		"survival_magnus_deathwish_wave_3"
	}

	SurvivalSettings.templates.fall_deathwish_wave3 = {
		"survival_fall_deathwish_wave_3"
	}

	WeightedRandomTerrorEvents.survival_magnus_deathwish_wave_3 = {
		"survival_magnus_deathwish_wave3_1",
		1,
		"survival_magnus_deathwish_wave3_2",
		1
	}

	WeightedRandomTerrorEvents.survival_fall_deathwish_wave_3 = {
		"survival_fall_deathwish_wave3_1",
		1,
		"survival_fall_deathwish_wave3_2",
		1
	}

	--Wave 4
	SurvivalSettings.survival_magnus_01.waves[30] = {
		"deathwish_wave4",
		reset = {
			"deathwish_wave4"
		}
	}

	SurvivalSettings.dlc_01.waves[30] = {
		"deathwish_wave4",
		reset = {
			"deathwish_wave4"
		}
	}

	SurvivalSettings.templates.deathwish_wave4 = {
		"survival_deathwish_wave_4"
	}

	WeightedRandomTerrorEvents.survival_deathwish_wave_4 = {
		"survival_deathwish_wave4",
		1
	}

	--Sub 13 filler (Wave 5, 6, 8, 9 and 11)
	SurvivalSettings.survival_magnus_01.waves[31] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[32] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[34] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[35] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[37] = {
		"deathwish_sub13filler",
		reset = {
			"deathwish_sub13filler"
		}
	}

	SurvivalSettings.dlc_01.waves[31] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[32] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[34] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[35] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[37] = {
		"deathwish_sub13filler",
		reset = {
			"deathwish_sub13filler"
		}
	}

	SurvivalSettings.templates.deathwish_sub13filler = {
		"survival_deathwish_sub13_filler_1",
		"survival_deathwish_sub13_filler_2",
		"survival_deathwish_sub13_filler_3",
		"survival_deathwish_sub13_filler_4",
		"survival_deathwish_sub13_filler_5",
		"survival_deathwish_sub13_filler_6"
	}

	WeightedRandomTerrorEvents.survival_deathwish_sub13_filler_1 = {
		"survival_deathwish_sub13filler_1",
		1
	}

	WeightedRandomTerrorEvents.survival_deathwish_sub13_filler_2 = {
		"survival_deathwish_sub13filler_2",
		1
	}

	WeightedRandomTerrorEvents.survival_deathwish_sub13_filler_3 = {
		"survival_deathwish_sub13filler_3",
		1
	}

	WeightedRandomTerrorEvents.survival_deathwish_sub13_filler_4 = {
		"survival_deathwish_sub13filler_4",
		1
	}

	WeightedRandomTerrorEvents.survival_deathwish_sub13_filler_5 = {
		"survival_deathwish_sub13filler_5",
		1
	}

	WeightedRandomTerrorEvents.survival_deathwish_sub13_filler_6 = {
		"survival_deathwish_sub13filler_6",
		1
	}

	--Wave 7
	SurvivalSettings.survival_magnus_01.waves[33] = {
		"deathwish_wave7",
		reset = {
			"deathwish_wave7"
		}
	}

	SurvivalSettings.dlc_01.waves[33] = {
		"deathwish_wave7",
		reset = {
			"deathwish_wave7"
		}
	}

	SurvivalSettings.templates.deathwish_wave7 = {
		"survival_deathwish_wave_7"
	}

	WeightedRandomTerrorEvents.survival_deathwish_wave_7 = {
		"survival_deathwish_wave7",
		1
	}

	--From the X (Wave 10 and 12)
	SurvivalSettings.survival_magnus_01.waves[36] = {
		"magnus_deathwish_from_the_x_silent"
	}

	SurvivalSettings.survival_magnus_01.waves[38] = {
		"magnus_deathwish_from_the_x_silent",
		reset = {
			"magnus_deathwish_from_the_x_silent"
		}
	}

	SurvivalSettings.dlc_01.waves[36] = {
		"fall_deathwish_from_the_x_silent"
	}

	SurvivalSettings.dlc_01.waves[38] = {
		"fall_deathwish_from_the_x_silent",
		reset = {
			"fall_deathwish_from_the_x_silent"
		}
	}

	SurvivalSettings.templates.magnus_deathwish_from_the_x = {
		"survival_magnus_deathwish_from_the_x"
	}

	SurvivalSettings.templates.fall_deathwish_from_the_x = {
		"survival_fall_deathwish_from_the_x"
	}

	WeightedRandomTerrorEvents.survival_magnus_deathwish_from_the_x = {
		"survival_magnus_deathwish_from_the_north",
		1,
		"survival_magnus_deathwish_from_the_south",
		1,
		"survival_magnus_deathwish_from_the_east",
		1,
		"survival_magnus_deathwish_from_the_west",
		1
	}

	WeightedRandomTerrorEvents.survival_fall_deathwish_from_the_x = {
		"survival_fall_deathwish_from_the_north",
		1,
		"survival_fall_deathwish_from_the_south",
		1,
		"survival_fall_deathwish_from_the_east",
		1,
		"survival_fall_deathwish_from_the_west",
		1
	}

	SurvivalSettings.templates.magnus_deathwish_from_the_x_silent = {
		"survival_magnus_deathwish_from_the_x_silent"
	}

	SurvivalSettings.templates.fall_deathwish_from_the_x_silent = {
		"survival_fall_deathwish_from_the_x_silent"
	}

	WeightedRandomTerrorEvents.survival_magnus_deathwish_from_the_x_silent = {
		"survival_magnus_deathwish_from_the_north_silent",
		1,
		"survival_magnus_deathwish_from_the_south_silent",
		1,
		"survival_magnus_deathwish_from_the_east_silent",
		1,
		"survival_magnus_deathwish_from_the_west_silent",
		1
	}

	WeightedRandomTerrorEvents.survival_fall_deathwish_from_the_x_silent = {
		"survival_fall_deathwish_from_the_north_silent",
		1,
		"survival_fall_deathwish_from_the_south_silent",
		1,
		"survival_fall_deathwish_from_the_east_silent",
		1,
		"survival_fall_deathwish_from_the_west_silent",
		1
	}

	--Wave 13
	SurvivalSettings.survival_magnus_01.waves[39] = {
		"deathwish_wave_13",
		reset = {
			"deathwish_wave_13"
		}
	}

	SurvivalSettings.dlc_01.waves[39] = {
		"deathwish_wave_13",
		reset = {
			"deathwish_wave_13"
		}
	}

	SurvivalSettings.templates.deathwish_wave_13 = {
		"survival_deathwish_wave_13"
	}

	WeightedRandomTerrorEvents.survival_deathwish_wave_13 = {
		"survival_deathwish_wave13",
		1
	}

	--Bonus wave
	SurvivalSettings.survival_magnus_01.waves[40] = {
		"deathwish_bonus_wave"
	}

	SurvivalSettings.dlc_01.waves[40] = {
		"deathwish_bonus_wave"
	}

	SurvivalSettings.templates.deathwish_bonus_wave = {
		"survival_deathwish_bonus_wave"
	}

	WeightedRandomTerrorEvents.survival_deathwish_bonus_wave = {
		"survival_deathwish_bonus_wave",
		1
	}

	--Veteran
	SurvivalSettings.survival_magnus_01.waves[1] = {
		"deathwish_wave1",
		reset = {
			"deathwish_wave1"
		}
	}

	SurvivalSettings.dlc_01.waves[1] = {
		"deathwish_wave1",
		reset = {
			"deathwish_wave1"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[2] = {
		"deathwish_wave2",
		reset = {
			"deathwish_wave2"
		}
	}

	SurvivalSettings.dlc_01.waves[2] = {
		"deathwish_wave2",
		reset = {
			"deathwish_wave2"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[3] = {
		"magnus_deathwish_wave3",
		reset = {
			"magnus_deathwish_wave3"
		}
	}

	SurvivalSettings.dlc_01.waves[3] = {
		"fall_deathwish_wave3",
		reset = {
			"fall_deathwish_wave3"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[4] = {
		"deathwish_wave4",
		reset = {
			"deathwish_wave4"
		}
	}

	SurvivalSettings.dlc_01.waves[4] = {
		"deathwish_wave4",
		reset = {
			"deathwish_wave4"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[5] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[5] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[6] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[6] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[7] = {
		"deathwish_wave7",
		reset = {
			"deathwish_wave7"
		}
	}

	SurvivalSettings.dlc_01.waves[7] = {
		"deathwish_wave7",
		reset = {
			"deathwish_wave7"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[8] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[8] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[9] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[9] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[10] = {
		"magnus_deathwish_from_the_x"
	}

	SurvivalSettings.dlc_01.waves[10] = {
		"fall_deathwish_from_the_x"
	}

	SurvivalSettings.survival_magnus_01.waves[11] = {
		"deathwish_sub13filler",
		reset = {
			"deathwish_sub13filler"
		}
	}

	SurvivalSettings.dlc_01.waves[11] = {
		"deathwish_sub13filler",
		reset = {
			"deathwish_sub13filler"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[12] = {
		"magnus_deathwish_from_the_x_silent",
		reset = {
			"magnus_deathwish_from_the_x_silent"
		}
	}

	SurvivalSettings.dlc_01.waves[12] = {
		"fall_deathwish_from_the_x_silent",
		reset = {
			"fall_deathwish_from_the_x_silent"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[13] = {
		"deathwish_wave_13",
		reset = {
			"deathwish_wave_13"
		}
	}

	SurvivalSettings.dlc_01.waves[13] = {
		"deathwish_wave_13",
		reset = {
			"deathwish_wave_13"
		}
	}

	--champion
	SurvivalSettings.survival_magnus_01.waves[14] = {
		"deathwish_wave1",
		reset = {
			"deathwish_wave1"
		}
	}

	SurvivalSettings.dlc_01.waves[14] = {
		"deathwish_wave1",
		reset = {
			"deathwish_wave1"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[15] = {
		"deathwish_wave2",
		reset = {
			"deathwish_wave2"
		}
	}

	SurvivalSettings.dlc_01.waves[15] = {
		"deathwish_wave2",
		reset = {
			"deathwish_wave2"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[16] = {
		"magnus_deathwish_wave3",
		reset = {
			"magnus_deathwish_wave3"
		}
	}

	SurvivalSettings.dlc_01.waves[16] = {
		"fall_deathwish_wave3",
		reset = {
			"fall_deathwish_wave3"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[17] = {
		"deathwish_wave4",
		reset = {
			"deathwish_wave4"
		}
	}

	SurvivalSettings.dlc_01.waves[17] = {
		"deathwish_wave4",
		reset = {
			"deathwish_wave4"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[18] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[18] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[19] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[19] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[20] = {
		"deathwish_wave7",
		reset = {
			"deathwish_wave7"
		}
	}

	SurvivalSettings.dlc_01.waves[20] = {
		"deathwish_wave7",
		reset = {
			"deathwish_wave7"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[21] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[21] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[22] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.dlc_01.waves[22] = {
		"deathwish_sub13filler"
	}

	SurvivalSettings.survival_magnus_01.waves[23] = {
		"magnus_deathwish_from_the_x_silent"
	}

	SurvivalSettings.dlc_01.waves[23] = {
		"fall_deathwish_from_the_x_silent"
	}

	SurvivalSettings.survival_magnus_01.waves[24] = {
		"deathwish_sub13filler",
		reset = {
			"deathwish_sub13filler"
		}
	}

	SurvivalSettings.dlc_01.waves[24] = {
		"deathwish_sub13filler",
		reset = {
			"deathwish_sub13filler"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[25] = {
		"magnus_deathwish_from_the_x_silent",
		reset = {
			"magnus_deathwish_from_the_x_silent"
		}
	}

	SurvivalSettings.dlc_01.waves[25] = {
		"fall_deathwish_from_the_x_silent",
		reset = {
			"fall_deathwish_from_the_x_silent"
		}
	}

	SurvivalSettings.survival_magnus_01.waves[26] = {
		"deathwish_wave_13",
		reset = {
			"deathwish_wave_13"
		}
	}

	SurvivalSettings.dlc_01.waves[26] = {
		"deathwish_wave_13",
		reset = {
			"deathwish_wave_13"
		}
	}

	Mods.hook.set("Gamemodes", "StateInGameRunning.event_game_started", function(func, ...)
		func(...)
		if Managers.player.is_server and slayertoken then
			--23, 36 need to be silenced/unsilenced. Limitation due to being unable to fix 'once only' flow_event bug.
			if Managers.matchmaking.lobby:get_stored_lobby_data().difficulty == "survival_hard" then
				SurvivalSettings.survival_magnus_01.waves[23] = {
					"magnus_deathwish_from_the_x_silent"
				}

				SurvivalSettings.dlc_01.waves[23] = {
					"fall_deathwish_from_the_x_silent"
				}
				SurvivalSettings.survival_magnus_01.waves[36] = {
					"magnus_deathwish_from_the_x_silent"
				}

				SurvivalSettings.dlc_01.waves[36] = {
					"fall_deathwish_from_the_x_silent"
				}
			elseif Managers.matchmaking.lobby:get_stored_lobby_data().difficulty == "survival_harder" then
				SurvivalSettings.survival_magnus_01.waves[23] = {
					"magnus_deathwish_from_the_x"
				}

				SurvivalSettings.dlc_01.waves[23] = {
					"fall_deathwish_from_the_x"
				}
				SurvivalSettings.survival_magnus_01.waves[36] = {
					"magnus_deathwish_from_the_x_silent"
				}

				SurvivalSettings.dlc_01.waves[36] = {
					"fall_deathwish_from_the_x_silent"
				}
			elseif Managers.matchmaking.lobby:get_stored_lobby_data().difficulty == "survival_hardest" then
				SurvivalSettings.survival_magnus_01.waves[36] = {
					"magnus_deathwish_from_the_x"
				}

				SurvivalSettings.dlc_01.waves[36] = {
					"fall_deathwish_from_the_x"
				}
			end
		end
	end)

	--End waves

	Mods.hook.set("Gamemodes", "IngamePlayerListUI.set_difficulty_name", function(func, self, name)
		local content = self.headers.content
		if (name == "Veteran" or name == "Champion" or name == "Heroic") and slayertoken then
			if name == "Heroic" and deathwishtoken and mutationtoken then
				content.game_difficulty = "Deathwish Mutated Slayer's Oath"
			elseif name == "Heroic" and deathwishtoken then
				content.game_difficulty = "Deathwish Slayer's Oath"
			elseif mutationtoken then 
				content.game_difficulty = name .. " Mutated Slayer's Oath"
			else
				content.game_difficulty = name .. " Slayer's Oath"
			end
		elseif (name == "Easy" or name == "Normal" or name == "Hard" or name == "Nightmare" or name == "Cataclysm") and onslaughttoken then
			if name == "Cataclysm" and deathwishtoken and mutationtoken then
				content.game_difficulty = "Deathwish Mutated Onslaught"
			elseif name == "Cataclysm" and deathwishtoken then
				content.game_difficulty = "Deathwish Onslaught"
			elseif mutationtoken then 
				content.game_difficulty = name .. " Mutated Onslaught"
			else
				content.game_difficulty = name .. " Onslaught"
			end
		elseif (name == "Cataclysm" or name == "Heroic") and deathwishtoken then
			if mutationtoken then
				content.game_difficulty = "Deathwish Mutated"
			else
				content.game_difficulty = "Deathwish"
			end
		elseif mutationtoken and name ~= "" then
			content.game_difficulty = name .. " Mutated"
		else
			content.game_difficulty = name
		end
		return
	end)

	Mods.hook.front("Gamemodes", "IngamePlayerListUI.set_difficulty_name")

	Mods.hook.set("Gamemodes", "MatchmakingStateHostGame.host_game", function(func, self, next_level_key, difficulty, game_mode, private_game, required_progression)
		func(self, next_level_key, difficulty, game_mode, private_game, required_progression)

		local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
		local old_server_name = LobbyAux.get_unique_server_name()

		if (difficulty == "survival_hard" or difficulty == "survival_harder" or difficulty == "survival_hardest") and slayertoken then
			if difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
				lobby_data.unique_server_name = "||DW MUTATED SLAYER'S OATH|| " .. string.sub(old_server_name,1,15)
			elseif difficulty == "survival_hardest" and deathwishtoken then
				lobby_data.unique_server_name = "||Deathwish Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			elseif mutationtoken then 
				lobby_data.unique_server_name = "||Mutated Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Slayer's Oath|| " .. string.sub(old_server_name,1,17)
			end
		elseif (difficulty == "easy" or difficulty == "normal" or difficulty == "hard" or difficulty == "harder" or difficulty == "hardest") and onslaughttoken then
			if difficulty == "hardest" and deathwishtoken and mutationtoken then
				lobby_data.unique_server_name = "||DW MUTATED ONSLAUGHT|| " .. string.sub(old_server_name,1,17)
			elseif difficulty == "hardest" and deathwishtoken then
				lobby_data.unique_server_name = "||Deathwish Onslaught|| " .. string.sub(old_server_name,1,17)
			elseif mutationtoken then 
				lobby_data.unique_server_name = "||Mutated Onslaught|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Onslaught|| " .. string.sub(old_server_name,1,17)
			end
		elseif (difficulty == "hardest" or difficulty == "survival_hardest") and deathwishtoken then
			if mutationtoken then
				lobby_data.unique_server_name = "||MUTATED DEATHWISH|| " .. string.sub(old_server_name,1,17)
			else
				lobby_data.unique_server_name = "||Deathwish Difficulty|| " .. string.sub(old_server_name,1,17)
			end
		elseif mutationtoken then
			lobby_data.unique_server_name = "||Stormvermin Mutation|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = old_server_name
		end

		Managers.matchmaking.lobby:set_lobby_data(lobby_data)
	end)

	--Instant set lobby data
	if not deathwishtoken then
		deathwishtoken = false
	end

	if not mutationtoken then
		mutationtoken = false
	end

	if not onslaughttoken then
		onslaughttoken = false
	end

	local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
	local old_server_name = LobbyAux.get_unique_server_name()

	if (lobby_data.difficulty == "survival_hard" or lobby_data.difficulty == "survival_harder" or lobby_data.difficulty == "survival_hardest") and slayertoken then
		if lobby_data.difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
			lobby_data.unique_server_name = "||DW MUTATED SLAYER'S OATH|| " .. string.sub(old_server_name,1,15)
		elseif lobby_data.difficulty == "survival_hardest" and deathwishtoken then
			lobby_data.unique_server_name = "||Deathwish Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		elseif mutationtoken then 
			lobby_data.unique_server_name = "||Mutated Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		end
	elseif (lobby_data.difficulty == "easy" or lobby_data.difficulty == "normal" or lobby_data.difficulty == "hard" or lobby_data.difficulty == "harder" or lobby_data.difficulty == "hardest") and onslaughttoken then
		if lobby_data.difficulty == "hardest" and deathwishtoken and mutationtoken then
			lobby_data.unique_server_name = "||DW MUTATED ONSLAUGHT|| " .. string.sub(old_server_name,1,17)
		elseif lobby_data.difficulty == "hardest" and deathwishtoken then
			lobby_data.unique_server_name = "||Deathwish Onslaught|| " .. string.sub(old_server_name,1,17)
		elseif mutationtoken then 
			lobby_data.unique_server_name = "||Mutated Onslaught|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Onslaught|| " .. string.sub(old_server_name,1,17)
		end
	elseif (lobby_data.difficulty == "hardest" or lobby_data.difficulty == "survival_hardest") and deathwishtoken then
		if mutationtoken then
			lobby_data.unique_server_name = "||MUTATED DEATHWISH|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Deathwish Difficulty|| " .. string.sub(old_server_name,1,17)
		end
	elseif mutationtoken then
		lobby_data.unique_server_name = "||Stormvermin Mutation|| " .. string.sub(old_server_name,1,17)
	else
		lobby_data.unique_server_name = old_server_name
	end

	Managers.matchmaking.lobby:set_lobby_data(lobby_data)
	--End lobby data

	--Whispering newcomers
	Mods.hook.set("Gamemodes", "MatchmakingManager.rpc_matchmaking_request_join_lobby", function(func, self, sender, client_cookie, host_cookie, lobby_id, friend_join)
		-- get the peer_id out of the client_cookie
		local peer_id = tostring(client_cookie)
		for i=1,3 do
			peer_id = string.sub(peer_id, 1 + tonumber(tostring(string.find(peer_id,"-"))))
		end
		peer_id=string.sub(peer_id, 2)
		peer_id = string.reverse(peer_id)
		peer_id = string.sub(peer_id, 2)
		peer_id = string.reverse(peer_id)

		local function member_func()
			local members = {}
			for i,v in ipairs(self.lobby:members():get_members()) do
				if v == peer_id then
					return {v}
				end
			end
			return self.lobby:members():get_members()
		end

		local original_member_func = Managers.chat.channels[1].members_func
		Managers.chat.channels[1].members_func = member_func
		
		if (lobby_data.difficulty == "survival_hard" or lobby_data.difficulty == "survival_harder" or lobby_data.difficulty == "survival_hardest") and slayertoken then
			if lobby_data.difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset, Deathwish difficulty, Stormvermin Mutation. Yeah, they're suicidal."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif lobby_data.difficulty == "survival_hardest" and deathwishtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset, Deathwish difficulty. Die with honor, hero."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset, Stormvermin Mutation."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			else
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Slayer's Oath waveset."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			end
		elseif (lobby_data.difficulty == "easy" or lobby_data.difficulty == "normal" or lobby_data.difficulty == "hard" or lobby_data.difficulty == "harder" or lobby_data.difficulty == "hardest") and onslaughttoken then
			if lobby_data.difficulty == "hardest" and deathwishtoken and mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught, Deathwish difficulty, Stormvermin Mutation. Yeah, they're suicidal."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif lobby_data.difficulty == "hardest" and deathwishtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught, Deathwish difficulty. Die with honor, hero."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			elseif mutationtoken then 
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught, Stormvermin Mutation."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			else
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Onslaught."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			end
		elseif (lobby_data.difficulty == "hardest" or lobby_data.difficulty == "survival_hardest") and deathwishtoken then
			if mutationtoken then
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Deathwish difficulty, Stormvermin Mutation."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			else
				Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Deathwish difficulty."
				Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
			end
		elseif mutationtoken then
			Mods.whisper.last_whisper = "[Automated message] This lobby has the following difficulty mod active : Stormvermin Mutation."
			Managers.chat:send_system_chat_message(1, Mods.whisper.last_whisper, 0, true)
		end

		Managers.chat.channels[1].members_func = original_member_func
		func(self, sender, client_cookie, host_cookie, lobby_id, friend_join)
		return
	end)

	Mods.hook.front("Gamemodes", "MatchmakingManager.rpc_matchmaking_request_join_lobby")
	--End whispers
	
	Managers.chat:send_system_chat_message(1, "Last Stand : Slayer's Oath waveset ENABLED.", 0, true)
else
	slayertoken = false

	SurvivalSettings.survival_magnus_01.waves = OriginalMagnusWaveset
	SurvivalSettings.dlc_01.waves = OriginalFallWaveset

	Mods.hook.enable(false, "Gamemodes", "StateInGameRunning.event_game_started")

	--Instant set lobby data
	local lobby_data = Managers.matchmaking.lobby:get_stored_lobby_data()
	local old_server_name = LobbyAux.get_unique_server_name()

	if (lobby_data.difficulty == "survival_hard" or lobby_data.difficulty == "survival_harder" or lobby_data.difficulty == "survival_hardest") and slayertoken then
		if lobby_data.difficulty == "survival_hardest" and deathwishtoken and mutationtoken then
			lobby_data.unique_server_name = "||DW MUTATED SLAYER'S OATH|| " .. string.sub(old_server_name,1,15)
		elseif lobby_data.difficulty == "survival_hardest" and deathwishtoken then
			lobby_data.unique_server_name = "||Deathwish Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		elseif mutationtoken then 
			lobby_data.unique_server_name = "||Mutated Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Slayer's Oath|| " .. string.sub(old_server_name,1,17)
		end
	elseif (lobby_data.difficulty == "easy" or lobby_data.difficulty == "normal" or lobby_data.difficulty == "hard" or lobby_data.difficulty == "harder" or lobby_data.difficulty == "hardest") and onslaughttoken then
		if lobby_data.difficulty == "hardest" and deathwishtoken and mutationtoken then
			lobby_data.unique_server_name = "||DW MUTATED ONSLAUGHT|| " .. string.sub(old_server_name,1,17)
		elseif lobby_data.difficulty == "hardest" and deathwishtoken then
			lobby_data.unique_server_name = "||Deathwish Onslaught|| " .. string.sub(old_server_name,1,17)
		elseif mutationtoken then 
			lobby_data.unique_server_name = "||Mutated Onslaught|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Onslaught|| " .. string.sub(old_server_name,1,17)
		end
	elseif (lobby_data.difficulty == "hardest" or lobby_data.difficulty == "survival_hardest") and deathwishtoken then
		if mutationtoken then
			lobby_data.unique_server_name = "||MUTATED DEATHWISH|| " .. string.sub(old_server_name,1,17)
		else
			lobby_data.unique_server_name = "||Deathwish Difficulty|| " .. string.sub(old_server_name,1,17)
		end
	elseif mutationtoken then
		lobby_data.unique_server_name = "||Stormvermin Mutation|| " .. string.sub(old_server_name,1,17)
	else
		lobby_data.unique_server_name = old_server_name
	end

	Managers.matchmaking.lobby:set_lobby_data(lobby_data)
	--End lobby data

	Managers.chat:send_system_chat_message(1, "Last Stand : Slayer's Oath waveset DISABLED.", 0, true)
end

for chunk_name, chunk in pairs(WeightedRandomTerrorEvents) do
	for i = 1, #chunk, 2 do
		local event_name = chunk[i]

		fassert(TerrorEventBlueprints[event_name], "TerrorEventChunk %s has a bad event: '%s'.", chunk_name, tostring(event_name))
	end

	chunk.loaded_probability_table = LoadedDice.create_from_mixed(chunk)
end