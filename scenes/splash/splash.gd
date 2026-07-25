extends Node2D


@export var menu_loader: Node
@export var logo: Sprite2D

var _tween: Tween

func _ready() -> void :
    _tween = create_tween()
    _tween.tween_property(logo, "modulate", Color.TRANSPARENT, 0.25)
    _tween.finished.connect(_on_wait1_finished, 4)


func _on_wait1_finished():
    _tween = create_tween()
    _tween.tween_property(logo, "modulate", Color.WHITE, 0.5)
    _tween.finished.connect(_on_fadein_finished, 4)


func _on_fadein_finished():
    _tween = create_tween()
    _tween.tween_property(logo, "modulate", Color.WHITE, 0.25)
    _tween.finished.connect(_on_wait2_finished, 4)


func _on_wait2_finished():
    _tween = create_tween()
    _tween.tween_property(logo, "modulate", Color.TRANSPARENT, 0.5)
    _tween.finished.connect(_on_fadeout_finished, 4)


func _on_fadeout_finished():
    _tween = create_tween()
    _tween.tween_property(logo, "modulate", Color.TRANSPARENT, 0.25)
    _tween.finished.connect(_on_wait3_finished, 4)


func _on_wait3_finished():
    menu_loader.load_main_menu()
    queue_free()
