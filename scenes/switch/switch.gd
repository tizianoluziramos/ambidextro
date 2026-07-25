extends Node2D


@export var emblem: int = 1

@export_category("references")

@export var emblems: Array[AtlasTexture]
@export var disabled_emblems: Array[AtlasTexture]
@export var emblem_sprite: Sprite2D
@export var audio_player: AudioStreamPlayer2D

var _active: bool

func _ready() -> void :
    Global.first_input.connect(_set_active, 4)
    emblem_sprite.texture = emblems[emblem - 1]


func _set_active():
    _active = true


func _on_area_2d_body_entered(body: Node2D) -> void :
    if !_active: return
    if body is PlayerChara:
        _active = false
        var activable_nodes: = get_tree().get_nodes_in_group("activable")
        emblem_sprite.texture = disabled_emblems[emblem - 1]

        audio_player.play()

        for activable_node in activable_nodes:
            if activable_node.emblem == emblem:
                activable_node.activate()
