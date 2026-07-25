extends RayCast2D

@export var block: Node

var _mode: int = 1
var _timer: SceneTreeTimer
var _reset: bool

var _collision_point_y: float
var _last_distance: float

func _ready():
    _timer = get_tree().create_timer(0.1)
    _timer.timeout.connect(reset_mask)


func _physics_process(_delta: float) -> void :
    if _reset:
        _do_reset_mask()
        return

    if get_collider():
        match _mode:

            1:
                if get_collider().get_parent().is_in_group("player_chara"):
                    _manager_player_collision()


            2:
                _collision_point_y = get_collision_point().y
                _manage_stage_collision(get_collision_point())

    if _mode == 3:

        _manage_distance()


func _manager_player_collision():

    set_collision_mask_value(4, false)
    set_collision_mask_value(1, true)
    _mode = 2


func _manage_stage_collision(point: Vector2):

    set_collision_mask_value(1, false)
    $"..".move_to_ground(point, false)
    _mode = 3


func reset_mask():
    _reset = true

func _do_reset_mask():
    _reset = false


    set_collision_mask_value(1, true)
    set_collision_mask_value(4, true)
    _mode = 1


func _manage_distance():

    if _collision_point_y - block.global_position.y < 33:
        if _last_distance > _collision_point_y - block.global_position.y:
            _mode = 4
            return
        _last_distance = _collision_point_y - block.global_position.y
        $"..".enable_lateral_barriers()
