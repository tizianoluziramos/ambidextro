class_name PlayerChara
extends CharacterBody2D

@export var player_chara_sprite: Node2D
@export var animation: AnimatedSprite2D
@export var animation_staff: AnimatedSprite2D
@export var coyote_timer: Timer
@export var jump_buffer_timer: Timer
@export var jump_cooldown_timer: Timer
@export var area: Area2D
@export var raycasts: Array[RayCast2D]
@export var raycasts_ground: Array[RayCast2D]
@export var raycasts_side: Array[RayCast2D]
@export var raycasts_spikes_ground: Array[RayCast2D]
@export var raycast_staff: RayCast2D
@export var audio_player: AudioStreamPlayer2D
@export var audio_player_land: AudioStreamPlayer2D
@export var audio_player_ceiling: AudioStreamPlayer2D
@export var damage_area: Node
@export var movement_particles: CPUParticles2D
@export var jump_particles: Array[CPUParticles2D]
@export var ceiling_particles: Array[CPUParticles2D]
@export var move_left: bool
@export var mobile_input_arrow: Sprite2D

@export var trailer_l: Node
@export var trailer_r: Node

var side_left: bool
var other_chara: Node2D
var input_strings: Array[String]

var _move_speed: float = 130
var _jump_height: float = 44
var _jump_time_to_peak: float = 0.3
var _jump_time_to_descent: float = 0.25

var _jump_velocity: float = ((2.0 * _jump_height) / _jump_time_to_peak) * -1.0
var _jump_gravity: float = ((-2.0 * _jump_height) / (_jump_time_to_peak * _jump_time_to_peak)) * -1.0
var _fall_gravity: float = ((-2.0 * _jump_height) / (_jump_time_to_descent * _jump_time_to_descent)) * -1.0
const _MAX_FALL_VELOCITY: float = 400

var _direction: float
var grounded: bool
var can_jump: bool
var win: bool
var _queue_call_next_level: int
var _queue_call_next_level_physics: int
var _previous_positions: Array[Vector2]
var _jumping: bool
var _jumping_up: bool
var _force_apply_gravity: bool
var _first_landing_particles: bool = true
var _just_jumped: int
var _jumped_position: Vector2

var _disabled_area: bool

signal first_input
var first_input_emited: bool
var _dead: bool

signal jumped
var _remaining_frames_without_pushing_box: int
var _floor_previous_frame22: Array[Node]
var _floor_this_frame: Array[Node]
var _ground_is_vertical_moving_platform: int
var _queue_ground_is_moving_platform_on_grounded: int
var _disable_movement_on_grounded: bool

var queue_big_jump: bool

var chara_disabled: bool
var _first_frame: bool = true

var _animation_playing: int
var _animation_staff_playing: int

var _static_staff: bool
var _staff_rotated: bool
var _staff_tween: Tween
var _degrees: float
var _distance: float

var _fail_on_next_frame: int
var _level_timer: Node

var _saved_velocity: Vector2

var disable_reset: bool

var _obtacle_preventing_win: bool
var _other_area: Area2D
var _disabled_area_frame_count: int

func _ready():
    add_to_group("player_chara")
    area.connect("area_entered", _on_win_area_entered)
    area.connect("area_exited", _on_win_area_exited)
    _previous_positions.resize(2)
    _get_other_chara.call_deferred()

    if Global.mobile:
        jump_buffer_timer.wait_time = 0.1




