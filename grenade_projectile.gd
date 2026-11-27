extends RigidBody3D
class_name GrenadeProjectile

@export var grenade_kind := "Frag"
@export var fuse := 2.8
@export var blast_radius := 7.0
@export var blast_damage := 90
var elapsed := 0.0
var detonated := false

func _ready() -> void:
    mass = 0.45
    linear_damp = 0.1
    angular_damp = 0.2
    var mesh := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.11
    sphere.height = 0.22
    mesh.mesh = sphere
    var mat := StandardMaterial3D.new()
    mat.albedo_color = _kind_color()
    mat.metallic = 0.55
    mesh.material_override = mat
    add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.11
    collision.shape = shape
    add_child(collision)

func _physics_process(delta: float) -> void:
    elapsed += delta
    if elapsed >= fuse and not detonated:
        detonate()

func _kind_color() -> Color:
    match grenade_kind:
        "Smoke": return Color(0.5,0.55,0.58)
        "Flash": return Color(0.95,0.9,0.55)
        "Incendiary": return Color(0.95,0.25,0.08)
        "Decoy": return Color(0.9,0.65,0.18)
        _: return Color(0.24,0.32,0.22)

func detonate() -> void:
    detonated = true
    if grenade_kind in ["Frag","Incendiary"]:
        for enemy in get_tree().get_nodes_in_group("enemies"):
            if enemy is Node3D and enemy.has_method("take_damage"):
                var distance := global_position.distance_to(enemy.global_position)
                if distance <= blast_radius:
                    var damage := blast_damage if grenade_kind == "Frag" else 28
                    enemy.take_damage(int(damage * (1.0-distance/blast_radius)),global_position)
    var light := OmniLight3D.new()
    light.position = global_position
    light.light_color = _kind_color()
    light.light_energy = 4.0
    light.omni_range = blast_radius
    get_tree().current_scene.add_child(light)
    get_tree().create_timer(0.3 if grenade_kind == "Frag" else 2.0).timeout.connect(light.queue_free)
    queue_free()
