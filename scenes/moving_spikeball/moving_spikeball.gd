extends Node2D

@export_range(2, 14) var length: int = 2
@export var speed: float = 2
@export var start_left: bool = true
@export var line_sprite: Texture2D
@export var spikeball: AnimatableBody2D
@export var spikeball_sprite: Sprite2D
@export var origin_sprite: Sprite2D
@export var visible_path: Node2D
@export var sprites_forest: Array[Texture]
@export var audio: AudioStreamPlayer2D
@export var audio_cling: AudioStreamPlayer2D
@export var tick_sound_forest: AudioStream
@export var cling_sound_forest: AudioStream
@export var dont_play: bool
@export var forest: bool

var _started: bool
var _ends: Array[Node]
var _start: Vector2
var _end: Vector2
var _duration: float
var _tween: Tween
var _path_set: bool

var _move_queued: bool
var _position_queued: bool

func _ready() -> void :
    _ends = visible_path.get_children()
    _ends.remove_at(0)
    set_path()
    get_input_signals()


    if rotation_degrees > 89:
        rotation_degrees = 90
        spikeball_sprite.rotation_degrees = -90
    elif rotation_degrees < -89:
        rotation_degrees = -90
        spikeball_sprite.rotation_degrees = 90
    spikeball.visible = true

    if forest:
        spikeball_sprite.texture = sprites_forest[0]
        origin_sprite.texture = sprites_forest[1]
        audio.stream = tick_sound_forest
        audio.volume_db = -10
        audio.max_distance = 200
        audio_cling.stream = cling_sound_forest
        audio_cling.volume_db = 10
        audio_cling.max_distance = 200
        visible = false


func _physics_process(_delta: float) -> void :
    if _move_queued:
        _move_queued = false

        _move_to_end()

    elif _position_queued:
        _position_queued = false
        spikeball.position = _start


func set_path():
    length -= 2
    for i in _ends.size():
        if i < length:
            if forest:
                _ends[i].texture = sprites_forest[2]
            else:
                _ends[i].texture = line_sprite
                _ends[i].rotation_degrees = 90
        elif i > length:
            _ends[i].texture = null
        elif forest:
            _ends[i].texture = sprites_forest[1]

    if start_left:
        _start = spikeball.position
        _end = _ends[length].position
    else:
        _start = _ends[length].position
        _end = spikeball.position
        _position_queued = true
    _duration = (length + 2.0) / speed

    _path_set = true


func get_input_signals():
    var players = get_tree().get_nodes_in_group("player_chara")
    if players.size() < 2:
        get_input_signals.call_deferred()
        return

    for player in players:
        player.first_input.connect(_queue_move, 4)


func _queue_move():
    if !_path_set:
        _queue_move.call_deferred()
        return
    if _started: return
    visible = true
    _started = true
    _move_queued = true
    if dont_play: return
    audio.play()


func _move_to_end():
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(spikeball, "position", _end, _duration)
    _tween.finished.connect(_move_to_start, 4)
    _tween.finished.connect(_play_cling, 4)


func _move_to_start():
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(spikeball, "position", _start, _duration)
    _tween.finished.connect(_move_to_end, 4)
    _tween.finished.connect(_play_cling, 4)


func _play_cling():
    if dont_play: return
    audio_cling.play()
