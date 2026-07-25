extends Node2D


@export var number_labels: Array[Label]
@export var total_label: Label
@export var audio_chains: AudioStreamPlayer
@export var same_level_timer: Timer
@export var control: Control
var audio: AudioStreamPlayer
var timer: Timer
var timer_audio: Timer
var _destroy_next_frame: bool


func _ready():
    if Global.mobile:
        control.position.y += 30


func _process(_delta: float) -> void :
    if _destroy_next_frame:
        _destroy_next_frame = false
        queue_free()


func set_level_number(number: String):
    number_labels[0].text = number[0]
    number_labels[1].text = number[1]
    number_labels[2].text = number[2]


func change_level_to_number(number: String) -> Signal:
    var ended_signal: Signal
    var different_numbers: int = 0
    for i in 3:
        if number_labels[i].text != number[i]:
            different_numbers += 1
            ended_signal = number_labels[i].change_to(number[i])


    if different_numbers == 0:
        ended_signal = number_labels[2].change_to(number[2])

    timer = Timer.new()
    timer.one_shot = true
    ended_signal.connect(_start_timer)

    _start_audio_timer.call_deferred()
    _play_audio_chains.call_deferred()

    timer.timeout.connect(_destroy)
    return timer.timeout


func _start_timer():
    _bounce()
    add_child(timer)
    timer.start(0.8)

func _bounce():
    for number in number_labels:
        number.bounce()
    total_label.bounce()


func _start_audio_timer():
    timer_audio = Timer.new()
    timer_audio.one_shot = true
    add_child(timer_audio)
    timer_audio.start(0.8)
    timer_audio.timeout.connect(_play_audio, 4)


func _play_audio():
    audio.play()


func _play_audio_chains():
    audio_chains.play()


func _destroy():
    queue_free()


func get_signal() -> Signal:
    return timer.timeout
