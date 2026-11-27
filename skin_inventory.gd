extends Node
class_name SkinInventory

signal inventory_changed
var all_skins: Array = []
var unlocked_ids: Array[int] = [1,2,3]
var equipped_by_weapon: Dictionary = {}

func _ready() -> void:
    var f := FileAccess.open("res://data/skins.json",FileAccess.READ)
    if f:
        var parsed = JSON.parse_string(f.get_as_text())
        if parsed is Array:
            all_skins = parsed

func unlock_skin(skin_id: int) -> bool:
    if skin_id < 1 or skin_id > all_skins.size() or unlocked_ids.has(skin_id):
        return false
    unlocked_ids.append(skin_id)
    inventory_changed.emit()
    return true

func equip_skin(weapon_id: int, skin_id: int) -> bool:
    if not unlocked_ids.has(skin_id):
        return false
    equipped_by_weapon[weapon_id] = skin_id
    inventory_changed.emit()
    return true
