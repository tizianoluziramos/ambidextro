extends Node


@export var save_load: Node
@export var music_players: Array[AudioStreamPlayer]
@export var music_players_layers: Array[AudioStreamPlayer]
@export var layer_0_timer: Timer
@export var layer_change_timer: Timer

@export_category("music")
@export var main_menu_music: AudioStream
@export var loop_0_intro: AudioStream
@export var loop_0: AudioStream
@export var loop_0_bridge: AudioStream
@export var loop_1: AudioStream
@export var loop_1_bridge: AudioStream
@export var loop_2: AudioStream
@export var loop_2_bridge: AudioStream
@export var loop_3: AudioStream
@export var loop_3_bridge: AudioStream
@export var loop_4: AudioStream
@export var loop_5: AudioStream
@export var loop_6: AudioStream
@export var loop_6_bridge: AudioStream
@export var loop_7: AudioStream
@export var loop_7_bridge: AudioStream
@export var loop_8: AudioStream
@export var loop_8_bridge: AudioStream
@export var loop_9: AudioStream
@export var loop_9_bridge: AudioStream
@export var loop_10: AudioStream
@export var loop_11: AudioStream
@export var loop_11_bridge: AudioStream
@export var loop_12: AudioStream


var _tween: Tween
var _tween_2: Tween
var _tween_3: Tween
var _tween_4: Tween

var _streams_queue: Array[AudioStream]
var _queue_cooldown: float
var _current_music_level: int
var _active_music_player_index: int
var _layers_stream: Array[AudioStreamSynchronized]
var _paused: bool = true
var _main_menu_music: bool
var _last_level_music: bool

const _DEATH_DISTORTION_DURATION = 0.15
const _DEATH_DISTORTION_DURATION_LAST_LEVEL = 0.3
const _LAYER_FADE_DURATION = 0.5
const DEFAULT_MUSIC_VOL: float = -5
const _MUSIC_LOOP_FADE_DURATION: float = 2.285714285714286
const _MAIN_MENU_MUSIC_LOOP_FADE_DURATION: float = 1.8947368421052633
const _MUSIC_LAYER_FADE_DURATION: float = 2.526315789473684

func _ready() -> void :
    _load_audio_levels.call_deferred()


func _process(delta: float) -> void :
    if _queue_cooldown > 0: _queue_cooldown -= delta
    _manage_queue(delta)
    _manage_layer_players(delta)


func _load_audio_levels():
    var data: Dictionary = save_load.get_loaded_settings()

    if data.has("audio"):
        AudioServer.set_bus_volume_db(0, linear_to_db(data["audio"]["master"] / 100.0))
        AudioServer.set_bus_volume_db(1, linear_to_db(data["audio"]["music"] / 140.0))
        AudioServer.set_bus_volume_db(2, linear_to_db(data["audio"]["sounds"] / 100.0))
        AudioServer.set_bus_volume_db(2, linear_to_db(data["audio"]["sounds"] / 100.0))

    else:
        var dic: Dictionary
        dic["master"] = 100
        dic["music"] = 100
        dic["sounds"] = 100

        save_load.save_settings("audio", dic)



func play_main_menu_music():
    if (music_players[0].stream == main_menu_music && music_players[0].playing) || (music_players[1].stream == main_menu_music && music_players[1].playing): return
    _stop_music_and_clear()
    music_players[0].stream = main_menu_music
    music_players[0].play()
    _streams_queue.append(main_menu_music)
    _main_menu_music = true
    _queue_cooldown = 2.5
    _paused = false


func play_levels_music(level: int):
    _stop_music_and_clear()

    if level < 101:
        _current_music_level = -1
        _manage_level_music(level)
        if level != 101:
            _play_first_stream()
    else:
        _current_music_level = 101
        _play_last_level_music()


func change_level_music(level: int):
    if level == 101:
        _stop_music_and_clear()
        play_levels_music(101)
        return
    _manage_level_music(level)


