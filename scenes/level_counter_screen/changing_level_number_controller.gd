extends Label


var _tween: Tween

const _DISTANCE: float = 60
const _BOUNCE_DISTANCE: float = 3
const _DURATION: float = 1
const _BOUNCE_DURATION: float = 0.15


func change_to(number: String) -> Signal:
	var child: Label = get_child(0)
	child.text = str(number)
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "position:y", position.y + _DISTANCE, _DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "self_modulate", Color.TRANSPARENT, _DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(get_child(0), "self_modulate", Color.WHITE, _DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	return _tween.finished


func bounce():
	_tween = create_tween()
	_tween.tween_property(self, "position:y", position.y + _BOUNCE_DISTANCE, _BOUNCE_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:y", position.y, _BOUNCE_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
