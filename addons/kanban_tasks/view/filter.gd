@tool
extends RefCounted




var text: String

var advanced: bool


func _init(p_text: String = "", p_advanced: bool = false) -> void :
    text = p_text
    advanced = p_advanced