func _process(delta: float) -> void :
    if chara_disabled: return


    if _first_frame:
        _first_frame = false
        return


    if _queue_call_next_level > 1:
        _queue_call_next_level -= 1
        return


    if _dead || win:
        velocity.x = 0
        velocity.y = 0
        return


    if _disable_movement_on_grounded && grounded:
        _do_disable_movement_on_grounded()
        return


    if !first_input_emited && (Input.is_action_just_pressed(input_strings[1]) || Input.is_action_just_pressed(input_strings[2])):
        _emit_first_input()


    var new_direction = Input.get_axis(input_strings[2], input_strings[1])


    _direction = 0
    if new_direction != 0 && first_input_emited:
        _direction = new_direction + get_floor_normal().x
    if _direction < 0: _direction = -1
    elif _direction > 0: _direction = 1


    if is_on_floor() || _ground_is_vertical_moving_platform:
        if _queue_ground_is_moving_platform_on_grounded > 0:
            _queue_ground_is_moving_platform_on_grounded -= 1
            _ground_is_vertical_moving_platform += 1


    elif !_jumping_up && _animation_playing != 4:
        _play_falling_animation()


    if Input.is_action_just_pressed(input_strings[0]):
        jump_buffer_timer.stop()
        jump_buffer_timer.start()
        if !first_input_emited:
            _emit_first_input()


    _manage_move_staff()


func _emit_first_input():
    first_input_emited = true
    first_input.emit()
    Global.emit_first_input()


func _physics_process(delta: float) -> void :
    if chara_disabled: return


    if _first_frame: return


    if _disabled_area:
        _disabled_area_frame_count += 1
        if _disabled_area_frame_count >= 3:
            _disabled_area_frame_count = 0
            toggle_disable_area(false)
    else:
        _disabled_area_frame_count = 0

    if _obtacle_preventing_win:
        _on_win_area_entered(_other_area)


    if _queue_call_next_level_physics > 1:
        velocity.x = 0
        velocity.y = 0
        _queue_call_next_level_physics -= 1
        return
    elif _queue_call_next_level_physics == 1 && _queue_call_next_level == 1:
        _queue_call_next_level_physics = 0
        _queue_call_next_level = 0
        var level_loaders: = get_tree().get_nodes_in_group("level_loader")
        level_loaders[0].next_level(false)
        return



    if _fail_on_next_frame == 1 && !win:
        _fail_on_next_frame += 1
        position = _previous_positions[1]
        velocity.x = 0
        velocity.y = 0
        return
    elif _fail_on_next_frame == 2 && !win:
        _fail_on_next_frame = 0
        do_failure()


    if _dead || win:
        position = _previous_positions[1]
        velocity.x = 0
        velocity.y = 0
        return


    _previous_positions[0] = _previous_positions[1]
    _previous_positions[1] = position


    _manage_movement_particles(_direction)


    if _just_jumped > 0: _just_jumped -= 1


    if grounded:

        if !is_on_floor():
            grounded = false
            can_jump = false


            coyote_timer.stop()
            if _is_floor_not_disappeared():
                coyote_timer.start()
                can_jump = true


    elif is_on_floor():
        grounded = true
        can_jump = true
        _jumping = false
        _jumping_up = false

        if _landed_on_spikes_ground():
            grounded = false
            can_jump = false
            coyote_timer.stop()
            _manage_stuck_falling()
        else:
            _manage_jump_particles(true)


    elif !coyote_timer.is_stopped():
        can_jump = true

    else:
        can_jump = false


    if !is_on_floor() || !jump_cooldown_timer.is_stopped():
        velocity.y += _get_gravity() * delta
        if velocity.y > _MAX_FALL_VELOCITY:
            velocity.y = _MAX_FALL_VELOCITY


        if _jumping && velocity.y >= 0.0:
            _jumping_up = false
            _play_falling_animation()


    if _force_apply_gravity:
        _jumping = false
        _jumping_up = false
        velocity.y = _MAX_FALL_VELOCITY



    velocity.x = _direction * _move_speed


    if !is_on_floor() && is_on_ceiling():
        can_jump = false
        jump_cooldown_timer.stop()
        coyote_timer.stop()


        if position.y + 40 > _jumped_position.y:
            audio_player_ceiling.play()
            ceiling_particles[0].emitting = true
            ceiling_particles[1].emitting = true


    if queue_big_jump: _big_jump()
    elif can_jump && !jump_buffer_timer.is_stopped():
        _jump()


    _saved_velocity = velocity
    move_and_slide()




    if !is_on_floor() && !_jumping_up && _previous_positions[1] == position && _animation_playing == 4:
        _manage_stuck_falling()


    if is_grounded() && !_jumping_up:
        if _direction != 0:
            if side_left:
                if _direction > 0 && _animation_playing != 1:
                    _animation_playing = 1
                    animation.speed_scale = 1
                    animation.play("walking_l")
                    animation_staff.speed_scale = 1
                    _animation_staff_playing = _animation_playing
                    animation_staff.play("walking")
                elif _direction < 0 && _animation_playing != 2:
                    _animation_playing = 2
                    animation.speed_scale = -1
                    animation.play("walking_l")
                    animation_staff.speed_scale = -1
                    _animation_staff_playing = _animation_playing
                    animation_staff.play("walking")
            else:
                if _direction > 0 && _animation_playing != 1:
                    _animation_playing = 1
                    animation.speed_scale = -1
                    animation.play("walking_r")
                    animation_staff.speed_scale = -1
                    _animation_staff_playing = _animation_playing
                    animation_staff.play("walking")
                elif _direction < 0 && _animation_playing != 2:
                    _animation_playing = 2
                    animation.speed_scale = 1
                    animation.play("walking_r")
                    animation_staff.speed_scale = 1
                    _animation_staff_playing = _animation_playing
                    animation_staff.play("walking")
        elif _animation_playing != 0:
            _animation_playing = 0
            if side_left:
                animation.play("idle_l")
            else:
                animation.play("idle_r")
            _animation_staff_playing = _animation_playing
            animation_staff.play("idle")


    if _remaining_frames_without_pushing_box > 0: _remaining_frames_without_pushing_box -= 1
    if is_on_floor() && get_slide_collision_count() > 0:
        _floor_previous_frame22 = _floor_this_frame.duplicate()
        _floor_this_frame.clear()
    for i in get_slide_collision_count():
        var collision: KinematicCollision2D = get_slide_collision(i)
        var collider: Object = collision.get_collider()
        if collider is box:
            var normal: Vector2 = collision.get_normal()
            if abs(normal.y) < 0.51:
                if _remaining_frames_without_pushing_box == 0: _saved_velocity *= 2
                collider.move(_saved_velocity)

                _remaining_frames_without_pushing_box = 3
        if is_on_floor():
            _floor_this_frame.append(collider)

            if collider.get_parent() is crumbling_platform:
                collider.get_parent().crumble()

    _manage_corner_correction(velocity.y, false)


