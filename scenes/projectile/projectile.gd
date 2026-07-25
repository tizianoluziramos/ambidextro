extends Node2D

@export var animation: AnimatedSprite2D
@export var audio: AudioStreamPlayer2D
@export var collision: CollisionShape2D
@export var sprite: AnimatedSprite2D

var mute: bool

func _ready() -> void :
    if global_rotation_degrees != 0: animation.flip_v = true


func set_projectile(origin_position: Vector2, target_position: Vector2, speed: float):
    var _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(self, "global_position", target_position, origin_position.distance_to(target_position) / speed).from(origin_position)
    _tween.finished.connect(_play_off, 4)

    animation.play("default")


func _play_off():
    collision.disabled = true
    sprite.visible = false

    if mute:
        queue_free()
        return

    audio.pitch_scale = randf_range(0.9, 1.1)
    audio.play()
    audio.finished.connect(queue_free, 4)
