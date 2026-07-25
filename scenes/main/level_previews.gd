extends Node

var previews: Array[CompressedTexture2D]
var previews_mirror: Array[CompressedTexture2D]
var previews_swap: Array[CompressedTexture2D]
var previews_mirror_swap: Array[CompressedTexture2D]

const _PATH_OPENING: String = "res://assets/level_previews/"
const _PATH_ENDING: String = ".png"

func _ready():
    await get_tree().create_timer(1.0).timeout
    previews.resize(102)
    previews_mirror.resize(102)
    previews_swap.resize(102)
    previews_mirror_swap.resize(102)
    var file_name: String
    var path: String
    var texture
    var level_number: int

    for i in 102:
        file_name = "level" + str(i)
        path = _PATH_OPENING + file_name + _PATH_ENDING
        texture = load(path)
        previews[i] = texture

        file_name = "level" + str(i) + "_mirror"
        path = _PATH_OPENING + file_name + _PATH_ENDING
        texture = load(path)
        previews_mirror[i] = texture
        file_name = "level" + str(i) + "_swap"
        path = _PATH_OPENING + file_name + _PATH_ENDING
        texture = load(path)
        previews_swap[i] = texture

        file_name = "level" + str(i) + "_mirror_swap"
        path = _PATH_OPENING + file_name + _PATH_ENDING
        texture = load(path)
        previews_mirror_swap[i] = texture
