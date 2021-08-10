local mod_name = "LobbyImprovements"

LobbyImprovements = {
    SETTINGS = {
        POPUP = {
            ["save"] = "cb_join_hero_popup",
            ["widget_type"] = "checkbox",
            ["text"] = "Always Show Hero Popup",
            ["tooltip"] = "Always Show Hero Popup\n" ..
                          "Always show the hero select popup before joining a lobby, even if your current hero is available.\n",
            ["default"] = false,
        },
        SKIP_COUNTDOWN = {
            ["save"] = "cb_join_skip_countdown",
            ["widget_type"] = "checkbox",
            ["text"] = "Skip Preparation Countdown",
            ["tooltip"] = "Skip Preparation Countdown\n" ..
                          "Skip the preperation countdown when joining a lobby or when starting a hosted game.\n",
            ["default"] = false,
        },
        TELEPORT = {
            ["save"] = "cb_teleport_to_host",
            ["widget_type"] = "checkbox",
            ["text"] = "Spawn Near Host",
            ["tooltip"] = "Spawn Near host\n" ..
                          "Change your spawn location to be close to the host after joining a lobby, if it otherwise would be too far away from any player.\n" ..
                          "If the host is dead, you will spawn next to another player.\n",
            ["default"] = false,
        },
        HIDE_BLACKLIST = {
            ["save"] = "cb_hide_blacklist",
            ["widget_type"] = "checkbox",
            ["text"] = "Hide Blacklisted Lobbies",
            ["tooltip"] = "Hide Blacklisted Lobbies\n" ..
                          "Don't show blacklisted lobbies in the lobby browser.\n" ..
                          "If not enabled, blacklisted lobbies will show in red.\n",
            ["default"] = false,
        },
    }
}

LobbyImprovements.get = function(data)
    return Application.user_setting(data.save)
end

LobbyImprovements.get_current_hero_index = function()
    local peer_id = Network.peer_id()
    local player = Managers.player:player_from_peer_id(peer_id)
    local player_idx = (player and player.profile_index) or 0

    return player_idx
end

LobbyImprovements.is_hero_available_in_lobby = function(hero_index, lobby_data)
    local player_slot_name = "player_slot_" .. tostring(hero_index)
    local player_id = lobby_data[player_slot_name]

    if not player_id then
        return true
    end

    if player_id == "available" then
        return true
    end

    local local_player = Managers.player:local_player()
    local local_player_id = local_player.profile_id(local_player)

    if player_id == local_player_id then
        return true
    end

    return false
end

LobbyImprovements.is_teleport_available = function(player)
    local player_unit = player.player_unit

    if not player_unit or not Unit.alive(player_unit) then
        return false
    end

    local status_extension = ScriptUnit.extension(player_unit, "status_system")

    if not status_extension then
        return false
    end

    return not status_extension.is_disabled(status_extension)
end

LobbyImprovements.is_player_near = function(pos, exclude_player)
    local current_players = Managers.player:human_players()

    for _,player in pairs(current_players) do
        if player.peer_id ~= exclude_player then
            local player_unit = player.player_unit

            if player_unit and Unit.alive(player_unit) then
                local status_extension = ScriptUnit.extension(player_unit, "status_system")

                if status_extension then
                    if not status_extension.is_disabled(status_extension) then
                        local player_pos = POSITION_LOOKUP[player_unit]

                        if Vector3.distance(pos, player_pos) < LobbyImprovements.min_distance_for_teleport then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

LobbyImprovements.valid_lobby_for_pinging = function(lobby_data)
    local is_valid = lobby_data.valid
    local host = lobby_data.host or lobby_data.Host
    local is_matchmaking = lobby_data.matchmaking and lobby_data.matchmaking ~= "false"
    local level_key = lobby_data.selected_level_key or lobby_data.level_key
    local difficulty = lobby_data.difficulty
    local num_players = tonumber(lobby_data.num_players)

    if not is_valid or not host or host == "0" or not is_matchmaking or not level_key or not difficulty or num_players == MatchmakingSettings.MAX_NUMBER_OF_PLAYERS then
        return false
    end

    return true
end

LobbyImprovements.setup_ping = function(lobby_data)
    local host_id = lobby_data.host or lobby_data.Host
    local from_ping_list = LobbyImprovements.ping_list[host_id]

    Steamworks.ClosePeerConnection(host_id)

    if from_ping_list then
        LobbyImprovements.ping_list[host_id].connected = false
        LobbyImprovements.ping_list[host_id].packet_expire = nil
        LobbyImprovements.ping_list[host_id].ping_time = nil
        LobbyImprovements.ping_list[host_id].ping_timeout = (Application.time_since_launch() * 1000) + LobbyImprovements.ping_timeout
        
        return host_id
    end

    LobbyImprovements.ping_list[host_id] = {
        connected = false,
        packet_expire = nil,
        ping_time = nil,
        ping_timeout = (Application.time_since_launch() * 1000) + LobbyImprovements.ping_timeout,
        ping = nil
    }

    return host_id
end

