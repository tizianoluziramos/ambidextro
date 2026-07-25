extends Node

@export var level_container: Node2D
@export var win_player: AudioStreamPlayer
@export var reset_player: AudioStreamPlayer
@export var change_level_audio: AudioStreamPlayer
@export var level_counter_screen: PackedScene
@export var save_load: Node
@export var menu_loader: Node
@export var music_controller: Node
@export var general_input_controller: Node
@export var CRT_shader: Node
@export var subviewport_container: SubViewportContainer
@export var touch_controllers: Array[Node]

var level_list: Array[String]
var level_index: int
var current_level_instance: Node
var level_counter_instance: Node
const _PATH_OPENING: String = "res://scenes/levels/"
const _PATH_ENDING: String = ".tscn"

var _save_file: int
var _death_count: int
var _reset_count: int
var _retry_count: int
var _time: float
var _speedrun_time: float
var _queue_reset_level: bool
var _data: Dictionary
var _when_winning_behaviour: int
var _levels_mode: bool
var _achievements_data: Dictionary
var _achievements_dictionary: Dictionary
var _speedrun_time_already_loaded: bool

var _used_accessibility: bool


var _cutscenes: bool
var _random: bool
var _mirror: int
var _swap: int

var random_levels_index: int
var random_levels_order: Array[int]
var levels_mirror: Array[bool]
var levels_swap: Array[bool]

var _players: Array[Node]

var _playing: bool
var _normal_timer_running: bool
var _speedrun_timer_running: bool
var _speedrun_timer_finished: bool

var _keyboard_test_pending: bool
var _queue_disable_player_charas: bool

var _cubes_states: Array

func _ready() -> void :
    add_to_group("level_loader")

    Global.first_input.connect(_manage_keyboard_test)

    level_list = [

        "tutorial", 

        "basic_zigzags", 
        "medium_zigzags", 
        "advanced_zigzags", 
        "labyrinth", 
        "different_paths", 

        "one_way_platforms", 
        "jump_trap", 
        "reflexes", 
        "one_way_jumps", 
        "one_way_final_2", 



        "lateral_spikes", 
        "simple_spikes", 
        "medium_difference", 
        "ceiling_spikes", 
        "advanced_spikes", 

        "crumbling_platforms", 
        "slow_descent", 
        "bigger_difference", 
        "spike_pit", 
        "spike_balls", 



        "first_glass", 
        "glass_head_break", 
        "spike_castle", 

        "first_trampoline", 
        "spiked_arms", 
        "cactus", 

        "forced_piston", 
        "piston_glass", 
        "wait_before_crumble", 
        "spiked_bars", 




        "first_moving_spikeball", 
        "inversed", 
        "laydown_s", 
        "spike_wings", 
        "spikeball_platforms", 

        "first_switch", 
        "switch_escape", 
        "bars_bridge", 
        "trampoline_chain", 
        "descent_to_switch", 



        "trident", 
        "platforms_over_spikes", 
        "taking_turns", 
        "first_vertical_platforms", 
        "elevators", 

        "first_button", 
        "spiky_swapped_buttons", 
        "retractile_platforms", 
        "falling_floor", 
        "ceiling_bars", 




        "first_mace", 
        "first_piston_old", 
        "maces_rope_jump", 
        "maces_and_trampolines", 
        "mace_sync_jump", 

        "first_box", 
        "reverse_boxes", 
        "spiky_piston", 
        "switches_and_boxes", 
        "double_pendulum", 





        "first_smasher", 
        "riding_smashers", 
        "maces_and_smashers", 
        "baiting_smashers", 
        "smasher_block", 

        "first_projectiles", 
        "unsinchronized_projectiles", 
        "second_pistons", 
        "projectiles_on_platforms", 
        "boxes_from_avobe", 





        "first_quantum_blocks", 
        "quantum_platforms", 
        "quantum_over_spikes", 
        "curled_tee", 
        "quantum_on_moving_platforms", 

        "first_directional_block", 
        "directional_blocks_path", 
        "directional_block_jumps", 
        "directional_steps", 
        "directional_block_rows", 




        "first_toggle_platform", 
        "toggle_catwalk", 
        "falls", 
        "alternate_jumps", 
        "alternating_platforms", 

        "first_swapper", 
        "spiky_situation", 
        "double_jump", 
        "shooter_swap", 
        "swapped_start", 



        "switches_on_double_maces", 
        "high_button", 
        "toggles_and_trampolines", 
        "cross", 
        "fire_columns", 
        "projectiles_in_corridors", 
        "stack_boxes", 
        "quantum_gaps", 
        "quick_buttons", 
        "limited_floor", 


        "scrolling_level"













        ]





