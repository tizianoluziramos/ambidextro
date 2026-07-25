extends Node2D


@export var options: Node
@export var device_label: Label
@export var key_labels: Array[Node]
@export var timer_bar: ColorRect
@export var input_names: Node
@export var test_label: Label
@export var labels: Array[Label]
@export var sublabels: Array[Label]
@export var custom_white: Color


var menu_loader: Node
var ui_sounds: Node
var save_load: Node
var general_input_controller: Node

var _index: int

var _is_remapping: bool
var _action_to_remap: String
var _option_index_remapping: int
var _actions_to_remap: Array[String] = ["left_l", "up_l", "right_l", "left_r", "up_r", "right_r", "reset", "pause"]
var _bindings_changed: bool

var _tween: Tween
var _tween_color: Tween

const _REMAPPING_TIME: float = 2.0


func _ready():
    _translate()


func initialize():
    if general_input_controller.last_action_device == 1:
        _index = 1
    _update_mapping_labels()


func accept_option(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_accept()
            options.select_option(11)
        "test":
            if _index == 0:
                ui_sounds.play_accept()
                menu_loader.load_keys_finder(true)
            else:
                ui_sounds.play_invalid()

        "default":
            ui_sounds.play_accept()
            _reset_to_default_bindings()

        "back":
            ui_sounds.play_back()
            _save_bindings()
            menu_loader.controls_to_settings()

        _:
            ui_sounds.play_accept()
            _initiate_remapping(option_index)


func increase(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _index += 1
            if _index > 1:
                _index = 0
            _update_mapping_labels()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    match option:
        "<":
            ui_sounds.play_lateral()
            _index -= 1
            if _index < 0:
                _index = 1
            _update_mapping_labels()
        _:
            ui_sounds.play_invalid()





func _input(event: InputEvent) -> void :
    if _is_remapping:

        if _index == 0:
            if event is InputEventKey && !event.is_echo() && event.is_pressed():
                var previous_events: Array[InputEvent] = InputMap.action_get_events(_action_to_remap)
                for previous_event in previous_events:
                    if previous_event is InputEventKey:
                        InputMap.action_erase_event(_action_to_remap, previous_event)
                InputMap.action_add_event(_action_to_remap, event)

                var viewport: Viewport = get_viewport()
                viewport.set_input_as_handled()

                _bindings_changed = true
                _end_remapping(false)


        else:
            if (event is InputEventJoypadButton || event is InputEventJoypadMotion) && !event.is_echo() && event.is_pressed():
                var previous_events: Array[InputEvent] = InputMap.action_get_events(_action_to_remap)
                for previous_event in previous_events:
                    if previous_event is InputEventJoypadButton || previous_event is InputEventJoypadMotion:
                        InputMap.action_erase_event(_action_to_remap, previous_event)
                InputMap.action_add_event(_action_to_remap, event)

                var viewport: Viewport = get_viewport()
                viewport.set_input_as_handled()

                _bindings_changed = true
                _end_remapping(false)


func _initiate_remapping(option_index: int):
    var lang: String = Global.language
    _option_index_remapping = option_index - 1
    options.active = false
    key_labels[_option_index_remapping].set("theme_override_colors/font_color", Color.YELLOW)
    key_labels[_option_index_remapping].text = Global.translations["setmc_press"][lang]

    _action_to_remap = _actions_to_remap[_option_index_remapping]

    await get_tree().create_timer(0.1).timeout

    timer_bar.scale.x = 1
    timer_bar.global_position = key_labels[_option_index_remapping].get_parent().get_child(0).get_child(0).global_position + Vector2(113, 12)
    timer_bar.visible = true
    _tween = create_tween()
    _tween.tween_property(timer_bar, "scale:x", 0, _REMAPPING_TIME)
    _tween.finished.connect(_end_remapping.bind(true), 4)

    set_remapping()


func set_remapping():
    _is_remapping = true



func _end_remapping(_cancel: bool):
    if !_is_remapping: return
    _is_remapping = false

    if _cancel: ui_sounds.play_back()
    else: ui_sounds.play_remap()

    if _tween && _tween.is_running(): _tween.custom_step(999)

    key_labels[_option_index_remapping].text = _get_formatted_key_event(_action_to_remap)
    key_labels[_option_index_remapping].set("theme_override_colors/font_color", custom_white)
    _manage_conflicts()

    await get_tree().create_timer(0.1).timeout
    options.active = true


func _manage_conflicts():
    var text: String
    for key in key_labels:
        text = key.text
        text = text.trim_prefix("(!) ")
        key.text = text
        key.set("theme_override_colors/font_color", custom_white)

    var conflict_indexes: Array[int]
    var inputs_text_1: PackedStringArray
    var inputs_text_2: PackedStringArray
    for i in key_labels.size():
        for j in range(i + 1, key_labels.size()):
            inputs_text_1 = key_labels[i].text.split(" / ")
            for k in inputs_text_1.size():
                inputs_text_2 = key_labels[j].text.split(" / ")
                for l in inputs_text_2.size():
                    if inputs_text_1[k] == inputs_text_2[l]:
                        if !conflict_indexes.has(i):
                            conflict_indexes.append(i)
                        if !conflict_indexes.has(j):
                            conflict_indexes.append(j)

    for conflict in conflict_indexes:
        key_labels[conflict].text = "(!) " + key_labels[conflict].text
        key_labels[conflict].set("theme_override_colors/font_color", Color.RED)


func _get_formatted_key_event(action_to_remap) -> String:
    var events: = InputMap.action_get_events(action_to_remap)
    var text: String
    for event in events:
        if _index == 0:
            if event is InputEventKey:
                text = input_names.get_label_for_input(event)
                return text
        else:

            if event is InputEventJoypadButton || event is InputEventJoypadMotion:
                if text.is_empty():
                    text = input_names.get_label_for_input(event)
                else:
                    text += " / " + input_names.get_label_for_input(event)
    return text


func _update_mapping_labels():
    var lang: String = Global.language
    if _index == 0:
        device_label.text = Global.translations["setmc_keyboard"][lang]
        test_label.self_modulate.a = 1
    else:
        device_label.text = Global.translations["setmc_controller"][lang]
        test_label.self_modulate.a = 0.5

    for i in key_labels.size():
        key_labels[i].text = _get_formatted_key_event(_actions_to_remap[i])
        key_labels[i].set("theme_override_colors/font_color", custom_white)
    _manage_conflicts()


func _reset_to_default_bindings():
    _save_bindings()
    InputMap.load_from_project_settings()
    general_input_controller.disable_faulty_input()


    var data: Dictionary = save_load.get_loaded_settings()
    if data.has("controls"):
        var controls_dic: Dictionary = data["controls"]
        for i in _actions_to_remap.size():

            var events: = InputMap.action_get_events(_actions_to_remap[i])
            for event in events:
                if _index == 0:
                    if event is InputEventJoypadButton || event is InputEventJoypadMotion:
                        InputMap.action_erase_event(_actions_to_remap[i], event)
                else:
                    if event is InputEventKey:
                        InputMap.action_erase_event(_actions_to_remap[i], event)


            if controls_dic.has(_actions_to_remap[i]):
                for event in controls_dic[_actions_to_remap[i]]:
                    if _index == 0:
                        if event is InputEventJoypadButton || event is InputEventJoypadMotion:
                            InputMap.action_add_event(_actions_to_remap[i], event)
                    else:
                        if event is InputEventKey:
                            InputMap.action_add_event(_actions_to_remap[i], event)

    _update_mapping_labels()

    if _tween_color && _tween_color.is_running():
        _tween_color.custom_step(999)
    _tween_color = create_tween()
    _tween_color.set_parallel(true)
    for label in key_labels:
        label.modulate = Color.ORANGE
        _tween_color.tween_property(label, "modulate", custom_white, 0.5)


func _save_bindings():
    var dic: Dictionary

    for i in _actions_to_remap.size():
        dic[_actions_to_remap[i]] = InputMap.action_get_events(_actions_to_remap[i])

    save_load.save_settings("controls", dic)


    if _bindings_changed:
        save_load.save_settings("keyboard_test", true)


func cancel():
    ui_sounds.play_back()
    _save_bindings()
    menu_loader.controls_to_settings()

func play_selection():
    ui_sounds.play_selection()




func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_controls"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmc_left_chara"][lang]
    i += 1
    labels[i].text = Global.translations["setmc_right_chara"][lang]
    i += 1
    labels[i].text = Global.translations["setmc_general"][lang]
    i += 1
    labels[i].text = Global.translations["setmc_test"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmc_default"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()

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
    sublabels[i].text = Global.translations["setmc_reset"][lang]
    i += 1
    sublabels[i].text = Global.translations["setmc_pause"][lang]
