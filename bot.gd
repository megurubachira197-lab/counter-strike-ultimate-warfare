extends CharacterBody3D

signal died

@export var max_health := 100
@export var move_speed := 3.1
@export var attack_range := 18.0
@export var attack_damage := 8
@export var attack_interval := 0.85

var health := 100
var target: Node3D
var attack_timer := 0.0
var strafe_timer := 0.0
var strafe_sign := 1.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var alive := true

func _ready() -> void:
    health = max_health
    add_to_group("enemies")
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.48, 0.16, 0.12)
    $Visual.material_override = mat

func _physics_process(delta: float) -> void:
    if not alive or not is_instance_valid(target):
        return
    attack_timer -= delta
    strafe_timer -= delta
    if strafe_timer <= 0:
        strafe_timer = randf_range(1.0, 2.2)
        strafe_sign = -strafe_sign if randf() > 0.5 else 1.0

    if not is_on_floor():
        velocity.y -= gravity * delta

    var to_target := target.global_position - global_position
    to_target.y = 0
    var distance := to_target.length()
    if distance > 0.1:
        var forward := to_target.normalized()
        look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP)
        var move_dir := Vector3.ZERO
        if distance > 8.0:
            move_dir = forward
        elif distance < 5.0:
            move_dir = -forward * 0.55
        else:
            move_dir = Vector3(-forward.z, 0, forward.x) * strafe_sign * 0.45
        velocity.x = move_dir.x * move_speed
        velocity.z = move_dir.z * move_speed
        if distance <= attack_range and attack_timer <= 0 and _has_line_of_sight():
            attack_timer = attack_interval
            if target.has_method("take_damage"):
                target.take_damage(attack_damage)
    move_and_slide()

func _has_line_of_sight() -> bool:
    var space := get_world_3d().direct_space_state
    var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, target.global_position + Vector3.UP * 1.3)
    query.exclude = [self]
    var result := space.intersect_ray(query)
    return result.is_empty() or result.collider == target

func take_damage(amount: int, _attacker_position: Vector3 = Vector3.ZERO) -> void:
    if not alive:
        return
    health -= amount
    if health <= 0:
        alive = false
        died.emit()
        queue_free()
