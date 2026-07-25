extends Node2D
class_name PlayerSpawnPoint

enum Side{Left, Right}
@export var side: Side
@export var preview_mode: bool

@export var player_chara: PackedScene
@export var static_staff: bool

var is_player_created: bool
signal player_created

func _ready() -> void :
    add_to_group("spawner")

    var instance = player_chara.instantiate()
    var side_int: int = -1 if side == Side.Left else 1
    instance.set_chara.call_deferred(side_int)
    self.add_child(instance)
    instance.global_position = global_position
    if preview_mode: instance.chara_disabled = true

    if side_int == -1:
        Global.player_charas[0] = instance
    else:
        Global.player_charas[1] = instance

    if static_staff:
        instance.set_static_staff()

    _emit_player_created.call_deferred(instance)



func _emit_player_created(instance):
    player_created.emit(instance)
    is_player_created = true


func mirror():
    scale.x = -1

func unmirror():
    scale.x = 1
