extends Node2D


@export var options: Node
@export var label_values: Array[Label]
@export var labels: Array[Label]


var menu_loader: Node
var save_menu: Node
var ui_sounds: Node
var save_load: Node
var crt_shader: Node
var subviewport_container: Node

var _delete: bool


func _ready() -> void :
    _translate()
    _initialize.call_deferred()


func _initialize():
    _update_labels()


func _update_labels():
    var lang: String = Global.language
    var yes: String = Global.translations["yes"][lang]
    var no: String = Global.translations["no"][lang]

    if _delete:
        label_values[0].text = yes
    else:
        label_values[0].text = no


func accept_option(option: String, option_index: int):
    match option:
        "apply":
            _apply_settings()
        "back":
            ui_sounds.play_back()
            menu_loader.data_to_settings()
        _:
            ui_sounds.play_invalid()


func increase(option: String, option_index: int):
    match option:
        "marker2d", "marker2d2":
            ui_sounds.play_lateral()
            match option_index:
                0:
                    _delete = !_delete
                    _update_labels()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    increase(option, option_index)


func cancel():
    ui_sounds.play_back()
    menu_loader.data_to_settings()


func play_selection():
    ui_sounds.play_selection()


func _apply_settings():
    if _delete:
        ui_sounds.play_accept()
        save_load.create_default_data()
        save_load.create_default_settings_data()
        _reset_game()
    else:
        ui_sounds.play_invalid()


func _reset_game():
    Global.reset()
    get_tree().reload_current_scene()


func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_data"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_delete_everything"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_apply"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
