extends Node2D


@export var options: Node
@export var label_value: Label
@export var arrows: Array[Label]
@export var enabled_color: Color
@export var disabled_color: Color
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var save_load: Node
var save_file: int

var data: Dictionary
var extra_time: int

var times: Array[int] = [0, 10, 25, 50, 75, 100]
var times_index: int

var _from_pause: bool

func _ready() -> void :
    _translate()


func initialize(from_pause: bool):
    _from_pause = from_pause
    data = save_load.get_loaded_data()

    if _from_pause:
        if save_file == 0:
            extra_time = Global.extra_time
        else:
            extra_time = data["save_file_" + str(save_file)].get("extra_time", 0)

    for i in times.size():
        if extra_time == times[i]:
            times_index = i
            break

    _update_labels()

    if !_from_pause:
        labels[1].modulate.a = 0.5
        label_value.modulate.a = 0.5
        labels[3].modulate.a = 1
        arrows[0].modulate.a = 0
        arrows[1].modulate.a = 0
        options.options.remove_at(0)
        options.select_option(0)


func _update_labels():
    label_value.text = str(extra_time) + "%"

    if times_index == 0:
        arrows[0].add_theme_color_override("font_color", disabled_color)
    else:
        arrows[0].add_theme_color_override("font_color", enabled_color)

    if times_index == times.size() - 1:
        arrows[1].add_theme_color_override("font_color", disabled_color)
    else:
        arrows[1].add_theme_color_override("font_color", enabled_color)


func accept_option(option: String, option_index: int):
    match option:
        "marker2d":
            options.select_option(1)
            ui_sounds.play_accept()
        "back":
            ui_sounds.play_back()
            _save_selection()
            menu_loader.accessibility_to_settings()


func increase(option: String, option_index: int):
    match option:
        "marker2d":
            if times_index < times.size() - 1:
                times_index += 1
                extra_time = times[times_index]
                _update_labels()
                ui_sounds.play_lateral()
            else:
                ui_sounds.play_invalid()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    match option:
        "marker2d":
            if times_index > 0:
                times_index -= 1
                extra_time = times[times_index]
                _update_labels()
                ui_sounds.play_lateral()
            else:
                ui_sounds.play_invalid()
        _:
            ui_sounds.play_invalid()


func cancel():
    ui_sounds.play_back()
    _save_selection()
    menu_loader.accessibility_to_settings()

func play_selection():
    ui_sounds.play_selection()


func _save_selection():
    if !_from_pause: return

    if save_file == 0:
        Global.extra_time = extra_time
        return

    Global.extra_time = extra_time
    menu_loader.level_loader.save()



func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme
        labels[3].theme = Global.secondary_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_accessibility"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["am_time"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["am_info"][lang]
