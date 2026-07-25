extends RayCast2D

func get_hit_position():
    force_raycast_update()
    if is_colliding():
        var point: Vector2 = get_collision_point()
        return point
    return null


func get_hit_body():
    force_raycast_update()
    return get_collider()
