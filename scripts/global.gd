extends Node


var version: String = "1.1.11"
var years: String = "2025"
var steam: bool = true
var mobile: bool = false
var allow_debug_controls: bool

var language: String
var non_latin_languages: Array[String] = ["jp", "ru", "ko", "sc", "de", "fr", "it", "pr"]
var languages: Array[String]
var translations: Dictionary
var subviewport_container: SubViewportContainer
var general_input_controller: Node

var extra_time: int
var speedrun_mode: bool
var speedrun_pausable: bool
var speedrun_time: float

var in_story_mode: bool
var game_ended: bool
var mirrored: bool

var level_selected: int
var clear_selected: int
var mirror_selected: int
var swap_selected: int

var main_theme: Theme
var secondary_theme: Theme

var player_charas: Array[Node] = [null, null]
var current_level_layout: Node

var steam_manager: Node

signal first_input


func reset():
	extra_time = 0
	speedrun_mode = false
	speedrun_time = 0.0
	in_story_mode = false
	current_level_layout = null


	level_selected = 1
	clear_selected = 0
	mirror_selected = 0
	swap_selected = 0


func emit_first_input():
	first_input.emit()
