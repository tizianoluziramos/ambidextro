extends Node2D

@export var emblem: int = 1

@export_category("References")
@export var sprites: Array[AtlasTexture]
@export var sprite: Sprite2D
@export var emblems: Array[AtlasTexture]
@export var emblem_sprite: Sprite2D
@export var audio_player: AudioStreamPlayer2D
@export var audio_player_2: AudioStreamPlayer2D

var _body_count: int
var _activable_nodes: Array[Node]
var _pressed: bool


func _ready() -> void :
    emblem_sprite.texture = emblems[emblem - 1]

    if rotation > 0:
        emblem_sprite.rotation_degrees = -90
    elif rotation < 0:
        emblem_sprite.rotation_degrees = 90
        sprite.flip_h = true

    if scale.y == -1:
        emblem_sprite.scale.x = -1


func _on_area_2d_body_entered(body: Node2D) -> void :
    if !body is PlayerChara && !body is box: return
    _body_count += 1
    if _pressed: return

    _pressed = true
    _get_activable_nodes()
    sprite.texture = sprites[1]

    audio_player.play()

    for activable_node in _activable_nodes:
        if activable_node.emblem == emblem:
            activable_node.activate()


func _on_area_2d_body_exited(body: Node2D) -> void :
    if !body is PlayerChara && !body is box: return
    _body_count -= 1
    if _body_count > 0: return

    _pressed = false
    _get_activable_nodes()
    sprite.texture = sprites[0]

    if !audio_player_2.is_inside_tree(): return
    audio_player_2.play()

    for activable_node in _activable_nodes:
        if activable_node.emblem == emblem:
            activable_node.deactivate()


func _get_activable_nodes():
    if _activable_nodes.size() > 0:
        return
    _activable_nodes = get_tree().get_nodes_in_group("activable")
