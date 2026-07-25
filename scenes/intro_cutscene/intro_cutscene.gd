extends Node2D


@export var label: RichTextLabel

@export var animation_player: AnimationPlayer
@export var audio_player: AudioStreamPlayer
@export var audio_player_rise: AudioStreamPlayer
@export var audio_player_lower: AudioStreamPlayer
@export var audio_player_slash: AudioStreamPlayer
@export var bg: ColorRect
@export var timer: Timer


var menu_loader: Node
var music_controller: Node
var level_loader: Node
var save_file: int
var data: Dictionary

var active: bool
var lines: Array
var showing_line: String
var hiding_line: String
var character_index: int
var line_index: int = -1
var sentence_index: int
var line_finished: bool
var showing_continue_icon: bool
var on_last_sentence: bool

var _fading_out: bool
var _ended: bool
var _ending: bool
var _slash_played: bool
var _rise_played: bool
var _lower_played: bool

var _skip_sound: bool

var _pause_queue: bool

const CHARACTER_TIME: float = 0.05
const ARROW_TIME: float = 0.5
const OPENING_TAGS: String = "[center][color=#FFFFFFFF]"
const MIDDLE_TAGS: String = "[/color][color=#FFFFFF00]"
const LAST_SENTENCE_TAGS: String = "[/color][color=#FFFFFF00] >[/color][color=#FFFFFFFF]"
const CLOSING_TAGS: String = "[/color][/center]"

signal line_finished_showing


func _ready():
    label.text = ""


func _input(event: InputEvent) -> void :
    if !active: return
    if !Global.mobile: return

    if event is InputEventScreenTouch:
        Input.action_press("ui_accept")
        get_viewport().set_input_as_handled()
        if !event.pressed:
            Input.action_release("ui_accept")


func _process(_delta: float) -> void :
    if !active: return

    if _pause_queue:
        _pause_queue = false
        if !_fading_out:
            _show_character(false)

    if !Input.is_action_just_pressed("alt_enter") && Input.is_action_just_pressed("ui_accept"):
        if _fading_out:
            _skip_fade_out()
        elif line_finished:
            _show_next_line()
        else:
            _skip_line()



func set_intro():
    _ending = false
    music_controller.stop_music()

    _set_lines()

    _show_next_line()


func set_ending():
    _ending = true
    music_controller.stop_music()

    _set_ending_lines()
    timer.stop()
    timer.start(0.5)
    timer.timeout.connect(_play_end_queen, 4)


func _play_end_queen():
    _play_animation("end_queen")
    timer.stop()
    timer.start(0.5)
    timer.timeout.connect(_show_next_line, 4)


func _show_next_line():
    if _ending && line_index == 1:
        _end_fade_out()
        return
    elif line_index == 8:
        _fade_out()
        return

    if timer && timer.timeout.is_connected(_show_character):
        timer.timeout.disconnect(_show_character)

    line_finished = false
    on_last_sentence = false
    showing_continue_icon = false
    line_index += 1
    sentence_index = 0
    character_index = 0

    lines[line_index][lines[line_index].size() - 1] += " >"

    if lines[line_index].size() - 1 == sentence_index:
        showing_line += LAST_SENTENCE_TAGS
        on_last_sentence = true

    showing_line = ""
    label.text = OPENING_TAGS + showing_line + MIDDLE_TAGS + hiding_line + CLOSING_TAGS

    timer.stop()
    timer.start(ARROW_TIME)
    timer.timeout.connect(_show_character.bind(false), 4)

    _show_illustration(line_index)

func _show_character(skip: bool):
    if !active:
        _pause_queue = true
        return

    var time: float = CHARACTER_TIME

    if character_index == lines[line_index][sentence_index].length() || \
(on_last_sentence && character_index == lines[line_index][sentence_index].length() - 2):
        if lines[line_index].size() - 1 > sentence_index:
            time = ARROW_TIME
            character_index = 0
            showing_line += "\n"
            sentence_index += 1
            if lines[line_index].size() - 1 == sentence_index:
                showing_line += LAST_SENTENCE_TAGS
                on_last_sentence = true
        else:
            time = ARROW_TIME
            if showing_continue_icon:
                showing_line += " >"
                hiding_line = ""
            else:
                if line_finished:
                    showing_line = showing_line.substr(0, showing_line.length() - 2)
                else:
                    line_finished = true
                    line_finished_showing.emit()
                    showing_line = showing_line.substr(0, showing_line.length())
                hiding_line = " >"

            showing_continue_icon = !showing_continue_icon
    else:
        showing_line += lines[line_index][sentence_index][character_index]
        hiding_line = lines[line_index][sentence_index].substr(character_index + 1, -1)
        character_index += 1

        if !_skip_sound:
            _play_sound()
        _skip_sound = !_skip_sound

    label.text = OPENING_TAGS + showing_line + MIDDLE_TAGS + hiding_line + CLOSING_TAGS

    if !skip:
        timer.stop()
        timer.start(time)
        timer.timeout.connect(_show_character.bind(false), 4)


