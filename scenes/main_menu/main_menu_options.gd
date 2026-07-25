extends Node

@export var active: bool = true
@export var horizontal: bool
@export var loop: bool
@export var default_option: int

@export var controller: Node
@export var selection_arrow: Node2D
@export var options: Array[Node]
@export var combo_to_fast_cooldown: Vector2 = Vector2(-1, -1)
@export var menu_allows_quick_actions: bool

var _current_selection: int

var _queue_activation: Array
var _option_to_select: int

var _cooldown_timer: float
var _cooldown_value: float
var _cooldown_combo_x: int
var _cooldown_combo_y: int
var _combo_blocked: bool
const _COOLDOWN_SLOW: float = 0.2
const _COOLDOWN_FAST: float = 0.05

var _ignore_next_option_selection: bool

signal option_selected

func _ready() -> void :
    Global.general_input_controller.device_changed.connect(toggle_selection_arrow)

    if !active: return
    _current_selection = default_option
    select_option.call_deferred(_current_selection)
    _cooldown_value = _COOLDOWN_SLOW


func activate(option_to_select: int):
    _queue_activation.resize(2)
    _option_to_select = option_to_select


func remove_option(index: int):
    options[index].visible = false
    options.remove_at(index)


func _process(delta: float) -> void :
    if _queue_activation.size() > 0:
        _queue_activation.remove_at(0)
        if _queue_activation.size() > 0: return
        select_option(_option_to_select)
        active = true
        return

    if !active: return

    if _cooldown_timer > 0:
        _cooldown_timer -= delta

    if Input.is_action_just_pressed("ui_up"):
        _cooldown_timer = _COOLDOWN_SLOW
        if horizontal:
            _decrease()
        else:
            _select_previous()
    elif Input.is_action_just_pressed("ui_down"):
        _cooldown_timer = _COOLDOWN_SLOW
        if horizontal:
            _increase()
        else:
            _select_next()
    elif Input.is_action_just_pressed("ui_left_quick") && menu_allows_quick_actions:
        _cooldown_timer = _COOLDOWN_SLOW
        if horizontal:
            _select_previous()
        else:
            _decrease_quick()
    elif Input.is_action_just_pressed("ui_right_quick") && menu_allows_quick_actions:
        _cooldown_timer = _COOLDOWN_SLOW
        if horizontal:
            _select_next()
        else:
            _increase_quick()
    elif Input.is_action_just_pressed("ui_left"):
        _cooldown_timer = _COOLDOWN_SLOW
        if horizontal:
            _select_previous()
        else:
            _decrease()
    elif Input.is_action_just_pressed("ui_right"):
        _cooldown_timer = _COOLDOWN_SLOW
        if horizontal:
            _select_next()
        else:
            _increase()
    elif !Input.is_action_just_pressed("alt_enter") && Input.is_action_just_pressed("ui_accept"):
        _cooldown_timer = _cooldown_value
        _accept()


    elif _cooldown_timer <= 0:

        if Input.is_action_pressed("ui_up"):
            if _combo_blocked: return
            _cooldown_timer = _cooldown_value
            _cooldown_combo_y += 1
            if horizontal:
                _decrease()
            else:
                _select_previous()
        elif Input.is_action_pressed("ui_down"):
            if _combo_blocked: return
            _cooldown_timer = _cooldown_value
            _cooldown_combo_y += 1
            if horizontal:
                _increase()
            else:
                _select_next()
        elif Input.is_action_pressed("ui_left_quick") && menu_allows_quick_actions:
            if _combo_blocked: return
            _cooldown_timer = _cooldown_value
            _cooldown_combo_x += 1
            if horizontal:
                _select_previous()
            else:
                _decrease_quick()
        elif Input.is_action_pressed("ui_right_quick") && menu_allows_quick_actions:
            if _combo_blocked: return
            _cooldown_timer = _cooldown_value
            _cooldown_combo_x += 1
            if horizontal:
                _select_next()
            else:
                _increase_quick()
        elif Input.is_action_pressed("ui_left"):
            if _combo_blocked: return
            _cooldown_timer = _cooldown_value
            _cooldown_combo_x += 1
            if horizontal:
                _select_previous()
            else:
                _decrease()
        elif Input.is_action_pressed("ui_right"):
            if _combo_blocked: return
            _cooldown_timer = _cooldown_value
            _cooldown_combo_x += 1
            if horizontal:
                _select_next()
            else:
                _increase()
        elif Input.is_action_just_pressed("ui_cancel"):
            controller.cancel()
        else:
            _combo_blocked = false



    if _cooldown_timer <= 0:
        _cooldown_combo_x = 0
        _cooldown_combo_y = 0
        _cooldown_value = _COOLDOWN_SLOW
    elif _cooldown_combo_x >= combo_to_fast_cooldown.x - 1 && combo_to_fast_cooldown.x != -1:
        _cooldown_value = _COOLDOWN_FAST
    elif _cooldown_combo_y >= combo_to_fast_cooldown.y - 1 && combo_to_fast_cooldown.y != -1:
        _cooldown_value = _COOLDOWN_FAST


