extends Node2D

enum Direction{Up, Down, Left, Right}

@export var direction: Direction = Direction.Right
@export var speed: float = 3
@export var audio: AudioStreamPlayer2D
@export var arrow: Sprite2D
@export var arrow_sprites: Array[Texture2D]
@export var animatable_body: AnimatableBody2D
@export var collision_shape: CollisionShape2D
@export var raycast: RayCast2D
@export var raycast_l: RayCast2D
@export var raycast_r: RayCast2D
@export var kill_collider_up: CollisionShape2D
@export var kill_collider_down: CollisionShape2D
@export var kill_collider_left: CollisionShape2D
@export var kill_collider_right: CollisionShape2D
@export var block_collider_down: CollisionShape2D

var _tween: Tween
var _target_position: Vector2
var _kill_area_collider: CollisionShape2D
var _unsafe_distance: float

var _queue_activate: bool
var _queue_deactivate: bool
var _body: Node2D
var _mirror: bool

var _reenable_collision_next_frame: bool

func _ready():
    add_to_group("directional_block")
    _initialize.call_deferred()


func _physics_process(_delta: float) -> void :
    if _reenable_collision_next_frame:
        _reenable_collision_next_frame = false
        collision_shape.disabled = false

    if _tween && _tween.is_running() && animatable_body.global_position.distance_to(_target_position) < _unsafe_distance:
        _kill_area_collider.disabled = false

    if _queue_activate:


        if _body.is_grounded():
            if direction == Direction.Up:
                if !_body.is_stepping_on_something_else():
                    _activate()

                elif abs(_body.global_position.x - animatable_body.global_position.x) < 13:
                    _activate()
            elif !_body.is_stepping_on_something_else():
                _activate()
            elif abs(_body.global_position.x - animatable_body.global_position.x) <= 3:
                _activate()

            if direction == Direction.Down:
                _body.set_force_apply_gravity(true)

    elif _queue_deactivate:
        _queue_deactivate = false
        _deactivate()


func _initialize():
    if !raycast:
        _initialize.call_deferred()
        return


    if Global.current_level_layout.mirrored:
        _mirror = true


    _unsafe_distance = 14
    match direction:
        Direction.Up:
            raycast.target_position = Vector2(0, -600)
            arrow.texture = arrow_sprites[0]
            _kill_area_collider = kill_collider_up
        Direction.Down:
            raycast.target_position = Vector2(0, 600)
            arrow.texture = arrow_sprites[2]
            _kill_area_collider = kill_collider_down
        Direction.Left:
            arrow.texture = arrow_sprites[1]
            raycast.target_position = Vector2(-600, 0)
            _kill_area_collider = kill_collider_left
        Direction.Right:
            arrow.rotation_degrees = 0
            raycast.target_position = Vector2(600, 0)
            _kill_area_collider = kill_collider_right



func _get_target_position():
    _target_position = raycast.get_wall_position()
    match direction:
        Direction.Up:
            _target_position.y += 8
        Direction.Down:
            _target_position.y -= 8
        Direction.Left:
            if _mirror:
                _target_position.x -= 8
            else:
                _target_position.x += 8
        Direction.Right:
            if _mirror:
                _target_position.x += 8
            else:
                _target_position.x -= 8


func _on_area_2d_body_entered(body: Node2D) -> void :
    if direction == Direction.Down:
        _deactivate_block_collider_down.call_deferred()

    body.queue_ground_is_moving_platform_on_grounded()
    _queue_activate = true
    _body = body


func _on_area_2d_body_exited(body: Node2D) -> void :
    _queue_deactivate = true
    _queue_activate = false
    _body = body
    body.set_force_apply_gravity(false)

    if direction == Direction.Down:
        _get_target_position()
        if animatable_body.global_position.distance_to(_target_position) < 13:
            _activate_block_collider_down.call_deferred()


func _activate_block_collider_down():
    block_collider_down.disabled = false


func _deactivate_block_collider_down():
    block_collider_down.disabled = true


func _activate():
    _queue_activate = false
    _queue_deactivate = false
    _get_target_position()

    audio.play()

    if _tween:
        _tween.stop()

    var distance: float = animatable_body.global_position.distance_to(_target_position)
    var duration: float = distance / (speed * 40)
    _tween = create_tween()

    if Engine.get_frames_per_second() < 60:
        _tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    _tween.tween_property(animatable_body, "global_position", _target_position, duration)
    _tween.finished.connect(_deactivate, 4)


func _deactivate():
    if _tween && _tween.finished.is_connected(_deactivate):
        _tween.finished.disconnect(_deactivate)

    audio.stop()
    if _body: _body.on_leave_vertical_moving_platform()
    _body = null
    if _tween && _tween.is_running():
        _tween.stop()



func move_back(move_left: bool):
    if direction == Direction.Left || direction == Direction.Right:
        if _tween && _tween.is_running(): _tween.stop()
        if move_left:
            _tween = create_tween()
            _tween.tween_property(animatable_body, "global_position:x", animatable_body.global_position.x - 1, 0.1)
        else:
            _tween = create_tween()
            _tween.tween_property(animatable_body, "global_position:x", animatable_body.global_position.x + 1, 0.1)
