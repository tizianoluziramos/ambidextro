extends Node2D
class_name LariatFireball


@export var sprite: Sprite2D
@export var collision: CollisionShape2D
@export var audio_shoot: AudioStreamPlayer2D
@export var audio_hit: AudioStreamPlayer2D


func set_projectile(origin_position: Vector2, target_position: Vector2, speed: float):
    var _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    var destiny: Vector2 = origin_position + (target_position - origin_position).normalized() * 300

    _tween.tween_property(self, "global_position", destiny, 3).from(origin_position)
    _tween.finished.connect(queue_free)

    audio_shoot.pitch_scale = randf_range(0.9, 1.1)
    audio_shoot.play()


func destroy():
    disable_collider.call_deferred()
    sprite.visible = false

    audio_hit.pitch_scale = randf_range(0.9, 1.1)
    audio_hit.play()
    audio_hit.finished.connect(queue_free, 4)


func disable_collider():
    collision.disabled = true
