extends Node2D


@export var options: Node
@export var label_value: Label
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var save_load: Node


var _language_codes: Array[String]
var _languages: Array[String]
var _language_index: int


func _ready() -> void :
    _initialize()


func _initialize():
    _language_codes = Global.languages
    for i in _language_codes.size():
        _languages.append(Global.translations["lang"][_language_codes[i]])
        if Global.language == _language_codes[i]:
            _language_index = i

    _translate()



func accept_option(option: String, option_index: int):
    match option:
        "marker2d":
            options.select_option(1)
            ui_sounds.play_accept()
        "back":
            ui_sounds.play_back()
            _save_selection()
            menu_loader.language_to_settings()


func increase(option: String, option_index: int):
    match option:
        "marker2d":
            ui_sounds.play_lateral()
            _language_index += 1
            if _language_index >= _languages.size():
                _language_index = 0
            Global.language = _language_codes[_language_index]
            _translate()
        _:
            ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    match option:
        "marker2d":
            ui_sounds.play_lateral()
            _language_index -= 1
            if _language_index < 0:
                _language_index = _languages.size() - 1
            Global.language = _language_codes[_language_index]
            _translate()
        _:
            ui_sounds.play_invalid()


func cancel():
    ui_sounds.play_back()
    _save_selection()
    menu_loader.language_to_settings()

func play_selection():
    ui_sounds.play_selection()


func _save_selection():
    save_load.save_settings("language", Global.language)



func _translate():
    var lang: String = Global.language

    if lang in Global.non_latin_languages:
        for label in labels:
            label.theme = Global.secondary_theme

        if lang in ["de", "fr", "it", "pr"]:
            labels[0].theme = Global.main_theme

    else:
        labels[0].theme = Global.main_theme
        labels[2].theme = Global.main_theme

    var i: int = 0
    labels[i].text = Global.translations["setm_language"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["lang"][lang]
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
