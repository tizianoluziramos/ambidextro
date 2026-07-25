extends RayCast2D


func is_hit() -> bool:
    force_raycast_update()
    if is_colliding():
        return true
    return false
