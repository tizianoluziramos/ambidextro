extends Node


@export var general_input_controller: Node
@export var level_loader: Node
@export var level_previews: Node
@export var save_load: Node
@export var menu_container: Node2D
@export var level_container: Node2D
@export var music_controller: Node
@export var ui_sounds: Node
@export var crt_shader: Node
@export var subviewport_container: Node
@export var steam_manager: Node
@export var main_menu: PackedScene
@export var save_menu: PackedScene
@export var modifiers_menu: PackedScene
@export var pause_menu: PackedScene
@export var levels_menu: PackedScene
@export var settings_menu: PackedScene
@export var data_menu: PackedScene
@export var credits_menu: PackedScene
@export var keyboard_test: PackedScene
@export var keys_finder: PackedScene
@export var intro_cutscene: PackedScene
@export var end_credits: PackedScene

@export var controls_menu: PackedScene
@export var language: PackedScene
@export var video: PackedScene
@export var audio: PackedScene
@export var accessibility: PackedScene
@export var speedrun: PackedScene

var _current_menu_instance: Node
var _cutscene_instance: Node
var _cutscene_is_intro: bool
var _end_credits_instance: Node
var _playing: bool
var _mode: int
var _from_pause: bool
var _current_save_file: int


var speedrun_time_string: String = ""
var hours: int
var hours_string: String
var minutes: int
var minutes_string: String
var seconds_int: int
var seconds_string: String
var mili: float
var mili_string: String


func _process(_delta: float) -> void :
    if !_playing: return
    if Input.is_action_just_pressed("pause"):
        ui_sounds.play_accept()
        load_pause_menu(_mode)


func set_playing(state: bool):
    _playing = state


func set_mode(mode: int):
    _mode = mode



