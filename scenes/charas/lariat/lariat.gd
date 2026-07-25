extends Node2D

@export var animation: AnimatedSprite2D
@export var camera: Camera2D
@export var spawn: Node
@export var other_lariat: Node
@export var swapper: Node
@export var royal_end: Node
@export var audio_fly: AudioStreamPlayer2D
@export var left: bool
var mirror: bool

var fireball: PackedScene = preload("res://scenes/lariat_fireball/lariat_fireball.tscn")
var _player: Node

var _tween_x: Tween
var _tween_y: Tween
var _original_position: Vector2
var _offset_x: float = 40
var _offset_y: float = 50
var _duration: float = 2
var _projectile_speed: float = 50
var _shooting: bool
var _stop_attacking: bool
var _flee_activated: bool

var _timer: Timer

var _tween_swapper: Tween
var _swapper_time: float = 0.5
var _swapper_activated: bool
var swapped: bool

func _ready() -> void :
    spawn.player_created.connect(_get_player)

    position.x -= _offset_x / 2
    _original_position = position
    _timer = Timer.new()
    add_child(_timer)
    _fly_r()


func _process(_delta: float) -> void :

    if camera.global_position.y - 100 < global_position.y:
        global_position.y = camera.global_position.y - 100


func _fly_r():
    if _flee_activated: return
    if _stop_attacking && other_lariat.is_stop_attacking():
        flee(false)
        return

    _tween_x = create_tween()
    _tween_x.tween_method(_move_pixel_perfect_x, _original_position.x, _original_position.x + _offset_x, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_x.finished.connect(_fly_l, 4)

    _tween_y = create_tween()
    _tween_y.tween_method(_move_pixel_perfect_y, 0, _offset_y / 4.0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_method(_move_pixel_perfect_y, _offset_y / 4.0, 0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_method(_move_pixel_perfect_y, 0, _offset_y / 4.0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_method(_move_pixel_perfect_y, _offset_y / 4.0, 0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    _timer.start(_duration * 0.6)
    if _shooting && !_stop_attacking:
        if royal_end.is_active():
            _stop_attacking = true
            _timer.timeout.connect(_play_animation.bind("end_r"), 4)
        else:
            _timer.timeout.connect(_play_animation.bind("end_r_shoot"), 4)
    else:
        _timer.timeout.connect(_play_animation.bind("end_r"), 4)

    if left:
        _attack()

    if _shooting && !_stop_attacking:
        animation.play("start_r_shoot")
    else:
        animation.play("start_r")

    if !_shooting && camera.position.y < -50:
        _shooting = true

    if _stop_attacking && other_lariat.is_stop_attacking():
        flee(false)
        return

    other_lariat.force_sync()

    if !left: _play_fly()


func _fly_l():
    if _flee_activated: return
    if _stop_attacking && other_lariat.is_stop_attacking():
        flee(true)
        return

    _tween_x = create_tween()
    _tween_x.tween_method(_move_pixel_perfect_x, _original_position.x + _offset_x, _original_position.x, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_x.finished.connect(_fly_r, 4)

    _tween_y = create_tween()
    _tween_y.tween_method(_move_pixel_perfect_y, 0, _offset_y / 4.0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_method(_move_pixel_perfect_y, _offset_y / 4.0, 0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_method(_move_pixel_perfect_y, 0, _offset_y / 4.0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_method(_move_pixel_perfect_y, _offset_y / 4.0, 0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    _timer.start(_duration * 0.6)

    if _shooting && !_stop_attacking:
        if royal_end.is_active():
            _stop_attacking = true
            _timer.timeout.connect(_play_animation.bind("end_l"), 4)
        else:
            _timer.timeout.connect(_play_animation.bind("end_l_shoot"), 4)
    else:
        _timer.timeout.connect(_play_animation.bind("end_l"), 4)

    if !left:
        _attack()

    if _shooting && !_stop_attacking:
        animation.play("start_l_shoot")
    else:
        animation.play("start_l")

    if !_shooting && camera.position.y < -50:
        _shooting = true

    if _stop_attacking && other_lariat.is_stop_attacking():
        flee(true)
        return

    if left: _play_fly()


func force_sync():
    if _tween_x && _tween_x.get_total_elapsed_time() > 0.1 && _tween_x.is_running():
        _tween_x.custom_step(999)
    elif _tween_y && _tween_y.get_total_elapsed_time() > 0.1 && _tween_y.is_running():
        _tween_y.custom_step(999)


func _play_animation(anim: String):
    animation.play(anim)


func _attack():
    if royal_end.is_active(): return
    if !_player: return

    if _shooting:






        _shoot()


func activate_swapper():
    _swapper_activated = true
    _tween_swapper = create_tween()
    _tween_swapper.tween_property(swapper, "scale:y", 1, _swapper_time)


func swap():
    var this_player_pos: Vector2 = _player.global_position
    var other_player: Node = other_lariat.get_player()
    var other_player_pos: Vector2 = other_player.global_position

    if swapped:
        _player.reparent(spawn)
        other_player.reparent(other_lariat.spawn)
        swapped = false
        other_lariat.swapped = false
    else:
        other_player.reparent(spawn)
        _player.reparent(other_lariat.spawn)
        swapped = true
        other_lariat.swapped = true

    _player.global_position = Vector2(0, 0)
    other_player.global_position = this_player_pos
    _player.global_position = other_player_pos


func _shoot():

    var instance: Node = fireball.instantiate()
    get_parent().add_child(instance)

    var ball_pos: Vector2 = global_position

    if !mirror:
        if left:
            ball_pos.x -= 15
        else:
            ball_pos.x += 15
    else:
        if left:
            ball_pos.x += 15
        else:
            ball_pos.x -= 15

    instance.global_position = ball_pos
    queue_redraw()
    instance.set_projectile(ball_pos, _player.global_position + Vector2(0, -5), _projectile_speed)
    pass


func flee(from_right):
    if _flee_activated: return
    _flee_activated = true
    other_lariat.flee(from_right)

    _player.set_immortal(true)

    if _tween_x && _tween_x.is_running():
        _tween_x.stop()

    _tween_x = create_tween()
    _tween_x.tween_property(self, "position:x", _original_position.x + _offset_x / 2, _duration / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_x.finished.connect(fly_away, 4)

    _tween_y = create_tween()
    _tween_y.tween_property(animation, "position:y", _offset_y / 4.0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_y.tween_property(animation, "position:y", 0, _duration / 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

    _timer.start((_duration / 2) * 0.6)
    if from_right:
        animation.play("start_l")
        if _timer.timeout.is_connected(_play_animation):
            _timer.timeout.disconnect(_play_animation)
        _timer.timeout.connect(_play_animation.bind("end_l"), 4)

        if !left: _play_fly()
    else:
        animation.play("start_r")
        if _timer.timeout.is_connected(_play_animation):
            _timer.timeout.disconnect(_play_animation)
        _timer.timeout.connect(_play_animation.bind("end_r"), 4)

        if left: _play_fly()


func fly_away():
    await get_tree().create_timer(1).timeout
    _tween_y = create_tween()
    _tween_y.tween_property(self, "position:y", -1500, 3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    _tween_y.finished.connect(_destroy, 4)

    audio_fly.max_distance = 500
    _play_fly()

    camera.activate_credits_music()


func _destroy():
    camera.activate_ending()
    queue_free()


func _play_fly():
    await get_tree().create_timer(0.4).timeout
    _do_play_fly()


func _do_play_fly():
    audio_fly.pitch_scale = randf_range(0.9, 1.1)
    audio_fly.play()


func _get_player(player: Node):
    _player = player


func set_spawn(new_spawn: Node):
    spawn = new_spawn


func get_player() -> Node:
    return _player


func is_stop_attacking() -> bool:
    return _stop_attacking


func _move_pixel_perfect_x(new_x: float):
    position.x = round(new_x)

func _move_pixel_perfect_y(new_y: float):
    animation.position.y = round(new_y)