func _process(delta: float) -> void :
    if _speedrun_timer_running && !_speedrun_timer_finished:
        _speedrun_time += delta
        Global.speedrun_time = _speedrun_time

    if _queue_disable_player_charas:
        _disable_player_charas()

    if _normal_timer_running:
        _time += delta

    if !_playing: return

    if Input.is_action_just_pressed("reset"):
        if !_get_players(): return
        if _players[0].disable_reset || _players[1].disable_reset: return
        if level_index == 101 && Global.game_ended: return

        _reset_effect()
        if !_players[0].is_first_input_emited() && !_players[1].is_first_input_emited(): return
        reset_player.play()
        reset_level(true)

    elif Global.allow_debug_controls && Input.is_action_just_pressed("next_level"):
        unload_level()
        next_level(true)

    elif Global.allow_debug_controls && Input.is_action_just_pressed("previous_level"):
        unload_level()
        previous_level()


func set_playing(state: bool):
    _playing = state

    if Global.mobile:
        subviewport_container.adapt_level_screen_for_mobile()
        if _playing:
            for tc in touch_controllers:
                tc.enable()
        else:
            for tc in touch_controllers:
                tc.disable()


func set_normal_timer_running(state: bool):
    _normal_timer_running = state


func set_speedrun_timer_running(state: bool):
    _speedrun_timer_running = state



func set_speedrun_timer_finished(state: bool):
    _speedrun_timer_finished = state


func _physics_process(_delta: float) -> void :
    if _queue_reset_level:
        _queue_reset_level = false
        _do_reset_level()


func load_stats(save_file: int, stats: Dictionary):
    _levels_mode = false
    _when_winning_behaviour = 0
    _save_file = save_file
    level_index = stats["level"]
    random_levels_index = stats.get("random_levels_index", 0)
    _retry_count = stats["retries"]
    _time = stats["time"]

    if !_speedrun_time_already_loaded:
        _speedrun_time_already_loaded = true
        _speedrun_time = stats["speedrun_time"]
    _data = stats.duplicate()
    Global.in_story_mode = true

    set_normal_timer_running(true)
    set_speedrun_timer_running(true)


    _used_accessibility = stats.get("used_accessibility", false)
    Global.extra_time = stats.get("extra_time", 0)

    if stats.get("speedrun_timer", 0) == 1:
        Global.speedrun_mode = true
    else:
        Global.speedrun_mode = false

    if stats.get("speedrun_pausable", 0) == 1:
        Global.speedrun_pausable = true
    else:
        Global.speedrun_pausable = false

    if stats.get("cutscenes", 0) == 1:
        _cutscenes = false
    else:
        _cutscenes = true

    if stats.get("order", 0) == 0:
        _random = false
    else:
        _random = true
        if random_levels_index == 0:
            _randomize_levels(0)
        else:
            random_levels_order = stats["random_levels_order"]

    _mirror = stats.get("mirror", 0)
    _swap = stats.get("swap", 0)
    if level_index == 0 || (_random && random_levels_index == 0):
        if _mirror == 2:
            _randomize_mirrors()
        if _swap == 2:
            _randomize_swaps()
    else:
        if _mirror == 2:
            levels_mirror = stats["levels_mirror"]
        if _swap == 2:
            levels_swap = stats["levels_swap"]


func start_music_and_timer():
    _play_levels_music()
    set_speedrun_timer_finished(false)
    set_speedrun_timer_running(true)


