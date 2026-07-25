extends Node2D


@export var other_swapper: Node
@export var lariat: Node

var active: bool = true

func activate():
    if !active: return
    other_swapper.active = false

    lariat.swap()

    other_swapper.queue_free()
    queue_free()
