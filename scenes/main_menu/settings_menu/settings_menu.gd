extends Node2D


@export var options: Node
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node
var from_pause: bool


func _ready():
    _translate()

    if from_pause:
        options.remove_option(5)


func select_option(index: int):
    options.select_option(index)


func accept_option(option: String, option_index: int):
    match option:
        "language":
            ui_sounds.play_accept()
            menu_loader.load_language_menu()
        "video":
            ui_sounds.play_accept()
            menu_loader.load_video_menu()
        "audio":
            ui_sounds.play_accept()
            menu_loader.load_audio_menu()
        "controls":
            ui_sounds.play_accept()
            menu_loader.load_controls_menu()
        "accessibility":
            ui_sounds.play_accept()
            menu_loader.load_accessibility_menu()
        "speedrun":
            ui_sounds.play_accept()
            menu_loader.load_speedrun_menu()
        "data":
            ui_sounds.play_accept()
            menu_loader.load_data_menu()
        "credits":
            ui_sounds.play_accept()
            menu_loader.load_credits_menu()
        "back":
            ui_sounds.play_back()
            menu_loader.settings_to_main()


func increase(option: String, option_index: int):
    ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
    ui_sounds.play_invalid()

func cancel():
    ui_sounds.play_back()
    menu_loader.settings_to_main()

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
    labels[i].text = Global.translations["mm_settings"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_language"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_video"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_audio"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_controls"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_accessibility"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_data"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["setm_credits"][lang].to_upper()
    i += 1
    labels[i].text = Global.translations["sm_back"][lang].to_upper()