func load_main_menu():
    _playing = false
    load_scene(main_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.general_input_controller = general_input_controller
    menu_container.add_child(_current_menu_instance)
    music_controller.play_main_menu_music()


func load_save_menu():
    set_mode(0)
    load_scene(save_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.level_previews = level_previews
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.level_list = level_loader.level_list
    _current_menu_instance.data = save_load.get_loaded_data()
    _current_menu_instance.initialize.call_deferred()
    menu_container.add_child(_current_menu_instance)


func load_modifiers_menu(save_file: int):
    load_scene(modifiers_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.data = save_load.get_loaded_data()
    _current_menu_instance.initialize.call_deferred(save_file)
    menu_container.add_child(_current_menu_instance)


func modifiers_to_save():
    load_save_menu()
    _current_menu_instance.options.select_option.call_deferred(2)


func load_levels_menu():
    load_scene(levels_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.level_previews = level_previews
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.level_list = level_loader.level_list
    if save_load.is_last_level_unlocked(): _current_menu_instance.unlock_last_level()
    _current_menu_instance.initialize.call_deferred()
    menu_container.add_child(_current_menu_instance)


func levels_to_main():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_main_menu()
    _current_menu_instance.options.select_option.call_deferred(1)


func manage_load_save(save_file: int, dic: Dictionary, last_level: bool):
    remove_clickable_areas()

    _current_save_file = save_file
    level_loader.set_keyboard_test_pending( !save_load.get_loaded_settings().has("keyboard_test"))

    if !dic.has("intro_cutscene") && dic.get("cutscenes", 0) == 0 && !last_level:
        level_loader.load_stats(save_file, dic)
        load_intro_cutscene(save_file, dic, false)

    else:
        if _current_menu_instance != null && !_current_menu_instance.is_queued_for_deletion():
            if _current_menu_instance: _current_menu_instance.queue_free()
            _current_menu_instance = null

        if _cutscene_instance != null && !_cutscene_instance.is_queued_for_deletion():
            _cutscene_instance.queue_free()
            _cutscene_instance = null
            _cutscene_is_intro = false

        dic["intro_cutscene"] = true
        save_load.update_default_save_file(save_file)
        level_loader.load_stats(save_file, dic)
        level_loader.load_level()
        level_loader.start_music_and_timer()
        if last_level: level_loader.level_index = 101


func manage_load_level(level: int, when_winning_option: int, mirror: int, swap: int):
    remove_clickable_areas()

    _current_save_file = 0
    level_loader.set_keyboard_test_pending( !save_load.get_loaded_settings().has("keyboard_test"))
    level_loader.load_single_level_options(level, when_winning_option, mirror, swap)
    if _current_menu_instance: _current_menu_instance.queue_free()
    _current_menu_instance = null
    level_loader.load_level()
    level_loader.call_play_music()


func load_pause_menu(mode: int):
    level_container.visible = false
    var level_to_pause: bool
    if !_from_pause:
        level_to_pause = true
    _from_pause = true
    get_tree().paused = true
    if !_cutscene_is_intro:
        level_loader.save()
    set_playing(false)
    level_loader.set_playing(false)
    load_scene(pause_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.level_loader = level_loader
    if _cutscene_instance != null:
        _current_menu_instance.cutscene = true
        _current_menu_instance.cutscene_is_intro = _cutscene_is_intro
        _current_menu_instance.cutscene_instance = _cutscene_instance
    if _end_credits_instance != null:
        _end_credits_instance.visible = false
    _current_menu_instance.initialize(level_loader.get_data(), mode, level_to_pause)
    menu_container.add_child(_current_menu_instance)
    music_controller.pause_music()

    if _cutscene_instance != null:
        _cutscene_instance.visible = false

    level_loader.set_normal_timer_running(false)
    if Global.speedrun_pausable:
        level_loader.set_speedrun_timer_running(false)

    if _cutscene_instance != null:
        _cutscene_instance.active = false


func unload_pause_menu():
    level_container.visible = true
    _from_pause = false
    if _current_menu_instance: _current_menu_instance.queue_free()
    _current_menu_instance = null
    set_playing(true)
    level_loader.set_playing(true)
    get_tree().paused = false
    music_controller.resume_music()

    if _cutscene_instance != null:
        _cutscene_instance.active = true
        _cutscene_instance.visible = true
    if _end_credits_instance != null:
        _end_credits_instance.visible = true

    level_loader.set_normal_timer_running(true)
    level_loader.set_speedrun_timer_running(true)


func pause_to_main():
    level_container.visible = true
    _from_pause = false
    music_controller.stop_music()
    if _current_menu_instance: _current_menu_instance.queue_free()
    _current_menu_instance = null
    get_tree().paused = false
    level_loader.set_normal_timer_running(false)
    level_loader.set_speedrun_timer_running(false)
    level_loader.unload_level()
    level_loader.unload_speedrun_timer()

    _current_save_file = 0
    if Global.in_story_mode:
        Global.extra_time = 0

    if _cutscene_instance != null && !_cutscene_instance.is_queued_for_deletion():
        _cutscene_instance.queue_free()
        _cutscene_instance = null
        _cutscene_is_intro = false

    if _end_credits_instance != null && !_end_credits_instance.is_queued_for_deletion():
        _end_credits_instance.queue_free()
        _end_credits_instance = null

    load_main_menu()


func settings_to_main():
    if _from_pause:
        if _current_menu_instance: _current_menu_instance.queue_free()
        load_pause_menu(_mode)
        _current_menu_instance.select_settings_option.call_deferred()
        return

    if _current_menu_instance: _current_menu_instance.queue_free()
    load_main_menu()
    _current_menu_instance.options.select_option.call_deferred(2)


func load_keyboard_test():
    get_tree().paused = true
    level_container.visible = false
    set_playing(false)
    load_scene(keyboard_test)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    menu_container.add_child(_current_menu_instance)
    music_controller.pause_music.call_deferred()


func load_keys_finder(came_from_controls_menu: bool):
    load_scene(keys_finder)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.came_from_controls_menu = came_from_controls_menu
    menu_container.add_child(_current_menu_instance)



func load_intro_cutscene(save_file: int, data: Dictionary, ending: bool):
    set_playing(true)
    if _current_menu_instance != null && !_current_menu_instance.is_queued_for_deletion():
        if _current_menu_instance: _current_menu_instance.queue_free()
        _current_menu_instance = null
    _cutscene_instance = intro_cutscene.instantiate()
    _cutscene_instance.menu_loader = self
    _cutscene_instance.music_controller = music_controller
    _cutscene_instance.level_loader = level_loader
    _cutscene_instance.save_file = save_file
    _cutscene_instance.data = data
    _cutscene_instance.active = true
    if ending:
        _cutscene_is_intro = false
        _cutscene_instance.set_ending.call_deferred()
    else:
        _cutscene_is_intro = true
        _cutscene_instance.set_intro.call_deferred()
    menu_container.add_child(_cutscene_instance)


func load_end_credits():
    steam_manager.unlock_achievements(save_load.get_loaded_data()["achievements"])
    _end_credits_instance = end_credits.instantiate()
    _end_credits_instance.menu_loader = self
    menu_container.add_child(_end_credits_instance)



func unload_end_credits():
    if _end_credits_instance != null && !_end_credits_instance.is_queued_for_deletion():
        _end_credits_instance.queue_free()


func end_credits_to_main():
    load_scene(main_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.general_input_controller = general_input_controller
    _playing = false
    _current_menu_instance.play_wizards_fusion_animation()
    menu_container.add_child(_current_menu_instance)
    level_loader.unload_speedrun_timer()


func load_scene(menu_scene: PackedScene):
    remove_clickable_areas()

    if _current_menu_instance != null && !_current_menu_instance.is_queued_for_deletion():
        if _current_menu_instance: _current_menu_instance.queue_free()
    _current_menu_instance = menu_scene.instantiate()


func remove_clickable_areas():
    for child in subviewport_container.clickable_areas_container.get_children():
        child.queue_free()





func load_settings_menu():
    load_scene(settings_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    if _from_pause:
        _current_menu_instance.from_pause = true
    menu_container.add_child(_current_menu_instance)


func load_controls_menu():
    load_scene(controls_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.general_input_controller = general_input_controller
    _current_menu_instance.initialize.call_deferred()
    menu_container.add_child(_current_menu_instance)



func test_to_controls():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_controls_menu()
    _current_menu_instance.options.select_option.call_deferred(9)


func controls_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(3)


    level_loader.manage_update_tutorial_keys()


func load_language_menu():
    load_scene(language)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    menu_container.add_child(_current_menu_instance)


func language_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(0)


func load_video_menu():
    load_scene(video)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.crt_shader = crt_shader
    _current_menu_instance.subviewport_container = subviewport_container
    menu_container.add_child(_current_menu_instance)


func video_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(1)


func load_audio_menu():
    load_scene(audio)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    _current_menu_instance.from_pause = _from_pause
    _current_menu_instance.music_controller = music_controller
    menu_container.add_child(_current_menu_instance)


func audio_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(2)


func load_accessibility_menu():
    load_scene(accessibility)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    if _from_pause:
        _current_menu_instance.save_file = _current_save_file
    menu_container.add_child(_current_menu_instance)
    _current_menu_instance.initialize.call_deferred(_from_pause)


func accessibility_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(4)
    level_loader.manage_reset_timer()


func load_speedrun_menu():
    load_scene(speedrun)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    menu_container.add_child(_current_menu_instance)


func speedrun_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(5)


func load_data_menu():
    load_scene(data_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    _current_menu_instance.save_load = save_load
    menu_container.add_child(_current_menu_instance)


func data_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    _current_menu_instance.options.select_option.call_deferred(5)


func load_credits_menu():
    load_scene(credits_menu)
    _current_menu_instance.menu_loader = self
    _current_menu_instance.ui_sounds = ui_sounds
    menu_container.add_child(_current_menu_instance)


func credits_to_settings():
    if _current_menu_instance: _current_menu_instance.queue_free()
    load_settings_menu()
    if _from_pause:
        _current_menu_instance.options.select_option.call_deferred(5)
    else:
        _current_menu_instance.options.select_option.call_deferred(6)




func manage_finish_keyboard_test():
    level_container.visible = true
    _current_menu_instance.queue_free()
    save_load.load_data()
    level_loader.set_keyboard_test_pending(false)
    Global.player_charas[0].chara_disabled = false
    Global.player_charas[1].chara_disabled = false
    set_playing.call_deferred(true)
    music_controller.add_queue_cooldown()
    music_controller.resume_music()
    level_loader.manage_refresh_tutorial()
    get_tree().paused = false













func manage_restart_game():
    if _cutscene_instance != null && !_cutscene_instance.is_queued_for_deletion():
        _cutscene_instance.queue_free()
        _cutscene_instance = null
        _cutscene_is_intro = false

    if _end_credits_instance != null && !_end_credits_instance.is_queued_for_deletion():
        _end_credits_instance.queue_free()
        _end_credits_instance = null

    level_loader.unload_level()
    level_loader.unload_speedrun_timer()
    save_load.delete_save_file_preserving_modifiers(_current_save_file)
    manage_load_save(_current_save_file, save_load.get_loaded_data()["save_file_" + str(_current_save_file)], false)


func quit_credits():
    if _end_credits_instance != null && !_end_credits_instance.is_queued_for_deletion():
        _end_credits_instance.queue_free()


func get_level_number_string(number: int) -> String:
    var string: String
    if number < 10:
        string = "00" + str(number)
    elif number < 100:
        string = "0" + str(number)
    else:
        string = str(number)
    return string


func get_retries_number_string(number: int) -> String:
    var string: String = ""
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



func get_time_string(seconds: float) -> String:
    var string: String = ""

    var overflow: bool
    hours = 0
    minutes = 0


    while seconds >= 3600:
        hours += 1
        seconds -= 3600

    if hours > 99:
        hours = 99
        overflow = true

    hours_string = str(hours)


    while seconds >= 60:
        minutes += 1
        seconds -= 60

    if overflow:
        minutes = 59

    if minutes < 10:
        minutes_string = "0" + str(minutes)
    else:
        minutes_string = str(minutes)



    seconds_int = floor(seconds)
    if overflow:
        seconds_int = 59

    if seconds_int < 10:
        seconds_string = "0" + str(seconds_int)
    else:
        seconds_string = str(seconds_int)


    string = hours_string + ":" + minutes_string + ":" + seconds_string
    return string


func get_speedrun_time_string(seconds: float) -> String:
    var overflow: bool

    hours = 0
    minutes = 0


    while seconds >= 3600:
        hours += 1
        seconds -= 3600

    if hours > 99:
        hours = 99
        overflow = true

    hours_string = str(hours)


    while seconds >= 60:
        minutes += 1
        seconds -= 60

    if overflow:
        minutes = 59

    if minutes < 10:
        minutes_string = "0" + str(minutes)
    else:
        minutes_string = str(minutes)



    seconds_int = floor(seconds)
    if overflow:
        seconds_int = 59

    if seconds_int < 10:
        seconds_string = "0" + str(seconds_int)
    else:
        seconds_string = str(seconds_int)



    mili = seconds - seconds_int
    mili *= 1000
    mili = floor(mili)

    if overflow:
        mili = 999

    if mili < 10:
        mili_string = "00" + str(mili)
    elif mili < 100:
        mili_string = "0" + str(mili)
    else:
        mili_string = str(mili)



    speedrun_time_string = hours_string + ":" + minutes_string + ":" + seconds_string + ":" + mili_string
    return speedrun_time_string
