extends Node


@export var save_load: Node
@export var faulty_joystick_timer: Timer
@export var subviewport_container: Node

var _actions_to_remap: Array[String] = ["left_l", "right_l", "up_l", "left_r", "right_r", "up_r", "reset", "pause"]
var _ui_actions: Array[String] = ["ui_accept", "ui_cancel"]
var _axis_motions: Array[String] = ["left_l", "right_l", "up_l", "left_r", "right_r", "up_r", "ui_left", "ui_right", "ui_up", "ui_down"]


var last_action_device: int
var _previous_action_device: int

var _mouse_hidden: bool
var _hide_mouse_time: float
var _last_mouse_position: Vector2

var _checking_faulty_joysticks: bool = true
var _joypads: Array[int]
var _repeated_initial_input_device_id: Array[int]
var _repeated_initial_input_axis: Array[int]
var _repeated_initial_input_strikes: Array[int]
var _disabled_device_ids: Array[int]
var _disabled_axis: Array[int]

var _debug_key_count: int

var screenshot_count: int

signal device_changed

func _ready():
    Global.general_input_controller = self
    if Global.mobile:
        last_action_device = 2

    _load_bindings.call_deferred()

    _joypads = Input.get_connected_joypads()
    faulty_joystick_timer.timeout.connect(_stop_checking_faulty_joysticks, 4)


func _process(delta: float) -> void :
    if _last_mouse_position != get_viewport().get_mouse_position():
        _hide_mouse_time = 0
        _last_mouse_position = get_viewport().get_mouse_position()
        if _mouse_hidden:
            _mouse_hidden = false
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    elif !_mouse_hidden:
        if _hide_mouse_time < 1:
            _hide_mouse_time += delta
        elif is_cursor_over_window() && DisplayServer.window_is_focused(0):
            _mouse_hidden = true
            Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

    if _stop_checking_faulty_joysticks:
        for joypad in _joypads:
            for axis in range(0, 11):
                var value = Input.get_joy_axis(joypad, axis)
                if abs(value) >= 0.5:
                    var found: bool
                    for i in _repeated_initial_input_device_id.size():
                        if _repeated_initial_input_device_id[i] == joypad && _repeated_initial_input_axis[i] == axis:
                            _repeated_initial_input_strikes[i] += 1
                            found = true
                            break
                    if !found:
                        _repeated_initial_input_device_id.append(joypad)
                        _repeated_initial_input_axis.append(axis)
                        _repeated_initial_input_strikes.append(1)


func _input(event: InputEvent) -> void :
    _previous_action_device = last_action_device

    if event is InputEventKey:
        if Input.is_action_just_pressed("alt_enter"):
            if DisplayServer.window_get_mode() == 0:
                DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
            else:
                DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
                var data: Dictionary = save_load.get_loaded_settings()
                if data["video"].has("window_resolution"):
                    DisplayServer.window_set_size(data["video"]["window_resolution"])
            subviewport_container.on_size_changed()
            return

    if event is InputEventKey:
        last_action_device = 0
    elif event is InputEventJoypadButton || event is InputEventJoypadMotion:


        for action in _actions_to_remap:
            if Input.is_action_just_pressed(action):
                last_action_device = 1
                return

        for action in _ui_actions:
            if Input.is_action_just_pressed(action):
                last_action_device = 1
                return
    elif event is InputEventScreenTouch:
        last_action_device = 2

    if Input.is_action_just_pressed("debug"):
        _debug_key_count += 1
        if _debug_key_count >= 4:
            Global.allow_debug_controls = true

    if _previous_action_device != last_action_device:
        device_changed.emit(last_action_device)







func _stop_checking_faulty_joysticks():
    _checking_faulty_joysticks = false

    for i in _repeated_initial_input_strikes.size():
        if _repeated_initial_input_strikes[i] > 30:
            _disabled_device_ids.append(_repeated_initial_input_device_id[i])
            _disabled_axis.append(_repeated_initial_input_axis[i])

    disable_faulty_input()


func disable_faulty_input():
    for action in _axis_motions:
        var events: = InputMap.action_get_events(action)
        for event in events:
            if event is InputEventJoypadMotion && event.device in _disabled_device_ids:
                for i in _disabled_device_ids.size():
                    match _disabled_axis[i]:
                        0:
                            if action in ["ui_left", "ui_right", "left_l", "right_l"]:
                                InputMap.action_erase_event(action, event)
                                print("Disabling device ", _disabled_device_ids[i], " on axis ", _disabled_axis[i])
                        1:
                            if action in ["ui_up", "ui_down"]:
                                InputMap.action_erase_event(action, event)
                                print("Disabling device ", _disabled_device_ids[i], " on axis ", _disabled_axis[i])
                        2:
                            if action in ["left_r", "right_r"]:
                                InputMap.action_erase_event(action, event)
                                print("Disabling device ", _disabled_device_ids[i], " on axis ", _disabled_axis[i])
                        4:
                            if action in ["up_l"]:
                                InputMap.action_erase_event(action, event)
                                print("Disabling device ", _disabled_device_ids[i], " on axis ", _disabled_axis[i])
                        5:
                            if action in ["up_r"]:
                                InputMap.action_erase_event(action, event)
                                print("Disabling device ", _disabled_device_ids[i], " on axis ", _disabled_axis[i])
                    break


func is_cursor_over_window() -> bool:
    var window_rect = Rect2(
    DisplayServer.window_get_position(), 
    DisplayServer.window_get_size()
    )
    var cursor_pos = DisplayServer.mouse_get_position()
    return window_rect.has_point(cursor_pos)


func _load_bindings():
    var data: Dictionary = save_load.get_loaded_settings()

    if data.has("controls"):
        for action in data["controls"]:
            InputMap.action_erase_events(action)
            for event in data["controls"][action]:
                InputMap.action_add_event(action, event)

    else:
        data["controls"] = _get_deafult_bindings()

        for action in data["controls"]:
            InputMap.action_erase_events(action)
            for event in data["controls"][action]:
                InputMap.action_add_event(action, event)

        save_load.save_settings("controls", data["controls"])


func _get_deafult_bindings():
    var dic: Dictionary

    for i in _actions_to_remap.size():
        dic[_actions_to_remap[i]] = InputMap.action_get_events(_actions_to_remap[i])

    return dic