LobbyImprovements.ping = function(host_id)
    local from_ping_list = LobbyImprovements.ping_list[host_id]
    local ctime = Application.time_since_launch() * 1000

    if ctime > from_ping_list.ping_timeout then
        return -1
    end

    local ping = 0

    if not from_ping_list.connected then
        local host_address = Steamworks.CreatePeerConnection(host_id, "0")

        if host_address and host_address ~= "0" then
            LobbyImprovements.ping_list[host_id].connected = true
        end
    else
        local packet = Steamworks.ReadPacketFromPeer(host_id, "4")

        if packet ~= nil then
            ping = round((Application.time_since_launch() * 1000) - LobbyImprovements.ping_list[host_id].ping_time)
        else
            ctime = Application.time_since_launch() * 1000

            if not from_ping_list.packet_expire or ctime >= from_ping_list.packet_expire then
                if Steamworks.SendPacketToPeer(host_id, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\0", "0") then
                    LobbyImprovements.ping_list[host_id].packet_expire = ctime + LobbyImprovements.packet_expire_time
                    LobbyImprovements.ping_list[host_id].ping_time = Application.time_since_launch() * 1000
                end
            end
        end
    end

    return math.max(ping, 0)
end

LobbyImprovements.finish_ping = function(host_id)
    Steamworks.ClosePeerConnection(host_id)

    LobbyImprovements.ping_list[host_id].connected = false
    LobbyImprovements.ping_list[host_id].packet_expire = nil
    LobbyImprovements.ping_list[host_id].ping_time = nil

    return
end

LobbyImprovements.end_pinging = function()
    for host_id,_ in pairs(LobbyImprovements.ping_list) do
        LobbyImprovements.ping_list[host_id].ping_timeout = nil
    end
end

LobbyImprovements.read_blacklist = function()
    LobbyImprovements.blacklist = {}

    local fp = io.open(LobbyImprovements.blacklist_file, "rt")

    if fp then
        for line in fp:lines() do
            LobbyImprovements.blacklist[#LobbyImprovements.blacklist + 1] = line
        end

        io.close(fp)
    end

    return
end

LobbyImprovements.write_blacklist = function()
    local fp = io.open(LobbyImprovements.blacklist_file, "wt")

    for _,host_id in ipairs(LobbyImprovements.blacklist) do
        fp.write(fp, host_id .. "\n")
    end

    io.close(fp)

    return
end

LobbyImprovements.is_lobby_blacklisted = function(lobby_data)
    local lobby_host_id = lobby_data.host or lobby_data.Host

    if not lobby_host_id or lobby_host_id == "0" then
        return false
    end

    if LobbyImprovements.blacklist == nil then
        LobbyImprovements.read_blacklist()
    end

    for _,host_id in ipairs(LobbyImprovements.blacklist) do
        if host_id == lobby_host_id then
            return true
        end
    end

    return false
end

LobbyImprovements.add_to_blacklist = function(lobby_data)
    local lobby_host_id = lobby_data.host or lobby_data.Host

    if not lobby_host_id or lobby_host_id == "0" then
        return
    end

    if LobbyImprovements.blacklist == nil then
        LobbyImprovements.read_blacklist()
    end

    LobbyImprovements.blacklist[#LobbyImprovements.blacklist + 1] = lobby_host_id

    LobbyImprovements.write_blacklist()

    return
end

LobbyImprovements.remove_from_blacklist = function(lobby_data)
    local lobby_host_id = lobby_data.host or lobby_data.Host

    if not lobby_host_id or lobby_host_id == "0" then
        return
    end

    if LobbyImprovements.blacklist == nil then
        LobbyImprovements.read_blacklist()
    end

    local _new_blacklist = {}

    for _,host_id in ipairs(LobbyImprovements.blacklist) do
        if host_id ~= lobby_host_id then
            _new_blacklist[#_new_blacklist + 1] = host_id
        end
    end

    LobbyImprovements.blacklist = _new_blacklist

    LobbyImprovements.write_blacklist()

    return
end


LobbyImprovements.apply_lobby_red_filter = function(style)
    for k,v in pairs(style) do
        if v.text_color then
            style[k].text_color = Colors.color_definitions.red
        end
    end

    return style
end

LobbyImprovements.update_steam_gameinfo = function(lobby_id)
    local current_hero_index = LobbyImprovements.get_current_hero_index()

    if current_hero_index < 1 then
        return false
    end

    local lobby_data = LobbyInternal.get_lobby_data_from_id(lobby_id)

    if not lobby_data then
        return false
    end

    local lobby_host = lobby_data.host or lobby_data.Host

    if not lobby_host then
        return false
    end

    local lobby_name = LobbyImprovements.make_utf8_valid(lobby_data.server_name or lobby_data.unique_server_name or lobby_host)
    local num_players = lobby_data.num_players or 0
    local level_name = LobbyImprovements.lobby_level_display_name(lobby_data)
    local difficulty = LobbyImprovements.lobby_difficulty_display_name(lobby_data)
    local status = LobbyImprovements.lobby_status_text(lobby_data)
    local current_hero = SPProfiles[current_hero_index]
    local current_hero_name = Localize(current_hero.display_name)

    local status_string = "Lobby: " .. lobby_name .. ", Players: " .. num_players .. "/4\n" ..
                          "Level: " .. level_name .. ", Difficulty: " .. difficulty .. "\n" ..
                          "Status: " .. status .. ", Playing as: " .. current_hero_name .. "\n"

    if status_string ~= LobbyImprovements.current_status_string then
        if Steamworks.SetGameInfo(lobby_id, status_string) then
            LobbyImprovements.current_status_string = status_string
        end
    end

    return true
end

LobbyImprovements.browser_scenegraph_definition = {
    root = {
        is_root = true,
        position = {
            0,
            0,
            UILayer.default
        },
        size = {
            1920,
            1080
        }
    },
    dead_space_filler = {
        scale = "fit",
        position = {
            0,
            0,
            0
        },
        size = {
            1920,
            1280
        }
    },
    screen = {
        scale = "fit",
        position = {
            0,
            0,
            UILayer.default - 2
        },
        size = {
            1920,
            1080
        }
    },
    lobby_root = {
        vertical_alignment = "center",
        parent = "root",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            0
        },
        size = {
            1920,
            1080
        }
    },
    background = {
        vertical_alignment = "center",
        parent = "screen",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            -1
        },
        size = {
            1920,
            1080
        }
    },
    title_text = {
        vertical_alignment = "top",
        parent = "background",
        horizontal_alignment = "center",
        position = {
            0,
            -10,
            1
        },
        size = {
            420,
            28
        }
    },
    back_button = {
        parent = "background",
        horizontal_alignment = "right",
        position = {
            -60,
            40,
            1
        },
        size = {
            220,
            62
        }
    },
    lobby_list_frame = {
        vertical_alignment = "top",
        parent = "background",
        horizontal_alignment = "right",
        position = {
            -50,
            -70,
            2
        },
        size = {
            1414,
            900
        }
    },
    lobby_list_title_line = {
        vertical_alignment = "top",
        parent = "lobby_list_frame",
        horizontal_alignment = "center",
        position = {
            10,
            -37,
            -1
        },
        size = {
            1373,
            8
        }
    },
    join_button = {
        parent = "lobby_list_frame",
        horizontal_alignment = "left",
        position = {
            30,
            -70,
            1
        },
        size = {
            220,
            62
        }
    },
    blacklist_button = {
        parent = "lobby_list_frame",
        horizontal_alignment = "center",
        position = {
            7,
            -70,
            1
        },
        size = {
            220,
            62
        }
    },
    ping_button = {
        parent = "lobby_list_frame",
        horizontal_alignment = "center",
        position = {
            -278,
            -70,
            1
        },
        size = {
            220,
            62
        }
    },
    ping_button_all = {
        parent = "lobby_list_frame",
        horizontal_alignment = "center",
        position = {
            292,
            -70,
            1
        },
        size = {
            220,
            62
        }
    },
    status_fade = {
        vertical_alignment = "center",
        parent = "background",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            100
        },
        size = {
            1920,
            1080
        }
    },
    status_background = {
        vertical_alignment = "center",
        parent = "status_fade",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            571,
            279
        }
    },
    status_title = {
        vertical_alignment = "top",
        parent = "status_background",
        horizontal_alignment = "center",
        position = {
            0,
            -14,
            1
        },
        size = {
            260,
            32
        }
    },
    status_text = {
        vertical_alignment = "center",
        parent = "status_background",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            571,
            50
        }
    },
    status_cancel_button = {
        vertical_alignment = "bottom",
        parent = "status_background",
        horizontal_alignment = "center",
        position = {
            0,
            -31,
            1
        },
        size = {
            220,
            62
        }
    },
    invalid_checkbox = {
        parent = "root",
        position = {
            40,
            1000,
            1
        },
        size = {
            200,
            34
        }
    },
    filter_frame = {
        vertical_alignment = "top",
        parent = "background",
        horizontal_alignment = "left",
        position = {
            30,
            -70,
            2
        },
        size = {
            375,
            900
        }
    },
    game_mode_stepper = {
        vertical_alignment = "top",
        parent = "filter_frame",
        horizontal_alignment = "left",
        position = {
            60,
            -83,
            1
        },
        size = {
            240,
            32
        }
    },
    game_mode_banner = {
        parent = "game_mode_stepper",
        position = {
            -45,
            40,
            1
        },
        size = {
            340,
            56
        }
    },
    game_mode_banner_text = {
        vertical_alignment = "center",
        parent = "game_mode_banner",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            340,
            40
        }
    },
    level_stepper = {
        vertical_alignment = "top",
        parent = "game_mode_stepper",
        horizontal_alignment = "left",
        position = {
            0,
            -128,
            1
        },
        size = {
            240,
            32
        }
    },
    level_banner = {
        parent = "level_stepper",
        position = {
            -45,
            40,
            1
        },
        size = {
            340,
            56
        }
    },
    level_banner_text = {
        vertical_alignment = "center",
        parent = "level_banner",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            340,
            40
        }
    },
    difficulty_stepper = {
        vertical_alignment = "top",
        parent = "level_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            -128,
            0
        },
        size = {
            240,
            32
        }
    },
    difficulty_banner = {
        parent = "difficulty_stepper",
        position = {
            -45,
            40,
            1
        },
        size = {
            340,
            56
        }
    },
    difficulty_banner_text = {
        vertical_alignment = "center",
        parent = "difficulty_banner",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            340,
            40
        }
    },
    show_lobbies_stepper = {
        vertical_alignment = "top",
        parent = "difficulty_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            -128,
            0
        },
        size = {
            240,
            32
        }
    },
    show_lobbies_banner = {
        parent = "show_lobbies_stepper",
        position = {
            -45,
            40,
            1
        },
        size = {
            340,
            56
        }
    },
    show_lobbies_banner_text = {
        vertical_alignment = "center",
        parent = "show_lobbies_banner",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            340,
            40
        }
    },
    distance_stepper = {
        vertical_alignment = "top",
        parent = "show_lobbies_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            -128,
            0
        },
        size = {
            240,
            32
        }
    },
    distance_banner = {
        parent = "distance_stepper",
        position = {
            -45,
            40,
            1
        },
        size = {
            340,
            56
        }
    },
    distance_banner_text = {
        vertical_alignment = "center",
        parent = "distance_banner",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            1
        },
        size = {
            340,
            40
        }
    },
    gamepad_node_game_mode_stepper = {
        vertical_alignment = "center",
        parent = "game_mode_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            10
        },
        size = {
            270,
            67
        }
    },
    gamepad_node_level_stepper = {
        vertical_alignment = "center",
        parent = "level_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            10
        },
        size = {
            270,
            67
        }
    },
    gamepad_node_difficulty_stepper = {
        vertical_alignment = "center",
        parent = "difficulty_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            10
        },
        size = {
            270,
            67
        }
    },
    gamepad_node_show_lobbies_stepper = {
        vertical_alignment = "center",
        parent = "show_lobbies_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            10
        },
        size = {
            270,
            67
        }
    },
    gamepad_node_distance_stepper = {
        vertical_alignment = "center",
        parent = "distance_stepper",
        horizontal_alignment = "center",
        position = {
            0,
            0,
            10
        },
        size = {
            270,
            67
        }
    },
    reset_button = {
        vertical_alignment = "top",
        parent = "search_button",
        horizontal_alignment = "center",
        position = {
            0,
            120,
            1
        },
        size = {
            318,
            84
        }
    },
    filter_divider = {
        vertical_alignment = "bottom",
        parent = "search_button",
        horizontal_alignment = "center",
        position = {
            0,
            93,
            2
        },
        size = {
            301,
            18
        }
    },
    search_button = {
        vertical_alignment = "bottom",
        parent = "filter_frame",
        horizontal_alignment = "center",
        position = {
            0,
            20,
            1
        },
        size = {
            318,
            84
        }
    },
    gamepad_stepper_selection = {
        vertical_alignment = "bottom",
        parent = "filter_frame",
        horizontal_alignment = "left",
        position = {
            0,
            0,
            1
        },
        size = {
            240,
            32
        }
    },
    frame_divider = {
        vertical_alignment = "top",
        parent = "background",
        horizontal_alignment = "left",
        position = {
            420,
            -150,
            2
        },
        size = {
            36,
            746
        }
    },
    left_frame_glow = {
        vertical_alignment = "center",
        parent = "frame_divider",
        horizontal_alignment = "center",
        position = {
            -72,
            0,
            -1
        },
        size = {
            144,
            758
        }
    },
    right_frame_glow = {
        vertical_alignment = "center",
        parent = "frame_divider",
        horizontal_alignment = "center",
        position = {
            72,
            0,
            -1
        },
        size = {
            144,
            758
        }
    },
    reset_button_octagon = {
        vertical_alignment = "top",
        parent = "distance_stepper",
        horizontal_alignment = "center",
        position = {
            -70,
            -80,
            1
        },
        size = {
            64,
            64
        }
    },
    search_button_octagon = {
        vertical_alignment = "top",
        parent = "distance_stepper",
        horizontal_alignment = "center",
        position = {
            70,
            -80,
            1
        },
        size = {
            64,
            64
        }
    }
}

