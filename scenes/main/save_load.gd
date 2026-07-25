extends Node

@export var steam_manager: Node

var _file_name: = "save.tres"
var _persistent_path: = "user://"
var _settings_path: = "user://settings.tres"
var _shared_path: = "user://shared_save_files/"
var _steam_path: = "user://steam_save_files/"
var _portable_path: String
var _selected_full_path: String
var _shared_full_path: String
var _save_data: SaveData
var _settings_data: SaveData


func _ready():
    if OS.has_feature("editor"):
        _portable_path = "res://"
    else:
        _portable_path = OS.get_executable_path().get_base_dir() + "/"

    _check_path()
    load_settings()
    load_data()


    _unlock_achievements.call_deferred()







func _check_path():
    _shared_full_path = _shared_path + _file_name

    if Global.steam:
        _selected_full_path = _steam_path + _file_name
        return


    DirAccess.make_dir_absolute(_shared_path)


    var empty_file_path: = _portable_path + "permissions_check.tres"
    var empty_data: SaveData = SaveData.new()
    var error: = ResourceSaver.save(empty_data, empty_file_path)
    if error:
        _selected_full_path = _persistent_path + _file_name
        print("Write test failed. Using persistent path. Failed path: ", empty_file_path, " . Changed to path: ", _selected_full_path)

        if !FileAccess.file_exists(_selected_full_path):
            _copy_shared_save(false)
        return


    if !FileAccess.file_exists(empty_file_path):
        _selected_full_path = _persistent_path + _file_name
        print("Read test failed. Using persistent path. Failed path: ", empty_file_path, " . Changed to path: ", _selected_full_path)

        if !FileAccess.file_exists(_selected_full_path):
            _copy_shared_save(false)
        return


    var dir: = DirAccess.open(empty_file_path.get_base_dir())
    if !dir:
        print("Delete test failed. Error: ", DirAccess.get_open_error(), ". Path: ", empty_file_path)
    else:
        dir.remove(empty_file_path)

    _selected_full_path = _portable_path + _file_name
    print("Read/write tests successful. Using portable path. Path: ", _selected_full_path)


    if !FileAccess.file_exists(_selected_full_path):
        _copy_shared_save(true)


func _copy_shared_save(to_portable: bool):

    if FileAccess.file_exists(_shared_full_path):

        _selected_full_path = _shared_full_path
        load_data()
        if to_portable:
            _selected_full_path = _portable_path + _file_name
        else:
            _selected_full_path = _persistent_path + _file_name
        var error: = ResourceSaver.save(_save_data, _selected_full_path)
        if error: print("Error saving the copy of shared save: ", error, ". Shared path: ", _shared_full_path, " . Destination path: ", _selected_full_path)
        else: print("Copied save file from shared path to destination path. Shared path: ", _shared_full_path, " Destination path: ", _selected_full_path)


func update_default_save_file(new_file: int):
    _save_data.data["default_save_file"] = new_file


func save_data(value_name: String, value):
    _save_data.data[value_name] = value
    var error: = ResourceSaver.save(_save_data, _selected_full_path)
    if error: print("Error saving: ", error, ". Path: ", _selected_full_path)

    if !Global.steam:
        error = ResourceSaver.save(_save_data, _shared_full_path)
        if error: print("Error saving: ", error, ". Path: ", _shared_full_path)


func save_settings(value_name: String, value):
    _settings_data.data[value_name] = value
    var error: = ResourceSaver.save(_settings_data, _settings_path)
    if error: print("Error saving settings: ", error, ". Path: ", _settings_path)



func delete_data(value_name: String):
    _save_data.data.erase(value_name)
    var error: = ResourceSaver.save(_save_data, _selected_full_path)
    if error: print("Error saving deleted data: ", error, ". Path: ", _selected_full_path)


func delete_settings(value_name: String):
    _settings_data.data.erase(value_name)
    var error: = ResourceSaver.save(_settings_data, _settings_path)
    if error: print("Error saving deleted settings data: ", error, ". Path: ", _settings_path)







