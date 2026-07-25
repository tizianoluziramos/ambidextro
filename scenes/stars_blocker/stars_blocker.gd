extends ColorRect


var tween: Tween


func fade_in():
    tween = create_tween()
    tween.tween_property(self, "modulate:a", 1, 1)
