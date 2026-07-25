extends Control

@export var number: int
@export var number_label: Label
@export var key_label: Label
@export var color_rect: ColorRect


func _ready() -> void :
    number_label.text = str(number)
    key_label.text = ""
