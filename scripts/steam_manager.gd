extends Node


@export var save_load: Node
var _steam_initialized: bool


func _ready() -> void :
	if Global.steam:
		initialize_steam()


func initialize_steam() -> void :
	Global.steam_manager = self
	var initialize_response: Dictionary = Steam.steamInitEx(3445580)
	print("Did Steam initialize?: %s " % initialize_response, " (0 = yes)")
	if initialize_response["status"] == 0:
		_steam_initialized = true






func unlock_achievements(achievements_dictionary: Dictionary) -> void :
	if !_steam_initialized: return
	for achievement in achievements_dictionary:
		print("unlocked achievement: ", achievement)
		Steam.setAchievement(achievement)
		Steam.storeStats()
