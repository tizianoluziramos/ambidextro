extends SubViewportContainer

@export var camera_collision_v: Node
@export var camera_collision_v2: Node
@export var camera_collision_h: Node
@export var scrolling_camera: Camera2D
@export var right: bool


func _ready():
    get_viewport().size_changed.connect(_on_size_changed)
    _on_size_changed()


func _on_size_changed():
    var resolution: Vector2 = get_viewport().get_size()

    var aspect: float = resolution.x / resolution.y

    var size_x: float = (aspect * 260) / 2

    size_x = clamp(size_x, 230, 260)

    var size_r: int
    var size_l: int
    size_r = floor(size_x)
    size_l = ceil(size_x)

    if size_r % 2 != 0:
        size_r += 1
    if size_l % 2 != 0:
        size_l += 1

    if right:
        size_x = size_r
    else:
        size_x = size_l


    size.x = size_x


    if !right:
        position.x = - size.x








    var aspect_clamp: float = clamp(aspect, 1.3, 1.777)
    camera_collision_v.position.y = 200 - (90.147 * (aspect_clamp - 1.3))
    camera_collision_v2.position.y = (camera_collision_v.position.y * -1) - 32





    aspect_clamp = clamp(aspect, 1.777, 2)
    var pos: float = 140 + (71.749 * (aspect_clamp - 1.777))
    if !right: pos *= -1
    camera_collision_h.position.x = pos

    var extra_size: float = size_x - 230
    var extra_wide: float
    if extra_size > 0:
        extra_wide = (size_x - 230) / 2

    var extra_wide_i: int
    if right:
        extra_wide_i = floori(extra_wide)
    else:
        extra_wide_i = ceili(extra_wide)
        extra_wide_i *= -1

    scrolling_camera.update_offset(extra_wide_i)
