extends Node
class_name WeaponSystem

signal ammo_changed(current: int, capacity: int)
signal weapon_changed(weapon: Dictionary)
signal shot_fired(hit_position: Vector3, hit_something: bool)

var catalog: Array = []
var current_index := 0
var ammo := 0
var reserve_ammo := 120
var reloading := false
var cooldown := 0.0
var recoil_pitch := 0.0
var recoil_yaw := 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    var file := FileAccess.open("res://data/weapons.json", FileAccess.READ)
    if file:
        var parsed = JSON.parse_string(file.get_as_text())
        if parsed is Array:
            catalog = parsed
    if not catalog.is_empty():
        ammo = int(current_weapon().get("magazine", 30))
        weapon_changed.emit(current_weapon())
        ammo_changed.emit(ammo, int(current_weapon().get("magazine", 30)))

func current_weapon() -> Dictionary:
    if catalog.is_empty():
        return {"name":"Training Rifle","damage":34,"rpm":600,"magazine":30,"recoil":1.0,"spread":1.0,"range_m":100}
    return catalog[clampi(current_index, 0, catalog.size()-1)]

func select_weapon(index: int) -> void:
    if index < 0 or index >= catalog.size() or reloading:
        return
    current_index = index
    ammo = int(current_weapon().get("magazine", 30))
    weapon_changed.emit(current_weapon())
    ammo_changed.emit(ammo, int(current_weapon().get("magazine", 30)))

func tick(delta: float) -> void:
    cooldown = maxf(0.0, cooldown-delta)
    recoil_pitch = move_toward(recoil_pitch, 0.0, delta*2.8)
    recoil_yaw = move_toward(recoil_yaw, 0.0, delta*2.2)

func fire(origin: Vector3, direction: Vector3, shooter: Node) -> Dictionary:
    if cooldown > 0.0 or reloading or ammo <= 0:
        return {"fired":false}
    var weapon := current_weapon()
    if weapon.get("category","") == "Cuerpo a cuerpo":
        return {"fired":false, "melee":true}
    ammo -= 1
    cooldown = 60.0 / maxf(1.0, float(weapon.get("rpm",600)))
    var spread := float(weapon.get("spread",1.0)) * 0.0018
    var shot_dir := (direction + Vector3(rng.randf_range(-spread,spread),rng.randf_range(-spread,spread),rng.randf_range(-spread,spread))).normalized()
    var query := PhysicsRayQueryParameters3D.create(origin, origin + shot_dir * float(weapon.get("range_m",100)))
    query.exclude = [shooter]
    var result := shooter.get_world_3d().direct_space_state.intersect_ray(query)
    var hit_pos: Vector3 = result.get("position", origin + shot_dir * 100.0)
    if not result.is_empty():
        var collider = result.get("collider")
        if collider and collider.has_method("take_damage"):
            collider.take_damage(int(weapon.get("damage",30)), shooter.global_position)
    recoil_pitch += float(weapon.get("recoil",1.0))*0.0015
    recoil_yaw += rng.randf_range(-1.0,1.0)*float(weapon.get("recoil",1.0))*0.001
    ammo_changed.emit(ammo, int(weapon.get("magazine",30)))
    shot_fired.emit(hit_pos, not result.is_empty())
    return {"fired":true,"hit":not result.is_empty(),"position":hit_pos,"weapon":weapon}

func reload() -> void:
    if reloading or ammo >= int(current_weapon().get("magazine",30)) or reserve_ammo <= 0:
        return
    reloading = true
    var capacity := int(current_weapon().get("magazine",30))
    var missing := capacity-ammo
    await get_tree().create_timer(1.35).timeout
    var loaded := mini(missing,reserve_ammo)
    ammo += loaded
    reserve_ammo -= loaded
    reloading = false
    ammo_changed.emit(ammo,capacity)
