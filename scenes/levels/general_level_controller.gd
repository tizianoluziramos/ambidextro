extends Node2D


@export var time: float
@export var timer: Node2D

@export var level_numbers: Array[Sprite2D]
@export var retry_numbers: Array[Sprite2D]
@export var level_other_numbers: Array[Sprite2D]
@export var retry_icon: Sprite2D

@export var level_counter_color_rects: Array[ColorRect]
@export var retry_counter_color_rects: Array[ColorRect]

@export var forest_color_1: Color
@export var forest_color_2: Color
@export var forest_color_3: Color

@export var hide_tiles: bool
@export var hide_UI: bool
@export var forest_colors: bool

@export var timer_bar: Node2D
@export var speedrun_timer: Node2D

@export var quantum_managers: Array[Node]
@export var level_layout: Node
@export var level_layout_preview: Node
@export var UI: Node

@export var charas_souldnt_swap_on_mirror: bool
@export var toggles_souldnt_swap_on_mirror: bool
@export var toggles_should_swap_on_chara_swap: bool
@export var disable_timer: bool

var _tween: Tween
var _tween2: Tween

var preview: bool
var mirrored: bool
var swapped: bool

signal called_mirror_or_swap


func _ready() -> void :
    add_to_group("level_layout")
    set_timer()

    if hide_tiles:
        level_layout.visible = false
        level_layout.collision_enabled = false

        if forest_colors: _set_forest_colors()

    if hide_UI:
        UI.visible = false


func initialize_quantum_cubes(previous_cubes_states) -> Array:
    var cubes_states: Array
    for i in quantum_managers.size():
        cubes_states.append(quantum_managers[i].initialize(previous_cubes_states[i]))

    return cubes_states


func get_original_quantum_cubes_states() -> Array:
    var cubes_states: Array
    for i in quantum_managers.size():
        cubes_states.append(quantum_managers[i].get_cubes_states())
    return cubes_states


func set_preview():
    preview = true
    level_layout.visible = false
    level_layout_preview.visible = true
    UI.visible = false

    var children: Array[Node] = get_children()
    for child in children:
        if child is PlayerSpawnPoint:
            child.preview_mode = true
            var children2: Array[Node] = child.get_children()
            for child2 in children2:
                if child2 is PlayerChara:
                    child2.preview_mode = true


func update_level_label(text: String):
    level_numbers[0].texture = timer.numbers_font[int(text[0])]
    level_numbers[1].texture = timer.numbers_font[int(text[1])]
    level_numbers[2].texture = timer.numbers_font[int(text[2])]

func update_retry_label(text: String):
    retry_numbers[0].texture = timer.numbers_font[int(text[0])]
    retry_numbers[1].texture = timer.numbers_font[int(text[1])]
    retry_numbers[2].texture = timer.numbers_font[int(text[2])]
    retry_numbers[3].texture = timer.numbers_font[int(text[3])]
    retry_numbers[4].texture = timer.numbers_font[int(text[4])]


func stop_timer():
    timer.stop_timer()


func fade_timer():
    _tween = create_tween()
    _tween.tween_property(timer_bar, "modulate", Color.TRANSPARENT, 1)


func _set_forest_colors():
    level_counter_color_rects[0].color = Color.TRANSPARENT
    level_counter_color_rects[1].color = Color.TRANSPARENT
    retry_counter_color_rects[0].color = forest_color_1
    retry_counter_color_rects[1].color = forest_color_2

    for number in level_numbers:
        number.modulate = Color.TRANSPARENT

    for number in level_other_numbers:
        number.modulate = Color.TRANSPARENT

    for number in retry_numbers:
        number.modulate = forest_color_1

    retry_icon.modulate = forest_color_1


func change_number_colors_for_end_credits():
    var duration: float = 1
    _tween2 = create_tween()
    _tween2.set_parallel(true)
    _tween2.tween_property(retry_counter_color_rects[0], "color", Color.TRANSPARENT, duration)
    _tween2.tween_property(retry_counter_color_rects[1], "color", Color.TRANSPARENT, duration)
    _tween2.tween_property(retry_icon, "modulate", Color.WHITE, duration)
    _tween2.tween_property(retry_icon, "modulate", Color.WHITE, duration)

    for number in retry_numbers:
        _tween2.tween_property(number, "modulate", Color.WHITE, duration)
        _tween2.tween_property(number, "modulate", Color.WHITE, duration)

    retry_icon.self_modulate = Color.WHITE

    speedrun_timer.change_number_colors_for_end_credits()


func set_timer():
    if !timer: return
    if disable_timer:
        timer.disable_timer = true
    else:
        timer.initialize(time, time * (1.0 + Global.extra_time / 100.0))


func mirror():
    mirrored = true
    get_parent().scale.x = -1
    UI.scale.x = -1

    if !charas_souldnt_swap_on_mirror:
        _swap_spawners.call_deferred(true)
    else:
        _mirror_spawners.call_deferred()

    called_mirror_or_swap.emit()


func unmirror():
    mirrored = false
    get_parent().scale.x = 1
    UI.scale.x = 1

    if !charas_souldnt_swap_on_mirror:
        _unswap_spawners.call_deferred(true)
    else:
        _unmirror_spawners.call_deferred()

    called_mirror_or_swap.emit()


func _swap_spawners(mirror_: bool):
    var spawners: Array[Node2D]
    var children: = get_children()
    for child in children:
        if child.is_in_group("spawner"):
            spawners.append(child)
            if spawners.size() == 2:
                break

    var position1 = spawners[0].position
    spawners[0].position = spawners[1].position
    spawners[1].position = position1

    if mirror_:
        spawners[0].mirror()
        spawners[1].mirror()


func _unswap_spawners(mirror_: bool):
    var spawners: Array[Node2D]
    var children: = get_children()
    for child in children:
        if child.is_in_group("spawner"):
            spawners.append(child)
            if spawners.size() == 2:
                break

    var position1 = spawners[0].position
    spawners[0].position = spawners[1].position
    spawners[1].position = position1

    if mirror_:
        spawners[0].unmirror()
        spawners[1].unmirror()



func _mirror_spawners():
    var spawners: Array[Node2D]
    var children: = get_children()
    for child in children:
        if child.is_in_group("spawner"):
            spawners.append(child)
            if spawners.size() == 2:
                break
    spawners[0].mirror()
    spawners[1].mirror()


func _unmirror_spawners():
    var spawners: Array[Node2D]
    var children: = get_children()
    for child in children:
        if child.is_in_group("spawner"):
            spawners.append(child)
            if spawners.size() == 2:
                break
    spawners[0].unmirror()
    spawners[1].unmirror()


func swap():
    swapped = true
    _swap_spawners.call_deferred(false)
    called_mirror_or_swap.emit()


func unswap():
    swapped = false
    _unswap_spawners.call_deferred(false)
    called_mirror_or_swap.emit()
