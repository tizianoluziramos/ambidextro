extends Node2D

@export var level_preview: Node2D
@export var options: Node
@export var level_label: Label
@export var when_winning_label: Label
@export var mirror_label: Label
@export var swap_label: Label
@export var labels: Array[Label]
@export var preview_image: Sprite2D


var menu_loader: Node
var level_previews: Node
var ui_sounds: Node
var level_list: Array[String]

const _PATH_OPENING: String = "res://scenes/levels/"
const _PATH_ENDING: String = ".tscn"

var _current_level: int = 0
var _level_instance: Node
var _when_winning_option: int
var _preview_mirrored: bool
var _preview_swapped: bool
var _mirror: int
var _swap: int
var _max_level: int = 100
var _lang: String


var _mirror_next_frame: bool
var _swap_next_frame: bool

var _cooldown_timer: float
const _COOLDOWN_SLOW: float = 0.2

func _ready():
    _translate()


func _process(delta: float) -> void :
    pass








func accept_option(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_accept()
            options.select_option(4)
        "marker2d":
            ui_sounds.play_accept()
            options.select_option(4)
        "play":
            ui_sounds.play_accept()
            play()
            _save_globals()
        "back":
            ui_sounds.play_back()
            menu_loader.levels_to_main()
            _save_globals()


func decrease(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _current_level -= 1
            if _current_level < 0: _current_level = _max_level
            _preview_level(_current_level)
        "marker2d":
            ui_sounds.play_lateral()
            match option_index:
                1:
                    _when_winning_option -= 1
                    if _when_winning_option < 0: _when_winning_option = 2
                    _change_when_winning_option(_when_winning_option)
                2:
                    _mirror -= 1
                    if _mirror < 0: _mirror = 2
                    _change_mirror_option(_mirror)
                3:
                    _swap -= 1
                    if _swap < 0: _swap = 2
                    _change_swap_option(_swap)
        "play":
            options.select_option(0)
            decrease("<", 0)
        _:
            ui_sounds.play_invalid()


func increase(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _current_level += 1
            if _current_level > _max_level: _current_level = 0
            _preview_level(_current_level)
        "marker2d":
            ui_sounds.play_lateral()
            match option_index:
                1:
                    _when_winning_option += 1
                    if _when_winning_option > 2: _when_winning_option = 0
                    _change_when_winning_option(_when_winning_option)
                2:
                    _mirror += 1
                    if _mirror > 2: _mirror = 0
                    _change_mirror_option(_mirror)
                3:
                    _swap += 1
                    if _swap > 2: _swap = 0
                    _change_swap_option(_swap)
        "play":
            options.select_option(0)
            increase("<", 0)
        _:
            ui_sounds.play_invalid()


func decrease_quick(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _current_level -= 10
            if _current_level < 0: _current_level = _max_level
            _preview_level(_current_level)
        _:
            decrease(option, option_index)


func increase_quick(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _current_level += 10
            if _current_level > _max_level: _current_level = 0
            _preview_level(_current_level)
        _:
            increase(option, option_index)


func play():
    options.active = false
    menu_loader.manage_load_level(_current_level, _when_winning_option, _mirror, _swap)


func _change_when_winning_option(option_index: int):
    var label_text: String
    match option_index:
        0:
            label_text = Global.translations["lm_next"][_lang]
            menu_loader.set_mode(1)
        1:
            label_text = Global.translations["lm_repeat"][_lang]
            menu_loader.set_mode(2)
        2:
            label_text = Global.translations["lm_random"][_lang]
            menu_loader.set_mode(3)

    when_winning_label.text = label_text


func _change_mirror_option(option_index: int):
    var label_text: String
    match option_index:
        0:
            label_text = Global.translations["no"][_lang]
            menu_loader.set_mode(1)
        1:
            label_text = Global.translations["yes"][_lang]
            menu_loader.set_mode(2)
        2:
            label_text = Global.translations["random"][_lang]
            menu_loader.set_mode(3)

    mirror_label.text = label_text
    _preview_level(_current_level)
















func _change_swap_option(option_index: int):
    var label_text: String
    match option_index:
        0:
            label_text = Global.translations["no"][_lang]
            menu_loader.set_mode(1)
        1:
            label_text = Global.translations["yes"][_lang]
            menu_loader.set_mode(2)
        2:
            label_text = Global.translations["random"][_lang]
            menu_loader.set_mode(3)

    swap_label.text = label_text
    _preview_level(_current_level)













func initialize():
    _current_level = Global.level_selected
    _when_winning_option = Global.clear_selected
    _mirror = Global.mirror_selected
    _swap = Global.swap_selected
    _change_when_winning_option(_when_winning_option)
    _change_mirror_option(_mirror)
    _change_swap_option(_swap)
    _preview_level(_current_level)






func _preview_level(level: int):
    _preview_mirrored = false
    _preview_swapped = false
    _update_level_label(level)
    var mirror: bool = true if _mirror == 1 else false
    var swap: bool = true if _swap == 1 else false
    _load_preview_level(level, mirror, swap)











func _load_preview_level(level: int, mirror: bool, swap: bool):
    if mirror && swap:
        preview_image.texture = level_previews.previews_mirror_swap[level]
    elif swap:
        preview_image.texture = level_previews.previews_swap[level]
    elif mirror:
        preview_image.texture = level_previews.previews_mirror[level]
    else:
        preview_image.texture = level_previews.previews[level]













func _update_level_label(level: int):
    level_label.text = menu_loader.get_level_number_string(level)


func cancel():
    ui_sounds.play_back()
    menu_loader.levels_to_main()
    _save_globals()


func play_selection():
    ui_sounds.play_selection()


func unlock_last_level():
    _max_level = 101



func _translate():
    var lang: String = Global.language
    _lang = lang

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
        when_winning_label.theme = Global.secondary_theme
        mirror_label.theme = Global.secondary_theme
        swap_label.theme = Global.secondary_theme
        level_label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme
        level_label.theme = Global.main_theme


    var i: int = 0
    labels[i].text = Global.translations["sm_level"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["lm_clear"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_mirror"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_swap"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mm_play"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()

    mirror_label.text = Global.translations["no"][lang]
    swap_label.text = Global.translations["no"][lang]


func _save_globals():
    Global.level_selected = _current_level
    Global.clear_selected = _when_winning_option
    Global.mirror_selected = _mirror
    Global.swap_selected = _swap
