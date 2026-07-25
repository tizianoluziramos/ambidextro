extends Node2D


@export var audio: AudioStreamPlayer2D
@export var particles_l: CPUParticles2D
@export var particles_r: CPUParticles2D

var _children: Array[Node]
var _player_charas: Array[Node]

var _activate: bool
var _activated: bool
var _call_reactivate_areas: bool

func _ready():
    _children = get_children()
    _children.remove_at(0)
    _set_particles()


func _set_particles():
    var size_y: float
    size_y = (_children[_children.size() - 1].position.y + 16) / 2.0
    particles_l.position.y = size_y
    particles_r.position.y = size_y
    particles_l.emission_rect_extents.y = size_y
    particles_r.emission_rect_extents.y = size_y


func _physics_process(_delta: float) -> void :
    if _activate && !_activated:
        _activated = true
        _player_charas = get_tree().get_nodes_in_group("player_chara")
        var pos0: Vector2 = _player_charas[0].global_position
        var pos1: Vector2 = _player_charas[1].global_position
        if _player_charas[0].win || _player_charas[1].win:
            return
        _player_charas[0].toggle_disable_area(true)
        _player_charas[1].toggle_disable_area(true)
        _player_charas[0].global_position = Vector2(-999, -999)
        _player_charas[1].global_position = Vector2(999, 999)
        _player_charas[0].global_position = pos1
        _player_charas[1].global_position = pos0
        _call_reactivate_areas = true

        for i in _children.size():
            _children[i].queue_free()

        particles_l.emitting = true
        particles_r.emitting = true

    elif _call_reactivate_areas:
        _call_reactivate_areas = false
        reactivate_areas()


func reactivate_areas():
    _player_charas[0].toggle_disable_area(false)
    _player_charas[1].toggle_disable_area(false)


func activate():
    if _activated || _activate: return
    _activate = true
    audio.play()
