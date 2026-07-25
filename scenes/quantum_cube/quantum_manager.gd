extends Node


var _quantum_cubes: Array[Node]


func _ready() -> void :
    add_to_group("quantum_manager")
    _quantum_cubes = get_children()


func initialize(previous_states: Array[bool]) -> Array[bool]:
    var cubes_states: Array[bool]
    var indexes: Array[int]
    var holes: int

    for i in _quantum_cubes.size():

        indexes.append(i)

        if !_quantum_cubes[i].start_active:
            _quantum_cubes[i].enable()
            holes += 1

        cubes_states.append(true)


    var control: int
    var different: bool
    while !different:
        indexes.shuffle()

        for i in holes:
            if previous_states[indexes[i]] == true:
                different = true
                break

        control += 1
        if control > 100: break



    for i in holes:
        _quantum_cubes[indexes[i]].disable()
        cubes_states[indexes[i]] = false

    return cubes_states


func get_cubes_states() -> Array[bool]:
    var cubes_states: Array[bool]
    for i in _quantum_cubes.size():
        if _quantum_cubes[i].start_active:
            cubes_states.append(true)
        else:
            cubes_states.append(false)

    return cubes_states
