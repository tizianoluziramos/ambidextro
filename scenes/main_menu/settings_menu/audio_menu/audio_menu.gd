extends Node2D


@export var options: Node
@export var label_values: Array[Label]
@export var audio_bus_layout: AudioBusLayout
@export var labels: Array[Label]


var menu_loader: Node
var music_controller: Node
var ui_sounds: Node
var save_load: Node
var from_pause: bool

var _master_value: int = 100
var _music_value: int = 100
var _sounds_value: int = 100


func _ready() -> void :
    _translate()
    _load_audio_levels.call_deferred()

    options.option_selected.connect(_on_option_selected)


func _load_audio_levels():
    var data: Dictionary = save_load.get_loaded_settings()

    _master_value = data["audio"]["master"]
    _music_value = data["audio"]["music"]
    _sounds_value = data["audio"]["sounds"]
    _update_sound_values()


func _on_option_selected(index: int):
    if !from_pause: return
    if index == 1:
        music_controller.resume_music()
    else:
        music_controller.pause_music()



func _update_sound_values():
    label_values[0].text = str(_master_value)
    label_values[1].text = str(_music_value)
    label_values[2].text = str(_sounds_value)


func accept_option(option: String, option_index: int):
    match option:
        "marker2d":
            options.select_option(3)
            ui_sounds.play_accept()
        "back":
            ui_sounds.play_back()
            _save_audio_levels()
            menu_loader.audio_to_settings()


func increase(option: String, option_index: int):
    match option:
        "marker2d":
            match option_index:
                0:
                    if _master_value >= 100:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        if _master_value >= 5:
                            _master_value += 5
                        else:
                            _master_value += 1
                        label_values[option_index].text = str(_master_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(0, linear_to_db(_master_value / 100.0))
                1:
                    if _music_value >= 100:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        if _music_value >= 5:
                            _music_value += 5
                        else:
                            _music_value += 1
                        label_values[option_index].text = str(_music_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(1, linear_to_db(_music_value / 140.0))
                2:
                    if _sounds_value >= 100:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        if _sounds_value >= 5:
                            _sounds_value += 5
                        else:
                            _sounds_value += 1
                        label_values[option_index].text = str(_sounds_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(2, linear_to_db(_sounds_value / 100.0))
                        AudioServer.set_bus_volume_db(3, linear_to_db(_sounds_value / 100.0))

        _:
            ui_sounds.play_invalid()



func decrease(option: String, option_index: int):
    match option:
        "marker2d":
            match option_index:
                0:
                    if _master_value <= 0:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        if _master_value <= 5:
                            _master_value -= 1
                        else:
                            _master_value -= 5
                        label_values[option_index].text = str(_master_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(0, linear_to_db(_master_value / 100.0))
                1:
                    if _music_value <= 0:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        if _music_value <= 5:
                            _music_value -= 1
                        else:
                            _music_value -= 5
                        label_values[option_index].text = str(_music_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(1, linear_to_db(_music_value / 140.0))
                2:
                    if _sounds_value <= 0:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        if _sounds_value <= 5:
                            _sounds_value -= 1
                        else:
                            _sounds_value -= 5
                        label_values[option_index].text = str(_sounds_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(2, linear_to_db(_sounds_value / 100.0))
                        AudioServer.set_bus_volume_db(3, linear_to_db(_sounds_value / 100.0))

        _:
            ui_sounds.play_invalid()


func increase_quick(option: String, option_index: int):
    match option:
        "marker2d":
            match option_index:
                0:
                    if _master_value >= 100:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        _master_value += 10
                        if _master_value > 100:
                            _master_value = 100
                        label_values[option_index].text = str(_master_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(0, linear_to_db(_master_value / 100.0))
                1:
                    if _music_value >= 100:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        _music_value += 10
                        if _music_value > 100:
                            _music_value = 100
                        label_values[option_index].text = str(_music_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(1, linear_to_db(_music_value / 140.0))
                2:
                    if _sounds_value >= 100:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        _sounds_value += 10
                        if _sounds_value > 100:
                            _sounds_value = 100
                        label_values[option_index].text = str(_sounds_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(2, linear_to_db(_sounds_value / 100.0))
                        AudioServer.set_bus_volume_db(3, linear_to_db(_sounds_value / 100.0))

        _:
            ui_sounds.play_invalid()



func decrease_quick(option: String, option_index: int):
    match option:
        "marker2d":
            match option_index:
                0:
                    if _master_value <= 0:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        _master_value -= 10
                        if _master_value < 0:
                            _master_value = 0
                        label_values[option_index].text = str(_master_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(0, linear_to_db(_master_value / 100.0))
                1:
                    if _music_value <= 0:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        _music_value -= 10
                        if _music_value < 0:
                            _music_value = 0
                        label_values[option_index].text = str(_music_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(1, linear_to_db(_music_value / 140.0))
                2:
                    if _sounds_value <= 0:
                        ui_sounds.play_invalid()
                        options.block_combo()
                        return
                    else:
                        _sounds_value -= 10
                        if _sounds_value < 0:
                            _sounds_value = 0
                        label_values[option_index].text = str(_sounds_value)
                        ui_sounds.play_lateral()
                        AudioServer.set_bus_volume_db(2, linear_to_db(_sounds_value / 100.0))
                        AudioServer.set_bus_volume_db(3, linear_to_db(_sounds_value / 100.0))

        _:
            ui_sounds.play_invalid()


func _save_audio_levels():
    var dic: Dictionary

    dic["master"] = _master_value
    dic["music"] = _music_value
    dic["sounds"] = _sounds_value

    save_load.save_settings("audio", dic)

func cancel():
    ui_sounds.play_back()
    _save_audio_levels()
    menu_loader.audio_to_settings()

func play_selection():
    ui_sounds.play_selection()




func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme
    else:
        for label in labels:
            label.theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_audio"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setma_master"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setma_music"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setma_sounds"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
