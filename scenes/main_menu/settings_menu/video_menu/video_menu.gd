extends Node2D


@export var options: Node
@export var label_values: Array[Label]
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var save_load: Node
var crt_shader: Node
var subviewport_container: Node


var data: Dictionary
var fullscreen: bool
var pixel_perfect: bool
var curvature: bool
var scanlines: bool
var distortion: bool
var aberration: bool

var _size_changing_on_apply: bool


func _ready() -> void :
    _translate()
    get_viewport().size_changed.connect(_on_size_changed)
    _initialize.call_deferred()


func _initialize():
    data = save_load.get_loaded_settings()

    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        fullscreen = true
    else:
        fullscreen = false

    pixel_perfect = data["video"]["pixel_perfect"]
    curvature = data["video"].get("shader_curvature", true)
    scanlines = data["video"].get("shader_scanlines", true)
    distortion = data["video"].get("shader_distortion", true)
    aberration = data["video"].get("shader_aberration", true)
    _update_labels()



func _on_size_changed():
    if _size_changing_on_apply:
        return
    if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
        fullscreen = true
    else:
        fullscreen = false
    _update_labels()


func _update_labels():
    var lang: String = Global.language
    var yes: String = Global.translations["yes"][lang]
    var no: String = Global.translations["no"][lang]

    if fullscreen:
        label_values[0].text = yes
    else:
        label_values[0].text = no

    if pixel_perfect:
        label_values[1].text = yes
    else:
        label_values[1].text = no

    if curvature:
        label_values[2].text = yes
    else:
        label_values[2].text = no

    if scanlines:
        label_values[3].text = yes
    else:
        label_values[3].text = no

    if distortion:
        label_values[4].text = yes
    else:
        label_values[4].text = no

    if aberration:
        label_values[5].text = yes
    else:
        label_values[5].text = no


func accept_option(option: String, option_index: int):
    match option:
        "marker2d":
            options.select_option(2)
            ui_sounds.play_accept()
        "marker2d2":
            options.select_option(7)
            ui_sounds.play_accept()
        "apply":
            ui_sounds.play_accept()
            _apply_settings()
        "back":
            _save_settings()
            ui_sounds.play_back()
            menu_loader.video_to_settings()


func increase(option: String, option_index: int):
    match option:
        "marker2d", "marker2d2":
            ui_sounds.play_lateral()
            match option_index:
                0:
                    fullscreen = !fullscreen
                    _update_labels()
                1:
                    pixel_perfect = !pixel_perfect
                    _update_labels()
                3:
                    curvature = !curvature
                    _update_labels()
                    _apply_curvature()
                4:
                    scanlines = !scanlines
                    _update_labels()
                    _apply_scanlines()
                5:
                    distortion = !distortion
                    _update_labels()
                    _apply_distortion()
                6:
                    aberration = !aberration
                    _update_labels()
                    _apply_aberration()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    increase(option, option_index)


func cancel():
    _save_settings()
    ui_sounds.play_back()
    menu_loader.video_to_settings()


func play_selection():
    ui_sounds.play_selection()


func _apply_settings():
    _size_changing_on_apply = true

    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
        DisplayServer.window_set_size(data["video"]["window_resolution"])

    subviewport_container.set_pixel_perfect(pixel_perfect)

    var dic: Dictionary
    dic = data["video"]
    dic["fullscreen"] = fullscreen
    dic["pixel_perfect"] = pixel_perfect
    save_load.save_settings("video", dic)
    data = save_load.get_loaded_settings()

    subviewport_container.on_size_changed()


    await get_tree().create_timer(0.2).timeout
    _size_changing_on_apply = false
    Input.action_release("ui_accept")


func _save_settings():
    var dic: Dictionary
    dic = data["video"]
    dic["shader_curvature"] = curvature
    dic["shader_scanlines"] = scanlines
    dic["shader_distortion"] = distortion
    dic["shader_aberration"] = aberration
    save_load.save_settings("video", dic)
    data = save_load.get_loaded_settings()



func _apply_curvature():
    crt_shader.set_curvature(curvature)


func _apply_scanlines():
    crt_shader.set_scanlines(scanlines)


func _apply_distortion():
    crt_shader.set_distortion(distortion)


func _apply_aberration():
    crt_shader.set_aberration(aberration)


func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_video"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_fullscreen"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_pixel_perfect"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_curvature"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_scanlines"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_distortion"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_aberration"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setmv_apply"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