LobbyImprovements.create_lobby_list_entry_style = function()
    local style = {
        background = {
            size = {
                1348,
                45
            },
            offset = {
                0,
                0,
                1
            }
        },
        locked_level = {
            size = {
                20,
                26
            },
            offset = {
                360,
                10,
                3
            }
        },
        locked_difficulty = {
            size = {
                20,
                26
            },
            offset = {
                610,
                10,
                3
            }
        },
        locked_status = {
            size = {
                20,
                26
            },
            offset = {
                830,
                10,
                3
            }
        },
        title_text = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            font_type = "hell_shark",
            size = {
                1348,
                45
            },
            text_color = Colors.color_definitions.white,
            font_size = 18,
            offset = {
                10,
                0,
                2
            }
        },
        level_text = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            font_type = "hell_shark",
            size = {
                1348,
                45
            },
            text_color = Colors.color_definitions.white,
            font_size = 18,
            offset = {
                380,
                0,
                2
            }
        },
        difficulty_text = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            font_type = "hell_shark",
            size = {
                1348,
                45
            },
            text_color = Colors.color_definitions.white,
            font_size = 18,
            offset = {
                630,
                0,
                2
            }
        },
        num_players_text = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            font_type = "hell_shark",
            size = {
                1348,
                45
            },
            text_color = Colors.color_definitions.white,
            font_size = 18,
            offset = {
                750,
                0,
                2
            }
        },
        status_text = {
            vertical_alignment = "center",
            horizontal_alignment = "left",
            font_type = "hell_shark",
            size = {
                1348,
                45
            },
            text_color = Colors.color_definitions.white,
            font_size = 18,
            offset = {
                850,
                0,
                2
            }
        },
        hero_icon_1 = {
            size = { 30, 26 },
            offset = {
                950,
                8,
                3
            }
        },
        hero_icon_2 = {
            size = { 30, 26 },
            offset = {
                982,
                8,
                3
            }
        },
        hero_icon_3 = {
            size = { 30, 26 },
            offset = {
                1014,
                8,
                3
            }
        },
        hero_icon_4 = {
            size = { 30, 26 },
            offset = {
                1046,
                8,
                3

            }
        },
        hero_icon_5 = {
            size = { 30, 26 },
            offset = {
                1078,
                8,
                3
            }
        },
        country_text = {
            vertical_alignment = "center",
            horizontal_alignment = "right",
            font_type = "hell_shark",
            size = {
                1348,
                45
            },
            text_color = Colors.color_definitions.white,
            font_size = 18,
            offset = {
                -5,
                0,
                2
            }
        }
    }

    return style
