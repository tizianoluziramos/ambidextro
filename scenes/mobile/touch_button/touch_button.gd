extends Control

enum Placement{Down, Corner}

@export var action: String
@export var button: TextureButton
@export var texture_normal: Texture2D
@export var texture_pressed: Texture2D
@export var placement: Placement
@export var subviewport_container: SubViewportContainer

var _enabled: bool


func _ready() -> void :
    if !Global.mobile:
        queue_free()

    button.texture_normal = texture_normal
    button.texture_pressed = texture_pressed

    subviewport_container.size_changed.connect(_resize)
    await get_tree().create_timer(0.5).timeout
    _resize.call_deferred()

    disable()


func _on_button_button_down() -> void :
    Input.action_press(action)
    Input.action_release(action)


func _resize():
    var resolution: Vector2 = get_viewport().get_size()

    match placement:
        Placement.Down:
            var scale: float = resolution.y / (2880.0 / 1.4)
            button.scale = Vector2(scale, scale)
            global_position = Vector2(resolution.x / 2 - (button.size.x * button.scale.x) / 2.0, resolution.y - (button.size.y * button.scale.y) - 20)
        Placement.Corner:
            var scale: float = resolution.y / (2880.0)
            button.scale = Vector2(scale, scale)
            global_position = Vector2(resolution.x - (button.size.x * button.scale.x) - 20, 20)


func disable():
    _enabled = false
    button.visible = false


func enable():
    _enabled = true
    button.visible = true
