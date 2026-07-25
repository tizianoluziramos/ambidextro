extends Node2D


@export var tutorial_keys: Array[Node]
@export var input_lrm: Array[Node]
@export var controller_lrm: Array[Node]
@export var keys: Node
@export var tile_map_blocking_reset: Node
@export var input_names: Node



var general_input_controller: Node

var device: int = -1
var _actions: Array[String] = ["left_l", "up_l", "right_l", "left_r", "up_r", "right_r", "reset"]
var _default_controller_english_names: Array[String] = ["LS Left", "LB", "LS Right", "RS Left", "RB", "RS Right", "Back"]


func _process(delta: float) -> void :
    if device > -1 && device != general_input_controller.last_action_device:
        set_keys()


func set_keys():

    device = general_input_controller.last_action_device

    if device == 2:
        keys.visible = false
        return

    var original_key: Array[bool]
    original_key.resize(7)
    for i in tutorial_keys.size():
        if device == 0:
            var events: = InputMap.action_get_events(_actions[i])
            for event in events:
                if event is InputEventKey:
                    tutorial_keys[i].set_key(input_names.get_label_for_input(event), input_names.get_english_label_for_input(event))
                    break
        else:
            var events: = InputMap.action_get_events(_actions[i])

            for event in events:
                match i:
                    0, 2, 3, 5:
                        if event is InputEventJoypadMotion:
                            if input_names.get_english_label_for_input(event) == _default_controller_english_names[i]:
                                original_key[i] = true
                                break
                    1, 4, 6:
                        if event is InputEventJoypadButton:
                            if input_names.get_english_label_for_input(event) == _default_controller_english_names[i]:
                                original_key[i] = true
                                break

    input_lrm[0].visible = true
    input_lrm[1].visible = true
    input_lrm[2].visible = true
    controller_lrm[0].visible = false
    controller_lrm[1].visible = false
    controller_lrm[2].visible = false

    if device == 1:
        if original_key[0] && original_key[1] && original_key[2]:
            input_lrm[0].visible = false
            controller_lrm[0].visible = true
        else:
            for i in [0, 1, 2]:
                var events: = InputMap.action_get_events(_actions[i])
                for event in events:
                    if event is InputEventJoypadButton || event is InputEventJoypadMotion:
                        tutorial_keys[i].set_key(input_names.get_label_for_input(event), input_names.get_english_label_for_input(event))
                        break

        if original_key[3] && original_key[4] && original_key[5]:
            input_lrm[1].visible = false
            controller_lrm[1].visible = true
        else:
            for i in [3, 4, 5]:
                var events: = InputMap.action_get_events(_actions[i])
                for event in events:
                    if event is InputEventJoypadButton || event is InputEventJoypadMotion:
                        tutorial_keys[i].set_key(input_names.get_label_for_input(event), input_names.get_english_label_for_input(event))
                        break

        if original_key[6]:
            input_lrm[2].visible = false
            controller_lrm[2].visible = true
        else:
            var events: = InputMap.action_get_events(_actions[6])
            for event in events:
                if event is InputEventJoypadButton || event is InputEventJoypadMotion:
                    tutorial_keys[6].set_key(input_names.get_label_for_input(event), input_names.get_english_label_for_input(event))
                    break


    keys.visible = true


func mirror_tutorial():
    keys.scale.x = -1


func swap_tutorial():
    var pos: Vector2 = input_lrm[0].position
    input_lrm[0].position = input_lrm[1].position
    input_lrm[1].position = pos
