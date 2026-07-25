extends Node

@export var delete_options_label: Node
@export var delete_options: Node
@export var save_file_options: Node
@export var options: Node
@export var save_menu: Node
@export var question_label: Label
@export var option_labels: Array[Label]
@export var clickable_areas: Array[Node]

var _save_file: int
var _question_selected: bool
var _question_clicked_counter: int
var _deleting_everything: bool

var _clickable_areas_initialized: bool


func _ready():
    for area in clickable_areas:
        area.disable()

func initialize(save_file: int):
    _save_file = save_file
    _question_selected = false
    _deleting_everything = false
    options.active = false
    delete_options_label.activate(1)

    save_file_options.visible = false
    delete_options_label.visible = true
    delete_options.visible = true

    _save_file = save_file
    question_label.text = Global.translations["sm_delete_save"][Global.language].to_upper() + " " + str(save_file)

    if Global.mobile:
        save_menu.disable_clickable_areas()

    if Global.mobile:
        manage_clickable_areas.call_deferred()


func manage_clickable_areas():
    if !_clickable_areas_initialized:
        _clickable_areas_initialized = true
        for area in clickable_areas:
            area.initialize()
    else:
        for area in clickable_areas:
            area.enable()


func accept_option(option: String, option_index: int):
    match option:
        "yes":
            save_menu.ui_sounds.play_accept()
            if _deleting_everything:
                save_menu.save_load.create_default_data()
                save_menu.save_load.create_default_settings()
                _reset_game()
            else:
                save_menu.delete_save_file()
            hide_menu()
        "no":
            save_menu.ui_sounds.play_back()
            hide_menu()


func hide_menu():
    delete_options_label.visible = false
    delete_options.visible = false
    save_file_options.visible = true

    delete_options_label.active = false
    options.activate(3)

    options.select_option(3)

    if Global.mobile:
        save_menu.enable_clickable_areas()
        for area in clickable_areas:
            area.disable()


func increase(string: String, option_index: int):
    save_menu.ui_sounds.play_invalid()


func decrease(string: String, option_index: int):
    save_menu.ui_sounds.play_invalid()


func play_selection():
    save_menu.ui_sounds.play_selection()

func cancel():
    save_menu.ui_sounds.play_back()
    hide_menu()


func _reset_game():
    delete_options_label.active = false
    Global.reset()
    get_tree().reload_current_scene()