func _manage_level_music(level: int):
    if level == 0:
        _manage_add_to_queue(level, [loop_0_intro, loop_0])
    elif level in range(1, 11):
        _manage_add_to_queue(level, [loop_0_bridge, loop_1])

    elif level in range(11, 20):
        _manage_add_to_queue(level, [loop_1_bridge, loop_2])

    elif level in range(20, 30):
        _manage_add_to_queue(level, [loop_2_bridge, loop_3])

    elif level in range(30, 40):
        _manage_add_to_queue(level, [loop_3_bridge, loop_4])

    elif level in range(40, 50):
        _manage_add_to_queue(level, [loop_5])

    elif level in range(50, 60):
        _manage_add_to_queue(level, [loop_6])

    elif level in range(60, 70):
        _manage_add_to_queue(level, [loop_7])

    elif level in range(70, 80):
        _manage_add_to_queue(level, [loop_7_bridge, loop_8])

    elif level in range(80, 85):
        _manage_add_to_queue(level, [loop_8_bridge, loop_9])

    elif level in range(85, 90):
        _manage_add_to_queue(level, [loop_9_bridge, loop_10])

    elif level in range(90, 95):
        _manage_add_to_queue(level, [loop_11])

    elif level in range(95, 101):
        _manage_add_to_queue(level, [loop_11_bridge, loop_12])







    elif level == 101:
        stop_music()

    _current_music_level = level



func _manage_add_to_queue(level: int, streams: Array[AudioStream]):
    if level <= _current_music_level: return
    _current_music_level = level


    if streams[0] == loop_0_bridge:
        for i in _streams_queue.size():
            if i == 0: continue
            if _streams_queue[i] == loop_0:
                _streams_queue.resize(i)



    for i in _streams_queue.size():
        if _streams_queue[i] == streams[streams.size() - 1]:
            if _streams_queue.size() > i + 1:
                _streams_queue.resize(i + 1)
            return


    for i in streams.size():
        _streams_queue.append(streams[i])


func _fade_all_other_layers(sync: AudioStreamSynchronized, index: int):
    if _tween_2 && _tween_2.is_running(): _tween_2.custom_step(999)
    if _tween_2:
        _tween_2.kill()
        _tween_2 = null
    for i in 5:
        if i == index || sync.get_sync_stream_volume(i) == -60: continue
        if !_tween_2:
            _tween_2 = create_tween()
        _tween_2.tween_method(update_layer_volume.bind(sync, i - 1), sync.get_sync_stream_volume(i), -60, _LAYER_FADE_DURATION / 10.0)



func update_layer_volume(volume: float, sync: AudioStreamSynchronized, index: int):
    if index < 0: return
    sync.set_sync_stream_volume(index, volume)


func death_distortion():
    if _tween && _tween.is_running(): _tween.custom_step(999)
    _tween = create_tween()
    var new_pitch: float = 1.1 if randi_range(0, 1) == 0 else 0.9
    if _current_music_level < 101:
        _tween.set_parallel(true)
        _tween.tween_property(music_players[0], "pitch_scale", new_pitch, _DEATH_DISTORTION_DURATION)
        _tween.tween_property(music_players[1], "pitch_scale", new_pitch, _DEATH_DISTORTION_DURATION)
        _tween.set_parallel(false)
        _tween.tween_property(music_players[0], "pitch_scale", 1, _DEATH_DISTORTION_DURATION)
        _tween.tween_property(music_players[1], "pitch_scale", 1, _DEATH_DISTORTION_DURATION)
    else:
        _tween.set_parallel(true)
        _tween.tween_property(music_players_layers[0], "pitch_scale", new_pitch, _DEATH_DISTORTION_DURATION_LAST_LEVEL)
        _tween.tween_property(music_players_layers[1], "pitch_scale", new_pitch, _DEATH_DISTORTION_DURATION_LAST_LEVEL)
        _tween.set_parallel(false)
        _tween.tween_property(music_players_layers[0], "pitch_scale", 1, _DEATH_DISTORTION_DURATION_LAST_LEVEL)
        _tween.tween_property(music_players_layers[1], "pitch_scale", 1, _DEATH_DISTORTION_DURATION_LAST_LEVEL)


