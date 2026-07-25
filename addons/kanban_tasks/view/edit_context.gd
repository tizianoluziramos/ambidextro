@tool
extends Node




const __Filter: = preload("filter.gd")
const __SettingData: = preload("../data/settings.gd")

signal filter_changed()
signal save_board()
signal create_board()
signal reload_board()


var filter: __Filter = null:
    set(value):
        filter = value
        filter_changed.emit()


var undo_redo: = UndoRedo.new()



var focus: String = ""


var settings: = __SettingData.new()
