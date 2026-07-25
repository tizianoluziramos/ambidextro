extends Control

@export var key: int
@export var key_label: Label
@export var arrow: Sprite2D
@export var color_rect: ColorRect

var _pressed: bool
var _tween: Tween

const _FADE_DURATION: float = 0.1


func _ready() -> void :
    match key:
        0:
            key_label.text = "A"
            arrow.visible = false
        1:
            key_label.text = "W"
            arrow.visible = false
        2:
            key_label.text = "D"
            arrow.visible = false
        3:
            key_label.text = ""
            arrow.flip_h = true
            arrow.visible = true
        4:
            key_label.text = ""
            arrow.rotation_degrees = -90
            arrow.position.y = 13
            arrow.visible = true
        5:
            key_label.text = ""
            arrow.visible = true


func _input(event: InputEvent) -> void :
    if event is InputEventKey:
        match key:
            0:
                if event.key_label == KEY_A:
                    if event.is_pressed():
                        _do_press()
                    elif event.is_released():
                        _do_unpress()
            1:
                if event.key_label == KEY_W:
                    if event.is_pressed():
                        _do_press()
                    elif event.is_released():
                        _do_unpress()
            2:
                if event.key_label == KEY_D:
                    if event.is_pressed():
                        _do_press()
                    elif event.is_released():
                        _do_unpress()
            3:
                if event.key_label == KEY_LEFT:
                    if event.is_pressed():
                        _do_press()
                    elif event.is_released():
                        _do_unpress()
            4:
                if event.key_label == KEY_UP:
                    if event.is_pressed():
                        _do_press()
                    elif event.is_released():
                        _do_unpress()
            5:
                if event.key_label == KEY_RIGHT:
                    if event.is_pressed():
                        _do_press()
                    elif event.is_released():
                        _do_unpress()


func _do_press():
    _pressed = true
    if _tween && _tween.is_running(): _tween.custom_step(999)
    _tween = create_tween()
    _tween.tween_property(color_rect, "color", Color.LIGHT_GRAY, _FADE_DURATION)


func _do_unpress():
    _pressed = false
    if _tween && _tween.is_running(): _tween.custom_step(999)
    _tween = create_tween()
    _tween.tween_property(color_rect, "color", Color.DIM_GRAY, _FADE_DURATION)


func is_pressed():
    return _pressed
