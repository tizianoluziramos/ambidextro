extends Node2D


@export var key_visualizers: Array[Node]
@export var done: Node
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var save_load: Node

var _time_pressed: float
const _TIME_REQUIRED: float = 0.5

var active: bool = true

var _return_in_cooldown: bool = true


func _ready():
    _translate()
    await get_tree().create_timer(2.0).timeout
    _return_in_cooldown = false


func _process(delta: float) -> void :
    if !active: return

    if !_return_in_cooldown && Input.is_action_just_pressed("return"):
        active = false
        save_load.save_settings("keyboard_test", true)
        menu_loader.load_keys_finder(false)

    if Input.is_action_just_pressed("ui_cancel"):
        active = false
        proceed()

    for key_visualizer in key_visualizers:
        if !key_visualizer.is_pressed():
            _time_pressed = 0
            return

    _time_pressed += delta

    if _time_pressed >= _TIME_REQUIRED:
        passed()



func passed():
    active = false
    var viewport: Viewport = get_viewport()
    viewport.set_input_as_handled()

    done.visible = true
    await get_tree().create_timer(1.0).timeout
    proceed()


func proceed():
    save_load.save_settings("keyboard_test", true)
    menu_loader.manage_finish_keyboard_test()



func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        labels[0].theme = Global.main_theme
        labels[3].theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["kt_title"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["kt_info1"][lang]
    i += 1
    labels[i].text = Global.translations["kt_info2"][lang]
    i += 1
    labels[i].text = Global.translations["kt_title"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["kt_finished"][lang]
