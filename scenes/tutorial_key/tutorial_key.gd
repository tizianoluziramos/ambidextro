extends Node2D

@export var action: String
@export var color_rect_small: ColorRect
@export var color_rect_large: ColorRect
@export var label_small: Label
@export var label_large: Label
@export var sprite: Sprite2D
@export var large_sprites: Array[Sprite2D]
@export var arrow_sprite: Texture2D
@export var stick_sprites: Array[Texture2D]

func set_key(text: String, english_text: String):
	label_small.text = ""
	label_large.text = ""

	color_rect_small.visible = true
	color_rect_large.visible = false
	sprite.visible = false
	large_sprites[0].visible = false
	large_sprites[1].visible = false


	match english_text:
		"Left":
			sprite.texture = arrow_sprite
			sprite.visible = true
			sprite.rotation_degrees = -90

		"Up":
			sprite.texture = arrow_sprite
			sprite.visible = true
			sprite.rotation_degrees = 0

		"Right":
			sprite.texture = arrow_sprite
			sprite.visible = true
			sprite.rotation_degrees = 90

		"Down":
			sprite.texture = arrow_sprite
			sprite.visible = true
			sprite.rotation_degrees = 180

		"LS Left":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[0]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = -90
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		"LS Up":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[0]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = 0
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		"LS Right":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[0]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = 90
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		"LS Down":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[0]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = 180
			large_sprites[0].visible = true
			large_sprites[1].visible = true


		"RS Left":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[1]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = -90
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		"RS Up":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[1]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = 0
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		"RS Right":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[1]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = 90
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		"RS Down":
			color_rect_large.visible = true
			color_rect_small.visible = false
			label_large.text = ""
			large_sprites[0].texture = stick_sprites[1]
			large_sprites[1].texture = arrow_sprite
			large_sprites[1].rotation_degrees = 180
			large_sprites[0].visible = true
			large_sprites[1].visible = true

		_:
			if text.length() > 2:
				label_large.text = text
				color_rect_large.visible = true
				color_rect_small.visible = false

			else:
				label_small.text = text
