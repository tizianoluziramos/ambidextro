extends Node2D

enum DamagePosition{None, Full, Left, Right}

@export var celining_crush_damage: DamagePosition = DamagePosition.Full
@export var brothers: Array[Node2D]
@export var lateral_barriers: Array[Node]
@export var audio_chain: AudioStreamPlayer2D
@export var audio_lock: AudioStreamPlayer2D
@export var audio_hit: AudioStreamPlayer2D
@export var audio_drop: AudioStreamPlayer2D
@export var block: AnimatableBody2D
@export var interpolation_down: Area2D
@export var interpolation_up: Area2D
@export var marker: Marker2D
@export var chains: ColorRect
@export var floor_colision: CollisionShape2D
@export var celing_colision: CollisionShape2D
@export var damage_colision: CollisionShape2D
@export var toggle_colision: CollisionShape2D
@export var raycasts: Array[RayCast2D]
@export var move_raycasts_inward: bool

var _tween: Tween
var _activated: bool
var _original_pos: Vector2
var _global_position_factor: float
var _final_mask_size: float
var _timer: SceneTreeTimer
var _brother_call: bool

var _closest_player_chara: Node

var _interpolation_body: Node
var _clear_interpolation_body_next_frame: bool

const _FALL_DURATION: float = 0.32
const _UP_DURATION: float = 2


func _ready() -> void :
    _original_pos = block.global_position
    var marker_pos: Vector2 = marker.global_position
    var difference: float = (marker_pos - _original_pos).y
    _global_position_factor = 16.0 / difference

    match celining_crush_damage:
        DamagePosition.None:
            celing_colision.scale = Vector2.ZERO
        DamagePosition.Left:
            celing_colision.scale.x = 0.7
            celing_colision.position.x = -3
        DamagePosition.Right:
            celing_colision.scale.x = 0.7
            celing_colision.position.x = 3

    for brother in brothers:
        if brother.brothers.size() == 0:
            brother.brothers = brothers.duplicate()
            brother.brothers.append(self)
            brother.brothers.erase(brother)

    interpolation_down.body_entered.connect(on_interpolation_down_entered)
    interpolation_down.body_exited.connect(on_interpolation_down_exited)
    interpolation_up.body_entered.connect(on_interpolation_up_entered)

    if move_raycasts_inward:
        raycasts[0].position.x += 4
        raycasts[2].position.x -= 4

    _manage_shared_brothers_collider()


func _physics_process(_delta: float) -> void :
    if _clear_interpolation_body_next_frame:
        _interpolation_body = null


func move_to_ground(point: Vector2, brother_call: bool):
    if _activated: return
    _activated = true

    _brother_call = brother_call
    if !_brother_call: audio_drop.play()

    celing_colision.disabled = true

    var final_pos: Vector2 = Vector2(block.global_position.x, point.y - 17)
    var distance: Vector2 = final_pos - block.global_position
    _final_mask_size = distance.y * _global_position_factor + 1
    chains.size.y = 1

    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(block, "global_position", final_pos, _FALL_DURATION)
    _tween.set_parallel(true)
    _tween.tween_property(chains, "size:y", _final_mask_size, _FALL_DURATION)
    _tween.finished.connect(_queue_move_back)

    _disable_lateral_barriers()
    damage_colision.scale.x = 1.1
    toggle_colision.disabled = true

    for brother in brothers:
        brother.move_to_ground(point, true)


func _queue_move_back():
    if !_brother_call: audio_hit.play()

    await get_tree().create_timer(0.1).timeout
    _move_back()


func _move_back():
    if !_brother_call: audio_chain.play()

    _tween = create_tween()
    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(block, "global_position", _original_pos, _UP_DURATION)
    _tween.set_parallel(true)
    chains.size.y += 5
    _tween.tween_property(chains, "size:y", 3, _UP_DURATION)
    _tween.tween_method(_while_moving_back, 0, 1, _UP_DURATION)
    _tween.finished.connect(_reset_raycasts)


    var player_chara_l_pos: Vector2 = Global.player_charas[0].global_position
    var player_chara_r_pos: Vector2 = Global.player_charas[1].global_position
    var distance: float = block.global_position.distance_to(player_chara_l_pos)
    if distance < block.global_position.distance_to(player_chara_r_pos):
        _closest_player_chara = Global.player_charas[0]
    else:
        _closest_player_chara = Global.player_charas[1]

    damage_colision.scale.x = 1
    toggle_colision.disabled = false

    var _duration_per_pixel: float = _UP_DURATION / _final_mask_size
    _timer = get_tree().create_timer(_UP_DURATION - (_duration_per_pixel * 10))
    _timer.timeout.connect(_activate_ceiling_crush_damage)


func _while_moving_back(arg):
    if !_closest_player_chara.is_grounded() && (_closest_player_chara.global_position.x < block.global_position.x + 13 && _closest_player_chara.global_position.x > block.global_position.x - 13):
        if !lateral_barriers[0].disabled:
            _disable_lateral_barriers()
    elif lateral_barriers[0].disabled:
        enable_lateral_barriers()


func _reset_raycasts():
    if !_brother_call: audio_lock.play()
    if !_brother_call: audio_chain.stop()

    _disable_lateral_barriers()

    raycasts[0].reset_mask()
    raycasts[1].reset_mask()
    raycasts[2].reset_mask()
    _activated = false


func _activate_ceiling_crush_damage():
    celing_colision.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void :
    body.queue_ground_is_moving_platform_on_grounded()


func _on_area_2d_body_exited(body: Node2D) -> void :
    body.on_leave_vertical_moving_platform()


func _disable_lateral_barriers():
    for barrier in lateral_barriers:
        barrier.disabled = true



func enable_lateral_barriers():
    if !lateral_barriers[0].disabled: return
    for barrier in lateral_barriers:
        barrier.disabled = false



func on_interpolation_down_entered(body):
    if body is PlayerChara:
        _interpolation_body = body


func on_interpolation_down_exited(body):
    if body is PlayerChara:
        _clear_interpolation_body_next_frame = true


func on_interpolation_up_entered(body):
    if _interpolation_body != null && body == _interpolation_body:
        _interpolation_body.global_position.y = block.global_position.y + 5
        _interpolation_body.force_die()


func _manage_shared_brothers_collider():
    if brothers.size() == 0: return


    for brother in brothers:
        if global_position.x > brother.global_position.x:
            floor_colision.disabled = true
            return

    floor_colision.scale.x = brothers.size() + 1

    if !Global.mirrored:
        floor_colision.position.x = 8 * brothers.size()
    else:
        floor_colision.position.x = -8 * brothers.size()
