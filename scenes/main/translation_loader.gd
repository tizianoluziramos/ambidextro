extends Node

@export var main_theme: Theme
@export var secondary_theme: Theme

var file_path: String = "res://assets/texts/text.csv"
var folder_path: String = "res://assets/texts"
var translations: Dictionary


func _ready() -> void :
    Global.main_theme = main_theme
    Global.secondary_theme = secondary_theme
    _parse_file()


func _parse_file():
    var csv_array: Array[PackedStringArray]
    var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)

    while !file.eof_reached():
        var csv_rows: PackedStringArray = file.get_csv_line(",")
        csv_array.append(csv_rows)
    file.close()

    var languages: Array[String]
    for i in csv_array[0].size():
        if i == 0: continue
        languages.append(csv_array[0][i])

    for line in csv_array:
        if line[0].is_empty(): continue

        var dic: Dictionary
        for i in languages.size():
            if line[0] == "id":
                Global.languages.append(line[i + 1])

            if line.size() > i + 1 && !line[i + 1].is_empty():
                dic[languages[i]] = line[i + 1]
            else:

                dic[languages[i]] = line[1]
        translations[line[0]] = dic

    Global.translations = translations
