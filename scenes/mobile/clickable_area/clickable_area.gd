extends TextureButton

enum Action{Accept, Decrease, Increase}

@export var action: Action
@export var color_rect: ColorRect
@export var options: Node
@export var marker2D: Node
@export var autoinitilize: bool = true
var _disable_color: bool = true

var _index: int
var _parent: Node
var _original_position: Vector2
var _original_size: Vector2

func _ready() -> void :
    if !Global.mobile:
        color_rect.visible = false
        queue_free()
        return

    if !_disable_color: color_rect.visible = true

    if autoinitilize:
        initialize.call_deferred()


func initialize():
    enable()

    _parent = get_parent()

    global_position = _parent.global_position + _parent.size / 2.0
    global_position.x -= size.x / 2.0
    global_position.y -= size.y / 2.0

    _original_position = global_position
    _original_size = size
    reparent(Global.subviewport_container.clickable_areas_container)
    reposition.call_deferred()
    Global.subviewport_container.size_changed.connect(reposition)

    for i in options.options.size():
        if marker2D:
            if options.options[i] == marker2D:
                _index = i
        else:
            if options.options[i] == _parent:
                _index = i


func reposition():
    size = _original_size * Global.subviewport_container.camera.zoom
    color_rect.size = size
    global_position = (_original_position * Global.subviewport_container.camera.zoom) + (get_viewport().get_size() as Vector2 / 2.0)


func _on_pressed() -> void :
    match action:
        Action.Accept:
            options.accept_from_click(_index)
        Action.Decrease:
            options.decrease_from_click(_index)
        Action.Increase:
            options.increase_from_click(_index)


func enable():
    mouse_filter = MouseFilter.MOUSE_FILTER_STOP


func disable():
    mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
