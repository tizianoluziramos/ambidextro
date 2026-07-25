extends SubViewportContainer

@export var save_load: Node
@export var camera: Camera2D
@export var subviewport: SubViewport
@export var CRT_shader: ColorRect
@export var level_loader: Node
@export var clickable_areas_container: Node

var timer: SceneTreeTimer
var timer2: SceneTreeTimer
var pixel_perfect: bool

var _initial_size_changes: bool = true

const ORIGINAL_RESOLUTION: Vector2 = Vector2(448, 256)

signal size_changed

func _ready():
    Global.subviewport_container = self
    get_viewport().size_changed.connect(on_size_changed)
    _manage_new_size()

    _apply_saved_resolution.call_deferred()
    await get_tree().create_timer(1).timeout
    _initial_size_changes = false


func on_size_changed():
    _manage_new_size()

    if timer:
        timer.timeout.disconnect(_save_resolution)
        timer.time_left = 0

    if _initial_size_changes:
        return

    timer = get_tree().create_timer(1)
    timer.timeout.connect(_save_resolution, 0)

    size_changed.emit.call_deferred()


func _manage_new_size():
    var resolution: Vector2 = get_viewport().get_size()

    var aspect: float = resolution.x / resolution.y
    var tall: bool


    if aspect < 1.777:
        tall = true
        var new_res: Vector2
        var base_resolution_x: float = resolution.x
        if base_resolution_x > 1280: base_resolution_x = 1280

        if pixel_perfect:
            var division: float = resolution.x / ORIGINAL_RESOLUTION.x
            var closest_scale: int = floori(division)
            if closest_scale < 1: closest_scale = 1

            camera.zoom = (Vector2.ONE * closest_scale)
        else:

            camera.zoom = (Vector2.ONE * (resolution.x / 448))

        if aspect < 1.3:
            var relative_axis_resolution: float = (resolution.x * (base_resolution_x / 1.3)) / base_resolution_x

            new_res = Vector2(resolution.x, relative_axis_resolution)
            subviewport.size = new_res
            size = new_res
            subviewport.size = new_res
            size = new_res

            position.y = (resolution.y - size.y) / 2
            position.x = 0
        else:
            subviewport.size = resolution
            size = resolution
            subviewport.size = resolution
            size = resolution

            position = Vector2.ZERO


    else:

        if pixel_perfect:
            var division: float = resolution.y / ORIGINAL_RESOLUTION.y
            var closest_scale: int = floori(division)
            if closest_scale < 1: closest_scale = 1

            camera.zoom = (Vector2.ONE * closest_scale)
        else:
            camera.zoom = (Vector2.ONE * (resolution.y / 256))
        position.y = 0

        if aspect > 2:
            var base_resolution_y: float = resolution.y
            if base_resolution_y > 720: base_resolution_y = 720

            var new_res: = Vector2(resolution.y * 2, resolution.y)

            subviewport.size = new_res
            size = new_res
            subviewport.size = new_res
            size = new_res

            position.x = (resolution.x - size.x) / 2


        else:
            subviewport.size = resolution
            size = resolution
            subviewport.size = resolution
            size = resolution

            position = Vector2.ZERO


    if pixel_perfect:
        var division: float

        if tall:
            division = resolution.x / ORIGINAL_RESOLUTION.x
        else:
            division = resolution.y / ORIGINAL_RESOLUTION.y
        var closest_scale: int = floori(division)
        if closest_scale < 1: closest_scale = 1

        subviewport.size.x = ORIGINAL_RESOLUTION.x * closest_scale
        size.x = subviewport.size.x
        position.x = (resolution.x - size.x) / 2

        subviewport.size.y = ORIGINAL_RESOLUTION.y * closest_scale
        size.y = subviewport.size.y
        position.y = (resolution.y - size.y) / 2


    if timer2:
        timer2.timeout.disconnect(_ensure_minimum_size)
        timer2.time_left = 0
    timer2 = get_tree().create_timer(0.1)
    timer2.timeout.connect(_ensure_minimum_size, 0)


    if CRT_shader:
        CRT_shader.set_deferred("size", size)
        CRT_shader.position = position
        CRT_shader.change_resolution(Vector2(448, 256))


    if Global.mobile && level_loader.is_playing():
        adapt_level_screen_for_mobile()


    camera.offset = Vector2(0, 0)


func _save_resolution():
    var data: Dictionary = save_load.get_loaded_settings()
    var dic: Dictionary
    dic = data["video"]

    if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN:
        dic["fullscreen"] = true
        dic["window_resolution"] = data["video"]["window_resolution"]
    else:
        dic["fullscreen"] = false
        dic["window_resolution"] = DisplayServer.window_get_size(0)

    save_load.save_settings("video", dic)


func _ensure_minimum_size():
    var resolution: Vector2 = get_viewport().get_size()
    var new_resolution: Vector2i = resolution
    if resolution.x < ORIGINAL_RESOLUTION.x:
        new_resolution.x = int(ORIGINAL_RESOLUTION.x)
    if resolution.y < ORIGINAL_RESOLUTION.y:
        new_resolution.y = int(ORIGINAL_RESOLUTION.y)
    DisplayServer.window_set_size(new_resolution, 0)


func _apply_saved_resolution():
    var data: Dictionary = save_load.get_loaded_settings()

    if !data.has("video"):
        save_load.create_default_data()
        _apply_saved_resolution.call_deferred()
        return



    if data["video"]["fullscreen"] == true:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(data["video"]["window_resolution"], 0)

    set_pixel_perfect(data["video"]["pixel_perfect"])

    CRT_shader.set_curvature(data["video"].get("shader_curvature", true))
    CRT_shader.set_scanlines(data["video"].get("shader_scanlines", true))
    CRT_shader.set_distortion(data["video"].get("shader_distortion", true))
    CRT_shader.set_aberration(data["video"].get("shader_aberration", true))

    await get_tree().create_timer(1).timeout
    _check_fullscreen_mode_has_been_applied()


func _check_fullscreen_mode_has_been_applied():
    var data: Dictionary = save_load.get_loaded_settings()
    if data["video"]["fullscreen"] == true && DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    elif data["video"]["fullscreen"] == false && DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(data["video"]["window_resolution"], 0)


func set_pixel_perfect(value: bool):
    pixel_perfect = value
    _manage_new_size()


func adapt_level_screen_for_mobile():
    var resolution: Vector2 = get_viewport().get_size()
    var aspect: float = resolution.x / resolution.y

    if aspect < 1.4:

        camera.zoom = (Vector2.ONE * (resolution.x / 448))
        camera.position.y = 30
    else:

        camera.zoom = (Vector2.ONE * (resolution.y / 256 * 0.8))
        camera.position.y = 30

    if !level_loader.is_playing():
        camera.position.y = 0