func _get_gravity() -> float:
    return _jump_gravity if velocity.y < 0.0 else _fall_gravity


func _jump():
    if !jump_cooldown_timer.is_stopped() || chara_disabled || _disable_movement_on_grounded: return

    _manage_jump_particles(false)
    _jumped_position = position

    _force_apply_gravity = false
    _jumping = true
    _jumping_up = true
    jumped.emit()
    can_jump = false
    _just_jumped = 4
    _manage_corner_correction(_jump_velocity, true)
    jump_cooldown_timer.stop()
    jump_cooldown_timer.start()
    coyote_timer.stop()
    jump_buffer_timer.stop()
    if !audio_player.is_queued_for_deletion():

        if side_left:
            audio_player.pitch_scale = randf_range(0.8, 0.9)
        else:
            audio_player.pitch_scale = randf_range(0.65, 0.75)
        audio_player.play()

    _animation_playing = 3
    if side_left:
        animation.play("ascend_l")
    else:
        animation.play("ascend_r")
    _animation_staff_playing = _animation_playing
    animation_staff.play("ascend")



func _big_jump():
    queue_big_jump = false
    _jumping = true
    _jumping_up = true
    can_jump = false
    _jumped_position = position
    _manage_corner_correction(_jump_velocity * 1.5, true)

    jump_cooldown_timer.stop()
    jump_cooldown_timer.start()
    coyote_timer.stop()
    jump_buffer_timer.stop()
    audio_player.pitch_scale = randf_range(0.8, 1.2)

    _animation_playing = 3
    if side_left:
        animation.play("ascend_l")
    else:
        animation.play("ascend_r")
    _animation_staff_playing = _animation_playing
    animation_staff.play("ascend")


