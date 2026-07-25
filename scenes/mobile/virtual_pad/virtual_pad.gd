extends Control

@export var action_left: = "ui_left"
@export var action_right: = "ui_right"
@export var action_up: = "ui_up"
@export var buttons: Array[Node]
@export var grid: Node
@export var subviewport_container: SubViewportContainer


var _touch_index: int = -1


func _ready() -> void :
    queue_free()
    if !Global.mobile:
        queue_free()
        return

    _initialize()


func _initialize():
    visible = true
    buttons[0].set_actions([action_up, action_left] as Array[String], [action_up] as Array[String])
    buttons[1].set_actions([action_up] as Array[String], [action_left, action_right] as Array[String])
    buttons[2].set_actions([action_up, action_right] as Array[String], [action_left] as Array[String])
    buttons[3].set_actions([action_left] as Array[String], [action_up, action_right] as Array[String])
    buttons[5].set_actions([action_right] as Array[String], [action_up, action_left] as Array[String])

    subviewport_container.size_changed.connect(_resize)
    await get_tree().create_timer(0.5).timeout
    _resize.call_deferred()


func _input(event: InputEvent) -> void :
    if event is InputEventScreenTouch:
        if event.pressed:
            if _is_point_inside_node_area(event.position, grid) and _touch_index == -1:
                _touch_index = event.index
                _press_touched_area(event.position)
                get_viewport().set_input_as_handled()
        elif event.index == _touch_index:
            _reset()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag:
        if event.index == _touch_index:
            _press_touched_area(event.position)
            get_viewport().set_input_as_handled()


func _is_point_inside_node_area(point: Vector2, node: Node) -> bool:
    var x: bool = point.x >= node.global_position.x and point.x <= node.global_position.x + (node.size.x * get_global_transform_with_canvas().get_scale().x)
    var y: bool = point.y >= node.global_position.y and point.y <= node.global_position.y + (node.size.y * get_global_transform_with_canvas().get_scale().y)
    return x and y


func _press_touched_area(point: Vector2):
    for button in buttons:
        if _is_point_inside_node_area(point, button):
            button.press()
        else:
            button.release()


func _reset():
    _touch_index = -1
    for button in buttons:
        button.release()
    Input.action_release(action_up)
    Input.action_release(action_left)
    Input.action_release(action_right)


func _resize():
    var svc_resolution: Vector2 = subviewport_container.size
    var scale_factor: float = (svc_resolution.y / 256.0) * 1.5
    scale = Vector2.ONE * scale_factor

    var resolution: Vector2 = get_viewport().get_size()
    if position.x < resolution.x / 2:
        position.x = get_child(0).size.x / 2.0 * scale.x
    else:
        position.x = resolution.x - get_child(0).size.x / 2.0 * scale.x
