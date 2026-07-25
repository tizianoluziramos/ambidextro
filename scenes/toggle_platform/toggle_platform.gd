extends Node2D

@export var left: bool = true
@export var toggle_count: int = 1
@export var platform_sprite: Sprite2D
@export var collision: CollisionShape2D
@export var audio_player: AudioStreamPlayer2D

var active: bool
var already_mirrored: bool

const _PATH_OPENING: String = "res://scenes/toggle_platform/"
const _PATH_ENDING: String = ".tscn"

func _ready() -> void :
    add_to_group("disappearing_platform")
    if !left: audio_player.pitch_scale = 0.8

    _deactivate()
    _initialize.call_deferred()


func _initialize():

    Global.current_level_layout.called_mirror_or_swap.connect(_manage_remirror)
    if !already_mirrored:
        if _manage_mirror(): return


    var players = get_tree().get_nodes_in_group("player_chara")
    if players.size() < 2:
        _ready.call_deferred()
        return

    for player in players:
        if player.side_left == left:
            player.jumped.connect(_activate)
        else:
            player.jumped.connect(_deactivate)


func _manage_mirror() -> bool:
    if (Global.current_level_layout.mirrored && !Global.current_level_layout.toggles_souldnt_swap_on_mirror) || (Global.current_level_layout.swapped && Global.current_level_layout.toggles_should_swap_on_chara_swap):
        if (Global.current_level_layout.mirrored && !Global.current_level_layout.toggles_souldnt_swap_on_mirror) && (Global.current_level_layout.swapped && Global.current_level_layout.toggles_should_swap_on_chara_swap):

            pass
        else:
            _mirror(true)
            return true
    return false


func _manage_remirror():
    var should_be_mirrored: bool
    var should_be_swapped: bool
    var do_mirror: bool

    if Global.current_level_layout.mirrored && !Global.current_level_layout.toggles_souldnt_swap_on_mirror:
        should_be_mirrored = true
    if Global.current_level_layout.swapped && Global.current_level_layout.toggles_should_swap_on_chara_swap:
        should_be_swapped = true

    if (should_be_mirrored && !should_be_swapped) || ( !should_be_mirrored && should_be_swapped):
        do_mirror = true

    if do_mirror && already_mirrored:
        return
    elif do_mirror && !already_mirrored:
        _mirror(true)
    elif !do_mirror && already_mirrored:
        _mirror(false)


func _activate():
    if !active: audio_player.play()

    active = true
    collision.disabled = false
    platform_sprite.self_modulate.a = 1


func _deactivate():
    active = false
    collision.disabled = true
    platform_sprite.self_modulate.a = 0.5


func _mirror(set_already_mirrored: bool):
    var scene_name: String
    if left:
        scene_name = "toggle_platform_r"
    else:
        scene_name = "toggle_platform_l"
    var toggle_platform_resource = load(_PATH_OPENING + scene_name + _PATH_ENDING)

    var node: Node2D = toggle_platform_resource.instantiate()
    if set_already_mirrored:
        node.already_mirrored = true
    get_parent().add_child(node)
    node.global_position = global_position

    queue_free()