func pause_music():
    music_players[0].stream_paused = true
    music_players[1].stream_paused = true
    music_players_layers[0].stream_paused = true
    music_players_layers[1].stream_paused = true
    _paused = true


func resume_music():
    if _current_music_level < 101:
        music_players[0].stream_paused = false
        music_players[1].stream_paused = false
    else:
        music_players_layers[0].stream_paused = false
        music_players_layers[1].stream_paused = false
    _paused = false


func stop_music():
    _paused = false
    _stop_music_and_clear()


func _manage_queue(delta: float):
    if _paused || _streams_queue.size() == 0: return
    if _main_menu_music:
        if _queue_cooldown <= 0 && music_players[_active_music_player_index].stream != null && music_players[_active_music_player_index].get_playback_position() + AudioServer.get_time_since_last_mix() + delta >= music_players[_active_music_player_index].stream.get_length() - _MAIN_MENU_MUSIC_LOOP_FADE_DURATION:
            _play_next_stream()
    else:
        if _queue_cooldown <= 0 && music_players[_active_music_player_index].stream != null && music_players[_active_music_player_index].get_playback_position() + AudioServer.get_time_since_last_mix() + delta >= music_players[_active_music_player_index].stream.get_length() - _MUSIC_LOOP_FADE_DURATION:
            _play_next_stream()


func _manage_layer_players(delta: float):
    if _paused || !_last_level_music: return
    if _queue_cooldown <= 0 && music_players_layers[_active_music_player_index].get_playback_position() + AudioServer.get_time_since_last_mix() + delta >= music_players_layers[_active_music_player_index].stream.get_length() - _MUSIC_LAYER_FADE_DURATION:
        _play_next_layer_player()


func _play_next_layer_player():
    _queue_cooldown = 2.5
    _active_music_player_index = 1 if _active_music_player_index == 0 else 0
    music_players_layers[_active_music_player_index].play()


    if _active_music_player_index == 0 && _layers_stream[_active_music_player_index].get_sync_stream_volume(0) == 0:
        _layers_stream[_active_music_player_index].set_sync_stream_volume(0, -60)
        _layers_stream[_active_music_player_index].set_sync_stream_volume(1, 0)



func _play_next_stream():

    if _streams_queue.size() > 1:
        _streams_queue.remove_at(0)

    _active_music_player_index = 1 if _active_music_player_index == 0 else 0
    music_players[_active_music_player_index].stream = _streams_queue[0]
    music_players[_active_music_player_index].play()
    _queue_cooldown = 2.5


func _play_first_stream():

    if _current_music_level > 0 && _streams_queue.size() > 0:
        _streams_queue[0] = _streams_queue[_streams_queue.size() - 1]
        _streams_queue.resize(1)

    music_players[0].stream = _streams_queue[0]
    music_players[0].play()
    _active_music_player_index = 0


func _play_last_level_music():
    _stop_music_and_clear()
    _last_level_music = true
    _layers_stream.resize(2)
    _layers_stream[0] = music_players_layers[0].stream
    _layers_stream[1] = music_players_layers[1].stream
    for i in _layers_stream[0].stream_count:
        _layers_stream[0].set_sync_stream_volume(i, -60)
    _layers_stream[0].set_sync_stream_volume(0, 0)
    for i in _layers_stream[1].stream_count:
        _layers_stream[1].set_sync_stream_volume(i, -60)
    _layers_stream[1].set_sync_stream_volume(1, 0)
    music_players_layers[0].play()
    _active_music_player_index = 0

    if layer_0_timer && layer_0_timer.timeout.is_connected(change_to_layer):
        layer_0_timer.timeout.disconnect(change_to_layer)
        layer_0_timer.stop()
    else:
        layer_0_timer.start()
        layer_0_timer.timeout.connect(change_to_layer.bind(1), 4)
        layer_0_timer.start()

    _queue_cooldown = 2.5