func load_single_level_options(level: int, when_winning_option: int, mirror: int, swap: int):
    _used_accessibility = false
    Global.in_story_mode = false
    _levels_mode = true
    _when_winning_behaviour = when_winning_option
    level_index = level

    if _when_winning_behaviour == 2:
        _random = true
        random_levels_index = 0
        _randomize_levels(level)
    else:
        _random = false

    _mirror = mirror
    _swap = swap

    if _mirror:
        _randomize_mirrors()
    if _swap:
        _randomize_swaps()

    _play_levels_music()


func _randomize_levels(first_level: int):
    random_levels_order.clear()
    for i in range(0, 101):
        if i == first_level: continue
        random_levels_order.append(i)
    random_levels_order.shuffle()
    random_levels_order.push_front(first_level)
    if first_level != 101:
        random_levels_order.append(101)
    random_levels_index = 0


func _randomize_mirrors():
    levels_mirror.resize(102)
    for i in range(0, 102):
        levels_mirror[i] = true if randf_range(0, 1) < 0.5 else false


func _randomize_swaps():
    levels_swap.resize(102)
    for i in range(0, 102):
        levels_swap[i] = true if randf_range(0, 1) < 0.5 else false


func set_keyboard_test_pending(state: bool):
    _keyboard_test_pending = state


func next_level(instantly: bool):
    _cancel_level_counter_screen()

    win_player.play()
    _cubes_states.clear()

    if !instantly: _manage_achievements()

    if current_level_instance:
        current_level_instance.queue_free()
        current_level_instance = null

    if instantly:
        if _random:
            random_levels_index += 1
            if random_levels_index >= random_levels_order.size():
                random_levels_index = 0
            level_index = random_levels_order[random_levels_index]
        else:
            level_index += 1
            if level_index > 101:
                level_index = 1
            save()

        call_play_music()
        load_level()
        return

    if !_levels_mode && level_index == 100 && ( !_random || random_levels_index == 100):
        if _random:
            random_levels_index += 1
            level_index = random_levels_order[random_levels_index]
        else:
            level_index += 1
        save()
        if _data.get("cutscenes", 0) == 0:
            menu_loader.load_intro_cutscene(_save_file, _data, true)
        else:
            load_level()
            call_play_music()
        return

    level_counter_instance = level_counter_screen.instantiate()
    level_counter_instance.audio = change_level_audio
    level_counter_instance.set_level_number(get_level_number_string())
    level_container.add_child.call_deferred(level_counter_instance)


    if _when_winning_behaviour == 0 && !_random:
        level_index += 1
        var max_level: int = 100
        if save_load.is_last_level_unlocked(): max_level = 101
        if level_index > max_level: level_index = 1

        if Global.extra_time > 0:
            _used_accessibility = true
        save()
    elif _random:
        random_levels_index += 1
        if random_levels_index >= random_levels_order.size():
            random_levels_index = 0
        level_index = random_levels_order[random_levels_index]

    level_counter_instance.change_level_to_number(get_level_number_string()).connect(load_level)

    call_play_music()


func previous_level():

    if _cancel_level_counter_screen():
        level_index -= 1

    win_player.play()
    _cubes_states.clear()

    if _random:
        _set_previous_random_level()
    else:
        level_index -= 1
    if level_index < 0: level_index = 0

    if current_level_instance != null && !current_level_instance.is_queued_for_deletion():
        current_level_instance.queue_free()
        current_level_instance = null

    load_level()
    call_play_music()


func reset_level(from_button: bool):

    if _cancel_level_counter_screen():
        level_index -= 1

    if !from_button: _reset_effect()
    if level_index > 0:
        if from_button:
            _reset_count += 1
        else:
            _death_count += 1
        _retry_count += 1

    _queue_reset_level = true


func _reset_effect():
    music_controller.death_distortion()
    CRT_shader.death_distortion()


func _do_reset_level():
    if level_index == 101:
        menu_loader.unload_end_credits()
        menu_loader.music_controller.reset_last_level_music()

    if current_level_instance:
        current_level_instance.queue_free()
        current_level_instance = null

    load_level()
    _reset_quantum_cubes.call_deferred()



func _reset_quantum_cubes():
    _cubes_states = current_level_instance.get_child(0).initialize_quantum_cubes(_cubes_states)


