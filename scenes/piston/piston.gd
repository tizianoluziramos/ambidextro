extends Node2D

@export var down: bool = true
@export var pair: Node
@export var down_node: Node
@export var up_node: Node
@export var down_collision: CollisionShape2D
@export var up_collision: CollisionShape2D
@export var static_collision: CollisionShape2D
@export var audio_down: AudioStreamPlayer2D
@export var audio_up: AudioStreamPlayer2D

var _player_in: Node
var toggle_queued: bool
var _toggle_collider_queued: bool
var _tracking_body: Node

var _cooldown_timer: Timer

func _ready() -> void :
    down = !down
    toggle()

func _physics_process(_delta: float) -> void :
    if toggle_queued:
        toggle()
        toggle_queued = false

    if _toggle_collider_queued:
        _toggle_collider()

    if _tracking_body != null:
        if _tracking_body.velocity.y >= 0 && ( !_tracking_body.is_grounded() || (_tracking_body.is_grounded() && _tracking_body.global_position.y - global_position.y >= -11)):
            toggle_queued = true
            pair.toggle_queued = true
            _tracking_body.fall.call_deferred()
            _tracking_body = null


func toggle():
    _tracking_body = null

    if down:

        down = false
        if _player_in:
            _player_in.global_position.y = global_position.y - 14
            _player_in.queue_big_jump = true
            start_cooldown_timer()

        up_node.visible = true
        _toggle_collider_queued = true
        up_collision.disabled = false

        down_node.visible = false
        down_collision.disabled = true
        if toggle_queued: audio_up.play()

    else:

        down = true
        up_node.visible = false
        static_collision.disabled = true
        up_collision.disabled = true

        down_node.visible = true
        down_collision.disabled = false
        if toggle_queued: audio_down.play()



func _toggle_collider():
    _toggle_collider_queued = false
    if !down:
        static_collision.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void :
    if not body is PlayerChara: return
    _player_in = body


func _on_area_2d_body_exited(body: Node2D) -> void :
    if not body is PlayerChara: return
    _player_in = null


func _on_area_2d_up_body_entered(body: Node2D) -> void :
    if _cooldown_timer && !_cooldown_timer.is_stopped(): return
    if not body is PlayerChara: return

    if (body.velocity.y >= 0 && body.global_position.x - global_position.x <= 13.5) && ( !body.is_grounded() || (body.is_grounded() && body.global_position.y - global_position.y >= -11)):
        _tracking_body = null
        toggle_queued = true
        pair.toggle_queued = true
        body.fall.call_deferred()
    else:
        _tracking_body = body


func start_cooldown_timer():
    _cooldown_timer = Timer.new()
    _cooldown_timer.one_shot = true
    add_child(_cooldown_timer)
    _cooldown_timer.start(0.1)


func _on_area_2d_up_body_exited(body: Node2D) -> void :
    _tracking_body = null
