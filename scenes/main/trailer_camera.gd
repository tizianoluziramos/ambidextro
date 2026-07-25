extends Camera2D


var _target_chara: Node2D
var _moving: bool
var _tween: Tween

func _process(delta: float) -> void :
    if Input.is_action_just_pressed("trailer"):
        if !_moving:
            _moving = true
            _move()
        else:
            _moving = false
            if _tween:
                _tween.custom_step(999)

    if _moving: return

    if _target_chara == null:
        if Global.player_charas.size() > 0:
            _target_chara = Global.player_charas[1]
    else:
        global_position = _target_chara.global_position


func _move():
    _tween = create_tween()
    _tween.tween_property(self, "global_position", Vector2.ZERO, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
