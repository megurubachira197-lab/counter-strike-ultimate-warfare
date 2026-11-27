extends Control
class_name LoadoutMenu

signal weapon_selected(index: int)
var weapon_catalog: Array = []
var current_category := "Fusil de asalto"

func _ready() -> void:
    anchors_preset = Control.PRESET_FULL_RECT
    var file := FileAccess.open("res://data/weapons.json",FileAccess.READ)
    if file:
        var parsed = JSON.parse_string(file.get_as_text())
        if parsed is Array:
            weapon_catalog = parsed
    _build()

func _build() -> void:
    var panel := PanelContainer.new()
    panel.position = Vector2(30,30)
    panel.size = Vector2(460,600)
    add_child(panel)
    var column := VBoxContainer.new()
    panel.add_child(column)
    var title := Label.new()
    title.text = "ARSENAL / EQUIPAMIENTO"
    title.add_theme_font_size_override("font_size",22)
    column.add_child(title)
    var categories := ["Pistola","Subfusil","Fusil de asalto","Fusil de precisión","Escopeta","Ametralladora ligera","Especial","Cuerpo a cuerpo"]
    var tabs := HFlowContainer.new()
    column.add_child(tabs)
    for category in categories:
        var tab := Button.new()
        tab.text = category
        tab.pressed.connect(_select_category.bind(category))
        tabs.add_child(tab)
    var list := ItemList.new()
    list.name = "WeaponList"
    list.custom_minimum_size = Vector2(420,430)
    column.add_child(list)
    list.item_activated.connect(_on_weapon_activated)
    _populate(list)

func _select_category(category: String) -> void:
    current_category = category
    var list := get_node_or_null("PanelContainer/VBoxContainer/WeaponList")
    if list:
        _populate(list)

func _populate(list: ItemList) -> void:
    list.clear()
    for i in weapon_catalog.size():
        var weapon: Dictionary = weapon_catalog[i]
        if weapon.get("category","") == current_category:
            list.add_item("%s  |  DMG %s  |  RPM %s" % [weapon.get("name","Weapon"),weapon.get("damage",0),weapon.get("rpm",0)])
            list.set_item_metadata(list.item_count-1,i)


func _on_weapon_activated(local_index: int) -> void:
    var list := get_node_or_null("PanelContainer/VBoxContainer/WeaponList")
    if list:
        var global_index: int = int(list.get_item_metadata(local_index))
        weapon_selected.emit(global_index)
