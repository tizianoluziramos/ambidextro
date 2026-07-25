extends Node2D

@export var numbers_font: Array[Texture2D]
@export var hours_sprite: Sprite2D
@export var minutes_sprites: Array[Sprite2D]
@export var seconds_sprites: Array[Sprite2D]
@export var mili_sprites: Array[Sprite2D]

@export var color_rects: Array[ColorRect]
@export var dots: Array[Sprite2D]
@export var stop_visual_update: bool
@export var dark_colors: bool
@export var stopped_colors: bool

var _time: float
var _hours: int
var _minutes: int
var _minutes_1: int
var _minutes_2: int
var _seconds: int
var _seconds_1: int
var _seconds_2: int
var _mili: float
var _mili_1: int
var _mili_2: int
var _mili_3: int

var _showing: bool
var _max_reached: bool

var _tween: Tween


func _ready() -> void :
    if !Global.speedrun_mode || !Global.in_story_mode:
        visible = false
        return

    if dark_colors:
        _change_colors_to_dark()

    if stopped_colors:
        _change_colors_to_stopped()

    _showing = true
    _update_timer()


func _process(_delta: float) -> void :
    if stop_visual_update: return
    if !Global.speedrun_mode || !Global.in_story_mode:
        return
    elif !_showing:
        _showing = true
        visible = true
    _update_timer()


func _update_timer():
    if _max_reached: return

    _time = Global.speedrun_time

    _hours = 0
    _minutes = 0
    _minutes_1 = 0
    _minutes_2 = 0
    _seconds = 0
    _seconds_1 = 0
    _seconds_2 = 0
    _mili = 0
    _mili_1 = 0
    _mili_2 = 0
    _mili_3 = 0

    while _time >= 3600:
        _time -= 3600
        _hours += 1

    while _time >= 60:
        _time -= 60
        _minutes += 1

    _seconds = floor(_time)

    _mili = (_time - _seconds) * 1000

    if _hours > 9:
        _max_reached = true
        _hours = 9
        _minutes = 59
        _seconds = 59
        _mili = 999

    while _minutes >= 10:
        _minutes -= 10
        _minutes_1 += 1
    _minutes_2 = _minutes

    while _seconds >= 10:
        _seconds -= 10
        _seconds_1 += 1
    _seconds_2 = _seconds

    while _mili >= 100:
        _mili -= 100
        _mili_1 += 1

    while _mili >= 10:
        _mili -= 10
        _mili_2 += 1
    _mili_3 = int(_mili)


    hours_sprite.texture = numbers_font[_hours]

    minutes_sprites[0].texture = numbers_font[_minutes_1]
    minutes_sprites[1].texture = numbers_font[_minutes_2]

    seconds_sprites[0].texture = numbers_font[_seconds_1]
    seconds_sprites[1].texture = numbers_font[_seconds_2]

    mili_sprites[0].texture = numbers_font[_mili_1]
    mili_sprites[1].texture = numbers_font[_mili_2]
    mili_sprites[2].texture = numbers_font[_mili_3]


func change_number_colors_for_end_credits():
    _tween = create_tween()
    _tween.set_parallel(true)
    _tween.tween_property(hours_sprite, "modulate", Color.WHITE, 1)

    _tween.tween_property(minutes_sprites[0], "modulate", Color.WHITE, 1)
    _tween.tween_property(minutes_sprites[1], "modulate", Color.WHITE, 1)

    _tween.tween_property(seconds_sprites[0], "modulate", Color.WHITE, 1)
    _tween.tween_property(seconds_sprites[1], "modulate", Color.WHITE, 1)

    _tween.tween_property(mili_sprites[0], "modulate", Color.WHITE, 1)
    _tween.tween_property(mili_sprites[1], "modulate", Color.WHITE, 1)
    _tween.tween_property(mili_sprites[2], "modulate", Color.WHITE, 1)

    _tween.tween_property(dots[0], "modulate", Color.WHITE, 1)
    _tween.tween_property(dots[1], "modulate", Color.WHITE, 1)
    _tween.tween_property(dots[2], "modulate", Color.WHITE, 1)

    _tween.tween_property(color_rects[0], "modulate", Color.TRANSPARENT, 1)
    _tween.tween_property(color_rects[1], "modulate", Color.TRANSPARENT, 1)


func _change_colors_to_dark():
    color_rects[0].color = Color.TRANSPARENT
    color_rects[1].color = Color.TRANSPARENT
    hours_sprite.modulate = Color.GRAY
    minutes_sprites[0].modulate = Color.GRAY
    minutes_sprites[1].modulate = Color.GRAY
    seconds_sprites[0].modulate = Color.GRAY
    seconds_sprites[1].modulate = Color.GRAY
    mili_sprites[0].modulate = Color.GRAY
    mili_sprites[1].modulate = Color.GRAY
    mili_sprites[2].modulate = Color.GRAY
    dots[0].modulate = Color.GRAY
    dots[1].modulate = Color.GRAY
    dots[2].modulate = Color.GRAY


func _change_colors_to_stopped():
    color_rects[0].color = Color.TRANSPARENT
    color_rects[1].color = Color.TRANSPARENT
    hours_sprite.modulate = Color.DIM_GRAY
    minutes_sprites[0].modulate = Color.DIM_GRAY
    minutes_sprites[1].modulate = Color.DIM_GRAY
    seconds_sprites[0].modulate = Color.DIM_GRAY
    seconds_sprites[1].modulate = Color.DIM_GRAY
    mili_sprites[0].modulate = Color.DIM_GRAY
    mili_sprites[1].modulate = Color.DIM_GRAY
    mili_sprites[2].modulate = Color.DIM_GRAY
    dots[0].modulate = Color.DIM_GRAY
    dots[1].modulate = Color.DIM_GRAY
    dots[2].modulate = Color.DIM_GRAY
