extends Node3D

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const BOT_SCENE := preload("res://scenes/bot.tscn")

var player
var bots: Array = []
var score := 0
var hud_label: Label
var status_label: Label

func _ready() -> void:
    _build_environment()
    _build_map()
    player = PLAYER_SCENE.instantiate()
    add_child(player)
    player.global_position = Vector3(0, 1.1, 8)
    player.bot_killed.connect(_on_bot_killed)
    _spawn_bots(5)
    _build_hud()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.sky.sky_material = ProceduralSkyMaterial.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.48, 0.52, 0.58)
    env.ambient_light_energy = 0.7
    world.environment = env
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.2
    sun.shadow_enabled = true
    add_child(sun)

func _make_box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, name: String = "Block") -> StaticBody3D:
    var body := StaticBody3D.new()
    body.name = name
    body.position = pos
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.82
    mesh.material_override = mat
    body.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    parent.add_child(body)
    return body

func _build_map() -> void:
    _make_box(self, Vector3(0, -0.5, 0), Vector3(42, 1, 42), Color(0.20, 0.23, 0.24), "ArenaFloor")
    var wall := Color(0.34, 0.36, 0.35)
    _make_box(self, Vector3(0, 2, -21), Vector3(42, 4, 1), wall)
    _make_box(self, Vector3(0, 2, 21), Vector3(42, 4, 1), wall)
    _make_box(self, Vector3(-21, 2, 0), Vector3(1, 4, 42), wall)
    _make_box(self, Vector3(21, 2, 0), Vector3(1, 4, 42), wall)
    # Three lanes, mid cover, and elevated sightline blockers for a first competitive greybox.
    _make_box(self, Vector3(-8, 1, -5), Vector3(2, 2, 7), Color(0.42, 0.34, 0.25), "Crate_A")
    _make_box(self, Vector3(8, 1, 5), Vector3(2, 2, 7), Color(0.42, 0.34, 0.25), "Crate_B")
    _make_box(self, Vector3(0, 1, 0), Vector3(6, 2, 2), Color(0.30, 0.34, 0.36), "Mid_Cover")
    _make_box(self, Vector3(-13, 1.5, 10), Vector3(4, 3, 3), Color(0.36, 0.38, 0.39), "Container")
    _make_box(self, Vector3(13, 1.5, -10), Vector3(4, 3, 3), Color(0.36, 0.38, 0.39), "Container")

func _spawn_bots(amount: int) -> void:
    var spots := [Vector3(-13, 0.1, -13), Vector3(13, 0.1, -13), Vector3(-13, 0.1, 13), Vector3(13, 0.1, 13), Vector3(0, 0.1, -15)]
    for i in amount:
        var bot = BOT_SCENE.instantiate()
        add_child(bot)
        bot.global_position = spots[i % spots.size()]
        bot.target = player
        bot.died.connect(_on_bot_killed)
        bots.append(bot)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    hud_label = Label.new()
    hud_label.position = Vector2(22, 18)
    hud_label.add_theme_font_size_override("font_size", 20)
    hud_label.add_theme_color_override("font_color", Color.WHITE)
    layer.add_child(hud_label)
    status_label = Label.new()
    status_label.anchor_left = 0.5
    status_label.anchor_top = 1.0
    status_label.anchor_right = 0.5
    status_label.anchor_bottom = 1.0
    status_label.position = Vector2(-180, -65)
    status_label.add_theme_font_size_override("font_size", 18)
    status_label.add_theme_color_override("font_color", Color.WHITE)
    status_label.text = "WASD mover  •  Ratón apuntar  •  Click disparar  •  R recargar  •  Espacio saltar"
    layer.add_child(status_label)

func _process(_delta: float) -> void:
    if is_instance_valid(player) and hud_label:
        hud_label.text = "COUNTER STRIKE: ULTIMATE WARFARE     |     HP: %d     |     BALAS: %d/%d     |     ELIMINACIONES: %d" % [player.health, player.ammo, player.magazine_size, score]

func _on_bot_killed() -> void:
    score += 1
