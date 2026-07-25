extends Area2D


func _on_body_entered(body: Node2D) -> void :
    if body is LariatFireball:
        body.queue_free()
