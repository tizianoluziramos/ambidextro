extends Node

@export var left_side: bool
@export var action_left: String
@export var action_right: String
@export var action_up: String
@export var joystick: Sprite2D
@export var joystick_arrow: Sprite2D
@export var subviewport_container: SubViewportContainer

var _enabled: bool

var _touch_index: int = -1
var _gesture_origin: Vector2
var _previous_point: Vector2
var _current_drag_direction: int
var _change_direction_to_left_count: int
var _change_direction_to_right_count: int
var _dragged_this_frame: bool

var _last_gesture: String

var _player_chara: Node
var _hide_visual_input: bool
var _change_visual_input: bool
var _time_to_hide_visual_input: float
const _TIME_TO_HIDE_JUMP_INPUT: float = 0.2

const _GESTURE_DISTANCE: float = 50.0
const _JUMP_GESTURE_DISTANCE: float = 60.0
const _DIAGONAL_MARGIN: float = 0.7
const _REDUCED_DIAGONAL_MARGIN: float = 0.75


func _ready() -> void :
    if !Global.mobile:
        queue_free()

    subviewport_container.size_changed.connect(_resize_joystick)
    await get_tree().create_timer(0.5).timeout
    _resize_joystick.call_deferred()

    joystick.visible = true
    _show_visual_input.call_deferred("release")

    disable()


func _process(delta: float):
    if !_enabled: return

    if !_dragged_this_frame:
        _update_gesture_origin(_previous_point)

    if _hide_visual_input || _change_visual_input:
        _time_to_hide_visual_input -= delta
        if _time_to_hide_visual_input <= 0:
            if _hide_visual_input:
                _hide_visual_input = false
                _player_chara.mobile_input_arrow.visible = false
            elif _change_visual_input:
                _change_visual_input = false
                if Input.is_action_pressed(action_left):
                    _show_visual_input("left")
                elif Input.is_action_pressed(action_right):
                    _show_visual_input("right")
            else:
                _hide_visual_input = false
                _change_visual_input = false


func _input(event: InputEvent) -> void :
    if !_enabled: return

    if event is InputEventScreenTouch:
        if event.position.x < get_viewport().get_size().x / 2 && !left_side:
            if event.index == _touch_index:
                _reset()
                get_viewport().set_input_as_handled()
            return
        elif event.position.x > get_viewport().get_size().x / 2 && left_side:
            if event.index == _touch_index:
                _reset()
                get_viewport().set_input_as_handled()
            return

        if event.pressed:
            _touch_index = event.index
            _gesture_origin = event.position
            get_viewport().set_input_as_handled()
        elif event.index == _touch_index:
            _reset()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        if event.position.x < get_viewport().get_size().x / 2 && !left_side:
            return
        elif event.position.x > get_viewport().get_size().x / 2 && left_side:
            return

        _dragged_this_frame = true
        _previous_point = event.position
        if event.index == _touch_index:
            joystick.global_position = event.position
            _interpret_gesture(_previous_point)
            get_viewport().set_input_as_handled()


func _interpret_gesture(point: Vector2):
    _ensure_chara()
    _manage_change_of_drag_direction(point)

    if _gesture_origin.distance_to(point) > _GESTURE_DISTANCE:

        if point.y < _gesture_origin.y - _JUMP_GESTURE_DISTANCE * _DIAGONAL_MARGIN:
            if point.x < _gesture_origin.x - _GESTURE_DISTANCE * _DIAGONAL_MARGIN:

                if Input.is_action_pressed(action_left):
                    if point.y < _gesture_origin.y - _JUMP_GESTURE_DISTANCE * _REDUCED_DIAGONAL_MARGIN:
                        _manage_gesture("up_left", point)
                    else:
                        _manage_gesture("left", point)
                else:
                    _manage_gesture("up_left", point)
            elif point.x > _gesture_origin.x + _GESTURE_DISTANCE * _DIAGONAL_MARGIN:

                if Input.is_action_pressed(action_right):
                    if point.y < _gesture_origin.y - _JUMP_GESTURE_DISTANCE * _REDUCED_DIAGONAL_MARGIN:
                        _manage_gesture("up_right", point)
                    else:
                        _manage_gesture("right", point)
                else:
                    _manage_gesture("up_right", point)
            else:
                if Input.is_action_pressed(action_left):
                    _manage_gesture("up_left", point)
                elif Input.is_action_pressed(action_right):
                    _manage_gesture("up_right", point)
                else:
                    _manage_gesture("up", point)


        elif point.y > _gesture_origin.y + _GESTURE_DISTANCE * _DIAGONAL_MARGIN * 0.75:
            _manage_gesture("undo_jump", point)





        elif !Input.is_action_pressed(action_left) && point.x < _gesture_origin.x - _GESTURE_DISTANCE * _DIAGONAL_MARGIN:
            _manage_gesture("left", point)
            _current_drag_direction = 1
        elif !Input.is_action_pressed(action_right) && point.x > _gesture_origin.x + _GESTURE_DISTANCE * _DIAGONAL_MARGIN:
            _manage_gesture("right", point)
            _current_drag_direction = 2


