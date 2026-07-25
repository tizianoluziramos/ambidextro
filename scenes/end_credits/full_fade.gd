extends ColorRect

var _tween: Tween

func fade_in():
    _tween = create_tween()
    _tween.tween_property(self, "self_modulate", Color.TRANSPARENT, 2)
    _tween.finished.connect(_destroy, 4)


func _destroy():
    queue_free()
