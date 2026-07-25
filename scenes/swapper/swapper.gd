extends Node2D

var container: Node2D

func _ready() -> void :
    $Area2D.body_entered.connect(_manage_collision)
    container = get_parent()


func _manage_collision(body):
    if body is PlayerChara:
        activate()


func activate():
    container.activate()
