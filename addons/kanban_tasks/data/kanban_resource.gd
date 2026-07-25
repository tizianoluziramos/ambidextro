@tool
extends RefCounted





signal changed()

var __emit_changed: = true


func _init() -> void :
    pass



func to_json() -> Dictionary:
    push_error("Method to_json not implemented.")
    return {}



func from_json(json: Dictionary) -> void :
    push_error("Method from_json not implemented.")


func __notify_changed() -> void :
    if __emit_changed:
        changed.emit()