end

LobbyImprovements.make_utf8_valid = function(str)
    while not Utf8.valid(str) do
        local length = string.len(str)

        if length == 1 then
            str = ""
        else
            str = string.sub(str, 1, length - 1)
        end
    end

    return str
end

LobbyImprovements.lobby_level_display_name = function(lobby_data)
    local level = lobby_data.selected_level_key or lobby_data.level_key
    local level_setting = level and LevelSettings[level]
    local level_display_name = level and level_setting.display_name
    local level_text = (level and Localize(level_display_name)) or "-"

    return level_text
end

LobbyImprovements.lobby_difficulty_display_name = function(lobby_data)
    local difficulty = lobby_data.difficulty
    local difficulty_setting = difficulty and DifficultySettings[difficulty]
    local difficulty_display_name = difficulty and difficulty_setting.display_name
    local difficulty_text = (difficulty and Localize(difficulty_display_name)) or "-"

    return difficulty_text
end

LobbyImprovements.lobby_status_text = function(lobby_data)
    local is_private = lobby_data.matchmaking == "false"
    local is_full = lobby_data.num_players == MatchmakingSettings.MAX_NUMBER_OF_PLAYERS
    local is_in_inn = lobby_data.level_key == "inn_level"
    local is_broken = lobby_data.is_broken
    local status = (is_broken and "lb_broken") or (is_private and "lb_private") or (is_full and "lb_full") or (is_in_inn and "lb_in_inn") or "lb_started"
    local status_text = (status and Localize(status)) or ""

    return status_text
end

LobbyImprovements.sort_lobbies_on_heroes_asc = function(lobby_a, lobby_b)
    local current_hero_index = LobbyImprovements.get_current_hero_index()

    local hero_available_a = LobbyImprovements.is_hero_available_in_lobby(current_hero_index, lobby_a) and 1 or 0
    local hero_available_b = LobbyImprovements.is_hero_available_in_lobby(current_hero_index, lobby_b) and 1 or 0

    return hero_available_b < hero_available_a
end

LobbyImprovements.sort_lobbies_on_heroes_desc = function(lobby_a, lobby_b)
    local current_hero_index = LobbyImprovements.get_current_hero_index()

    local hero_available_a = LobbyImprovements.is_hero_available_in_lobby(current_hero_index, lobby_a) and 1 or 0
    local hero_available_b = LobbyImprovements.is_hero_available_in_lobby(current_hero_index, lobby_b) and 1 or 0

    return hero_available_a < hero_available_b
end

LobbyImprovements.sort_lobbies_on_country_ping_asc = function(lobby_a, lobby_b)
    local value_a = LobbyImprovements.lobby_country_text(lobby_a)
    local value_b = LobbyImprovements.lobby_country_text(lobby_b)

    if type(value_a) == type(value_b) then
        return value_a < value_b
    elseif type(value_a) == "number" then
        return true
    else
        return false
    end
end

LobbyImprovements.sort_lobbies_on_country_ping_desc = function(lobby_a, lobby_b)
    local value_a = LobbyImprovements.lobby_country_text(lobby_a)
    local value_b = LobbyImprovements.lobby_country_text(lobby_b)

    if type(value_a) == type(value_b) then
        return value_b < value_a
    elseif type(value_a) == "number" then
        return false
    else
        return true
    end
end