func set_chara(side: int):
    if side == -1:
        side_left = true

    if side_left:
        input_strings = ["up_l", "right_l", "left_l"]
        animation.flip_h = true
        animation_staff.flip_h = true
        animation_staff.offset.x = -1
        animation_staff.position.x = 1
        animation.play("idle_l")
        animation_staff.play("idle")
        audio_player_land.pitch_scale = 1.1

        trailer_l.visible = true
    else:
        audio_player_land.pitch_scale = 0.9
        input_strings = ["up_r", "right_r", "left_r"]
        animation.play("idle_r")
        animation_staff.play("idle")
        animation_staff.rotation_degrees = -360

        trailer_r.visible = true



func _on_win_area_entered(area_):
    if win || _disabled_area || _dead: return
    if area_.get_parent() is PlayerChara:

        if side_left:
            _degrees = rad_to_deg(((other_chara.global_position + Vector2(-1, -5)) - (global_position + Vector2(1, -5))).angle()) + 90
        else:
            _degrees = rad_to_deg(((other_chara.global_position + Vector2(1, -5)) - (global_position + Vector2(-1, -5))).angle()) + 90

        raycast_staff.rotation_degrees = _degrees
        var body = raycast_staff.get_hit_body()
        if body != null && body.name == "TileMap":
            _obtacle_preventing_win = true
            _other_area = area_
            return

        win = true

        other_chara.ensure_charas_visually_touch(ensure_charas_visually_touch(0))
        force_staff_to_final_position()
        other_chara.force_staff_to_final_position()

        damage_area.set_immortal(true)

        audio_player.reparent(get_parent().get_parent().get_parent().get_parent())
        audio_player.destroy()
        if side_left:
            disable_reset = true
            _queue_call_next_level = 2
            _queue_call_next_level_physics = 2
        else:
            other_chara.force_win()



func force_win():
    if side_left && !win && !_dead:
        damage_area.set_immortal(true)
        win = true
        disable_reset = true
        _queue_call_next_level = 2
        _queue_call_next_level_physics = 2


func _on_win_area_exited(area_):
    _obtacle_preventing_win = false



func force_staff_to_final_position():
    if _staff_tween && _staff_tween.is_running():
        _staff_tween.custom_step(999)

    if side_left:
        _degrees = rad_to_deg(((other_chara.global_position + Vector2(-1, -5)) - (global_position + Vector2(1, -5))).angle()) + 90
    else:
        _degrees = rad_to_deg(((other_chara.global_position + Vector2(1, -5)) - (global_position + Vector2(-1, -5))).angle()) + 90

    animation_staff.rotation_degrees = _degrees
    animation_staff.play("ascend")


func on_timeout(level_timer: Node):
    disable_reset = true
    _level_timer = level_timer
    if !win:
        audio_player.stop()
        _fail_on_next_frame = 1


func do_failure():
    if !win && !_dead:
        _dead = true
        audio_player.stop()
        if side_left:
            _level_timer.confirm_failure()



func toggle_disable_area(state: bool):
    _disabled_area = state



func get_previous_positions() -> Array[Vector2]:
    return _previous_positions


func is_first_input_emited() -> bool:
    return first_input_emited


func set_dead():
    disable_reset = true
    _dead = true


func is_dead() -> bool:
    return _dead



func on_leave_vertical_moving_platform():
    if _ground_is_vertical_moving_platform > 0:
        _ground_is_vertical_moving_platform -= 1



        if _just_jumped > 0:
            velocity.y = _jump_velocity
        elif !_jumping:
            velocity.y = 0


func queue_ground_is_moving_platform_on_grounded():
    _queue_ground_is_moving_platform_on_grounded += 1



