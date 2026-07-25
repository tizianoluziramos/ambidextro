extends Area2D

@export var player: CharacterBody2D
@export var sprite: AnimatedSprite2D
@export var sprite_staff: AnimatedSprite2D
@export var audio: AudioStreamPlayer2D


var shader_material: ShaderMaterial = preload("res://shaders/colorize/colorize_material.tres")
const _DEATH_COOLDOWN: float = 0.2

var _immortal: bool

func _ready() -> void :
    body_entered.connect(die, 4)


func die(_body: Node2D):

    if _immortal: return
    if player.is_dead(): return

    audio.play()
    get_tree().paused = true

    for player_chara in Global.player_charas:
        player_chara.audio_player.stop()
        player_chara.set_dead()

    sprite.material = shader_material
    sprite.material.set_shader_parameter("color", Color.RED)
    sprite_staff.material = shader_material
    sprite_staff.material.set_shader_parameter("color", Color.RED)

    var timer: SceneTreeTimer = get_tree().create_timer(_DEATH_COOLDOWN)
    timer.timeout.connect(_reset)


func _reset():
    var level_loaders: = get_tree().get_nodes_in_group("level_loader")
    level_loaders[0].reset_level(false)


func set_immortal(state: bool):
    _immortal = state
