extends Node2D

@export var options: Node
@export var labels: Array[Label]
@export var animation_player: AnimationPlayer

@export var v_box_container: BoxContainer
@export var logo: Sprite2D
@export var wizard_left: Sprite2D
@export var wizard_right: Sprite2D


var menu_loader: Node
var ui_sounds: Node
var save_load: Node
var general_input_controller: Node

var _active: bool = true
var _fusion: bool

func _ready():
    _translate.call_deferred()
    play_wizards_fade_in.call_deferred()

    if Global.mobile:
        _set_for_mobile()


func _set_for_mobile():
    v_box_container.add_theme_constant_override("separation", 10)
    v_box_container.position.y = 10

    labels[3].visible = false
    options.options.remove_at(3)

    options.selection_arrow.visible = false


func accept_option(option: String, _option_index: int):
    if !_active: return
    ui_sounds.play_accept()
    match option:
        "play":
            _manage_play()
        "levels":
            menu_loader.load_levels_menu()
        "settings":
            menu_loader.load_settings_menu()
        "exit":
            _manage_exit()


func _manage_exit():
    options.active = false
    _active = false
    await get_tree().create_timer(0.3).timeout
    get_tree().quit()


func _manage_play():
    menu_loader.load_save_menu()

func increase(option: String, option_index: int):
    ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    ui_sounds.play_invalid()


func cancel():
    if options.get_current_selection() == 3:
        _manage_exit()
    else:
        options.select_option(3)
        ui_sounds.play_selection()


func play_selection():
    ui_sounds.play_selection()



func play_wizards_fade_in():
    if !_fusion:
        animation_player.play("fade_in")


func play_wizards_fusion_animation():
    _fusion = true
    animation_player.stop()
    animation_player.play("fuse")


func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme

    labels[0].text = Global.translations["mm_play"][lang].to_upper()
    labels[1].text = Global.translations["mm_levels"][lang].to_upper()
    labels[2].text = Global.translations["mm_settings"][lang].to_upper()
    labels[3].text = Global.translations["mm_exit"][lang].to_upper()
