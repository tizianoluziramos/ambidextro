class_name box
extends CharacterBody2D

@export var audio: AudioStreamPlayer2D
@export var audio_hit: AudioStreamPlayer2D
@export var box_sprite: Sprite2D
@export var top_sprite: Sprite2D
@export var sprites_forest: Array[Texture2D]
@export var forest: bool

var _jump_height: float = 120
var _jump_time_to_descent: float = 0.25
var _frames_to_stop_audio: int = 3
var _last_floor_y: float = 999

var _fall_gravity: float = ((-2.0 * _jump_height) / (_jump_time_to_descent * _jump_time_to_descent)) * -1.0

var saved_velocity: Vector2


func _ready():
    if forest:
        box_sprite.texture = sprites_forest[0]
        top_sprite.texture = sprites_forest[1]


func _physics_process(delta: float) -> void :
    if !is_on_floor():
        if _last_floor_y == 999:
            _last_floor_y = position.y
        velocity.y += _fall_gravity * delta
    elif position.y > _last_floor_y + 10:
        _last_floor_y = 999
        audio_hit.play()

    if saved_velocity.x == 0 && _frames_to_stop_audio > 0:
        _frames_to_stop_audio -= 1

    if _frames_to_stop_audio == 0:
        _frames_to_stop_audio -= 1
        audio.stop()

    velocity.x = saved_velocity.x
    move_and_slide()
    saved_velocity = Vector2.ZERO


func move(vel: Vector2):
    saved_velocity = vel / 1.75

    _frames_to_stop_audio = 3
    if velocity.x == 0:
        audio.stop()
    elif !audio.playing:
        audio.play()