func select_option(index: int):
    _current_selection = index
    option_selected.emit.call_deferred(index)

    if options[index] is Marker2D:
        select_marker(options[index])
        return

    var label_center_position_x: float = options[index].get_character_bounds(0).position.x

    if horizontal:
        var separation: float = options[index].get_parent().get_theme_constant("separation")
        var total_labels_size: float
        for i in options.size():
            total_labels_size += options[i].get_total_character_count() * 8
            total_labels_size += separation

        var parent_size: float = options[index].get_parent().size.x
        var first_label_start_position: float = parent_size / 2 + total_labels_size / -2
        var label_start_position: float = first_label_start_position
        for i in options.size():
            if i >= index: break
            label_start_position += options[i].get_total_character_count() * 8
            label_start_position += separation
        label_center_position_x = label_start_position + 50

    else:
        var parent = options[index].get_parent()
        if parent is HBoxContainer:
            var separation: float = parent.get_theme_constant("separation")
            var total_labels_size: float
            var children: Array[Node] = parent.get_children()
            for i in children.size():
                total_labels_size += children[i].get_total_character_count() * 8
                total_labels_size += separation
            total_labels_size -= separation
            var parent_size: float = options[index].get_parent().size.x
            var first_label_start_position: float = parent_size / 2 + total_labels_size / -2
            var label_start_position: float = first_label_start_position
            label_center_position_x = label_start_position

    var distance_from_the_label_center: float = 8 + 6
    var label_y: float = options[index].get_parent().position.y + options[index].position.y
    var center_y: float = ceil(label_y + options[index].size.y / 2 - 3)
    var final_pos: Vector2 = Vector2(options[index].get_parent().size.x / -2 + label_center_position_x - distance_from_the_label_center, center_y)
    selection_arrow.position = final_pos


func change_current_selection_index_manual(new_selection: int):
    _current_selection = new_selection


func select_marker(marker: Marker2D):
    var final_pos: Vector2 = Vector2(marker.global_position.x - 14, marker.global_position.y + 2)
    selection_arrow.global_position = final_pos


func _select_previous():
    if _ignore_next_option_selection:
        _ignore_next_option_selection = false
        return

    _current_selection -= 1
    if _current_selection < 0:
        if loop:
            _current_selection = options.size() - 1
        else:
            _current_selection = 0
    select_option(_current_selection)
    controller.play_selection()


func _select_next():
    if _ignore_next_option_selection:
        _ignore_next_option_selection = false
        return

    _current_selection += 1
    if _current_selection >= options.size():
        if loop:
            _current_selection = 0
        else:
            _current_selection = options.size() - 1
    select_option(_current_selection)
    controller.play_selection()


func _decrease():
    controller.decrease(options[_current_selection].name.to_lower(), _current_selection)


func _increase():
    controller.increase(options[_current_selection].name.to_lower(), _current_selection)


func _decrease_quick():
    controller.decrease_quick(options[_current_selection].name.to_lower(), _current_selection)


func _increase_quick():
    controller.increase_quick(options[_current_selection].name.to_lower(), _current_selection)


func _accept():
    if _ignore_next_option_selection:
        _ignore_next_option_selection = false
        return

    controller.accept_option(options[_current_selection].name.to_lower(), _current_selection)


func accept_from_click(index: int):
    _current_selection = index
    _accept()

func decrease_from_click(index: int):
    _current_selection = index
    _decrease()

func increase_from_click(index: int):
    _current_selection = index
    _increase()


func block_combo():
    _combo_blocked = true


func get_current_selection() -> int:
    return _current_selection


func toggle_selection_arrow(device: int):
    if device == 2:
        selection_arrow.visible = false
    else:
        selection_arrow.visible = true
        select_option(0)
        _ignore_next_option_selection = true
