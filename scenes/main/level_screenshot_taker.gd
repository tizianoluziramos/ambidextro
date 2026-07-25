extends Node

@export var menu_loader: Node
@export var level_loader: Node
@export var crt_shader: Node

var _take_screenshots_called: bool
var wait_time: float = 0.5








func _process(_delta):
    if !_take_screenshots_called:
        _take_screenshots_called = true
        _take_screenshots()


func _take_screenshots():
    await get_tree().create_timer(3).timeout
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
    DisplayServer.window_set_size(Vector2(448, 256), 0)
    crt_shader.set_curvature(false)
    crt_shader.set_scanlines(false)
    crt_shader.set_distortion(false)
    crt_shader.set_aberration(false)
    AudioServer.set_bus_volume_db(0, linear_to_db(0))
    await get_tree().create_timer(0.5).timeout
    menu_loader.manage_load_level(0, 0, 0, 0)
    await get_tree().create_timer(0.5).timeout
    for i in 102:
        if i < 101: continue
        level_loader.unload_level()
        level_loader.load_single_level_options(i, 0, 0, 0)
        level_loader.load_level()
        await get_tree().create_timer(wait_time).timeout
        var image = get_viewport().get_texture().get_image()
        image.save_png("res://assets/level_previews/" + "level" + str(i) + ".png")

    for i in 102:
        if i < 101: continue
        level_loader.unload_level()
        level_loader.load_single_level_options(i, 0, 1, 0)
        level_loader.load_level()
        await get_tree().create_timer(wait_time).timeout
        var image = get_viewport().get_texture().get_image()
        image.save_png("res://assets/level_previews/" + "level" + str(i) + "_mirror.png")

    for i in 102:
        if i < 101: continue
        level_loader.unload_level()
        level_loader.load_single_level_options(i, 0, 0, 1)
        level_loader.load_level()
        await get_tree().create_timer(wait_time).timeout
        var image = get_viewport().get_texture().get_image()
        image.save_png("res://assets/level_previews/" + "level" + str(i) + "_swap.png")

    for i in 102:
        if i < 101: continue
        level_loader.unload_level()
        level_loader.load_single_level_options(i, 0, 1, 1)
        level_loader.load_level()
        await get_tree().create_timer(wait_time).timeout
        var image = get_viewport().get_texture().get_image()
        image.save_png("res://assets/level_previews/" + "level" + str(i) + "_mirror_swap.png")
