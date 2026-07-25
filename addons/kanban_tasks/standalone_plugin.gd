

@tool
extends EditorPlugin




















const CONTAINER_LAUNCH_PAD: = 12


func save_project_settings() -> int:
    return ProjectSettings.save()


func add_menu(menu: PopupMenu) -> void :
    pass


func remove_menu(menu: PopupMenu) -> void :
    pass
