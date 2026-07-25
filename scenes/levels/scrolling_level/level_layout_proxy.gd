extends Node

@export var scrolling_level: Node
@export var level_layout: Node
@export var level_layout_l: Node
@export var level_layout_r: Node
@export var subviewport_l: Node
@export var subviewport_r: Node
@export var camera_l: Camera2D
@export var camera_r: Camera2D
@export var lariat_l: Node
@export var lariat_r: Node
@export var player_spawn_l: Node
@export var player_spawn_r: Node


func set_preview():
    level_layout.set_preview()
    level_layout_l.set_preview()
    level_layout_r.set_preview()
    camera_l.zoom = Vector2(2, 2)
    camera_r.zoom = Vector2(2, 2)


func update_level_label(text: String):
    level_layout.update_level_label(text)

func update_retry_label(text: String):
    level_layout.update_retry_label(text)

func get_original_quantum_cubes_states() -> Array:
    var cubes_states: Array
    return cubes_states

func initialize_quantum_cubes(previous_cubes_states) -> Array:
    var cubes_states: Array
    return cubes_states

func change_quantum_cubes_positions(_indexes: Array[int], previous_quantum_cubes_positions: Array[Vector2]):
    level_layout.change_quantum_cubes_positions(_indexes, previous_quantum_cubes_positions)


func mirror():
    scrolling_level.mirror = true
    scrolling_level.cancel_reparent = true
    level_layout_l.reparent(subviewport_r)
    level_layout_r.reparent(subviewport_l)


    if level_layout_l.scale.x > 0:
        level_layout_l.scale.x = level_layout_l.scale.x * -1
        level_layout_r.scale.x = level_layout_r.scale.x * -1

    var position1 = level_layout_l.global_position
    level_layout_l.global_position = level_layout_r.global_position
    level_layout_r.global_position = position1

    camera_l.left = false
    camera_r.left = true
    subviewport_l.get_parent().scrolling_camera = camera_r
    subviewport_r.get_parent().scrolling_camera = camera_l

    lariat_l.mirror = true
    lariat_r.mirror = true
    lariat_l.set_spawn(player_spawn_r)
    lariat_r.set_spawn(player_spawn_l)

    _swap_spawners.call_deferred(true)


func unmirror():
    scrolling_level.mirror = false
    scrolling_level.cancel_reparent = true


    if level_layout_l.scale.x < 0:
        level_layout_l.scale.x = level_layout_l.scale.x * -1
        level_layout_r.scale.x = level_layout_r.scale.x * -1

    level_layout_l.reparent(subviewport_l)
    level_layout_r.reparent(subviewport_r)

    var position1 = level_layout_l.global_position
    level_layout_l.global_position = level_layout_r.global_position
    level_layout_r.global_position = position1

    camera_l.left = true
    camera_r.left = false
    subviewport_l.get_parent().scrolling_camera = camera_l
    subviewport_r.get_parent().scrolling_camera = camera_r

    _swap_spawners.call_deferred(true)


func _swap_spawners(mirror: bool):
    var spawners: Array[Node2D]
    var children: Array[Node]
    children = level_layout_l.get_children()
    for child in children:
        if child.is_in_group("spawner"):
            spawners.append(child)
            break

    children = level_layout_r.get_children()
    for child in children:
        if child.is_in_group("spawner"):
            spawners.append(child)
            break

    var position1 = spawners[0].global_position
    var parent1: Node = spawners[0].get_parent()
    spawners[0].reparent(spawners[1].get_parent())
    spawners[1].reparent(parent1)
    spawners[0].global_position = spawners[1].global_position
    spawners[1].global_position = position1

    camera_l.disconnect_player_created()
    camera_r.disconnect_player_created()

    if spawners[0].is_player_created:
        var child: = spawners[0].get_child(0)
        if !child.is_in_group("player_chara"):
            child = spawners[0].get_child(1)
        camera_r.get_player_reference(child)
    else:
        if spawners[0].player_created.is_connected(camera_r.get_player_reference):
            spawners[0].player_created.disconnect(camera_r.get_player_reference)
        if spawners[1].player_created.is_connected(camera_r.get_player_reference):
            spawners[1].player_created.disconnect(camera_r.get_player_reference)
        spawners[0].player_created.connect(camera_r.get_player_reference)

    if spawners[1].is_player_created:
        var child: = spawners[1].get_child(0)
        if !child.is_in_group("player_chara"):
            child = spawners[1].get_child(1)
        camera_l.get_player_reference(child)
    else:
        if spawners[1].player_created.is_connected(camera_l.get_player_reference):
            spawners[1].player_created.disconnect(camera_l.get_player_reference)
        if spawners[0].player_created.is_connected(camera_l.get_player_reference):
            spawners[0].player_created.disconnect(camera_l.get_player_reference)
        spawners[1].player_created.connect(camera_l.get_player_reference)

    if mirror:
        spawners[0].mirror()
        spawners[1].mirror()



func swap():
    _swap_spawners.call_deferred(false)

func unswap():
    swap()


func set_timer():
    level_layout.set_timer()
