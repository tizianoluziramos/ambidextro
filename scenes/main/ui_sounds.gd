extends Node


@export var ui_players: Array[AudioStreamPlayer]
@export var accept_sound: AudioStream
@export var back_sound: AudioStream
@export var selection_sound: AudioStream
@export var lateral_sound: AudioStream
@export var invalid_sound: AudioStream
@export var remap_sound: AudioStream
@export var key_sound: AudioStream


func play_accept():
    play_sound(accept_sound)


func play_back():
    play_sound(back_sound)


func play_invalid():
    play_sound(invalid_sound)


func play_selection():
    play_sound(selection_sound)


func play_lateral():
    play_sound(lateral_sound)


func play_remap():
    play_sound(remap_sound)


func play_key():
    play_sound(key_sound)


func play_sound(sound: AudioStream):
    if ui_players[0].is_playing():
        ui_players[1].stream = sound
        ui_players[1].play()
    else:
        ui_players[0].stream = sound
        ui_players[0].play()
