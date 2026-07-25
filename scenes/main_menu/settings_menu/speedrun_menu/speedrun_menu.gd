extends Node2D


@export var options: Node
@export var label_values: Array[Label]
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var save_load: Node


var data: Dictionary
var _speedrun_mode: bool
var _pausable: bool


func _ready() -> void :
    _translate()
    _initialize.call_deferred()


func _initialize():
    data = save_load.get_loaded_data()
    if data.has("speedrun"):
        _speedrun_mode = data["speedrun"].get("speedrun_mode", false)
        _pausable = data["speedrun"].get("speedrun_pausable", false)

    _update_labels()



func _update_labels():
    var lang: String = Global.language
    if _speedrun_mode:
        label_values[0].text = Global.translations["yes"][lang]
    else:
        label_values[0].text = Global.translations["no"][lang]

    if _pausable:
        label_values[1].text = Global.translations["yes"][lang]
    else:
        label_values[1].text = Global.translations["no"][lang]



func accept_option(option: String, option_index: int):
    match option:
        "marker2d":
            options.select_option(2)
            ui_sounds.play_accept()
        "back":
            ui_sounds.play_back()
            _save_selection()
            menu_loader.speedrun_to_settings()


func increase(option: String, option_index: int):
    match option:
        "marker2d":
            if option_index == 0:
                _speedrun_mode = !_speedrun_mode
                ui_sounds.play_lateral()
                _update_labels()
            else:
                _pausable = !_pausable
                ui_sounds.play_lateral()
                _update_labels()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    increase(option, option_index)


func cancel():
    ui_sounds.play_back()
    _save_selection()
    menu_loader.speedrun_to_settings()

func play_selection():
    ui_sounds.play_selection()


func _save_selection():
    var dic: Dictionary
    dic["speedrun_mode"] = _speedrun_mode
    dic["speedrun_pausable"] = _pausable
    save_load.save_data("speedrun", dic)
    Global.speedrun_mode = _speedrun_mode
    Global.speedrun_pausable = _pausable

    if _speedrun_mode:
        save_load.save_data("keyboard_test", true)
    Global.speedrun_mode = _speedrun_mode



func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        labels[0].theme = Global.main_theme
        labels[1].theme = Global.main_theme
        labels[4].theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_speedrun"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["srm_mode"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["srm_pausable"][lang].to_upper()
    i += 1
    labels[i].text = "- " + Global.translations["srm_info1"][lang] + "\n- " + Global.translations["srm_info2"][lang] + "\n- " + Global.translations["srm_info3"][lang]
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
    i += 1
