extends AudioStreamPlayer2D


func destroy():
    await get_tree().create_timer(0.5).timeout
    queue_free()
