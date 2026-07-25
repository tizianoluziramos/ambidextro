extends Node2D


@export var options: Node
@export var label_values: Array[Label]
@export var labels: Array[Label]
@export var arrow_containers: Array[BoxContainer]

@export var v_box_container_1: BoxContainer
@export var v_box_container_2: BoxContainer
@export var v_box_container_3: BoxContainer
@export var v_box_container_4: BoxContainer



var menu_loader: Node
var ui_sounds: Node
var save_load: Node


var data: Dictionary
var _save_file: int
var _save_data: Dictionary
var _cutscenes: int
var _speedrun_timer: int
var _speedrun_pausable: int
var _order: int
var _mirror: int
var _swap: int
var _run_started: bool


func _ready() -> void :
    _translate()

    if Global.mobile:
            _set_for_mobile()


func _set_for_mobile():
    labels[0].position.y -= 20
    v_box_container_1.position.y -= 20
    v_box_container_2.position.y -= 18
    v_box_container_2.add_theme_constant_override("separation", 25)
    v_box_container_3.position.y -= 10
    v_box_container_3.add_theme_constant_override("separation", 25)
    v_box_container_4.position.y += 5


func initialize(save_file: int):
    _save_file = save_file
    data = save_load.get_loaded_data()
    _save_data = data["save_file_" + str(save_file)]

    _cutscenes = _save_data.get("cutscenes", 0)
    _speedrun_timer = _save_data.get("speedrun_timer", 0)
    _speedrun_pausable = _save_data.get("speedrun_pausable", 0)
    _order = _save_data.get("order", 0)
    _mirror = _save_data.get("mirror", 0)
    _swap = _save_data.get("swap", 0)

    _run_started = true if _save_data["time"] > 0 else false

    if _run_started:
        for arrow in arrow_containers:
            arrow.modulate.a = 0
        for i in 6:
            options.options.remove_at(0)
        options.select_option(0)

    _update_labels()



func _update_labels():
    var lang: String = Global.language

    match _cutscenes:
        0:
            label_values[0].text = Global.translations["yes"][lang]
        1:
            label_values[0].text = Global.translations["no"][lang]

    match _speedrun_timer:
        0:
            label_values[1].text = Global.translations["no"][lang]
            if !_run_started:
                labels[3].modulate.a = 0.5
                label_values[2].modulate.a = 0.5
        1:
            label_values[1].text = Global.translations["yes"][lang]
            if !_run_started:
                labels[3].modulate.a = 1
                label_values[2].modulate.a = 1

    match _speedrun_pausable:
        0:
            label_values[2].text = Global.translations["no"][lang]
        1:
            label_values[2].text = Global.translations["yes"][lang]

    match _order:
        0:
            label_values[3].text = Global.translations["normal"][lang]
        1:
            label_values[3].text = Global.translations["random"][lang]

    match _mirror:
        0:
            label_values[4].text = Global.translations["no"][lang]
        1:
            label_values[4].text = Global.translations["yes"][lang]
        2:
            label_values[4].text = Global.translations["random"][lang]

    match _swap:
        0:
            label_values[5].text = Global.translations["no"][lang]
        1:
            label_values[5].text = Global.translations["yes"][lang]
        2:
            label_values[5].text = Global.translations["random"][lang]




func accept_option(option: String, option_index: int):
    match option:
        "marker2d":
            options.select_option(6)
            ui_sounds.play_accept()
        "back":
            ui_sounds.play_back()
            _save_selection()
            menu_loader.modifiers_to_save()


func increase(option: String, option_index: int):
    match option:
        "marker2d":
            if option_index >= 3 && _run_started:
                option_index += 1
            match option_index:
                0:
                    _cutscenes += 1
                    if _cutscenes == 2:
                        _cutscenes = 0
                1:
                    _speedrun_timer += 1
                    if _speedrun_timer == 2:
                        _speedrun_timer = 0
                2:
                    _speedrun_pausable += 1
                    if _speedrun_pausable == 2:
                        _speedrun_pausable = 0
                3:
                    _order += 1
                    if _order == 2:
                        _order = 0
                4:
                    _mirror += 1
                    if _mirror == 3:
                        _mirror = 0
                5:
                    _swap += 1
                    if _swap == 3:
                        _swap = 0

            ui_sounds.play_lateral()
            _update_labels()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    match option:
        "marker2d":
            if option_index >= 3 && _run_started:
                option_index += 1
            match option_index:
                0:
                    _cutscenes -= 1
                    if _cutscenes == -1:
                        _cutscenes = 1
                1:
                    _speedrun_timer -= 1
                    if _speedrun_timer == -1:
                        _speedrun_timer = 1
                2:
                    _speedrun_pausable -= 1
                    if _speedrun_pausable == -1:
                        _speedrun_pausable = 1
                3:
                    _order -= 1
                    if _order == -1:
                        _order = 1
                4:
                    _mirror -= 1
                    if _mirror == -1:
                        _mirror = 2
                5:
                    _swap -= 1
                    if _swap == -1:
                        _swap = 2

            ui_sounds.play_lateral()
            _update_labels()
        _:
            ui_sounds.play_invalid()


func cancel():
    ui_sounds.play_back()
    _save_selection()
    menu_loader.modifiers_to_save()

func play_selection():
    ui_sounds.play_selection()


func _save_selection():
    var dic: Dictionary = _save_data.duplicate()
    dic["cutscenes"] = _cutscenes
    dic["speedrun_timer"] = _speedrun_timer
    dic["speedrun_pausable"] = _speedrun_pausable
    dic["order"] = _order
    dic["mirror"] = _mirror
    dic["swap"] = _swap

    save_load.save_data("save_file_" + str(_save_file), dic)

    if _speedrun_timer > 0:
        save_load.save_data("keyboard_test", true)

    save_load.save_data("default_save_file", _save_file)







func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["sm_modifiers"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_cutscenes"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_speedrun"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_pausable"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_order"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_mirror"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["mod_swap"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
    i += 1
