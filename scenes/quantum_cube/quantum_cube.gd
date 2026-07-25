@tool
extends Node2D


@export var cube: bool = false:
    set(value):
        cube = value
        set_cube()


@export var start_active: bool = true:
    set(value):
        start_active = value
        if value:
            enable()
        else:
            disable()

@export var collision: CollisionShape2D
@export var sprite: Sprite2D
@export var collision_cube: CollisionShape2D
@export var sprite_cube: Sprite2D


func disable():
    collision.disabled = true
    sprite.visible = false
    collision_cube.disabled = true
    sprite_cube.visible = false


func enable():
    if cube:
        collision_cube.disabled = false
        sprite_cube.visible = true
    else:
        collision.disabled = false
        sprite.visible = true


func set_cube():
    if start_active:
        disable()
        enable()
