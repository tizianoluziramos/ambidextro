extends Node2D

@export var sprite: Sprite2D
@export var marker: Marker2D


func _ready() -> void :
    if rotation_degrees >= 170 || rotation_degrees <= -170:
        sprite.flip_v = true


func get_pos():
    return marker.global_position