func _manage_corner_correction(velocity_y: float, jump_start: bool):
    if !_jumping_up && !jump_start: return
    velocity_y = abs(velocity_y)

    var raycast_collisions: Array
    raycast_collisions.resize(4)
    raycast_collisions[0] = raycasts[0].get_hit_position()
    raycast_collisions[1] = raycasts[1].get_hit_position()
    raycast_collisions[2] = raycasts[2].get_hit_position()
    raycast_collisions[3] = raycasts[3].get_hit_position()

    var ignore: bool
    if raycast_collisions[1] && raycast_collisions[2]: ignore = true
    elif !raycast_collisions[0] && !raycast_collisions[3]: ignore = true
    elif raycast_collisions[0] && raycast_collisions[3]: ignore = true
    elif abs(velocity.x) > 100: ignore = true

    if abs(velocity.x) >= abs(velocity.y): ignore = true

    if !ignore:
        var distance_to_ceiling: float

        if !raycast_collisions[0]:
            if velocity.x <= 0:
                distance_to_ceiling = global_position.y - 9 - raycast_collisions[3].y
                if distance_to_ceiling < velocity_y / 40:
                    var celing_on_top: bool = true
                    while celing_on_top:
                        global_position.x -= 1
                        if raycasts[3].get_hit_position() == null:
                            celing_on_top = false


        else:
            if velocity.x >= 0:
                distance_to_ceiling = global_position.y - 9 - raycast_collisions[0].y
                if distance_to_ceiling < velocity_y / 40:
                    var celing_on_top: bool = true
                    while celing_on_top:
                        global_position.x += 1
                        if raycasts[0].get_hit_position() == null:
                            celing_on_top = false

    if jump_start:
        velocity.y = - velocity_y


func _is_floor_not_disappeared() -> bool:
    for platform in _floor_previous_frame22:
        if platform == null || platform.is_queued_for_deletion(): continue
        var parent: Node = platform.get_parent()
        if parent.is_in_group("disappearing_platform"):
            if parent.active:
                return true
        else:
            return true

    for platform in _floor_this_frame:
        if platform == null || platform.is_queued_for_deletion(): continue
        var parent: Node = platform.get_parent()
        if parent.is_in_group("disappearing_platform"):
            if parent.active:
                return true
        else:
            return true

    return false


func _play_falling_animation():
    if _animation_playing != 4:
        _animation_playing = 4
        if side_left:
            animation.play("descend_l")
        else:
            animation.play("descend_r")
        _animation_staff_playing = _animation_playing
        animation_staff.play("descend")



func _manage_movement_particles(direction: float):
    if direction == 0 || !grounded:
        movement_particles.emitting = false
    elif direction < 0:
        movement_particles.emitting = true
        movement_particles.position.x = 5
    else:
        movement_particles.emitting = true
        movement_particles.position.x = -5


func _manage_jump_particles(land: bool):
    if _first_landing_particles:
        _first_landing_particles = false
        return

    if !land:

        jump_particles[0].reparent(self)
        jump_particles[1].reparent(self)

        jump_particles[0].position = Vector2(-5, -2)
        jump_particles[1].position = Vector2(5, -2)
        jump_particles[0].reparent(get_parent())
        jump_particles[1].reparent(get_parent())
    else:
        audio_player_land.play()
        jump_particles[0].reparent(self)
        self.move_child(jump_particles[0], 1)
        jump_particles[0].position = Vector2(-6, -2)
        jump_particles[1].reparent(self)
        self.move_child(jump_particles[1], 2)
        jump_particles[1].position = Vector2(6, -2)

    if jump_particles[0].emitting:
        jump_particles[0].restart()
    else:
        jump_particles[0].emitting = true

    if jump_particles[1].emitting:
        jump_particles[1].restart()
    else:
        jump_particles[1].emitting = true


func _get_other_chara():
    if side_left:
        other_chara = Global.player_charas[1]
    else:
        other_chara = Global.player_charas[0]