func load_level():
    Global.game_ended = false

    set_playing(true)
    menu_loader.set_playing(true)

    _manage_keyboard_test()

    var level_name = level_list[level_index] if level_list[level_index] != "" else "_template"

    var next_level_resource = load(_PATH_OPENING + level_name + _PATH_ENDING)
    current_level_instance = next_level_resource.instantiate()
    Global.current_level_layout = current_level_instance.get_child(0)

    if level_index == 0:
        current_level_instance.general_input_controller = general_input_controller
        current_level_instance.set_keys()
    elif level_index == 101:
        current_level_instance.menu_loader = menu_loader
    level_container.add_child.call_deferred(current_level_instance)

    if _mirror == 1:
        current_level_instance.get_child(0).mirror()
        Global.mirrored = true
    elif _mirror == 2:
        if levels_mirror[random_levels_index]:
            current_level_instance.get_child(0).mirror()
            Global.mirrored = true
        else:
            Global.mirrored = false
    else:
        Global.mirrored = false

    if level_index == 0 && Global.mirrored:
        current_level_instance.mirror_tutorial()

    if _swap == 1:
        current_level_instance.get_child(0).swap()
        if level_index == 0:
            current_level_instance.swap_tutorial()
    elif _swap == 2:
        if levels_swap[random_levels_index]:
            current_level_instance.get_child(0).swap()
            if level_index == 0:
                current_level_instance.swap_tutorial()

    _update_labels()

    _get_original_quantum_cubes.call_deferred()

    get_tree().paused = false


func _get_original_quantum_cubes():
    if _cubes_states.is_empty():
        _cubes_states = current_level_instance.get_child(0).get_original_quantum_cubes_states()


func call_play_music():
    if _random:
        if random_levels_index == 0 && random_levels_order[random_levels_index] != 0:
            music_controller.change_level_music(1)
        else:
            music_controller.change_level_music(random_levels_index)
    else:
        music_controller.change_level_music(level_index)


func _play_levels_music():
    if _random:
        if random_levels_index == 0 && random_levels_order[random_levels_index] != 0:
            music_controller.play_levels_music(1)
        else:
            music_controller.play_levels_music(random_levels_index)
    else:
        music_controller.play_levels_music(level_index)



func save():
    if !Global.in_story_mode: return

    if level_index == 101:
        save_load.unlock_last_level()
        if _data.get("ended", false) == true: return

    _data["level"] = level_index
    _data["retries"] = _retry_count
    _data["time"] = _time
    _data["speedrun_time"] = _speedrun_time
    _data["extra_time"] = Global.extra_time
    if _used_accessibility:
        _data["used_accessibility"] = true

    if _random:
        _data["random_levels_index"] = random_levels_index
        _data["random_levels_order"] = random_levels_order

    if _mirror == 2:
        _data["levels_mirror"] = levels_mirror
    if _swap == 2:
        _data["levels_swap"] = levels_swap

    save_load.save_data("save_file_" + str(_save_file), _data.duplicate())


func save_ending():
    if !Global.in_story_mode: return

    if _data.get("ended", false) == true: return

    save_load.unlock_last_level()
    _data["level"] = level_index
    _data["retries"] = _retry_count
    _data["time"] = _time
    _data["speedrun_time"] = _speedrun_time
    _data["ended"] = true

    if _random:
        _data["random_levels_index"] = random_levels_index
        _data["random_levels_order"] = random_levels_order

    if _mirror == 2:
        _data["levels_mirror"] = levels_mirror
    if _swap == 2:
        _data["levels_swap"] = levels_swap

    save_load.save_data("save_file_" + str(_save_file), _data.duplicate())


func _get_players() -> bool:
    _players = get_tree().get_nodes_in_group("player_chara")

    if _players.size() < 2: return false

    for player in _players:
        var parent: Node
        parent = player.get_parent()
        while parent != null && parent != current_level_instance:
            parent = parent.get_parent()
        if parent != current_level_instance:
            return false
    return true


func _update_labels():
    if _random && Global.in_story_mode:
        current_level_instance.get_child(0).update_level_label(get_random_levels_index_string())
    else:
        current_level_instance.get_child(0).update_level_label(get_level_number_string())
    current_level_instance.get_child(0).update_retry_label(get_retries_number_string())


