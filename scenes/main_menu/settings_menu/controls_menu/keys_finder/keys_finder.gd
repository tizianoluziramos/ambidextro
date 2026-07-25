extends Node2D


@export var key_visualizers: Array[Node]
@export var timer_line: ColorRect
@export var done: Node
@export var labels: Array[Label]
@export var sublabels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var save_load: Node
var came_from_controls_menu: bool

var _keys_pressed: Array[String]
var _event_keys: Array[InputEventKey]
var _all_keys_pressed: Array[String]
var _tweens: Array[Tween]
var _actions_to_remap: Array[String] = ["left_l", "up_l", "right_l", "left_r", "up_r", "right_r"]

var _time_pressed: float
const _TIME_REQUIRED: float = 1.5

const _FADE_DURATION: float = 0.2

var active: bool = true

var _pause_event: InputEvent
var _reset_event: InputEvent
var _backspace_event: InputEvent

func _ready() -> void :
    _translate()
    _tweens.resize(6)
    _keys_pressed.resize(6)
    _event_keys.resize(6)

    for i in key_visualizers.size():
        key_visualizers[i].color_rect.modulate = Color.DIM_GRAY

    var events: = InputMap.action_get_events("pause")
    for event in events:
        if event is InputEventKey:
            _pause_event = event
            break
    events = InputMap.action_get_events("reset")
    for event in events:
        if event is InputEventKey:
            _reset_event = event
            break
    _backspace_event = InputEventKey.new()
    _backspace_event.key_label = KEY_BACKSPACE


func _process(delta: float) -> void :
    if !active: return

    if Input.is_action_just_pressed("ui_cancel"):
        ui_sounds.play_back()
        proceed()

    for key_pressed in _keys_pressed:
        if key_pressed.is_empty():
            _time_pressed = 0
            timer_line.visible = false
            return

    _time_pressed += delta
    timer_line.scale.x = 1 - _time_pressed / _TIME_REQUIRED
    timer_line.visible = true

    if _time_pressed >= _TIME_REQUIRED:
        passed()


func passed():
    active = false

    for i in _event_keys.size():
        var previous_events: Array[InputEvent] = InputMap.action_get_events(_actions_to_remap[i])
        for previous_event in previous_events:
            if previous_event is InputEventKey:
                InputMap.action_erase_event(_actions_to_remap[i], previous_event)
                InputMap.action_add_event(_actions_to_remap[i], _event_keys[i])

                if _event_keys[i] == _reset_event:
                    InputMap.action_erase_event("reset", _reset_event)
                    InputMap.action_add_event(_actions_to_remap[i], _backspace_event)

    var viewport: Viewport = get_viewport()
    viewport.set_input_as_handled()

    save_load.save_settings("keyboard_test", true)
    _save_bindings()

    done.visible = true
    await get_tree().create_timer(1.0).timeout
    proceed()


func _save_bindings():
    var dic: Dictionary

    for i in _actions_to_remap.size():
        dic[_actions_to_remap[i]] = InputMap.action_get_events(_actions_to_remap[i])

    save_load.save_settings("controls", dic)


func proceed():
    if !came_from_controls_menu:
        menu_loader.manage_finish_keyboard_test()
    else:
        menu_loader.test_to_controls()


func _input(event: InputEvent) -> void :
    if event is InputEventKey:
        if event == _reset_event || event == _backspace_event:
            return

        if event.is_pressed():

            if event.as_text() != "+":
                var parts: PackedStringArray = event.as_text().split("+")
                for part in parts:
                    _manage_event_pressed(event, part)
            else:
                _manage_event_pressed(event, event.as_text())

        elif event.is_released():

            if event.as_text() != "+":
                var parts: PackedStringArray = event.as_text().split("+")
                for part in parts:
                    _manage_event_released(part)
            else:
                _manage_event_released(event.as_text())



func _manage_event_pressed(event_key: InputEventKey, event: String):
    if !_all_keys_pressed.has(event):
        _all_keys_pressed.append(event)
        ui_sounds.play_key()

    if !_keys_pressed.has(event):
        for i in _keys_pressed.size():
            if _keys_pressed[i].is_empty():
                _keys_pressed[i] = event
                _event_keys[i] = event_key

                var keycode = DisplayServer.keyboard_get_keycode_from_physical(event_key.physical_keycode)
                var text: String = OS.get_keycode_string(keycode)
                key_visualizers[i].key_label.text = text

                if _tweens[i] && _tweens[i].is_running(): _tweens[i].custom_step(999)
                _tweens[i] = create_tween()
                _tweens[i].tween_property(key_visualizers[i].color_rect, "modulate", Color.WHITE, _FADE_DURATION)

                break


func _manage_event_released(event: String):
    if _all_keys_pressed.has(event):
        _all_keys_pressed.erase(event)

    for i in _keys_pressed.size():

        if _keys_pressed[i] == event:
            _keys_pressed[i] = ""
            _event_keys[i] = null

            if _tweens[i] && _tweens[i].is_running(): _tweens[i].custom_step(999)
            _tweens[i] = create_tween()
            _tweens[i].tween_property(key_visualizers[i].color_rect, "modulate", Color.DIM_GRAY, _FADE_DURATION)
            key_visualizers[i].key_label.text = ""
            break


func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        labels[0].theme = Global.main_theme
        labels[3].theme = Global.main_theme
        labels[4].theme = Global.main_theme
        labels[5].theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setmc_test"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["kf_info1"][lang] + "\n" + Global.translations["kf_info2"][lang] + "\n" + Global.translations["kf_info3"][lang]
    i += 1
    labels[i].text = Global.translations["kf_info4"][lang] + "\n" + Global.translations["kf_info5"][lang]
    i += 1
    labels[i].text = Global.translations["kf_left_hand"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["kf_left_right"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmc_test"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["kf_updated"][lang]

    i = 0
    sublabels[i].text = Global.translations["setmc_left"][lang]
    i += 1
    sublabels[i].text = Global.translations["setmc_jump"][lang]
    i += 1
    sublabels[i].text = Global.translations["setmc_right"][lang]
    i += 1
    sublabels[i].text = Global.translations["setmc_left"][lang]
    i += 1
    sublabels[i].text = Global.translations["setmc_jump"][lang]
    i += 1
    sublabels[i].text = Global.translations["setmc_right"][lang]
    i += 1
