extends Node2D

@export var emblem: int = 1

@export_category("references")
@export var emblems: Array[AtlasTexture]
@export var emblem_sprite: Sprite2D
@export var audio: AudioStreamPlayer2D
@export var mute: bool

const _DURATION: float = 0.1

var _bar_childrens: Array[Node]
var _tween: Tween
var _distance_to_bottom: float
var _min_scale: float
var _active: bool

func _ready() -> void :
	add_to_group("activable")
	emblem_sprite.texture = emblems[emblem - 1]

	var longer_distance: float
	var this_distance: float
	var children: Array = get_children()
	for child in children:
		if child.is_in_group("bars"):
			_bar_childrens.append(child)
			var cc: Node2D
			this_distance = child.position.distance_to(Vector2.ZERO)
			if longer_distance < this_distance:
				longer_distance = this_distance

	emblem_sprite.position.y += longer_distance / 2.0
	if rotation > 0:
		emblem_sprite.rotation_degrees = -90
	elif rotation < 0:
		emblem_sprite.rotation_degrees = 90
	_distance_to_bottom = longer_distance

	_min_scale = 0.5 / _distance_to_bottom


func _process(_delta: float) -> void :
	if _active: return
	if _distance_to_bottom - (_distance_to_bottom * scale.y) < 9:
		for child in _bar_childrens:
			child.collider_damage.set_deferred("disabled", false)


func activate():
	_active = true
	emblem_sprite.visible = false

	if _tween: _tween.stop()

	_tween = create_tween()
	if Engine.get_frames_per_second() < 60:
		_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "scale:y", _min_scale, _DURATION * _distance_to_bottom / 20)
	_tween.finished.connect(disable_colliders, 4)

	if !mute:
		audio.pitch_scale = 1
		audio.play()



func disable_colliders():
	for child in _bar_childrens:
		child.collider.set_deferred("disabled", true)
		child.collider_damage.set_deferred("disabled", true)


func deactivate():
	_active = false
	if _tween: _tween.stop()

	if !is_inside_tree(): return

	for child in _bar_childrens:
		child.collider.set_deferred("disabled", false)
		child.collider_damage.set_deferred("disabled", false)

	_tween = create_tween()
	if Engine.get_frames_per_second() < 60:
		_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "scale:y", 1, _DURATION * _distance_to_bottom / 10)
	_tween.finished.connect(show_emblem, 4)

	if !mute:
		audio.pitch_scale = 0.9
		audio.play()


func show_emblem():
	emblem_sprite.visible = true
