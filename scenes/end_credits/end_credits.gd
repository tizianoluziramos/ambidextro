extends Node2D


@export var logo_ambidextro: Node2D
@export var logo_majorariatto: Node2D
@export var credits_label: Label
@export var version_label: Label
@export var full_fade: ColorRect
@export var _timer: Timer


var menu_loader: Node

var _index: int
var _lines_index: int
var _tween: Tween
var _tween_2: Tween
var _label_shown: bool

const FADE_DURATION: float = 0.5
const SLOW_FADE_DURATION: float = 1
const END_FADE_DURATION: float = 2
const LOGO_MOVE_DURATION: float = 2
const CREDIT_DURATION: float = 3

func _ready() -> void :
    logo_ambidextro.self_modulate = Color.TRANSPARENT
    logo_ambidextro.position = Vector2.ZERO
    logo_majorariatto.self_modulate = Color.TRANSPARENT
    credits_label.self_modulate = Color.TRANSPARENT
    full_fade.self_modulate = Color.TRANSPARENT
    remove_child(full_fade)
    get_parent().add_child(full_fade)

    _next()


func _next():
    var wait: float = CREDIT_DURATION

    match _index:
        0:
            _tween = create_tween()
            _tween.tween_property(logo_ambidextro, "self_modulate", Color.WHITE, SLOW_FADE_DURATION)
            wait = 1

        1:
            _tween = create_tween()
            _tween.tween_property(logo_ambidextro, "position:y", -90, LOGO_MOVE_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
            wait = 2
        2:
            _show_next_line()

        10:
            _tween = create_tween()
            _tween.tween_property(credits_label, "self_modulate", Color.TRANSPARENT, SLOW_FADE_DURATION)

            _tween_2 = create_tween()
            _tween_2.tween_property(logo_majorariatto, "self_modulate", Color.WHITE, SLOW_FADE_DURATION)
            wait = CREDIT_DURATION

        11:
            _tween = create_tween()
            _tween.tween_property(full_fade, "self_modulate", Color.WHITE, END_FADE_DURATION)
            _tween.finished.connect(_load_main_menu, 4)
            wait = 10

        _:
            _tween = create_tween()
            _tween.tween_property(credits_label, "self_modulate", Color.TRANSPARENT, FADE_DURATION)
            _tween.finished.connect(_show_next_line, 4)

    _index += 1
    _timer.start(wait)
    _timer.timeout.connect(_next, 4)


func _show_next_line():
    load_credits_page(_lines_index)
    _lines_index += 1

    var duration: float = FADE_DURATION
    if _lines_index == 1: duration = SLOW_FADE_DURATION
    _tween = create_tween()
    _tween.tween_property(credits_label, "self_modulate", Color.WHITE, duration)

    if !_label_shown && Global.speedrun_mode:
        version_label.text = "v" + Global.version
        _tween.set_parallel(true)
        _tween.tween_property(version_label, "self_modulate", Color.WHITE, duration)


func load_credits_page(index: int):
    var lang: String = Global.language
    var text: String
    match index:
        0:
            text += Global.translations["credits_created"][lang]
        1:
            text += Global.translations["credits_music"][lang]
        2:
            text += Global.translations["credits_illustrations"][lang]
        3:
            text += Global.translations["credits_thanks"][lang]
            text += "\n\n"
            text += Global.translations["credits_lariat"][lang]
            text += "\n"
            text += Global.translations["credits_nico"][lang]
            text += "\n"
            text += Global.translations["credits_migu"][lang]
            text += "\n"
            text += Global.translations["credits_guinxu"][lang]
            text += "\n"
            text += Global.translations["credits_gius"][lang]
            text += "\n"
            text += Global.translations["credits_kony"][lang]
            text += "\n"
            text += Global.translations["credits_nosgo"][lang]
            text += "\n"
            text += Global.translations["credits_david_chen"][lang]
            text += "\n"
            text += Global.translations["credits_fanzy_pants"][lang]
        4:
            text += Global.translations["credits_engine"][lang]
        5:
            text += Global.translations["credits_shaders"][lang]
            text += "\n\n"
            text += Global.translations["credits_shaders1"][lang]
            text += "\n\n\n"
            text += Global.translations["credits_fonts"][lang]
            text += "\n\n"
            text += Global.translations["credits_fonts1"][lang]
            text += "\n"
            text += Global.translations["credits_fonts2"][lang]
            text += "\n"
            text += Global.translations["credits_fonts3"][lang]
        6:
            text += Global.translations["credits_sounds"][lang]
            text += "\n\n"
            text += Global.translations["credits_sfx1"][lang]
            text += "\n"
            text += Global.translations["credits_sfx2"][lang]
            text += "\n"
            text += Global.translations["credits_sfx3"][lang]
            text += "\n"
            text += Global.translations["credits_sfx4"][lang]
            text += "\n"
            text += Global.translations["credits_sfx5"][lang]
            text += "\n"
            text += Global.translations["credits_sfx6"][lang]
            text += "\n"
            text += Global.translations["credits_sfx7"][lang]
            text += "\n"
            text += Global.translations["credits_sfx8"][lang]
            text += "\n"
            text += Global.translations["credits_sfx9"][lang]
            text += "\n"
            text += Global.translations["credits_sfx10"][lang]
            text += "\n"
            text += Global.translations["credits_sfx11"][lang]
        7:
            text += Global.translations["credits_majorariatto"][lang] + " " + Global.years

    credits_label.text = text


func _load_main_menu():
    menu_loader.end_credits_to_main()
    full_fade.fade_in()
    _destroy()


func _destroy():
    menu_loader.level_loader.unload_level()
    self.queue_free()