func get_level_number_string() -> String:
    var number: int = level_index
    var string: String
    if number < 10:
        string = "00" + str(number)
    elif number < 100:
        string = "0" + str(number)
    else:
        string = str(number)
    return string


func get_random_levels_index_string() -> String:
    var number: int = random_levels_index
    var string: String
    if number < 10:
        string = "00" + str(number)
    elif number < 100:
        string = "0" + str(number)
    else:
        string = str(number)
    return string


func get_retries_number_string() -> String:
    var number: int = _retry_count
    var string: String = ""

    if number > 99999: return "99999"

    if number < 10:
        string = "0000" + str(number)
    elif number < 100:
        string = "000" + str(number)
    elif number < 1000:
        string = "00" + str(number)
    elif number < 10000:
        string = "0" + str(number)
    else:
        string = str(number)
    return string


func get_data() -> Dictionary:
    return _data.duplicate()


func unload_level():
    Global.player_charas[0] = null
    Global.player_charas[1] = null
    if level_counter_instance != null:
        if level_counter_instance.change_level_to_number(get_level_number_string()).is_connected(load_level):
            level_counter_instance.change_level_to_number(get_level_number_string()).disconnect(load_level)
        if !level_counter_instance.is_queued_for_deletion():
            level_counter_instance.queue_free()

    if current_level_instance != null && !current_level_instance.is_queued_for_deletion():
        current_level_instance.queue_free()
        current_level_instance = null


func _set_previous_random_level():
    if random_levels_index > 0:
        random_levels_index -= 1
        level_index = random_levels_order[random_levels_index]


func stop_normal_timer():
    _normal_timer_running = true


func manage_update_tutorial_keys():
    if current_level_instance && level_index == 0:
        current_level_instance.set_keys()


func manage_reset_timer():
    if current_level_instance:
        current_level_instance.get_child(0).set_timer()


func _manage_keyboard_test():
    if Global.mobile: return
    if general_input_controller.last_action_device == 0 && _keyboard_test_pending:
        _queue_disable_player_charas = true
        menu_loader.load_keyboard_test()


func _disable_player_charas():
    if Global.player_charas[0] == null || Global.player_charas[1] == null:
        return

    _queue_disable_player_charas = false
    Global.player_charas[0].chara_disabled = true
    Global.player_charas[1].chara_disabled = true