LobbyImprovements.lobby_heroes_icons = function(lobby_data)
    local heroes_icons = {
        "icon_loot_trinket_witch_hunter",
        "icon_loot_trinket_bright_wizard",
        "icon_loot_trinket_dwarf_ranger",
        "icon_loot_trinket_waywatcher",
        "icon_loot_trinket_empire_soldier"
        }

    local active_icons = {}

    for i=5,1,-1 do
        local player_slot = "player_slot_" .. i

        if lobby_data[player_slot] and lobby_data[player_slot] ~= "available" then
            active_icons[#active_icons + 1] = heroes_icons[i]
        end
    end

    return active_icons
end

LobbyImprovements.lobby_country_text = function(lobby_data)
    local country_code = lobby_data.country_code
    local country_text = (country_code and iso_countries[country_code]) or ""

    local host_id = lobby_data.host or lobby_data.Host
    local value = country_text

    for k,v in pairs(LobbyImprovements.ping_list) do
        if k == host_id then
            if v.ping ~= nil then
                return v.ping
            end

            break
        end
    end

    local country_code = lobby_data.country_code
    local country_text = (country_code and iso_countries[country_code]) or ""

    return country_text
end

LobbyImprovements.level_is_locked = function(lobby_data)
    local level = lobby_data.selected_level_key or lobby_data.level_key

    if not level then
        return false
    end

    local in_inn = lobby_data.level_key == "inn_level"

    if in_inn then
        return false
    end

    local player_manager = Managers.player
    local player = player_manager.local_player(player_manager)
    local statistics_db = player_manager.statistics_db(player_manager)
    local player_stats_id = player.stats_id(player)
    local level_unlocked = LevelUnlockUtils.level_unlocked(statistics_db, player_stats_id, level)

    if not level_unlocked then
        return true
    end

    return 
end

LobbyImprovements.difficulty_is_locked = function(lobby_data)
    local level_key = lobby_data.selected_level_key or lobby_data.level_key
    local player_manager = Managers.player
    local player = player_manager.local_player(player_manager)
    local statistics_db = player_manager.statistics_db(player_manager)
    local player_stats_id = player.stats_id(player)
    local difficulty = lobby_data.difficulty

    if not difficulty or not level_key then
        return false
    end

    local in_inn = lobby_data.level_key == "inn_level"

    if in_inn then
        return false
    end

    local unlocked_level_difficulty_index = LevelUnlockUtils.unlocked_level_difficulty_index(statistics_db, player_stats_id, level_key)

    if not unlocked_level_difficulty_index then
        return true
    end

    local difficulty_manager = Managers.state.difficulty
    local level_difficulties = difficulty_manager.get_level_difficulties(difficulty_manager, level_key)
    local unlocked_difficulty_key = level_difficulties[unlocked_level_difficulty_index]
    local unlocked_difficulty_settings = DifficultySettings[unlocked_difficulty_key]
    local difficulty_setting = DifficultySettings[difficulty]

    if unlocked_difficulty_settings.rank < difficulty_setting.rank then
        return true
    end

    return 
end

LobbyImprovements.status_is_locked = function(lobby_data)
    local num_players = lobby_data.num_players
    local matchmaking = lobby_data.matchmaking

    if not num_players or not matchmaking then
        return false
    end

    local is_private = lobby_data.matchmaking == "false"
    local is_full = lobby_data.num_players == MatchmakingSettings.MAX_NUMBER_OF_PLAYERS
    local is_broken = lobby_data.is_broken

    return is_broken or is_full or is_private
end

LobbyImprovements.create_lobby_list_entry_content = function(lobby_data)
    local my_peer_id = Network:peer_id()
    local host = lobby_data.host or lobby_data.Host
    local title_text = LobbyImprovements.make_utf8_valid(lobby_data.server_name or lobby_data.unique_server_name or host)

    if host == my_peer_id or not title_text then
        return 
    end

    local level_text = LobbyImprovements.lobby_level_display_name(lobby_data)
    local num_players_text = lobby_data.num_players or 0
    local difficulty_text = LobbyImprovements.lobby_difficulty_display_name(lobby_data)
    local status_text = LobbyImprovements.lobby_status_text(lobby_data)
    local heroes_icons = LobbyImprovements.lobby_heroes_icons(lobby_data)
    local is_invalid = not lobby_data.valid
    local status_text_parsed = (is_invalid and "[INV]" .. status_text) or status_text
    local country_text = LobbyImprovements.lobby_country_text(lobby_data)
    local content = {
        locked_difficulty = "locked_icon_01",
        locked_status = "locked_icon_01",
        background_selected = "lb_list_item_clicked",
        background_normal_hover = "lb_list_item_hover",
        visible = true,
        background_selected_hover = "lb_list_item_clicked",
        background_normal = "lb_list_item_normal",
        locked_level = "locked_icon_01",
        button_hotspot = {},
        lobby_data = lobby_data,
        title_text = title_text,
        level_text = level_text,
        difficulty_text = difficulty_text,
        num_players_text = num_players_text .. "/4",
        status_text = status_text_parsed,
        country_text = country_text,
        level_is_locked = LobbyImprovements.level_is_locked(lobby_data),
        difficulty_is_locked = LobbyImprovements.difficulty_is_locked(lobby_data),
        status_is_locked = LobbyImprovements.status_is_locked(lobby_data)
    }

    for i=1,5 do
        content["hero_icon_"..i] = ""
    end

    for i,hero_icon in ipairs(heroes_icons) do
        content["hero_icon_"..i] = hero_icon
    end 

    return content
end

LobbyImprovements.create_empty_lobby_list_entry_content = function()
    local content = {
        difficulty_text = "",
        title_text = "",
        num_players_text = "",
        background_normal = "lb_list_item_bg",
        background_normal_hover = "lb_list_item_bg",
        fake = true,
        country_text = "",
        background_selected = "lb_list_item_bg",
        level_text = "",
        status_text = "",
        background_selected_hover = "lb_list_item_bg",
        button_hotspot = {}
    }

    for i=1,5 do
        content["hero_icon_"..i] = ""
    end

    return content
end

LobbyImprovements.min_distance_for_teleport = 15

LobbyImprovements.max_list_entries = 100

LobbyImprovements.blacklist_file = "mods/patch/storage/blacklist.db"

LobbyImprovements.ping_timeout = 10000
LobbyImprovements.packet_expire_time = 2500
LobbyImprovements.ping_list = {}

LobbyImprovements.gameinfo_update_interval = 25
LobbyImprovements.gameinfo_next_update = 0
LobbyImprovements.current_status_string = ""

-- ####################################################################################################################
-- ##### Options ######################################################################################################
-- ####################################################################################################################
LobbyImprovements.create_options = function()
    Mods.option_menu:add_group("lobby_improvements", "Lobby Improvements")
    Mods.option_menu:add_item("lobby_improvements", LobbyImprovements.SETTINGS.POPUP, true)
    Mods.option_menu:add_item("lobby_improvements", LobbyImprovements.SETTINGS.SKIP_COUNTDOWN, true)
    Mods.option_menu:add_item("lobby_improvements", LobbyImprovements.SETTINGS.TELEPORT, true)
    Mods.option_menu:add_item("lobby_improvements", LobbyImprovements.SETTINGS.HIDE_BLACKLIST, true)
end

LobbyImprovements.create_lobby_buttons = function()
    LobbyImprovements.heroes_button = UIWidgets.create_text_button("heroes_text_button", "Heroes", 18)
    LobbyImprovements.heroes_button.style.text.localize = false
    LobbyImprovements.heroes_button.style.text_hover.localize = false

    LobbyImprovements.blacklist_button = UIWidgets.create_menu_button_medium("Blacklist", "blacklist_button", true)

    LobbyImprovements.ping_button_single = UIWidgets.create_menu_button_medium("Ping", "ping_button", true)
    LobbyImprovements.ping_button_all = UIWidgets.create_menu_button_medium("Ping All", "ping_button_all", true)

    LobbyImprovements.country_ping_button = UIWidgets.create_text_button("country_text_button", "Country/Ping", 18)
    LobbyImprovements.country_ping_button.style.text.localize = false
    LobbyImprovements.country_ping_button.style.text_hover.localize = false
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################
Mods.hook.set(mod_name, "LobbyItemsList.populate_lobby_list", function(func, self, lobbies, ignore_scroll_reset)
    local settings = self.settings
    local item_list_widget = self.item_list_widget
    local list_content = {}
    local list_style = self.list_style
    local num_lobbies = 0
    local sort_func = self.sort_lobbies_function
    local selected_lobby = self.selected_lobby(self)
    local lobbies_array = self.convert_to_array(self, lobbies)

    if sort_func then
        self.sort_lobbies(self, lobbies_array, sort_func)
    end

    for lobby_id, lobby_data in pairs(lobbies_array) do
        local style = LobbyImprovements.create_lobby_list_entry_style()
        local content = LobbyImprovements.create_lobby_list_entry_content(lobby_data)

        if content then
            local blacklisted = LobbyImprovements.is_lobby_blacklisted(lobby_data)

            if blacklisted then
                style = LobbyImprovements.apply_lobby_red_filter(style)
            end

            if not blacklisted or not LobbyImprovements.get(LobbyImprovements.SETTINGS.HIDE_BLACKLIST) then
                num_lobbies = num_lobbies + 1
                list_content[num_lobbies] = content
                list_style.item_styles[num_lobbies] = style

                if LobbyImprovements.max_list_entries <= num_lobbies then
                    break
                end
            end
        end
    end

    self.lobbies = lobbies_array
    self.number_of_items_in_list = num_lobbies
    item_list_widget.content.list_content = list_content
    item_list_widget.style.list_style = list_style
    item_list_widget.style.list_style.start_index = 1
    item_list_widget.style.list_style.num_draws = settings.num_list_items
    item_list_widget.element.pass_data[1].num_list_elements = nil
    local num_draws = item_list_widget.style.list_style.num_draws

    if num_lobbies < num_draws then
        local num_empty = num_draws - num_lobbies%num_draws

        if num_empty <= num_draws then
            for i = 1, num_empty, 1 do
                local content = LobbyImprovements.create_empty_lobby_list_entry_content()
                local style = LobbyImprovements.create_lobby_list_entry_style()
                local index = #list_content + 1
                list_content[index] = content
                list_style.item_styles[index] = style
            end
        end
    end

    self.set_scrollbar_length(self, nil, ignore_scroll_reset)

    if selected_lobby then
        self.set_selected_lobby(self, selected_lobby)
    else
        self.on_lobby_selected(self, 1, false)
    end

    return 
end)

Mods.hook.set(mod_name, "MatchmakingStateJoinGame.on_enter", function(func, self, state_context)
    if not LobbyImprovements.get(LobbyImprovements.SETTINGS.POPUP) then
        return func(self, state_context)
    else
        self.lobby_data = state_context.profiles_data
        self.state_context = state_context
        self.lobby_client = state_context.lobby_client
        self.join_lobby_data = state_context.join_lobby_data
        self.lobby_data.selected_level_key = self.join_lobby_data.selected_level_key
        self.lobby_data.difficulty = self.join_lobby_data.difficulty
        local matchmaking_manager = self.matchmaking_manager
        local hero_index, hero_name = self._current_hero(self)

        assert(hero_index, "no hero index? this is wrong")

        self.wanted_profile_index = hero_index

        self.show_popup = true

        self.matchmaking_manager:set_status_message("matchmaking_status_joining_game")

        self._update_lobby_data_timer = 0
    end

    return
end)

Mods.hook.set(mod_name, "LevelCountdownUI.rpc_start_game_countdown", function(func, self, sender)
    func(self, sender)

    if LobbyImprovements.get(LobbyImprovements.SETTINGS.SKIP_COUNTDOWN) and Managers.player.is_server then
        self.enter_game_timer = 1
        self.total_start_game_time = 0
        self.last_timer_value = 0

        self.play_sound(self, "Play_hud_matchmaking_countdown_final")

        local widget = self.countdown_widget
        local widget_content = widget.content

        widget_content.info_text = ""
        widget_content.timer_text = Localize("game_starts_prepare")
    end

    return
end)

Mods.hook.set(mod_name, "MatchmakingStateStartGame.update_start_game_timer", function(func, self, dt)
    if not LobbyImprovements.get(LobbyImprovements.SETTINGS.SKIP_COUNTDOWN) then
        return func(self, dt)
    end

    self.start_game_timer = nil

    return true
end)

Mods.hook.set(mod_name, "PlayerManager.rpc_to_client_spawn_player", function(func, self, sender, local_player_id, profile_index, position, rotation, is_initial_spawn, ammo_melee_percent_int, ammo_ranged_percent_int, healthkit_id, potion_id, grenade_id)
   func(self, sender, local_player_id, profile_index, position, rotation, is_initial_spawn, ammo_melee_percent_int, ammo_ranged_percent_int, healthkit_id, potion_id, grenade_id) 

   if LobbyImprovements.get(LobbyImprovements.SETTINGS.TELEPORT) then
        local my_player = self:local_player()

        if not my_player.is_server then
            local level_key = Managers.state.game_mode.level_transition_handler:get_current_level_keys()

            if level_key and level_key ~= "inn_level" then
                local cutscene_system = Managers.state.entity:system("cutscene_system")
                local active_cutscene = nil

                if cutscene_system then
                    active_cutscene = cutscene_system.active_camera
                end

                if not active_cutscene then
                    if not is_initial_spawn and not LobbyImprovements.is_player_near(position, my_player.peer_id) then
                        local current_players = self:human_players()
                        local teleport_to_player = nil

                        for _,player in pairs(current_players) do
                            if player.peer_id == sender then
                                if LobbyImprovements.is_teleport_available(player) then
                                    teleport_to_player = player
                                end

                                break
                            end
                        end

                        if not teleport_to_player then
                            for _,player in pairs(current_players) do
                                if player.peer_id ~= sender and player.peer_id ~= my_player.peer_id then
                                    if LobbyImprovements.is_teleport_available(player) then
                                        teleport_to_player = player
                                        break
                                    end
                                end
                            end
                        end

                        if teleport_to_player then
                            local tp_pos = POSITION_LOOKUP[teleport_to_player.player_unit]

                            if tp_pos then
                                if LobbyImprovements.is_teleport_available(my_player) then
                                    local my_player_unit = my_player.player_unit
                                    local locomotion_extension = ScriptUnit.extension(my_player_unit, "locomotion_system")

                                    if locomotion_extension then
                                        local distance_delta = math.floor(Vector3.distance(position, tp_pos))
                                        --EchoConsole("Teleporting to player " .. Steam.user_name(teleport_to_player.peer_id) .. "... Distance: " .. tostring(distance_delta))
                                        locomotion_extension.teleport_to(locomotion_extension, tp_pos)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return
end)

Mods.hook.set(mod_name, "LobbyBrowseView.create_ui_elements", function(func, self)
    func(self)

    self.blacklist_button = UIWidget.init(LobbyImprovements.blacklist_button)
    self.ping_button_single = UIWidget.init(LobbyImprovements.ping_button_single)
    self.ping_button_all = UIWidget.init(LobbyImprovements.ping_button_all)

    return
end)

Mods.hook.set(mod_name, "LobbyBrowseView._handle_input", function(func, self, dt)
    local blacklist_button_hotspot = self.blacklist_button.content.button_hotspot

    if blacklist_button_hotspot.on_hover_enter then
        self.play_sound(self, "Play_hud_hover")
    end

    if blacklist_button_hotspot.on_release and not blacklist_button_hotspot.disabled then
        self.play_sound(self, "Play_hud_select")
        blacklist_button_hotspot.on_release = nil

        local lobby = self.lobby_list:selected_lobby()

        if not LobbyImprovements.is_lobby_blacklisted(lobby) then
            LobbyImprovements.add_to_blacklist(lobby)
        else
            LobbyImprovements.remove_from_blacklist(lobby)
        end

        self.lobby_list.populate_list_for_blacklist = true
    end

    local ping_button_all_hotspot = self.ping_button_all.content.button_hotspot

    if ping_button_all_hotspot.on_hover_enter then
        self.play_sound(self, "Play_hud_hover")
    end

    if ping_button_all_hotspot.on_release and not ping_button_all_hotspot.disabled then
        self.play_sound(self, "Play_hud_select")
        ping_button_all_hotspot.on_release = nil

        if not self.lobby_list.ping_all then
            self.lobby_list.ping_all = true
        else
            self.lobby_list.cancel_pinging = true
        end
    end

    local ping_button_single_hotspot = self.ping_button_single.content.button_hotspot

    if ping_button_single_hotspot.on_hover_enter then
        self.play_sound(self, "Play_hud_hover")
    end

    if ping_button_single_hotspot.on_release and not ping_button_single_hotspot.disabled then
        self.play_sound(self, "Play_hud_select")
        ping_button_single_hotspot.on_release = nil
        self.lobby_list.ping_selected = true
    end

    return func(self, dt)
end)

Mods.hook.set(mod_name, "LobbyBrowseView.update", function(func, self, dt)
    if not self.buttons_initialized then
        self.ui_scenegraph = UISceneGraph.init_scenegraph(LobbyImprovements.browser_scenegraph_definition)
        self.buttons_initialized = true
    end

    local blacklist_button_hotspot = self.blacklist_button.content.button_hotspot
    local ping_button_all_hotspot = self.ping_button_all.content.button_hotspot
    local ping_button_single_hotspot = self.ping_button_single.content.button_hotspot

    local lobby = self.lobby_list:selected_lobby()

    if not lobby then
        self.blacklist_button.content.text_field = "Blacklist"
        blacklist_button_hotspot.disabled = true
    elseif not LobbyImprovements.is_lobby_blacklisted(lobby) then
        self.blacklist_button.content.text_field = "Blacklist"
        blacklist_button_hotspot.disabled = false
    else
        self.blacklist_button.content.text_field = "Unblacklist"
        blacklist_button_hotspot.disabled = false
    end

    if not self.lobby_list.lobbies or #self.lobby_list.lobbies < 1 then
        self.ping_button_all.content.text_field = "Ping All"
        ping_button_all_hotspot.disabled = true
        ping_button_single_hotspot.disabled = true
    elseif self.lobby_list.ping_selected then
        self.ping_button_all.content.text_field = "Ping All"
        ping_button_all_hotspot.disabled = true
        ping_button_single_hotspot.disabled = true
    elseif not self.lobby_list.ping_all then
        self.ping_button_all.content.text_field = "Ping All"
        ping_button_all_hotspot.disabled = false

        if lobby and LobbyImprovements.valid_lobby_for_pinging(lobby) then
            ping_button_single_hotspot.disabled = false
        else
            ping_button_single_hotspot.disabled = true
        end
    else
        self.ping_button_all.content.text_field = "Cancel Ping"
        ping_button_all_hotspot.disabled = false
        ping_button_single_hotspot.disabled = true
    end

    func(self, dt)

    local ui_renderer = self.ui_renderer
    local input_manager = self.input_manager
    local input_service = self.input_service(self)
    local ui_scenegraph = self.ui_scenegraph
    local gamepad_active = input_manager.is_device_active(input_manager, "gamepad")

    if self.active then
        if not gamepad_active then
            UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt)
            UIRenderer.draw_widget(ui_renderer, self.blacklist_button)
            UIRenderer.draw_widget(ui_renderer, self.ping_button_single)
            UIRenderer.draw_widget(ui_renderer, self.ping_button_all)
            UIRenderer.end_pass(ui_renderer)
        end
    end

    return
end)

