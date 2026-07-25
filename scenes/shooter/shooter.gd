extends Node2D

var projectile: PackedScene = preload("res://scenes/projectile/projectile.tscn")

@export var interval: float = 1
@export var speed: float = 200
@export var prepopulation_offset: float = 0
@export var target: Node2D
@export var timer: Timer
@export var marker: Marker2D
@export var sprite: Sprite2D
@export var audio: AudioStreamPlayer2D
@export var mute_projectiles: bool
@export var mute_audio: bool
@export var limit_audio: bool
@export var limit_audio_count: int
var _max_limit: int = 1

var instances: Array
var _started: bool

var _player: Array[Node]
var _first_input: bool

func _ready() -> void :
    _prepopulate()
    _get_input_signals()

    if rotation_degrees >= 170 || rotation_degrees <= -170:
        sprite.flip_v = true


func _shoot():
    timer.start(interval)
    timer.timeout.connect(_reshoot, 4)
    var instance = projectile.instantiate()
    add_child(instance)
    instance.set_projectile(marker.global_position, target.get_pos(), speed)
    if mute_projectiles:
        instance.mute = true

    if !mute_audio:
        if limit_audio:
            if limit_audio_count == 0:
                audio.play()
            limit_audio_count += 1
            if limit_audio_count > _max_limit:
                limit_audio_count = 0
        else:
            audio.play()


func _reshoot():
    _shoot.call_deferred()


func _prepopulate():
    var origin_pos: Vector2 = marker.global_position
    var target_pos: Vector2 = target.global_position
    var pos: Vector2 = marker.global_position
    var total_distance: float = origin_pos.distance_to(target_pos)
    var direction_vector: Vector2 = (origin_pos - target_pos).normalized()

    pos += direction_vector * speed * prepopulation_offset
    pos -= direction_vector * speed * interval

    var new_vector = (pos - target_pos).normalized()
    while new_vector.is_equal_approx(direction_vector):
        var instance = projectile.instantiate()
        add_child(instance)
        instance.global_position = pos
        instances.append(instance)
        pos -= direction_vector * speed * interval
        new_vector = (pos - target_pos).normalized()


func _start():
    if _started: return
    _started = true

    for instance in instances:
        instance.set_projectile(instance.global_position, target.get_pos(), speed)
        if mute_projectiles:
            instance.mute = true

    if prepopulation_offset == 0:
        _shoot()
    else:
        timer.start(prepopulation_offset)
        timer.timeout.connect(_shoot, 4)


func _on_first_input():
    if _first_input: return
    _first_input = true

    for player in _player:
        if player.first_input.is_connected(_on_first_input):
            player.first_input.disconnect(_on_first_input)

    _start()


func _get_input_signals():
    var _player = get_tree().get_nodes_in_group("player_chara")
    if _player.size() < 2:
        _get_input_signals.call_deferred()
        return

    for player in _player:
        player.first_input.connect(_on_first_input, 4)