func load_data():
    if FileAccess.file_exists(_selected_full_path):
        _save_data = ResourceLoader.load(_selected_full_path)
        if !_save_data:
            print("Error loading data.", ". Path: ", _selected_full_path)
            create_default_data()
        elif !_save_data.data || !_save_data.data.has("default_save_file"):
            return create_default_data()
    else:
        return create_default_data()


func load_settings():
    if FileAccess.file_exists(_settings_path):
        _settings_data = ResourceLoader.load(_settings_path)
        if !_settings_data:
            print("Error loading settings.", ". Path: ", _settings_path)
            return create_default_settings_data()
        elif !_settings_data.data || !_settings_data.data.has("language"):
            return create_default_settings_data()
    else:
        return create_default_settings_data()

    Global.language = _settings_data.data.get("language", "en")


func create_default_data():
    var dic: Dictionary
    dic["default_save_file"] = 1

    var dic2: Dictionary
    dic2["fullscreen"] = true
    dic2["window_resolution"] = Vector2i(448, 256)
    dic2["pixel_perfect"] = false
    dic2["shader_curvature"] = true
    dic2["shader_scanlines"] = true
    dic2["shader_distortion"] = true
    dic2["shader_aberration"] = true
    dic["video"] = dic2

    var dic3: Dictionary
    dic["achievements"] = dic3

    Global.extra_time = 0

    Global.speedrun_mode = false
    Global.speedrun_pausable = false

    var lang: String = OS.get_locale_language()
    if lang in ["ca", "cat", "eu", "eus"]:
        lang = "es"
    if lang not in ["en", "es"]:
        lang = "en"
    dic["language"] = lang
    Global.language = lang

    _save_data = SaveData.new()
    _save_data.data = dic

    var error: = ResourceSaver.save(_save_data, _selected_full_path)
    if error: print("Error saving default data: ", error, ". Path: ", _selected_full_path)

    return load_data()


func create_default_settings_data():
    var dic: Dictionary

    var dic2: Dictionary
    dic2["fullscreen"] = true
    dic2["window_resolution"] = Vector2i(448, 256)
    dic2["pixel_perfect"] = false
    dic2["shader_curvature"] = true
    dic2["shader_scanlines"] = true
    dic2["shader_distortion"] = true
    dic2["shader_aberration"] = true
    dic["video"] = dic2

    Global.extra_time = 0

    Global.speedrun_mode = false
    Global.speedrun_pausable = false

    var lang: String = OS.get_locale_language()
    if lang in ["ca", "cat", "eu", "eus"]:
        lang = "es"
    if lang not in ["en", "es"]:
        lang = "en"
    dic["language"] = lang
    Global.language = lang

    _settings_data = SaveData.new()
    _settings_data.data = dic

    var error: = ResourceSaver.save(_settings_data, _settings_path)
    if error: print("Error saving default settings data: ", error, ". Path: ", _settings_path)

    return load_settings()


func _unlock_achievements():
    if Global.steam && _save_data.data.has("achievements"):
        steam_manager.unlock_achievements(_save_data.data["achievements"])


func unlock_last_level():
    _save_data.data["last_level"] = true

    var error: = ResourceSaver.save(_save_data, _selected_full_path)
    if error: print("Error saving last level unlock: ", error, ". Path: ", _selected_full_path)


func is_last_level_unlocked() -> bool:
    return _save_data.data.has("last_level")


func get_loaded_data() -> Dictionary:
    return _save_data.data.duplicate()

func get_loaded_settings() -> Dictionary:
    return _settings_data.data.duplicate()


func delete_save_file(save_file_numer: int):
    var key: String = "save_file_" + str(save_file_numer)
    var dic: Dictionary
    dic["level"] = 0
    dic["retries"] = 0
    dic["time"] = 0
    dic["speedrun_time"] = 0
    dic["ended"] = false
    save_data(key, dic.duplicate())
    load_data()


func delete_save_file_preserving_modifiers(save_file_numer: int):
    var key: String = "save_file_" + str(save_file_numer)
    var dic: Dictionary = _save_data.data[key]
    dic["level"] = 0
    dic["retries"] = 0
    dic["time"] = 0
    dic["speedrun_time"] = 0
    if dic.has("intro_cutscene"):
        dic.erase("intro_cutscene")
    dic["ended"] = false
    save_data(key, dic.duplicate())
    load_data()