Mods.hook.set(mod_name, "LobbyItemsList.create_ui_elements", function(func, self)
    self.scenegraph_definition.players_text_button.position = {750, 0, 2}
    self.scenegraph_definition.status_text_button.position = {850, 0, 2}

    local _heroes_text_button = {
        parent = "label_root",
        horizontal_alignment = "left",
        position = {950, 0, 2},
        size = {
                110,
                40
               }
    }

    self.scenegraph_definition.heroes_text_button = _heroes_text_button

    local passes = self.widget_definitions.inventory_list_widget.element.passes[1].passes

    for i=1,5 do
        local found_pass = false

        for _,pass in ipairs(passes) do
            if pass.style_id == "hero_icon_"..i then
                found_pass = true
                break
            end
        end

        if not found_pass then
            local _heroes_pass = {
                pass_type = "texture",
                style_id = "hero_icon_"..i,
                texture_id = "hero_icon_"..i,
                content_check_function = function(ui_content)
                    return ui_content and ui_content["hero_icon_"..i] ~= ""
                end
            }
            self.widget_definitions.inventory_list_widget.element.passes[1].passes[#self.widget_definitions.inventory_list_widget.element.passes[1].passes + 1] = _heroes_pass
        end
    end

    self.ui_scenegraph = UISceneGraph.init_scenegraph(self.scenegraph_definition)
    local scrollbar_scenegraph_id = "scrollbar_root"
    local scrollbar_scenegraph = self.scenegraph_definition[scrollbar_scenegraph_id]
    self.scrollbar_widget = UIWidget.init(UIWidgets.create_scrollbar(scrollbar_scenegraph.size[2], scrollbar_scenegraph_id))
    self.item_list_widget = UIWidget.init(self.widget_definitions.inventory_list_widget)
    self.scroll_field_widget = UIWidget.init(self.widget_definitions.scroll_field)
    self.host_text_button = UIWidget.init(self.widget_definitions.host_text_button)
    self.level_text_button = UIWidget.init(self.widget_definitions.level_text_button)
    self.difficulty_text_button = UIWidget.init(self.widget_definitions.difficulty_text_button)
    self.players_text_button = UIWidget.init(self.widget_definitions.players_text_button)
    self.status_text_button = UIWidget.init(self.widget_definitions.status_text_button)
    self.heroes_text_button = UIWidget.init(LobbyImprovements.heroes_button)
    self.country_text_button = UIWidget.init(LobbyImprovements.country_ping_button)
    self.loading_overlay = UIWidget.init(self.widget_definitions.loading_overlay)
    self.loading_icon = UIWidget.init(self.widget_definitions.loading_icon)
    self.loading_text = UIWidget.init(self.widget_definitions.loading_text)
    self.country_text_button.style.text.horizontal_alignment = "right"
    self.country_text_button.style.text_hover.horizontal_alignment = "right"

    UIRenderer.clear_scenegraph_queue(self.ui_renderer)

    return
end)

Mods.hook.set(mod_name, "LobbyItemsList.draw", function(func, self, dt)
    func(self, dt)

    local ui_renderer = self.ui_renderer
    local ui_scenegraph = self.ui_scenegraph
    local input_manager = self.input_manager
    local input_service = input_manager.get_service(input_manager, self.input_service_name)

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt)
    UIRenderer.draw_widget(ui_renderer, self.heroes_text_button)
	UIRenderer.end_pass(ui_renderer)

    return
end)