func fall():
    velocity.y = _fall_gravity



func is_stepping_on_something_else() -> bool:
    var raycast_collisions: Array
    raycast_collisions.resize(2)
    raycast_collisions[0] = raycasts_ground[0].get_hit_position()
    raycast_collisions[1] = raycasts_ground[1].get_hit_position()

    if raycast_collisions[0] == null || raycast_collisions[1] == null:
        return false

    return true


func _landed_on_spikes_ground() -> bool:
    var raycast_collisions: Array
    raycast_collisions.resize(2)
    raycast_collisions[0] = raycasts_spikes_ground[0].get_hit_position()
    raycast_collisions[1] = raycasts_spikes_ground[1].get_hit_position()
    if (raycast_collisions[0] && !raycast_collisions[1]) || ( !raycast_collisions[0] && raycast_collisions[1]):
        return true
    return false


func _manage_stuck_falling():
    var raycast_collisions: Array
    var stuck: bool = true
    var extra_stuck: bool = true
    var control: int
    var stucked_at_some_point: bool

    while stuck && control < 5:
        stuck = false
        control += 1
        raycast_collisions.resize(2)
        raycasts_ground[0].position.x -= 1
        raycasts_ground[1].position.x += 1
        raycast_collisions[0] = raycasts_ground[0].get_hit_position()
        raycast_collisions[1] = raycasts_ground[1].get_hit_position()
        raycasts_ground[0].position.x += 1
        raycasts_ground[1].position.x -= 1
        if raycast_collisions[0] && !raycast_collisions[1]:
            position.x += 1
            if extra_stuck: position.x += 1
            stuck = true
            stucked_at_some_point = true
        elif raycast_collisions[1] && !raycast_collisions[0]:
            position.x -= 1
            if extra_stuck: position.x -= 1
            stuck = true
            stucked_at_some_point = true
        elif raycast_collisions[0] && raycast_collisions[1]:
            stuck = false
            stucked_at_some_point = true

            raycasts_ground[0].position.x -= 1
            var body: Node = raycasts_ground[0].get_hit_body()
            raycasts_ground[0].position.x += 1
            if body && body.get_parent().is_in_group("directional_block"):
                body.get_parent().move_back(true)
            else:
                raycasts_ground[1].position.x -= 1
                body = raycasts_ground[1].get_hit_body()
                raycasts_ground[1].position.x += 1
                if body && body.get_parent().is_in_group("directional_block"):
                    body.get_parent().move_back(false)


            raycast_collisions[0] = raycasts_spikes_ground[0].get_hit_position()
            raycast_collisions[1] = raycasts_spikes_ground[1].get_hit_position()
            if raycast_collisions[0]:
                position.x += 1
            elif raycast_collisions[1]:
                position.x -= 1
        elif !raycast_collisions[0] && !raycast_collisions[1]:

            stuck = true
            extra_stuck = true
            raycasts_ground[0].position.x = -5
            raycasts_ground[0].rotation_degrees = 70
            raycasts_ground[0].target_position.y = 6
            raycasts_ground[1].position.x = 5
            raycasts_ground[1].rotation_degrees = -70
            raycasts_ground[1].target_position.y = 6


            raycast_collisions.resize(4)
            for i in raycasts_side.size():
                raycast_collisions[i] = raycasts_side[i].get_hit_position()
                if raycast_collisions[i]:
                    var body = raycasts_side[i].get_hit_body()
                    if body.get_parent().is_in_group("directional_block"):
                        if i < 2:
                            body.get_parent().move_back(true)
                        else:
                            body.get_parent().move_back(false)

    raycasts_ground[0].position.x = -6
    raycasts_ground[0].rotation_degrees = 0
    raycasts_ground[0].target_position.y = 3
    raycasts_ground[1].position.x = 6
    raycasts_ground[1].rotation_degrees = 0
    raycasts_ground[1].target_position.y = 3

    if stucked_at_some_point:
        position.y -= 1



