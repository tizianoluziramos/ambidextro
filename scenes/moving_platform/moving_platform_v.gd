extends Node2D

@export_range(2, 12) var length: int = 2
@export var speed: float = 2
@export var start_bottom: bool = true
@export var hide_lines: bool
@export var line_sprite: AtlasTexture
@export var end_sprite: AtlasTexture
@export var origin: Sprite2D
@export var ends: Array[Sprite2D]
@export var platform_audio: AudioStreamPlayer2D
@export var platform_audio_cling: AudioStreamPlayer2D
@export var platform: Node
@export var dont_play: bool

var _start: Vector2
var _end: Vector2
var _duration: float
var _started: bool
var _tween: Tween
var _ends: Array[Sprite2D]
var _platform_set: bool

func _ready() -> void :
    _ends = [$VisiblePath / End1, $VisiblePath / End2, $VisiblePath / End3, $VisiblePath / End4, $VisiblePath / End5, $VisiblePath / End6, $VisiblePath / End7, $VisiblePath / End8, $VisiblePath / End9, $VisiblePath / End10, $VisiblePath / End11]
    set_platform()
    get_input_signals()

    await get_tree().create_timer(0.01).timeout
    platform.visible = true


func set_platform():
    length -= 2
    if hide_lines:
        origin.texture = end_sprite
    for i in _ends.size():
        if i < length:
            if !hide_lines:
                _ends[i].texture = line_sprite
            else:
                _ends[i].texture = null
        elif i == length && hide_lines:
            _ends[i].texture = end_sprite
        elif i > length:
            _ends[i].texture = null

    if start_bottom:
        _start = $Platform.position
        _end = _ends[length].position
        _end += Vector2(0, -5)
    else:
        _start = _ends[length].position
        _end = $Platform.position
        _start += Vector2(0, -5)
        $Platform.position = _start

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

    platform_audio.play()


func _move_to_end():
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property($Platform, "position", _end, _duration)
    _tween.finished.connect(_move_to_start, 4)
    _tween.finished.connect(_play_cling, 4)


func _move_to_start():
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property($Platform, "position", _start, _duration)
    _tween.finished.connect(_move_to_end, 4)
    _tween.finished.connect(_play_cling, 4)


func _play_cling():
    if !dont_play:
        platform_audio_cling.play()


func _on_area_2d_body_entered(body: Node2D) -> void :
    body.queue_ground_is_moving_platform_on_grounded()


func _on_area_2d_body_exited(body: Node2D) -> void :
    body.on_leave_vertical_moving_platform()
