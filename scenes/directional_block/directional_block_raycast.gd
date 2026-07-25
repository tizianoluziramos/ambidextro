extends RayCast2D


func get_wall_position() -> Vector2:
    return get_collision_point()