func _manage_gesture(gesture: String, point: Vector2):
    _last_gesture = gesture
    match gesture:
        "left":
            Input.action_press(action_left)
            Input.action_release(action_right)
            _show_visual_input(gesture)
        "right":
            Input.action_press(action_right)
            Input.action_release(action_left)
            _show_visual_input(gesture)
        "up":
            Input.action_press(action_up)
            Input.action_release(action_up)

            Input.action_release(action_right)
            Input.action_release(action_left)

            _show_visual_input(gesture)
        "up_left":
            Input.action_press(action_left)
            Input.action_release(action_right)

            Input.action_press(action_up)
            Input.action_release(action_up)

            _show_visual_input(gesture)
        "up_right":
            Input.action_press(action_right)
            Input.action_release(action_left)

            Input.action_press(action_up)
            Input.action_release(action_up)

            _show_visual_input(gesture)
        "undo_jump":
            pass
        "center":
            Input.action_release(action_left)
            Input.action_release(action_right)

            _show_visual_input(gesture)

            if _player_chara:
                _player_chara.mobile_input_arrow.visible = false

    _update_gesture_origin.call_deferred(point)


func _update_gesture_origin(point: Vector2):
    _gesture_origin = point


func _manage_change_of_drag_direction(point: Vector2):
    if _current_drag_direction == 1 && _previous_point.x > point.x:
        _change_direction_to_right_count = 0
        _change_direction_to_left_count += 1
    elif _current_drag_direction == 2 && _previous_point.x < point.x:
        _change_direction_to_left_count = 0
        _change_direction_to_right_count += 1
    else:
        _change_direction_to_left_count = 0
        _change_direction_to_right_count = 0

    if _change_direction_to_right_count >= 3 && _gesture_origin.x > point.x:
        _update_gesture_origin.call_deferred(point)
        _change_direction_to_right_count = 0
    elif _change_direction_to_left_count >= 3 && _gesture_origin.x < point.x:
        _update_gesture_origin.call_deferred(point)
        _change_direction_to_left_count = 0


func _reset():
    _touch_index = -1
    Input.action_release(action_up)
    Input.action_release(action_left)
    Input.action_release(action_right)

    _show_visual_input("release")


func _ensure_chara():
    if _player_chara == null:
        if Global.player_charas.size() < 2: return
        if left_side:
            _player_chara = Global.player_charas[0]
        else:
            _player_chara = Global.player_charas[1]


func _show_visual_input(input: String):
    match input:
        "left":
            joystick_arrow.visible = true
            joystick_arrow.rotation_degrees = -90
            joystick_arrow.position = Vector2(-225, 0)

            if !_player_chara: return
            _hide_visual_input = false
            _player_chara.mobile_input_arrow.visible = true
            _player_chara.mobile_input_arrow.rotation_degrees = -90
            _player_chara.mobile_input_arrow.position = Vector2(-10, -5)

        "right":
            if !_player_chara: return
            _hide_visual_input = false
            _player_chara.mobile_input_arrow.visible = true
            _player_chara.mobile_input_arrow.rotation_degrees = 90
            _player_chara.mobile_input_arrow.position = Vector2(10, -5)

            joystick_arrow.visible = true
            joystick_arrow.rotation_degrees = 90
            joystick_arrow.position = Vector2(225, 0)
        "up":
            joystick_arrow.visible = true
            joystick_arrow.rotation_degrees = 0
            joystick_arrow.position = Vector2(0, -225)

            _hide_visual_input = true
            _time_to_hide_visual_input = _TIME_TO_HIDE_JUMP_INPUT

            if !_player_chara: return
            _player_chara.mobile_input_arrow.visible = true
            _player_chara.mobile_input_arrow.rotation_degrees = 0
            _player_chara.mobile_input_arrow.position = Vector2(-10, -5)
        "up_left":
            joystick_arrow.visible = true
            joystick_arrow.rotation_degrees = -45
            joystick_arrow.position = Vector2(-160, -160)

            _change_visual_input = true
            _time_to_hide_visual_input = _TIME_TO_HIDE_JUMP_INPUT

            if !_player_chara: return
            _player_chara.mobile_input_arrow.visible = true
            _player_chara.mobile_input_arrow.rotation_degrees = -45
            _player_chara.mobile_input_arrow.position = Vector2(-10, -17)
        "up_right":
            joystick_arrow.visible = true
            joystick_arrow.rotation_degrees = 45
            joystick_arrow.position = Vector2(160, -160)

            _change_visual_input = true
            _time_to_hide_visual_input = _TIME_TO_HIDE_JUMP_INPUT

            if !_player_chara: return
            _player_chara.mobile_input_arrow.visible = true
            _player_chara.mobile_input_arrow.rotation_degrees = 45
            _player_chara.mobile_input_arrow.position = Vector2(10, -17)
        "undo_jump":
            pass
        "center":
            if !_player_chara: return
            _player_chara.mobile_input_arrow.visible = false
        "release":
            joystick_arrow.visible = false

            var resolution: Vector2 = get_viewport().get_size()
            if left_side:
                joystick.global_position = Vector2(resolution.x / 10, resolution.y - resolution.y / 7)
            else:
                joystick.global_position = Vector2(resolution.x - resolution.x / 10, resolution.y - resolution.y / 7)

            if !_player_chara: return
            _player_chara.mobile_input_arrow.visible = false


func _resize_joystick():
    var resolution: Vector2 = get_viewport().get_size()
    var scale: float = resolution.y / 2880.0
    joystick.scale = Vector2(scale, scale)


func disable():
    _enabled = false
    joystick.visible = false


func enable():
    _enabled = true
    joystick.visible = true
