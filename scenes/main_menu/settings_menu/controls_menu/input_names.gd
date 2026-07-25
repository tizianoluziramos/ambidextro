extends Node


const DEVICE_KEYBOARD = "keyboard"
const DEVICE_XBOX_CONTROLLER = "xbox"
const DEVICE_SWITCH_CONTROLLER = "switch"
const DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER = "switch_left_joycon"
const DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER = "switch_right_joycon"
const DEVICE_PLAYSTATION_CONTROLLER = "playstation"
const DEVICE_GENERIC = "generic"

var XBOX_BUTTON_LABELS = ["A", "B", "X", "Y", "Back", "Home", "Menu", "LS", "RS", "LB", "RB", "Up", "Down", "Left", "Right", "Share"]
var SWITCH_BUTTON_LABELS = ["B", "A", "Y", "X", "-", "", "+", "LS", "RS", "L", "R", "Up", "Down", "Left", "Right", "Capture"]
var PLAYSTATION_BUTTON_LABELS = ["Cross", "Circle", "Square", "Triangle", "Select", "PS", "Options", "L3", "R3", "L1", "R1", "Up", "Down", "Left", "Right", "Microphone"]


func _ready():
    var lang: String = Global.language
    XBOX_BUTTON_LABELS = ["A", "B", "X", "Y", "Back", "Home", "Menu", "LS", "RS", "LB", "RB", Global.translations["setmc_up"][lang], Global.translations["setmc_down"][lang], Global.translations["setmc_left"][lang], Global.translations["setmc_right"][lang], "Share"]
    SWITCH_BUTTON_LABELS = ["B", "A", "Y", "X", "-", "", "+", "LS", "RS", "L", "R", Global.translations["setmc_up"][lang], Global.translations["setmc_down"][lang], Global.translations["setmc_left"][lang], Global.translations["setmc_right"][lang], "Capture"]
    PLAYSTATION_BUTTON_LABELS = ["Cross", "Circle", "Square", "Triangle", "Select", "PS", "Options", "L3", "R3", "L1", "R1", Global.translations["setmc_up"][lang], Global.translations["setmc_down"][lang], Global.translations["setmc_left"][lang], Global.translations["setmc_right"][lang], "Microphone"]


func _get_simplified_device_name(raw_name: String) -> String:
    match raw_name:
        "XInput Gamepad", "Xbox Series Controller", "Xbox 360 Controller", \
"Xbox One Controller":
            return DEVICE_XBOX_CONTROLLER

        "Sony DualSense", "PS5 Controller", "PS4 Controller", \
"Nacon Revolution Unlimited Pro Controller":
            return DEVICE_PLAYSTATION_CONTROLLER

        "Switch":
            return DEVICE_SWITCH_CONTROLLER
        "Joy-Con (L)":
            return DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER
        "Joy-Con (R)":
            return DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER

        _:
            return DEVICE_GENERIC


func get_label_for_input(input: InputEvent) -> String:
    var string: String = _get_label_for_input(input)
    if input.device > 0:
        string += " [" + str(input.device + 1) + "]"
    return string


