extends Node2D

@export var barrier: Sprite2D
@export var audio_player: AudioStreamPlayer2D
@export var fireball_block: Area2D
@export var other_end: Node
@export var scrolling_level: Node

var _tween: Tween
var _duration: float = 0.3

var _body: Node
var _activated: bool
var _sound_played: bool

func _process(delta: float) -> void :
    if _activated:
        barrier.global_position = Vector2(_body.global_position.x, _body.global_position.y - 8)

        if !_sound_played:
            _sound_played = true
            audio_player.play()


func _on_area_2d_body_entered(body: Node2D) -> void :
    if body is PlayerChara && !_activated:
        _activated = true
        _body = body
        body.set_disable_movement_on_grounded(true)

        barrier.global_position = Vector2(body.global_position.x, body.global_position.y - 8)

        _tween = create_tween()
        _tween.set_loops()
        _tween.tween_property(barrier, "modulate:a", 0.5, _duration)
        _tween.tween_property(barrier, "modulate:a", 0.2, _duration)

        fireball_block.monitoring = true
        fireball_block.force_update_transform()

        _manage_stop_timer()


func _manage_stop_timer():
    if other_end.is_active():

        scrolling_level.menu_loader.level_loader.set_speedrun_timer_finished(true)
        scrolling_level.menu_loader.level_loader.stop_normal_timer()

        scrolling_level.menu_loader.level_loader.save_ending()
        scrolling_level.menu_loader.level_loader.manage_beat_game_achievements()

        Global.game_ended = true


func is_active() -> bool:
    return _activated
