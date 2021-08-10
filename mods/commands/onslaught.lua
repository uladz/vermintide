local local_player = Managers.player

if not local_player.is_server then
	EchoConsole("You must be the host to activate mods.")
	return
end

if Managers.state.game_mode == nil or (Managers.state.game_mode._game_mode_key ~= "inn" and local_player.is_server) then
	EchoConsole("You must be in the inn to change the difficulty!")
	return
end

if not onslaughttoken then
	onslaughttoken = true

	OriginalTerrorEventBlueprints = table.clone(TerrorEventBlueprints)
	OriginalHordeSettings = table.clone(HordeSettings.default.compositions)
	OriginalCurrentHordeSettings = table.clone(CurrentHordeSettings.compositions)

	BossSettings.default.boss_events.events = {
		"boss_event_rat_ogre",
		"boss_event_storm_vermin_patrol"
	}

	BossSettings.default.boss_events.max_events_of_this_kind = {
		boss_event_rat_ogre = 2
	}

	LevelSettings.city_wall.boss_events.recurring_distance = 50
	LevelSettings.city_wall.boss_events.padding_distance = 25
	LevelSettings.city_wall.boss_events.max_events_of_this_kind = {
		boss_event_storm_vermin_patrol = 2
	}


	PackSpawningSettings.area_density_coefficient = 7.5
	PackSpawningSettings.squezed_rats_per_10_meter = 15

	SpecialsSettings.default.max_specials = 4

	SpecialsSettings.default.methods.specials_by_time_window.spawn_interval = {
		45,
		60
	}

	SpecialsSettings.default.methods.specials_by_time_window.lull_time = {
		5,
		15
	}

	SpecialsSettings.default.methods.specials_by_slots.after_safe_zone_delay = {
		5,
		75	
	}

	SpecialsSettings.default.methods.specials_by_slots.spawn_cooldown = {
		30,
		60
	}

	PacingSettings.default.horde_frequency = {
		40,
		80
	}

	PacingSettings.default.relax_duration = {
		20,
		25
	}

	PacingSettings.default.peak_intensity_threshold = 120

	PacingSettings.default.peak_fade_threshold = 110

	PacingSettings.default.sustain_peak_duration = {
		5,
		10
	}

	PacingSettings.default.mini_patrol.only_spawn_below_intensity = 90

	PacingSettings.default.mini_patrol.frequency = {
		4,
		8
	}

	PacingSettings.city_wall.horde_frequency = {
		60,
		80
	}

	PacingSettings.city_wall.relax_duration = {
		15,
		20
	}

	PacingSettings.city_wall.peak_intensity_threshold = 120

	PacingSettings.city_wall.peak_fade_threshold = 110

	PacingSettings.city_wall.sustain_peak_duration = {
		5,
		10
	}

	PacingSettings.city_wall.mini_patrol.only_spawn_below_intensity = 135

	PacingSettings.city_wall.mini_patrol.frequency = {
		5,
		10
	}

	----------------------------------------------

	local function count_event_breed(breed_name)
		return Managers.state.conflict:count_units_by_breed_during_event(breed_name)
	end

	local function count_breed(breed_name)
		return Managers.state.conflict:count_units_by_breed(breed_name)
	end

	local ogre_event = {
		"spawn",
		breed_name = "skaven_rat_ogre"
	}

	----------------
	--Horn of Magnus

	TerrorEventBlueprints.magnus_door_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 9
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		}
	}

	TerrorEventBlueprints.magnus_door_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_survival_stormvermin_few"
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 4
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_survival_stormvermin"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 6
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_c",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_b",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 11
		},
		{
			"event_horde",
			spawner_id = "magnus_door_event_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 7 and count_breed("skaven_slave") < 7 and count_breed("skaven_storm_vermin_commander") < 2
			end
		}
	}

	HordeSettings.default.compositions.event_magnus_horn_smaller = {
				{
					name = "plain",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							6,
							9
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "somevermin",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							4,
							5
						},
						"skaven_storm_vermin_commander",
						2
					}
				}
			}

	HordeSettings.default.compositions.event_magnus_horn_small = {
				{
					name = "plain",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							17,
							19
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2
						}
					}
				},
				{
					name = "lotsofvermin",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							4,
							5
						},
						"skaven_storm_vermin_commander",
						{
							3,
							4
						}
					}
				}
			}

	HordeSettings.default.compositions.magnus_end_patrol = {
				{
					name = "somevermin",
					weight = 3,
					breeds = {
						"skaven_storm_vermin_commander",
						12
					}
				}
			}

	table.insert(TerrorEventBlueprints.magnus_end_event, 4, 
		{
			"event_horde",
			spawner_id = "magnus_tower_horn",
			composition_type = "magnus_end_patrol"
		}
	)

	table.insert(TerrorEventBlueprints.magnus_end_event, 12, 
		{
			"event_horde",
			spawner_id = "magnus_tower_horn",
			composition_type = "magnus_end_patrol"
		}
	)

	--------------
	--Shared composition

	HordeSettings.default.compositions.event_generic_long_level_extra_spice = {
				{
					name = "few_clanrats",
					weight = 25,
					breeds = {
						"skaven_clan_rat",
						{
							8,
							10
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2
						}
					}
				},
				{
					name = "storm_clanrats",
					weight = 2,
					breeds = {
						"skaven_clan_rat",
						{
							4,
							5
						},
						"skaven_storm_vermin_commander",
						{
							3,
							4
						}
					}
				}
			}

	--------------
	--Supply & Demand

	TerrorEventBlueprints.merchant_market_event_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "merchant_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 3
			end
		},
		{
			"delay",
			duration = {
				10,
				12
			}
		},
		{
			"flow_event",
			flow_event_name = "merchant_market_event_restart"
		}
	}

	TerrorEventBlueprints.merchant_market_event_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "merchant_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_large"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 3
			end
		},
		{
			"delay",
			duration = {
				10,
				12
			}
		},
		{
			"flow_event",
			flow_event_name = "merchant_market_event_restart"
		}
	}

	TerrorEventBlueprints.merchant_market_event_c = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "merchant_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 3
			end
		},
		{
			"delay",
			duration = {
				11,
				13
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "merchant_market_event_restart"
		}
	}

	TerrorEventBlueprints.merchant_market_event_hard_c = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "merchant_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 7 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				4,
				6
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "market_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"continue_when",
			duration = 75,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				6,
				8
			}
		},
		{
			"flow_event",
			flow_event_name = "merchant_market_event_post_pause_start"
		}
	}

	TerrorEventBlueprints.merchant_market_event_hard_d = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "merchant_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn",
			{
				6,
				8
			},
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 90,
			condition = function (t)
				return count_event_breed("skaven_poison_wind_globadier") < 2 and count_event_breed("skaven_rat_ogre") == 0
			end
		},
		{
			"delay",
			duration = {
				14,
				18
			}
		},
		{
			"flow_event",
			flow_event_name = "merchant_market_event_post_pause_start"
		}
	}

	--------------
	--Smuggler's Run

	HordeSettings.default.compositions.sewers_event_smaller_hard = {
				{
					name = "plain",
					weight = 5,
					breeds = {
						"skaven_clan_rat",
						{
							9,
							12
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "somevermin",
					weight = 5,
					breeds = {
						"skaven_clan_rat",
						{
							4,
							5
						},
						"skaven_storm_vermin_commander",
						{
							2,
							3
						}
					}
				}
			}

	HordeSettings.default.compositions.sewers_event_small_hard = {
				{
					name = "plain",
					weight = 5,
					breeds = {
						"skaven_slave",
						{
							4,
							6
						},
						"skaven_clan_rat",
						{
							20,
							25
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "somevermin",
					weight = 5,
					breeds = {
						"skaven_clan_rat",
						{
							10,
							12
						},
						"skaven_storm_vermin_commander",
						3
					}
				}
			}

	TerrorEventBlueprints.sewers_alt_door_event_01_stopped = {
		{
			"control_pacing",
			enable = true
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"flow_event",
			flow_event_name = "sewers_alt_door_event_01_vo"
		}
	}

	TerrorEventBlueprints.sewers_end_event = {
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "sewers_end_event_a",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "sewers_alt_door_02",
			composition_type = "event_small"
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 12 and count_breed("skaven_slave") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 4
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 12 and count_breed("skaven_slave") < 8
			end
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4
			end
		},
		{
			"delay",
			duration = 8
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 12 and count_breed("skaven_slave") < 8
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			composition_type = "event_smaller"
		},
		{
			"delay",
			duration = 4
		},
		{
			"control_pacing",
			enable = true
		}
	}

	--------------
	--Wizard's Tower

	HordeSettings.default.compositions.wizard_event_smaller_hard = {
				{
					name = "plain",
					weight = 25,
					breeds = {
						"skaven_slave_rat",
						{
							3,
							7
						},
						"skaven_clan_rat",
						{
							24,
							26
						},
						"skaven_storm_vermin_commander",
						2
					}
				},
				{
					name = "somevermin",
					weight = 2,
					breeds = {
						"skaven_slave_rat",
						{
							2,
							5
						},
						"skaven_clan_rat",
						{
							14,
							16
						},
						"skaven_storm_vermin_commander",
						{
							3,
							4
						}
					}
				}
			}

	HordeSettings.default.compositions.wizard_event_small_hard = {
				{
					name = "plain",
					weight = 10,
					breeds = {
						"skaven_slave_rat",
						{
							2,
							3
						},
						"skaven_clan_rat",
						{
							30,
							33
						}
					}
				},
				{
					name = "somevermin",
					weight = 3,
					breeds = {
						"skaven_slave_rat",
						{
							6,
							8
						},
						"skaven_storm_vermin_commander",
						{
							6,
							7
						}
					}
				}
			}

	if TerrorEventBlueprints.open_door[8] ~= ogre_event then
		table.insert(TerrorEventBlueprints.open_door, 8, ogre_event)
	end

	--------------
	--Black Powder & Well Watch

	if TerrorEventBlueprints.bridge_event_horde_a[27]["breed_name"] ~= "skaven_rat_ogre" then
		table.insert(TerrorEventBlueprints.bridge_event_horde_a, 26, ogre_event)
	end

	if TerrorEventBlueprints.courtyard_rolling_event[142]["breed_name"] ~= "skaven_rat_ogre" then
		table.insert(TerrorEventBlueprints.courtyard_rolling_event, 140, ogre_event)
		table.insert(TerrorEventBlueprints.courtyard_rolling_event, 140, ogre_event)
	end

	HordeSettings.default.compositions.event_courtyard_extra_spice = {
				{
					name = "plain",
					weight = 25,
					breeds = {
						"skaven_slave",
						{
							5,
							10
						},
						"skaven_clan_rat",
						{
							12,
							18
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2
						}
					}
				},
				{
					name = "somevermin",
					weight = 2,
					breeds = {
						"skaven_clan_rat",
						{
							10,
							14
						},
						"skaven_storm_vermin_commander",
						{
							3,
							4
						}
					}
				}
			}

	HordeSettings.default.compositions.event_courtyard_extra_big_spice = {
				{
					name = "plain",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							22,
							24
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2
						}
					}
				},
				{
					name = "lotsofvermin",
					weight = 3,
					breeds = {
						"skaven_storm_vermin_commander",
						{
							6,
							7
						}
					}
				}
			}
	--------------
	--Engines of War

	TerrorEventBlueprints.forest_skaven_camp_a = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_a_done"
		}
	}

	TerrorEventBlueprints.forest_skaven_camp_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_b_done"
		}
	}

	TerrorEventBlueprints.forest_skaven_camp_c = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "forest_camp"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_skaven_camp",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 4
			end
		},
		{
			"flow_event",
			flow_event_name = "forest_skaven_camp_c_done"
		}
	}

	if TerrorEventBlueprints.forest_skaven_camp_finale[6]["breed_name"] ~= "skaven_rat_ogre" then
		table.insert(TerrorEventBlueprints.forest_skaven_camp_finale, 6, ogre_event)
	end

	if TerrorEventBlueprints.forest_end_event_a[8]["breed_name"] ~= "skaven_rat_ogre" then
		table.insert(TerrorEventBlueprints.forest_end_event_a, 8, ogre_event)
	end

	TerrorEventBlueprints.forest_end_event_b = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	TerrorEventBlueprints.forest_end_event_c = {
		{
			"set_master_event_running",
			name = "forest_finale"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "forest_end_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				10,
				15
			}
		},
		{
			"flow_event",
			flow_event_name = "forest_end_event_restart"
		}
	}

	--------------
	--Man the Ramparts

	TerrorEventBlueprints.walls_gate_guards_a = {
		{
			"spawn_at_raw",
			spawner_id = "gateguard_a_1",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_a_2",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_a_3",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_a_4",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_a_5",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_a_6",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_b_1",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_b_2",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_b_3",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_b_4",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_b_5",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"spawn_at_raw",
			spawner_id = "gateguard_b_6",
			breed_name = "skaven_storm_vermin_commander"
		},
		{
			"delay",
			duration = {
				5,
				10
			}
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		}
	}

	TerrorEventBlueprints.walls_gate_guards_b = TerrorEventBlueprints.walls_gate_guards_a

	HordeSettings.default.compositions.city_wall_extra_spice = {
				{
					name = "few_clanrats",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							8,
							12
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "storm_clanrats",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						{
							6,
							8
						},
						"skaven_storm_vermin_commander",
						3
					}
				}
			}

	HordeSettings.default.compositions.event_generic_short_level_extra_spice = {
				{
					name = "few_clanrats",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							9,
							13
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "storm_clanrats",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							5,
							8
						},
						"skaven_storm_vermin_commander",
						{
							2,
							3
						}
					}
				}
			}

	TerrorEventBlueprints.city_wall_a = {
		{
			"set_master_event_running",
			name = "wall"
		},
		{
			"event_horde",
			spawner_id = "city_wall_a",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "city_wall_a",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "city_wall_b",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 5 and count_breed("skaven_storm_vermin_commander") < 2
			end
		}
	}

	TerrorEventBlueprints.city_wall_b = {
		{
			"set_master_event_running",
			name = "wall"
		},
		{
			"event_horde",
			spawner_id = "city_wall_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "city_wall_b",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "city_wall_c",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 5 and count_breed("skaven_storm_vermin_commander") < 2
			end
		}
	}

	TerrorEventBlueprints.city_wall_c = {
		{
			"set_master_event_running",
			name = "wall"
		},
		{
			"disable_kick"
		},
		{
			"event_horde",
			spawner_id = "city_wall_c",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "city_wall_c",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "city_wall_d",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 5 and count_breed("skaven_storm_vermin_commander") < 2
			end
		}
	}

	TerrorEventBlueprints.city_wall_d = {
		{
			"set_master_event_running",
			name = "wall"
		},
		{
			"disable_kick"
		},
		{
			"event_horde",
			spawner_id = "city_wall_d",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "city_wall_d",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "city_wall_b",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 5 and count_breed("skaven_storm_vermin_commander") < 2
			end
		}
	}

	TerrorEventBlueprints.city_wall_end = {
		{
			"delay",
			duration = 20
		},
		{
			"disable_kick"
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		},
		{
			"event_horde",
			spawner_id = "city_wall_end",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "city_wall_d",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "city_wall_b",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 20
		},
		{
			"stop_master_event"
		}
	}

	--------------
	--Garden of Morr

	TerrorEventBlueprints.cemetery_plague_brew_event_1_a = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_small"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_smaller"
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}

	TerrorEventBlueprints.cemetery_plague_brew_event_1_b = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_small"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_smaller"
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}

	TerrorEventBlueprints.cemetery_plague_brew_event_2_a = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_small"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_smaller"
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}

	TerrorEventBlueprints.cemetery_plague_brew_event_2_b = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_small"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_smaller"
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}


	TerrorEventBlueprints.cemetery_plague_brew_event_3_a = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_small"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_smaller"
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}

	TerrorEventBlueprints.cemetery_plague_brew_event_3_b = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_small"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"event_horde",
			composition_type = "event_magnus_horn_smaller"
		},
		{
			"event_horde",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		}
	}


	TerrorEventBlueprints.cemetery_plague_brew_event_4_a = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_rat_ogre"
		}
	}

	TerrorEventBlueprints.cemetery_plague_brew_event_4_b = {
		{
			"disable_kick"
		},
		{
			"event_horde",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"spawn",
			1,
			breed_name = "skaven_rat_ogre"
		}
	}

	--------------
	--Wheat&Chaff

	HordeSettings.default.compositions.event_farm_extra_spice = {
				{
					name = "plain",
					weight = 6,
					breeds = {
						"skaven_clan_rat",
						{
							15,
							22
						},
						"skaven_storm_vermin_commander",
						2
					}
				},
				{
					name = "avermin",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							15,
							22
						},
						"skaven_storm_vermin_commander",
						3
					}
				},
				{
					name = "somevermin",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						{
							7,
							12
						},
						"skaven_storm_vermin_commander",
						5
					}
				}
			}

	HordeSettings.default.compositions.event_farm_extra_big_spice = {
				{
					name = "plain",
					weight = 5,
					breeds = {
						"skaven_clan_rat",
						{
							20,
							30
						},
						"skaven_storm_vermin_commander",
						3
					}
				},
				{
					name = "lotsofvermin",
					weight = 5,
					breeds = {
						"skaven_slave",
						{
							13,
							19
						},
						"skaven_storm_vermin_commander",
						6
					}
				}
			}

	TerrorEventBlueprints.farm_event_larger = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		}
	}

	TerrorEventBlueprints.farm_event_larger_vermin = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		}
	}

	TerrorEventBlueprints.farm_event_larger_second = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		}
	}

	TerrorEventBlueprints.farm_event_larger_second_vermin = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_second",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		}
	}

	TerrorEventBlueprints.farm_event_larger_third = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "large"
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "farm_vermin_larger",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		}
	}

	TerrorEventBlueprints.farm_event_larger_third_vermin = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "farm_vermin_larger_third",
			composition_type = "event_generic_short_level_stormvermin"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		}
	}

	TerrorEventBlueprints.farm_event_ogre = {
		{
			"set_master_event_running",
			name = "farm"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"control_specials",
			enable = false
		},
		{
			"disable_kick"
		},
		{
			"delay",
			duration = {
				5,
				40
			}
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 1 and count_breed("skaven_slave") < 12
			end
		},
		{
			"control_specials",
			enable = true
		}
	}

	--------------
	--Enemy Below

	TerrorEventBlueprints.tunnels_random_chance_event = {
		{
			"delay",
			duration = {
				1,
				3
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "tunnels_random_chance_event",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "tunnels_random_chance_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = {
				10,
				12
			}
		},
		{
			"flow_event",
			flow_event_name = "tunnels_random_chance_event_done"
		}
	}

	TerrorEventBlueprints.tunnels_skaven_bell = {
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 90
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 90
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 90
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 90
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 90
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"delay",
			duration = 90
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		},
		{
			"spawn",
			breed_name = "skaven_gutter_runner"
		}
	}

	TerrorEventBlueprints.tunnels_end_event_loop = {
		{
			"control_pacing",
			enable = false
		},
		{
			"set_master_event_running",
			name = "master_tunnels_end_event_loop"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "tunnels_end_event_room",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"delay",
			duration = 7
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "tunnels_end_event_room",
			composition_type = "event_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 8 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"stop_master_event"
		},
		{
			"flow_event",
			flow_event_name = "tunnels_end_event_loop_restart"
		}
	}

	TerrorEventBlueprints.tunnels_end_event_escape_stop_event = {
		{
			"stop_event",
			stop_event_name = "tunnels_end_event_escape"
		},
		{
			"stop_event",
			stop_event_name = "tunnels_escape_tunnels_1"
		},
		{
			"stop_event",
			stop_event_name = "tunnels_escape_tunnels_2_left"
		},
		{
			"stop_event",
			stop_event_name = "tunnels_escape_tunnels_2_right"
		},
		{
			"stop_event",
			stop_event_name = "tunnels_escape_tunnels_end"
		},
		{
			"delay",
			duration = 5
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		}
	}

	--------------
	--Waterfront

	HordeSettings.default.compositions.event_docks_warehouse_extra_spice = {
				{
					name = "few_clanrats",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							12,
							17
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "storm_clanrats",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							8,
							11
						},
						"skaven_storm_vermin_commander",
						{
							2,
							3
						}
					}
				}
			}

	TerrorEventBlueprints.docks_warehouse_event = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "docks_warehouse"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "docks_warehouse_event",
			composition_type = "event_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = {
				4,
				7
			}
		},
		{
			"event_horde",
			spawner_id = "docks_warehouse_event",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "docks_warehouse_end"
		}
	}

	TerrorEventBlueprints.docks_warehouse_end_event = {
		{
			"set_master_event_running",
			name = "docks_warehouse"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "docks_warehouse_event_end",
			composition_type = "event_large"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = {
				4,
				7
			}
		},
		{
			"event_horde",
			spawner_id = "docks_warehouse_event",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"disable_bots_in_carry_event"
		},
		{
			"flow_event",
			flow_event_name = "docks_warehouse_end"
		}
	}

	TerrorEventBlueprints.docks_extra_spice_event = {
		{
			"event_horde",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_breed("skaven_clan_rat") < 20 and count_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "docks_extra_spice_event_done"
		}
	}

	TerrorEventBlueprints.docks_shipyard_event = {
		{
			"set_master_event_running",
			name = "docks_shipyard"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "docks_shipyard_event",
			composition_type = "event_large"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = {
				4,
				7
			}
		},
		{
			"event_horde",
			spawner_id = "docks_warehouse_event",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "docks_shipyard_end"
		}
	}

	TerrorEventBlueprints.docks_end_event = {
		{
			"set_master_event_running",
			name = "docks_ending"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			composition_type = "event_generic_short_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 6
			end
		},
		{
			"delay",
			duration = {
				4,
				6
			}
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "docks_end_event_done"
		}
	}

	TerrorEventBlueprints.docks_end_ogre_event = {
		{
			"control_pacing",
			enable = true
		},
		{
			"disable_kick"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 2
			end
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 2
			end
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 2
			end
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_breed("skaven_rat_ogre") < 2 and count_breed("skaven_slave") < 8
			end
		},
		{
			"delay",
			duration = {
				10,
				12
			}
		},
		{
			"flow_event",
			flow_event_name = "docks_end_event_done"
		}
	}

	--------------
	--White Rat

	TerrorEventBlueprints.end_boss_bell_a = {
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_a",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_slave") < 8 and count_event_breed("skaven_storm_vermin_commander") < 5
			end
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_a",
			composition_type = "end_boss_event_smaller_hard"
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 15 and count_event_breed("skaven_slave") < 20 and count_event_breed("skaven_storm_vermin_commander") < 5
			end
		},
		{
			"delay",
			duration = 20
		},
		{
			"flow_event",
			flow_event_name = "end_boss_bell_a_restart"
		}
	}

	HordeSettings.default.compositions.end_boss_event_smaller_hard = {
				{
					name = "plain",
					weight = 6,
					breeds = {
						"skaven_slave",
						{
							6,
							8
						},
						"skaven_clan_rat",
						{
							8,
							12
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "somevermin",
					weight = 2,
					breeds = {
						"skaven_clan_rat",
						{
							8,
							11
						},
						"skaven_storm_vermin_commander",
						3
					}
				},
				{
					name = "somevermin",
					weight = 2,
					breeds = {
						"skaven_clan_rat",
						{
							12,
							16
						},
						"skaven_storm_vermin_commander",
						1
					}
				}
			}

	HordeSettings.default.compositions.end_boss_event_small_hard = {
				{
					name = "plain",
					weight = 6,
					breeds = {
						"skaven_clan_rat",
						{
							15,
							19
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "somevermin",
					weight = 2,
					breeds = {
						"skaven_storm_vermin_commander",
						6
					}
				},
				{
					name = "clanvermin",
					weight = 2,
					breeds = {
						"skaven_clan_rat",
						{
							6,
							10
						},
						"skaven_storm_vermin_commander",
						4
					}
				}
			}

	HordeSettings.default.compositions.end_boss_event_stormvermin = {
				{
					name = "somevermin",
					weight = 3,
					breeds = {
						"skaven_storm_vermin_commander",
						14
					}
				}
			}

	TerrorEventBlueprints.end_boss_bell_a_gate = {
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_a",
			composition_type = "end_boss_event_stormvermin"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_commander") < 1
			end
		},
		{
			"delay",
			duration = 20
		},
		{
			"control_pacing",
			enable = true
		}
	}

	TerrorEventBlueprints.end_boss_terror_b = {
		{
			"enable_bots_in_carry_event"
		},
		{
			"disable_kick"
		},
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_b",
			composition_type = "end_boss_event_stormvermin_small"
		},
		{
			"continue_when",
			duration = 10,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				5,
				12
			}
		},
		{
			"spawn",
			breed_name = "skaven_rat_ogre"
		}
	}

	TerrorEventBlueprints.end_boss_bell_b = {
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"disable_kick"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_b",
			composition_type = "event_medium"
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_b",
			composition_type = "end_boss_event_smaller_hard"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_slave") < 8 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "end_boss_bell_b_restart"
		}
	}

	TerrorEventBlueprints.end_boss_terror_c1 = {
		{
			"disable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_c_1",
			composition_type = "event_large"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"control_specials",
			enable = false
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_at_raw",
			spawner_id = "end_event_ogre1",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "end_event_ogre2",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 120,
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") == 0 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"control_specials",
			enable = true
		}
	}

	TerrorEventBlueprints.end_boss_terror_c2 = {
		{
			"disable_bots_in_carry_event"
		},
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_c_1",
			composition_type = "event_large"
		},
		{
			"continue_when",
			duration = 25,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"control_specials",
			enable = false
		},
		{
			"delay",
			duration = 6
		},
		{
			"spawn_at_raw",
			spawner_id = "end_event_ogre2",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 3
		},
		{
			"spawn_at_raw",
			spawner_id = "end_event_ogre1",
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 120,
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") == 0 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"control_specials",
			enable = true
		}
	}

	HordeSettings.default.compositions.end_boss_event_rolling = {
				{
					name = "plain",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							16,
							26
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "plain_slave",
					weight = 3,
					breeds = {
						"skaven_slave",
						{
							8,
							18
						},
						"skaven_clan_rat",
						{
							10,
							18
						},
						"skaven_storm_vermin_commander",
						1
					}
				},
				{
					name = "somevermin",
					weight = 2,
					breeds = {
						"skaven_storm_vermin_commander",
						{
							4,
							6
						}
					}
				},
				{
					name = "somevermin_slave",
					weight = 2,
					breeds = {
						"skaven_slave",
						{
							8,
							18
						},
						"skaven_storm_vermin_commander",
						4
					}
				}
			}

	TerrorEventBlueprints.end_boss_bell_c = {
		{
			"set_master_event_running",
			name = "end_boss"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_c",
			composition_type = "event_small"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"delay",
			duration = 15
		},
		{
			"event_horde",
			spawner_id = "end_boss_spawners_c",
			composition_type = "end_boss_event_rolling"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"flow_event",
			flow_event_name = "end_boss_bell_c_restart"
		}
	}

	--------------
	--Castle Drachenfels

	TerrorEventBlueprints.castle_inner_sanctum_event_loop = {
		{
			"set_master_event_running",
			name = "inner_sanctum"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "inner_sanctum",
			composition_type = "event_small"
		},
		{
			"event_horde",
			spawner_id = "inner_sanctum",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 8 and count_event_breed("skaven_slave") < 8 and count_event_breed("skaven_storm_vermin_commander") < 10
			end
		},
		{
			"delay",
			duration = {
				8,
				10
			}
		},
		{
			"flow_event",
			flow_event_name = "castle_inner_sanctum_event_loop_restart"
		}
	}

	TerrorEventBlueprints.castle_inner_sanctum_extra_spice_loop = {
		{
			"set_master_event_running",
			name = "inner_sanctum"
		},
		{
			"event_horde",
			spawner_id = "inner_sanctum",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 5
			end
		},
		{
			"delay",
			duration = {
				10,
				12
			}
		},
		{
			"flow_event",
			flow_event_name = "castle_inner_sanctum_extra_spice_loop_restart"
		}
	}

	TerrorEventBlueprints.castle_inner_sanctum_stop_event = {
		{
			"stop_event",
			stop_event_name = "castle_inner_sanctum_event_loop"
		},
		{
			"stop_event",
			stop_event_name = "castle_inner_sanctum_extra_spice_loop"
		},
		{
			"disable_bots_in_carry_event"
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 2
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		}
	}

	TerrorEventBlueprints.castle_catacombs_end_event_loop = {
		{
			"set_master_event_running",
			name = "escape_catacombs"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "escape_catacombs",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "castle_catacombs_end_event_loop_done"
		}
	}

	TerrorEventBlueprints.castle_catacombs_end_event_loop_extra_spice = {
		{
			"set_master_event_running",
			name = "escape_catacombs"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape_spice",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 10 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "castle_catacombs_end_event_loop_extra_spice_done"
		}
	}

	--------------
	--Dungeons

	TerrorEventBlueprints.dungeon_event_dark_end_ogre = {
		{
			"set_master_event_running",
			name = "dungeon"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"delay",
			duration = {
				1,
				3
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_large"
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"control_specials",
			enable = false
		},
		{
			"delay",
			duration = 7
		},
		{
			"spawn_at_raw",
			spawner_id = "dark_ogre1",
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 7
		},
		{
			"spawn_at_raw",
			spawner_id = "dark_ogre1",
			breed_name = "skaven_rat_ogre"
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
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "medium"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			spawner_id = "dark_finale_spawn",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 140,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 4 and count_event_breed("skaven_rat_ogre") < 1 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"control_specials",
			enable = true
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "dungeon_event_dark_doors"
		}
	}

	-------------
	--Summoner's Peak

	HordeSettings.default.compositions.event_portals_slaves_small = {
				{
					name = "slaves_small",
					weight = 1,
					breeds = {
						"skaven_slave",
						{
							15,
							20
						},
						"skaven_clan_rat",
						{
							2,
							4
						},
						"skaven_storm_vermin_commander",
						1
					}
				}
			}

	HordeSettings.default.compositions.event_portals_flank = {
				{
					name = "flank_a",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						{
							15,
							18
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2,
						}
					}
				},
				{
					name = "flank_b",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						{
							5,
							6
						},
						"skaven_slave",
						{
							10,
							15
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2,
						}
					}
				}
			}

	HordeSettings.default.compositions.event_portals_flush = {
				{
					name = "flush",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						{
							12,
							16
						},
						"skaven_slave",
						{
							20,
							30
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2,
						}
					}
				}
			}

	HordeSettings.default.compositions.event_portals_pack = {
				{
					name = "pack",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						15,
						"skaven_storm_vermin_commander",
						4
					}
				}
			}

	HordeSettings.default.compositions.event_portals_stormvermin = {
				{
					name = "stormvermin",
					weight = 1,
					breeds = {
						"skaven_storm_vermin_commander",
						{
							6,
							7
						}
					}
				}
			}


	TerrorEventBlueprints.dlc_portals_a = {
		{
			"set_master_event_running",
			name = "dlc_portals_a"
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
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 8
			end
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
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 20
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 30,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_large"
		},
		{
			"delay",
			duration = 8
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"event_horde",
			composition_type = "event_portals_flush"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_a",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"flow_event",
			flow_event_name = "portals_terror_event_a_complete"
		}
	}

	TerrorEventBlueprints.dlc_portals_b = {
		{
			"set_master_event_running",
			name = "dlc_portals_b"
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
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 8
			end
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
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 20
		},
		{
			"flow_event",
			flow_event_name = "event_portal_b_spawn_ogre"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"event_horde",
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_b",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_clanrats"
		},
		{
			"flow_event",
			flow_event_name = "portals_terror_event_b_complete"
		}
	}

	TerrorEventBlueprints.dlc_portals_c = {
		{
			"set_master_event_running",
			name = "dlc_portals_c"
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
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 2
			end
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
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_stormvermin"
		},
		{
			"delay",
			duration = 15
		},
		{
			"flow_event",
			flow_event_name = "event_portal_c_spawn_ogre"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
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
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_stormvermin"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
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
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			composition_type = "event_portals_flush"
		},
		{
			"delay",
			duration = 3
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_flank"
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_flank"
		},
		{
			"delay",
			duration = 15
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			duration = 15,
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_1",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 5,
			spawner_id = "spawner_portal_c_2",
			composition_type = "event_portals_slaves_small"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 15,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 6 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"control_pacing",
			enable = true
		},
		{
			"flow_event",
			flow_event_name = "portals_terror_event_c_complete"
		}
	}

	-----------
	--Khazid Kro

	TerrorEventBlueprints.dwarf_interior_brewery_loop = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "brewery_event",
			composition_type = "event_generic_long_level_extra_spice"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 8 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"delay",
			duration = {
				3,
				5
			}
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_loop_restart"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_a = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_restart"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_b = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_restart"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_c = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 3
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_restart"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_hard_b = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "brewery_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "brewery_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "brewery_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_post_pause_start"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_hard_c = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 7
			end
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_post_pause_start"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_hard_d = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 10
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "brewery_event",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_brewery_post_pause_start"
		}
	}

	TerrorEventBlueprints.dwarf_interior_brewery_finale = {
		{
			"set_master_event_running",
			name = "brewery_event"
		},
		{
			"disable_bots_in_carry_event"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "brewery_event_finale",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 15
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"control_pacing",
			enable = true
		}
	}

	TerrorEventBlueprints.dwarf_interior_great_hall_start = {
		{
			"control_pacing",
			enable = false
		},
		{
			"disable_kick"
		},
		{
			"enable_bots_in_carry_event"
		},
		{
			"delay",
			duration = {
				3,
				8
			}
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		}
	}

	TerrorEventBlueprints.dwarf_interior_great_hall_extra_spice_event = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "great_hall_extra_spice",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_storm_vermin_commander") < 3
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_extra_spice_done"
		}
	}

	TerrorEventBlueprints.dwarf_interior_great_hall_tunnels = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "tunnel_spawn",
			composition_type = "event_medium"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"delay",
			duration = {
				10,
				12
			}
		},
		{
			"event_horde",
			spawner_id = "tunnel_spawn",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_done"
		}
	}

	TerrorEventBlueprints.dwarf_interior_great_hall_upstairs_tunnel_extra = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "upstairs_tunnel_spawn",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "upstairs_tunnel_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_upstairs_tunnel_extra_done"
		}
	}

	TerrorEventBlueprints.dwarf_interior_great_hall_downstairs_tunnel_extra = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "downstairs_tunnel_spawn",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "downstairs_tunnel_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 2
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_downstairs_tunnel_extra_done"
		}
	}

	TerrorEventBlueprints.dwarf_interior_great_hall_back_tunnel_extra = {
		{
			"set_master_event_running",
			name = "great_hall_spawn"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "back_tunnel_spawn",
			composition_type = "event_smaller"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "back_tunnel_spawn",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 80,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_interior_great_hall_back_tunnel_extra_done"
		}
	}

	-----------
	--Chain of Fire

	TerrorEventBlueprints.dwarf_beacons_gate_part1 = {
		{
			"set_master_event_running",
			name = "beacons_gate"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "gate_currentside",
			composition_type = "event_large"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"event_horde",
			spawner_id = "gate_currentside",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "gate_currentside",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = {
				5,
				6
			}
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_otherside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_otherside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_otherside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		}
	}

	TerrorEventBlueprints.dwarf_beacons_gate_part2 = {
		{
			"set_master_event_running",
			name = "beacons_gate"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "gate_otherside",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = {
				3,
				8
			}
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_otherside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"event_horde",
			spawner_id = "gate_currentside",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "gate_otherside",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = {
				5,
				6
			}
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_currentside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"delay",
			duration = {
				5,
				6
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "gate_otherside",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12
			end
		},
		{
			"control_pacing",
			enable = true
		}
	}

	TerrorEventBlueprints.dwarf_beacons_beacon = {
		{
			"set_master_event_running",
			name = "beacons_beacon"
		},
		{
			"control_pacing",
			enable = false
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "beacon",
			composition_type = "event_large"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"spawn",
			{
				1,
				2
			},
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"event_horde",
			spawner_id = "beacon",
			composition_type = "event_medium"
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"delay",
			duration = {
				3,
				4
			}
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_ratling_gunner"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			spawner_id = "beacon",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = {
				5,
				6
			}
		},
		{
			"continue_when",
			duration = 40,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"continue_when",
			duration = 20,
			condition = function (t)
				return count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"spawn",
			{
				1,
				2
			},
			breed_name = "skaven_poison_wind_globadier"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "beacon",
			composition_type = "event_docks_warehouse_extra_spice"
		},
		{
			"delay",
			duration = {
				9,
				11
			}
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 12 and count_event_breed("skaven_slave") < 12 and count_event_breed("skaven_storm_vermin_commander") < 4
			end
		}
	}

	-----------
	--Cursed Rune

	TerrorEventBlueprints.dwarf_exterior_end_event_survival_01 = {
		{
			"set_master_event_running",
			name = "dwarf_exterior_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_survival",
			composition_type = "event_large"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			spawner_id = "end_event_survival",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"event_horde",
			spawner_id = "end_event_survival",
			composition_type = "event_generic_long_level_stormvermin"
		},
		{
			"delay",
			duration = 10
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"delay",
			duration = 5
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 7 and count_event_breed("skaven_slave") < 8 and count_event_breed("skaven_storm_vermin_commander") < 2 and count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_exterior_end_event_survival_01_done"
		}
	}

	HordeSettings.default.compositions.event_dwarf_exterior_extra_spice = {
				{
					name = "few_clanrats",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							11,
							13
						},
						"skaven_storm_vermin_commander",
						2
					}
				},
				{
					name = "storm_clanrats",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							5,
							7
						},
						"skaven_storm_vermin_commander",
						5
					}
				}
			}

	HordeSettings.default.compositions.event_dwarf_exterior_extra_spice_02 = {
				{
					name = "few_clanrats",
					weight = 10,
					breeds = {
						"skaven_clan_rat",
						{
							10,
							11
						},
						"skaven_storm_vermin_commander",
						2
					}
				},
				{
					name = "storm_clanrats",
					weight = 3,
					breeds = {
						"skaven_clan_rat",
						{
							13,
							15
						},
						"skaven_storm_vermin_commander",
						1
					}
				}
			}

	TerrorEventBlueprints.dwarf_exterior_end_event_survival_end = {
		{
			"set_master_event_running",
			name = "dwarf_exterior_end_event_survival"
		},
		{
			"play_stinger",
			stinger_name = "enemy_horde_stinger"
		},
		{
			"spawn",
			{
				1
			},
			breed_name = "skaven_rat_ogre"
		},
		{
			"event_horde",
			limit_spawners = 4,
			spawner_id = "end_event_survival",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_survival",
			composition_type = "event_dwarf_exterior_extra_spice"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 60,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 3 and count_event_breed("skaven_slave") < 3 and count_event_breed("skaven_storm_vermin_commander") < 1 and count_event_breed("skaven_rat_ogre") < 1
			end
		},
		{
			"flow_event",
			flow_event_name = "dwarf_exterior_end_event_survival_end_done"
		}
	}

	TerrorEventBlueprints.dwarf_exterior_end_event_escape_02 = {
		{
			"set_master_event_running",
			name = "dwarf_exterior_end_event_escape"
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape",
			composition_type = "event_medium"
		},
		{
			"delay",
			duration = 5
		},
		{
			"event_horde",
			limit_spawners = 2,
			spawner_id = "end_event_escape",
			composition_type = "event_dwarf_exterior_extra_spice_02"
		},
		{
			"delay",
			duration = 10
		},
		{
			"continue_when",
			duration = 50,
			condition = function (t)
				return count_event_breed("skaven_clan_rat") < 8 and count_event_breed("skaven_slave") < 10 and count_event_breed("skaven_storm_vermin_commander") < 6
			end
		},
		{
			"delay",
			duration = 5
		},
		{
			"flow_event",
			flow_event_name = "dwarf_exterior_end_event_escape_02_done"
		}
	}

	-----------
	--Reaching Out

	TerrorEventBlueprints.stromdorf_pacing_off = {
		{
			"control_pacing",
			enable = false
		}
	}

	BreedActions.skaven_storm_vermin_champion.spawn_sequence.considerations.time_since_last.max_value = 1100

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn = {
			harder = "stormdorf_boss_event_defensive_hardest",
			normal = "stormdorf_boss_event_defensive_hardest",
			hard = "stormdorf_boss_event_defensive_hardest",
			survival_hard = "stormdorf_boss_event_defensive_hard",
			survival_harder = "stormdorf_boss_event_defensive_hard",
			hardest = "stormdorf_boss_event_defensive_hardest",
			survival_hardest = "stormdorf_boss_event_defensive_hard",
			easy = "stormdorf_boss_event_defensive_hardest"
		}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.easy = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.normal = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.hard = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.harder = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.ignore_staggers = {
			true,
			true,
			true,
			true,
			true,
			true
		}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.ignore_staggers = {
			true,
			true,
			true,
			true,
			true,
			true
		}

	Mods.hook.set("Gamemodes", "Breeds.skaven_storm_vermin_champion.run_on_update", function(func, unit, blackboard, t, dt)
		local self_pos = POSITION_LOOKUP[unit]
		local range = BreedActions.skaven_storm_vermin_champion.special_attack_spin.radius
		local num = 0

		for i, position in ipairs(PLAYER_AND_BOT_POSITIONS) do
			if Vector3.distance(self_pos, position) < range and not ScriptUnit.extension(PLAYER_AND_BOT_UNITS[i], "status_system"):is_disabled() then
				num = num + 1
			end
		end

		blackboard.surrounding_players = num

		if 0 < blackboard.surrounding_players then
			blackboard.surrounding_players_last = t
		end

		if blackboard.trickle_timer and blackboard.trickle_timer < t and not blackboard.defensive_mode_duration then
			local conflict_director = Managers.state.conflict

			if conflict_director.count_units_by_breed(conflict_director, "skaven_clan_rat") < 12 then
				local strictly_not_close_to_players = true
				local silent = true
				local composition_type = "mini_patrol"
				local limit_spawners, terror_event_id = nil

				conflict_director.horde_spawner:execute_event_horde(t, terror_event_id, composition_type, limit_spawners, silent, nil, strictly_not_close_to_players)

				blackboard.trickle_timer = t + 10
			else
				blackboard.trickle_timer = t + 5
			end
		end

		local hp = ScriptUnit.extension(blackboard.unit, "health_system"):current_health_percent()

		if blackboard.current_phase == 2 and hp < 0.15 then
			blackboard.current_phase = 3
			local new_run_speed = blackboard.breed.angry_run_speed
			blackboard.run_speed = new_run_speed

			if not blackboard.run_speed_overridden then
				blackboard.navigation_extension:set_max_speed(new_run_speed)
			end
		elseif blackboard.current_phase == 1 and hp < 0.8 then
			blackboard.current_phase = 2
		end

		if blackboard.defensive_mode_duration then
			local remaining = blackboard.defensive_mode_duration - dt

			if remaining <= 5 or (remaining <= 30 and Managers.state.conflict:spawned_during_event() <= 15) then
				blackboard.defensive_mode_duration = nil
			else
				blackboard.defensive_mode_duration = remaining
			end
		end

		if blackboard.ward_active and script_data.ai_champion_spawn_debug then
			QuickDrawer:sphere(POSITION_LOOKUP[unit] + Vector3(0, 0, 1.5), 1.5, Color(255, 0, 0))
		end

		return
	end)

	-----------
	--Trial of the Foolhardy

	TerrorEventBlueprints.general_wizard = {
				{
					"set_master_event_running",
					name = "general_wizard"
				},
				{
					"control_specials",
					enable = true
				},
				{
					"event_horde",
					spawner_id = "general_wizard",
					composition_type = "event_general_trickle_hub"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					condition = function (t)
						return count_breed("skaven_clan_rat") < 16 and count_breed("skaven_slave") < 16 and count_breed("skaven_storm_vermin_commander") < 2
					end
				},
				{
					"flow_event",
					flow_event_name = "general_wizard_loop"
				}
			}

	TerrorEventBlueprints.general_snow = {
				{
					"set_master_event_running",
					name = "general_snow"
				},
				{
					"control_specials",
					enable = true
				},
				{
					"event_horde",
					spawner_id = "general_snow",
					composition_type = "event_general_trickle"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					condition = function (t)
						return count_breed("skaven_clan_rat") < 40 and count_breed("skaven_slave") < 16 and count_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"flow_event",
					flow_event_name = "general_snow_loop"
				}
			}

	TerrorEventBlueprints.general_forest = {
				{
					"set_master_event_running",
					name = "general_forest"
				},
				{
					"control_specials",
					enable = true
				},
				{
					"event_horde",
					spawner_id = "general_forest",
					composition_type = "event_general_trickle"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					condition = function (t)
						return count_breed("skaven_clan_rat") < 40 and count_breed("skaven_slave") < 16 and count_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"flow_event",
					flow_event_name = "general_forest_loop"
				}
			}

	TerrorEventBlueprints.general_escher = {
				{
					"set_master_event_running",
					name = "general_escher"
				},
				{
					"control_specials",
					enable = true
				},
				{
					"event_horde",
					spawner_id = "general_escher",
					composition_type = "event_general_trickle"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					condition = function (t)
						return count_breed("skaven_clan_rat") < 40 and count_breed("skaven_slave") < 16 and count_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"flow_event",
					flow_event_name = "general_escher_loop"
				}
			}

	TerrorEventBlueprints.general_town = {
				{
					"set_master_event_running",
					name = "general_town"
				},
				{
					"control_specials",
					enable = true
				},
				{
					"event_horde",
					spawner_id = "general_town",
					composition_type = "event_general_trickle"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					condition = function (t)
						return count_breed("skaven_clan_rat") < 40 and count_breed("skaven_slave") < 16 and count_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"flow_event",
					flow_event_name = "general_town_loop"
				}
			}

	TerrorEventBlueprints.general_final_showdown = {
				{
					"set_master_event_running",
					name = "end"
				},
				{
					"control_specials",
					enable = true
				},
				{
					"event_horde",
					spawner_id = "general_wizard",
					composition_type = "event_general_trickle"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					condition = function (t)
						return count_breed("skaven_clan_rat") < 40 and count_breed("skaven_slave") < 16 and count_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"flow_event",
					flow_event_name = "general_final_showdown_loop"
				}
			}

	TerrorEventBlueprints.snow_grabbed_ingredient = {
				{
					"set_master_event_running",
					name = "snow"
				},
				{
					"spawn",
					{
						1
					},
					breed_name = "skaven_rat_ogre"
				},
				{
					"event_horde",
					spawner_id = "general_snow_tear",
					composition_type = "event_general_trickle"
				}
			}

	TerrorEventBlueprints.forest_grabbed_ingredient = {
				{
					"set_master_event_running",
					name = "forest"
				},
				{
					"spawn",
					{
						1
					},
					breed_name = "skaven_rat_ogre"
				},
				{
					"event_horde",
					spawner_id = "general_forest_tear",
					composition_type = "event_general_trickle"
				}
			}

	TerrorEventBlueprints.town_grabbed_ingredient = {
				{
					"set_master_event_running",
					name = "town"
				},
				{
					"spawn",
					{
						1
					},
					breed_name = "skaven_rat_ogre"
				},
				{
					"event_horde",
					spawner_id = "general_town_tear",
					composition_type = "event_general_trickle"
				}
			}

	-----------
	--Reikwald Forest

	TerrorEventBlueprints.reikwald_mid_event_loop_extra_spice = {
				{
					"set_master_event_running",
					name = "reikwald_mid_starting"
				},
				{
					"event_horde",
					spawner_id = "reikwald_mid_spawner_spice",
					composition_type = "event_small"
				},
				{
					"event_horde",
					spawner_id = "reikwald_mid_spawner_spice",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "reikwald_mid_spawner",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"delay",
					duration = 5
				},
				{
					"event_horde",
					spawner_id = "reikwald_mid_spawner_spice",
					composition_type = "event_small"
				},
				{
					"event_horde",
					spawner_id = "reikwald_mid_spawner_spice",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "reikwald_mid_spawner",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"delay",
					duration = 5
				},
				{
					"flow_event",
					flow_event_name = "reikwald_mid_event_loop_extra_spice_done"
				}
	}

	TerrorEventBlueprints.reikwald_end_event = {
				{
					"set_master_event_running",
					name = "reikwald_end_starting"
				},
				{
					"control_specials",
					enable = false
				},
				{
					"disable_kick"
				},
				{
					"play_stinger",
					stinger_name = "enemy_horde_stinger"
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_large"
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"spawn_at_raw",
					spawner_id = "reikwald_end_spawner_raw01",
					breed_name = "skaven_rat_ogre"
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_generic_long_level_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_medium"
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"spawn_at_raw",
					spawner_id = "reikwald_end_spawner_raw01",
					breed_name = "skaven_rat_ogre"
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_generic_long_level_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_small"
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_generic_long_level_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_generic_long_level_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_medium"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_generic_long_level_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner",
					composition_type = "event_medium"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"continue_when",
					duration = 50,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				}
	}

	TerrorEventBlueprints.reikwald_end_event_loop_extra_spice = {
				{
					"set_master_event_running",
					name = "reikwald_end_spice_starting"
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner_spice",
					composition_type = "event_small"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10
					end
				},
				{
					"delay",
					duration = 5
				},
				{
					"event_horde",
					spawner_id = "reikwald_end_spawner_spice",
					composition_type = "event_smaller"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 10 and count_breed("skaven_slave") < 10
					end
				},
				{
					"delay",
					duration = 5
				},
				{
					"flow_event",
					flow_event_name = "reikwald_end_event_loop_extra_spice_done"
				}
	}

	TerrorEventBlueprints.reikwald_wharf_event = {
				{
					"set_master_event_running",
					name = "reikwald_wharf_starting"
				},
				{
					"play_stinger",
					stinger_name = "enemy_horde_stinger"
				},
				{
					"spawn_at_raw",
					spawner_id = "reikwald_wharf_spawner_raw01",
					breed_name = "skaven_storm_vermin_commander"
				},
				{
					"spawn_at_raw",
					spawner_id = "reikwald_wharf_spawner_raw02",
					breed_name = "skaven_storm_vermin_commander"
				},
				{
					"spawn_at_raw",
					spawner_id = "reikwald_wharf_spawner_raw03",
					breed_name = "skaven_storm_vermin_commander"
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_medium"
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_docks_warehouse_extra_spice"
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_small"
				},
				{
					"spawn_at_raw",
					spawner_id = "reikwald_end_spawner_raw01",
					breed_name = "skaven_rat_ogre"
				},
				{
					"continue_when",
					duration = 20,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_docks_warehouse_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"continue_when",
					duration = 50,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_docks_warehouse_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"continue_when",
					duration = 50,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_docks_warehouse_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_small"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"continue_when",
					duration = 50,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				}
	}

	TerrorEventBlueprints.reikwald_wharf_event_part2 = {
				{
					"set_master_event_running",
					name = "reikwald_wharf_starting"
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_large"
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "magnus_end_patrol"
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5 and count_event_breed("skaven_storm_vermin_commander") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_docks_warehouse_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"continue_when",
					duration = 50,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_docks_warehouse_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					limit_spawners = 2,
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_generic_long_level_extra_spice"
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_large"
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						9,
						11
					}
				},
				{
					"event_horde",
					spawner_id = "reikwald_wharf_spawner",
					composition_type = "event_medium"
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"delay",
					duration = {
						3,
						4
					}
				},
				{
					"continue_when",
					duration = 50,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 5 and count_event_breed("skaven_slave") < 5
					end
				},
				{
					"control_pacing",
					enable = true
				}
	}

	-----------
	--River Reik

	TerrorEventBlueprints.reikwald_river_plaza_01 = {
				{
					"delay",
					duration = 5
				},
				{
					"spawn",
					{
						1
					},
					breed_name = "skaven_rat_ogre"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_landside_01 = {
				{
					"control_pacing",
					enable = false
				},
				{
					"control_specials",
					enable = false
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_gutter_runner"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"delay",
					duration = 5
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_landside_raw_01",
					breed_name = "skaven_rat_ogre"
				},
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_replace_left_01 = {
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_01_clan_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_01_clan_02",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_01_clan_03",
					breed_name = "skaven_gutter_runner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_01_clan_04",
					breed_name = "skaven_pack_master"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_01_captain",
					breed_name = "skaven_storm_vermin_commander"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_replace_right_01 = {
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_01_clan_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_01_clan_02",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_01_clan_03",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_01_clan_04",
					breed_name = "skaven_pack_master"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_01_captain",
					breed_name = "skaven_storm_vermin_commander"
				}
	}
	
	TerrorEventBlueprints.reikwald_river_sea_battle_right_01 = {
				{
					"event_horde",
					spawner_id = "sea_battle_right_01",
					composition_type = "event_medium"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4
					end
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_01",
					composition_type = "event_large"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_01",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 2 and count_breed("skaven_slave") < 2 and count_breed("skaven_storm_vermin_commander") < 3
					end
				},
				{
					"flow_event",
					flow_event_name = "reikwald_river_sea_battle_right_01_done"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_replace_left_02 = {
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_02_clan_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_02_clan_02",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_02_clan_03",
					breed_name = "skaven_gutter_runner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_02_captain",
					breed_name = "skaven_storm_vermin_commander"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_left_02 = {
				{
					"event_horde",
					spawner_id = "sea_battle_left_02",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_left_02",
					composition_type = "event_medium"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_left_02_storm",
					breed_name = "skaven_pack_master"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_left_02",
					composition_type = "event_large"
				},
				{
					"flow_event",
					flow_event_name = "reikwald_river_sea_battle_left_02_done"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_replace_right_02 = {
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_02_clan_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_02_clan_02",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_02_clan_03",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_02_clan_04",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_02_captain",
					breed_name = "skaven_storm_vermin_commander"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_right_02 = {
				{
					"event_horde",
					spawner_id = "sea_battle_right_02",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_02",
					composition_type = "event_medium"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_right_02_storm",
					breed_name = "skaven_pack_master"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_02",
					composition_type = "event_large"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"flow_event",
					flow_event_name = "reikwald_river_sea_battle_right_02_done"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_replace_left_03 = {
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_03_clan_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_03_clan_02",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_03_clan_03",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_left_03_captain",
					breed_name = "skaven_storm_vermin_commander"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_left_03 = {
				{
					"event_horde",
					spawner_id = "sea_battle_left_03",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_left_03",
					composition_type = "event_small"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"event_horde",
					spawner_id = "sea_battle_left_03",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"event_horde",
					spawner_id = "sea_battle_left_03",
					composition_type = "event_large"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"flow_event",
					flow_event_name = "reikwald_river_sea_battle_left_03_done"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_replace_right_03 = {
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_03_clan_01",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_03_clan_02",
					breed_name = "skaven_ratling_gunner"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_03_clan_03",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_03_clan_04",
					breed_name = "skaven_pack_master"
				},
				{
					"spawn_at_raw",
					spawner_id = "raw_skaven_ship_right_03_captain",
					breed_name = "skaven_storm_vermin_commander"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_right_03 = {
				{
					"event_horde",
					spawner_id = "sea_battle_right_03",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_03",
					composition_type = "event_medium"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_03",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_right_03_storm",
					breed_name = "skaven_pack_master"
				},
				{
					"spawn_at_raw",
					spawner_id = "sea_battle_right_03_storm",
					breed_name = "skaven_poison_wind_globadier"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_right_03",
					composition_type = "event_large"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4 and count_breed("skaven_storm_vermin_commander") < 4
					end
				},
				{
					"flow_event",
					flow_event_name = "reikwald_river_sea_battle_right_03_done"
				}
	}

	TerrorEventBlueprints.reikwald_river_sea_battle_front_03 = {
				{
					"event_horde",
					spawner_id = "sea_battle_front_03",
					composition_type = "event_small"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 2 and count_breed("skaven_slave") < 2
					end
				},
				{
					"event_horde",
					spawner_id = "sea_battle_front_03",
					composition_type = "event_generic_long_level_stormvermin"
				},
				{
					"event_horde",
					spawner_id = "sea_battle_front_03",
					composition_type = "event_small"
				},
				{
					"delay",
					duration = 10
				},
				{
					"continue_when",
					duration = 80,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 4 and count_breed("skaven_slave") < 4
					end
				},
				{
					"flow_event",
					flow_event_name = "reikwald_river_sea_battle_front_03_done"
				}
	}

	TerrorEventBlueprints.reikwald_river_shore_crash_01 = {
				{
					"event_horde",
					spawner_id = "shore_crash_01",
					composition_type = "event_reikwald_shore_mix"
				},
				{
					"delay",
					duration = 15
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_storm_vermin_commander") < 2
					end
				},
				{
					"event_horde",
					spawner_id = "shore_crash_01",
					composition_type = "event_reikwald_shore_mix"
				},
				{
					"delay",
					duration = 15
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_storm_vermin_commander") < 2
					end
				},
				{
					"event_horde",
					spawner_id = "shore_crash_01",
					composition_type = "event_reikwald_shore_mix"
				},
				{
					"delay",
					duration = 15
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_storm_vermin_commander") < 2
					end
				},
				{
					"event_horde",
					spawner_id = "shore_crash_01",
					composition_type = "event_reikwald_shore_mix"
				},
				{
					"delay",
					duration = 15
				},
				{
					"continue_when",
					duration = 40,
					condition = function (t)
						return count_event_breed("skaven_clan_rat") < 2 and count_event_breed("skaven_slave") < 2 and count_event_breed("skaven_storm_vermin_commander") < 2
					end
				},
				{
					"event_horde",
					spawner_id = "shore_crash_01",
					composition_type = "event_reikwald_shore_mix"
				}
	}

	HordeSettings.default.compositions.event_reikwald_shore_mix = {
				{
					name = "few_stormvermins",
					weight = 1,
					breeds = {
						"skaven_storm_vermin_commander",
						{
							5,
							8
						},
						"skaven_clan_rat",
						{
							5,
							6
						}
					}
				},
				{
					name = "some_slaves",
					weight = 1,
					breeds = {
						"skaven_slave",
						{
							22,
							23
						},
						"skaven_clan_rat",
						{
							5,
							6
						},
						"skaven_storm_vermin_commander",
						{
							1,
							2
						}
					}
				},
				{
					name = "few_clanrats",
					weight = 1,
					breeds = {
						"skaven_clan_rat",
						{
							12,
							15
						},
						"skaven_storm_vermin_commander",
						{
							2,
							3
						}
					}
				}
			}

	TerrorEventBlueprints.reikwald_river_gauntlet_01 = {
				{
					"event_horde",
					spawner_id = "gauntlet_01_front",
					composition_type = "event_reikwald_gauntlet_front_mix"
				},
				{
					"event_horde",
					spawner_id = "gauntlet_01",
					composition_type = "event_reikwald_gauntlet_mix"
				},
				{
					"delay",
					duration = 5
				},
				{
					"continue_when",
					duration = 30,
					condition = function (t)
						return count_breed("skaven_clan_rat") < 15 and count_breed("skaven_slave") < 10
					end
				},
				{
					"event_horde",
					spawner_id = "gauntlet_01_front",
					composition_type = "event_reikwald_gauntlet_front_mix"
				},
				{
					"event_horde",
					spawner_id = "gauntlet_01",
					composition_type = "event_reikwald_gauntlet_mix"
				}
	}

	-----------
	--Required Initialization

	local weights = {}

	for key, setting in pairs(HordeSettings) do
		if setting.compositions then
			for size, composition in pairs(setting.compositions) do
				table.clear_array(weights, #weights)

				for i, variant in ipairs(composition) do
					weights[i] = variant.weight
				end

				composition.loaded_probs = {
					LoadedDice.create(weights)
				}
			end
		end
	end

	CurrentHordeSettings.compositions = HordeSettings.default.compositions

	Mods.hook.set("Gamemodes", "GameModeManager.complete_level", function(func, self)
		local total = 0
		local mission_system = Managers.state.entity:system("mission_system")
		local active_mission = mission_system.active_missions

		-- Add Death Wish Grimoires
		local rank = Managers.state.difficulty:get_difficulty_rank()

		if deathwishtoken and rank == 5 then
			for i = 1,2 do
				mission_system.request_mission(mission_system, "grimoire_hidden_mission", nil, Network.peer_id())
				mission_system.update_mission(mission_system, "grimoire_hidden_mission", true, nil, Network.peer_id(), nil, true)
			end
		end

		-- Add Onslaught Grimoire
		if onslaughttoken then
			mission_system.request_mission(mission_system, "grimoire_hidden_mission", nil, Network.peer_id())
			mission_system.update_mission(mission_system, "grimoire_hidden_mission", true, nil, Network.peer_id(), nil, true)
		end

		-- Add Mutation dice.
		if mutationtoken then
			for i = 1,5 do
				mission_system.request_mission(mission_system, "bonus_dice_hidden_mission", nil, Network.peer_id())
				mission_system.update_mission(mission_system, "bonus_dice_hidden_mission", true, nil, Network.peer_id(), nil, true)
			end
		end

		-- Calculate the total
		for name, obj in pairs(active_mission) do
			if name == "tome_bonus_mission" or name == "grimoire_hidden_mission" or name == "bonus_dice_hidden_mission" then
				total = total + obj.current_amount 
			end
		end
	
		-- Remove if there are to much total
		if active_mission.bonus_dice_hidden_mission then
			for i = 1, active_mission.bonus_dice_hidden_mission.current_amount do
				if total > 7 then
					mission_system.request_mission(mission_system,  "bonus_dice_hidden_mission", nil, Network.peer_id())
					mission_system.update_mission(mission_system,  "bonus_dice_hidden_mission", false, nil, Network.peer_id(), nil, true)
				
					total = total - 1
				end
			end
		end
	
		if active_mission.tome_bonus_mission then
			for i = 1, active_mission.tome_bonus_mission.current_amount do
				if total > 7 then
					mission_system.request_mission(mission_system,  "tome_bonus_mission", nil, Network.peer_id())
					mission_system.update_mission(mission_system,  "tome_bonus_mission", false, nil, Network.peer_id(), nil, true)
				
					total = total - 1
				end
			end
		end
	
		if active_mission.grimoire_hidden_mission then
			for i = 1, active_mission.grimoire_hidden_mission.current_amount do
				if total > 7 then
					mission_system.request_mission(mission_system,  "grimoire_hidden_mission", nil, Network.peer_id())
					mission_system.update_mission(mission_system,  "grimoire_hidden_mission", nil, Network.peer_id(), false, nil, true)
		
					total = total - 1
				end
			end
		end
	
		-- Call orginal function
		func(self)

		return
	end)

	Mods.hook.front("Gamemodes", "GameModeManager.complete_level")

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

	if not slayertoken then
		slayertoken = false
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

	Managers.chat:send_system_chat_message(1, "Adventure Mode : Onslaught ENABLED.", 0, true)
else
	onslaughttoken = false

	TerrorEventBlueprints = OriginalTerrorEventBlueprints
	HordeSettings.default.compositions = OriginalHordeSettings
	CurrentHordeSettings.compositions = OriginalCurrentHordeSettings

	BossSettings.default.boss_events.events = {
		"boss_event_rat_ogre",
		"boss_event_storm_vermin_patrol",
		"nothing"
	}

	BossSettings.default.boss_events.max_events_of_this_kind = {
		boss_event_rat_ogre = 1
	}

	LevelSettings.city_wall.boss_events.recurring_distance = 200
	LevelSettings.city_wall.boss_events.padding_distance = 100
	LevelSettings.city_wall.boss_events.max_events_of_this_kind = {
		boss_event_storm_vermin_patrol = 1
	}


	PackSpawningSettings.area_density_coefficient = 5
	PackSpawningSettings.squezed_rats_per_10_meter = 10

	SpecialsSettings.default.max_specials = 3

	SpecialsSettings.default.methods.specials_by_time_window.spawn_interval = {
		90,
		120
	}

	SpecialsSettings.default.methods.specials_by_time_window.lull_time = {
		20,
		40
	}

	SpecialsSettings.default.methods.specials_by_slots.after_safe_zone_delay = {
		5,
		150	
	}

	SpecialsSettings.default.methods.specials_by_slots.spawn_cooldown = {
		100,
		200
	}

	PacingSettings.default.horde_frequency = {
		90,
		180
	}

	PacingSettings.default.relax_duration = {
		35,
		45
	}

	PacingSettings.default.peak_intensity_threshold = 35

	PacingSettings.default.peak_fade_threshold = 32.5

	PacingSettings.default.sustain_peak_duration = {
		3,
		5
	}

	PacingSettings.default.mini_patrol.only_spawn_below_intensity = 25

	PacingSettings.default.mini_patrol.frequency = {
		7,
		15
	}

	PacingSettings.city_wall.horde_frequency = {
		120,
		180
	}

	PacingSettings.city_wall.relax_duration = {
		25,
		35
	}

	PacingSettings.city_wall.peak_intensity_threshold = 35

	PacingSettings.city_wall.peak_fade_threshold = 32.5

	PacingSettings.city_wall.sustain_peak_duration = {
		3,
		5
	}

	PacingSettings.city_wall.mini_patrol.only_spawn_below_intensity = 65

	PacingSettings.city_wall.mini_patrol.frequency = {
		10,
		15
	}

	BreedActions.skaven_storm_vermin_champion.spawn_sequence.considerations.time_since_last.max_value = 2200

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn = {
			harder = "stormdorf_boss_event_defensive_harder",
			normal = "stormdorf_boss_event_defensive_normal",
			hard = "stormdorf_boss_event_defensive_hard",
			survival_hard = "stormdorf_boss_event_defensive_hard",
			survival_harder = "stormdorf_boss_event_defensive_hard",
			hardest = "stormdorf_boss_event_defensive_hardest",
			survival_hardest = "stormdorf_boss_event_defensive_hard",
			easy = "stormdorf_boss_event_defensive_easy"
		}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.easy = {
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.normal = {
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.hard = {
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.spawn_allies.difficulty_spawn_list.harder = {
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin",
				"skaven_storm_vermin"
			}

	BreedActions.skaven_storm_vermin_champion.special_attack_spin.ignore_staggers = {
			true,
			true,
			true,
			true,
			true,
			false
		}

	BreedActions.skaven_storm_vermin_champion.defensive_mode_spin.ignore_staggers = {
			true,
			true,
			true,
			true,
			true,
			false
		}

	Mods.hook.enable(false, "Gamemodes", "Breeds.skaven_storm_vermin_champion.run_on_update")

	if not deathwishtoken and not mutationtoken then
		Mods.hook.enable(false, "Gamemodes", "GameModeManager.complete_level")
	end

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

	Managers.chat:send_system_chat_message(1, "Adventure Mode : Onslaught DISABLED.", 0, true)
end