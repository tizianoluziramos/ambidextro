extends Node2D


@export var top: AnimatableBody2D
@export var audio_tick: AudioStreamPlayer2D
@export var audio_boing: AudioStreamPlayer2D
@export var base_sprite: Sprite2D
@export var top_sprite: Sprite2D
@export var sprites_forest: Array[Texture]
@export var tick_forest_sound: AudioStream
@export var boing_forest_sound: AudioStream
@export var forest: bool

var _tween: Tween
var _chara: Node2D
var _playing_ticks: bool
const _DURATION_DOWN: float = 0.2
const _DURATION_UP: float = 0.05

var queue_up: bool


func _ready():
    if forest:
        top_sprite.texture = sprites_forest[0]
        base_sprite.texture = sprites_forest[1]
        audio_tick.stream = tick_forest_sound
        audio_tick.volume_db = 0
        audio_boing.stream = boing_forest_sound
        audio_boing.volume_db = 0
        _fix_top_pos.call_deferred()


func _fix_top_pos():
    top.position.x = 0


func _on_area_2d_body_entered(body: Node2D) -> void :
    if body.is_in_group("player_chara"):
        _chara = body
        if _tween:
            _tween.stop()
        _tween = create_tween()
        if Engine.get_frames_per_second() < 60:
            _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
        _tween.tween_property(top, "position", Vector2(0, -2), _DURATION_DOWN)
        _tween.finished.connect(jump.bind(body), 4)

        _playing_ticks = true
        _play_tick()


func jump(body: Node2D):
    body.queue_big_jump = true
    _playing_ticks = false
    audio_boing.play()


func _on_area_2d_body_exited(body: Node2D) -> void :
    if body == _chara:
        if _tween:
            _tween.stop()
            if _tween.finished.is_connected(jump): _tween.finished.disconnect(jump)
        _tween = create_tween()
        if Engine.get_frames_per_second() < 60:
            _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
        _tween.tween_property(top, "position", Vector2(0, -8), _DURATION_UP)

        _playing_ticks = false


func _play_tick():
    audio_tick.play()
    if _playing_ticks:
        get_tree().create_timer(0.1).timeout.connect(_play_tick, 4)
