extends Node2D

@export var options: Node
@export var level_label: Label
@export var retries_label: Label
@export var time_label: Label
@export var time_related_elements: Array[Node]
@export var labels: Array[Label]
@export var save_icon: Sprite2D

@export var save_info: Node
@export var v_box_container: BoxContainer


var menu_loader: Node
var ui_sounds: Node
var level_loader: Node
var cutscene: bool
var cutscene_is_intro: bool
var cutscene_instance: Node


var _data: Dictionary
var _active: bool
var _active_one_frame_after_ready
var _unload_pause_next_frame: bool

func _ready() -> void :
	_active_one_frame_after_ready = 2
	_translate()

	if Global.mobile:
		_set_for_mobile()


func _set_for_mobile():
	labels[0].position.y -= 20
	save_info.position.y -= 30
	v_box_container.add_theme_constant_override("separation", 10)
	v_box_container.position.y -= 30

	labels[3].visible = false
	options.options.remove_at(3)

	options.selection_arrow.visible = false


func initialize(data: Dictionary, mode: int, from_level: bool):
	_data = data

	match mode:
		0:
			if !Global.speedrun_mode:
				time_label.text = menu_loader.get_time_string(level_loader.get_normal_time())
			else:
				time_label.text = menu_loader.get_speedrun_time_string(Global.speedrun_time)

			if data.has("random_levels_index") && Global.in_story_mode:
				level_label.text = menu_loader.get_level_number_string(data["random_levels_index"])
			else:
				level_label.text = menu_loader.get_level_number_string(data["level"])
			retries_label.text = menu_loader.get_retries_number_string(data["retries"])

			if Global.speedrun_mode:
				options.remove_option(3)
				options.remove_option(3)
			else:
				options.remove_option(1)
				options.remove_option(2)
				options.remove_option(2)

			if from_level && !cutscene_is_intro && data.get("ended", false) == false:
				show_save_icon()

		1, 2:
			level_label.text = level_loader.get_level_number_string()
			retries_label.text = level_loader.get_retries_number_string()

			_hide_time_related_elements()
			options.remove_option(1)
			if level_loader.level_index == 1 || (level_loader.level_index == 2 && level_loader.is_level_counter_instantiated()):
				options.remove_option(3)
			elif level_loader.level_index == 100 && !level_loader.is_last_level_unlocked():
				options.remove_option(2)

		3:
			level_label.text = level_loader.get_level_number_string()
			retries_label.text = level_loader.get_retries_number_string()

			_hide_time_related_elements()
			options.remove_option(1)
			if level_loader.random_levels_index == 0:
				options.remove_option(3)


func _activate():
	_active = true


func _process(_delta: float) -> void :
	if _active_one_frame_after_ready > 0:
		if _active_one_frame_after_ready == 1:
			_activate.call_deferred()
		_active_one_frame_after_ready -= 1

	if !_active: return

	if Input.is_action_just_pressed("pause"):
		ui_sounds.play_back()
		cancel()

	if Global.speedrun_mode:
		time_label.text = menu_loader.get_speedrun_time_string(Global.speedrun_time)


func _physics_process(delta: float) -> void :
	if _unload_pause_next_frame:
		_unload_pause_next_frame = false
		menu_loader.unload_pause_menu.call_deferred()


func _hide_time_related_elements():
	for element in time_related_elements:
		element.visible = false


func accept_option(option: String, option_index: int):
	match option:
		"continue":
			_active = false
			ui_sounds.play_back()
			menu_loader.unload_pause_menu()
		"restartgame":
			_active = false
			ui_sounds.play_accept()
			menu_loader.manage_restart_game()
			menu_loader.unload_pause_menu()
		"restartlevel":
			ui_sounds.play_accept()
			if cutscene:
				menu_loader.unload_pause_menu()
				cutscene_instance.end()
			else:
				level_loader.reset_level(true)
				_active = false
				_unload_pause_next_frame = true
		"nextlevel":
			_active = false
			menu_loader.quit_credits()
			level_loader.next_level(true)
			menu_loader.unload_pause_menu()
		"previouslevel":
			_active = false
			menu_loader.quit_credits()
			level_loader.previous_level()
			menu_loader.unload_pause_menu()
		"settings":
			ui_sounds.play_accept()
			menu_loader.load_settings_menu()
		"mainmenu":
			_active = false
			ui_sounds.play_back()
			menu_loader.pause_to_main()


func increase(option: String, option_index: int):
	pass


func decrease(option: String, option_index: int):
	pass


func cancel():
	menu_loader.unload_pause_menu()


func play_selection():
	ui_sounds.play_selection()


func select_settings_option():
	options.select_option(options.options.size() - 2)


func show_save_icon():
	var tween: Tween = create_tween()
	save_icon.modulate.a = 1
	tween.tween_property(save_icon, "modulate:a", 0, 1)


func _translate():
	var lang: String = Global.language

	if lang in Global.non_latin_languages:
		for label in labels:
			label.theme = Global.secondary_theme
	else:
		for i in labels.size():
			if i in [1, 2, 3]: continue
			labels[i].theme = Global.main_theme

	var i: int = 0
	labels[i].text = Global.translations["pm_pause"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["sm_level"][lang]
	i += 1
	labels[i].text = Global.translations["sm_retries"][lang]
	i += 1
	labels[i].text = Global.translations["sm_time"][lang]
	i += 1
	labels[i].text = Global.translations["pm_continue"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["pm_restart_game"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["pm_restart_level"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["pm_next"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["pm_previous"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["mm_settings"][lang].to_upper()
	i += 1
	labels[i].text = Global.translations["pm_main"][lang].to_upper()

	if cutscene:
		labels[6].text = Global.translations["pm_skip"][lang].to_upper()
