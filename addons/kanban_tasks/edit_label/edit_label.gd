@tool
extends VBoxContainer
















signal text_changed(new_text: String)


enum INTENTION{
    REPLACE, 
    ADDITION, 
}


@export var text: String = "":
    set(value):
        text = value
        __update_content()
        text_changed.emit(text)


@export var default_intention: = INTENTION.ADDITION



@export var double_click: bool = true


var __edit: LineEdit


var __label: Label



var __old_focus: Control = null


func _ready() -> void :
    alignment = BoxContainer.ALIGNMENT_CENTER
    mouse_filter = Control.MOUSE_FILTER_PASS


    __label = Label.new()
    __label.size_flags_horizontal = SIZE_EXPAND_FILL
    __label.size_flags_vertical = SIZE_SHRINK_CENTER
    __label.mouse_filter = Control.MOUSE_FILTER_PASS

    __label.clip_text = true
    __label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

    __label.gui_input.connect(__on_label_gui_input)
    add_child(__label)


    __edit = LineEdit.new()
    __edit.visible = false
    __edit.size_flags_horizontal = SIZE_EXPAND_FILL
    __edit.size_flags_vertical = SIZE_FILL
    __edit.text_submitted.connect(__on_edit_text_submitted)
    __edit.gui_input.connect(__on_edit_gui_input)
    __edit.focus_exited.connect(__on_edit_focus_exited, CONNECT_DEFERRED)
    add_child(__edit)

    __update_content()


    await get_tree().create_timer(0.0).timeout

    custom_minimum_size.y = max(__label.size.y, __edit.size.y) * 1.1


func _input(event: InputEvent) -> void :

    if (event is InputEventMouseButton) and event.pressed and __edit.visible:
        var local = __edit.make_input_local(event)
        if not Rect2(Vector2.ZERO, __edit.size).has_point(local.position):
            show_label()




func show_edit(intention: INTENTION = default_intention) -> void :
    if __edit.visible:
        return



    __old_focus = get_viewport().gui_get_focus_owner() if focus_mode == FOCUS_NONE else null

    __update_content()
    __label.visible = false
    __edit.visible = true

    __edit.grab_focus()

    match intention:
        INTENTION.ADDITION:
            __edit.caret_column = len(__edit.text)
        INTENTION.REPLACE:
            __edit.select_all()





func show_label(apply_changes: bool = true) -> void :
    if __label.visible:
        return

    if apply_changes:
        text = __edit.text

    if is_instance_valid(__old_focus):
        __old_focus.grab_focus()
    else:
        if focus_mode == FOCUS_NONE:
            __edit.release_focus()
        else:
            grab_focus()

    __edit.visible = false
    __label.visible = true







func get_edit() -> LineEdit:
    return __edit







func get_label() -> Label:
    return __label




func __update_content() -> void :
    if __label:
        __label.text = text
    if __edit:
        __edit.text = text


func __on_label_gui_input(event: InputEvent) -> void :

    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            if double_click == event.is_double_click():

                __label.accept_event()
                show_edit()


func __on_edit_gui_input(event: InputEvent) -> void :

    if event is InputEventKey and event.is_pressed():
        if event.is_action(&"ui_cancel"):
            show_label(false)


func __on_edit_text_submitted(_new_text: String) -> void :

    __edit.accept_event()
    show_label()


func __on_edit_focus_exited() -> void :
    if __edit.visible:
        __old_focus = null
        show_label()
