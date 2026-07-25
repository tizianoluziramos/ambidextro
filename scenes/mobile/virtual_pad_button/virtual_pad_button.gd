extends TextureButton

@export var color_rect: ColorRect
var _actions: Array[String]
var _release_actions: Array[String]


func set_actions(actions: Array[String], release_actions: Array[String]):
    _actions = actions
    _release_actions = release_actions


func press() -> void :
    for action in _actions:
        Input.action_press(action)
    for release_action in _release_actions:
        Input.action_release(release_action)
    color_rect.color = Color.RED
    color_rect.color.a = 0.4


func release() -> void :
    color_rect.color = Color.WHITE
    color_rect.color.a = 0.4
