extends Area2D

@export var damage_area: Node

func _ready() -> void :
    body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D):
    damage_area.die(null)
