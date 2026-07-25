@tool
extends Node2D

@export var cube: bool = false:
    set(value):
        cube = value
        set_cube(value)

@export var start_active: bool = true:
    set(value):
        start_active = value
        if value:
            enable()
        else:
            disable()

@export var quantum_cubes: Array[Node]


func enable():
    for cube in quantum_cubes:
        cube.start_active = true


func disable():
    for cube in quantum_cubes:
        cube.start_active = false


func set_cube(value: bool):
    for cube in quantum_cubes:
        cube.cube = value