func _manage_achievements():
    _achievements_data = save_load.get_loaded_data()
    if _achievements_data.has("achievements"):
        _achievements_dictionary = _achievements_data["achievements"]

    var achievement_unlocked: bool
    if !Global.extra_time > 0:
        match level_index:
            1:
                if !_achievements_dictionary.get("symmetrical", false):
                    _achievements_dictionary["symmetrical"] = true
                    achievement_unlocked = true
            6:
                if !_achievements_dictionary.get("wooden_platform", false):
                    _achievements_dictionary["wooden_platform"] = true
                    achievement_unlocked = true
            11:
                if !_achievements_dictionary.get("spikes", false):
                    _achievements_dictionary["spikes"] = true
                    achievement_unlocked = true
            16:
                if !_achievements_dictionary.get("sandstone", false):
                    _achievements_dictionary["sandstone"] = true
                    achievement_unlocked = true
            21:
                if !_achievements_dictionary.get("glass", false):
                    _achievements_dictionary["glass"] = true
                    achievement_unlocked = true
            24:
                if !_achievements_dictionary.get("springboard", false):
                    _achievements_dictionary["springboard"] = true
                    achievement_unlocked = true
            27:
                if !_achievements_dictionary.get("bellows", false):
                    _achievements_dictionary["bellows"] = true
                    achievement_unlocked = true
            31:
                if !_achievements_dictionary.get("spike_ball", false):
                    _achievements_dictionary["spike_ball"] = true
                    achievement_unlocked = true
            36:
                if !_achievements_dictionary.get("switch", false):
                    _achievements_dictionary["switch"] = true
                    achievement_unlocked = true
            41:
                if !_achievements_dictionary.get("moving_platform", false):
                    _achievements_dictionary["moving_platform"] = true
                    achievement_unlocked = true
            46:
                if !_achievements_dictionary.get("button", false):
                    _achievements_dictionary["button"] = true
                    achievement_unlocked = true
            51:
                if !_achievements_dictionary.get("spiked_pendulum", false):
                    _achievements_dictionary["spiked_pendulum"] = true
                    achievement_unlocked = true
            56:
                if !_achievements_dictionary.get("box", false):
                    _achievements_dictionary["box"] = true
                    achievement_unlocked = true
            61:
                if !_achievements_dictionary.get("smasher", false):
                    _achievements_dictionary["smasher"] = true
                    achievement_unlocked = true
            66:
                if !_achievements_dictionary.get("fireball", false):
                    _achievements_dictionary["fireball"] = true
                    achievement_unlocked = true
            71:
                if !_achievements_dictionary.get("quantum_platform", false):
                    _achievements_dictionary["quantum_platform"] = true
                    achievement_unlocked = true
            76:
                if !_achievements_dictionary.get("directional_block", false):
                    _achievements_dictionary["directional_block"] = true
                    achievement_unlocked = true
            81:
                if !_achievements_dictionary.get("toggle_platform", false):
                    _achievements_dictionary["toggle_platform"] = true
                    achievement_unlocked = true
            86:
                if !_achievements_dictionary.get("swapper", false):
                    _achievements_dictionary["swapper"] = true
                    achievement_unlocked = true
            91:
                if !_achievements_dictionary.get("final_stretch", false):
                    _achievements_dictionary["final_stretch"] = true
                    achievement_unlocked = true
            100:
                if !_achievements_dictionary.get("dungeon_master", false):
                    _achievements_dictionary["dungeon_master"] = true
                    achievement_unlocked = true

    if achievement_unlocked:
        save_load.save_data("achievements", _achievements_dictionary)
        save_load.load_data()
        if Global.steam:
            Global.steam_manager.unlock_achievements(_achievements_dictionary)


func manage_beat_game_achievements():
    if Global.extra_time > 0 || !Global.in_story_mode: return

    _achievements_data = save_load.get_loaded_data()
    if _achievements_data.has("achievements"):
        _achievements_dictionary = _achievements_data["achievements"]

    var achievement_unlocked: bool


    if !_achievements_dictionary.get("ambidexterity", false):
        _achievements_dictionary["ambidexterity"] = true
        achievement_unlocked = true

    if _time <= 1800 || _speedrun_time <= 1800:
        if !_achievements_dictionary.get("speedrun", false):
            _achievements_dictionary["speedrun"] = true
            achievement_unlocked = true

    if _retry_count <= 300:
        if !_achievements_dictionary.get("retries", false):
            _achievements_dictionary["retries"] = true
            achievement_unlocked = true

    if _random && _mirror == 2:
        if !_achievements_dictionary.get("randomizer", false):
            _achievements_dictionary["randomizer"] = true
            achievement_unlocked = true

    if achievement_unlocked:
        save_load.save_data("achievements", _achievements_dictionary)
        save_load.load_data()
        if Global.steam:
            Global.steam_manager.unlock_achievements(_achievements_dictionary)


func _cancel_level_counter_screen() -> bool:
    if level_counter_instance != null && !level_counter_instance.is_queued_for_deletion():
        if level_counter_instance.get_signal().is_connected(load_level):
            level_counter_instance.get_signal().disconnect(load_level)
        level_counter_instance.queue_free()
        return true
    return false



func is_level_counter_instantiated() -> bool:
    if level_counter_instance != null:
        return true
    return false


func is_last_level_unlocked() -> bool:
    return save_load.get_loaded_data().get("last_level", false)


func unload_speedrun_timer():
    _speedrun_time_already_loaded = false
    _speedrun_time = 0
    Global.speedrun_time = 0
    set_speedrun_timer_finished(false)


func get_normal_time() -> float:
    return _time


func manage_refresh_tutorial():
    if level_index == 0 && current_level_instance != null:
        current_level_instance.set_keys()


func is_playing() -> bool:
    return _playing
