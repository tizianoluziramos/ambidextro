extends Node2D

@export var level_preview: Node2D
@export var save_info_labels: Array[Label]
@export var options: Node
@export var delete_options_controller: Node
@export var labels: Array[Label]
@export var preview_image: Sprite2D

@export var save_file_options: BoxContainer
@export var save_info: Node
@export var level_preview_mask: Node
@export var preview_frame: Node
@export var clickable_areas: Array[Node]


var menu_loader: Node
var level_previews: Node
var ui_sounds: Node
var save_load: Node
var data: Dictionary
var level_list: Array[String]

const _PATH_OPENING: String = "res://scenes/levels/"
const _PATH_ENDING: String = ".tscn"

var _level_instance: Node

var _current_save_file: int
var _modifier_keys: Array[String] = ["cutscenes", "speedrun_timer", "order", "mirror", "swap"]

func _ready():
    _translate()

    if Global.mobile:
        _set_for_mobile()


func _set_for_mobile():
    save_file_options.add_theme_constant_override("separation", 5)

    level_preview_mask.position.y -= 10
    preview_frame.position.y -= 10
    options.position.y -= 10
    save_info.position.y -= 10


func accept_option(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_accept()
            options._select_next()
        "play":
            ui_sounds.play_accept()
            play()
        "modifiers":
            ui_sounds.play_accept()
            menu_loader.load_modifiers_menu(_current_save_file)
        "delete":
            ui_sounds.play_accept()
            delete_options_controller.initialize(_current_save_file)
        "back":
            ui_sounds.play_back()
            menu_loader.load_main_menu()


func decrease(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _current_save_file -= 1
            if _current_save_file <= 0: _current_save_file = 9
            _preview_save_file(_current_save_file)
        "back":
            ui_sounds.play_invalid()
        _:
            options.select_option(0)
            decrease("<", 0)


func increase(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _current_save_file += 1
            if _current_save_file >= 10: _current_save_file = 1
            _preview_save_file(_current_save_file)
        "back":
            ui_sounds.play_invalid()
        _:
            options.select_option(0)
            increase("<", 0)


func delete_save_file():
    save_load.delete_save_file(_current_save_file)
    data = save_load.get_loaded_data()

    _preview_save_file(_current_save_file)


func play():
    options.active = false
    save_load.save_data("default_save_file", _current_save_file)
    menu_loader.manage_load_save(_current_save_file, data["save_file_" + str(_current_save_file)], false)





func initialize():
    _preview_save_file(data["default_save_file"])


func _preview_save_file(file: int):
    _current_save_file = file

    var key: String = "save_file_" + str(_current_save_file)

    var level: int
    var retries: int
    var time: float

    if data.has(key):
        level = data[key].get("level", 0)
        retries = data[key].get("retries", 0)
        if !Global.speedrun_mode:
            time = data[key].get("time", 0)
        else:
            time = data[key].get("speedrun_time", 0)
    else:
        delete_save_file()
        level = data[key].get("level", 0)
        retries = data[key].get("retries", 0)
        if !Global.speedrun_mode:
            time = data[key].get("time", 0)
        else:
            time = data[key].get("speedrun_time", 0)


    var modifier_count: int
    for modifier_key in _modifier_keys:
        if data[key].get(modifier_key, 0) > 0:
            modifier_count += 1

    var level_number: int = level
    if data[key].has("random_levels_index"):
        level_number = data[key]["random_levels_index"]

    _update_labels(file, level_number, retries, time, modifier_count)
    if data[key].get("intro_cutscene", false):
        _load_preview_level(level)
    else:
        preview_image.texture = null





func _load_preview_level(level: int):
    var key: String = "save_file_" + str(_current_save_file)
    var mirror: bool = true if data[key].get("mirror", 0) == 1 else false
    var swap: bool = true if data[key].get("swap", 0) == 1 else false

    if !data[key].get("intro_cutscene", false):
        preview_image.texture = null
        return

    if mirror && swap:
        preview_image.texture = level_previews.previews_mirror_swap[level]
    elif swap:
        preview_image.texture = level_previews.previews_swap[level]
    elif mirror:
        preview_image.texture = level_previews.previews_mirror[level]
    else:
        preview_image.texture = level_previews.previews[level]









































func _update_labels(save_number: int, level: int, retries: int, time: float, modifier_count: int):
    save_info_labels[0].text = str(save_number)
    save_info_labels[1].text = menu_loader.get_level_number_string(level)
    save_info_labels[2].text = menu_loader.get_retries_number_string(retries)
    var key: String = "save_file_" + str(_current_save_file)
    if data[key].get("speedrun_timer", 0) == 1:
        save_info_labels[3].text = menu_loader.get_speedrun_time_string(time)
    else:
        save_info_labels[3].text = menu_loader.get_time_string(time as int)

    if modifier_count > 0:
        labels[5].text = Global.translations["sm_modifiers"][Global.language].to_upper() + " (" + str(modifier_count) + ")"
    else:
        labels[5].text = Global.translations["sm_modifiers"][Global.language].to_upper()

    if time == 0:
        labels[5].modulate.a = 1
    else:
        labels[5].modulate.a = 0.6


func cancel():
    ui_sounds.play_back()
    menu_loader.load_main_menu()


func play_selection():
    ui_sounds.play_selection()




func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
        save_info_labels[0].theme = Global.secondary_theme
    else:
        labels[0].theme = Global.main_theme
        labels[1].theme = Global.main_theme
        labels[5].theme = Global.main_theme
        labels[6].theme = Global.main_theme
        labels[7].theme = Global.main_theme
        labels[8].theme = Global.main_theme
        labels[9].theme = Global.main_theme
        labels[10].theme = Global.main_theme
        save_info_labels[0].theme = Global.main_theme

    labels[0].text = Global.translations["mm_play"][lang].to_upper()
    labels[1].text = Global.translations["sm_save"][lang].to_upper()
    labels[2].text = Global.translations["sm_level"][lang]
    labels[3].text = Global.translations["sm_retries"][lang]
    labels[4].text = Global.translations["sm_time"][lang]
    labels[5].text = Global.translations["sm_modifiers"][lang].to_upper()
    labels[6].text = Global.translations["sm_delete"][lang].to_upper()
    labels[7].text = Global.translations["sm_back"][lang].to_upper()
    labels[8].text = Global.translations["sm_delete_save"][lang].to_upper()
    labels[9].text = Global.translations["yes"][lang]
    labels[10].text = Global.translations["no"][lang]


func enable_clickable_areas():
    for area in clickable_areas:
        area.enable()


func disable_clickable_areas():
    for area in clickable_areas:
        area.disable()
