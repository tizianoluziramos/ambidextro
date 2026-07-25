extends Node2D

@export var timer: Timer
@export var bar_extra: ColorRect
@export var bar_extra_shadow: ColorRect
@export var bar: ColorRect
@export var bar_shadow: ColorRect
@export var numbers_font: Array[Texture2D]
@export var audio_start: AudioStreamPlayer
@export var audio_player: AudioStreamPlayer

const _DEATH_COOLDOWN: float = 0.2

var _time: float
var _original_time: float
var _tween: Tween
var _started: bool
var _stopped: bool
var input_strings: Array[String]

var _original_extra_size_x: float
var _original_size_x: float

var disable_timer: bool

func initialize(time: float, time_plus_extra: float) -> void :
    if _tween: return
    if time == 0:
        self.queue_free()
        return
    _original_time = time
    _time = time_plus_extra
    timer.wait_time = _time
    if !timer.timeout.is_connected(_on_timeout):
        timer.timeout.connect(_on_timeout)
    get_input_signals()

    _original_extra_size_x = bar_extra.size.x

    var new_size: float = (time * _original_extra_size_x) / time_plus_extra
    bar.size.x = round(new_size)
    bar_shadow.size.x = bar.size.x
    _original_size_x = bar.size.x
    bar.position.x = bar.size.x / -2
    bar_shadow.position.x = 0


func get_input_signals():
    var players = get_tree().get_nodes_in_group("player_chara")
    if players.size() < 2:
        get_input_signals.call_deferred()
        return

    for player in players:
        if !player.first_input.is_connected(start_timer):
            player.first_input.connect(start_timer, 4)


func start_timer():
    if _started || disable_timer: return

    _started = true
    bar_extra.self_modulate = Color(255 / 255.0, 195 / 255.0, 49 / 255.0)
    bar.self_modulate = Color(255 / 255.0, 148 / 255.0, 8 / 255.0)
    timer.start()
    _tween = create_tween()
    _tween.set_parallel(true)
    _tween.tween_method(_reduce_size_extra, 1.0, 0.0, _time)
    _tween.tween_method(_reduce_size, 1.0, 0.0, _original_time)

    audio_start.play()


func _reduce_size_extra(value: float):
    bar_extra.size.x = roundi(_original_extra_size_x * value)
    bar_extra_shadow.size.x = bar_extra.size.x
    bar_extra.position.x = bar_extra.size.x / -2
    bar_extra_shadow.position.x = 0


func _reduce_size(value: float):
    bar.size.x = roundi(_original_size_x * value)
    bar_shadow.size.x = bar.size.x
    bar.position.x = bar.size.x / -2
    bar_shadow.position.x = 0



func stop_timer():
    _stopped = false
    bar_extra.self_modulate = Color(139 / 255.0, 111 / 255.0, 86 / 255.0)
    bar.self_modulate = Color(105 / 255.0, 87 / 255.0, 71 / 255.0)
    if _tween: _tween.stop()
    if timer: timer.stop()


func _on_timeout():
    var players: Array[Node] = get_tree().get_nodes_in_group("player_chara")
    for player in players:
        player.on_timeout(self)



func confirm_failure():
    $"../TimerIcon".self_modulate = Color.RED
    audio_player.play()
    get_tree().paused = true
    var timer_: SceneTreeTimer = get_tree().create_timer(_DEATH_COOLDOWN)
    timer_.timeout.connect(_reset)


func _reset():
    var level_loaders: = get_tree().get_nodes_in_group("level_loader")
    level_loaders[0].reset_level(false)
