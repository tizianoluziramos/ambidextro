extends Node2D

@export var menu_loader: Node
@export var level_l: Node
@export var level_r: Node
@export var subviewport_l: Node
@export var subviewport_r: Node
@export var subviewport_container_l: Node
@export var subviewport_container_r: Node

@export var player_spawners: Array[Node]
@export var cameras: Array[Node]
@export var heirs: Array[Node]
@export var stars_blockers: Array[Node]

@export var level_layout: Node

var mirror: bool
var _end_credits_loaded: bool
var _timer_faded: bool
var _music_index: int

var cancel_reparent: bool

var _cheat: int = 1

func _ready() -> void :
    if !cancel_reparent:
        level_l.reparent(subviewport_container_l)
        level_r.reparent(subviewport_container_r)
    level_l.visible = true
    level_r.visible = true
    subviewport_l.visible = true
    subviewport_r.visible = true


func _input(event: InputEvent) -> void :
    if Global.allow_debug_controls:

        if Input.is_action_just_pressed("cheat"):
            if _cheat == 0:
                cameras[0].position = Vector2(1717, 0)
                cameras[1].position = Vector2(-1717, 0)
                cameras[0].on_tower_centered()
                cameras[1].on_tower_centered()
                cameras[0]._tower_reached = true
                cameras[0]._tower_centered = true
                cameras[1]._tower_reached = true
                cameras[1]._tower_centered = true
                level_layout.stop_timer()
                level_layout.fade_timer()

                if mirror:
                    player_spawners[1].get_child(1).global_position = Vector2(-1676, 80)
                    player_spawners[0].get_child(1).global_position = Vector2(1676, 80)
                else:
                    player_spawners[0].get_child(1).global_position = Vector2(1676, 80)
                    player_spawners[1].get_child(1).global_position = Vector2(-1676, 80)
            else:
                cameras[0]._tower_reached = true
                cameras[0]._tower_centered = true
                cameras[1]._tower_reached = true
                cameras[1]._tower_centered = true
                level_layout.stop_timer()
                level_layout.fade_timer()

                if mirror:
                    player_spawners[1].get_child(1).global_position = heirs[0].global_position
                    player_spawners[0].get_child(1).global_position = heirs[1].global_position
                else:
                    player_spawners[0].get_child(1).global_position = heirs[0].global_position
                    player_spawners[1].get_child(1).global_position = heirs[1].global_position

                cameras[0].position = Vector2(1717, -795)
                cameras[1].position = Vector2(-1717, -795)



func load_end_credits():
    if _end_credits_loaded: return

    for i in stars_blockers.size():
        stars_blockers[i].fade_in()

    _end_credits_loaded = true
    menu_loader.load_end_credits()



func change_music_layer(index: int):
    if index <= _music_index: return
    if index == 1:
        _music_index = 1
        return
    _music_index = index
    menu_loader.music_controller.change_to_layer(index)