func _get_label_for_input(input: InputEvent) -> String:
    if input == null: return ""
    var lang: String = Global.language

    var device: String = _get_simplified_device_name(Input.get_joy_name(input.device))

    if input is InputEventKey:
        if input.physical_keycode > 0:
            var keycode: = DisplayServer.keyboard_get_keycode_from_physical(input.physical_keycode)
            return OS.get_keycode_string(keycode)
        elif input.keycode > 0:
            return OS.get_keycode_string(input.keycode)
        else:
            return input.as_text()

    elif input is InputEventMouseButton:
        match input.button_index:
            MOUSE_BUTTON_LEFT:
                return "Mouse LB"
            MOUSE_BUTTON_MIDDLE:
                return "Mouse MB"
            MOUSE_BUTTON_RIGHT:
                return "Mouse RB"
        return "Mouse %d" % input

    elif input is InputEventJoypadButton:
        match device:
            DEVICE_XBOX_CONTROLLER, DEVICE_GENERIC:
                return "%s" % XBOX_BUTTON_LABELS[input.button_index]
            DEVICE_SWITCH_CONTROLLER, DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER, DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER:
                return "%s" % SWITCH_BUTTON_LABELS[input.button_index]
            DEVICE_PLAYSTATION_CONTROLLER:
                return "%s" % PLAYSTATION_BUTTON_LABELS[input.button_index]
    elif input is InputEventJoypadMotion:
        var motion: InputEventJoypadMotion = input as InputEventJoypadMotion
        match motion.axis:
            JOY_AXIS_LEFT_X:
                return "LS %s" % (Global.translations["setmc_left"][lang] if motion.axis_value < 0 else Global.translations["setmc_right"][lang])
            JOY_AXIS_LEFT_Y:
                return "LS %s" % (Global.translations["setmc_up"][lang] if motion.axis_value < 0 else Global.translations["setmc_down"][lang])
            JOY_AXIS_RIGHT_X:
                return "RS %s" % (Global.translations["setmc_left"][lang] if motion.axis_value < 0 else Global.translations["setmc_right"][lang])
            JOY_AXIS_RIGHT_Y:
                return "RS %s" % (Global.translations["setmc_up"][lang] if motion.axis_value < 0 else Global.translations["setmc_down"][lang])
            JOY_AXIS_TRIGGER_LEFT:
                return "LT"
            JOY_AXIS_TRIGGER_RIGHT:
                return "RT"
    return input.as_text()



func get_english_label_for_input(input: InputEvent) -> String:
    if input == null: return ""
    var lang: String = "en"

    var device: String = _get_simplified_device_name(Input.get_joy_name(input.device))

    if input is InputEventKey:
        if input.physical_keycode > 0:
            var keycode: = DisplayServer.keyboard_get_keycode_from_physical(input.physical_keycode)
            return OS.get_keycode_string(keycode)
        elif input.keycode > 0:
            return OS.get_keycode_string(input.keycode)
        else:
            return input.as_text()

    elif input is InputEventMouseButton:
        match input.button_index:
            MOUSE_BUTTON_LEFT:
                return "Mouse LB"
            MOUSE_BUTTON_MIDDLE:
                return "Mouse MB"
            MOUSE_BUTTON_RIGHT:
                return "Mouse RB"
        return "Mouse %d" % input

    elif input is InputEventJoypadButton:
        match device:
            DEVICE_XBOX_CONTROLLER, DEVICE_GENERIC:
                return "%s" % XBOX_BUTTON_LABELS[input.button_index]
            DEVICE_SWITCH_CONTROLLER, DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER, DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER:
                return "%s" % SWITCH_BUTTON_LABELS[input.button_index]
            DEVICE_PLAYSTATION_CONTROLLER:
                return "%s" % PLAYSTATION_BUTTON_LABELS[input.button_index]
    elif input is InputEventJoypadMotion:
        var motion: InputEventJoypadMotion = input as InputEventJoypadMotion
        match motion.axis:
            JOY_AXIS_LEFT_X:
                return "LS %s" % (Global.translations["setmc_left"][lang] if motion.axis_value < 0 else Global.translations["setmc_right"][lang])
            JOY_AXIS_LEFT_Y:
                return "LS %s" % (Global.translations["setmc_up"][lang] if motion.axis_value < 0 else Global.translations["setmc_down"][lang])
            JOY_AXIS_RIGHT_X:
                return "RS %s" % (Global.translations["setmc_left"][lang] if motion.axis_value < 0 else Global.translations["setmc_right"][lang])
            JOY_AXIS_RIGHT_Y:
                return "RS %s" % (Global.translations["setmc_up"][lang] if motion.axis_value < 0 else Global.translations["setmc_down"][lang])
            JOY_AXIS_TRIGGER_LEFT:
                return "LT"
            JOY_AXIS_TRIGGER_RIGHT:
                return "RT"
    return input.as_text()
