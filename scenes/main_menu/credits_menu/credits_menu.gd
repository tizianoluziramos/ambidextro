extends Node2D


@export var options: Node
@export var credits_label: Node
@export var labels: Array[Label]


var menu_loader: Node
var ui_sounds: Node

var _index: int


func _ready():
	_translate()
	load_credits_page.call_deferred(0)


func accept_option(option: String, option_index: int):
	match option:
		"<":
			ui_sounds.play_accept()
			options.select_option(1)
		"back":
			ui_sounds.play_back()
			menu_loader.credits_to_settings()


func increase(option: String, option_index: int):
	match option:
		"<":
			ui_sounds.play_lateral()
			_index += 1
			if _index > 4:
				_index = 0
			load_credits_page(_index)
		_:
			ui_sounds.play_invalid()


func decrease(option: String, option_index: int):
	match option:
		"<":
			ui_sounds.play_lateral()
			_index -= 1
			if _index < 0:
				_index = 4
			load_credits_page(_index)
		_:
			ui_sounds.play_invalid()


func load_credits_page(index: int):
	var lang: String = Global.language
	var text: String
	match index:
		0:
			text = Global.translations["credits_title"][lang]
			text += " (v" + Global.version + ")"
			text += "\n\n"
			text += Global.translations["credits_created"][lang]
			text += "\n\n"
			text += Global.translations["credits_music"][lang]
			text += "\n\n"
			text += Global.translations["credits_illustrations"][lang]
			text += "\n\n"
			text += Global.translations["credits_majorariatto"][lang] + " " + Global.years
		1:
			text += Global.translations["credits_thanks"][lang]
			text += "\n\n"
			text += Global.translations["credits_lariat"][lang]
			text += "\n"
			text += Global.translations["credits_nico"][lang]
			text += "\n"
			text += Global.translations["credits_migu"][lang]
			text += "\n"
			text += Global.translations["credits_guinxu"][lang]
			text += "\n"
			text += Global.translations["credits_gius"][lang]
			text += "\n"
			text += Global.translations["credits_kony"][lang]
			text += "\n"
			text += Global.translations["credits_nosgo"][lang]
			text += "\n"
			text += Global.translations["credits_david_chen"][lang]
			text += "\n"
			text += Global.translations["credits_fanzy_pants"][lang]
		2:
			text += Global.translations["credits_engine"][lang]
		3:
			text += Global.translations["credits_shaders"][lang]
			text += "\n\n"
			text += Global.translations["credits_shaders1"][lang]
			text += "\n\n\n"
			text += Global.translations["credits_fonts"][lang]
			text += "\n\n"
			text += Global.translations["credits_fonts1"][lang]
			text += "\n"
			text += Global.translations["credits_fonts2"][lang]
			text += "\n"
			text += Global.translations["credits_fonts3"][lang]
		4:
			text += Global.translations["credits_sounds"][lang]
			text += "\n\n"
			text += Global.translations["credits_sfx1"][lang]
			text += "\n"
			text += Global.translations["credits_sfx2"][lang]
			text += "\n"
			text += Global.translations["credits_sfx3"][lang]
			text += "\n"
			text += Global.translations["credits_sfx4"][lang]
			text += "\n"
			text += Global.translations["credits_sfx5"][lang]
			text += "\n"
			text += Global.translations["credits_sfx6"][lang]
			text += "\n"
			text += Global.translations["credits_sfx7"][lang]
			text += "\n"
			text += Global.translations["credits_sfx8"][lang]
			text += "\n"
			text += Global.translations["credits_sfx9"][lang]
			text += "\n"
			text += Global.translations["credits_sfx10"][lang]
			text += "\n"
			text += Global.translations["credits_sfx11"][lang]

	credits_label.text = text

func cancel():
	ui_sounds.play_back()
	menu_loader.credits_to_settings()

func play_selection():
	ui_sounds.play_selection()



func _translate():
	var lang: String = Global.language

	if lang in Global.non_latin_languages:
		for label in labels:
			label.theme = Global.secondary_theme
	else:
		labels[0].theme = Global.main_theme
		labels[2].theme = Global.main_theme

	labels[0].text = Global.translations["setm_credits"][lang].to_upper()
	labels[2].text = Global.translations["sm_back"][lang].to_upper()
