extends Node2D

@export_range(2, 7) var length: int = 2
@export var speed: float = 2
@export var start_left: bool = true
@export var long: bool
@export var line_sprite: AtlasTexture
@export var platform: Node
@export var platform_long: Node
@export var platform_audio: AudioStreamPlayer2D
@export var platform_audio_cling: AudioStreamPlayer2D
@export var platform_long_audio: AudioStreamPlayer2D
@export var platform_long_audio_cling: AudioStreamPlayer2D
@export var dont_play: bool

var _start: Vector2
var _end: Vector2
var _duration: float
var _started: bool
var _tween: Tween
var _ends: Array[Sprite2D]
var _platform_set: bool


func _ready() -> void :
    _ends = [$VisiblePath / End1, $VisiblePath / End2, $VisiblePath / End3, $VisiblePath / End4, $VisiblePath / End5, $VisiblePath / End6]
    set_platform()
    get_input_signals()

    await get_tree().create_timer(0.01).timeout

    if !long:
        platform.visible = true
        platform_long.queue_free()
    else:
        platform_long.visible = true
        platform.queue_free()


func set_platform():
    length -= 2
    for i in _ends.size():
        if i < length:
            _ends[i].texture = line_sprite
            _ends[i].rotation_degrees = 90
        elif i > length:
            _ends[i].texture = null

    if start_left:
        _start = platform.position
        _end = _ends[length].position
        if long: _end.x -= 4
    else:
        _start = _ends[length].position
        _end = platform.position
        if long:
            _start.x -= 4
            platform_long.position = _start
        else:
            platform.position = _start

    _duration = (length + 2.0) / speed

    _platform_set = true

func get_input_signals():
    var players = get_tree().get_nodes_in_group("player_chara")
    if players.size() < 2:
        get_input_signals.call_deferred()
        return

    for player in players:
        player.first_input.connect(_queue_move, 4)


func _queue_move():
    if !_platform_set:
        _queue_move.call_deferred()
        return
    if _started: return
    _started = true
    _move_to_end()
    if dont_play: return

    if long:
        platform_long_audio.play()
    else:
        platform_audio.play()


func _move_to_end():
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    if !long:
        _tween.tween_property(platform, "position", _end, _duration)
    else:
        _tween.tween_property(platform_long, "position", _end, _duration)
    _tween.finished.connect(_move_to_start, 4)
    _tween.finished.connect(_play_cling, 4)


func _move_to_start():
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    if !long:
        _tween.tween_property(platform, "position", _start, _duration)
    else:
        _tween.tween_property(platform_long, "position", _start, _duration)
    _tween.finished.connect(_move_to_end, 4)
    _tween.finished.connect(_play_cling, 4)


func _play_cling():
    if !dont_play:
        if long:
            platform_long_audio_cling.play()
        else:
            platform_audio_cling.play()