func _skip_line():
    if timer:
        if timer.timeout.is_connected(_show_character):
            timer.timeout.disconnect(_show_character)

        elif timer.timeout.is_connected(_play_end_queen):
            timer.timeout.disconnect(_play_end_queen)
            _play_animation("end_queen")
            if animation_player.current_animation != "":
                animation_player.seek(animation_player.current_animation_length)
            _show_next_line()
            return

        elif timer.timeout.is_connected(_show_next_line):
            timer.timeout.disconnect(_show_next_line)
            _show_next_line()

    if animation_player.current_animation != "":
        animation_player.seek(animation_player.current_animation_length)

    while !line_finished:
        _show_character(true)
    _show_character(false)


func _skip_fade_out():
    if animation_player.current_animation != null:
        animation_player.seek(animation_player.current_animation_length)
    if _ending:
        if timer && timer.timeout.is_connected(_end_ending):
            timer.timeout.disconnect(_end_ending)
        _end_ending()
    else:
        if timer && timer.timeout.is_connected(_end):
            timer.timeout.disconnect(_end)
        _end()


func _show_illustration(_line_index: int):

    if !_ending:
        match _line_index:
            0:
                _play_animation("witch")
            1:
                _play_animation("queen")
            2:
                _play_animation("heirs")
            3:
                _play_animation("queen_wizard")
            5:
                _play_animation("queen_slash")
            7:
                _play_animation("halves")


func _play_animation(animation_name: String):
    animation_player.play(animation_name)


func _fade_out():
    if _fading_out: return
    _fading_out = true

    if timer && timer.timeout.is_connected(_show_character):
        timer.timeout.disconnect(_show_character)

    label.text = ""
    _play_animation("fade_out")

    timer.stop()
    timer.start(1.5)
    timer.timeout.connect(_end, 4)


func _end():
    if _ended: return
    active = false
    _ended = true
    data["intro_cutscene"] = true
    bg.z_index = 10
    data["time"] = level_loader.get_normal_time()
    menu_loader.manage_load_save(save_file, data, false)


func end():
    _end()


func _end_fade_out():
    if _fading_out: return
    _fading_out = true

    if timer && timer.timeout.is_connected(_show_character):
        timer.timeout.disconnect(_show_character)

    label.text = ""
    _play_animation("end_fade_out")

    timer.stop()
    timer.start(1.5)
    timer.timeout.connect(_end_ending, 4)


func _end_ending():
    if _ended: return
    active = false
    _ended = true
    bg.z_index = 10
    menu_loader.manage_load_save(save_file, data, true)


func _set_lines():
    var lang: String = Global.language
    lines.clear()
    lines.append([Global.translations["intro1"][lang]])
    lines.append([Global.translations["intro2"][lang]])
    lines.append([Global.translations["intro3"][lang], Global.translations["intro4"][lang]])
    lines.append([Global.translations["intro5"][lang], Global.translations["intro6"][lang]])
    lines.append([Global.translations["intro7"][lang], Global.translations["intro8"][lang]])
    lines.append([Global.translations["intro9"][lang]])
    lines.append([Global.translations["intro10"][lang]])
    lines.append([Global.translations["intro11"][lang], Global.translations["intro12"][lang]])
    lines.append([Global.translations["intro13"][lang], Global.translations["intro14"][lang]])



func _set_ending_lines():
    var lang: String = Global.language
    lines.clear()
    lines.append([Global.translations["end1"][lang]])
    lines.append([Global.translations["end2"][lang]])



func _play_sound():
    audio_player.pitch_scale = randf_range(0.5, 0.52)
    audio_player.play()


func play_slash():
    if _slash_played: return
    _slash_played = true
    audio_player_slash.play()


func play_rise():
    if _slash_played: return
    _rise_played = true
    audio_player_rise.play()


func play_lower():
    if _slash_played: return
    _lower_played = true
    audio_player_lower.play()
