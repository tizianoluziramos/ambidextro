extends ColorRect

var _original_aberration: float
var _original_roll_speed: float
var _original_roll_size: float
var _original_roll_intensity: float
var _tween: Tween


var _aberration: bool = true
var _scanlines: bool = true
var _distortion: bool = true
var _curvature: bool = true

func _ready():
    _original_aberration = material.get_shader_parameter("aberration")
    _original_roll_speed = material.get_shader_parameter("roll_speed")
    _original_roll_size = material.get_shader_parameter("roll_size")
    _original_roll_intensity = material.get_shader_parameter("distort_intensity")


func change_resolution(resolution: Vector2):
    material.set_shader_parameter("resolution", resolution)

    _update_warp_scale.call_deferred()


func _update_warp_scale():
    var window_resolution: Vector2 = DisplayServer.window_get_size(0)
    var warp_scale: Vector2 = window_resolution / size
    material.set_shader_parameter("warp_scale", warp_scale)


func death_distortion():
    if !_aberration && !_distortion: return

    var time: float = 0.2
    var max_aberration: float = 0.02
    var max_roll_speed: float = 4.5
    var max_roll_intensity: float = 0.02
    if _tween:
        _tween.stop()
        if _aberration:
            material.set_shader_parameter("aberration", _original_aberration)
    _tween = create_tween()
    _tween.set_parallel(true)
    if _aberration:
        _tween.tween_method(_tween_aberration, _original_aberration, max_aberration, time)
    if _distortion:
        _tween.tween_method(_tween_roll_speed, _original_roll_speed, max_roll_speed, time)
        _tween.tween_method(_tween_roll_intensity, _original_roll_intensity, max_roll_intensity, time)
    _tween.set_parallel(false)
    if _aberration:
        _tween.tween_method(_tween_aberration, max_aberration, _original_aberration, time)
    _tween.set_parallel(true)
    if _distortion:
        _tween.tween_method(_tween_roll_speed, max_roll_speed, _original_roll_speed, time)
        _tween.tween_method(_tween_roll_intensity, max_roll_intensity, _original_roll_intensity, time)


func _tween_aberration(value: float):
    material.set_shader_parameter("aberration", value)


func _tween_roll_speed(value: float):
    material.set_shader_parameter("roll_speed", value)


func _tween_roll_intensity(value: float):
    material.set_shader_parameter("distort_intensity", value)


func set_curvature(state: bool):
    _curvature = state
    if state:
        material.set_shader_parameter("warp_amount", 0.3)
        material.set_shader_parameter("vignette_intensity", 0.3)
    else:
        material.set_shader_parameter("warp_amount", 0.0)
        material.set_shader_parameter("vignette_intensity", 0)


func set_scanlines(state: bool):
    _scanlines = state
    if state:
        material.set_shader_parameter("scanlines_opacity", 0.25)
        material.set_shader_parameter("brightness", 1.25)
    else:
        material.set_shader_parameter("scanlines_opacity", 0.0)
        material.set_shader_parameter("brightness", 0.95)


func set_distortion(state: bool):
    _distortion = state
    if state:
        material.set_shader_parameter("noise_opacity", 0.12)
        material.set_shader_parameter("distort_intensity", 0.002)
        material.set_shader_parameter("roll", true)
    else:
        material.set_shader_parameter("noise_opacity", 0.0)
        material.set_shader_parameter("distort_intensity", 0.0)
        material.set_shader_parameter("roll", false)


func set_aberration(state: bool):
    _aberration = state
    if state:
        material.set_shader_parameter("aberration", 0.005)
    else:
        material.set_shader_parameter("aberration", 0.0)


func set_offset_y(offset: float):
    material.set_shader_parameter("offset_y", offset)