func change_to_layer(layer_index: int):
    if layer_index == 0: return
    layer_0_timer.stop()

    var duration: float = 4
    if layer_index == 3: duration = 6.5
    elif layer_index == 5: duration = 2
    elif layer_index == 7: duration = 5

    if _tween_3: _tween_3.kill()
    if _tween_4: _tween_4.kill()

    if _layers_stream[_active_music_player_index].get_sync_stream_volume(layer_index) < 0:
        _tween_3 = create_tween()
        _tween_3.tween_method(_change_layer_volume.bind(layer_index), _layers_stream[_active_music_player_index].get_sync_stream_volume(layer_index), 0, duration)

    layer_change_timer.stop()
    if layer_change_timer.timeout.is_connected(_fade_other_layers):
        layer_change_timer.timeout.disconnect(_fade_other_layers)
    layer_change_timer.timeout.connect(_fade_other_layers.bind(layer_index))
    layer_change_timer.start(duration * 0.83)


func _fade_other_layers(layer_index: int):
    var there_are_tweeners: bool
    if _tween_4: _tween_4.kill()
    _tween_4 = create_tween()
    _tween_4.set_parallel(true)

    var duration: float = 4
    if layer_index == 3: duration = 6.5
    elif layer_index == 5: duration = 1
    elif layer_index == 6: duration = 6
    elif layer_index == 7: duration = 5

    for i in _layers_stream[0].stream_count:
        if i != layer_index && _layers_stream[0].get_sync_stream_volume(i) > -60:
            _tween_4.tween_method(_change_layer_volume.bind(i), _layers_stream[0].get_sync_stream_volume(i), -60, duration)
            there_are_tweeners = true
    for i in _layers_stream[1].stream_count:
        if i != layer_index && _layers_stream[1].get_sync_stream_volume(i) > -60:
            _tween_4.tween_method(_change_layer_volume.bind(i), _layers_stream[1].get_sync_stream_volume(i), -60, duration)
            there_are_tweeners = true

    if !there_are_tweeners:
        _tween_4.kill()



func reset_last_level_music():
    if _tween_3: _tween_3.kill()
    if _tween_4: _tween_4.kill()
    var there_are_tweeners: bool
    _tween_3 = create_tween()
    _tween_3.set_parallel(true)
    layer_0_timer.stop()
    layer_change_timer.stop()
    for i in _layers_stream[0].stream_count:
        if i != 1 && _layers_stream[0].get_sync_stream_volume(i) > -60:
            _tween_3.tween_method(_change_layer_volume.bind(i), _layers_stream[0].get_sync_stream_volume(i), -60, 5)
            there_are_tweeners = true
        elif i == 1:
            _tween_3.tween_method(_change_layer_volume.bind(i), _layers_stream[0].get_sync_stream_volume(i), 0, 1)
            there_are_tweeners = true
    layer_change_timer.stop()
    for i in _layers_stream[1].stream_count:
        if i != 1 && _layers_stream[1].get_sync_stream_volume(i) > -60:
            _tween_3.tween_method(_change_layer_volume.bind(i), _layers_stream[1].get_sync_stream_volume(i), -60, 5)
            there_are_tweeners = true
        elif i == 1:
            _tween_3.tween_method(_change_layer_volume.bind(i), _layers_stream[1].get_sync_stream_volume(i), 0, 1)
            there_are_tweeners = true

    if !there_are_tweeners:
        _tween_3.kill()


func _change_layer_volume(volume: float, index: int):
    _layers_stream[0].set_sync_stream_volume(index, volume)
    _layers_stream[1].set_sync_stream_volume(index, volume)



func add_queue_cooldown():
    _queue_cooldown = 1


func _stop_music_and_clear():
    _last_level_music = false
    _main_menu_music = false
    music_players[0].stop()
    music_players[1].stop()
    music_players[0].stream = null
    music_players[1].stream = null
    _streams_queue.clear()
    music_players[0].volume_db = 0
    music_players[1].volume_db = 0
    _active_music_player_index = 0

    music_players_layers[0].stop()
    music_players_layers[1].stop()
    layer_change_timer.stop()
