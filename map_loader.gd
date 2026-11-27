extends Node
class_name MapLoader

signal map_loaded(map_data: Dictionary)

var maps: Array = []

func _ready() -> void:
    var f := FileAccess.open("res://data/maps.json",FileAccess.READ)
    if f:
        var parsed = JSON.parse_string(f.get_as_text())
        if parsed is Array:
            maps = parsed

func get_map(index: int) -> Dictionary:
    if index < 0 or index >= maps.size():
        return {}
    return maps[index]

func load_map_definition(index: int) -> Dictionary:
    var data := get_map(index)
    if not data.is_empty():
        map_loaded.emit(data)
    return data