func is_grounded() -> bool:
    if grounded && !_jumping:
        return true
    return false


func is_falling() -> bool:
    if !grounded && !_jumping_up:
        return true
    return false



func set_force_apply_gravity(value: bool):
    if _just_jumped > 0: value = false
    _force_apply_gravity = value


func set_disable_movement_on_grounded(state: bool):
    _disable_movement_on_grounded = state


func _do_disable_movement_on_grounded():
    _disable_movement_on_grounded = false
    chara_disabled = true
    _animation_playing = 0
    if side_left:
        animation.play("idle_l")
    else:
        animation.play("idle_r")
    _animation_staff_playing = _animation_playing
    animation_staff.play("idle")


func set_immortal(state: bool):
    damage_area.set_immortal(state)


func set_static_staff():
    _static_staff = true



func force_die():
    damage_area.die(null)


func _manage_move_staff():

    if !_static_staff:
        if side_left:
            _distance = (global_position + Vector2(1, -5)).distance_to(other_chara.global_position + Vector2(-1, -5))
        else:
            _distance = (global_position + Vector2(-1, -5)).distance_to(other_chara.global_position + Vector2(1, -5))

        if _distance < 40:
            if side_left:
                _degrees = rad_to_deg(((other_chara.global_position + Vector2(-1, -5)) - (global_position + Vector2(1, -5))).angle()) + 90
            else:
                _degrees = rad_to_deg(((other_chara.global_position + Vector2(1, -5)) - (global_position + Vector2(-1, -5))).angle()) + 90

            if _degrees > 180: _degrees -= 360
            elif _degrees < -180: _degrees += 360
            if !side_left:
                _degrees = -360 + _degrees


            if _staff_rotated && _animation_staff_playing not in [3, 4]:
                _animation_staff_playing = 3
                animation_staff.play("ascend")

            if !_staff_rotated:

                if _distance > 25:
                    raycast_staff.rotation_degrees = _degrees
                    if raycast_staff.get_hit_position() != null:
                        return

                _staff_rotated = true

                if _staff_tween && _staff_tween.is_running():
                    _staff_tween.custom_step(999)
                _staff_tween = create_tween()
                _staff_tween.tween_property(animation_staff, "rotation_degrees", _degrees, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
            elif _staff_rotated && !_staff_tween.is_running():
                animation_staff.rotation_degrees = _degrees
        else:
            _animation_staff_playing = _animation_playing
            match _animation_playing:
                0:
                    animation_staff.play("idle")
                1, 2:
                    animation_staff.play("walking")
                3:
                    animation_staff.play("ascend")
                4:
                    animation_staff.play("descend")


            if _staff_rotated:
                _staff_rotated = false
                if _staff_tween && _staff_tween.is_running():
                    _staff_tween.custom_step(999)
                _staff_tween = create_tween()
                if side_left:
                    _degrees = 0
                else:
                    _degrees = -360
                _staff_tween.tween_property(animation_staff, "rotation_degrees", _degrees, 0.05).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func ensure_charas_visually_touch(received_distance: float) -> float:
    var distance: float
    if received_distance > 0:
        distance = received_distance
    else:
        if side_left:
            distance = (global_position + Vector2(1, -5)).distance_to(other_chara.global_position + Vector2(-1, -5))
        else:
            distance = (global_position + Vector2(-1, -5)).distance_to(other_chara.global_position + Vector2(1, -5))

    var max_distance: float = 22



    if distance > max_distance:
        var vector: Vector2
        if side_left:
            vector = (other_chara.global_position + Vector2(-1, -5)) - (global_position + Vector2(1, -5))
        else:
            vector = (other_chara.global_position + Vector2(1, -5)) - (global_position + Vector2(-1, -5))
        vector = vector.normalized()
        global_position += vector * ((distance - max_distance) * 0.5)

    _previous_positions[1] = position

    return distance


func get_just_jumped() -> int:
    return _just_jumped
