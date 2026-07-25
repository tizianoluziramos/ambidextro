extends Node2D

@export var length: int = 3
@export var plus_half: bool
@export var duration: float = 1
@export var start_left: bool = true
@export var mace_sprite: Sprite2D
@export var top: Sprite2D
@export var chain_sprite: Sprite2D
@export var rotation_container: Node
@export var audio: AudioStreamPlayer2D
@export var sprites_forest: Array[Texture2D]
@export var forest: bool

var _mace_chain: PackedScene = preload("res://scenes/mace/mace_chain.tscn")
const _ANGLES: Array = [0, 0, 70, 78, 81, 83, 84]
var _angle: float
var _tween: Tween

var _player: Array[Node]
var _first_input: bool

func _ready() -> void :
    var mace_offset: float = (length - 1) * 16
    if plus_half:
        mace_offset += 8

    mace_sprite.position.x += 16
    mace_sprite.position.y += mace_offset


    var _mace_chain_instance: Node2D


    for i in length - 2:
        _mace_chain_instance = _mace_chain.instantiate()
        _mace_chain_instance.position.y += 16 * (i + 1) + 8
        if plus_half: _mace_chain_instance.position.y += 8
        rotation_container.add_child(_mace_chain_instance)

        if forest:
            _mace_chain_instance.texture = sprites_forest[2]

    if plus_half:
        _mace_chain_instance = _mace_chain.instantiate()
        _mace_chain_instance.position.y += 16
        rotation_container.add_child(_mace_chain_instance)

        if forest:
            _mace_chain_instance.texture = sprites_forest[2]


    _mace_chain_instance = _mace_chain.instantiate()
    _mace_chain_instance.position.y += 16 * (length - 1)
    if plus_half: _mace_chain_instance.position.y += 8
    rotation_container.add_child(_mace_chain_instance)
    if forest:
        _mace_chain_instance.texture = sprites_forest[2]


    _angle = _ANGLES[length]
    if !start_left: _angle *= -1
    rotation_container.rotation_degrees = _angle

    _get_input_signals()

    if forest:
        mace_sprite.texture = sprites_forest[0]
        top.texture = sprites_forest[1]
        chain_sprite.texture = sprites_forest[2]



func _process(delta: float) -> void :
    mace_sprite.global_rotation = 0


func _swing():
    _angle *= -1
    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(rotation_container, "rotation_degrees", _angle, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
    _tween.finished.connect(_swing, 4)
    get_tree().create_timer(duration / 4).timeout.connect(_play_swing)


func _play_swing():
    audio.pitch_scale = randf_range(0.95, 1.05)
    audio.play()


func _on_first_input():
    if _first_input: return
    _first_input = true

    for player in _player:
        if player.first_input.is_connected(_on_first_input):
            player.first_input.disconnect(_on_first_input)

    _swing()


func _get_input_signals():
    var _player = get_tree().get_nodes_in_group("player_chara")
    if _player.size() < 2:
        _get_input_signals.call_deferred()
        return

    for player in _player:
        player.first_input.connect(_on_first_input, 4)
