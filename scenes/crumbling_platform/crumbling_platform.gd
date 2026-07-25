class_name crumbling_platform
extends Node2D

@export var sprite: Sprite2D
@export var sprites: Array[Texture2D]
@export var sprites_forest: Array[Texture2D]
@export var particles: CPUParticles2D
@export var particles_forest: CPUParticles2D
@export var audio: AudioStreamPlayer2D
@export var gas_sound: AudioStream
@export var forest: bool
@export var area: Area2D
@export var timer: Timer
@export var timer2: Timer
@export var timer3: Timer

var crumbling: bool
var active: bool = true
var body_being_tracked: Node

func _ready() -> void :
    add_to_group("disappearing_platform")
    area.body_entered.connect(_start_crumbling)
    area.body_exited.connect(_stop_tracking)

    if forest:
        sprite.texture = sprites_forest[0]


func _physics_process(delta: float) -> void :
    if body_being_tracked && body_being_tracked.global_position.y <= global_position.y - 1 && (body_being_tracked.get_just_jumped() >= 3 || body_being_tracked.is_grounded() || body_being_tracked.is_falling() || body_being_tracked.velocity.y == 0):
        crumble()


func _start_crumbling(body):
    var parent: Node = body.get_parent()
    if parent is PlayerChara && !crumbling:

        if parent.global_position.y <= global_position.y - 1 && (parent.get_just_jumped() >= 3 || parent.is_grounded() || parent.is_falling() || parent.velocity.y == 0):
            crumble()

        else:
            body_being_tracked = parent
            return
    elif body is box && !crumbling:
        crumble()



func crumble():
    if crumbling: return
    body_being_tracked = null
    audio.pitch_scale = randf_range(0.9, 1.1)
    if forest:
        audio.stream = gas_sound
    audio.play()

    crumbling = true
    timer.start()
    timer.timeout.connect(destroy)
    if forest:
        particles_forest.emitting = true
    else:
        particles.emitting = true

    timer2.start()
    timer2.timeout.connect(_change_sprite_1)

    timer3.start()
    timer3.timeout.connect(_change_sprite_2)


func destroy():
    active = false
    queue_free()


func _stop_tracking(body):
    body_being_tracked = null


func _change_sprite_1():
    if forest:
        sprite.texture = sprites_forest[1]
    else:
        sprite.texture = sprites[0]


func _change_sprite_2():
    if forest:
        sprite.texture = sprites_forest[2]
    else:
        sprite.texture = sprites[1]
