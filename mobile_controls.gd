extends CanvasLayer
class_name MobileControls

signal move_vector_changed(value: Vector2)
signal look_vector_changed(value: Vector2)
signal fire_pressed
signal jump_pressed
signal reload_pressed
signal grenade_pressed

var enabled_for_mobile := false
var move_vector := Vector2.ZERO

func _ready() -> void:
    enabled_for_mobile = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
    visible = enabled_for_mobile
    if not enabled_for_mobile:
        return
    _create_button("FIRE",Vector2(0.82,0.72),fire_pressed.emit)
    _create_button("JUMP",Vector2(0.91,0.54),jump_pressed.emit)
    _create_button("RELOAD",Vector2(0.72,0.88),reload_pressed.emit)
    _create_button("GRENADE",Vector2(0.90,0.88),grenade_pressed.emit)

func _create_button(caption: String, anchor: Vector2, callback: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.anchor_left = anchor.x-0.06
    button.anchor_right = anchor.x+0.06
    button.anchor_top = anchor.y-0.045
    button.anchor_bottom = anchor.y+0.045
    button.pressed.connect(callback)
    add_child(button)

func set_move_input(value: Vector2) -> void:
    move_vector = value.limit_length(1.0)
    move_vector_changed.emit(move_vector)

func set_look_input(value: Vector2) -> void:
    look_vector_changed.emit(value)
