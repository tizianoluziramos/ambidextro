extends Node2D

@export var sprites: Array[Texture2D]
@export var audio: AudioStreamPlayer2D
@export var glass_break: AudioStream


var sprite_index: int = -1
var parent: Node
var active: bool = true

func _ready() -> void :
	add_to_group("disappearing_platform")
	parent = get_parent()

func hit():
	sprite_index += 1
	if sprites.size() > sprite_index:
		audio.play()
		$Sprite2D.texture = sprites[sprite_index]

	if active && sprite_index > 1:
		audio.stream = glass_break
		audio.play()
		active = false
		$StaticBody2D.process_mode = Node.PROCESS_MODE_DISABLED
		$Sprite2D.visible = false
		$CPUParticles2D.emitting = true
		$CPUParticles2D2.emitting = true


func manage_hit(body: Node2D):
	var previous_positions: Array[Vector2] = body.get_previous_positions()

	var y0: int = previous_positions[0].y * 100
	var y1: int = previous_positions[1].y * 100

	if y0 != y1:
		hit()


func _on_area_2d_body_entered(body: Node2D) -> void :
	manage_hit(body)
	return
