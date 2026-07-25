extends Camera2D

@export var scrolling_level: Node
@export var player_spawn_point: Node
@export var other_camera: Camera2D
@export var level_layout: Node
@export var left: bool

var _player: CharacterBody2D
var _tower_reached: bool

var initial_pos_x: float
var _tween: Tween
var _horizontal_duration: float = 4
var _tween_2: Tween
var _vertical_duration: float = 35
var _tower_centered: bool
var _tween_3: Tween
var _towards_sky_duration: float = 4
var _way_behind: bool
var _tween_offset: Tween
var _final_pos: int = 1717

var _music_index: int

var _offset: int

var _mirror: bool

func _ready() -> void :
    player_spawn_point.player_created.connect(get_player_reference)


func _process(_delta: float) -> void :
    if !_player: return

    _manage_music()

    if !_tower_reached:
        if !other_camera.is_tower_reached() && (_way_behind || abs(global_position.x - initial_pos_x) < abs(other_camera.global_position.x - other_camera.initial_pos_x) - 300):
            if left:
                if _player.global_position.x > global_position.x:
                    _way_behind = false
                    global_position.x = _player.global_position.x
                else:
                    _way_behind = true
                    global_position.x = (other_camera.global_position.x * -1) - 300
            else:
                if _player.global_position.x < global_position.x:
                    _way_behind = false
                    global_position.x = _player.global_position.x
                else:
                    _way_behind = true
                    global_position.x = (other_camera.global_position.x * -1) + 300
        else:
            global_position.x = _player.global_position.x

        if position.x >= 1514 || position.x <= -1514:
            _on_tower_reached()



func get_player_reference(instance):
    _player = instance

    global_position.x = _player.global_position.x
    initial_pos_x = global_position.x


func _on_tower_reached():
    level_layout.stop_timer()
    level_layout.fade_timer()
    if position.x < 0: _final_pos *= -1
    _tower_reached = true

    _tween = create_tween()
    _tween.tween_property(self, "position:x", _final_pos, _horizontal_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    _tween.finished.connect(on_tower_centered, 4)

    _tween_offset = create_tween()
    _tween_offset.tween_property(self, "offset:x", _offset, _horizontal_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

    scrolling_level.change_music_layer(5)



func on_tower_centered():
    if _tower_centered: return
    _tower_centered = true
    other_camera.on_tower_centered()
    _tween_2 = create_tween()
    _tween_2.tween_property(self, "position:y", -795, _vertical_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)



func activate_ending():
    _tween_3 = create_tween()
    _tween_3.tween_property(self, "position:y", -1180, _towards_sky_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    _tween_3.finished.connect(_activate_credits, 4)

    level_layout.change_number_colors_for_end_credits()



func activate_credits_music():
    scrolling_level.change_music_layer(7)


func _activate_credits():
    scrolling_level.load_end_credits()



func update_offset(extra_wide: int):
    _offset = extra_wide

    if _tower_reached:
        if _tween_offset && _tween_offset.is_running():
            _tween_offset.custom_step(999)

        offset.x = _offset


func is_tower_reached():
    return _tower_reached



func disconnect_player_created():
    _mirror = true
    if player_spawn_point && player_spawn_point.player_created.is_connected(get_player_reference):
        player_spawn_point.player_created.disconnect(get_player_reference)


func _manage_music():
    var _previous_music_index: int = _music_index
    if left:
        if position.x > (240 + 200) && _music_index < 2:
            _music_index = 2
        elif position.x > (280 * 2 + 200) && _music_index < 3:
            _music_index = 3
        elif position.x > (300 * 3 + 200) && _music_index < 4:
            _music_index = 4
        elif position.y < -20 && _music_index < 6:
            _music_index = 6
        else:
            _music_index = 1
    else:
        if position.x < (-240 - 200) && _music_index < 2:
            _music_index = 2
        elif position.x < (-280 * 2 - 200) && _music_index < 3:
            _music_index = 3
        elif position.x < (-300 * 3 - 200) && _music_index < 4:
            _music_index = 4
        else:
            _music_index = 1

    if _previous_music_index != _music_index:
        scrolling_level.change_music_layer(_music_index)
