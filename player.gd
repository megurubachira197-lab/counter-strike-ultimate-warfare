extends CharacterBody3D

signal bot_killed

@export var walk_speed := 6.0
@export var sprint_speed := 8.2
@export var crouch_speed := 3.0
@export var jump_velocity := 4.8
@export var mouse_sensitivity := 0.0022
@export var magazine_size := 30
@export var reload_seconds := 1.45
@export var damage := 34

var health := 100
var ammo := 30
var is_reloading := false
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var pitch := 0.0
var fire_cooldown := 0.0
var weapon_system: WeaponSystem
var weapon_view: WeaponViewModel
var grenade_cooldown := 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var weapon_ray: RayCast3D = $Head/Camera3D/WeaponRay

func _ready() -> void:
    ammo = magazine_size
    add_to_group("player")
    weapon_system = WeaponSystem.new()
    weapon_view = WeaponViewModel.new()
    camera.add_child(weapon_view)
    weapon_system.weapon_changed.connect(_on_weapon_changed)
    weapon_system.ammo_changed.connect(_on_ammo_changed)
    add_child(weapon_system)
    _on_weapon_changed(weapon_system.current_weapon())

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pitch = clampf(pitch - event.relative.y * mouse_sensitivity, -1.45, 1.45)
        head.rotation.x = pitch
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    grenade_cooldown = maxf(0.0, grenade_cooldown - delta)
    if weapon_system:
        weapon_system.tick(delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if Input.is_action_just_pressed("jump") and is_on_floor() and not Input.is_action_pressed("crouch"):
        velocity.y = jump_velocity

    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    var speed := walk_speed
    if Input.is_action_pressed("move_forward") and Input.is_key_pressed(KEY_SHIFT):
        speed = sprint_speed
    if Input.is_action_pressed("crouch"):
        speed = crouch_speed
    if direction:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, speed * 8 * delta)
        velocity.z = move_toward(velocity.z, 0, speed * 8 * delta)

    if Input.is_action_just_pressed("reload"):
        reload_weapon()
    if Input.is_action_just_pressed("throw_grenade"):
        throw_grenade()
    if Input.is_action_pressed("fire"):
        shoot()
    move_and_slide()

func shoot() -> void:
    if weapon_system == null:
        return
    var result := weapon_system.fire(camera.global_position,-camera.global_transform.basis.z,self)
    if result.get("fired",false) and weapon_view:
        weapon_view.play_recoil(float(result.weapon.get("recoil",1.0))*0.025)

func reload_weapon() -> void:
    if weapon_system:
        weapon_system.reload()

func throw_grenade() -> void:
    if grenade_cooldown > 0.0:
        return
    grenade_cooldown = 1.0
    var grenade := GrenadeProjectile.new()
    grenade.grenade_kind = "Frag"
    get_tree().current_scene.add_child(grenade)
    grenade.global_position = camera.global_position + -camera.global_transform.basis.z * 0.7
    grenade.apply_central_impulse(-camera.global_transform.basis.z * 8.0 + Vector3.UP * 3.2)

func _on_weapon_changed(data: Dictionary) -> void:
    if weapon_view:
        weapon_view.build(data)

func _on_ammo_changed(current: int, capacity: int) -> void:
    ammo = current
    magazine_size = capacity

func take_damage(amount: int) -> void:
    health = maxi(0, health - amount)
    if health == 0:
        health = 100
        global_position = Vector3(0, 1.1, 8)