Mods.hook.set(mod_name, "LobbyItemsList.update", function(func, self, dt, loading, ignore_gamepad_input)
    local lobbies = self.lobbies

    if self.populate_list_for_blacklist then
        self.populate_lobby_list(self, lobbies, true)
        self.populate_list_for_blacklist = false
    end

    if self.cancel_pinging then
        if self.current_ping_lobby ~= nil then
            LobbyImprovements.finish_ping(self.current_ping_lobby)
        end

        self.current_ping_lobby = nil

        self.ping_all = false
        self.ping_selected = false
        self.cancel_pinging = false
        LobbyImprovements.end_pinging()
    elseif self.ping_all then
        if self.current_ping_lobby ~= nil then
            local ping = LobbyImprovements.ping(self.current_ping_lobby)

            if ping ~= 0 then
                LobbyImprovements.finish_ping(self.current_ping_lobby)

                if ping > 0 then
                    LobbyImprovements.ping_list[self.current_ping_lobby].ping = ping
                    self.populate_lobby_list(self, self.lobbies, true)
                end

                self.current_ping_lobby = nil
            end
        else
            for _,lobby in ipairs(lobbies) do
                local host_id = lobby.host or lobby.Host

                if host_id then
                    local found = false

                    for k,v in pairs(LobbyImprovements.ping_list) do
                        if k == host_id and LobbyImprovements.ping_list[host_id].ping_timeout ~= nil then
                            found = true
                            break
                        end
                    end

                    if not found then
                        if LobbyImprovements.valid_lobby_for_pinging(lobby) then
                            self.current_ping_lobby = LobbyImprovements.setup_ping(lobby)
                            break
                        end
                    end
                end
            end

            if self.current_ping_lobby == nil then
                self.ping_all = false
                LobbyImprovements.end_pinging()
            end
        end
    elseif self.ping_selected then
        if self.current_ping_lobby ~= nil then
            local ping = LobbyImprovements.ping(self.current_ping_lobby)

            if ping ~= 0 then
                LobbyImprovements.finish_ping(self.current_ping_lobby)

                if ping > 0 then
                    LobbyImprovements.ping_list[self.current_ping_lobby].ping = ping
                    self.populate_lobby_list(self, self.lobbies, true)
                end

                self.current_ping_lobby = nil
                self.ping_selected = false
                LobbyImprovements.end_pinging()
            end
        else
            local lobby = self.selected_lobby(self)

            if lobby and LobbyImprovements.valid_lobby_for_pinging(lobby) then
                self.current_ping_lobby = LobbyImprovements.setup_ping(lobby)
            else
                self.ping_selected = false
            end
        end
    end
    
    local country_ping_button_pressed = self.country_text_button.content.button_text.on_pressed
    self.country_text_button.content.button_text.on_pressed = nil

    func(self, dt, loading, ignore_gamepad_input)

    local heroes_button_hotspot = self.heroes_text_button.content.button_text

    if heroes_button_hotspot.on_pressed then
        local sort_func = self._pick_sort_func(self, LobbyImprovements.sort_lobbies_on_heroes_asc, LobbyImprovements.sort_lobbies_on_heroes_desc)
        local lobbies = self.lobbies

        self.populate_lobby_list(self, lobbies, true)
        self.play_sound(self, "Play_hud_select")
    end

    if country_ping_button_pressed then
        local sort_func = self._pick_sort_func(self, LobbyImprovements.sort_lobbies_on_country_ping_asc, LobbyImprovements.sort_lobbies_on_country_ping_desc)
        local lobbies = self.lobbies

        self.populate_lobby_list(self, lobbies, sort_func)
        self.play_sound(self, "Play_hud_select")
    end

    return
end)

Mods.hook.set(mod_name, "LobbyHost.update", function(func, self, dt)
    local t = Application.time_since_launch()
    local lobby_id = self:id()

    if t >= LobbyImprovements.gameinfo_next_update and lobby_id then
        if LobbyImprovements.update_steam_gameinfo(lobby_id) then
            LobbyImprovements.gameinfo_next_update = t + LobbyImprovements.gameinfo_update_interval
        end
    end

    return func(self, dt)
end)

Mods.hook.set(mod_name, "LobbyClient.update", function(func, self, dt)
    local t = Application.time_since_launch()
    local lobby_id = self:id()

    if t >= LobbyImprovements.gameinfo_next_update and lobby_id then
        if LobbyImprovements.update_steam_gameinfo(lobby_id) then
            LobbyImprovements.gameinfo_next_update = t + LobbyImprovements.gameinfo_update_interval
        end
    end

    return func(self, dt)
end)

-- ####################################################################################################################
-- ##### Start ########################################################################################################
-- ####################################################################################################################
LobbyImprovements.create_options()
LobbyImprovements.create_lobby_buttons()